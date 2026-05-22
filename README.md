# 熹微之萍 · Flutter App

ESP32-S3 多功能屏控制 App。

## 项目初始化

这个仓库只包含 `lib/` 业务代码和 `pubspec.yaml`，**没有** `android/` `ios/` 等平台目录。
拷贝到 Android Studio 后第一步：

```bash
flutter create .
flutter pub get
flutter run
```

`flutter create .` 会在当前目录生成 `android/` `ios/` `linux/` 等平台脚手架，不会覆盖已有的 `lib/` 和 `pubspec.yaml`。

## 项目结构

```
lib/
├── main.dart                    # 入口
├── app.dart                     # MaterialApp + 顶层 Scaffold
├── theme.dart                   # iOS 风配色、字体
│
├── core/
│   ├── connection/
│   │   ├── connection_manager.dart   # 自动选 WS / MQTT
│   │   ├── ws_channel.dart           # WebSocket port 81
│   │   ├── mqtt_channel.dart         # ThingsCloud
│   │   └── channel.dart              # 通道抽象接口
│   ├── models/
│   │   ├── device_state.dart
│   │   ├── effect_modes.dart         # effect/dyn_effect/amb_effect 枚举
│   │   └── scene.dart
│   └── providers/
│       ├── device_provider.dart
│       └── settings_provider.dart
│
├── features/
│   ├── home/
│   │   └── home_screen.dart
│   ├── light/
│   │   └── light_screen.dart
│   ├── color/
│   │   └── color_screen.dart
│   ├── scenes/
│   │   ├── scenes_screen.dart
│   │   └── scene_editor_screen.dart
│   ├── games/
│   │   ├── games_lobby_screen.dart
│   │   ├── snake_screen.dart
│   │   └── tetris_screen.dart
│   └── device/
│       ├── device_screen.dart
│       ├── ws_config_card.dart
│       ├── appearance_card.dart
│       └── protocol_log_card.dart
│
└── shared/
    └── widgets/
        ├── lrp_card.dart
        ├── lrp_switch_tile.dart
        ├── lrp_slider.dart
        ├── channel_badge.dart
        └── tab_scaffold.dart
```

## 协议

WebSocket: `ws://<设备IP>:81/ws`
连接后立即发 `{"t":"get_state"}` 拉取初始状态。

App → 设备：
- `{"t":"get_state"}` 拉状态
- `{"t":"set","key":"vol","val":80}` 调参数
- `{"t":"game","action":"start","game":"snake"}` 启动游戏
- `{"t":"game","action":"input","dir":0..3}` 游戏输入
- `{"t":"game","action":"quit"}` 退出游戏

设备 → App：
- `{"t":"state",...}` 完整状态
- `{"t":"spec","b":[16个频段],"v":总音量}` 20Hz 频谱
- `{"t":"game_evt","evt":"score|game_over","val":...}` 游戏事件

详见 `core/models/device_state.dart` 和 `core/connection/ws_channel.dart` 的字段映射。

## 打包

```bash
flutter build apk --release
# 产物：build/app/outputs/flutter-apk/app-release.apk
```

## 设计原型

UI 设计参考 `Ping App.html`（HTML/React 原型），双端逻辑跟随该原型。
