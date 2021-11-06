//
// Author: Code Tiger
// Copyright (c) 2021, MIT Lisence
//
Shader "CompactTexture/Mobile/Diffuse" {
    Properties {
        [MainTexture][NoScaleOffset] _MainTex ("Base (RGB)", 2D) = "white" {}

        [Toggle(SUBTEX0_ENABLE_ON)]_SubTex0Enabled("Sub-texture 0 [(0, 0), (0.5, 0.5)]: Scale & Offset enable?", Int) = 1
        _SubTex0("Scale(X, Y), Offset(Z, W)", Vector) = (1.0, 1.0, 0.0, 0.0)
        [Toggle(SUBTEX1_ENABLE_ON)]_SubTex1Enabled("Sub-texture 1 [(0.5, 0), (1, 0.5)]: Scale & Offset enable?", Int) = 1
        _SubTex1("Scale(X, Y), Offset(Z, W)", Vector) = (1.0, 1.0, 0.0, 0.0)
        [Toggle(SUBTEX2_ENABLE_ON)]_SubTex2Enabled("Sub-texture 2 [(0, 0.5), (0.5, 1)]: Scale & Offset enable?", Int) = 1
        _SubTex2("Scale(X, Y), Offset(Z, W)", Vector) = (1.0, 1.0, 0.0, 0.0)
        [Toggle(SUBTEX3_ENABLE_ON)]_SubTex3Enabled("Sub-texture 3 [(0.5, 0.5), (1, 1)]: Scale & Offset enable?", Int) = 1
        _SubTex3("Scale(X, Y), Offset(Z, W)", Vector) = (1.0, 1.0, 0.0, 0.0)

        _SeamCleaner("Seam Cleaner", Range(0.5, 1)) = 0.996
    }
    SubShader {
        Tags { "RenderType"="Opaque" }
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
            o.Albedo = c.rgb;
            o.Alpha = c.a;
        }
        ENDCG
    }
    Fallback "Mobile/Diffuse"
}
