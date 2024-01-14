
# 🚧工事中🚧 RenardShaderLibrary

RenardのUnityシェーダーライブラリ

- 責任無し
- 信頼性無し
- 転載しないで

## Contents

![](https://github.com/Forenard/RenardShaderLibrary/blob/main/Docs/Cap1.png)

### [Shader Template](https://github.com/Forenard/RenardShaderLibrary/tree/main/Editor/Template)

- V2F_Img
  - Blit等に使える最小構成
- Nothing
  - 何もしないシェーダー　GrabPass起動などに使える
- Unlit
  - gpu instancing
  - SPS-I
- Unlit_Transparent
  - ↑+BlendOp
- Particle
  - gpu instancing(on/off)
  - SPS-I
  - texture sheet animation(flip-book blending)
- Particle_CVS
  - gpu instancing only
  - ↑+Custom Vertex Streams
  - ↑-texture sheet animation
- FullScreen
  - SPS-I
- CRT_Init
- CRT_Update
- Unlit_Billboard
  - gpu instancing
  - roll回転の無効化
- GPU_Particle_Billboard
  - ↑+gpu particle
- GPU_Particle_Line


### PointMesh Creater

指定した数の頂点を持つMesh(MeshTopology.Points)を作成する

### [Shader Tips](https://github.com/Forenard/RenardShaderLibrary/blob/main/Docs/README.md)

Shaderに関する知見を纏めたもの　VRC特化

## TODO

順不同

- [x] FullScreen Shader
- [x] Custom Render Texture Shader
- [x] Unlit Billboard Shader
- [x] GPU Particle Billboard Shader
- [x] GPU Particle Line Shader
- [ ] Vertex Read/Write Shader
- [ ] Raymarching Shader
- [ ] Voronoi Tracking Shader
- [ ] Super Cool Simulation Shader (Fluid, Cloth, Softbody, Collision, etc...)
- [ ] Custom TMPro Shader
- [ ] MonoSpace Font MSDF Shader
  - [ ] ASCII Only
  - [ ] 日本語も含む
- [ ] PBR Shader + Vertex Offset / Geometry / Tessellation / or something
  - [ ] ASE/Standard/Surface Shader改変等のTips纏める
- [ ] Depth/GrabPass/MotionVector等のScreenSpaceなTextureを使うShader
- [ ] 座標変換まとめ Shader
- [ ] Noiseまとめ Shader

**VRで見え確認する**