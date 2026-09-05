import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';

/// Clean, beautiful, lightweight Markdown Renderer for AI responses in LSP Mobile.
class AiMarkdownView extends StatelessWidget {
  final String text;
  final TextStyle? baseStyle;
  final Color? defaultTextColor;
  final bool isUser;

  const AiMarkdownView({
    super.key,
    required this.text,
    this.baseStyle,
    this.defaultTextColor,
    this.isUser = false,
  });

  @override
  Widget build(BuildContext context) {
    if (text.trim().isEmpty) {
      return Text(
        'Mohon maaf, respon dari sistem kosong atau mengalami kendala jaringan. Silakan ketuk tombol refresh untuk mencoba kembali.',
        style: _getBaseStyle(context),
      );
    }

    if (isUser) {
      return Text(
        text,
        style: _getBaseStyle(context).copyWith(color: Colors.white),
      );
    }

    final base = _getBaseStyle(context);

    return MarkdownBody(
      data: text,
      selectable: true,
      styleSheet: MarkdownStyleSheet.fromTheme(Theme.of(context)).copyWith(
        p: base,
        h1: base.copyWith(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A)),
        h2: base.copyWith(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A)),
        h3: base.copyWith(fontSize: 14.5, fontWeight: FontWeight.bold, color: const Color(0xFF1E293B)),
        code: TextStyle(
          backgroundColor: const Color(0xFFF1F5F9),
          color: const Color(0xFF0F172A),
          fontFamily: 'monospace',
          fontSize: (base.fontSize ?? 13.5) * 0.9,
        ),
        codeblockDecoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        blockquoteDecoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(4),
          border: const Border(left: BorderSide(color: Color(0xFF3B82F6), width: 3)),
        ),
        tableBorder: TableBorder.all(color: const Color(0xFFE2E8F0), width: 1),
        tableHead: base.copyWith(fontWeight: FontWeight.bold, color: const Color(0xFF0F172A)),
        tableBody: base,
        tableCellsPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      ),
    );
  }

  TextStyle _getBaseStyle(BuildContext context) {
    return baseStyle ??
        TextStyle(
          color: defaultTextColor ?? const Color(0xFF1E293B),
          fontSize: 13.5,
          height: 1.5,
        );
  }
}
