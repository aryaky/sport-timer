# 运动计时器 (Sport Timer)

基于 **Flutter** 的跨平台运动间歇计时器应用，支持 **macOS** 和 **Android** 平台。

> 原版为单文件 HTML 应用，现重构为 Flutter 原生应用，无需浏览器即可运行。

## 功能

- ⏱️ **自定义训练参数**：轮次（1-99）、运动时长（1-3600秒）、休息时长（1-3600秒）
- 🔵 **圆环进度 + 线性进度条**：双重倒计时显示，颜色随阶段动态变化
- 🔄 **自动阶段切换**：运动 ↔ 休息自动交替，带闪烁动画和音效
- 🔊 **提示音效**：最后 3 秒 beep、阶段切换双音、完成三音旋律
- ⏯️ **暂停/继续/重置**
- 📐 **最小化模式**：折叠为紧凑条状显示
- 🎨 **毛玻璃 UI**：Glassmorphism 风格，渐变色主题

## 截图

```
┌─────────────────────────────┐
│  🟠▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬   │  橙色 = 运动中
│  🏃 运动计时器    [运动中] │
│                             │
│         ◉ 00:32             │  圆环进度 + 倒计时
│                             │
│      第 2 / 5 轮            │
│  ████████████░░░░░░░░░░░░   │  线性进度条
│                             │
│   [  暂停  ]  [  重置  ]    │
└─────────────────────────────┘
```

## 技术栈

| 类别 | 选择 | 说明 |
|------|------|------|
| 框架 | Flutter 3.x | Dart 语言 |
| 音频 | flutter_soloud 4.x | 内置波形生成，无需音频文件 |
| 状态管理 | StatefulWidget + setState | 轻量，无额外依赖 |
| 平台 | macOS + Android | 单代码库双平台 |

## 项目结构

```
lib/
├── main.dart                    # 应用入口，视图切换
├── engine/
│   └── timer_engine.dart        # 计时器状态机（纯 Dart）
├── audio/
│   └── beep_player.dart         # 音频播放器封装
├── widgets/
│   ├── setup_view.dart          # 参数设置页面
│   ├── timer_view.dart          # 倒计时页面
│   ├── done_view.dart           # 完成页面
│   ├── glass_card.dart          # 毛玻璃卡片容器
│   ├── circle_progress.dart     # 圆环进度组件
│   └── stepper_input.dart       # 步进器输入组件
└── theme/
    └── app_theme.dart           # 主题常量
```

## 快速开始

### 环境要求

- Flutter SDK 3.x+
- macOS: Xcode 15+（用于 macOS 构建）
- Android: Android SDK（用于 Android 构建）

### 安装与运行

```bash
# 克隆项目
git clone https://github.com/aryaky/sport-timer.git
cd sport-timer

# 安装依赖
flutter pub get

# 运行（macOS）
flutter run -d macos

# 运行（Android）
flutter run -d android

# 构建 macOS 应用
flutter build macos --release

# 构建 Android APK
flutter build apk --release
```

### 测试

```bash
# 代码分析
flutter analyze

# 运行测试
flutter test
```

## API 文档

### TimerEngine

计时器核心状态机，纯 Dart 实现，无 Flutter UI 依赖。

```dart
final engine = TimerEngine();

// 配置参数
engine.configure(rounds: 3, exercise: 45, rest: 15);

// 状态控制
engine.start();    // 开始 → running
engine.pause();    // 暂停 → paused
engine.resume();   // 继续 → running
engine.reset();    // 重置 → setup

// 每秒驱动
final change = engine.tick();
// change.isDone          → 训练完成
// change.isPhaseSwitch   → 阶段切换
// change.newPhase        → 新阶段 (exercise/rest)
// change.newRound        → 新轮次编号

// 属性
engine.view             // TimerView: setup | running | paused | done
engine.phase            // Phase: exercise | rest
engine.totalRounds      // 总轮次数
engine.exerciseSec      // 运动时长（秒）
engine.restSec          // 休息时长（秒）
engine.currentRound     // 当前轮次
engine.remaining        // 当前阶段剩余秒数
engine.progress         // 当前进度 (0.0 ~ 1.0)
```

### BeepPlayer

音频播放器封装，使用 flutter_soloud 内置波形生成。

```dart
final player = BeepPlayer();
await player.init();

player.playCountdown();   // 倒计时 beep（方波短促音）
player.playPhaseStart();  // 阶段切换提示（双音）
player.playDone();        // 完成旋律（三音上行）

player.dispose();         // 释放资源
```

### 组件

| 组件 | 说明 | 路径 |
|------|------|------|
| `GlassCard` | 毛玻璃卡片容器 | `widgets/glass_card.dart` |
| `CircleProgress` | SVG 风格圆环进度 | `widgets/circle_progress.dart` |
| `StepperInput` | 步进器输入组件 | `widgets/stepper_input.dart` |
| `SetupView` | 参数设置页面 | `widgets/setup_view.dart` |
| `TimerView` | 倒计时页面 | `widgets/timer_view.dart` |
| `DoneView` | 完成页面 | `widgets/done_view.dart` |

## 状态机

```
setup → running → (pause ↔ running) → done → setup
         running → (exercise ↔ rest) → done
```

## 颜色主题

| 阶段 | 主题色 | 渐变 |
|------|--------|------|
| 运动中 | `#FF6B35` 橙色 | `#FF6B35 → #F7931E` |
| 休息中 | `#00B4D8` 蓝色 | `#00B4D8 → #48CAE4` |
| 已完成 | `#52C41A` 绿色 | `#7BC67E → #52C41A` |

## License

MIT
