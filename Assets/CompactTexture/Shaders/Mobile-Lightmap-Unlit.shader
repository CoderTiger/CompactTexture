//
// Author: Code Tiger
// Copyright (c) 2021, MIT Lisence
//
Shader "CompactTexture/Mobile Unlit (Supports Lightmap)" {
    Properties {
        [MainTexture][NoScaleOffset]_MainTex ("Base (RGB)", 2D) = "white" {}
        [NoScaleOffset]_EmissionMap ("Emission Map", 2D) = "white" {}
        [HDR]_EmissionColor("Emission Color", Color) = (0,0,0)

        [HideInInspector]_SubTex0Enabled("", Int) = 1
        [HideInInspector]_SubTex1Enabled("", Int) = 1
        [HideInInspector]_SubTex2Enabled("", Int) = 1
        [HideInInspector]_SubTex3Enabled("", Int) = 1

        [HideInInspector]_SubCutoff0Enabled("", Int) = 0
        [HideInInspector]_SubCutoff1Enabled("", Int) = 0
        [HideInInspector]_SubCutoff2Enabled("", Int) = 0
        [HideInInspector]_SubCutoff3Enabled("", Int) = 0

        [HideInInspector]_SubEmission0Enabled("", Int) = 0
        [HideInInspector]_SubEmission1Enabled("", Int) = 0
        [HideInInspector]_SubEmission2Enabled("", Int) = 0
        [HideInInspector]_SubEmission3Enabled("", Int) = 0

        [HideInInspector]_SubTex0("", Vector) = (1.0, 1.0, 0.0, 0.0)
        [HideInInspector]_SubTex1("", Vector) = (1.0, 1.0, 0.0, 0.0)
        [HideInInspector]_SubTex2("", Vector) = (1.0, 1.0, 0.0, 0.0)
        [HideInInspector]_SubTex3("", Vector) = (1.0, 1.0, 0.0, 0.0)

        [HideInInspector]_SubNormal0("", Vector) = (1.0, 1.0, 0.0, 0.0)
        [HideInInspector]_SubNormal1("", Vector) = (1.0, 1.0, 0.0, 0.0)
        [HideInInspector]_SubNormal2("", Vector) = (1.0, 1.0, 0.0, 0.0)
        [HideInInspector]_SubNormal3("", Vector) = (1.0, 1.0, 0.0, 0.0)

        [HideInInspector]_Cutoff ("Alpha Cutoff", Range(0, 1)) = 0.5
        [HideInInspector]_SubCutoff0("Alpha Cutoff", Range(0, 1)) = 0.5
        [HideInInspector]_SubCutoff1("Alpha Cutoff", Range(0, 1)) = 0.5
        [HideInInspector]_SubCutoff2("Alpha Cutoff", Range(0, 1)) = 0.5
        [HideInInspector]_SubCutoff3("Alpha Cutoff", Range(0, 1)) = 0.5

        [HideInInspector]_SubPadding0("Sub Regin Padding Space", Vector) = (0.0, 0.0, 0.0, 0.0)
        [HideInInspector]_SubPadding1("Sub Regin Padding Space", Vector) = (0.0, 0.0, 0.0, 0.0)
        [HideInInspector]_SubPadding2("Sub Regin Padding Space", Vector) = (0.0, 0.0, 0.0, 0.0)
        [HideInInspector]_SubPadding3("Sub Regin Padding Space", Vector) = (0.0, 0.0, 0.0, 0.0)

        [HideInInspector][HDR]_EmissionColor("Emission Color", Color) = (0,0,0)
        [HideInInspector][HDR]_SubEmissionColor0("", Color) = (0,0,0)
        [HideInInspector][HDR]_SubEmissionColor1("", Color) = (0,0,0)
        [HideInInspector][HDR]_SubEmissionColor2("", Color) = (0,0,0)
        [HideInInspector][HDR]_SubEmissionColor3("", Color) = (0,0,0)

        [HideInInspector]_TextureType("__textureType", Float) = 1.0
        // Blending state
        [HideInInspector]_Mode ("__mode", Float) = 0.0
    }
    SubShader {
        Tags { "RenderType"="Opaque" }
        LOD 100

        // Non-lightmapped
        Pass {
            Tags { "LightMode" = "Vertex" }

            CGPROGRAM

            #pragma vertex MobileVert
            #pragma fragment MobileFrag
            // make fog work
            #pragma multi_compile_fog

            #pragma shader_feature _EMISSION
            #pragma shader_feature_local _COMPACT_TEXTURE
            #pragma shader_feature_local _CUTOFF

            #include "UnityCG.cginc"

            #define COMPACT_VERTEX_FRAGMENT_SHADER
            #include "CGIIncludes/CompactTextureCore.cginc"

            ENDCG
        }

        // Lightmapped
        Pass {
            Tags{ "LIGHTMODE" = "VertexLM" "RenderType" = "Opaque" }

            CGPROGRAM

            #pragma vertex MobileVertLightmapped
            #pragma fragment MobileFragLightmapped
            #pragma target 2.0

            #pragma shader_feature _EMISSION
            #pragma shader_feature_local _COMPACT_TEXTURE
            #pragma shader_feature_local _CUTOFF

            #include "UnityCG.cginc"

            #pragma multi_compile_fog
            #define USING_FOG (defined(FOG_LINEAR) || defined(FOG_EXP) || defined(FOG_EXP2))

            #define COMPACT_VERTEX_FRAGMENT_SHADER
            #define COMPACT_LIGHTMAPPED
            #include "CGIIncludes/CompactTextureCore.cginc"

            ENDCG
        }

        UsePass "Mobile/VertexLit/SHADOWCASTER"
    }
    CustomEditor "CompactTextureMobileShaderGUI"
}
