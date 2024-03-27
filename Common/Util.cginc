#pragma once

#define RENARD_DECLARE_TEX2D(tex)   Texture2D tex; SamplerState sampler##tex
#define RENARD_DECLARE_TEX2DARRAY(tex)  Texture2DArray tex; SamplerState sampler##tex
#define RENARD_SAMPLE_TEX2D(tex, coord)     tex.Sample(sampler##tex, coord)
#define RENARD_SAMPLE_TEX2DARRAY(tex, coord)     tex.Sample(sampler##tex, coord)

#if defined(UNITY_STEREO_INSTANCING_ENABLED) || defined(UNITY_STEREO_MULTIVIEW_ENABLED)
    #define RENARD_DECLARE_TEX2D_SCREENSPACE(tex)   RENARD_DECLARE_TEX2DARRAY(tex)
    #define RENARD_SAMPLE_TEX2D_SCREENSPACE(tex, coord)    RENARD_SAMPLE_TEX2DARRAY(tex, float3((coord).xy, (float)unity_StereoEyeIndex))
#else
    #define RENARD_DECLARE_TEX2D_SCREENSPACE(tex)   RENARD_DECLARE_TEX2D(tex)
    #define RENARD_SAMPLE_TEX2D_SCREENSPACE(tex, coord)    RENARD_SAMPLE_TEX2D(tex, coord)
#endif

// https://github.com/MochiesCode/Mochies-Unity-Shaders/blob/5349d84458c62b93f5ce26f76d33171719fb623e/Mochie/Common/Utilities.cginc#L309
// For Cube
float4 GetFullScreenCPos(float4 oPos)
{
    oPos.x *= 1.4;
    #if UNITY_SINGLE_PASS_STEREO || defined(UNITY_STEREO_INSTANCING_ENABLED) || defined(UNITY_STEREO_MULTIVIEW_ENABLED)
        float ipd = length(mul(unity_WorldToObject,
        float4(unity_StereoWorldSpaceCameraPos[0].xyz - unity_StereoWorldSpaceCameraPos[1].xyz, 0)));
        float4 absPos = oPos + float4(ipd * (0.5 - unity_StereoEyeIndex), 0, 0, 0);
    #else
        float ipd = 0.0;
        float4 absPos = oPos;
    #endif
    float4 wPos = mul(unity_CameraToWorld, absPos);
    oPos = mul(unity_WorldToObject, wPos);
    return UnityObjectToClipPos(oPos);
}

// https://booth.pm/ja/items/1447794
// by momoma
float3x3 GetObjectBillBoardMatrix(bool enableXRot, float3 ocen = float3(0, 0, 0))
{
    #if defined(USING_STEREO_MATRICES)
        float3 cameraPos = (unity_StereoWorldSpaceCameraPos[0] + unity_StereoWorldSpaceCameraPos[1]) * 0.5;
    #else
        float3 cameraPos = _WorldSpaceCameraPos;
    #endif

    float3 direction = mul(unity_WorldToObject, float4(cameraPos, 1)).xyz;
    direction -= ocen;
    direction.y = enableXRot ? direction.y : 0;
    direction = normalize(-direction);

    float3x3 billboardMatrix;
    billboardMatrix[2] = direction;
    billboardMatrix[0] = normalize(float3(direction.z, 0, -direction.x));
    billboardMatrix[1] = normalize(cross(direction, billboardMatrix[0]));

    return transpose(billboardMatrix);
}


