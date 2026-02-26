![Logo](documents/banner.jpg)

![Build Status](https://img.shields.io/badge/build-%20passing%20-brightgreen) ![License](https://img.shields.io/badge/license-MIT-red) ![Platform](https://img.shields.io/badge/Platform-%20iOS%20macOS%20tvOS%20-blue)

# HHPlayer

HHPlayer is a media playback framework for iOS, macOS, and tvOS, based on FFmpeg + Metal + AudioToolbox.

HHPlayer is forked from [SGPlayer](https://github.com/libobjc/SGPlayer) and continues to evolve on top of it.

## 特性

- iOS / tvOS / macOS
- 360° 全景视频
- 复杂资源拼接（多段、多轨、混合资源）
- 后台播放
- RTMP / RTSP 流媒体
- 倍速播放
- 多音轨/多视频轨
- H.264 / H.265 硬件解码
- 精确状态通知
- 线程安全

## 技术原理

### 1) 分层架构

- `HHPlayer`：对外统一控制层（代码实现当前对应 `SGPlayer` 类，提供 play/pause/seek/rate/状态通知）。
- `SGPlayerItem`：单播放项上下文，维护音视频队列、Processor、FrameOutput。
- `SGFrameOutput`：聚合 `PacketOutput + DecodeLoop`，完成 packet->frame 的分发与解码调度。
- `SGAudioRenderer / SGVideoRenderer`：渲染层，分别驱动音频输出与 Metal 视频绘制。
- `SGClock`：统一时钟基准（`CMTimebase`），控制音视频同步。

### 2) 数据主链路

```text
SGAsset
  -> SGPacketOutput (Demux)
  -> SGDecodeLoop (Audio/Video Decode)
  -> SGFrameOutput
  -> SGPlayerItem (AudioQueue/VideoQueue + Processor)
  -> SGAudioRenderer / SGVideoRenderer
```

### 3) 资源与轨道模型

- 资源抽象：`SGAsset` / `SGURLAsset` / `SGMutableAsset`
- 轨道与片段：`SGTrack` / `SGMutableTrack` / `SGSegment`
- 复杂编排：通过 `SGExtractingDemuxer`、`SGMutilDemuxer`、`SGPaddingDemuxer` 支持裁剪、拼接、补齐等场景
- 轨道选择：`SGTrackSelection` 支持播放中切换音轨/视频轨

### 4) 缓冲与背压控制

- `SGCapacity` 用于统一描述缓存量（数量、字节、时长）。
- `SGDecodeLoop` 实时上报容量，`SGFrameOutput` 根据容量调节 `SGPacketOutput` pause/resume。
- 当音视频缓存均满足阈值或总缓存过大时暂停 demux，缓存下降后恢复，避免无界增长。

### 5) 音视频同步与渲染

- `SGClock` 维护 audio/video/playback 三套 timebase。
- 音频侧通过回调驱动（AudioToolbox）更新播放时间；视频侧按时钟抓帧并渲染。
- 视频渲染基于 Metal，支持 `BGRA / NV12 / YUV420P`，并支持平面与球面（VR）显示。

### 6) 并发模型

- Demux：`SGPacketOutput` 独立循环线程。
- 解码：音频/视频各自 `SGDecodeLoop` 独立循环。
- 渲染：音频回调线程 + 视频绘制/取帧定时循环。
- 线程安全：核心状态通过 `NSLock` + `SGLock` 宏做原子保护。

## 文件目录结构

说明：当前仓库的历史目录与类名仍保留 `SG` 前缀，这是 fork 后的延续实现；对外项目名称统一为 `HHPlayer`。

```text
.
|-- README.md
|-- build.sh
|-- scripts/                        # FFmpeg/OpenSSL 初始化与编译脚本
|-- documents/                      # 文档图片（banner、流程图）
|-- demo/                           # iOS/macOS/tvOS 示例工程与 workspace
|-- SGPlayer.xcodeproj
`-- SGPlayer/
    |-- Classes/
    |   |-- SGPlayer.h/.m           # 对外 API 入口
    |   `-- Core/
    |       |-- SGAsset/            # 资源、轨道、片段抽象
    |       |-- SGSession/          # PlayerItem、PacketOutput、FrameOutput、FrameReader
    |       |-- SGDemuxer/          # URL/拼接/裁剪/补齐 demux 适配
    |       |-- SGDecoder/          # 解码循环、上下文、音视频解码器
    |       |-- SGProcessor/        # 重采样、变速、混音、像素转换
    |       |-- SGRenderer/         # 时钟、音频渲染、视频渲染
    |       |-- SGMetal/            # Metal 渲染管线与 shader
    |       |-- SGAudio/            # AudioToolbox 播放器封装
    |       |-- SGFFmpeg/           # FFmpeg 初始化与桥接
    |       |-- SGData/             # Packet/Frame/Capacity 数据结构
    |       |-- SGVR/               # 全景投影与传感器
    |       |-- SGOption/           # Demux/Decode/Processor 配置
    |       |-- SGContainer/        # 对象队列/池
    |       |-- SGCommon/           # 错误、时间、锁等基础设施
    |       |-- SGPlatform/         # iOS/macOS/tvOS 平台兼容层
    |       |-- SGDescription/      # 音视频描述信息模型
    |       |-- SGDefine/           # 宏定义与映射
    |       `-- Vendor/sonic/       # 变速/变调第三方实现
    |-- module.modulemap
    `-- Info.plist
```

## 依赖

- HHPlayer.framework
- AVFoundation.framework
- AudioToolBox.framework
- VideoToolBox.framework
- libiconv.tbd
- libbz2.tbd
- libz.tbd

## 环境要求

- iOS 13.0+
- tvOS 13.0+
- macOS 10.15+

## 快速开始

### 1) 构建 FFmpeg 和 OpenSSL

默认脚本版本：
- FFmpeg n8.0.1
- OpenSSL 1.1.1w

```bash
git clone https://github.com/jerboy/HHPlayer.git
cd HHPlayer

# iOS
./build.sh iOS build

# tvOS
./build.sh tvOS build

# macOS
./build.sh macOS build
```

### 2) 打开 Demo

使用 Xcode 打开 `demo/demo.xcworkspace`，可直接运行 iOS/macOS/tvOS 示例。

## SPM

本仓库使用二进制 SPM 形式（`Package.swift` 指向 GitHub Release 的 `HHPlayer.xcframework.zip`）。

### 外部项目直接引用

```swift
dependencies: [
    .package(url: "https://github.com/jerboy/HHPlayer.git", branch: "master")
]
```

然后在 target 中添加：

```swift
.product(name: "HHPlayer", package: "HHPlayer")
```

### 本地生成 SPM 产物

```bash
./scripts/build_spm_artifact.sh
```

生成结果：
- `Artifacts/HHPlayer.xcframework`
- `Artifacts/HHPlayer.xcframework.zip`
- `Artifacts/HHPlayer.xcframework.checksum.txt`

默认会包含：
- iOS device
- iOS Simulator
- tvOS device
- tvOS Simulator
- macOS (arm64 + x86_64)

常用参数：

```bash
# 仅打 device + macOS（不包含 simulator）
INCLUDE_SIMULATOR=0 ./scripts/build_spm_artifact.sh

# 跳过依赖编译（要求本地已有对应平台/架构的 FFmpeg/OpenSSL 产物）
SKIP_DEPS_BUILD=1 INCLUDE_SIMULATOR=0 ./scripts/build_spm_artifact.sh
```

架构覆盖参数（按需）：
- `IOS_DEVICE_ARCHS`（默认 `arm64`）
- `IOS_SIMULATOR_ARCHS`（默认 `arm64-simulator`）
- `TVOS_DEVICE_ARCHS`（默认 `arm64`）
- `TVOS_SIMULATOR_ARCHS`（默认 `arm64-simulator`）
- `MACOS_ARCHS`（默认 `arm64 x86_64`）

### GitHub Actions 自动打包

- 工作流：`.github/workflows/build-spm-artifact.yml`
- 触发方式：
  - push 到 `master` 自动触发（产出 master 快照）
  - 手动触发（`workflow_dispatch`）
  - 推送 `v*` tag 自动触发
- 产出：
  - workflow artifact：`HHPlayer.xcframework.zip` + checksum
  - `master` 分支：自动更新 `spm-master` Release，并回写 `Package.swift` checksum
  - tag 构建时自动上传到 GitHub Release

## Flow Chart

![Flow Chart](documents/flow-chart.jpg)

## Author

- GitHub: [Single](https://github.com/libobjc)
- Email: libobjc@gmail.com

## Developed by Author

- [KTVHTTPCache](https://github.com/ChangbaDevs/KTVHTTPCache) - A smart media cache framework.
- [KTVVideoProcess](https://github.com/ChangbaDevs/KTVVideoProcess) - A high-performance video effects processing framework.
