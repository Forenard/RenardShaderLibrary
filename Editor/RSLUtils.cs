#if UNITY_EDITOR
using System.Collections;
using System.Collections.Generic;
using System.Reflection;
using UnityEngine;
using UnityEditor;
using System;
using System.Runtime.CompilerServices;
using System.IO;
using System.Text;

namespace RenardShaderLibrary
{
    /// <summary>
    /// ユーティリティ
    /// </summary>
    public class RSLUtils
    {
        // https://stackoverflow.com/questions/51179331/is-it-possible-to-use-path-getrelativepath-net-core2-in-winforms-proj-targeti
        // public static string GetRelativePath(string relativeTo, string path)
        // {
        //     var uri = new Uri(relativeTo);
        //     var rel = Uri.UnescapeDataString(uri.MakeRelativeUri(new Uri(path)).ToString()).Replace(Path.AltDirectorySeparatorChar, Path.DirectorySeparatorChar);
        //     if (rel.Contains(Path.DirectorySeparatorChar.ToString()) == false)
        //     {
        //         rel = $".{Path.DirectorySeparatorChar}{rel}";
        //     }
        //     return rel;
        // }

        public static string ReadFile(string path)
        {
            var fs = new FileStream(path, FileMode.Open, FileAccess.Read, FileShare.ReadWrite);
            var sr = new StreamReader(fs, Encoding.UTF8);
            string file = sr.ReadToEnd();
            sr.Close();
            fs.Close();
            return file;
        }
        public static void WriteFile(string path, string file)
        {
            var fs = new FileStream(path, FileMode.CreateNew, FileAccess.Write, FileShare.ReadWrite);
            var sw = new StreamWriter(fs, Encoding.UTF8);
            sw.Write(file);
            sw.Close();
            fs.Close();
        }
        // https://gist.github.com/allanolivei/9260107?permalink_comment_id=4232189#gistcomment-4232189
        public static string GetProjectWindowFolder()
        {
            string projectPath = new DirectoryInfo(Application.dataPath).Parent.FullName;
            string objectProjectPath = AssetDatabase.GetAssetPath(Selection.activeObject);
            string objectAbsolutePath = string.IsNullOrEmpty(objectProjectPath) ? Application.dataPath : $"{projectPath}/{objectProjectPath}";
            string objectCorrectAbsolutePath = objectAbsolutePath.Replace('/', Path.DirectorySeparatorChar).Replace('\\', Path.DirectorySeparatorChar);
            string folderAbsolutePath = File.Exists(objectCorrectAbsolutePath) ? Path.GetDirectoryName(objectCorrectAbsolutePath) : objectCorrectAbsolutePath;
            // string folderPath = GetRelativePath(projectPath, folderAbsolutePath);
            string folderPath = folderAbsolutePath.Replace($"{projectPath}\\", "");
            return folderPath;
        }
    }
}
#endif