float4x4 inverse(float4x4 mat)
{
    float4x4 M = transpose(mat);
    float m01xy = M[0].x * M[1].y - M[0].y * M[1].x;
    float m01xz = M[0].x * M[1].z - M[0].z * M[1].x;
    float m01xw = M[0].x * M[1].w - M[0].w * M[1].x;
    float m01yz = M[0].y * M[1].z - M[0].z * M[1].y;
    float m01yw = M[0].y * M[1].w - M[0].w * M[1].y;
    float m01zw = M[0].z * M[1].w - M[0].w * M[1].z;
    float m23xy = M[2].x * M[3].y - M[2].y * M[3].x;
    float m23xz = M[2].x * M[3].z - M[2].z * M[3].x;
    float m23xw = M[2].x * M[3].w - M[2].w * M[3].x;
    float m23yz = M[2].y * M[3].z - M[2].z * M[3].y;
    float m23yw = M[2].y * M[3].w - M[2].w * M[3].y;
    float m23zw = M[2].z * M[3].w - M[2].w * M[3].z;
    float4 adjM0, adjM1, adjM2, adjM3;
    adjM0.x = +dot(M[1].yzw, float3(m23zw, -m23yw, m23yz));
    adjM0.y = -dot(M[0].yzw, float3(m23zw, -m23yw, m23yz));
    adjM0.z = +dot(M[3].yzw, float3(m01zw, -m01yw, m01yz));
    adjM0.w = -dot(M[2].yzw, float3(m01zw, -m01yw, m01yz));
    adjM1.x = -dot(M[1].xzw, float3(m23zw, -m23xw, m23xz));
    adjM1.y = +dot(M[0].xzw, float3(m23zw, -m23xw, m23xz));
    adjM1.z = -dot(M[3].xzw, float3(m01zw, -m01xw, m01xz));
    adjM1.w = +dot(M[2].xzw, float3(m01zw, -m01xw, m01xz));
    adjM2.x = +dot(M[1].xyw, float3(m23yw, -m23xw, m23xy));
    adjM2.y = -dot(M[0].xyw, float3(m23yw, -m23xw, m23xy));
    adjM2.z = +dot(M[3].xyw, float3(m01yw, -m01xw, m01xy));
    adjM2.w = -dot(M[2].xyw, float3(m01yw, -m01xw, m01xy));
    adjM3.x = -dot(M[1].xyz, float3(m23yz, -m23xz, m23xy));
    adjM3.y = +dot(M[0].xyz, float3(m23yz, -m23xz, m23xy));
    adjM3.z = -dot(M[3].xyz, float3(m01yz, -m01xz, m01xy));
    adjM3.w = +dot(M[2].xyz, float3(m01yz, -m01xz, m01xy));
    float invDet = rcp(dot(M[0].xyzw, float4(adjM0.x, adjM1.x, adjM2.x, adjM3.x)));
    return transpose(float4x4(adjM0 * invDet, adjM1 * invDet, adjM2 * invDet, adjM3 * invDet));
}


#define PI UNITY_PI
#define TAU UNITY_TWO_PI

#define fract(x) ((x) - floor(x))
#define mod(x, y) ((x) - (y) * floor((x) / (y)))
#define mix(x, y, a) lerp(x, y, a)
#define linearstep(edge0, edge1, x) saturate(((x) - (edge0)) / ((edge1) - (edge0)))
#define remap(x, a, b, c, d) lerp(c, d, ((x) - (a)) / ((b) - (a)))
#define remapc(x, a, b, c, d) lerp(c, d, linearstep(a, b, x))
#define repeat(x, a, b) (mod(x, (b) - (a)) + (a))
#define mixema(x, y, dt, lm) lerp(x, y, getema(dt, lm))

float getema(float dt, float lm)
{
    return min(1, max(0, exp2(-dt / max(1e-5, lm))));
}
float2 orbit(float a)
{
    return float2(cos(a), sin(a));
}
float3 erot(float3 p, float3 ax, float ro)
{
    return mix(dot(ax, p) * ax, p, cos(ro)) + cross(ax, p) * sin(ro);
}
float3 cospalette(float3 a, float3 b, float t)
{
    return 0.5 - 0.5 * cos(TAU * (a * t + b));
}
float2x2 rot(float a)
{
    float c = cos(a);
    float s = sin(a);
    return float2x2(c, -s, s, c);
}