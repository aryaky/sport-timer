import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'glass_card.dart';
import 'stepper_input.dart';

/// 运动计时器 - 设置页面
///
/// 用户可以在这里配置训练参数：
/// - 总轮次
/// - 每轮运动时长
/// - 每轮休息时长
/// 配置完成后点击"开始训练"按钮进入计时。
class SetupView extends StatelessWidget {
  /// 用户点击开始训练时的回调
  final void Function(int rounds, int exercise, int rest) onStart;

  /// 最小化按钮回调
  final VoidCallback onMinimize;

  const SetupView({
    super.key,
    required this.onStart,
    required this.onMinimize,
  });

  @override
  Widget build(BuildContext context) {
    return _SetupContent(
      onStart: onStart,
      onMinimize: onMinimize,
    );
  }
}

class _SetupContent extends StatefulWidget {
  final void Function(int rounds, int exercise, int rest) onStart;
  final VoidCallback onMinimize;

  const _SetupContent({
    required this.onStart,
    required this.onMinimize,
  });

  @override
  State<_SetupContent> createState() => _SetupContentState();
}

class _SetupContentState extends State<_SetupContent> {
  int _rounds = 3;
  int _exercise = 45;
  int _rest = 15;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      gradientColors: AppTheme.exerciseGradient,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── 标题栏 ────────────────────────────────────────
            _buildHeader(),

            const SizedBox(height: 24),

            // ── 阶段标签占位 ──────────────────────────────────
            const SizedBox(height: 28),

            const SizedBox(height: 16),

            // ── 参数输入区域 ──────────────────────────────────
            StepperInput(
              label: '总轮次',
              value: _rounds,
              min: 1,
              max: 99,
              step: 1,
              suffix: '轮',
              onChanged: (v) => setState(() => _rounds = v),
            ),

            const SizedBox(height: 14),

            StepperInput(
              label: '运动时长',
              value: _exercise,
              min: 1,
              max: 3600,
              step: 5,
              suffix: '秒',
              onChanged: (v) => setState(() => _exercise = v),
            ),

            const SizedBox(height: 14),

            StepperInput(
              label: '休息时长',
              value: _rest,
              min: 1,
              max: 3600,
              step: 5,
              suffix: '秒',
              onChanged: (v) => setState(() => _rest = v),
            ),

            const SizedBox(height: 24),

            // ── 开始训练按钮 ──────────────────────────────────
            _buildStartButton(),
          ],
        ),
      ),
    );
  }

  /// 标题栏：左侧标题 + 右侧最小化按钮
  Widget _buildHeader() {
    return Row(
      children: [
        // 标题文字
        const Text(
          '🏃 运动计时器',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF333333),
          ),
        ),
        const Spacer(),
        // 最小化按钮
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

  /// 底部全宽渐变橙色"开始训练"按钮
  Widget _buildStartButton() {
    return GestureDetector(
      onTap: () => widget.onStart(_rounds, _exercise, _rest),
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: AppTheme.exerciseGradient,
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(
              color: Color(0x40FF6B35),
              blurRadius: 12,
              offset: Offset(0, 4),
            ),
          ],
        ),
        alignment: Alignment.center,
        child: const Text(
          '开始训练',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
