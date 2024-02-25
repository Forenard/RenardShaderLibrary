Shader "Template/Vertex_Write"
{
    Properties
    {
        _RT_Resolution ("Render Texture Resolution", Int) = 512
        _Camera_Far ("Camera far for Position", Float) = 1
    }
    Subshader
    {
        Tags { "RenderType" = "Opaque" "Queue" = "Overlay+999" "DisableBatching" = "True" }
        ZWrite Off
        ZTest Always
        Blend One Zero

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma geometry geom
            #pragma fragment frag
            #pragma multi_compile_fog
            #pragma multi_compile_instancing

            #include "UnityCG.cginc"
            #include "../../Common/Util.cginc"
            int _RT_Resolution;
            float _Camera_Far;
            #define EQ_EPS 0.001
            bool Check()
            {
                bool isFar = abs(_ProjectionParams.z - _Camera_Far) < EQ_EPS;
                bool isOrtho = (unity_OrthoParams.w > 0.5);
                bool isFit = (int(_ScreenParams.x) == _RT_Resolution) && (int(_ScreenParams.y) == _RT_Resolution);
                return (isFar && isOrtho && isFit);
            }

            struct g2f
            {
                float4 cPos : SV_POSITION;
                float3 oPos : TEXCOORD0;
            };

            appdata_full vert(appdata_full IN)
            {
                if (!Check())return (appdata_full)sqrt(-1);
                return IN;
            }
            
            static const float2 uvs[4] = {
                float2(0, 0), float2(0, 1), float2(1, 0), float2(1, 1)
            };
            [maxvertexcount(4)]
            void geom(point appdata_full IN[1], inout TriangleStream<g2f> triStream, uint id : SV_PrimitiveID)
            {
                if (!Check())return;
                g2f OUT;
                UNITY_INITIALIZE_OUTPUT(g2f, OUT);
                float3 opos = IN[0].vertex.xyz;
                for (int i = 0; i < 4; i++)
                {
                    float2 suv = (float2(id % _RT_Resolution, id / _RT_Resolution) + uvs[i]) / float(_RT_Resolution);
                    suv = (suv * 2 - 1) * float2(1, -1);
                    OUT.cPos = float4(suv, 0, 1);
                    OUT.oPos = opos;
                    triStream.Append(OUT);
                }
                triStream.RestartStrip();
            }
            
            float4 frag(g2f IN) : SV_Target
            {
                return float4(IN.oPos, 1);
            }
            ENDCG
        }
    }
}