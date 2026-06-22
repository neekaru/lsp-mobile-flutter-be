// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/master_models.dart';

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
    
    // Highly robust value resolution: try exact match, then try trimmed case-insensitive match, fallback to null
    String? effectiveValue;
    if (value != null) {
      if (uniqueItems.contains(value)) {
        effectiveValue = value;
      } else {
        final String trimmedValue = value!.trim().toLowerCase();
        try {
          effectiveValue = uniqueItems.firstWhere(
            (item) => item.trim().toLowerCase() == trimmedValue,
          );
        } catch (_) {
          effectiveValue = null;
        }
      }
    }

    // PERF: Use lightweight key based on item count + selected value only.
    // Previous key joined ALL items into one massive string on every rebuild.
    final dropdownKey = ValueKey('${hint}_${uniqueItems.length}_$effectiveValue');

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
        key: dropdownKey,
        value: effectiveValue,
        isExpanded: true,
        menuMaxHeight: MediaQuery.of(context).size.height * 0.4,
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

class CustomKeyValueDropdownSelector extends StatelessWidget {
  final String hint;
  final String? value;
  final List<MasterItem> items;
  final ValueChanged<String?> onChanged;
  final bool isLoading;

  const CustomKeyValueDropdownSelector({
    super.key,
    required this.hint,
    required this.value,
    required this.items,
    required this.onChanged,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    // Make sure we have unique keys
    final Map<String, String> uniqueItems = {};
    for (var item in items) {
      if (item.id.isNotEmpty) {
        uniqueItems[item.id] = item.name;
      }
    }

    String? effectiveValue;
    if (value != null && uniqueItems.containsKey(value)) {
      effectiveValue = value;
    }

    // PERF: Lightweight key — only item count + selected value.
    // Previous key joined ALL keys into one massive string on every rebuild.
    final dropdownKey = ValueKey('${hint}_${uniqueItems.length}_$effectiveValue');

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
        key: dropdownKey,
        value: effectiveValue,
        isExpanded: true,
        menuMaxHeight: MediaQuery.of(context).size.height * 0.4,
        hint: Text(
          isLoading ? 'Memuat data...' : hint,
          style: TextStyle(
            color: isLoading ? const Color(0xFF0F4C81) : const Color(0xFF94A3B8),
            fontSize: 13,
          ),
        ),
        icon: isLoading
            ? const Padding(
                padding: EdgeInsets.only(right: 4.0),
                child: SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF0F4C81)),
                  ),
                ),
              )
            : const Icon(
                Icons.keyboard_arrow_down_rounded,
                color: Color(0xFF0F4C81),
              ),
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          border: _kBorder,
          enabledBorder: _kEnabledBorder,
          focusedBorder: _kFocusedBorder,
        ),
        items: isLoading
            ? []
            : uniqueItems.entries.map((entry) {
                return DropdownMenuItem<String>(
                  value: entry.key,
                  child: Text(
                    entry.value,
                    style: const TextStyle(fontSize: 13.5, color: Color(0xFF1E293B)),
                    overflow: TextOverflow.ellipsis,
                  ),
                );
              }).toList(),
        onChanged: isLoading ? null : onChanged,
      ),
    );
  }
}

class DropdownItemData<T> {
  final T value;
  final String label;

  const DropdownItemData({required this.value, required this.label});
}

class CustomKeyValueDropdownSelectorGeneric<T> extends StatelessWidget {
  final String hint;
  final T? value;
  final List<DropdownItemData<T>> items;
  final ValueChanged<T?> onChanged;
  final bool isLoading;

  const CustomKeyValueDropdownSelectorGeneric({
    super.key,
    required this.hint,
    required this.value,
    required this.items,
    required this.onChanged,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    // Highly robust value resolution
    T? effectiveValue;
    if (value != null && items.any((item) => item.value == value)) {
      effectiveValue = value;
    }

    // PERF: Lightweight key — only item count + selected value.
    // Previous key joined ALL item values into one massive string on every rebuild.
    final dropdownKey = ValueKey('${hint}_${items.length}_$effectiveValue');

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
      child: DropdownButtonFormField<T>(
        key: dropdownKey,
        value: effectiveValue,
        isExpanded: true,
        menuMaxHeight: MediaQuery.of(context).size.height * 0.4,
        hint: Text(
          isLoading ? 'Memuat data...' : hint,
          style: TextStyle(
            color: isLoading ? const Color(0xFF0F4C81) : const Color(0xFF94A3B8),
            fontSize: 13,
          ),
        ),
        icon: isLoading
            ? const Padding(
                padding: EdgeInsets.only(right: 4.0),
                child: SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF0F4C81)),
                  ),
                ),
              )
            : const Icon(
                Icons.keyboard_arrow_down_rounded,
                color: Color(0xFF0F4C81),
              ),
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          border: _kBorder,
          enabledBorder: _kEnabledBorder,
          focusedBorder: _kFocusedBorder,
        ),
        items: isLoading
            ? []
            : items.map((DropdownItemData<T> item) {
                return DropdownMenuItem<T>(
                  value: item.value,
                  child: Text(
                    item.label,
                    style: const TextStyle(fontSize: 13.5, color: Color(0xFF1E293B)),
                    overflow: TextOverflow.ellipsis,
                  ),
                );
              }).toList(),
        onChanged: isLoading ? null : onChanged,
      ),
    );
  }
}

