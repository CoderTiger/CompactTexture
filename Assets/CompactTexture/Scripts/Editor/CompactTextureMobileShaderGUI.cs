using System;
using UnityEngine;
using UnityEditor;

internal class CompactTextureMobileShaderGUI : ShaderGUI
{
    public enum TextureType
    {
        Single,
        Compact
    }

    public enum BlendMode
    {
        Opaque,
        Cutout
    }

    private static class Styles
    {
        public static string textureType = "Texture Type";
        public static readonly string[] textureTypes = Enum.GetNames(typeof(TextureType));

        public static GUIContent albedoText = EditorGUIUtility.TrTextContent("Albedo", "Albedo (RGB) and Transparency (A)");
        public static GUIContent alphaCutoutText = EditorGUIUtility.TrTextContent("Cutout", "Enable cutout?");
        public static GUIContent alphaCutoffText = EditorGUIUtility.TrTextContent("Alpha Cutoff", "Threshold for alpha cutoff");
        public static GUIContent normalMapText = EditorGUIUtility.TrTextContent("Normal Map", "Normal Map");
        public static GUIContent specularMapText = EditorGUIUtility.TrTextContent("Specular Map", "Specular Map");
        public static GUIContent shininessText = EditorGUIUtility.TrTextContent("Shininess", "Specular Shininess");
        public static GUIContent emissionMapText = EditorGUIUtility.TrTextContent("Emission Map", "Emission Map");
        public static GUIContent emissionColorText = EditorGUIUtility.TrTextContent("Color", "Emission (RGB)");

        public static GUIContent paddingText = EditorGUIUtility.TrTextContent("Padding", "Padding Space (used to erasing seams)");

        public static string forwardText = "Forward Rendering Options";
        public static string renderingMode = "Rendering Mode";
        public static string advancedText = "Advanced Options";
        public static readonly string[] blendNames = Enum.GetNames(typeof(BlendMode));
    }

    private class SubProperties
    {
        public static class Styles
        {
            private static string subTexEnabledNameFormat = "Sub textuer {0}";
            private static string subTexEnabledTipFormat =  "Sub region {0} {1} of the main texture.";

            private static string[] uvRegions = {
                "[(0,0),(0.5,0.5)]",
                "[(0.5,0),(1,0.5)]",
                "[(0,0.5),(0.5,1)]",
                "[(0.5,0.5),(1,1)]"
            };

            public static GUIContent SubTexEnabled(int index)
            {
                GUIContent ret = EditorGUIUtility.TrTextContent(
                    string.Format(subTexEnabledNameFormat, index),
                    string.Format(subTexEnabledTipFormat, index, uvRegions[index])
                    );
                return ret;
            }
        }

        public MaterialProperty texEnabled = null;
        public MaterialProperty padding = null;
        public MaterialProperty tex = null;
        public MaterialProperty normal = null;
        public MaterialProperty specularEnabled = null;
        public MaterialProperty shininess = null;
        public MaterialProperty cutoffEnabled = null;
        public MaterialProperty cutoff = null;
        public MaterialProperty emissionEnabled = null;
        public MaterialProperty emissionColorForRendering = null;

        public void FindeProperties(int index, MaterialProperty[] props)
        {
            texEnabled = FindProperty("_SubTex" + index + "Enabled", props);
            padding = FindProperty("_SubPadding" + index, props);
            tex = FindProperty("_SubTex" + index, props);
            normal = FindProperty("_SubNormal" + index, props);
            specularEnabled = FindProperty("_SubSpecular" + index + "Enabled", props, false);
            shininess = FindProperty("_SubShininess" + index, props, false);
            cutoffEnabled = FindProperty("_SubCutoff" + index + "Enabled", props);
            cutoff = FindProperty("_SubCutoff" + index, props);
            emissionEnabled = FindProperty("_SubEmission" + index + "Enabled", props);
            emissionColorForRendering = FindProperty("_SubEmissionColor" + index, props);
        }
    }

    MaterialProperty textureType = null;
    MaterialProperty blendMode = null;
    MaterialProperty albedoMap = null;
    MaterialProperty specularMap = null;
    MaterialProperty shininess = null;
    MaterialProperty alphaCutoff = null;
    MaterialProperty bumpMap = null;
    MaterialProperty emissionColorForRendering = null;
    MaterialProperty emissionMap = null;

    SubProperties[] subProperties = new SubProperties[4];

    MaterialEditor m_MaterialEditor;
    bool m_FirstTimeApply = true;
    bool m_EmissionEnabled = false;
    bool m_HadEmissionTexture = false;

