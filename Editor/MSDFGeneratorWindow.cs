#if UNITY_EDITOR
using System.Collections;
using System.Collections.Generic;
using System.Reflection;
using UnityEngine;
using UnityEditor;
using System;
using System.Runtime.CompilerServices;
using System.IO;
using UnityEditor.VersionControl;
using UnityEngine.Experimental.Rendering;
using System.Linq;

namespace RenardShaderLibrary
{
    using static RSLUtils;
    /// <summary>
    /// msdf-bmfont-xmlをUnityで使うためのエディタ拡張
    /// </summary>
    public class MSDFGeneratorWindow : EditorWindow
    {
        private TextAsset _fontJson;
        private string _rawText;
        private string _coordText;
        private void OnGUI()
        {
            GUILayout.Label("PointMeshCreater");
            _fontJson = EditorGUILayout.ObjectField("Font Json", _fontJson, typeof(TextAsset), false) as TextAsset;
            if (GUILayout.Button("Create"))
            {
                Create();
            }
            _rawText = EditorGUILayout.TextArea(_rawText);
            EditorGUILayout.TextArea(_coordText);
            if (GUILayout.Button("get coord"))
            {
                GetCoord();
            }
        }
        private FontJson GetFontJson()
        {
            if (_fontJson == null)
            {
                Debug.LogError("Font Json Not Found");
                return null;
            }
            string text = _fontJson.text;
            text = text.Replace("\"char\"", "\"letter\"");
            FontJson fontJson = JsonUtility.FromJson<FontJson>(text);
            // sort chars by id
            fontJson.chars.Sort((a, b) => a.id - b.id);
            Debug.Log($"FontJson: {fontJson.chars.Count} chars");
            return fontJson;
        }
        private void Create()
        {
            FontJson fontJson = GetFontJson();
            Texture2D fontInfo = new Texture2D(fontJson.chars.Count, 1, TextureFormat.RGBA64, false, false);
            fontInfo.filterMode = FilterMode.Point;
            fontInfo.wrapMode = TextureWrapMode.Clamp;
            Vector2Int resolution = new Vector2Int(fontJson.common.scaleW, fontJson.common.scaleH);
            for (int i = 0; i < fontJson.chars.Count; i++)
            {
                var fontChar = fontJson.chars[i];
                fontInfo.SetPixel(i, 0, new Color(
                    (float)fontChar.x / resolution.x,
                    (float)fontChar.y / resolution.y,
                    (float)fontChar.width / resolution.x,
                    (float)fontChar.height / resolution.y
                ));
            }
            fontInfo.Apply();
            string path = GetProjectWindowFolder();
            AssetDatabase.CreateAsset(fontInfo, $"{path}/{_fontJson.name}-Info.asset");
            AssetDatabase.SaveAssets();
            AssetDatabase.Refresh();
        }

        private void GetCoord()
        {
            FontJson fontJson = GetFontJson();
            foreach (var fontChar in fontJson.chars)
            {
                if (fontChar.id != fontChar.letter[0])
                {
                    Debug.LogError($"id: {fontChar.id} letter: {fontChar.letter}");
                }
            }
            // id -> coord
            Dictionary<int, int> idToFontChar = new Dictionary<int, int>();
            for (int i = 0; i < fontJson.chars.Count; i++)
            {
                idToFontChar.Add(fontJson.chars[i].id, i);
            }
            _coordText = _rawText.Select(c => $"{(idToFontChar.ContainsKey((int)c) ? idToFontChar[(int)c] : -1)}")
                .Aggregate((a, b) => a + "," + b);
        }
    }

    [Serializable]
    public class FontJson
    {
        public List<FontChar> chars;
        public FontCommon common;
    }
    [Serializable]
    public class FontCommon
    {
        public int lineHeight;
        public int baseLine;
        public int scaleW;
        public int scaleH;
        public int pages;
        public int packed;
        public int alphaChnl;
        public int redChnl;
        public int greenChnl;
        public int blueChnl;
    }
    [Serializable]
    public class FontChar
    {
        public int id;
        public int index;
        public string letter;
        public int width;
        public int height;
        public int xoffset;
        public int yoffset;
        public int xadvance;
        public int chnl;
        public int x;
        public int y;
        public int page;
    }
}
#endif