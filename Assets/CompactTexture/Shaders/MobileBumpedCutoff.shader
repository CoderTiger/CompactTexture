//
// Author: Code Tiger
// Copyright (c) 2021, MIT Lisence
//
Shader "CompactTexture/Mobile/Bumped Cutoff" {
    Properties {
        [MainTexture][NoScaleOffset]_MainTex ("Main Texture", 2D) = "white" {}
        [Normal][NoScaleOffset] _BumpMap ("Normalmap", 2D) = "bump" {}

        [Toggle(SUBTEX0_CUTOFF_ENABLE_ON)]_SubTex0CutoffEnabled("Sub-texture 0 [(0, 0), (0.5, 0.5)]: Cutoff enable?", Int) = 1
        _SubTex0Cutoff ("Alpha Cutoff", Range(0, 1)) = 0.5
        [Toggle(SUBTEX0_ENABLE_ON)]_SubTex0Enabled("Scale & Offset enable?", Int) = 1
        _SubTex0("Base (RGB)", Vector) = (1.0, 1.0, 0.0, 0.0)
        _SubNormal0("Normalmap", Vector) = (1.0, 1.0, 0.0, 0.0)

        [Toggle(SUBTEX1_CUTOFF_ENABLE_ON)]_SubTex1CutoffEnabled("Sub-texture 1 [(0.5, 0), (1, 0.5)]: Cutoff enable?", Int) = 1
        _SubTex1Cutoff ("Alpha Cutoff", Range(0, 1)) = 0.5
        [Toggle(SUBTEX1_ENABLE_ON)]_SubTex1Enabled("Scale & Offset enable?", Int) = 1
        _SubTex1("Base (RGB)", Vector) = (1.0, 1.0, 0.0, 0.0)
        _SubNormal1("Normalmap", Vector) = (1.0, 1.0, 0.0, 0.0)

        [Toggle(SUBTEX2_CUTOFF_ENABLE_ON)]_SubTex2CutoffEnabled("Sub-texture 2 [(0, 0.5), (0.5, 1)]: Cutoff enable?", Int) = 1
        _SubTex2Cutoff ("Alpha Cutoff", Range(0, 1)) = 0.5
        [Toggle(SUBTEX2_ENABLE_ON)]_SubTex2Enabled("Scale & Offset enable?", Int) = 1
        _SubTex2("Base (RGB)", Vector) = (1.0, 1.0, 0.0, 0.0)
        _SubNormal2("Normalmap", Vector) = (1.0, 1.0, 0.0, 0.0)

        [Toggle(SUBTEX3_CUTOFF_ENABLE_ON)]_SubTex3CutoffEnabled("Sub-texture 3 [(0.5, 0.5), (1, 1)]: Cutoff enable?", Int) = 1
        _SubTex3Cutoff ("Alpha Cutoff", Range(0, 1)) = 0.5
        [Toggle(SUBTEX3_ENABLE_ON)]_SubTex3Enabled("Scale & Offset enable?", Int) = 1
        _SubTex3("Base (RGB)", Vector) = (1.0, 1.0, 0.0, 0.0)
        _SubNormal3("Normalmap", Vector) = (1.0, 1.0, 0.0, 0.0)

    }
    SubShader {
        Tags {
            "Queue"="AlphaTest"
            "IgnoreProjector"="True"
            "RenderType"="TransparentCutout"
            "DisableBatching"="LODFading"
        }
        LOD 150
    
        CGPROGRAM
        #pragma surface surf Lambert noforwardadd
        #include "CGIIncludes/CompactTextureCommon.cginc"
        
        sampler2D _MainTex;
        sampler2D _BumpMap;
        
        struct Input {
            float2 uv_MainTex;
        };
        
        void surf (Input IN, inout SurfaceOutput o) {
            fixed4 c;
            float4 uvs = CompactBumpedUVs(IN.uv_MainTex);
            c = tex2D(_MainTex, uvs.xy);
            CompactClip(c.a, IN.uv_MainTex);
            o.Albedo = c.rgb;
            o.Alpha = c.a;
            o.Normal = UnpackNormal(tex2D(_BumpMap, uvs.zw));
        }
        ENDCG
    }
    Fallback "CompactTexture/Mobile/Diffuse"
}