    public void FindProperties(MaterialProperty[] props)
    {
        textureType = FindProperty("_TextureType", props);

        blendMode = FindProperty("_Mode", props);
        albedoMap = FindProperty("_MainTex", props);
        specularMap = FindProperty("_SpecularMap", props, false);
        shininess = FindProperty("_Shininess", props, false);
        alphaCutoff = FindProperty("_Cutoff", props);
        bumpMap = FindProperty("_BumpMap", props, false);
        emissionColorForRendering = FindProperty("_EmissionColor", props);
        emissionMap = FindProperty("_EmissionMap", props);

        for (int i = 0; i < subProperties.Length; i++)
        {
            subProperties[i].FindeProperties(i, props);
        }
    }

    public override void OnGUI(MaterialEditor materialEditor, MaterialProperty[] properties)
    {
        if (m_FirstTimeApply)
        {
            for (int i = 0; i < subProperties.Length; i++)
            {
                subProperties[i] = new SubProperties();
            }
        }

        FindProperties(properties);
        m_MaterialEditor = materialEditor;
        materialEditor.SetDefaultGUIWidths();
        Material material = materialEditor.target as Material;

        if (m_FirstTimeApply)
        {
            int renderQueue = material.renderQueue;
            MaterialChanged(material);
            material.renderQueue = renderQueue;
            m_FirstTimeApply = false;
        }

        ShaderPropertiesGUI(material);
    }

    public override void AssignNewShaderToMaterial(Material material, Shader oldShader, Shader newShader)
    {
        // _Emission property is lost after assigning Standard shader to the material
        // thus transfer it before assigning the new shader
        if (material.HasProperty("_Emission"))
        {
            material.SetColor("_EmissionColor", material.GetColor("_Emission"));
        }

        base.AssignNewShaderToMaterial(material, oldShader, newShader);

        material.SetFloat("_TextureType", (float)TextureType.Compact);
        material.SetFloat("_Mode", (float)BlendMode.Opaque);
        MaterialChanged(material);
    }

    public void ShaderPropertiesGUI(Material material)
    {
        // Use default labelWidth
        EditorGUIUtility.labelWidth = 0f;
        // Detect any changes to the material
        EditorGUI.BeginChangeCheck();
        {
            TextuerTypePopup();
            BlendModePopup();
            EditorGUI.BeginChangeCheck();

            DoTexturesArea(material);
            EditorGUILayout.Space();
            DoSubtexturesArea(material);
            EditorGUILayout.Space();

            if (EditorGUI.EndChangeCheck())
                emissionMap.textureScaleAndOffset = albedoMap.textureScaleAndOffset; // Apply the main texture scale and offset to the emission texture as well, for Enlighten's sake
        }
        if (EditorGUI.EndChangeCheck())
        {
            foreach (var obj in textureType.targets)
                MaterialChanged((Material)obj);
            foreach (var obj in blendMode.targets)
                MaterialChanged((Material)obj);
        }
        EditorGUILayout.Space();

        // NB renderqueue editor is not shown on purpose: we want to override it based on blend mode
        GUILayout.Label(Styles.advancedText, EditorStyles.boldLabel);
        m_MaterialEditor.RenderQueueField();
        m_MaterialEditor.EnableInstancingField();
        m_MaterialEditor.DoubleSidedGIField();
    }

    void TextuerTypePopup()
    {
        EditorGUI.showMixedValue = textureType.hasMixedValue;
        var type = (TextureType)textureType.floatValue;

        EditorGUI.BeginChangeCheck();
        type = (TextureType)EditorGUILayout.Popup(Styles.textureType, (int)type, Styles.textureTypes);

        if (EditorGUI.EndChangeCheck())
        {
            m_MaterialEditor.RegisterPropertyChangeUndo("Texture Type");
            textureType.floatValue = (float)type;
        }

        EditorGUI.showMixedValue = false;
    }

    void BlendModePopup()
    {
        EditorGUI.showMixedValue = blendMode.hasMixedValue;
        var mode = (BlendMode)blendMode.floatValue;

        EditorGUI.BeginChangeCheck();
        mode = (BlendMode)EditorGUILayout.Popup(Styles.renderingMode, (int)mode, Styles.blendNames);
        if (EditorGUI.EndChangeCheck())
        {
            m_MaterialEditor.RegisterPropertyChangeUndo("Rendering Mode");
            blendMode.floatValue = (float)mode;
        }

        EditorGUI.showMixedValue = false;
    }

