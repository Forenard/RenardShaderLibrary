Shader "Template/Unlit_Transparent"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" { }
        [HDR]_Color ("Color", Color) = (1, 1, 1, 1)
        [Space(10)]
        [Header(Rendering)]
        [Space(10)]
        [Enum(UnityEngine.Rendering.BlendMode)] _SrcBlend ("Source Blend", Int) = 5
        [Enum(UnityEngine.Rendering.BlendMode)] _DstBlend ("Destination Blend", Int) = 10
        [Enum(UnityEngine.Rendering.BlendOp)] _BlendOp ("BlendOp", Int) = 0
        [Toggle] _ZWrite ("ZWrite", Int) = 0
        [Enum(UnityEngine.Rendering.CullMode)] _Cull ("CullMode", Int) = 2
    }
    SubShader
    {
        Tags { "RenderType" = "Opaque" "Queue" = "Transparent" }
        Blend [_SrcBlend] [_DstBlend]
        BlendOp [_BlendOp]
        ZWrite [_ZWrite]
        Cull [_Cull]

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_fog
            #pragma multi_compile_instancing
            
            #include "UnityCG.cginc"

            UNITY_DECLARE_TEX2D(_MainTex);
            float4 _MainTex_ST;
            float4 _Color;

            struct appdata
            {
                float4 oPos : POSITION;
                float2 uv : TEXCOORD0;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct v2f
            {
                float4 cPos : SV_POSITION;
                float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
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

                OUT.cPos = UnityObjectToClipPos(IN.oPos);
                OUT.uv = TRANSFORM_TEX(IN.uv, _MainTex);
                UNITY_TRANSFER_FOG(OUT, OUT.cPos);
                return OUT;
            }

            float4 frag(v2f IN) : SV_Target
            {
                UNITY_SETUP_INSTANCE_ID(IN);
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(IN);
                
                float4 col = UNITY_SAMPLE_TEX2D(_MainTex, IN.uv);
                col *= _Color;
                UNITY_APPLY_FOG(IN.fogCoord, col);
                return col;
            }
            ENDCG
        }
    }
}
