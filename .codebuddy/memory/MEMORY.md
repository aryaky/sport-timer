# Sport Timer 项目长期记忆

## 项目架构
- Flutter macOS 应用，运动计时器
- 核心模块：`lib/engine/`（计时引擎）、`lib/widgets/`（UI 组件）
- 通用 UI 组件：`glass_card.dart`、`stepper_input.dart`、`circle_progress.dart`
- 音频依赖 `flutter_soloud` 已暂时移除（因阻塞编译），文件在 `_disabled/`

## macOS 窗口配置
- 无边框透明窗口：在 `MainFlutterWindow.swift` 中通过代码动态隐藏标题栏/按钮
- xib 保留标准 `titled="YES"` 以确保窗口正常加载，Swift 中再隐藏
- 关键设置：`titlebarAppearsTransparent`、`titleVisibility = .hidden`、`isMovableByWindowBackground`、`isOpaque = false`、`backgroundColor = .clear`
- Flutter 侧：`scaffoldBackgroundColor: Colors.transparent`

## 已知问题
- `flutter_soloud` 插件在 macOS release 模式下可能导致编译/启动问题，暂时禁用
- `BeepPlayer` 音频播放功能已注释掉，后续如需恢复需重新集成 soloud

## 构建相关
- 构建命令：`flutter build macos --release`
- 启动二进制：`build/macos/Build/Products/Release/sport_timer.app/Contents/MacOS/sport_timer`
- 包体积：约 37-40 MB（取决于依赖）

## Git 配置
- `.gitignore` 已更新，排除 `build/`、`.dart_tool/`、`.idea/`、`.flutter-plugins-dependencies`、`_disabled/`
