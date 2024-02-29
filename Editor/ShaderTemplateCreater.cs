#if UNITY_EDITOR
using System.Collections;
using System.Collections.Generic;
using System.Reflection;
using UnityEngine;
using UnityEditor;
using System;
using System.Runtime.CompilerServices;
using System.IO;

namespace RenardShaderLibrary
{
    using static RSLUtils;
    /// <summary>
    /// シェーダーテンプレートを作成するエディタ拡張
    /// </summary>
    public class ShaderTemplateCreater : EditorWindow
    {
        private const string MENU_INFO_PATH = "Assets/Create/Shader/OpenRenardShaderTips";
        [MenuItem(MENU_INFO_PATH)]
        private static void OpenRenardShaderTips() => Application.OpenURL("https://github.com/Forenard/RenardShaderLibrary/blob/main/Docs/README.md");

        private const string MENU_POINT_MESH_PREFIX = "Assets/Create/Shader/PointMeshCreater";
        [MenuItem(MENU_POINT_MESH_PREFIX)]
        private static void OpenPointMeshCreater() => PointMeshCreater();

        private const string MENU_MSDF_GENERATOR_PREFIX = "Assets/Create/Shader/MSDFGenerator";
        [MenuItem(MENU_MSDF_GENERATOR_PREFIX)]
        private static void OpenMSDFGenerator() => MSDFGenerator();

        private const string MENU_PREFIX = "Assets/Create/Shader/ShaderTemplate/";
        [MenuItem(MENU_PREFIX + "Nothing")]
        private static void Nothing() => CreateShader();
        [MenuItem(MENU_PREFIX + "V2F_Img")]
        private static void V2F_Img() => CreateShader();
        [MenuItem(MENU_PREFIX + "Unlit")]
        private static void Unlit() => CreateShader();
        [MenuItem(MENU_PREFIX + "Unlit_Transparent")]
        private static void Unlit_Transparent() => CreateShader();
        [MenuItem(MENU_PREFIX + "Particle")]
        private static void Particle() => CreateShader();
        [MenuItem(MENU_PREFIX + "Particle_CVS")]
        private static void Particle_CVS() => CreateShader();
        [MenuItem(MENU_PREFIX + "FullScreen")]
        private static void FullScreen() => CreateShader();
        [MenuItem(MENU_PREFIX + "CRT_Init")]
        private static void CRT_Init() => CreateShader();
        [MenuItem(MENU_PREFIX + "CRT_Update")]
        private static void CRT_Update() => CreateShader();
        [MenuItem(MENU_PREFIX + "Unlit_Billboard")]
        private static void Unlit_Billboard() => CreateShader();
        [MenuItem(MENU_PREFIX + "GPU_Particle_Billboard")]
        private static void GPU_Particle_Billboard() => CreateShader();
        [MenuItem(MENU_PREFIX + "GPU_Particle_Line")]
        private static void GPU_Particle_Line() => CreateShader();
        [MenuItem(MENU_PREFIX + "Vertex_Write")]
        private static void Vertex_Write() => CreateShader();
        [MenuItem(MENU_PREFIX + "Vertex_Read")]
        private static void Vertex_Read() => CreateShader();
        [MenuItem(MENU_PREFIX + "Font")]
        private static void Font() => CreateShader();

        private static void PointMeshCreater()
        {
            var window = GetWindow<PointMeshCreaterWindow>("PointMeshCreater");
            window.Show();
        }
        private static void MSDFGenerator()
        {
            var window = GetWindow<MSDFGeneratorWindow>("MSDFGenerator");
            window.Show();
        }
        private static void CreateShader([CallerMemberName] string shaderName = null)
        {
            string thispath = GetThisScriptPath();
            string path = $"{thispath}\\Template\\{shaderName}.shader";
            string folder = GetProjectWindowFolder();
            string newpath = $"{folder}\\{shaderName}.shader";
            string file = ReadFile(path);
            // rewrite path
            string thisparentpath = thispath.Replace("/Editor", "");
            file = file.Replace("../../", thisparentpath);
            WriteFile(newpath, file);
            AssetDatabase.ImportAsset(newpath);
            var created = AssetDatabase.LoadAssetAtPath(newpath, typeof(UnityEngine.Object));
            Selection.SetActiveObjectWithContext(created, null);
        }
        private static string GetThisScriptPath()
        {
            System.Type scriptType = typeof(ShaderTemplateCreater);
            MonoScript monoScript = MonoScript.FromScriptableObject(ScriptableObject.CreateInstance(scriptType));
            string scriptPath = AssetDatabase.GetAssetPath(monoScript);
            return scriptPath.Replace("ShaderTemplateCreater.cs", "");
        }
    }
}
#endif