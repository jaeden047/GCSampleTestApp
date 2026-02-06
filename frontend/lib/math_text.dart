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

  /// Normalize double-escaped LaTeX commands (e.g. \\frac -> \frac) but preserve
  /// \\ used as row separator in matrices (e.g. 1 & 2 \\ 3 & 4).
  static String _normalizeBackslashes(String s) {
    // Only collapse \\ when followed by letters (command name), not \\ followed by space/&
    return s.replaceAllMapped(RegExp(r'\\\\([a-zA-Z]+)'), (m) => '\\${m[1]}');
  }

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) return SizedBox.shrink();

    final normalized = _normalizeBackslashes(data);
    final style = textStyle ?? DefaultTextStyle.of(context).style;
    final fontSize = mathFontSize ?? style.fontSize ?? 14.0;

    // Display math: split by $$ and render math segments
    if (normalized.contains(r'$$')) {
      final segments = normalized.split(r'$$');
      final children = <Widget>[];
      for (int i = 0; i < segments.length; i++) {
        final segment = segments[i].trim();
        if (segment.isEmpty) continue;
        if (i % 2 == 1) {
          children.add(_buildMath(segment, fontSize, style));
        } else {
          children.add(_buildSegment(segment, fontSize, style));
        }
      }
      return Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        children: children,
      );
    }

    // Inline math: split by single $ so that $...$ segments render as math
    if (normalized.contains('\$') && _countOccurrences(normalized, '\$') >= 2) {
      final segments = normalized.split('\$');
      final children = <Widget>[];
      for (int i = 0; i < segments.length; i++) {
        final segment = segments[i];
        if (segment.isEmpty) continue;
        if (i % 2 == 1) {
          children.add(_buildMath(segment.trim(), fontSize, style));
        } else {
          children.add(_buildSegment(segment, fontSize, style));
        }
      }
      return Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        children: children,
      );
    }

    // Whole string might be a single LaTeX expression (e.g. after normalizing \\ to \)
    if (_looksLikeLatex(normalized)) {
      return _buildMath(normalized, fontSize, style);
    }

    return Text(normalized, style: style, textAlign: textAlign);
  }

  int _countOccurrences(String s, String sub) {
    int count = 0;
    int i = 0;
    while (i <= s.length - sub.length) {
      if (s.substring(i, i + sub.length) == sub) {
        count++;
        i += sub.length;
      } else {
        i++;
      }
    }
    return count;
  }

  Widget _buildSegment(String segment, double fontSize, TextStyle style) {
    if (segment.isEmpty) return SizedBox.shrink();
    final seg = _normalizeBackslashes(segment);
    if (_looksLikeLatex(seg)) {
      return _buildMath(seg, fontSize, style);
    }
    return Text(seg, style: style, textAlign: textAlign);
  }

  bool _looksLikeLatex(String s) {
    final t = s.trim();
    return t.startsWith(r'\') ||
        t.contains(r'\frac') ||
        t.contains(r'\begin') ||
        t.contains(r'\sqrt') ||
        t.contains(r'\theta') ||
        t.contains(r'\vec') ||
        t.contains(r'\hat') ||
        t.contains(r'\equiv') ||
        t.contains(r'\pmod') ||
        t.contains(r'\det') ||
        t.contains(r'\int') ||
        t.contains(r'\sum');
  }

  Widget _buildMath(String latex, double fontSize, TextStyle fallbackStyle) {
    final normalizedLatex = _normalizeBackslashes(latex);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Math.tex(
        normalizedLatex,
        textStyle: fallbackStyle.copyWith(fontSize: fontSize),
        mathStyle: MathStyle.text,
        onErrorFallback: (error) => Text(
          normalizedLatex,
          style: fallbackStyle.copyWith(fontSize: fontSize, color: Colors.grey),
        ),
      ),
    );
  }
}
