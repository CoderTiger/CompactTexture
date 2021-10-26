//
// Author: Code Tiger
// Copyright (c) 2021, MIT Lisence
//
Shader "CompactTexture/Mobile/Bumped Diffuse" {
    Properties {
        [MainTexture][NoScaleOffset] _MainTex ("Base (RGB)", 2D) = "white" {}
        [Normal][NoScaleOffset] _BumpMap ("Normalmap", 2D) = "bump" {}

        [Toggle(SUBTEX0_ENABLE_ON)]_SubTex0Enabled("Sub-texture 0 [(0, 0), (0.5, 0.5)]: Scale & Offset enable?", Int) = 1
        _SubTex0("Base (RGB)", Vector) = (1.0, 1.0, 0.0, 0.0)
        _SubNormal0("Normalmap", Vector) = (1.0, 1.0, 0.0, 0.0)
        [Toggle(SUBTEX1_ENABLE_ON)]_SubTex1Enabled("Sub-texture 1 [(0.5, 0), (1, 0.5)]: Scale & Offset enable?", Int) = 1
        _SubTex1("Base (RGB)", Vector) = (1.0, 1.0, 0.0, 0.0)
        _SubNormal1("Normalmap", Vector) = (1.0, 1.0, 0.0, 0.0)
        [Toggle(SUBTEX2_ENABLE_ON)]_SubTex2Enabled("Sub-texture 2 [(0, 0.5), (0.5, 1)]: Scale & Offset enable?", Int) = 1
        _SubTex2("Base (RGB)", Vector) = (1.0, 1.0, 0.0, 0.0)
        _SubNormal2("Normalmap", Vector) = (1.0, 1.0, 0.0, 0.0)
        [Toggle(SUBTEX3_ENABLE_ON)]_SubTex3Enabled("Sub-texture 3 [(0.5, 0.5), (1, 1)]: Scale & Offset enable?", Int) = 1
        _SubTex3("Base (RGB)", Vector) = (1.0, 1.0, 0.0, 0.0)
        _SubNormal3("Normalmap", Vector) = (1.0, 1.0, 0.0, 0.0)
    }
    SubShader {
        Tags { "RenderType"="Opaque" }
        LOD 250
    
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
            o.Albedo = c.rgb;
            o.Alpha = c.a;
            o.Normal = UnpackNormal(tex2D(_BumpMap, uvs.zw));
        }
        ENDCG
    }
    Fallback "CompactTexture/Mobile/Diffuse"
    //CustomEditor "CompactTextureShaderGUI"
}
