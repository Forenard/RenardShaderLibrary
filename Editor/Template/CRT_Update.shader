Shader "Template/CRT_Update"
{
    SubShader
    {
        Lighting Off
        Blend One Zero
        Pass
        {
            CGPROGRAM
            #include "UnityCustomRenderTexture.cginc"
            #pragma vertex CustomRenderTextureVertexShader
            #pragma fragment frag

            float4 frag(v2f_customrendertexture IN) : COLOR
            {
                return float4(IN.globalTexcoord.xy, 0, 1);
            }
            ENDCG
        }
    }
}