Shader "Unlit/FirstShaderMultiUV"
{
    Properties
    {
      _BaseMap ("Base Map", 2D) = "white" {}
      _BaseColor ("Base Color", Color) = (1,1,1,1)

      //Dropdown pick which UV set the BAse Map uses 
      [KeywordEnum(Uv0, UV1)] _UVSET ("UV Set", Float) = 0
    }
    // The SubShader block containing the Shader code. 
    SubShader
    {
        // SubShader Tags define when and under which conditions a SubShader block or
        // a pass is executed.
        Tags { "RenderType"="Opaque" "Queue"="Geometry" "RenderPipeline"="UniversalPipeline" }
        LOD 200

        Pass
        {
            Name "Unlit" //no lighting 
            Tags { "LightMode"="UniversalForward"}
            
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            
            #pragma shader_feature_local _UVSET_UV0 _UVSET_UV1
            // creat keywords to match the enum above 
            
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            //Vertex stuff
            struct Attributes
            {
                float4 positionOS : POSITION;
                float2 uv0 : TEXCOORD0; //mesh uv chgannel 0 
                float2 uv1: TEXCOORD1; //mesh uv chgannel 1 
            };

            struct Varyings
            {
                float4 positionHCS : SV_POSITION;
                float2 uv : TEXCOORD0;
            };

            //Testures and samplers
            TEXTURE2D(_BaseMap);
            SAMPLER(sampler_BaseMap);

            //material srp batcher
            CBUFFER_START(UnityPerMaterial)
            float4 _BaseColor;
            float4 _BaseMap_ST; //tiling offset
            CBUFFER_END

            Varyings vert (Attributes IN)
            {
                Varyings OUT;
                OUT.positionHCS = TransformObjectToHClip(IN.positionOS.xyz);

                #if defined(_UVSET_UV1)
                OUT.uv = TRANSFORM_TEX(IN.uv1, _BaseMap);
                #else
                OUT.uv = TRANSFORM_TEX(IN.uv0, _BaseMap);
                #endif

                return OUT;
            }

            half4 frag (Varyings IN) : SV_Target
            {
                half4 baseTex = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, IN.uv);
                return half4(baseTex.rgb * _BaseColor.rgb, 1.0);
            }
            ENDHLSL
            }
            }
            FallBack Off
            }