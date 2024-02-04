#pragma once

// https://www.pcg-random.org/
uint pcg1d(uint v)
{
    uint state = v * 747796405u + 2891336453u;
    uint word = ((state >> ((state >> 28u) + 4u)) ^ state) * 277803737u;
    return (word >> 22u) ^ word;
}
float pcg1(float v)
{
    return pcg1d(asuint(v)) / float(-1u);
}
uint2 pcg2d(uint2 v)
{
    v = v * 1664525u + 1013904223u;
    v.x += v.y * 1664525u;
    v.y += v.x * 1664525u;
    v = v ^(v >> 16u);
    v.x += v.y * 1664525u;
    v.y += v.x * 1664525u;
    v = v ^(v >> 16u);
    return v;
}
float2 pcg2(float2 v)
{
    return pcg2d(asuint(v)) / float(-1u);
}
// http://www.jcgt.org/published/0009/03/02/
uint3 pcg3d(uint3 v)
{
    v = v * 1664525u + 1013904223u;
    v.x += v.y * v.z;
    v.y += v.z * v.x;
    v.z += v.x * v.y;
    v ^= v >> 16u;
    v.x += v.y * v.z;
    v.y += v.z * v.x;
    v.z += v.x * v.y;
    return v;
}
float3 pcg3(float3 v)
{
    return pcg3d(asuint(v)) / float(-1u);
}
// http://www.jcgt.org/published/0009/03/02/
uint4 pcg4d(uint4 v)
{
    v = v * 1664525u + 1013904223u;
    v.x += v.y * v.w;
    v.y += v.z * v.x;
    v.z += v.x * v.y;
    v.w += v.y * v.z;
    v ^= v >> 16u;
    v.x += v.y * v.w;
    v.y += v.z * v.x;
    v.z += v.x * v.y;
    v.w += v.y * v.z;
    return v;
}
float4 pcg4(float4 v)
{
    return pcg4d(asuint(v)) / float(-1u);
}

// ortho basis
// https://en.wikipedia.org/wiki/Osculating_plane
float3x3 getBNT(float3 T)
{
    // camera rotation (may not be needed)
    // float cr = 0.0;
    // float3 N = float3(sin(cr), cos(cr), 0.0);
    T = normalize(T);
    float3 N = float3(0, 1, 0);
    float3 B = normalize(cross(N, T));
    N = normalize(cross(T, B));
    return float3x3(B, N, T);
}
// Cyclic Noise by nimitz (explained by jeyko)
// https://www.shadertoy.com/view/3tcyD7
// And edited by 0b5vr
// https://scrapbox.io/0b5vr/Cyclic_Noise
float3 cyclic(float3 p, float freq = 2.0, float3 seed = float3(1, 2, 3))
{
    const int octaves = 8;
    float4 n = (float4)0;
    float3x3 bnt = getBNT(seed);
    for (int i = 0; i < octaves; i++)
    {
        p += sin(p.yzx);
        n += float4(cross(cos(p), sin(p.zxy)), 1);
        // p *= bnt * freq;
        p = mul(bnt, p * freq);
    }
    return n.xyz / n.w;
}

// https://www.shadertoy.com/view/XsX3zB
// by nikat
float snoise(float3 p)
{
    const float F3 = 0.3333333;
    const float G3 = 0.1666667;
    float3 s = floor(p + dot(p, (float3) (F3)));
    float3 x = p - s + dot(s, (float3) (G3));

    float3 e = step((float3) (0.0), x - x.yzx);
    float3 i1 = e * (1.0 - e.zxy);
    float3 i2 = 1.0 - e.zxy * (1.0 - e);

    float3 x1 = x - i1 + G3;
    float3 x2 = x - i2 + 2.0 * G3;
    float3 x3 = x - 1.0 + 3.0 * G3;

    float4 w, d;

    w.x = dot(x, x);
    w.y = dot(x1, x1);
    w.z = dot(x2, x2);
    w.w = dot(x3, x3);

    w = max(0.6 - w, 0.0);

    d.x = dot(pcg3(s), x);
    d.y = dot(pcg3(s + i1), x1);
    d.z = dot(pcg3(s + i2), x2);
    d.w = dot(pcg3(s + 1.0), x3);

    w *= w;
    w *= w;
    d *= w;

    return dot(d, (float4) (52.0));
}