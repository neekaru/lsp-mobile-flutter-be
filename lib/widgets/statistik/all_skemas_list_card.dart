import 'package:flutter/material.dart';
import '../../models/dashboard_models.dart';

class AllSkemasListCard extends StatelessWidget {
  final List<SebaranSkemaAsesorItem> sebaranSkemaAsesorList;
  final bool isLoading;
  final String searchQuery;
  final ValueChanged<SebaranSkemaAsesorItem> onSelectSkema;

  const AllSkemasListCard({
    super.key,
    required this.sebaranSkemaAsesorList,
    required this.isLoading,
    required this.searchQuery,
    required this.onSelectSkema,
  });

  @override
  Widget build(BuildContext context) {
    final filteredList = sebaranSkemaAsesorList.where((item) {
      return item.skema.toLowerCase().contains(searchQuery.toLowerCase()) ||
          item.kodeSkema.toLowerCase().contains(searchQuery.toLowerCase());
    }).toList();

    return Padding(
      padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 8.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: const [
            BoxShadow(
              color: Color(0x05000000),
              blurRadius: 6,
              offset: Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Daftar Sebaran Skema & Asesor',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            if (isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: Color(0xFF2C6C9C),
                  ),
                ),
              )
            else if (filteredList.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Text('Tidak ada skema yang cocok dengan pencarian.'),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: filteredList.length > 8 ? 8 : filteredList.length,
                itemBuilder: (context, index) {
                  final item = filteredList[index];
                  return Column(
                    children: [
                      Material(
                        color: Colors.transparent,
                        child: ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(
                            item.skema,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: Text(
                            item.kodeSkema,
                            style: const TextStyle(
                              fontSize: 11,
                              color: Colors.grey,
                            ),
                          ),
                          trailing: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE5F1FC),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '${item.jumlahAsesor} Asesor',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF2C6C9C),
                              ),
                            ),
                          ),
                          onTap: () => onSelectSkema(item),
                        ),
                      ),
                      Divider(
                          height: 1, thickness: 0.5, color: Colors.grey[200]),
                    ],
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}
