// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// ─── Shared cached border objects ────────────────────────────────────────────
// These are created once and reused across all text inputs and dropdowns
// to avoid allocating new OutlineInputBorder objects on every build frame.
const _kBorderRadius = BorderRadius.all(Radius.circular(8));
const _kEnabledBorderSide = BorderSide(color: Color(0xFFCBD5E1), width: 1.2);
const _kFocusedBorderSide = BorderSide(color: Color(0xFF0F4C81), width: 1.5);

final _kBorder = OutlineInputBorder(
  borderRadius: _kBorderRadius,
  borderSide: _kEnabledBorderSide,
);
final _kEnabledBorder = _kBorder;
final _kFocusedBorder = OutlineInputBorder(
  borderRadius: _kBorderRadius,
  borderSide: _kFocusedBorderSide,
);

class CustomFieldLabel extends StatelessWidget {
  final String label;
  final bool isRequired;

  const CustomFieldLabel({
    super.key,
    required this.label,
    this.isRequired = true,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(
            color: Color(0xFF1E293B),
            fontSize: 13.5,
            fontWeight: FontWeight.bold,
            fontFamily: 'Outfit', // Or default if not loaded
          ),
          children: [
            TextSpan(text: label),
            if (isRequired)
              const TextSpan(
                text: ' *',
                style: TextStyle(color: Color(0xFFEF5350)),
              ),
          ],
        ),
      ),
    );
  }
}

class CustomTextInput extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final int maxLines;
  final TextInputType keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final Widget? suffixIcon;
  final bool readOnly;
  final VoidCallback? onTap;
  final ValueChanged<String>? onChanged;

  const CustomTextInput({
    super.key,
    required this.controller,
    required this.hint,
    this.maxLines = 1,
    this.keyboardType = TextInputType.text,
    this.inputFormatters,
    this.suffixIcon,
    this.readOnly = false,
    this.onTap,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: _kBorderRadius,
        boxShadow: [
          BoxShadow(
            color: Color(0x05000000), // black with 2% opacity
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        inputFormatters: inputFormatters,
        readOnly: readOnly,
        onTap: onTap,
        onChanged: onChanged,
        // Disable Android Autofill/AssistStructure scanning to prevent lag.
        // Must be null (not empty list) — only null prevents the engine from
        // calling onProvideAutofillVirtualStructure in TextInputPlugin.java.
        autofillHints: null,
        enableSuggestions: false,
        autocorrect: false,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(
            color: Color(0xFF94A3B8),
            fontSize: 13,
          ),
          suffixIcon: suffixIcon,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          border: _kBorder,
          enabledBorder: _kEnabledBorder,
          focusedBorder: _kFocusedBorder,
        ),
        style: const TextStyle(
          color: Color(0xFF1E293B),
          fontSize: 14,
        ),
      ),
    );
  }
}

class CustomDropdownSelector extends StatelessWidget {
  final String hint;
  final String? value;
  final List<String> items;
  final ValueChanged<String?> onChanged;

  const CustomDropdownSelector({
    super.key,
    required this.hint,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final List<String> uniqueItems = items.toSet().toList();
    final String? effectiveValue = (value != null && uniqueItems.contains(value)) ? value : null;

    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFF8FAFC),
        borderRadius: _kBorderRadius,
        boxShadow: [
          BoxShadow(
            color: Color(0x03000000), // black with 1% opacity
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: DropdownButtonFormField<String>(
        value: effectiveValue,
        isExpanded: true,
        hint: Text(
          hint,
          style: const TextStyle(
            color: Color(0xFF94A3B8),
            fontSize: 13,
          ),
        ),
        icon: const Icon(
          Icons.keyboard_arrow_right_rounded,
          color: Color(0xFF0F4C81),
        ),
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          border: _kBorder,
          enabledBorder: _kEnabledBorder,
          focusedBorder: _kFocusedBorder,
        ),
        items: uniqueItems.map((String item) {
          return DropdownMenuItem<String>(
            value: item,
            child: Text(
              item,
              style: const TextStyle(fontSize: 13.5, color: Color(0xFF1E293B)),
              overflow: TextOverflow.ellipsis,
            ),
          );
        }).toList(),
        onChanged: onChanged,
      ),
    );
  }
}
