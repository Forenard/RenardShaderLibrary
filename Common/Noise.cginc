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