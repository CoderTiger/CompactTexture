//
// Author: Code Tiger
// Copyright (c) 2021, MIT Lisence
//
Shader "CompactTexture/Mobile/Simple Bumped Cutoff" {
    Properties {
        [MainTexture][NoScaleOffset]_MainTex ("Main Texture", 2D) = "white" {}
        [Normal][NoScaleOffset] _BumpMap ("Normalmap", 2D) = "bump" {}
        _Cutoff ("Alpha Cutoff", Range(0, 1)) = 0.5
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
        fixed _Cutoff;
        
        struct Input {
            float2 uv_MainTex;
        };
        
        void surf (Input IN, inout SurfaceOutput o) {
            fixed4 c = tex2D(_MainTex, IN.uv_MainTex);
            clip(c.a - _Cutoff);
            o.Albedo = c.rgb;
            o.Alpha = c.a;
            o.Normal = UnpackNormal(tex2D(_BumpMap, IN.uv_MainTex));
        }
        ENDCG
    }
    Fallback "CompactTexture/Mobile/Diffuse"
}
