﻿//
// Author: Code Tiger
// Copyright (c) 2021, MIT Lisence
//
#ifndef COMPACT_TEXTURE_COMMON_INCLUDED
#define COMPACT_TEXTURE_COMMON_INCLUDED

sampler2D _MainTex;
sampler2D _BumpMap;

bool _SubTex0Enabled;
bool _SubTex1Enabled;
bool _SubTex2Enabled;
bool _SubTex3Enabled;
float4 _SubTex0;
float4 _SubTex1;
float4 _SubTex2;
float4 _SubTex3;
float4 _SubNormal0;
float4 _SubNormal1;
float4 _SubNormal2;
float4 _SubNormal3;

bool _SubCutoff0Enabled;
bool _SubCutoff1Enabled;
bool _SubCutoff2Enabled;
bool _SubCutoff3Enabled;
fixed _Cutoff;
fixed _SubCutoff0;
fixed _SubCutoff1;
fixed _SubCutoff2;
fixed _SubCutoff3;

half4 _EmissionColor;
sampler2D _EmissionMap;
bool _SubEmission0Enabled;
bool _SubEmission1Enabled;
bool _SubEmission2Enabled;
bool _SubEmission3Enabled;
half4 _SubEmissionColor0;
half4 _SubEmissionColor1;
half4 _SubEmissionColor2;
half4 _SubEmissionColor3;

half _Shininess;
sampler2D _SpecularMap;
bool _SubSpecular0Enabled;
bool _SubSpecular1Enabled;
bool _SubSpecular2Enabled;
bool _SubSpecular3Enabled;
half _SubShininess0;
half _SubShininess1;
half _SubShininess2;
half _SubShininess3;

fixed4 _SubPadding0;
fixed4 _SubPadding1;
fixed4 _SubPadding2;
fixed4 _SubPadding3;

struct Input {
    float2 uv_MainTex;
};

struct MobileSurfResult {
    fixed4 color;
    float2 uv;
};

inline float2 CompactUV(float2 uv) {
    float2 compactUV = uv;
    if (uv.y < 0.5) {
        // sub texture 0, [(0, 0), (0.5, 0.5)]
        if (uv.x < 0.5) {
            if (_SubTex0Enabled) {
                float2 subUVSize = float2(0.5 - _SubPadding0.x - _SubPadding0.y, 0.5 - _SubPadding0.z - _SubPadding0.w);
                compactUV += float2(_SubTex0.z, _SubTex0.w);
                compactUV.x *= _SubTex0.x;
                compactUV.y *= _SubTex0.y;
                compactUV = fmod(compactUV, subUVSize);
                compactUV += _SubPadding0.xw;
            }
        // sub texture 1, [(0.5, 0), (1, 0.5)]
        } else {
            if (_SubTex1Enabled) {
                float2 subUVSize = float2(0.5 - _SubPadding1.x - _SubPadding1.y, 0.5 - _SubPadding1.z - _SubPadding1.w);
                compactUV += float2(_SubTex1.z - 0.5, _SubTex1.w);
                compactUV.x *= _SubTex1.x;
                compactUV.y *= _SubTex1.y;
                compactUV = fmod(compactUV, subUVSize);
                compactUV.x += 0.5;
                compactUV += _SubPadding1.xw;
            }
        }
    }
    else {
        // sub texture 2, [(0, 0.5), (0.5, 1)]
        if (uv.x < 0.5) {
            if (_SubTex2Enabled) {
                float2 subUVSize = float2(0.5 - _SubPadding2.x - _SubPadding2.y, 0.5 - _SubPadding2.z - _SubPadding2.w);
                compactUV += float2(_SubTex2.z, _SubTex2.w - 0.5);
                compactUV.x *= _SubTex2.x;
                compactUV.y *= _SubTex2.y;
                compactUV = fmod(compactUV, subUVSize);
                compactUV.y += 0.5;
                compactUV += _SubPadding2.xw;
            }
        // sub texture 3, [(0.5, 0.5), (1, 1)]
        } else {
            if (_SubTex3Enabled) {
                float2 subUVSize = float2(0.5 - _SubPadding3.x - _SubPadding3.y, 0.5 - _SubPadding3.z - _SubPadding3.w);
                compactUV += float2(_SubTex3.z - 0.5, _SubTex3.w - 0.5);
                compactUV.x *= _SubTex3.x;
                compactUV.y *= _SubTex3.y;
                compactUV = fmod(compactUV, subUVSize);
                compactUV += 0.5;
                compactUV += _SubPadding3.xw;
            }
        }
    }
    return compactUV;
}

