Shader "Template/FullScreen"
{
    Properties
    {
        _Monochrome ("Monochrome", Range(0, 1)) = 1
    }
    SubShader
    {
        Tags { "RenderType" = "Overlay" "Queue" = "Overlay-1" "ForceNoShadowCasting" = "True" "IgnoreProjector" = "True" "DisableBatching" = "True" }
        Cull Front
        ZWrite Off
        ZTest Always

        GrabPass
        {
            "_FullSceenGrabTexture"
        }
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            
            #include "UnityCG.cginc"
            #include "../../Common/Util.cginc"

            RENARD_DECLARE_TEX2D_SCREENSPACE(_FullSceenGrabTexture);
            float _Monochrome;

            struct appdata
            {
                float4 oPos : POSITION;
                float2 uv : TEXCOORD0;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct v2f
            {
                float4 cPos : SV_POSITION;
                float4 gPos : TEXCOORD0;
                UNITY_VERTEX_INPUT_INSTANCE_ID
                UNITY_VERTEX_OUTPUT_STEREO
            };
            
            v2f vert(appdata IN)
            {
                v2f OUT;
                UNITY_INITIALIZE_OUTPUT(v2f, OUT);
                UNITY_SETUP_INSTANCE_ID(IN);
                UNITY_TRANSFER_INSTANCE_ID(IN, OUT);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(OUT);

                OUT.cPos = GetFullScreenCPos(IN.oPos);
                OUT.gPos = ComputeGrabScreenPos(OUT.cPos);
                UNITY_TRANSFER_FOG(OUT, OUT.cPos);
                return OUT;
            }
            
            float4 frag(v2f IN) : SV_Target
            {
                UNITY_SETUP_INSTANCE_ID(IN);
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(IN);

                float2 uv = IN.gPos.xy / IN.gPos.w;
                float4 col = RENARD_SAMPLE_TEX2D_SCREENSPACE(_FullSceenGrabTexture, uv);
                col.rgb = lerp(col.rgb, (float3)dot(col.rgb, float3(0.299, 0.587, 0.114)), _Monochrome);
                return col;
            }
            ENDCG
        }
    }
}
