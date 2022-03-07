import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:spotify_2/shared/constants/style.dart';

class CustomAutoSizeText extends StatelessWidget {
  const CustomAutoSizeText(
    this.text, {

    required this.minFontSize,
    required this.fontSize,
    required this.maxLines,
    required this.overflow,
    required this.overflowReplacement,
  }) ;

  final String text;
  final Widget overflowReplacement;
  final double minFontSize;
  final double fontSize;
  final int maxLines;
  final TextOverflow overflow;

  @override
  Widget build(BuildContext context) {
    return AutoSizeText(text,
        maxLines: maxLines,
        minFontSize: minFontSize,
        overflowReplacement: overflowReplacement,
        textAlign: TextAlign.center,
        overflow: overflow,
        style: TextStyles.primary.copyWith(
            fontSize: fontSize,
            fontWeight: FontWeight.w600,
            height: 1.1,
            letterSpacing: -1.5));
  }
}
