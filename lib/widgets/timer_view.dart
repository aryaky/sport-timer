import 'dart:async';

import 'package:flutter/material.dart';

import '../engine/timer_engine.dart';
import '../theme/app_theme.dart';
import 'circle_progress.dart';
import 'glass_card.dart';

/// 运动计时器 - 计时页面
///
/// 显示当前训练进度，包含：
/// - 阶段标签（运动中 / 休息中）
/// - 圆环进度 + 倒计时数字
/// - 轮次信息
/// - 线性进度条
/// - 暂停/继续 + 重置按钮
///
/// 支持最小化模式，只显示一行紧凑文字。
class TimerView extends StatefulWidget {
  /// 计时引擎实例
  final TimerEngine engine;

  /// 是否处于最小化模式
  final bool isMinimized;

  /// 暂停回调
  final VoidCallback onPause;

  /// 继续回调
  final VoidCallback onResume;

  /// 重置回调
  final VoidCallback onReset;

  /// 最小化回调
  final VoidCallback onMinimize;

  const TimerView({
    super.key,
    required this.engine,
    this.isMinimized = false,
    required this.onPause,
    required this.onResume,
    required this.onReset,
    required this.onMinimize,
  });

  @override
  State<TimerView> createState() => _TimerViewState();
}

class _TimerViewState extends State<TimerView>
    with SingleTickerProviderStateMixin {
  /// 闪烁动画控制器（最后 3 秒使用）
  AnimationController? _blinkController;
  bool _blinkVisible = true;
  Timer? _blinkTimer;

  TimerEngine get engine => widget.engine;

  @override
  void initState() {
    super.initState();
    _setupBlink();
  }

  void _setupBlink() {
    _blinkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
  }

  @override
  void dispose() {
    _blinkController?.dispose();
    _blinkTimer?.cancel();
    super.dispose();
  }

  /// 判断当前是否应该闪烁（剩余时间 <= 3 秒 且 正在运行）
  bool get _shouldBlink =>
      engine.isRunning && engine.remaining <= 3 && engine.remaining > 0;

  @override
  Widget build(BuildContext context) {
    // 管理闪烁定时器
    if (_shouldBlink) {
      _startBlink();
    } else {
      _stopBlink();
    }

    // 最小化模式：只显示一行紧凑文字
    if (widget.isMinimized) {
      return _buildMinimized();
    }

    return _buildFull();
  }

  /// 最小化模式 UI
  Widget _buildMinimized() {
    final phaseText = engine.phase == Phase.exercise ? '运动' : '休息';
    final minutes = engine.remaining ~/ 60;
    final seconds = engine.remaining % 60;
    final timeStr =
        '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';

    return GestureDetector(
      onTap: widget.onMinimize,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.92),
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(
              color: Color(0x1A000000),
              blurRadius: 12,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Text(
          '$phaseText $timeStr · 第${engine.currentRound}/${engine.totalRounds}轮',
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF333333),
          ),
        ),
      ),
    );
  }

  /// 完整模式 UI
  Widget _buildFull() {
    final phaseGradient = engine.phase == Phase.exercise
        ? AppTheme.exerciseGradient
        : AppTheme.restGradient;

    final phaseColor = engine.phase == Phase.exercise
        ? AppTheme.exerciseOrange
        : AppTheme.restBlue;

    return GlassCard(
      gradientColors: phaseGradient,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── 标题栏 ──────────────────────────────────────
            _buildHeader(phaseColor),

            const SizedBox(height: 16),

            // ── 阶段标签 ────────────────────────────────────
            _buildPhaseLabel(phaseColor),

            const SizedBox(height: 20),

            // ── 圆环进度 + 倒计时数字 ───────────────────────
            _buildCircleProgress(phaseColor),

            const SizedBox(height: 16),

            // ── 轮次信息 ────────────────────────────────────
            _buildRoundInfo(),

            const SizedBox(height: 12),

            // ── 线性进度条 ──────────────────────────────────
            _buildLinearProgress(phaseColor),

            const SizedBox(height: 20),

            // ── 按钮组 ──────────────────────────────────────
            _buildButtonRow(phaseGradient),
          ],
        ),
      ),
    );
  }

  /// 标题栏
  Widget _buildHeader(Color phaseColor) {
    return Row(
      children: [
        Text(
          '🏃 运动计时器',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: phaseColor,
          ),
        ),
        const Spacer(),
        GestureDetector(
          onTap: widget.onMinimize,
          child: Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(8),
            ),
            alignment: Alignment.center,
            child: const Text(
              '—',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF999999),
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// 阶段标签胶囊
  Widget _buildPhaseLabel(Color phaseColor) {
    final label = engine.phase == Phase.exercise ? '运动中' : '休息中';

    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: phaseColor.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: phaseColor,
          ),
        ),
      ),
    );
  }

  /// 圆环进度 + 倒计时数字
  Widget _buildCircleProgress(Color phaseColor) {
    final minutes = engine.remaining ~/ 60;
    final seconds = engine.remaining % 60;
    final timeStr =
        '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';

    // 闪烁效果：最后 3 秒时数字闪烁
    final bool showNumber = !_shouldBlink || _blinkVisible;

    return Center(
      child: CircleProgress(
        progress: engine.progress,
        color: phaseColor,
        size: 160,
        child: showNumber
            ? Text(
                timeStr,
                style: const TextStyle(
                  fontSize: 42,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF333333),
                ),
              )
            : const SizedBox.shrink(),
      ),
    );
  }

  /// 轮次信息
  Widget _buildRoundInfo() {
    return Center(
      child: Text(
        '第 ${engine.currentRound} / ${engine.totalRounds} 轮',
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: Color(0xFF666666),
        ),
      ),
    );
  }

  /// 线性进度条
  Widget _buildLinearProgress(Color phaseColor) {
    return Container(
      height: 5,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(2.5),
        color: const Color(0xFFE8E8E8),
      ),
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: engine.progress.clamp(0.0, 1.0),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(2.5),
            color: phaseColor,
          ),
        ),
      ),
    );
  }

  /// 按钮组：暂停/继续 + 重置
  Widget _buildButtonRow(List<Color> gradient) {
    final bool isRunning = engine.isRunning;

    return Row(
      children: [
        // 暂停 / 继续按钮
        Expanded(
          child: GestureDetector(
            onTap: isRunning ? widget.onPause : widget.onResume,
            child: Container(
              height: 44,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: gradient,
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: gradient.first.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              alignment: Alignment.center,
              child: Text(
                isRunning ? '暂停' : '继续',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),

        const SizedBox(width: 12),

        // 重置按钮
        Expanded(
          child: GestureDetector(
            onTap: widget.onReset,
            child: Container(
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFFE8E8E8),
                borderRadius: BorderRadius.circular(12),
              ),
              alignment: Alignment.center,
              child: const Text(
                '重置',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF666666),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ─── 闪烁动画控制 ───────────────────────────────────────

  void _startBlink() {
    if (_blinkTimer != null && _blinkTimer!.isActive) return;
    _blinkVisible = true;
    _blinkTimer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        _blinkVisible = !_blinkVisible;
      });
      // 如果不再需要闪烁则停止
      if (!_shouldBlink) {
        timer.cancel();
        _blinkVisible = true;
        setState(() {});
      }
    });
  }

  void _stopBlink() {
    _blinkTimer?.cancel();
    _blinkTimer = null;
    _blinkVisible = true;
  }
}
