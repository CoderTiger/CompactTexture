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
        public static GUIContent shininessText = EditorGUIUtility.TrTextContent("Specular Shininess", "Specular Shininess");
        public static GUIContent emissionMapText = EditorGUIUtility.TrTextContent("Emission Map", "Emission Map");
        public static GUIContent emissionColorText = EditorGUIUtility.TrTextContent("Color", "Emission (RGB)");

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
        public MaterialProperty tex = null;
        public MaterialProperty texDummy = null;
        public MaterialProperty normal = null;
        public MaterialProperty normalDummy = null;
        public MaterialProperty specularEnabled = null;
        public MaterialProperty shininess = null;
        public MaterialProperty cutoffEnabled = null;
        public MaterialProperty cutoff = null;
        public MaterialProperty emissionEnabled = null;
        public MaterialProperty emissionColorForRendering = null;

        public void FindeProperties(int index, MaterialProperty[] props)
        {
            texEnabled = FindProperty("_SubTex" + index + "Enabled", props);
            tex = FindProperty("_SubTex" + index, props);
            texDummy = FindProperty("_SubTexDummy" + index, props);
            normal = FindProperty("_SubNormal" + index, props);
            normalDummy = FindProperty("_SubNormalDummy" + index, props);
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
        bumpMap = FindProperty("_BumpMap", props);
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
            MaterialChanged(material);
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
        m_MaterialEditor.TextureProperty(bumpMap, Styles.normalMapText.text, false);
        if (specularMap != null)
        {
            m_MaterialEditor.TextureProperty(specularMap, Styles.specularMapText.text, false);
        }

        if (isNotCompact)
        {
            m_MaterialEditor.ShaderProperty(shininess, Styles.shininessText.text, MaterialEditor.kMiniTextureFieldLabelIndentLevel + 1);
            if (mode == BlendMode.Cutout)
            {
                m_MaterialEditor.ShaderProperty(alphaCutoff, Styles.alphaCutoffText.text, MaterialEditor.kMiniTextureFieldLabelIndentLevel + 1);
            }
        }

        m_EmissionEnabled = m_MaterialEditor.EmissionEnabledProperty();
        // change the GI flag and fix it up with emissive as black if necessary
        if (m_EmissionEnabled)
        {
            if (isNotCompact)
            {
                emissionColorForRendering.colorValue = EditorGUILayout.ColorField(Styles.emissionColorText, emissionColorForRendering.colorValue, true, false, true);
            }
            m_HadEmissionTexture = emissionMap.textureValue != null;
            m_MaterialEditor.TextureProperty(emissionMap, Styles.emissionMapText.text);

            // If texture was assigned and color was black set color to white
            float brightness = emissionColorForRendering.colorValue.maxColorComponent;
            if (emissionMap.textureValue != null && !m_HadEmissionTexture && brightness <= 0f)
                emissionColorForRendering.colorValue = Color.white;

            m_MaterialEditor.LightmapEmissionFlagsProperty(MaterialEditor.kMiniTextureFieldLabelIndentLevel, true);
        }
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
                    GUILayout.Label("Albedo:");
                    EditorGUILayout.BeginVertical("Albedo");
                    m_MaterialEditor.TextureScaleOffsetProperty(subProperties[i].texDummy);
                    subProperties[i].tex.vectorValue = subProperties[i].texDummy.textureScaleAndOffset;
                    EditorGUILayout.EndVertical();

                    if (hasNormal)
                    {
                        GUILayout.Label("Normal Map:");
                        EditorGUILayout.BeginVertical("Normal Map");
                        m_MaterialEditor.TextureScaleOffsetProperty(subProperties[i].normalDummy);
                        subProperties[i].normal.vectorValue = subProperties[i].normalDummy.textureScaleAndOffset;
                        EditorGUILayout.EndVertical();
                    }

                    if (shininess != null)
                    {
                        bool subSpecularEnabled = EditorGUILayout.Toggle(Styles.specularMapText, subProperties[i].specularEnabled.floatValue > 0);
                        subProperties[i].specularEnabled.floatValue = subSpecularEnabled ? 1 : 0;
                        if (subSpecularEnabled)
                        {
                            m_MaterialEditor.ShaderProperty(subProperties[i].shininess, Styles.shininessText.text, MaterialEditor.kMiniTextureFieldLabelIndentLevel + 1);
                        }
                    }

                    if (mode == BlendMode.Cutout)
                    {
                        bool cutoffEnabled = EditorGUILayout.Toggle(Styles.alphaCutoutText, subProperties[i].cutoffEnabled.floatValue > 0);
                        subProperties[i].cutoffEnabled.floatValue = cutoffEnabled ? 1 : 0;
                        if (cutoffEnabled)
                        {
                            m_MaterialEditor.ShaderProperty(subProperties[i].cutoff, Styles.alphaCutoffText.text, MaterialEditor.kMiniTextureFieldLabelIndentLevel + 1);
                        }
                    }

                    if (m_EmissionEnabled)
                    {
                        bool subEmissionEnabled = EditorGUILayout.Toggle(Styles.emissionMapText, subProperties[i].emissionEnabled.floatValue > 0);
                        subProperties[i].emissionEnabled.floatValue = subEmissionEnabled ? 1 : 0;
                        if (subEmissionEnabled)
                        {
                            subProperties[i].emissionColorForRendering.colorValue = EditorGUILayout.ColorField(
                                Styles.emissionColorText,
                                subProperties[i].emissionColorForRendering.colorValue,
                                true,
                                false,
                                true
                                );

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
                material.renderQueue = -1;
                break;
            case BlendMode.Cutout:
                material.SetOverrideTag("RenderType", "TransparentCutout");
                SetKeyword(material, "_CUTOFF", true);
                material.renderQueue = (int)UnityEngine.Rendering.RenderQueue.AlphaTest;
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
        // Note: keywords must be based on Material value not on MaterialProperty due to multi-edit & material animation
        // (MaterialProperty value might come from renderer material property block)
        SetKeyword(material, "_NORMALMAP", material.GetTexture("_BumpMap"));

        if (material.HasProperty("_SpecularMap"))
        {
            SetKeyword(material, "_SPECULARMAP", material.GetTexture("_SpecularMap"));
        }

        // A material's GI flag internally keeps track of whether emission is enabled at all, it's enabled but has no effect
        // or is enabled and may be modified at runtime. This state depends on the values of the current flag and emissive color.
        // The fixup routine makes sure that the material is in the correct state if/when changes are made to the mode or color.
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
