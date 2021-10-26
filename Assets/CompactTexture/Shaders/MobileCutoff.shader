//
// Author: Code Tiger
// Copyright (c) 2021, MIT Lisence
//
Shader "CompactTexture/Mobile/Cutoff" {
    Properties {
        [MainTexture][NoScaleOffset]_MainTex ("Main Texture", 2D) = "white" {}

        [Toggle(SUBTEX0_CUTOFF_ENABLE_ON)]_SubTex0CutoffEnabled("Sub-texture 0 [(0, 0), (0.5, 0.5)]: Cutoff enable?", Int) = 1
        _SubTex0Cutoff ("Alpha Cutoff", Range(0, 1)) = 0.5
        [Toggle(SUBTEX0_ENABLE_ON)]_SubTex0Enabled("Scale(X, Y) & Offset(Z, W) enable?", Int) = 1
        _SubTex0("", Vector) = (1.0, 1.0, 0.0, 0.0)

        [Toggle(SUBTEX1_CUTOFF_ENABLE_ON)]_SubTex1CutoffEnabled("Sub-texture 1 [(0.5, 0), (1, 0.5)]: Cutoff enable?", Int) = 1
        _SubTex1Cutoff ("Alpha Cutoff", Range(0, 1)) = 0.5
        [Toggle(SUBTEX1_ENABLE_ON)]_SubTex1Enabled("Scale(X, Y) & Offset(Z, W) enable?", Int) = 1
        _SubTex1("", Vector) = (1.0, 1.0, 0.0, 0.0)

        [Toggle(SUBTEX2_CUTOFF_ENABLE_ON)]_SubTex2CutoffEnabled("Sub-texture 2 [(0, 0.5), (0.5, 1)]: Cutoff enable?", Int) = 1
        _SubTex2Cutoff ("Alpha Cutoff", Range(0, 1)) = 0.5
        [Toggle(SUBTEX2_ENABLE_ON)]_SubTex2Enabled("Scale(X, Y) & Offset(Z, W) enable?", Int) = 1
        _SubTex2("", Vector) = (1.0, 1.0, 0.0, 0.0)

        [Toggle(SUBTEX3_CUTOFF_ENABLE_ON)]_SubTex3CutoffEnabled("Sub-texture 3 [(0.5, 0.5), (1, 1)]: Cutoff enable?", Int) = 1
        _SubTex3Cutoff ("Alpha Cutoff", Range(0, 1)) = 0.5
        [Toggle(SUBTEX3_ENABLE_ON)]_SubTex3Enabled("Scale(X, Y) & Offset(Z, W) enable?", Int) = 1
        _SubTex3("", Vector) = (1.0, 1.0, 0.0, 0.0)
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
        
        struct Input {
            float2 uv_MainTex;
        };
        
        void surf (Input IN, inout SurfaceOutput o) {
            fixed4 c;
            float2 uv = CompactUV(IN.uv_MainTex);
            c = tex2D(_MainTex, uv);
            CompactClip(c.a, IN.uv_MainTex);
            o.Albedo = c.rgb;
            o.Alpha = c.a;
        }
        ENDCG
    }
    Fallback "CompactTexture/Mobile/Diffuse"
}
