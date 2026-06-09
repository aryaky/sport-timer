import 'dart:math' as math;

import 'package:flutter/material.dart';

/// SVG 风格圆环进度组件
///
/// 使用 CustomPainter 绘制带圆角端点的圆环进度条。
/// 从顶部开始（-90 度），顺时针减少。
/// 圆环内可通过 Stack 叠加子 Widget（如倒计时数字）。
class CircleProgress extends StatelessWidget {
  /// 进度值，范围 0.0 ~ 1.0
  final double progress;

  /// 进度圆环颜色
  final Color color;

  /// 组件尺寸（宽高），默认 120
  final double size;

  /// 圆环内显示的子 Widget（如倒计时数字），可选
  final Widget? child;

  const CircleProgress({
    super.key,
    required this.progress,
    required this.color,
    this.size = 120,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 旋转 -π/2，使进度从顶部（12 点方向）开始
          Transform.rotate(
            angle: -math.pi / 2,
            child: CustomPaint(
              size: Size(size, size),
              painter: _CircleProgressPainter(
                progress: progress.clamp(0.0, 1.0),
                color: color,
              ),
            ),
          ),
          // 中心子 Widget
          if (child != null) ?child,
        ],
      ),
    );
  }
}

/// 圆环进度绘制器
class _CircleProgressPainter extends CustomPainter {
  final double progress;
  final Color color;

  static const double _strokeWidth = 6.0;
  static const Color _backgroundColor = Color(0xFFF0F0F0);

  _CircleProgressPainter({
    required this.progress,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - _strokeWidth) / 2;

    // 背景圆环画笔
    final bgPaint = Paint()
      ..color = _backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = _strokeWidth
      ..strokeCap = StrokeCap.round;

    // 进度圆环画笔
    final progressPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = _strokeWidth
      ..strokeCap = StrokeCap.round;

    // 绘制完整背景圆环
    canvas.drawCircle(center, radius, bgPaint);

    // 绘制进度圆弧（从 0 到 progress * 2π，顺时针）
    final sweepAngle = 2 * math.pi * progress;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      0, // 起始角度：旋转后 0 即顶部
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _CircleProgressPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.color != color;
  }
}
