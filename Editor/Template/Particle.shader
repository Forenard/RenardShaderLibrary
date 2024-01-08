Shader "Template/Particle"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" { }
        [HDR]_Color ("Color", Color) = (1, 1, 1, 1)
        [Toggle(_FLIPBOOK_BLENDING)] _FlipbookBlending ("Flipbook Blending", Int) = 0
    }
    SubShader
    {
        Tags { "RenderType" = "Opaque" "Queue" = "Transparent" "IgnoreProjector" = "True" }
        // Blend SrcAlpha One // Addtive
        Blend SrcAlpha OneMinusSrcAlpha // Alpha Blending
        BlendOp Add
        ZWrite Off
        ColorMask RGB
        Lighting Off

        Pass
        {
            CGPROGRAM
            #pragma exclude_renderers gles
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_fog
            // Texture Sheet Animation
            #pragma multi_compile __ _FLIPBOOK_BLENDING
            #pragma multi_compile_instancing
            #pragma instancing_options procedural:vertInstancingSetup

            #include "UnityCG.cginc"
            #include "UnityStandardParticleInstancing.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                fixed4 color : COLOR;
                #if defined(_FLIPBOOK_BLENDING) && !defined(UNITY_PARTICLE_INSTANCING_ENABLED)
                    float4 uvs : TEXCOORD0;
                    float blend : TEXCOORD1;
                #else
                    float2 uv : TEXCOORD0;
                #endif
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                fixed4 color : COLOR;
                float2 uv : TEXCOORD0;
                #if defined(_FLIPBOOK_BLENDING)
                    float3 uvAnimBlend : TEXCOORD1;
                #endif
                UNITY_FOG_COORDS(2)
                UNITY_VERTEX_INPUT_INSTANCE_ID
                UNITY_VERTEX_OUTPUT_STEREO
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float4 _Color;

            // インスタンシングをきかせる変数はここに定義する
            UNITY_INSTANCING_BUFFER_START(Props)
            // UNITY_DEFINE_INSTANCED_PROP(float4, hoge)
            UNITY_INSTANCING_BUFFER_END(Props)
            // インスタンシングをきかせた変数はこの様に参照する
            // float4 hoge = UNITY_ACCESS_INSTANCED_PROP(Props, hoge);

            v2f vert(appdata IN)
            {
                v2f OUT;
                UNITY_INITIALIZE_OUTPUT(v2f, OUT);
                UNITY_SETUP_INSTANCE_ID(IN);
                UNITY_TRANSFER_INSTANCE_ID(IN, OUT);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(OUT);

                OUT.vertex = UnityObjectToClipPos(IN.vertex);
                #if defined(UNITY_PARTICLE_INSTANCING_ENABLED)
                    vertInstancingColor(OUT.color);
                    #if defined(_FLIPBOOK_BLENDING)
                        vertInstancingUVs(IN.uv, OUT.uv, OUT.uvAnimBlend);
                    #else
                        vertInstancingUVs(IN.uv, OUT.uv);
                    #endif
                #else
                    OUT.color = IN.color;
                    #if defined(_FLIPBOOK_BLENDING)
                        OUT.uv = TRANSFORM_TEX(IN.uvs.xy, _MainTex);
                        OUT.uvAnimBlend = float3(TRANSFORM_TEX(IN.uvs.zw, _MainTex), IN.blend);
                    #else
                        OUT.uv = TRANSFORM_TEX(IN.uv, _MainTex);
                    #endif
                #endif
                UNITY_TRANSFER_FOG(OUT, OUT.vertex);
                return OUT;
            }

            float4 frag(v2f IN) : SV_Target
            {
                UNITY_SETUP_INSTANCE_ID(IN);
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(IN);
                #if defined(_FLIPBOOK_BLENDING)
                    float4 col = lerp(tex2D(_MainTex, IN.uv), tex2D(_MainTex, IN.uvAnimBlend.xy), IN.uvAnimBlend.z);
                #else
                    float4 col = tex2D(_MainTex, IN.uv);
                #endif
                col *= IN.color;
                col *= _Color;
                UNITY_APPLY_FOG(IN.fogCoord, col);
                return col;
            }
            ENDCG
        }
    }
}
