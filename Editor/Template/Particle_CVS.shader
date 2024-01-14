// Custom Vertex Stream
Shader "Template/Particle_CVS"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" { }
        [HDR]_Color ("Color", Color) = (1, 1, 1, 1)
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
            #pragma multi_compile_instancing
            #pragma instancing_options procedural:vertInstancingSetup

            #define UNITY_PARTICLE_INSTANCE_DATA_NO_ANIM_FRAME
            #define UNITY_PARTICLE_INSTANCE_DATA CustomParticleInstanceData
            struct CustomParticleInstanceData
            {
                float3x4 transform;
                uint color;
                float3 velocity;
            };

            #include "UnityCG.cginc"
            #include "UnityStandardParticleInstancing.cginc"

            UNITY_DECLARE_TEX2D(_MainTex);
            float4 _MainTex_ST;
            float4 _Color;

            struct appdata
            {
                float4 oPos : POSITION;
                fixed4 color : COLOR;
                float2 uv : TEXCOORD0;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct v2f
            {
                float4 cPos : SV_POSITION;
                fixed4 color : COLOR;
                float2 uv : TEXCOORD0;
                float3 velocity : TEXCOORD1;
                UNITY_FOG_COORDS(2)
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
                
                OUT.cPos = UnityObjectToClipPos(IN.oPos);
                OUT.color = IN.color;
                OUT.uv = TRANSFORM_TEX(IN.uv, _MainTex);
                #if defined(UNITY_PARTICLE_INSTANCING_ENABLED)
                    vertInstancingColor(OUT.color);
                    vertInstancingUVs(IN.uv, OUT.uv);
                    UNITY_PARTICLE_INSTANCE_DATA data = unity_ParticleInstanceData[unity_InstanceID];
                    OUT.velocity = data.velocity;
                #endif

                UNITY_TRANSFER_FOG(OUT, OUT.cPos);
                return OUT;
            }

            float4 frag(v2f IN) : SV_Target
            {
                UNITY_SETUP_INSTANCE_ID(IN);
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(IN);
                
                float4 col = UNITY_SAMPLE_TEX2D(_MainTex, IN.uv);
                col *= IN.color;
                col *= _Color;
                col.rgb *= saturate(sign(dot(IN.velocity, float3(0, 1, 0))));
                UNITY_APPLY_FOG(IN.fogCoord, col);
                return col;
            }
            ENDCG
        }
    }
}