    void DoTexturesArea(Material material)
    {
        bool isNotCompact = (TextureType)textureType.floatValue != TextureType.Compact;
        BlendMode mode = (BlendMode)material.GetFloat("_Mode");

        m_MaterialEditor.TextureProperty(albedoMap, Styles.albedoText.text, false);
        if (bumpMap != null)
        {
            m_MaterialEditor.TextureProperty(bumpMap, Styles.normalMapText.text, false);
        }
        if (specularMap != null)
        {
            m_MaterialEditor.TextureProperty(specularMap, Styles.specularMapText.text, false);
        }

        if (isNotCompact)
        {
            if (shininess != null)
            {
                EditorGUI.indentLevel++;
                m_MaterialEditor.ShaderProperty(shininess, Styles.shininessText.text);
                EditorGUI.indentLevel--;
            }
            if (mode == BlendMode.Cutout)
            {
                EditorGUI.indentLevel++;
                m_MaterialEditor.ShaderProperty(alphaCutoff, Styles.alphaCutoffText.text);
                EditorGUI.indentLevel--;
            }
        }

        m_EmissionEnabled = m_MaterialEditor.EmissionEnabledProperty();
        // change the GI flag and fix it up with emissive as black if necessary
        if (m_EmissionEnabled)
        {
            if (isNotCompact)
            {
                EditorGUI.indentLevel++;
                m_MaterialEditor.ShaderProperty(emissionColorForRendering, Styles.emissionColorText);
                //emissionColorForRendering.colorValue = EditorGUILayout.ColorField(Styles.emissionColorText, emissionColorForRendering.colorValue, true, false, true);
                EditorGUI.indentLevel--;
            }
            m_HadEmissionTexture = emissionMap.textureValue != null;
            m_MaterialEditor.TextureProperty(emissionMap, Styles.emissionMapText.text);

            // If texture was assigned and color was black set color to white
            float brightness = emissionColorForRendering.colorValue.maxColorComponent;
            if (emissionMap.textureValue != null && !m_HadEmissionTexture && brightness <= 0f)
                emissionColorForRendering.colorValue = Color.white;

            m_MaterialEditor.LightmapEmissionFlagsProperty(EditorGUI.indentLevel + 1, true);
        }
    }

    static float GetFloatValueBetweenMinMax(float min, float max, float value)
    {
        if (value < min) return min;
        if (value > max) return max;
        return value;
    }

    static Vector4 GetVector4ValueBetweenMinMax(float min, float max, Vector4 value)
    {
        Vector4 ret = new Vector4(
            GetFloatValueBetweenMinMax(min, max, value.x),
            GetFloatValueBetweenMinMax(min, max, value.y),
            GetFloatValueBetweenMinMax(min, max, value.z),
            GetFloatValueBetweenMinMax(min, max, value.w)
            );
        return ret;
    }

    void DoPaddingArea(MaterialProperty paddingProp, int labelIndentLevel)
    {
        int origLabelIndentLevel = EditorGUI.indentLevel;
        EditorGUI.indentLevel = labelIndentLevel;
        EditorGUILayout.LabelField(Styles.paddingText);
        EditorGUI.indentLevel++;

        const float kMaxPaddingFloatFieldWidth = 30;
        Vector4 paddingNameWidths = new Vector4(80, 80, 80, 80);// new Vector4(36, 42, 34, 57);
        float origionalLableWidth = EditorGUIUtility.labelWidth;
        EditorGUILayout.BeginHorizontal();
        EditorGUIUtility.labelWidth = paddingNameWidths.x;
        float left = EditorGUILayout.FloatField("left", paddingProp.vectorValue.x,
            GUILayout.MaxWidth(kMaxPaddingFloatFieldWidth + paddingNameWidths.x), GUILayout.ExpandWidth(true));
        EditorGUIUtility.labelWidth = paddingNameWidths.y;
        float right = EditorGUILayout.FloatField("right", paddingProp.vectorValue.y,
            GUILayout.MaxWidth(kMaxPaddingFloatFieldWidth + paddingNameWidths.y), GUILayout.ExpandWidth(true));
        EditorGUILayout.EndHorizontal();
        EditorGUILayout.BeginHorizontal();
        EditorGUIUtility.labelWidth = paddingNameWidths.z;
        float top = EditorGUILayout.FloatField("top", paddingProp.vectorValue.z,
            GUILayout.MaxWidth(kMaxPaddingFloatFieldWidth + paddingNameWidths.z), GUILayout.ExpandWidth(true));
        EditorGUIUtility.labelWidth = paddingNameWidths.w;
        float bottom = EditorGUILayout.FloatField("bottom", paddingProp.vectorValue.w,
            GUILayout.MaxWidth(kMaxPaddingFloatFieldWidth + paddingNameWidths.w), GUILayout.ExpandWidth(true));
        paddingProp.vectorValue = GetVector4ValueBetweenMinMax(0, 0.2499f, new Vector4(left, right, top, bottom));
        EditorGUILayout.EndHorizontal();

        EditorGUIUtility.labelWidth = origionalLableWidth;
        EditorGUI.indentLevel--;
        EditorGUI.indentLevel = origLabelIndentLevel;
    }

