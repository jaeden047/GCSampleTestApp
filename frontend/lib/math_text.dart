import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';

class MathText extends StatelessWidget {
  final String data;
  final TextStyle? textStyle;
  final double? mathFontSize;
  final TextAlign textAlign;

  const MathText(
    this.data, {
    super.key,
    this.textStyle,
    this.mathFontSize,
    this.textAlign = TextAlign.start,
  });

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) return SizedBox.shrink();

    final style = textStyle ?? DefaultTextStyle.of(context).style;
    final fontSize = mathFontSize ?? style.fontSize ?? 14.0;

    // Mixed content: split by $$ and render math segments
    if (data.contains(r'$$')) {
      final segments = data.split(r'$$');
      final children = <Widget>[];
      for (int i = 0; i < segments.length; i++) {
        final segment = segments[i].trim();
        if (segment.isEmpty) continue;
        if (i % 2 == 1) {
          children.add(_buildMath(segment, fontSize, style));
        } else {
          children.add(Text(segment, style: style, textAlign: textAlign));
        }
      }
      return Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        children: children,
      );
    }

    // Whole string might be a single LaTeX expression (e.g. \frac{1}{2} or \begin{bmatrix}...)
    if (_looksLikeLatex(data)) {
      return _buildMath(data, fontSize, style);
    }

    return Text(data, style: style, textAlign: textAlign);
  }

  bool _looksLikeLatex(String s) {
    final t = s.trim();
    return t.startsWith(r'\') ||
        t.contains(r'\frac') ||
        t.contains(r'\begin') ||
        t.contains(r'\sqrt') ||
        t.contains(r'\theta') ||
        t.contains(r'\vec') ||
        t.contains(r'\hat');
  }

  Widget _buildMath(String latex, double fontSize, TextStyle fallbackStyle) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Math.tex(
        latex,
        textStyle: fallbackStyle.copyWith(fontSize: fontSize),
        mathStyle: MathStyle.text,
        onErrorFallback: (error) => Text(
          latex,
          style: fallbackStyle.copyWith(fontSize: fontSize, color: Colors.grey),
        ),
      ),
    );
  }
}