inline float4 CompactBumpedUVs(float2 uv) {
    float2 compactUV = uv;
    float2 compactNormalUV = uv;
    if (uv.y < 0.5) {
        // sub texture 0, [(0, 0), (0.5, 0.5)]
        if (uv.x < 0.5) {
            if (_SubTex0Enabled) {
                float2 subUVSize = float2(0.5 - _SubPadding0.x - _SubPadding0.y, 0.5 - _SubPadding0.z - _SubPadding0.w);
                compactUV += float2(_SubTex0.z, _SubTex0.w);
                compactUV.x *= _SubTex0.x;
                compactUV.y *= _SubTex0.y;
                compactUV = fmod(compactUV, subUVSize);
                compactUV += _SubPadding0.xw;

                compactNormalUV += float2(_SubNormal0.z, _SubNormal0.w);
                compactNormalUV.x *= _SubNormal0.x;
                compactNormalUV.y *= _SubNormal0.y;
                compactNormalUV = fmod(compactNormalUV, subUVSize);
                compactNormalUV += _SubPadding0.xw;
            }
        // sub texture 1, [(0.5, 0), (1, 0.5)]
        } else {
            if (_SubTex1Enabled) {
                float2 subUVSize = float2(0.5 - _SubPadding1.x - _SubPadding1.y, 0.5 - _SubPadding1.z - _SubPadding1.w);
                compactUV += float2(_SubTex1.z - 0.5, _SubTex1.w);
                compactUV.x *= _SubTex1.x;
                compactUV.y *= _SubTex1.y;
                compactUV = fmod(compactUV, subUVSize);
                compactUV.x += 0.5;
                compactUV += _SubPadding1.xw;

                compactNormalUV += float2(_SubNormal1.z - 0.5, _SubNormal1.w);
                compactNormalUV.x *= _SubNormal1.x;
                compactNormalUV.y *= _SubNormal1.y;
                compactNormalUV = fmod(compactNormalUV, subUVSize);
                compactNormalUV.x += 0.5;
                compactNormalUV += _SubPadding1.xw;
            }
        }
    }
    else {
        // sub texture 2, [(0, 0.5), (0.5, 1)]
        if (uv.x < 0.5) {
            if (_SubTex2Enabled) {
                float2 subUVSize = float2(0.5 - _SubPadding2.x - _SubPadding2.y, 0.5 - _SubPadding2.z - _SubPadding2.w);
                compactUV += float2(_SubTex2.z, _SubTex2.w - 0.5);
                compactUV.x *= _SubTex2.x;
                compactUV.y *= _SubTex2.y;
                compactUV = fmod(compactUV, subUVSize);
                compactUV.y += 0.5;
                compactUV += _SubPadding2.xw;

                compactNormalUV += float2(_SubNormal2.z, _SubNormal2.w - 0.5);
                compactNormalUV.x *= _SubNormal2.x;
                compactNormalUV.y *= _SubNormal2.y;
                compactNormalUV = fmod(compactNormalUV, subUVSize);
                compactNormalUV.y += 0.5;
                compactNormalUV += _SubPadding2.xw;
            }
        // sub texture 3, [(0.5, 0.5), (1, 1)]
        } else {
            if (_SubTex3Enabled) {
                float2 subUVSize = float2(0.5 - _SubPadding3.x - _SubPadding3.y, 0.5 - _SubPadding3.z - _SubPadding3.w);
                compactUV += float2(_SubTex3.z - 0.5, _SubTex3.w - 0.5);
                compactUV.x *= _SubTex3.x;
                compactUV.y *= _SubTex3.y;
                compactUV = fmod(compactUV, subUVSize);
                compactUV += 0.5;
                compactUV += _SubPadding3.xw;

                compactNormalUV += float2(_SubNormal3.z - 0.5, _SubNormal3.w - 0.5);
                compactNormalUV.x *= _SubNormal3.x;
                compactNormalUV.y *= _SubNormal3.y;
                compactNormalUV = fmod(compactNormalUV, subUVSize);
                compactNormalUV += 0.5;
                compactNormalUV += _SubPadding3.xw;
            }
        }
    }
    return float4(compactUV.x, compactUV.y, compactNormalUV.x, compactNormalUV.y);
}