    void DoTextureScaleOffsetArea(GUIContent label, MaterialProperty scaleOffsetProp, int labelIndentLevel)
    {
        int origLabelIndentLevel = EditorGUI.indentLevel;
        EditorGUI.indentLevel = labelIndentLevel;
        EditorGUILayout.LabelField(label);
        EditorGUI.indentLevel++;

        const float kGroupNameWidth = 20;
        const float kMaxFloatFieldValueWidth = 80;
        const float kFloatFieldNameWidth = 30;
        float origionalLableWidth = EditorGUIUtility.labelWidth;

        EditorGUILayout.BeginHorizontal();
        EditorGUIUtility.labelWidth = kGroupNameWidth;
        EditorGUILayout.LabelField("Tiling");
        EditorGUIUtility.labelWidth = kFloatFieldNameWidth;
        float x = EditorGUILayout.FloatField("X", scaleOffsetProp.vectorValue.x,
            GUILayout.MaxWidth(kMaxFloatFieldValueWidth + kFloatFieldNameWidth), GUILayout.ExpandWidth(true));
        EditorGUIUtility.labelWidth = kFloatFieldNameWidth;
        float y = EditorGUILayout.FloatField("Y", scaleOffsetProp.vectorValue.y,
            GUILayout.MaxWidth(kMaxFloatFieldValueWidth + kFloatFieldNameWidth), GUILayout.ExpandWidth(true));
        EditorGUILayout.EndHorizontal();
        EditorGUILayout.BeginHorizontal();
        EditorGUIUtility.labelWidth = kGroupNameWidth;
        EditorGUILayout.LabelField("Offset");
        EditorGUIUtility.labelWidth = kFloatFieldNameWidth;
        float z = EditorGUILayout.FloatField("X", scaleOffsetProp.vectorValue.z,
            GUILayout.MaxWidth(kMaxFloatFieldValueWidth + kFloatFieldNameWidth), GUILayout.ExpandWidth(true));
        EditorGUIUtility.labelWidth = kFloatFieldNameWidth;
        float w = EditorGUILayout.FloatField("Y", scaleOffsetProp.vectorValue.w,
            GUILayout.MaxWidth(kMaxFloatFieldValueWidth + kFloatFieldNameWidth), GUILayout.ExpandWidth(true));
        scaleOffsetProp.vectorValue = new Vector4(x, y, z, w);
        EditorGUILayout.EndHorizontal();

        EditorGUIUtility.labelWidth = origionalLableWidth;
        EditorGUI.indentLevel--;
        EditorGUI.indentLevel = origLabelIndentLevel;
    }

