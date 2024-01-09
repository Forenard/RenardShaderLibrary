#pragma once

#define RENARD_DECLARE_TEX2D(tex)   Texture2D tex; SamplerState sampler##tex
#define RENARD_DECLARE_TEX2DARRAY(tex)  Texture2DArray tex; SamplerState sampler##tex

#if defined(UNITY_STEREO_INSTANCING_ENABLED) || defined(UNITY_STEREO_MULTIVIEW_ENABLED)
    #define RENARD_DECLARE_TEX2D_SCREENSPACE(tex)   RENARD_DECLARE_TEX2DARRAY(tex)
#else
    #define RENARD_DECLARE_TEX2D_SCREENSPACE(tex)   RENARD_DECLARE_TEX2D(tex)
#endif

#define RENARD_SAMPLE_TEX2D_SCREENSPACE(tex, coord) tex.SampleLevel(sampler##tex, coord, 0)

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