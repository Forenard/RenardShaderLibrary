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

    return clamp(dot(d, (float4) (52.0)), -1, 1);
}

// COSINE NOISE
// https://cescg.org/wp-content/uploads/2019/03/Balint-Closed-Form-Transmittance-in-Heterogeneous-Media-Using-Cosine-Noise.pdf
#define CN_MEDIUM_QUALITY
#ifdef CN_LOW_QUALITY
    #define traceAcc 0.008
    #define iter 4
    #define octaves 6
    #define boundAcc 0.05
#endif
#ifdef CN_MEDIUM_QUALITY
    #define traceAcc 0.005
    #define iter 6
    #define octaves 8
    #define boundAcc 0.02
#endif
#ifdef CN_HIGH_QUALITY
    #define traceAcc 0.001
    #define iter 8
    #define octaves 10
    #define boundAcc 0.01
#endif
#define CN_offset 60.
static const float CN_octaveWeight[10] = {
    1., 2.0, 3.0, 2.6, 2.3, 1.2, 0.9, 0.7, 0.5, 0.4
};
static const float3x3 CN_transforms[9] = {
    transpose(float3x3(-2.601, 0.651, -6.378,
    - 2.923, 4.877, 1.975,
    1.835, -3.061, -3.238)),
    transpose(float3x3(-3.182, -1.907, 5.481,
    4.579, 2.744, -0.931,
    3.048, 2.762, 4.895)),
    transpose(float3x3(-3.741, -3.391, -1.217,
    4.528, -4.996, 1.858,
    - 2.641, 2.914, -4.255)),
    transpose(float3x3(-4.887, 0.240, 0.076,
    1.072, -0.053, -5.999,
    - 0.231, -4.701, 2.833)),
    transpose(float3x3(0.287, 5.849, -3.242,
    2.221, 4.697, 2.205,
    - 2.320, -4.905, -4.170)),
    transpose(float3x3(2.073, -0.981, 4.492,
    - 5.610, 2.654, -0.683,
    - 1.848, 5.165, 4.576)),
    transpose(float3x3(1.869, -5.222, -2.136,
    - 6.100, -2.183, 0.920,
    2.573, 0.921, -4.592)),
    transpose(float3x3(3.790, 0.949, 4.227,
    - 6.505, -1.630, -1.848,
    1.218, -4.862, 1.208)),
    transpose(float3x3(-0.994, 3.966, -4.867,
    - 4.995, 2.994, 3.224,
    4.010, -2.403, -2.813))
};
static const float3x3 CN_rot = float3x3(-0.5879431, -0.4649327, 0.6619370,
- 0.3151081, -0.6220310, -0.7167875,
0.7450032, -0.6300120, 0.2192148) * 1.635;
// THIS IS GLSL
/*
float cnoise1(float3 ro, float3 rd, float t)
{
    float3 p = ro + rd * t + float3(100);
    float c = 0.;
    for (int i = 0; i < iter; i++)
    {
        float3 transformedRd = CN_transforms[i] * rd;
        float3 transformedP = CN_transforms[i] * p;
        for (int o = 0; o < octaves; o++)
        {
            c += dot(sin(transformedP) * clamp(1. / transformedRd, -100., 100.), float3(1)) * CN_octaveWeight[o];
            transformedP *= CN_rot;
            transformedRd *= CN_rot;
        }
    }
    return (c + t * CN_offset) / 30.;
}

float cnoise2(float3 ro, float3 rd, float t)
{
    float3 p = ro + rd * t + float3(100);
    float c = 0.;
    for (int i = 0; i < iter; i++)
    {
        float3 transformedP = CN_transforms[i] * p;
        for (int o = 0; o < octaves; o++)
        {
            c += dot(cos(transformedP), float3(1)) * CN_octaveWeight[o];
            transformedP *= CN_rot;
        }
    }
    return max((c + CN_offset) / 30., 0.);
}
*/
// TO HLSL
float cnoise1(float3 ro, float3 rd, float t)
{
    float3 p = ro + rd * t + float3(100, 100, 100);
    float c = 0.;
    for (int i = 0; i < iter; i++)
    {
        float3 transformedRd = mul(CN_transforms[i], rd);
        float3 transformedP = mul(CN_transforms[i], p);
        for (int o = 0; o < octaves; o++)
        {
            c += dot(sin(transformedP) * clamp(1. / transformedRd, -100., 100.), float3(1, 1, 1)) * CN_octaveWeight[o];
            transformedP = mul(CN_rot, transformedP);
            transformedRd = mul(CN_rot, transformedRd);
        }
    }
    return (c + t * CN_offset) / 30.;
}

float cnoise2(float3 ro, float3 rd, float t)
{
    float3 p = ro + rd * t + float3(100, 100, 100);
    float c = 0.;
    for (int i = 0; i < iter; i++)
    {
        float3 transformedP = mul(CN_transforms[i], p);
        for (int o = 0; o < octaves; o++)
        {
            c += dot(cos(transformedP), float3(1, 1, 1)) * CN_octaveWeight[o];
            transformedP = mul(CN_rot, transformedP);
        }
    }
    return max((c + CN_offset) / 30., 0.);
}