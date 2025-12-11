import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class StyleTextField extends StatelessWidget {
  final Function(String) onChange;
  final bool obscureText;
  final String hintText;
  final String value;
  final bool readOnly;
  final bool isInteger;
  final bool isNumber;
  final TextInputType keyboardType;
  final int? maxLength;
  final int? maxLines;
  final FocusNode? focusNode;
  final TextEditingController? textEditingController;
  final TextStyle? textStyle;
  final TextStyle? hintTextStyle;
  final TextAlign textAlign;
  final EdgeInsets? padding;

  const StyleTextField({
    super.key,
    required this.onChange,
    this.obscureText = false,
    this.hintText = 'Please input',
    this.value = '',
    this.readOnly = false,
    this.isInteger = false,
    this.isNumber = false,
    this.keyboardType = TextInputType.text,
    this.maxLength,
    this.maxLines = 1,
    this.focusNode,
    this.textEditingController,
    this.textStyle,
    this.hintTextStyle,
    this.textAlign = TextAlign.start,
    this.padding,

  });

  @override
  Widget build(BuildContext context) {
    final ctr = TextEditingController(text: value);
    ctr.selection =
        TextSelection.fromPosition(TextPosition(offset: ctr.text.length));
    List<TextInputFormatter> inputFormatters = [];
    if (isInteger) {
      inputFormatters = <TextInputFormatter>[
        FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
      ];
    }
    if (isNumber) {
      inputFormatters = <TextInputFormatter>[
        FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
      ];
    }
    return Container(
      padding: padding ?? const EdgeInsets.symmetric(horizontal: 5),
      alignment: Alignment.center,
      color: Colors.transparent,
      child: TextField(
        maxLength: maxLength,
        keyboardType: keyboardType,
        readOnly: readOnly,
        controller: textEditingController ?? ctr,
        maxLines: maxLines,
        textAlign: textAlign,
        decoration: InputDecoration(
          counterText: '',
          hintText: hintText,
          border: InputBorder.none,
          contentPadding: EdgeInsets.zero,
          isDense: true,
          isCollapsed: false,
          hintStyle: hintTextStyle ?? const TextStyle(
            color: Color(0xffadadad),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        obscureText: obscureText,
        style: textStyle ?? const TextStyle(
          color: Colors.black,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        inputFormatters: !isInteger && !isNumber ? null : inputFormatters,
        onChanged: (v) {
          onChange.call(v);
        },
      ),
    );
  }
}
