Shader "Template/Font"
{
    Properties
    {
        [NoScaleOffset]_FontTex ("Font Texture", 2D) = "white" { }
        [NoScaleOffset]_FontInfoTex ("Font Info Texture", 2D) = "white" { }
    }
    SubShader
    {
        Tags { "RenderType" = "Opaque" "Queue" = "Geometry" }
        Pass
        {
            CGPROGRAM
            #pragma vertex vert_img
            #pragma fragment frag
            #include "UnityCG.cginc"
            #include "../../Common/Util.cginc"

            Texture2D<float4> _FontTex;
            Texture2D<float4> _FontInfoTex;
            float4 _FontInfoTex_TexelSize;
            SamplerState sampler_trilinear_clamp;

            float _median(float r, float g, float b)
            {
                return max(min(r, g), min(max(r, g), b));
            }
            float sampleChar(float2 uv, int id, float width = 0.3)
            {
                float4 info = _FontInfoTex[int2(id, 0)];
                float2 anc = info.xy, sz = info.zw;
                float2 cuv = remap(uv, float2(0, 1), float2(1, 0), anc, anc + sz);
                cuv.y = 1 - cuv.y;
                float4 font = _FontTex.SampleGrad(sampler_trilinear_clamp, cuv, ddx(cuv), ddy(cuv));
                float d = abs(_median(font.r, font.g, font.b) - 0.5) - width;
                float s = fwidth(d);
                // 越えてる制限
                float2 fuv = fwidth(uv);
                return smoothstep(s, 0, d) * step(max(fuv.x, fuv.y), 0.5);
            }

            float4 frag(v2f_img IN) : SV_Target
            {
                float2 uv = IN.uv;
                int maxid = int(_FontInfoTex_TexelSize.z);
                return (float4)sampleChar(IN.uv, int(_Time.y * 8) % maxid);
            }
            ENDCG
        }
    }
}
