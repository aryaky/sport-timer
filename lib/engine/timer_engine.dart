/// 计时器视图状态
enum TimerView {
  /// 设置阶段 - 用户可配置参数
  setup,

  /// 正在运行
  running,

  /// 已暂停
  paused,

  /// 所有轮次完成
  done,
}

/// 当前运动阶段
enum Phase {
  /// 运动阶段
  exercise,

  /// 休息阶段
  rest,
}

/// 计时器阶段变化信息
///
/// 由 [TimerEngine.tick] 返回，用于通知 UI 层发生了状态变化。
class PhaseChange {
  /// 是否所有轮次已完成
  final bool isDone;

  /// 切换后的新阶段（阶段切换时非空）
  final Phase? newPhase;

  /// 切换后的新轮次（进入新轮次时非空）
  final int? newRound;

  /// 是否发生了阶段切换
  final bool isPhaseSwitch;

  const PhaseChange({
    required this.isDone,
    this.newPhase,
    this.newRound,
    required this.isPhaseSwitch,
  });

  /// 创建一个"无变化"的 PhaseChange
  const PhaseChange.noChange()
      : isDone = false,
        newPhase = null,
        newRound = null,
        isPhaseSwitch = false;

  /// 创建一个"完成"的 PhaseChange
  factory PhaseChange.done() => const PhaseChange(
        isDone: true,
        newPhase: null,
        newRound: null,
        isPhaseSwitch: false,
      );

  /// 创建一个"阶段切换"的 PhaseChange
  factory PhaseChange.phaseSwitch({
    required Phase newPhase,
    int? newRound,
  }) =>
      PhaseChange(
        isDone: false,
        newPhase: newPhase,
        newRound: newRound,
        isPhaseSwitch: true,
      );

  @override
  String toString() =>
      'PhaseChange(isDone: $isDone, newPhase: $newPhase, newRound: $newRound, isPhaseSwitch: $isPhaseSwitch)';
}

/// 运动间歇计时器核心状态机
///
/// 纯 Dart 实现，无 Flutter UI 依赖。
/// 工作流程：
///   configure → start → tick() × N → pause ↔ resume → reset
///
/// 阶段切换逻辑：
///   exercise 结束 → 如果 currentRound >= totalRounds → done
///                → 否则 → 切换到 rest
///   rest 结束     → currentRound++ → 切换到 exercise
class TimerEngine {
  // ─── 配置参数 ───────────────────────────────────────────────

  /// 总轮次数
  int totalRounds = 1;

  /// 每轮运动时长（秒）
  int exerciseSec = 30;

  /// 每轮休息时长（秒）
  int restSec = 10;

  // ─── 运行时状态 ─────────────────────────────────────────────

  /// 当前轮次（从 1 开始）
  int currentRound = 1;

  /// 当前阶段剩余秒数
  int remaining = 0;

  /// 当前阶段总时长（秒）
  int phaseDuration = 0;

  /// 当前视图状态
  TimerView view = TimerView.setup;

  /// 当前运动阶段
  Phase phase = Phase.exercise;

  // ─── 公开方法 ───────────────────────────────────────────────

  /// 配置计时器参数
  ///
  /// [rounds] 总轮次数
  /// [exercise] 每轮运动时长（秒）
  /// [rest] 每轮休息时长（秒）
  void configure(int rounds, int exercise, int rest) {
    totalRounds = rounds;
    exerciseSec = exercise;
    restSec = rest;
    _resetToStart();
  }

  /// 开始计时
  ///
  /// 从 setup 状态进入 running 状态，初始化第一轮运动阶段。
  void start() {
    if (view != TimerView.setup) return;
    currentRound = 1;
    phase = Phase.exercise;
    phaseDuration = exerciseSec;
    remaining = exerciseSec;
    view = TimerView.running;
  }

  /// 暂停计时
  void pause() {
    if (view == TimerView.running) {
      view = TimerView.paused;
    }
  }

  /// 继续计时
  void resume() {
    if (view == TimerView.paused) {
      view = TimerView.running;
    }
  }

  /// 重置计时器
  ///
  /// 回到 setup 状态，保留配置参数不变。
  void reset() {
    _resetToStart();
  }

  /// 每秒调用一次，驱动计时器前进。
  ///
  /// 返回 [PhaseChange]：
  /// - `PhaseChange.noChange()` - 无状态变化，剩余时间正常递减
  /// - `PhaseChange.phaseSwitch(...)` - 发生了阶段切换（exercise→rest 或 rest→exercise）
  /// - `PhaseChange.done()` - 所有轮次完成
  PhaseChange tick() {
    if (view != TimerView.running) {
      return const PhaseChange.noChange();
    }

    // 递减剩余时间
    remaining--;

    // 当前阶段尚未结束
    if (remaining > 0) {
      return const PhaseChange.noChange();
    }

    // 当前阶段结束（remaining == 0）
    if (phase == Phase.exercise) {
      // 运动阶段结束
      if (currentRound >= totalRounds) {
        // 所有轮次完成
        view = TimerView.done;
        return PhaseChange.done();
      } else {
        // 切换到休息阶段
        phase = Phase.rest;
        phaseDuration = restSec;
        remaining = restSec;
        return PhaseChange.phaseSwitch(newPhase: Phase.rest);
      }
    } else {
      // 休息阶段结束 → 进入下一轮运动
      currentRound++;
      phase = Phase.exercise;
      phaseDuration = exerciseSec;
      remaining = exerciseSec;
      return PhaseChange.phaseSwitch(
        newPhase: Phase.exercise,
        newRound: currentRound,
      );
    }
  }

  /// 当前阶段的进度（0.0 ~ 1.0）
  ///
  /// 0.0 表示刚开始，1.0 表示该阶段已结束。
  double get progress {
    if (phaseDuration <= 0) return 0.0;
    return 1.0 - (remaining / phaseDuration);
  }

  /// 是否正在运行
  bool get isRunning => view == TimerView.running;

  /// 是否已暂停
  bool get isPaused => view == TimerView.paused;

  /// 是否在设置阶段
  bool get isSetup => view == TimerView.setup;

  /// 是否已完成
  bool get isDone => view == TimerView.done;

  // ─── 内部方法 ───────────────────────────────────────────────

  /// 重置到初始设置状态
  void _resetToStart() {
    currentRound = 1;
    phase = Phase.exercise;
    phaseDuration = exerciseSec;
    remaining = exerciseSec;
    view = TimerView.setup;
  }
}
