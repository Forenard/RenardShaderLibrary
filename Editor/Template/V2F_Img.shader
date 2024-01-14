Shader "Template/V2F_Img"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" { }
    }
    SubShader
    {
        Tags { "RenderType" = "Opaque" }
        Pass
        {
            CGPROGRAM
            #pragma vertex vert_img
            #pragma fragment frag
            #include "UnityCG.cginc"
            
            UNITY_DECLARE_TEX2D(_MainTex);

            float4 frag(v2f_img IN) : SV_Target
            {
                return UNITY_SAMPLE_TEX2D(_MainTex, IN.uv);
            }
            ENDCG
        }
    }
}
