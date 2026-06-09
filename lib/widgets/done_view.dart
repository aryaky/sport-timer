import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'glass_card.dart';

/// 运动计时器 - 完成页面
///
/// 训练全部完成后显示，包含：
/// - 弹出动画庆祝图标
/// - 完成标题
/// - 统计信息副标题
/// - 重新设置按钮
class DoneView extends StatefulWidget {
  /// 完成的轮次数
  final int totalRounds;

  /// 大约花费的分钟数
  final int totalMinutes;

  /// 重新设置回调
  final VoidCallback onRedo;

  const DoneView({
    super.key,
    required this.totalRounds,
    required this.totalMinutes,
    required this.onRedo,
  });

  @override
  State<DoneView> createState() => _DoneViewState();
}

class _DoneViewState extends State<DoneView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _scaleController;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    // ScaleTransition 弹出动画
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _scaleAnimation = CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    );

    // 启动动画
    _scaleController.forward();
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      gradientColors: AppTheme.doneGradient,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── 庆祝图标（弹出动画） ──────────────────────────
            ScaleTransition(
              scale: _scaleAnimation,
              child: const Text(
                '🎉',
                style: TextStyle(fontSize: 56),
                textAlign: TextAlign.center,
              ),
            ),

            const SizedBox(height: 16),

            // ── 完成标题 ──────────────────────────────────────
            const Text(
              '训练完成！',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF333333),
              ),
            ),

            const SizedBox(height: 8),

            // ── 统计副标题 ────────────────────────────────────
            Text(
              '完成了 ${widget.totalRounds} 轮训练，约 ${widget.totalMinutes} 分钟，太棒了！',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: Color(0xFF999999),
              ),
            ),

            const SizedBox(height: 24),

            // ── 重新设置按钮 ──────────────────────────────────
            _buildRedoButton(),
          ],
        ),
      ),
    );
  }

  /// 绿色渐变"重新设置"按钮
  Widget _buildRedoButton() {
    return GestureDetector(
      onTap: widget.onRedo,
      child: Container(
        height: 44,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: AppTheme.doneGradient,
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(
              color: Color(0x407BC67E),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        alignment: Alignment.center,
        child: const Text(
          '重新设置',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