inline void CompactClip(fixed alpha, float2 uv) {
    if (uv.y < 0.5) {
        // sub texture 0, [(0, 0), (0.5, 0.5)]
        if (uv.x < 0.5) {
            if (_SubTex0Enabled && _SubCutoff0Enabled) {
                clip(alpha - _SubCutoff0);
            }
        // sub texture 1, [(0.5, 0), (1, 0.5)]
        } else {
            if (_SubTex1Enabled && _SubCutoff1Enabled) {
                clip(alpha - _SubCutoff1);
            }
        }
    }
    else {
        // sub texture 2, [(0, 0.5), (0.5, 1)]
        if (uv.x < 0.5) {
            if (_SubTex2Enabled && _SubCutoff2Enabled) {
                clip(alpha - _SubCutoff2);
            }
        // sub texture 3, [(0.5, 0.5), (1, 1)]
        } else {
            if (_SubTex3Enabled && _SubCutoff3Enabled) {
                clip(alpha - _SubCutoff3);
            }
        }
    }
}

inline half3 CompactEmission(float2 uv) {
    half3 emission = 0;
    if (uv.y < 0.5) {
        // sub texture 0, [(0, 0), (0.5, 0.5)]
        if (uv.x < 0.5) {
            if (_SubTex0Enabled && _SubEmission0Enabled) {
                emission = tex2D(_EmissionMap, uv).rgb * _SubEmissionColor0.rgb;
            }
        // sub texture 1, [(0.5, 0), (1, 0.5)]
        } else {
            if (_SubTex1Enabled && _SubEmission1Enabled) {
                emission = tex2D(_EmissionMap, uv).rgb * _SubEmissionColor1.rgb;
            }
        }
    }
    else {
        // sub texture 2, [(0, 0.5), (0.5, 1)]
        if (uv.x < 0.5) {
            if (_SubTex2Enabled && _SubEmission2Enabled) {
                emission = tex2D(_EmissionMap, uv).rgb * _SubEmissionColor2.rgb;
            }
        // sub texture 3, [(0.5, 0.5), (1, 1)]
        } else {
            if (_SubTex3Enabled && _SubEmission3Enabled) {
                emission = tex2D(_EmissionMap, uv).rgb * _SubEmissionColor3.rgb;
            }
        }
    }
    return emission;
}

inline fixed4 LightingCompactMobileBlinnPhong(SurfaceOutput s, fixed3 lightDir, fixed3 halfDir, fixed atten) {
    fixed diff = max(0, dot (s.Normal, lightDir));
    fixed nh = max(0, dot (s.Normal, halfDir));
    fixed spec = pow(nh, s.Specular * 128) * s.Gloss;// spec might not be 0 when s.Gloss is 0!

    fixed4 c;
#ifdef _SPECULARMAP
    // force spec to be 0 when s.Gloss is 0.
    const fixed kFixedEpsilon = 0.001;
    if (s.Gloss < kFixedEpsilon) spec = 0;
#endif
    c.rgb = (s.Albedo * _LightColor0.rgb * diff + _LightColor0.rgb * spec) * atten;
    UNITY_OPAQUE_ALPHA(c.a);
    return c;
}

