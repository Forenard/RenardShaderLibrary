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
        private const string MENU_PREFIX = "Assets/Create/Shader/ShaderTemplate/";
        [MenuItem(MENU_PREFIX + "V2F_Img")]
        private static void V2F_Img() => CreateShader();


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
}