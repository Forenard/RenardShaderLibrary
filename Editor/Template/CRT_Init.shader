Shader "Template/CRT_Init"
{
    SubShader
    {
        Lighting Off
        Blend One Zero
        Pass
        {
            CGPROGRAM
            #include "UnityCustomRenderTexture.cginc"
            #pragma vertex InitCustomRenderTextureVertexShader
            #pragma fragment frag

            float4 frag(v2f_init_customrendertexture IN) : COLOR
            {
                return float4(IN.texcoord.xy, 0, 1);
            }
            ENDCG
        }
    }
}