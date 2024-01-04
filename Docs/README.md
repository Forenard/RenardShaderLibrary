# Shader Tips

VRC特化

## 重要

VSCodeを使っている場合、[ShaderlabVSCode](https://assetstore.unity.com/packages/tools/utilities/shaderlabvscode-94653)を使用することを強く推奨します  
これを使うと
- シンタックスハイライト
- 補完
- スニペット
- ドキュメントのコメント表示
- **定義への移動**

が出来ます。定義への移動が無いとUnityのシェーダーなんて書いてられません

## 分からないときは？

1. `Unity Shader hogehoge`で検索
   - その概念を指す単語が判明したら、再度検索
2. このDocsを見る
3. Twitterで`VRC hogehoge`を検索
4. VRChat Shader DevelopmentのDiscordで検索する
5. それでも分からない場合、Twitterで叫ぶ

## Links

**知見**

- 新しめ
  - https://github.com/cnlohr/shadertrixx
  - https://github.com/pema99/shader-knowledge
  - https://tips.orels.sh/
  - https://github.com/frostbone25/Unity-Shader-Templates
  - https://github.com/netri/Neitri-Unity-Shaders/tree/master
  - https://scrapbox.io/unity-yatteiku/
  - https://rakurai5.fanbox.cc/
  - https://github.com/huwahuwa2017/huwahuwa-memo/tree/main
  - https://phi16.hatenablog.com/archive/category/%E5%88%B6%E4%BD%9C%E8%A7%A3%E8%AA%AC
- 古め
  - https://qiita.com/konchannyan
  - https://kurotorimkdocs.gitlab.io/kurotorimemo/
  - https://vrcworld.wiki.fc2.com/wiki/Shader%E9%96%A2%E9%80%A3

**ライブラリ/生産者**

- https://lox9973.com/gitlab/ (lox9973)
  - https://lox9973.booth.pm/
- https://github.com/lilxyzw/lilToon (lil)
- https://github.com/MochiesCode/Mochies-Unity-Shaders (mochie)
- https://s-ilent.booth.pm/ (silent)
- https://github.com/cnlohr (cnlohr)
- https://github.com/frostbone25 (David Matos)
- https://github.com/pema99 (pema)
- https://github.com/orels1/orels-Unity-Shaders (orels)
- https://github.com/MerlinVR (merlin)
- https://github.com/SCRN-VRC (scrn)
- https://github.com/PiMaker (pi)
- https://github.com/d4rkc0d3r (d4rkpl4y3r)
- https://lyuma.booth.pm/ (lyuma)
  - https://github.com/lyuma/LyumaShader
- https://github.com/cutesthypnotist (cutesthypnotist)
- https://github.com/phi16 (phi16)
- https://github.com/shivaduke28/kanikama (shivaduke)
  - https://shivaduke28.booth.pm/
- https://virtual-boys.booth.pm/ (momoma)
- https://suzufactory.booth.pm/ (suzuki_ith)
- https://rakuraiworks.booth.pm/ (rakurai)
- https://noriben.booth.pm/ (noriben)
- https://ayanotft.booth.pm/ (ayano)
- https://uniunishop.booth.pm/ (uniuni)
- https://reflex.booth.pm/ (reflex)

**その他知見**

- https://iquilezles.org/articles/

# Tips

## Buildin Shaderのコード

[Unity Archive](https://unity.com/releases/editor/archive)からBuild in shadersをダウンロードできる

## 警告(pragma warning)

- https://learn.microsoft.com/en-us/windows/win32/direct3dhlsl/dx-graphics-hlsl-appendix-pre-pragma-warning
- https://learn.microsoft.com/en-us/windows/win32/direct3dhlsl/hlsl-errors-and-warnings

EX)
```hlsl
#pragma warning(error : 3206) // WAR_ELT_TRUNCATION
#pragma warning(disable : 3556) // WAR_INT_DIVIDE_SLOW
```

これでコンパイラの警告を制御できる  
はずだが、なんか効果がある時とない時がある なんでだろうね

[HLSL のプラグマディレクティブ - Unity](https://docs.unity3d.com/ja/current/Manual/SL-PragmaDirectives.html)によると
> Unity は、標準的な HLSL の一部である #pragma ディレクティブが通常のインクルードファイルに含まれている限り、すべてサポートします。これらのディレクティブの詳細については、HLSL のドキュメント [#pragma ディレクティブ](https://docs.microsoft.com/ja-jp/windows/win32/direct3dhlsl/dx-graphics-hlsl-appendix-pre-pragma) を参照してください。

なのでいけるはずなんだけど

## ShaderのAttribute

- https://docs.unity3d.com/ja/2022.3/Manual/SL-Properties.html
- https://docs.unity3d.com/ja/2022.3/ScriptReference/MaterialPropertyDrawer.html

EnumはC#で定義したものを使うことが出来る
```hlsl
[Enum(UnityEngine.Rendering.BlendMode)] _SrcBlend ("Source Blend", Int) = 5
[Enum(UnityEngine.Rendering.BlendMode)] _DstBlend ("Destination Blend", Int) = 10
[Enum(UnityEngine.Rendering.BlendOp)] _BlendOp ("BlendOp", Int) = 0
[Toggle] _ZWrite ("ZWrite", Int) = 0
[Enum(UnityEngine.Rendering.CullMode)] _Cull ("CullMode", Int) = 2
~~~
Blend [_SrcBlend] [_DstBlend]
BlendOp [_BlendOp]
ZWrite [_ZWrite]
Cull [_Cull]
```

## Blend

- https://scrapbox.io/rn-works/Unity_:_ShaderLab_:_Blend%E6%A7%8B%E6%96%87
- https://docs.unity3d.com/ja/2022.3/Manual/SL-Blend.html

BlendOpはデフォルトでAdd  
Blend SrcFactor DstFactor  
**(シェーダーの出力 x SrcFactor)+(背景 x DstFactor)になる**

EX)
```hlsl
Blend SrcAlpha One // 加算
Blend SrcAlpha OneMinusSrcAlpha // アルファブレンド
```

また最終的なAlphaが書き換わる場合があるので、その場合は`ColorMask RGB`などで適宜対応するとよい  
加算してるはずなのに黒くなる場合とかね

## GPU InstancingとSPS-I(Single-pass instanced rendering)

- SPS-I
  - https://github.com/lilxyzw/Shader-MEMO/blob/main/Assets/SPSITest.shader
  - https://github.com/cnlohr/shadertrixx?tab=readme-ov-file#alert-for-early-2022
  - https://docs.unity3d.com/Manual/SinglePassInstancing.html
- GPU Instancing
  

### GPU Instancing
- https://light11.hatenadiary.com/entry/2019/09/25/220517
- https://docs.unity3d.com/ja/2019.4/Manual/GPUInstancing.html

[ドローコール](https://docs.unity3d.com/ja/2022.3/Manual/DrawCallBatching.html)を抑えて描画する仕組み  
マテリアルにEnable Instancingのチェックマークをつけると有効になる

EX) 詳しくはUnlit.shaderを参照
```hlsl
#pragma multi_compile_instancing
~~~
// struct appdataに追加
UNITY_VERTEX_INPUT_INSTANCE_ID
~~~
// struct v2fに追加
UNITY_VERTEX_INPUT_INSTANCE_ID
~~~
// インスタンシングをきかせる変数の宣言
UNITY_INSTANCING_BUFFER_START(Props)
    UNITY_DEFINE_INSTANCED_PROP(float4, hoge)
UNITY_INSTANCING_BUFFER_END(Props)
~~~
// vert(appdata IN)の先頭に追加
UNITY_SETUP_INSTANCE_ID(IN);
UNITY_TRANSFER_INSTANCE_ID(IN, OUT);
~~~
// frag(v2f IN)の先頭に追加
UNITY_SETUP_INSTANCE_ID(IN);
~~~
// インスタンシングをきかせた変数の参照
float4 hoge = UNITY_ACCESS_INSTANCED_PROP(Props, hoge);
```

Instancingが有効かどうかは`UNITY_INSTANCING_ENABLED`で確認できる