    void DoSubtexturesArea(Material material)
    {
        BlendMode mode = (BlendMode)material.GetFloat("_Mode");
        TextureType type = (TextureType)material.GetFloat("_TextureType");
        bool hasNormal = material.GetTexture("_BumpMap") != null;
        if (type == TextureType.Compact)
        {
            for (int i = 0; i < subProperties.Length; i++)
            {
                EditorGUILayout.LabelField("", GUI.skin.horizontalSlider);
                var origFontStyle = EditorStyles.label.fontStyle;
                int origFontSize = EditorStyles.label.fontSize;
                EditorStyles.label.fontStyle = FontStyle.Bold;
                EditorStyles.label.fontSize = (int)(1.2 * origFontSize);
                bool enabled = EditorGUILayout.Toggle(SubProperties.Styles.SubTexEnabled(i), subProperties[i].texEnabled.floatValue > 0);
                EditorStyles.label.fontSize = origFontSize;
                EditorStyles.label.fontStyle = origFontStyle;
                subProperties[i].texEnabled.floatValue = enabled ? 1 : 0;
                if (enabled)
                {
                    DoPaddingArea(subProperties[i].padding, EditorGUI.indentLevel);

                    DoTextureScaleOffsetArea(Styles.albedoText, subProperties[i].tex, EditorGUI.indentLevel);
                    if (hasNormal)
                    {
                        DoTextureScaleOffsetArea(Styles.normalMapText, subProperties[i].normal, EditorGUI.indentLevel);
                    }

                    if (shininess != null)
                    {
                        bool subSpecularEnabled = EditorGUILayout.Toggle(Styles.specularMapText, subProperties[i].specularEnabled.floatValue > 0);
                        subProperties[i].specularEnabled.floatValue = subSpecularEnabled ? 1 : 0;
                        if (subSpecularEnabled)
                        {
                            EditorGUI.indentLevel++;
                            m_MaterialEditor.ShaderProperty(subProperties[i].shininess, Styles.shininessText.text);
                            EditorGUI.indentLevel--;
                        }
                    }

                    if (mode == BlendMode.Cutout)
                    {
                        bool cutoffEnabled = EditorGUILayout.Toggle(Styles.alphaCutoutText, subProperties[i].cutoffEnabled.floatValue > 0);
                        subProperties[i].cutoffEnabled.floatValue = cutoffEnabled ? 1 : 0;
                        if (cutoffEnabled)
                        {
                            EditorGUI.indentLevel++;
                            m_MaterialEditor.ShaderProperty(subProperties[i].cutoff, Styles.alphaCutoffText.text);
                            EditorGUI.indentLevel--;
                        }
                    }

                    if (m_EmissionEnabled)
                    {
                        bool subEmissionEnabled = EditorGUILayout.Toggle(Styles.emissionMapText, subProperties[i].emissionEnabled.floatValue > 0);
                        subProperties[i].emissionEnabled.floatValue = subEmissionEnabled ? 1 : 0;
                        if (subEmissionEnabled)
                        {
                            EditorGUI.indentLevel++;
                            m_MaterialEditor.ShaderProperty(subProperties[i].emissionColorForRendering, Styles.emissionColorText);
                            EditorGUI.indentLevel--;
                            //subProperties[i].emissionColorForRendering.colorValue = EditorGUILayout.ColorField(
                            //    Styles.emissionColorText,
                            //    subProperties[i].emissionColorForRendering.colorValue,
                            //    true,
                            //    false,
                            //    true
                            //    );

                            // If texture was assigned and color was black set color to white
                            float brightness = subProperties[i].emissionColorForRendering.colorValue.maxColorComponent;
                            if (emissionMap.textureValue != null && !m_HadEmissionTexture && brightness <= 0f)
                                subProperties[i].emissionColorForRendering.colorValue = Color.white;
                        }
                    }
                }
                EditorGUILayout.Space();
            }
            EditorGUILayout.LabelField("", GUI.skin.horizontalSlider);
        }
    }

    public static void SetupMaterial(Material material, TextureType textureType, BlendMode blendMode)
    {
        switch (blendMode)
        {
            case BlendMode.Opaque:
                material.SetOverrideTag("RenderType", "");
                SetKeyword(material, "_CUTOFF", false);
                break;
            case BlendMode.Cutout:
                material.SetOverrideTag("RenderType", "TransparentCutout");
                SetKeyword(material, "_CUTOFF", true);
                break;
        }
        switch (textureType)
        {
            case TextureType.Compact:
                SetKeyword(material, "_COMPACT_TEXTURE", true);
                break;
            case TextureType.Single:
                SetKeyword(material, "_COMPACT_TEXTURE", false);
                break;
        }
    }

    static void SetMaterialKeywords(Material material)
    {
        SetKeyword(material, "_NORMALMAP", material.GetTexture("_BumpMap"));

        if (material.HasProperty("_SpecularMap"))
        {
            SetKeyword(material, "_SPECULARMAP", material.GetTexture("_SpecularMap"));
        }

        MaterialEditor.FixupEmissiveFlag(material);
        bool shouldEmissionBeEnabled = (material.globalIlluminationFlags & MaterialGlobalIlluminationFlags.EmissiveIsBlack) == 0;
        SetKeyword(material, "_EMISSION", shouldEmissionBeEnabled);
    }

    static void MaterialChanged(Material material)
    {
        SetupMaterial(material, (TextureType)material.GetFloat("_TextureType"), (BlendMode)material.GetFloat("_Mode"));
        SetMaterialKeywords(material);
    }

    static void SetKeyword(Material material, string keyword, bool state)
    {
        if (state)
            material.EnableKeyword(keyword);
        else
            material.DisableKeyword(keyword);
    }
}
