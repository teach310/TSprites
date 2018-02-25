using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;
using System.Linq;

public static class TShaderGUIUtils {

	/// <summary>
	/// Toggleで表示するUIを切り替える
	/// </summary>
	public static void DrawProperties(MaterialProperty toggle, string keyword, MaterialEditor materialEditor, MaterialProperty[] properties, string title = ""){
		
		materialEditor.ShaderProperty (toggle, string.IsNullOrEmpty(title) ? toggle.name : title);

		if (toggle.floatValue == 1f) {
			var subTexProps = properties
				.Where (x => x.name.Contains (keyword))
				.Where (x => x.name != toggle.name);
			EditorGUI.indentLevel++;
			foreach (var prop in subTexProps) {
				materialEditor.ShaderProperty (prop, prop.displayName);
			}
			EditorGUI.indentLevel--;
		}
	}

}
