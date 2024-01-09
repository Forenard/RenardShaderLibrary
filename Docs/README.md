# Shader Tips

VRC特化

## 重要

VSCodeを使っている場合、[ShaderlabVSCode](https://assetstore.unity.com/packages/tools/utilities/shaderlabvscode-94653)を使用することを強く推奨
これを使うと
- シンタックスハイライト
- 補完
- スニペット
- ドキュメントのコメント表示
- **定義への移動**

が出来る  定義への移動が無いとUnityのシェーダーなんて書いてられない

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
Toggleでmulti_compileもできる
```hlsl
[Enum(UnityEngine.Rendering.BlendMode)] _SrcBlend ("Source Blend", Int) = 5
[Enum(UnityEngine.Rendering.BlendMode)] _DstBlend ("Destination Blend", Int) = 10
[Enum(UnityEngine.Rendering.BlendOp)] _BlendOp ("BlendOp", Int) = 0
[Toggle] _ZWrite ("ZWrite", Int) = 0
[Enum(UnityEngine.Rendering.CullMode)] _Cull ("CullMode", Int) = 2
[Toggle(_HOGEHOGE)] _Hoge ("Hoge", Int) = 0
~~~
Blend [_SrcBlend] [_DstBlend]
BlendOp [_BlendOp]
ZWrite [_ZWrite]
Cull [_Cull]
#pragma multi_compile __ _HOGEHOGE
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

### GPU Instancing
- https://light11.hatenadiary.com/entry/2019/09/25/220517
- https://docs.unity3d.com/ja/2019.4/Manual/GPUInstancing.html

[ドローコール](https://docs.unity3d.com/ja/2022.3/Manual/DrawCallBatching.html)を抑えて描画する仕組み  
マテリアルにEnable Instancingのチェックマークをつけると有効になる

EX) 具体例はUnlit.shaderを参照
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

### SPS-I(Single-pass instanced rendering)
- https://github.com/lilxyzw/Shader-MEMO/blob/main/Assets/SPSITest.shader
- https://github.com/cnlohr/shadertrixx?tab=readme-ov-file#alert-for-early-2022
- https://docs.unity3d.com/Manual/SinglePassInstancing.html

GPU Instancingをきかせながら[SinglePassStereoRendering](https://docs.unity3d.com/ja/current/Manual/SinglePassStereoRendering.html)をする仕組み

EX) 簡易的な対応として、GPU Instancingの例に加えて以下のようにする
```hlsl
// struct v2fに追加
UNITY_VERTEX_OUTPUT_STEREO
~~~
// vert(appdata IN)の先頭に追加
UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(OUT);
~~~
// frag(v2f IN)の先頭に追加
UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(IN);
```

Depth、GrabPassなどのScreenSpaceなTextureをSampleするときはTEX2DARRAYが渡ってくるかもしれないので適宜`UNITY_SAMPLE_SCREENSPACE_TEXTURE`等を用いる必要がある

`unity_StereoEyeIndex`が右目1、左目0で渡ってくるよ～

その他の対応はlilさんのコードやshadertrixxを見てね

## Particle System

- https://light11.hatenadiary.com/entry/2020/06/28/195055
  - Custom Vertex StreamsとCustom Dataの使い方
- https://light11.hatenadiary.com/entry/2020/06/27/194816
  - GPU Instancing対応
- https://docs.unity3d.com/Manual/PartSysInstancing.html
  - Particle System GPU Instancing
- https://booth.pm/ja/items/2737413
  - Unity Particle SystemのCustom Vertex Streams入門 bt noriben
- https://light11.hatenadiary.com/entry/2021/11/09/195049
  - Flip-Book Blendingを使う

Flip-Book Blending(Texture Sheet Animation)を使う場合も注意  
対応するにはUnityの記事を見ればいいが、`_TSANIM_BLENDING`は多分`_FLIPBOOK_BLENDING`の間違い  
あとGPU Instancing Offの場合はblend用のuv2とAnimBlendがデフォで渡ってこないので、自分でCustom Vertex Streamsを設定する必要あり  
"StandardParticlesShaderGUI"使ってるとこんな感じで直すボタンがある

![](https://github.com/Forenard/RenardShaderLibrary/blob/main/Docs/Flip-Book-Particle1.png)

GPU InstancingのOnOff対応に気を付ける  
デフォではCustom Vertex Streams+GPU Instancing対応シェーダーはInstancing offにするとおかしくなるので注意  
対応するにはlight11さんの記事とParticle_CVS.shaderを見ればいい

具体例はParticle.shader/Particle_CVS.shaderを参照

## FullScreen Shader

### 座標系などについて

コマンドはこんな感じになる
```
Cull Off
ZWrite Off
ZTest Always
```

モデルをquadにして、uvが0~1なのを利用してクリップ座標を無理やり作るやり方をよく見る

- https://github.com/cnlohr/shadertrixx?tab=readme-ov-file#fullscreening-a-quad-from-its-uvs

```hlsl
float4 GetFullScreenCPos(float2 uv)
{
  retrun float4(float2(1, -1) * (v.uv * 2 - 1), 0, 1);
}
```

からの`ComputeGrabScreenPos(cPos)`からのw除算コンボでScreenSpaceのuv作る

MochieさんはSPS-Iも考慮したやり方をしている(多分)  
デカいCubeをモデルに使って、`Cull Front`にする

- https://github.com/MochiesCode/Mochies-Unity-Shaders/blob/5349d84458c62b93f5ce26f76d33171719fb623e/Mochie/Common/Utilities.cginc#L309

```hlsl
float4 GetFullScreenCPos(float4 oPos)
{
    oPos.x *= 1.4;
    #if UNITY_SINGLE_PASS_STEREO || defined(UNITY_STEREO_INSTANCING_ENABLED) || defined(UNITY_STEREO_MULTIVIEW_ENABLED)
        float ipd = length(mul(unity_WorldToObject,
        float4(unity_StereoWorldSpaceCameraPos[0].xyz - unity_StereoWorldSpaceCameraPos[1].xyz, 0)));
        float4 absPos = oPos + float4(ipd * (0.5 - unity_StereoEyeIndex), 0, 0, 0);
    #else
        float ipd = 0.0;
        float4 absPos = oPos;
    #endif
    float4 wPos = mul(unity_CameraToWorld, absPos);
    oPos = mul(unity_WorldToObject, wPos);
    return UnityObjectToClipPos(oPos);
}
```

### ScreenSpaceのTextureを使う

[SPS-Iの章](https://github.com/Forenard/RenardShaderLibrary/blob/main/Docs/README.md#gpu-instancing%E3%81%A8sps-isingle-pass-instanced-rendering)でもちょっと触れたが、Depth、GrabPass、ShadowなどのScreenSpaceなTextureはSPS-Iの影響を受けるので、やる

Texture2DArrayとTexture2Dの差異は吸収されてるので分岐は不要
```hlsl
#define RENARD_DECLARE_TEX2D(tex)   Texture2D tex; SamplerState sampler##tex
#define RENARD_DECLARE_TEX2DARRAY(tex)  Texture2DArray tex; SamplerState sampler##tex

#if defined(UNITY_STEREO_INSTANCING_ENABLED) || defined(UNITY_STEREO_MULTIVIEW_ENABLED)
    #define RENARD_DECLARE_TEX2D_SCREENSPACE(tex)   RENARD_DECLARE_TEX2DARRAY(tex)
#else
    #define RENARD_DECLARE_TEX2D_SCREENSPACE(tex)   RENARD_DECLARE_TEX2D(tex)
#endif

#define RENARD_SAMPLE_TEX2D_SCREENSPACE(tex, coord) tex.SampleLevel(sampler##tex, coord, 0)
```

## GrabPass

- https://docs.unity3d.com/ja/2022.3/Manual/SL-GrabPass.html

おなじみフレームバッファを取得できる　ポスプロに必須  

書き方でちょっとした違いがあり、多分

- `GrabPass{}` : このコマンドを含むバッチをレンダリングするたび毎回フレームバッファをGrabする
- `GrabPass{"TextureName"}` : このコマンドを含むバッチの最初だけフレームバッファをGrabする

なのでGrab後にGrabする場合はそれぞれに違う名前をつける必要がある

GrabしたTextureは別のシェーダーからでも取得できたり、次フレームでも保持されたりするので色々使える

FP16のTextureとして情報をpack/unpackしたりもできる(使えるbitは14か15説あり 以下リンク参照)  
これはAvaterに変なシェーダー仕込むとき、Cameraを使わずにCustomRenderTexture等に情報を送りたくなるので使える

- https://github.com/pema99/shader-knowledge/blob/main/tips-and-tricks.md#encoding-and-decoding-data-in-a-grabpass
- https://github.com/huwahuwa2017/huwahuwa-memo/blob/main/TexelReadWrite/GrabPassReadWrite15bit.shader

## CustomRenderTexture

- https://docs.unity3d.com/ja/2022.3/Manual/class-CustomRenderTexture.html
- https://light11.hatenadiary.com/entry/2018/06/12/004133

RenderTextureとMaterial(Shader)が一体化したみたいなやつ  
VRCWorldではBlitが使えるのであまり使わないが、普通に便利　逆にAvaterのShader芸では必須

CRT同士の依存関係も勝手に解決してパスの実行順序を決めてくれるのが神機能だと思う  
ループ検出もしてエラーを出してくれる

中身は普通にシェーダーなので、Geometry Shaderを強引に挟んでRandom Accessを実現してComputeShaderみたいに使うこともできる
- https://github.com/cnlohr/flexcrt

3DのCRTを使うとinterpolationが効いたりして楽だが、使うのは以下の理由からおすすめしない
- スライス(z)分DrawCallが走る
  - これは内部的にTexture2DArrayを使ってるからだと思われる
- 送られてくるz座標がちょっとずれてる(????)
  - https://x.com/suzuki_ith/status/1570369522523340802?s=20
  - `tex3Dfetch`とかで確実にやったりしないとだめそう
  - 私にもこれが発生したが、Unity2022.3.6f1で直ってるか不明