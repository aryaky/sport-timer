import 'package:flutter/material.dart';

/// 运动间歇计时器 - 主题常量
class AppTheme {
  AppTheme._();

  // ─── 颜色常量 ───────────────────────────────────────────────

  /// 运动阶段 - 橙色
  static const Color exerciseOrange = Color(0xFFFF6B35);

  /// 运动阶段渐变
  static const List<Color> exerciseGradient = [
    Color(0xFFFF6B35),
    Color(0xFFF7931E),
  ];

  /// 休息阶段 - 蓝色
  static const Color restBlue = Color(0xFF00B4D8);

  /// 休息阶段渐变
  static const List<Color> restGradient = [
    Color(0xFF00B4D8),
    Color(0xFF48CAE4),
  ];

  /// 完成阶段 - 绿色渐变
  static const List<Color> doneGradient = [
    Color(0xFF7BC67E),
    Color(0xFF52C41A),
  ];

  // ─── 圆角半径 ───────────────────────────────────────────────

  /// 卡片圆角
  static const double cardRadius = 20.0;

  /// 按钮圆角
  static const double buttonRadius = 12.0;

  /// 输入框圆角
  static const double inputRadius = 10.0;

  // ─── 字体大小 ───────────────────────────────────────────────

  /// 标题字体大小
  static const double fontSizeTitle = 13.0;

  /// 标签字体大小
  static const double fontSizeLabel = 11.0;

  /// 计时数字字体大小
  static const double fontSizeTimer = 42.0;

  /// 轮次信息字体大小
  static const double fontSizeRound = 12.0;

  // ─── 阴影 ───────────────────────────────────────────────────

  /// 卡片阴影
  static const BoxShadow cardShadow = BoxShadow(
    color: Color(0x1A000000),
    blurRadius: 12.0,
    offset: Offset(0, 4),
  );
}
