using System.Collections;
using System.Collections.Generic;
using UnityEditor;
using UnityEngine;

public class TSpritesEffectEditor : ShaderGUI {

	public override void OnGUI (MaterialEditor materialEditor, MaterialProperty[] properties)
	{
		using (new EditorGUILayout.VerticalScope (GUI.skin.box)) {
			var subTexToggle = ShaderGUI.FindProperty ("_UseSubTexture", properties);
			TShaderGUIUtils.DrawProperties (subTexToggle, "_SubTex", materialEditor, properties, "Sub Texture");
		}
		using (new EditorGUILayout.VerticalScope (GUI.skin.box)) {
			var maskToggle = ShaderGUI.FindProperty ("_UseMask", properties);
			TShaderGUIUtils.DrawProperties (maskToggle, "_Mask", materialEditor, properties, "Mask");
		}
		using (new EditorGUILayout.VerticalScope (GUI.skin.box)) {
			var gradToggle = ShaderGUI.FindProperty ("_UseGradation", properties);
			TShaderGUIUtils.DrawProperties (gradToggle, "_Gradation", materialEditor, properties, "Gradation");
		}

		using (new EditorGUILayout.VerticalScope (GUI.skin.box)) {
			var polarCoordToggle = ShaderGUI.FindProperty ("_UsePolarCoord", properties);
			materialEditor.ShaderProperty (polarCoordToggle, "PolarCoord");
		}
	}
}