float2 MobileSurf(Input IN, inout SurfaceOutput o) {
    fixed4 c;
#ifdef _NORMALMAP
    float4 uvs = CompactBumpedUVs(IN.uv_MainTex);
    float2 uv = uvs.xy;
#else
    float2 uv = CompactUV(IN.uv_MainTex);
#endif

    c = tex2D(_MainTex, uv);

#ifdef _CUTOFF
#   ifdef _COMPACT_TEXTURE
    CompactClip(c.a, uv);
#   else
    clip(c.a - _Cutoff);
#   endif
#endif

    o.Albedo = c.rgb;
    o.Alpha = c.a;

#ifdef _NORMALMAP
    o.Normal = UnpackNormal(tex2D(_BumpMap, uvs.zw));
#endif

#ifdef _EMISSION
#   ifdef _COMPACT_TEXTURE
    o.Emission = CompactEmission(uv);
#   else
    o.Emission = tex2D(_EmissionMap, uv).rgb * _EmissionColor.rgb;
#   endif
#endif
    return uv;
}

inline void CompactSpecularSetup(float2 uv, inout SurfaceOutput o) {
    
    if (uv.y < 0.5) {
        // sub texture 0, [(0, 0), (0.5, 0.5)]
        if (uv.x < 0.5) {
            if (_SubTex0Enabled && _SubSpecular0Enabled) {
#ifdef _SPECULARMAP
                o.Gloss = tex2D(_SpecularMap, uv).r * o.Alpha;
                o.Specular = _SubShininess0;
#else
                o.Gloss = o.Alpha;
                o.Specular = _SubShininess0;
#endif
            }
        // sub texture 1, [(0.5, 0), (1, 0.5)]
        } else {
            if (_SubTex1Enabled && _SubSpecular1Enabled) {
#ifdef _SPECULARMAP
                o.Gloss = tex2D(_SpecularMap, uv).r * o.Alpha;
                o.Specular = _SubShininess1;
#else
                o.Gloss = o.Alpha;
                o.Specular = _SubShininess1;
#endif
            }
        }
    }
    else {
        // sub texture 2, [(0, 0.5), (0.5, 1)]
        if (uv.x < 0.5) {
            if (_SubTex2Enabled && _SubSpecular2Enabled) {
#ifdef _SPECULARMAP
                o.Gloss = tex2D(_SpecularMap, uv).r * o.Alpha;
                o.Specular = _SubShininess2;
#else
                o.Gloss = o.Alpha;
                o.Specular = _SubShininess2;
#endif
            }
        // sub texture 3, [(0.5, 0.5), (1, 1)]
        } else {
            if (_SubTex3Enabled && _SubSpecular3Enabled) {
#ifdef _SPECULARMAP
                o.Gloss = tex2D(_SpecularMap, uv).r * o.Alpha;
                o.Specular = _SubShininess3;
#else
                o.Gloss = o.Alpha;
                o.Specular = _SubShininess3;
#endif
            }
        }
    }
}

inline void SpecularSetup(float2 uv, inout SurfaceOutput o) {
#ifdef _COMPACT_TEXTURE
    CompactSpecularSetup(uv, o);
#else
#   ifdef _SPECULARMAP
    o.Gloss = tex2D(_SpecularMap, uv).r * o.Alpha;
#   else
    o.Gloss = o.Alpha;
#   endif
    o.Specular = _Shininess;
#endif
}

void MobileSurfSpec(Input IN, inout SurfaceOutput o) {
    float2 uv = MobileSurf(IN, o);
    SpecularSetup(uv, o);
}

#endif
