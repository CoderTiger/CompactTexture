Shader "CompactTexture/Mobile" {
    Properties {
        [MainTexture][NoScaleOffset] _MainTex ("Base (RGB)", 2D) = "white" {}
        [Normal][NoScaleOffset] _BumpMap ("Normalmap", 2D) = "bump" {}
        [NoScaleOffset]_EmissionMap ("Emission Map", 2D) = "white" {}

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
        [HideInInspector]_SubTexDummy0("", 2D) = "sub texture dummy 0" {}
        [HideInInspector]_SubTexDummy1("", 2D) = "sub texture dummy 1" {}
        [HideInInspector]_SubTexDummy2("", 2D) = "sub texture dummy 2" {}
        [HideInInspector]_SubTexDummy3("", 2D) = "sub texture dummy 3" {}

        [HideInInspector]_SubNormal0("", Vector) = (1.0, 1.0, 0.0, 0.0)
        [HideInInspector]_SubNormal1("", Vector) = (1.0, 1.0, 0.0, 0.0)
        [HideInInspector]_SubNormal2("", Vector) = (1.0, 1.0, 0.0, 0.0)
        [HideInInspector]_SubNormal3("", Vector) = (1.0, 1.0, 0.0, 0.0)
        [HideInInspector]_SubNormalDummy0("", 2D) = "sub normal dummy 0" {}
        [HideInInspector]_SubNormalDummy1("", 2D) = "sub normal dummy 1" {}
        [HideInInspector]_SubNormalDummy2("", 2D) = "sub normal dummy 2" {}
        [HideInInspector]_SubNormalDummy3("", 2D) = "sub normal dummy 3" {}

        _Cutoff ("Alpha Cutoff", Range(0, 1)) = 0.5
        [HideInInspector]_SubCutoff0("Alpha Cutoff", Range(0, 1)) = 0.5
        [HideInInspector]_SubCutoff1("Alpha Cutoff", Range(0, 1)) = 0.5
        [HideInInspector]_SubCutoff2("Alpha Cutoff", Range(0, 1)) = 0.5
        [HideInInspector]_SubCutoff3("Alpha Cutoff", Range(0, 1)) = 0.5

        [HideInInspector] _SeamCleaner("Seam Cleaner", Range(0.5, 1)) = 0.996

        _EmissionColor("Emission Color", Color) = (0,0,0)
        [HideInInspector]_SubEmissionColor0("", Color) = (0,0,0)
        [HideInInspector]_SubEmissionColor1("", Color) = (0,0,0)
        [HideInInspector]_SubEmissionColor2("", Color) = (0,0,0)
        [HideInInspector]_SubEmissionColor3("", Color) = (0,0,0)

        [HideInInspector] _TextureType("__textureType", Float) = 1.0
        // Blending state
        [HideInInspector] _Mode ("__mode", Float) = 0.0
        [HideInInspector] _SrcBlend ("__src", Float) = 1.0
        [HideInInspector] _DstBlend ("__dst", Float) = 0.0
        [HideInInspector] _ZWrite ("__zw", Float) = 1.0
    }
    SubShader {
        Tags { "RenderType"="Opaque" }
        LOD 250

        CGPROGRAM
        #pragma surface MobileSurf Lambert noforwardadd

        #pragma shader_feature_local _NORMALMAP
        #pragma shader_feature _EMISSION

        #pragma shader_feature_local _COMPACT_TEXTURE
        #pragma shader_feature_local _COMPACT_CUTOFF

        #include "CGIIncludes/CompactTextureCore.cginc"

        ENDCG
    }
    FallBack "Mobile/Diffuse"
    CustomEditor "CompactTextureMobileShaderGUI"
}
