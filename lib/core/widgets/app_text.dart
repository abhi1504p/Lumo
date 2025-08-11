import 'package:flutter/material.dart';

import '../../theme/app_color.dart';


/// Define app-wide text styles
class AppTextStyle {
  static const TextStyle heading = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );

  static const TextStyle body = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: AppColors.textPrimary,
  );

  static const TextStyle caption = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textColor,
  );
  static const TextStyle title = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );
  static const TextStyle highlight = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.primaryColor,
  );
}

/// A reusable AppText widget that supports [heading], [body], and [caption] styles
class AppText extends StatelessWidget {
  final String text;
  final TextStyle style;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;

  const AppText._(
      this.text, {
        required this.style,
        this.textAlign,
        this.maxLines,
        this.overflow,
        Key? key,
      }) : super(key: key);

  /// Use for titles and important headings
  factory AppText.heading(
      String text, {
        TextAlign? textAlign,
        int? maxLines,
        TextOverflow? overflow,
        Color? color,
        double? fontSize,
        FontWeight? fontWeight,
        Key? key,
      }) {
    return AppText._(
      text,
      style: AppTextStyle.heading.copyWith(
        color: color,
        fontSize: fontSize,
        fontWeight: fontWeight,
      ),
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
      key: key,
    );
  }

  /// Use for subtitles or section titles
  factory AppText.title(
      String text, {
        TextAlign? textAlign,
        int? maxLines,
        TextOverflow? overflow,
        Color? color,
        double? fontSize,
        FontWeight? fontWeight,
        Key? key,
      }) {
    return AppText._(
      text,
      style: AppTextStyle.title.copyWith(
        color: color,
        fontSize: fontSize,
        fontWeight: fontWeight,
      ),
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
      key: key,
    );
  }

  /// Use for normal content
  factory AppText.body(
      String text, {
        TextAlign? textAlign,
        int? maxLines,
        TextOverflow? overflow,
        Color? color,
        double? fontSize,
        FontWeight? fontWeight,
        Key? key,
      }) {
    return AppText._(
      text,
      style: AppTextStyle.body.copyWith(
        color: color,
        fontSize: fontSize,
        fontWeight: fontWeight,
      ),
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
      key: key,
    );
  }

  /// Use for captions, footnotes, etc.
  factory AppText.caption(
      String text, {
        TextAlign? textAlign,
        int? maxLines,
        TextOverflow? overflow,
        Color? color,
        double? fontSize,
        FontWeight? fontWeight,
        Key? key,
      }) {
    return AppText._(
      text,
      style: AppTextStyle.caption.copyWith(
        color: color,
        fontSize: fontSize,
        fontWeight: fontWeight,
      ),
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
      key: key,
    );
  }

  /// Use for highlighted or success text (brand green)
  factory AppText.highlight(
      String text, {
        TextAlign? textAlign,
        int? maxLines,
        TextOverflow? overflow,
        Color? color,
        double? fontSize,
        FontWeight? fontWeight,
        Key? key,
      }) {
    return AppText._(
      text,
      style: AppTextStyle.highlight.copyWith(
        color: color,
        fontSize: fontSize,
        fontWeight: fontWeight,
      ),
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
      key: key,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: style,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
    );
  }
}