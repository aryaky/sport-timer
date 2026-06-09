import 'dart:ui';

import 'package:flutter/material.dart';

/// 毛玻璃卡片容器 Widget
///
/// 使用 BackdropFilter 实现毛玻璃效果，带圆角、阴影和内阴影边框。
/// 顶部可选渐变色彩条，hover 时轻微上浮并加深阴影。
class GlassCard extends StatefulWidget {
  /// 卡片内部的子 Widget
  final Widget child;

  /// 卡片宽度，可选
  final double? width;

  /// 卡片高度，可选
  final double? height;

  /// 顶部渐变色彩条的颜色列表，传 null 则不显示
  final List<Color>? gradientColors;

  const GlassCard({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.gradientColors,
  });

  @override
  State<GlassCard> createState() => _GlassCardState();
}

class _GlassCardState extends State<GlassCard> {
  bool _isHovered = false;

  /// 默认渐变：橙色渐变
  static const List<Color> _defaultGradient = [
    Color(0xFFFF6B35),
    Color(0xFFF7931E),
  ];

  List<Color> get _effectiveGradient {
    if (widget.gradientColors != null && widget.gradientColors!.isNotEmpty) {
      return widget.gradientColors!;
    }
    return _defaultGradient;
  }

  @override
  Widget build(BuildContext context) {
    // hover 时轻微上浮
    final double offsetY = _isHovered ? -4.0 : 0.0;
    // hover 时阴影加深
    final double shadowAlpha = _isHovered ? 0.18 : 0.12;
    final double shadowBlur = _isHovered ? 40.0 : 32.0;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        transform: Matrix4.translationValues(0, offsetY, 0),
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            // 主阴影
            BoxShadow(
              color: Colors.black.withValues(alpha: shadowAlpha),
              blurRadius: shadowBlur,
              offset: const Offset(0, 8),
            ),
            // 第二层阴影（更轻更远）
            BoxShadow(
              color: Colors.black.withValues(alpha: shadowAlpha * 0.4),
              blurRadius: shadowBlur * 0.5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: DecoratedBox(
              decoration: BoxDecoration(
                // 半透明白色背景
                color: Colors.white.withValues(alpha: 0.92),
                borderRadius: BorderRadius.circular(20),
                // 内阴影效果：用浅色边框模拟
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.6),
                  width: 1.5,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 顶部渐变色彩条
                  _GradientStrip(gradientColors: _effectiveGradient),
                  // 内容区域 — Expanded 让子内容填满剩余空间
                  Expanded(child: widget.child),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// 顶部渐变色彩条
class _GradientStrip extends StatelessWidget {
  final List<Color> gradientColors;

  const _GradientStrip({required this.gradientColors});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 4,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradientColors,
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
      ),
    );
  }
}
