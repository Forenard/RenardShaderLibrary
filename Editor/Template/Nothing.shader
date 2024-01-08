Shader "Template/Nothing"
{
    SubShader
    {
        Tags { "RenderType" = "Opaque" "ForceNoShadowCasting" = "True" "IgnoreProjector" = "True" }
        Pass
        {
            ZWrite Off
            ColorMask 0
        }
    }
}
