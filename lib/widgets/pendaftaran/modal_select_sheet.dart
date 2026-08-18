import 'package:material_ui/material_ui.dart';

/// Bottom sheet modal untuk memilih item dari list (dengan pencarian opsional).
class ModalSelectSheet<T> extends StatefulWidget {
  final String title;
  final List<T>? items;
  final Future<List<T>> Function()? fetchItems;
  final String Function(T item) labelOf;
  final String currentSelectedLabel;
  final ValueChanged<T> onSelected;
  final bool showSearch;

  const ModalSelectSheet({
    super.key,
    required this.title,
    this.items,
    this.fetchItems,
    required this.labelOf,
    required this.currentSelectedLabel,
    required this.onSelected,
    this.showSearch = false,
  });

  @override
  State<ModalSelectSheet<T>> createState() => _ModalSelectSheetState<T>();
}

class _ModalSelectSheetState<T> extends State<ModalSelectSheet<T>> {
  List<T> _allItems = [];
  List<T> _filteredItems = [];
  bool _isLoading = false;
  String _errorMessage = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.items != null) {
      _allItems = List.from(widget.items!);
      _filteredItems = List.from(_allItems);
    } else if (widget.fetchItems != null) {
      _loadData();
    }
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });
    try {
      final res = await widget.fetchItems!();
      if (!mounted) return;
      // Auto-select jika hanya 1 item
      if (res.length == 1) {
        widget.onSelected(res.first);
        return;
      }
      setState(() {
        _allItems = res;
        _filteredItems = List.from(res);
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = 'Gagal memuat data: $e';
      });
    }
  }

  void _onSearchChanged(String query) {
    if (query.isEmpty) {
      setState(() {
        _filteredItems = List.from(_allItems);
      });
    } else {
      final q = query.toLowerCase();
      setState(() {
        _filteredItems = _allItems.where((item) {
          final label = widget.labelOf(item).toLowerCase();
          return label.contains(q);
        }).toList();
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.3,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) {
        final mediaQuery = MediaQuery.of(context);
        final double keyboardHeight = mediaQuery.viewInsets.bottom;

        return Container(
          padding: EdgeInsets.only(bottom: keyboardHeight),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag Handle Indicator
              Center(
                child: Container(
                  margin: const EdgeInsets.only(top: 8, bottom: 4),
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFCBD5E1),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // Header Bar
              Padding(
                padding: const EdgeInsets.only(
                  left: 16,
                  right: 8,
                  top: 4,
                  bottom: 8,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      widget.title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.close,
                        color: Color(0xFF64748B),
                        size: 20,
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, color: Color(0xFFE2E8F0)),

              // Search field if requested or if item count > 8
              if (widget.showSearch || _allItems.length > 8)
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: _onSearchChanged,
                    style: const TextStyle(fontSize: 13),
                    decoration: InputDecoration(
                      hintText: 'Cari...',
                      prefixIcon: const Icon(
                        Icons.search,
                        size: 18,
                        color: Color(0xFF94A3B8),
                      ),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(
                                Icons.clear,
                                size: 16,
                                color: Color(0xFF94A3B8),
                              ),
                              onPressed: () {
                                _searchController.clear();
                                _onSearchChanged('');
                              },
                            )
                          : null,
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      filled: true,
                      fillColor: const Color(0xFFF8FAFC),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Color(0xFF3B82F6)),
                      ),
                    ),
                  ),
                ),

              // Content body
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _errorMessage.isNotEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                _errorMessage,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: Colors.red,
                                  fontSize: 13,
                                ),
                              ),
                              const SizedBox(height: 8),
                              ElevatedButton(
                                onPressed: _loadData,
                                child: const Text('Coba Lagi'),
                              ),
                            ],
                          ),
                        ),
                      )
                    : _filteredItems.isEmpty
                    ? const Center(
                        child: Padding(
                          padding: EdgeInsets.all(20.0),
                          child: Text(
                            'Data tidak ditemukan',
                            style: TextStyle(
                              color: Color(0xFF94A3B8),
                              fontSize: 13,
                            ),
                          ),
                        ),
                      )
                    : ListView.separated(
                        controller: scrollController,
                        physics: const AlwaysScrollableScrollPhysics(),
                        itemCount: _filteredItems.length,
                        separatorBuilder: (context, index) =>
                            const Divider(height: 1, color: Color(0xFFF1F5F9)),
                        itemBuilder: (context, index) {
                          final item = _filteredItems[index];
                          final label = widget.labelOf(item);
                          final isSelected =
                              label.toLowerCase() ==
                              widget.currentSelectedLabel.toLowerCase();

                          return Material(
                            color: Colors.transparent,
                            child: ListTile(
                              dense: true,
                              title: Text(
                                label,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                  color: isSelected
                                      ? const Color(0xFF3B82F6)
                                      : const Color(0xFF0F172A),
                                ),
                              ),
                              trailing: isSelected
                                  ? const Icon(
                                      Icons.check_rounded,
                                      color: Color(0xFF3B82F6),
                                      size: 18,
                                    )
                                  : null,
                              onTap: () => widget.onSelected(item),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}
