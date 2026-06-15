class MasterItem {
  final String id;
  final String name;

  const MasterItem({
    required this.id,
    required this.name,
  });

  factory MasterItem.fromJson(Map<String, dynamic> json) {
    return MasterItem(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
    );
  }
}
