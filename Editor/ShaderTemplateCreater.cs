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

        private static void PointMeshCreater()
        {
            var window = GetWindow<PointMeshCreaterWindow>("PointMeshCreater");
            window.Show();
        }
        private static void CreateShader([CallerMemberName] string shaderName = null)
        {
            // このライブラリを置いている場所に依存してるよ～～～～
            string path = Application.dataPath + $"/RenardShaderLibrary/Editor/Template/{shaderName}.shader";
            string file = ReadFile(path);
            string folder = GetProjectWindowFolder();
            string newpath = $"{folder}/{shaderName}.shader";
            WriteFile(newpath, file);
            AssetDatabase.ImportAsset(newpath);
            var created = AssetDatabase.LoadAssetAtPath(newpath, typeof(UnityEngine.Object));
            Selection.SetActiveObjectWithContext(created, null);
        }
        private static string ReadFile(string path)
        {
            var fs = new FileStream(path, FileMode.Open, FileAccess.Read);
            var sr = new StreamReader(fs);
            string file = sr.ReadToEnd();
            sr.Close();
            fs.Close();
            return file;
        }
        private static void WriteFile(string path, string file)
        {
            var fs = new FileStream(path, FileMode.CreateNew, FileAccess.Write);
            var sw = new StreamWriter(fs);
            sw.Write(file);
            sw.Close();
            fs.Close();
        }
        // https://gist.github.com/allanolivei/9260107?permalink_comment_id=4232189#gistcomment-4232189
        private static string GetProjectWindowFolder()
        {
            string projectPath = new DirectoryInfo(Application.dataPath).Parent.FullName;
            string objectProjectPath = AssetDatabase.GetAssetPath(Selection.activeObject);
            string objectAbsolutePath = string.IsNullOrEmpty(objectProjectPath) ? Application.dataPath : $"{projectPath}/{objectProjectPath}";
            string objectCorrectAbsolutePath = objectAbsolutePath.Replace('/', Path.DirectorySeparatorChar).Replace('\\', Path.DirectorySeparatorChar);
            string folderAbsolutePath = File.Exists(objectCorrectAbsolutePath) ? Path.GetDirectoryName(objectCorrectAbsolutePath) : objectCorrectAbsolutePath;
            return Path.GetRelativePath(projectPath, folderAbsolutePath);
        }
    }

    public class PointMeshCreaterWindow : EditorWindow
    {
        private int pointCount = 10000;
        private void OnGUI()
        {
            GUILayout.Label("PointMeshCreater");
            pointCount = EditorGUILayout.IntField("Point Count", pointCount);
            if (GUILayout.Button("Create"))
            {
                Create();
            }
        }

        private void Create()
        {
            var mesh = new Mesh();
            var vertices = new Vector3[pointCount];
            var indices = new int[pointCount];
            for (int i = 0; i < pointCount; i++)
            {
                vertices[i] = Vector3.zero;
                indices[i] = i;
            }
            mesh.vertices = vertices;
            mesh.SetIndices(indices, MeshTopology.Points, 0);
            mesh.bounds = new Bounds(Vector3.zero, Vector3.one * 1000);
            string path = GetProjectWindowFolder();
            AssetDatabase.CreateAsset(mesh, $"{path}/Point_{pointCount}.asset");
            AssetDatabase.SaveAssets();
        }

        private static string GetProjectWindowFolder()
        {
            string projectPath = new DirectoryInfo(Application.dataPath).Parent.FullName;
            string objectProjectPath = AssetDatabase.GetAssetPath(Selection.activeObject);
            string objectAbsolutePath = string.IsNullOrEmpty(objectProjectPath) ? Application.dataPath : $"{projectPath}/{objectProjectPath}";
            string objectCorrectAbsolutePath = objectAbsolutePath.Replace('/', Path.DirectorySeparatorChar).Replace('\\', Path.DirectorySeparatorChar);
            string folderAbsolutePath = File.Exists(objectCorrectAbsolutePath) ? Path.GetDirectoryName(objectCorrectAbsolutePath) : objectCorrectAbsolutePath;
            return Path.GetRelativePath(projectPath, folderAbsolutePath);
        }
    }
}