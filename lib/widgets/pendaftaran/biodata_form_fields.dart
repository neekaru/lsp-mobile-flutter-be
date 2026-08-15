// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';

// ============================================================================
// Form field widgets untuk biodata peserta (APL 01).
//
// Diekstrak dari step4_biodata_peserta.dart agar file step tetap ringkas.
// Semua widget murni menerima nilai + callback dari pemanggil.
// ============================================================================

class BiodataAccordionCard extends StatelessWidget {
  final IconData icon;
  final Color iconBgColor;
  final Color iconColor;
  final String title;
  final bool isExpanded;
  final VoidCallback onTapHeader;
  final Widget content;

  const BiodataAccordionCard({
    super.key,
    required this.icon,
    required this.iconBgColor,
    required this.iconColor,
    required this.title,
    required this.isExpanded,
    required this.onTapHeader,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: onTapHeader,
            borderRadius: BorderRadius.circular(10),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: iconBgColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Icon(
                        icon,
                        color: iconColor,
                        size: 20,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                  ),
                  Icon(
                    isExpanded
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.chevron_right_rounded,
                    color: const Color(0xFF0F172A),
                    size: 22,
                  ),
                ],
              ),
            ),
          ),
          if (isExpanded) ...[
            const Divider(height: 1, color: Color(0xFFE2E8F0)),
            Padding(
              padding: const EdgeInsets.all(14),
              child: content,
            ),
          ],
        ],
      ),
    );
  }
}

class BiodataInputField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String hint;
  final Widget? rightAction;
  final int maxLines;
  final TextInputType keyboardType;
  final bool isLast;

  const BiodataInputField({
    super.key,
    required this.label,
    required this.controller,
    this.hint = '',
    this.rightAction,
    this.maxLines = 1,
    this.keyboardType = TextInputType.text,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0.0 : 10.0),
      child: Row(
        crossAxisAlignment:
            maxLines > 1 ? CrossAxisAlignment.start : CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0F172A),
                height: 1.3,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller,
                    maxLines: maxLines,
                    keyboardType: keyboardType,
                    style: const TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A),
                    ),
                    decoration: InputDecoration(
                      isDense: true,
                      hintText: hint,
                      hintStyle: const TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.normal,
                        color: Color(0xFF94A3B8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 8,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6),
                        borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6),
                        borderSide:
                            const BorderSide(color: Color(0xFF3B82F6), width: 1.5),
                      ),
                      fillColor: Colors.white,
                      filled: true,
                    ),
                  ),
                ),
                if (rightAction != null) ...[
                  const SizedBox(width: 6),
                  rightAction!,
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class BiodataSelectField extends StatelessWidget {
  final String label;
  final String value;
  final String hint;
  final VoidCallback onTap;
  final bool isLast;

  const BiodataSelectField({
    super.key,
    required this.label,
    required this.value,
    this.hint = 'Pilih...',
    required this.onTap,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    final bool hasValue = value.isNotEmpty;

    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0.0 : 10.0),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0F172A),
                height: 1.3,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: GestureDetector(
              onTap: onTap,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: const Color(0xFFCBD5E1)),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        hasValue ? value : hint,
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight:
                              hasValue ? FontWeight.bold : FontWeight.normal,
                          color: hasValue
                              ? const Color(0xFF0F172A)
                              : const Color(0xFF94A3B8),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const Icon(
                      Icons.arrow_drop_down_rounded,
                      color: Color(0xFF64748B),
                      size: 20,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class BiodataDatePickerField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String hint;
  final VoidCallback onTap;
  final bool isLast;

  const BiodataDatePickerField({
    super.key,
    required this.label,
    required this.controller,
    this.hint = 'dd/mm/yyyy',
    required this.onTap,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0.0 : 10.0),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0F172A),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: GestureDetector(
              onTap: onTap,
              child: AbsorbPointer(
                child: TextField(
                  controller: controller,
                  style: const TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A),
                  ),
                  decoration: InputDecoration(
                    isDense: true,
                    hintText: hint,
                    hintStyle: const TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.normal,
                      color: Color(0xFF94A3B8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 8,
                    ),
                    suffixIcon: const Icon(
                      Icons.calendar_today_outlined,
                      color: Color(0xFF64748B),
                      size: 16,
                    ),
                    suffixIconConstraints: const BoxConstraints(
                      minWidth: 32,
                      minHeight: 32,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                      borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                      borderSide:
                          const BorderSide(color: Color(0xFF3B82F6), width: 1.5),
                    ),
                    fillColor: Colors.white,
                    filled: true,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class BiodataPhoneField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String hint;
  final bool isLast;
  final VoidCallback onTap;

  const BiodataPhoneField({
    super.key,
    required this.label,
    required this.controller,
    this.hint = 'Masukkan No.Kontak',
    this.isLast = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0.0 : 10.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0F172A),
                height: 1.3,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: GestureDetector(
              onTap: onTap,
              child: AbsorbPointer(
                child: TextField(
                  controller: controller,
                  style: const TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A),
                  ),
                  decoration: InputDecoration(
                    isDense: true,
                    hintText: hint,
                    hintStyle: const TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.normal,
                      color: Color(0xFF94A3B8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 8,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                      borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                      borderSide:
                          const BorderSide(color: Color(0xFF3B82F6), width: 1.5),
                    ),
                    fillColor: Colors.white,
                    filled: true,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
