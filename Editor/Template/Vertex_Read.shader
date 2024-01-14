// forked from GPU_Particle_Line.shader
Shader "Template/Vertex_Read"
{
    Properties
    {
        _Size ("Size", Float) = 1
        _SmoothPixel ("Smooth Pixel", Float) = 1
        [ToggleUI] _EnableXRot ("Enable X Rotation", Int) = 1
        [NoScaleOffset]_VertexTex ("VertexTex", 2D) = "white" { }
        _MaxVertexCount ("Max Vertex Count", Int) = 1000
    }
    Subshader
    {
        Tags { "RenderType" = "Opaque" "Queue" = "Transparent" "DisableBatching" = "True" }
        Blend SrcAlpha OneMinusSrcAlpha // Alpha Blending
        BlendOp Add
        ZWrite Off
        Cull Off
        ColorMask RGB
        Lighting Off
        
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

            float _Size;
            float _SmoothPixel;
            int _EnableXRot;
            int _MaxVertexCount;
            UNITY_DECLARE_TEX2D(_VertexTex);
            float4 _VertexTex_TexelSize;

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
                bool isLine : TEXCOORD1;
                UNITY_FOG_COORDS(2)
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
                id = id % _MaxVertexCount;
                int2 res = int2(_VertexTex_TexelSize.zw);
                float2 uv = (float2(id % res.x, id / res.x) + 0.5) / float2(res);
                return UNITY_SAMPLE_TEX2D_LOD(_VertexTex, uv, 0).xyz;
            }
            [maxvertexcount(8)]
            void geom(point v2g IN[1], inout TriangleStream<g2f> triStream, uint id : SV_PrimitiveID)
            {
                g2f OUT;
                UNITY_INITIALIZE_OUTPUT(g2f, OUT);
                float3 p1 = getpos(id);
                float3 p2 = getpos(id + 1);
                float4 c1 = UnityObjectToClipPos(float4(p1, 1));
                float4 c2 = UnityObjectToClipPos(float4(p2, 1));
                float2 u = normalize(c2.xy / c2.w - c1.xy / c1.w);
                float2 v = u.yx * float2(1, -1);
                float4 cs[4] = {
                    c1 + float4(-v, 0, 0) * _Size * 0.5,
                    c1 + float4(v, 0, 0) * _Size * 0.5,
                    c2 + float4(-v, 0, 0) * _Size * 0.5,
                    c2 + float4(v, 0, 0) * _Size * 0.5
                };
                // line
                for (int i = 0; i < 4; i++)
                {
                    OUT.uv = uvs[i];
                    OUT.cPos = cs[i];
                    OUT.isLine = true;
                    UNITY_TRANSFER_FOG(OUT, OUT.cPos);
                    triStream.Append(OUT);
                }
                triStream.RestartStrip();
                // quad
                for (int i = 0; i < 4; i++)
                {
                    OUT.uv = uvs[i];
                    OUT.cPos = c2 + float4((OUT.uv - .5) * _Size, 0, 0);
                    OUT.isLine = false;
                    UNITY_TRANSFER_FOG(OUT, OUT.cPos);
                    triStream.Append(OUT);
                }
                triStream.RestartStrip();
            }

            #define linearstep(a, b, x) saturate(((x) - (a)) / ((b) - (a)))
            float4 frag(g2f IN) : SV_Target
            {
                float2 uv = IN.uv;
                float2 px = fwidth(uv);
                float2 res = max(px.x, px.y) / px;
                float2 ruv = uv * res;
                float d = IN.isLine ? abs(uv.y - 0.5) : length(uv - 0.5);
                float sl = 0.5, sr = min(0.499999, 0.5 - px.y * _SmoothPixel);
                float a = linearstep(sl, sr, d);
                float4 col = float4(1, 1, 1, a);
                UNITY_APPLY_FOG(IN.fogCoord, col);
                return col;
            }
            ENDCG
        }
    }
}