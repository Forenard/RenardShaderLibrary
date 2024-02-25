Shader "Template/Unlit_Billboard"
{
    Properties
    {
        _MainTex ("Albedo (RGB)", 2D) = "white" { }
        [ToggleUI] _EnableXRot ("Enable X Rotation", Int) = 1
    }
    Subshader
    {
        Tags { "RenderType" = "Opaque" "Queue" = "Geometry" "DisableBatching" = "True" }

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_fog
            #pragma multi_compile_instancing

            #include "UnityCG.cginc"
            #include "../../Common/Util.cginc"

            UNITY_DECLARE_TEX2D(_MainTex);
            float4 _MainTex_ST;
            int _EnableXRot;

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

                // To BillBoard
                float3x3 bmat = GetObjectBillBoardMatrix(_EnableXRot);
                IN.oPos.xyz = mul(bmat, IN.oPos.xyz);
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
                UNITY_APPLY_FOG(IN.fogCoord, col);
                return col;
            }
            ENDCG
        }
    }
}