// ============================================================================
// Jadwal List View
//
// Daftar jadwal dengan pull-to-refresh + pagination (load more). Diekstrak
// dari jadwal_screen.dart.
// ============================================================================

import 'package:flutter/material.dart';

import '../../models/jadwal_models.dart';
import '../../screens/jadwal/jadwal_detail_screen.dart';
import 'jadwal_list_item.dart';

class JadwalListView extends StatelessWidget {
  final List<JadwalItem> items;
  final ScrollController controller;
  final bool hasMore;
  final bool isLoadingMore;
  final bool showCreatedDate;
  final UserRole userRole;
  final Future<void> Function() onRefresh;
  final void Function() onItemUpdated;

  const JadwalListView({
    super.key,
    required this.items,
    required this.controller,
    required this.hasMore,
    required this.isLoadingMore,
    this.showCreatedDate = false,
    required this.userRole,
    required this.onRefresh,
    required this.onItemUpdated,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return RefreshIndicator(
        onRefresh: onRefresh,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: SizedBox(
            height: MediaQuery.of(context).size.height - 300,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: const BoxDecoration(
                      color: Color(0xFFE5F1FC),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.event_busy_rounded,
                      color: Color(0xFF2C6C9C),
                      size: 36,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Tidak ada jadwal',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView.builder(
        controller: controller,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        itemCount: items.length + 1, // +1 for loading indicator
        itemBuilder: (context, index) {
          // Loading indicator at the end
          if (index == items.length) {
            if (isLoadingMore) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Center(child: CircularProgressIndicator()),
              );
            } else if (!hasMore) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Center(
                  child: Text(
                    'Tidak ada data lagi',
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ),
              );
            } else {
              return const SizedBox(height: 80);
            }
          }

          // List items
          final item = items[index];
          return Padding(
            padding: EdgeInsets.only(bottom: index < items.length - 1 ? 8 : 0),
            child: JadwalListItem(
              key: ValueKey(item.id),
              item: item,
              showCreatedDate: showCreatedDate,
              onTap: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        JadwalDetailScreen(jadwal: item, userRole: userRole),
                  ),
                );

                // Refresh data if status was updated
                if (result == true) {
                  onItemUpdated();
                }
              },
            ),
          );
        },
      ),
    );
  }
}
