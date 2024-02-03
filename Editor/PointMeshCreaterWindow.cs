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
    /// ポイントメッシュを作成するエディタ拡張
    /// </summary>
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

    }
}
#endif