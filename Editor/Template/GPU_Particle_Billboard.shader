Shader "Template/GPU_Particle_Billboard"
{
    Properties
    {
        _MainTex ("Albedo (RGB)", 2D) = "white" { }
        _Size ("Size", Float) = 1
        [ToggleUI] _EnableXRot ("Enable X Rotation", Int) = 1
    }
    Subshader
    {
        Tags { "RenderType" = "Opaque" "Queue" = "Geometry" "DisableBatching" = "True" }

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma geometry geom
            #pragma fragment frag
            #pragma multi_compile_fog
            #pragma multi_compile_instancing

            #include "UnityCG.cginc"
            #include "Assets/RenardShaderLibrary/Common/Util.cginc"

            UNITY_DECLARE_TEX2D(_MainTex);
            float4 _MainTex_ST;
            float _Size;
            int _EnableXRot;

            struct appdata
            {
                float4 oPos : POSITION;
            };

            struct v2g
            {
                float4 oPos : POSITION;
            };

            struct g2f
            {
                float4 cPos : SV_POSITION;
                float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
            };

            v2g vert(appdata IN)
            {
                v2g OUT;
                UNITY_INITIALIZE_OUTPUT(v2g, OUT);
                OUT.oPos = IN.oPos;
                return OUT;
            }
            
            static const float2 uvs[4] = {
                float2(0, 0), float2(0, 1), float2(1, 0), float2(1, 1)
            };
            float3 getpos(uint id)
            {
                float t = float(id) / 100.0 + _Time.x;
                float3 pos = float3(sin(2.5 * t), cos(7.0 * t + 0.4), sin(3.3 * t + 0.1));
                return pos;
            }
            [maxvertexcount(4)]
            void geom(point v2g IN[1], inout TriangleStream<g2f> triStream, uint id : SV_PrimitiveID)
            {
                g2f OUT;
                UNITY_INITIALIZE_OUTPUT(g2f, OUT);
                float3 p = getpos(id);
                float3x3 bmat = GetObjectBillBoardMatrix(_EnableXRot, p);
                for (int i = 0; i < 4; i++)
                {
                    OUT.uv = uvs[i];
                    float3 opos = mul(bmat, float3(OUT.uv - .5, 0) * _Size) + p;
                    OUT.cPos = UnityObjectToClipPos(float4(opos, 1));
                    UNITY_TRANSFER_FOG(OUT, OUT.cPos);
                    triStream.Append(OUT);
                }
                triStream.RestartStrip();
            }
            
            float4 frag(g2f IN) : SV_Target
            {
                float4 col = UNITY_SAMPLE_TEX2D(_MainTex, IN.uv);
                UNITY_APPLY_FOG(IN.fogCoord, col);
                return col;
            }
            ENDCG
        }
    }
}