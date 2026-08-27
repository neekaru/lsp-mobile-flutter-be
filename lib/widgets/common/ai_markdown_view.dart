import 'package:flutter/material.dart';

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

    // For user messages, simple styled text with inline formatting
    if (isUser) {
      return Text(
        text,
        style: _getBaseStyle(context).copyWith(color: Colors.white),
      );
    }

    final blocks = _parseBlocks(text);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: blocks.map((block) => _buildBlock(context, block)).toList(),
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

  // Parse lines into structured blocks
  List<_MdBlock> _parseBlocks(String rawText) {
    final List<_MdBlock> blocks = [];
    final lines = rawText.split('\n');

    int i = 0;
    while (i < lines.length) {
      final line = lines[i];
      final trimmed = line.trim();

      if (trimmed.isEmpty) {
        i++;
        continue;
      }

      // 1. Code Block ```
      if (trimmed.startsWith('```')) {
        final language = trimmed.substring(3).trim();
        final List<String> codeLines = [];
        i++;
        while (i < lines.length && !lines[i].trim().startsWith('```')) {
          codeLines.add(lines[i]);
          i++;
        }
        if (i < lines.length && lines[i].trim().startsWith('```')) {
          i++; // skip closing ```
        }
        blocks.add(_MdBlock(
          type: _MdBlockType.codeBlock,
          content: codeLines.join('\n'),
          extra: language,
        ));
        continue;
      }

      // 2. Table (| Col | Col |)
      if (trimmed.startsWith('|') && trimmed.endsWith('|') && trimmed.length > 2) {
        final List<String> tableLines = [];
        while (i < lines.length &&
            lines[i].trim().startsWith('|') &&
            lines[i].trim().endsWith('|')) {
          tableLines.add(lines[i].trim());
          i++;
        }
        blocks.add(_MdBlock(
          type: _MdBlockType.table,
          content: tableLines.join('\n'),
        ));
        continue;
      }

      // 3. Headings (#, ##, ###, ####)
      if (trimmed.startsWith('# ') ||
          trimmed.startsWith('## ') ||
          trimmed.startsWith('### ') ||
          trimmed.startsWith('#### ')) {
        int level = 1;
        if (trimmed.startsWith('#### ')) {
          level = 4;
        } else if (trimmed.startsWith('### ')) {
          level = 3;
        } else if (trimmed.startsWith('## ')) {
          level = 2;
        }
        final headingText = trimmed.substring(level + 1).trim();
        blocks.add(_MdBlock(
          type: _MdBlockType.heading,
          content: headingText,
          extra: level.toString(),
        ));
        i++;
        continue;
      }

      // 4. Horizontal Rule (---, ***, ___)
      if (trimmed == '---' || trimmed == '***' || trimmed == '___') {
        blocks.add(const _MdBlock(type: _MdBlockType.divider, content: ''));
        i++;
        continue;
      }

      // 5. Blockquote (> Quote)
      if (trimmed.startsWith('> ') || trimmed == '>') {
        final List<String> quoteLines = [];
        while (i < lines.length && (lines[i].trim().startsWith('>') || lines[i].trim().startsWith('> '))) {
          final qLine = lines[i].trim();
          quoteLines.add(qLine.startsWith('> ') ? qLine.substring(2) : qLine.substring(1));
          i++;
        }
        blocks.add(_MdBlock(
          type: _MdBlockType.blockquote,
          content: quoteLines.join('\n'),
        ));
        continue;
      }

      // 6. Bullet List (- item, * item, • item)
      final bulletMatch = RegExp(r'^(\s*)([-*•])\s+(.*)$').firstMatch(line);
      if (bulletMatch != null) {
        final indent = bulletMatch.group(1)?.length ?? 0;
        final itemContent = bulletMatch.group(3) ?? '';
        blocks.add(_MdBlock(
          type: _MdBlockType.bulletItem,
          content: itemContent,
          extra: (indent >= 2 ? 1 : 0).toString(),
        ));
        i++;
        continue;
      }

      // 7. Numbered List (1. item, 2. item)
      final numMatch = RegExp(r'^(\s*)(\d+)[\.\)]\s+(.*)$').firstMatch(line);
      if (numMatch != null) {
        final number = numMatch.group(2) ?? '1';
        final itemContent = numMatch.group(3) ?? '';
        blocks.add(_MdBlock(
          type: _MdBlockType.numberedItem,
          content: itemContent,
          extra: number,
        ));
        i++;
        continue;
      }

      // 8. Regular Paragraph
      final List<String> pLines = [line];
      i++;
      while (i < lines.length) {
        final nextLine = lines[i];
        final nextTrim = nextLine.trim();
        if (nextTrim.isEmpty ||
            nextTrim.startsWith('```') ||
            nextTrim.startsWith('|') ||
            nextTrim.startsWith('#') ||
            nextTrim.startsWith('>') ||
            nextTrim == '---' ||
            RegExp(r'^(\s*)([-*•]|\d+[\.\)])\s+').hasMatch(nextLine)) {
          break;
        }
        pLines.add(nextLine);
        i++;
      }
      blocks.add(_MdBlock(
        type: _MdBlockType.paragraph,
        content: pLines.join(' '),
      ));
    }

    return blocks;
  }

  Widget _buildBlock(BuildContext context, _MdBlock block) {
    final base = _getBaseStyle(context);

    switch (block.type) {
      case _MdBlockType.heading:
        final level = int.tryParse(block.extra ?? '1') ?? 1;
        double fontSize = 16.0;
        FontWeight weight = FontWeight.w700;
        Color color = const Color(0xFF0F172A);
        EdgeInsets margin = const EdgeInsets.only(top: 10, bottom: 4);

        if (level == 1) {
          fontSize = 17.0;
          color = const Color(0xFF1E3A8A);
          margin = const EdgeInsets.only(top: 12, bottom: 6);
        } else if (level == 2) {
          fontSize = 15.5;
          color = const Color(0xFF1E40AF);
          margin = const EdgeInsets.only(top: 10, bottom: 4);
        } else if (level == 3) {
          fontSize = 14.5;
          color = const Color(0xFF1E293B);
          margin = const EdgeInsets.only(top: 8, bottom: 4);
        } else {
          fontSize = 13.5;
          color = const Color(0xFF334155);
          margin = const EdgeInsets.only(top: 6, bottom: 2);
        }

        return Padding(
          padding: margin,
          child: RichText(
            text: _parseInlineSpans(
              block.content,
              base.copyWith(
                fontSize: fontSize,
                fontWeight: weight,
                color: color,
                height: 1.35,
              ),
            ),
          ),
        );

      case _MdBlockType.paragraph:
        return Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: RichText(
            text: _parseInlineSpans(block.content, base),
          ),
        );

      case _MdBlockType.bulletItem:
        final indentLevel = int.tryParse(block.extra ?? '0') ?? 0;
        final leftPadding = (indentLevel * 14.0) + 4.0;

        return Padding(
          padding: EdgeInsets.only(left: leftPadding, bottom: 4, top: 1),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 6, right: 8),
                width: 5.5,
                height: 5.5,
                decoration: const BoxDecoration(
                  color: Color(0xFF2563EB),
                  shape: BoxShape.circle,
                ),
              ),
              Expanded(
                child: RichText(
                  text: _parseInlineSpans(block.content, base),
                ),
              ),
            ],
          ),
        );

      case _MdBlockType.numberedItem:
        final numStr = block.extra ?? '1';
        return Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 4, top: 1),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: const EdgeInsets.only(right: 6),
                child: Text(
                  '$numStr.',
                  style: base.copyWith(
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF2563EB),
                  ),
                ),
              ),
              Expanded(
                child: RichText(
                  text: _parseInlineSpans(block.content, base),
                ),
              ),
            ],
          ),
        );

      case _MdBlockType.blockquote:
        return Container(
          margin: const EdgeInsets.symmetric(vertical: 6),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: const BoxDecoration(
            color: Color(0xFFF8FAFC),
            border: Border(
              left: BorderSide(color: Color(0xFF3B82F6), width: 3.5),
            ),
            borderRadius: BorderRadius.only(
              topRight: Radius.circular(8),
              bottomRight: Radius.circular(8),
            ),
          ),
          child: RichText(
            text: _parseInlineSpans(
              block.content,
              base.copyWith(
                color: const Color(0xFF475569),
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        );

      case _MdBlockType.codeBlock:
        final lang = block.extra ?? '';
        return Container(
          margin: const EdgeInsets.symmetric(vertical: 6),
          width: double.infinity,
          decoration: BoxDecoration(
            color: const Color(0xFF0F172A),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFF1E293B)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (lang.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: const BoxDecoration(
                    color: Color(0xFF1E293B),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(7),
                      topRight: Radius.circular(7),
                    ),
                  ),
                  child: Text(
                    lang.toUpperCase(),
                    style: const TextStyle(
                      color: Color(0xFF94A3B8),
                      fontSize: 10.5,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: SelectableText(
                  block.content,
                  style: const TextStyle(
                    color: Color(0xFFF1F5F9),
                    fontSize: 12.5,
                    fontFamily: 'monospace',
                    height: 1.45,
                  ),
                ),
              ),
            ],
          ),
        );

      case _MdBlockType.table:
        return _buildTableWidget(context, block.content, base);

      case _MdBlockType.divider:
        return const Padding(
          padding: EdgeInsets.symmetric(vertical: 8),
          child: Divider(color: Color(0xFFE2E8F0), thickness: 1),
        );
    }
  }

  Widget _buildTableWidget(BuildContext context, String tableStr, TextStyle base) {
    final lines = tableStr.split('\n').where((l) => l.trim().isNotEmpty).toList();
    if (lines.isEmpty) return const SizedBox.shrink();

    final List<List<String>> parsedRows = [];
    for (final line in lines) {
      final trimmed = line.trim();
      // Skip separator rows (|---|---|)
      if (RegExp(r'^\|[\s\-:]+(\|[\s\-:]+)+\|$').hasMatch(trimmed)) {
        continue;
      }
      final cells = trimmed
          .split('|')
          .map((c) => c.trim())
          .where((c) => c.isNotEmpty)
          .toList();
      if (cells.isNotEmpty) {
        parsedRows.add(cells);
      }
    }

    if (parsedRows.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Table(
            defaultColumnWidth: const IntrinsicColumnWidth(),
            border: TableBorder.all(
              color: const Color(0xFFE2E8F0),
              width: 0.8,
            ),
            children: List.generate(parsedRows.length, (rowIndex) {
              final isHeader = rowIndex == 0;
              final row = parsedRows[rowIndex];

              return TableRow(
                decoration: BoxDecoration(
                  color: isHeader ? const Color(0xFFF1F5F9) : (rowIndex.isEven ? const Color(0xFFF8FAFC) : Colors.white),
                ),
                children: row.map((cell) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                    child: RichText(
                      text: _parseInlineSpans(
                        cell,
                        base.copyWith(
                          fontSize: 12,
                          fontWeight: isHeader ? FontWeight.w700 : FontWeight.w400,
                          color: isHeader ? const Color(0xFF0F172A) : const Color(0xFF334155),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              );
            }),
          ),
        ),
      ),
    );
  }

  // Parse inline spans: **bold**, *italic*, `code`, ~~strike~~
  InlineSpan _parseInlineSpans(String text, TextStyle defaultStyle) {
    final List<InlineSpan> spans = [];

    // Regex for inline code: `code`
    final inlineRegex = RegExp(r'(`[^`]+`)|(\*\*\*[^*]+\*\*\*)|(\*\*[^*]+\*\*)|(\*[^*]+\*)|(~~[^~]+~~)');
    int lastMatchEnd = 0;

    for (final match in inlineRegex.allMatches(text)) {
      if (match.start > lastMatchEnd) {
        spans.add(TextSpan(
          text: text.substring(lastMatchEnd, match.start),
          style: defaultStyle,
        ));
      }

      final matchedStr = match.group(0)!;
      if (matchedStr.startsWith('`') && matchedStr.endsWith('`')) {
        // Inline code
        final codeText = matchedStr.substring(1, matchedStr.length - 1);
        spans.add(WidgetSpan(
          alignment: PlaceholderAlignment.middle,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
            margin: const EdgeInsets.symmetric(horizontal: 2),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Text(
              codeText,
              style: TextStyle(
                fontFamily: 'monospace',
                fontSize: (defaultStyle.fontSize ?? 13.5) * 0.9,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1E293B),
              ),
            ),
          ),
        ));
      } else if (matchedStr.startsWith('***') && matchedStr.endsWith('***')) {
        // Bold Italic
        final inner = matchedStr.substring(3, matchedStr.length - 3);
        spans.add(TextSpan(
          text: inner,
          style: defaultStyle.copyWith(
            fontWeight: FontWeight.bold,
            fontStyle: FontStyle.italic,
          ),
        ));
      } else if (matchedStr.startsWith('**') && matchedStr.endsWith('**')) {
        // Bold
        final inner = matchedStr.substring(2, matchedStr.length - 2);
        spans.add(TextSpan(
          text: inner,
          style: defaultStyle.copyWith(
            fontWeight: FontWeight.bold,
            color: const Color(0xFF0F172A),
          ),
        ));
      } else if (matchedStr.startsWith('*') && matchedStr.endsWith('*')) {
        // Italic
        final inner = matchedStr.substring(1, matchedStr.length - 1);
        spans.add(TextSpan(
          text: inner,
          style: defaultStyle.copyWith(fontStyle: FontStyle.italic),
        ));
      } else if (matchedStr.startsWith('~~') && matchedStr.endsWith('~~')) {
        // Strikethrough
        final inner = matchedStr.substring(2, matchedStr.length - 2);
        spans.add(TextSpan(
          text: inner,
          style: defaultStyle.copyWith(decoration: TextDecoration.lineThrough),
        ));
      }

      lastMatchEnd = match.end;
    }

    if (lastMatchEnd < text.length) {
      spans.add(TextSpan(
        text: text.substring(lastMatchEnd),
        style: defaultStyle,
      ));
    }

    return TextSpan(children: spans);
  }
}

enum _MdBlockType {
  heading,
  paragraph,
  bulletItem,
  numberedItem,
  blockquote,
  codeBlock,
  table,
  divider,
}

class _MdBlock {
  final _MdBlockType type;
  final String content;
  final String? extra;

  const _MdBlock({
    required this.type,
    required this.content,
    this.extra,
  });
}
