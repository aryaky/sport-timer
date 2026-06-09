import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// 步进器输入组件
///
/// 显示标签、减号按钮、数字输入框、加号按钮和后缀文字。
/// 支持步进增减和手动输入，自动校验 min/max 范围。
class StepperInput extends StatefulWidget {
  /// 顶部标签文字
  final String label;

  /// 当前数值
  final int value;

  /// 最小值
  final int min;

  /// 最大值
  final int max;

  /// 步长
  final int step;

  /// 数值后显示的后缀文字（如 "秒"）
  final String suffix;

  /// 数值变化回调
  final ValueChanged<int> onChanged;

  const StepperInput({
    super.key,
    required this.label,
    required this.value,
    this.min = 0,
    this.max = 99,
    this.step = 1,
    this.suffix = '',
    required this.onChanged,
  });

  @override
  State<StepperInput> createState() => _StepperInputState();
}

class _StepperInputState extends State<StepperInput> {
  late TextEditingController _controller;
  late FocusNode _focusNode;
  bool _isDecrementHovered = false;
  bool _isIncrementHovered = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value.toString());
    _focusNode = FocusNode();
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void didUpdateWidget(covariant StepperInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 外部值变化时更新输入框（避免在编辑中覆盖）
    if (widget.value != oldWidget.value && !_focusNode.hasFocus) {
      _controller.text = widget.value.toString();
    }
  }

  void _onFocusChange() {
    if (!_focusNode.hasFocus) {
      _validateAndCommit();
    }
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  /// 校验输入并提交
  void _validateAndCommit() {
    final parsed = int.tryParse(_controller.text);
    if (parsed == null) {
      // 非法输入，恢复到当前值
      _controller.text = widget.value.toString();
      return;
    }
    final clamped = parsed.clamp(widget.min, widget.max);
    if (clamped != parsed) {
      _controller.text = clamped.toString();
    }
    if (clamped != widget.value) {
      widget.onChanged(clamped);
    }
  }

  /// 按步长增减
  void _adjust(int delta) {
    final newValue = (widget.value + delta).clamp(widget.min, widget.max);
    if (newValue != widget.value) {
      widget.onChanged(newValue);
      _controller.text = newValue.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // 标签
        Text(
          widget.label,
          style: const TextStyle(
            fontSize: 11,
            color: Color(0xFF8E8E93),
            fontWeight: FontWeight.w400,
          ),
        ),
        const SizedBox(height: 6),
        // 操作行
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 减号按钮
            _StepButton(
              label: '\u2212', // − 减号
              isHovered: _isDecrementHovered,
              onHoverChanged: (hovered) {
                setState(() => _isDecrementHovered = hovered);
              },
              onTap: () => _adjust(-widget.step),
            ),
            const SizedBox(width: 8),
            // 数字输入框
            SizedBox(
              width: 52,
              height: 40,
              child: TextField(
                controller: _controller,
                focusNode: _focusNode,
                textAlign: TextAlign.center,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1D1D1F),
                  height: 1.2,
                ),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: const Color(0xFFF5F5F7),
                  contentPadding: EdgeInsets.zero,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(
                      color: Color(0xFFFF6B35),
                      width: 1.5,
                    ),
                  ),
                ),
                onSubmitted: (_) => _validateAndCommit(),
              ),
            ),
            const SizedBox(width: 8),
            // 加号按钮
            _StepButton(
              label: '+',
              isHovered: _isIncrementHovered,
              onHoverChanged: (hovered) {
                setState(() => _isIncrementHovered = hovered);
              },
              onTap: () => _adjust(widget.step),
            ),
            if (widget.suffix.isNotEmpty) ...[
              const SizedBox(width: 6),
              // 后缀文字
              Text(
                widget.suffix,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF8E8E93),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}

/// 步进器按钮（+ / −）
class _StepButton extends StatelessWidget {
  final String label;
  final bool isHovered;
  final ValueChanged<bool> onHoverChanged;
  final VoidCallback onTap;

  const _StepButton({
    required this.label,
    required this.isHovered,
    required this.onHoverChanged,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final Color foregroundColor =
        isHovered ? const Color(0xFFFF6B35) : const Color(0xFF8E8E93);

    return MouseRegion(
      onEnter: (_) => onHoverChanged(true),
      onExit: (_) => onHoverChanged(false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: isHovered
                ? const Color(0xFFFF6B35).withValues(alpha: 0.1)
                : const Color(0xFFF5F5F7),
            borderRadius: BorderRadius.circular(10),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: foregroundColor,
            ),
          ),
        ),
      ),
    );
  }
}