class SearchableModalSelectorGeneric<T> extends StatelessWidget {
  final String hint;
  final T? value;
  final List<DropdownItemData<T>> items;
  final ValueChanged<T?> onChanged;
  final bool isLoading;
  final String title;

  const SearchableModalSelectorGeneric({
    super.key,
    required this.hint,
    required this.value,
    required this.items,
    required this.onChanged,
    required this.title,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    // Find selected item label
    final selectedItem = items.any((item) => item.value == value)
        ? items.firstWhere((item) => item.value == value)
        : null;

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: _kBorderRadius,
        border: Border.all(
          color: const Color(0xFFCBD5E1),
          width: 1.2,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x03000000), // black with 1% opacity
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: isLoading ? null : () => _showSearchModal(context),
        borderRadius: _kBorderRadius,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  isLoading
                      ? 'Memuat data...'
                      : (selectedItem != null ? selectedItem.label : hint),
                  style: TextStyle(
                    fontSize: 13.5,
                    color: isLoading
                        ? const Color(0xFF0F4C81)
                        : (selectedItem != null
                            ? const Color(0xFF1E293B)
                            : const Color(0xFF94A3B8)),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              if (isLoading)
                const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF0F4C81)),
                  ),
                )
              else
                const Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: Color(0xFF0F4C81),
                  size: 20,
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSearchModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return _SearchModalContent<T>(
          title: title,
          hint: hint,
          items: items,
          selectedValue: value,
          onSelected: (val) {
            onChanged(val);
            Navigator.pop(context);
          },
        );
      },
    );
  }
}

class _SearchModalContent<T> extends StatefulWidget {
  final String title;
  final String hint;
  final List<DropdownItemData<T>> items;
  final T? selectedValue;
  final ValueChanged<T> onSelected;

  const _SearchModalContent({
    super.key,
    required this.title,
    required this.hint,
    required this.items,
    required this.selectedValue,
    required this.onSelected,
  });

  @override
  State<_SearchModalContent<T>> createState() => _SearchModalContentState<T>();
}

class _SearchModalContentState<T> extends State<_SearchModalContent<T>> {
  late TextEditingController _searchController;
  List<DropdownItemData<T>> _filteredItems = [];

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _filteredItems = widget.items;
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchController.text.trim().toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredItems = widget.items;
      } else {
        _filteredItems = widget.items
            .where((item) => item.label.toLowerCase().contains(query))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final bottomInset = mediaQuery.viewInsets.bottom;
    final maxAvailableHeight = mediaQuery.size.height * 0.8;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.only(
        bottom: bottomInset,
      ),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: maxAvailableHeight,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: 10, bottom: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFE2E8F0),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      widget.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B),
                        fontFamily: 'Outfit',
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: Color(0xFF64748B)),
                    onPressed: () => Navigator.pop(context),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Container(
                decoration: const BoxDecoration(
                  color: Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
                child: TextField(
                  controller: _searchController,
                  autofocus: true,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF1E293B),
                  ),
                  decoration: InputDecoration(
                    hintText: 'Cari ${widget.title.toLowerCase()}...',
                    hintStyle: const TextStyle(
                      color: Color(0xFF94A3B8),
                      fontSize: 13.5,
                    ),
                    prefixIcon: const Icon(
                      Icons.search_rounded,
                      color: Color(0xFF94A3B8),
                      size: 20,
                    ),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(
                              Icons.clear_rounded,
                              color: Color(0xFF94A3B8),
                              size: 18,
                            ),
                            onPressed: () {
                              _searchController.clear();
                            },
                          )
                        : null,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Flexible(
              child: _filteredItems.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24.0,
                        vertical: 40.0,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.search_off_rounded,
                            size: 48,
                            color: Color(0xFFCBD5E1),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Data tidak ditemukan',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF64748B),
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Coba masukkan kata kunci yang berbeda',
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFF94A3B8),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    )
                  : ListView.separated(
                      shrinkWrap: true,
                      padding: const EdgeInsets.only(
                        left: 16,
                        right: 16,
                        bottom: 24,
                      ),
                      itemCount: _filteredItems.length,
                      separatorBuilder: (context, index) => const Divider(
                        height: 1,
                        color: Color(0xFFF1F5F9),
                      ),
                      itemBuilder: (context, index) {
                        final item = _filteredItems[index];
                        final isSelected = item.value == widget.selectedValue;

                        return InkWell(
                          onTap: () => widget.onSelected(item.value),
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 14,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? const Color(0xFF0F4C81).withOpacity(0.05)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    item.label,
                                    style: TextStyle(
                                      fontSize: 13.5,
                                      fontWeight: isSelected
                                          ? FontWeight.w600
                                          : FontWeight.normal,
                                      color: isSelected
                                          ? const Color(0xFF0F4C81)
                                          : const Color(0xFF1E293B),
                                    ),
                                  ),
                                ),
                                if (isSelected)
                                  const Icon(
                                    Icons.check_circle_rounded,
                                    color: Color(0xFF0F4C81),
                                    size: 18,
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
