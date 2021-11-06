//
// Author: Code Tiger
// Copyright (c) 2021, MIT Lisence
//
#ifndef COMPACT_TEXTURE_COMMON_INCLUDED
#define COMPACT_TEXTURE_COMMON_INCLUDED

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

bool _SubTex0CutoffEnabled;
bool _SubTex1CutoffEnabled;
bool _SubTex2CutoffEnabled;
bool _SubTex3CutoffEnabled;
fixed _SubTex0Cutoff;
fixed _SubTex1Cutoff;
fixed _SubTex2Cutoff;
fixed _SubTex3Cutoff;

fixed _SeamCleaner;

float2 CompactUV(float2 uv) {
    float2 compactUV = uv;
    float subUVOffset = (0.5 - 0.5 * _SeamCleaner) / 2;
    if (uv.y < 0.5) {
        // sub texture 0, [(0, 0), (0.5, 0.5)]
        if (uv.x < 0.5) {
            if (_SubTex0Enabled) {
                compactUV += float2(_SubTex0.z, _SubTex0.w);
                compactUV.x *= _SubTex0.x;
                compactUV.y *= _SubTex0.y;
                compactUV = fmod(compactUV, 0.5);
                compactUV *= _SeamCleaner;
                compactUV += subUVOffset;
            }
        // sub texture 1, [(0.5, 0), (1, 0.5)]
        } else {
            if (_SubTex1Enabled) {
                compactUV += float2(_SubTex1.z - 0.5, _SubTex1.w);
                compactUV.x *= _SubTex1.x;
                compactUV.y *= _SubTex1.y;
                compactUV = fmod(compactUV, 0.5);
                compactUV *= _SeamCleaner;
                compactUV += subUVOffset;
                compactUV.x += 0.5;
            }
        }
    }
    else {
        // sub texture 2, [(0, 0.5), (0.5, 1)]
        if (uv.x < 0.5) {
            if (_SubTex2Enabled) {
                compactUV += float2(_SubTex2.z, _SubTex2.w - 0.5);
                compactUV.x *= _SubTex2.x;
                compactUV.y *= _SubTex2.y;
                compactUV = fmod(compactUV, 0.5);
                compactUV *= _SeamCleaner;
                compactUV += subUVOffset;
                compactUV.y += 0.5;
            }
        // sub texture 3, [(0.5, 0.5), (1, 1)]
        } else {
            if (_SubTex3Enabled) {
                compactUV += float2(_SubTex3.z - 0.5, _SubTex3.w - 0.5);
                compactUV.x *= _SubTex3.x;
                compactUV.y *= _SubTex3.y;
                compactUV = fmod(compactUV, 0.5);
                compactUV *= _SeamCleaner;
                compactUV += subUVOffset;
                compactUV += 0.5;
            }
        }
    }
    return compactUV;
}

float4 CompactBumpedUVs(float2 uv) {
    float2 compactUV = uv;
    float2 compactNormalUV = uv;
    fixed subUVOffset = (0.5 - 0.5 * _SeamCleaner) / 2;
    if (uv.y < 0.5) {
        // sub texture 0, [(0, 0), (0.5, 0.5)]
        if (uv.x < 0.5) {
            if (_SubTex0Enabled) {
                compactUV += float2(_SubTex0.z, _SubTex0.w);
                compactUV.x *= _SubTex0.x;
                compactUV.y *= _SubTex0.y;
                compactUV = fmod(compactUV, 0.5);
                compactUV *= _SeamCleaner;
                compactUV += subUVOffset;

                compactNormalUV += float2(_SubNormal0.z, _SubNormal0.w);
                compactNormalUV.x *= _SubNormal0.x;
                compactNormalUV.y *= _SubNormal0.y;
                compactNormalUV = fmod(compactNormalUV, 0.5);
                compactNormalUV *= _SeamCleaner;
                compactNormalUV += subUVOffset;
            }
        // sub texture 1, [(0.5, 0), (1, 0.5)]
        } else {
            if (_SubTex1Enabled) {
                compactUV += float2(_SubTex1.z - 0.5, _SubTex1.w);
                compactUV.x *= _SubTex1.x;
                compactUV.y *= _SubTex1.y;
                compactUV = fmod(compactUV, 0.5);
                compactUV *= _SeamCleaner;
                compactUV += subUVOffset;
                compactUV.x += 0.5;

                compactNormalUV += float2(_SubNormal1.z - 0.5, _SubNormal1.w);
                compactNormalUV.x *= _SubNormal1.x;
                compactNormalUV.y *= _SubNormal1.y;
                compactNormalUV = fmod(compactNormalUV, 0.5);
                compactNormalUV *= _SeamCleaner;
                compactNormalUV += subUVOffset;
                compactNormalUV.x += 0.5;
            }
        }
    }
    else {
        // sub texture 2, [(0, 0.5), (0.5, 1)]
        if (uv.x < 0.5) {
            if (_SubTex2Enabled) {
                compactUV += float2(_SubTex2.z, _SubTex2.w - 0.5);
                compactUV.x *= _SubTex2.x;
                compactUV.y *= _SubTex2.y;
                compactUV = fmod(compactUV, 0.5);
                compactUV *= _SeamCleaner;
                compactUV += subUVOffset;
                compactUV.y += 0.5;

                compactNormalUV += float2(_SubNormal2.z, _SubNormal2.w - 0.5);
                compactNormalUV.x *= _SubNormal2.x;
                compactNormalUV.y *= _SubNormal2.y;
                compactNormalUV = fmod(compactNormalUV, 0.5);
                compactNormalUV *= _SeamCleaner;
                compactNormalUV += subUVOffset;
                compactNormalUV.y += 0.5;
            }
        // sub texture 3, [(0.5, 0.5), (1, 1)]
        } else {
            if (_SubTex3Enabled) {
                compactUV += float2(_SubTex3.z - 0.5, _SubTex3.w - 0.5);
                compactUV.x *= _SubTex3.x;
                compactUV.y *= _SubTex3.y;
                compactUV = fmod(compactUV, 0.5);
                compactUV *= _SeamCleaner;
                compactUV += subUVOffset;
                compactUV += 0.5;

                compactNormalUV += float2(_SubNormal3.z - 0.5, _SubNormal3.w - 0.5);
                compactNormalUV.x *= _SubNormal3.x;
                compactNormalUV.y *= _SubNormal3.y;
                compactNormalUV = fmod(compactNormalUV, 0.5);
                compactNormalUV *= _SeamCleaner;
                compactNormalUV += subUVOffset;
                compactNormalUV += 0.5;
            }
        }
    }
    return float4(compactUV.x, compactUV.y, compactNormalUV.x, compactNormalUV.y);
}

void CompactClip(fixed alpha, float2 uv) {
    if (uv.y < 0.5) {
        // sub texture 0, [(0, 0), (0.5, 0.5)]
        if (uv.x < 0.5) {
            if (_SubTex0CutoffEnabled) {
                clip(alpha - _SubTex0Cutoff);
            }
        // sub texture 1, [(0.5, 0), (1, 0.5)]
        } else {
            if (_SubTex1CutoffEnabled) {
                clip(alpha - _SubTex1Cutoff);
            }
        }
    }
    else {
        // sub texture 2, [(0, 0.5), (0.5, 1)]
        if (uv.x < 0.5) {
            if (_SubTex2CutoffEnabled) {
                clip(alpha - _SubTex2Cutoff);
            }
        // sub texture 3, [(0.5, 0.5), (1, 1)]
        } else {
            if (_SubTex3CutoffEnabled) {
                clip(alpha - _SubTex3Cutoff);
            }
        }
    }
}

#endif
