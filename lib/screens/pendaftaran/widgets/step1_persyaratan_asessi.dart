// ignore_for_file: deprecated_member_use
import 'package:material_ui/material_ui.dart';
import '../../../services/asesi/permohonan_service.dart';

class Step1PersyaratanAsessi extends StatefulWidget {
  final int? permohonanId;

  const Step1PersyaratanAsessi({
    super.key,
    this.permohonanId,
  });

  @override
  State<Step1PersyaratanAsessi> createState() => _Step1PersyaratanAsessiState();
}

class _Step1PersyaratanAsessiState extends State<Step1PersyaratanAsessi> {
  List<Map<String, String>> _persyaratanDasarList = [];
  List<Map<String, String>> _persyaratanAdministrasiList = [];

  @override
  void initState() {
    super.initState();
    _loadStep1Data();
  }

  Future<void> _loadStep1Data() async {
    final id = widget.permohonanId ?? 251343;
    final realItems = await PermohonanService.getStep1Data(id);
    if (!mounted) return;
    if (realItems.isNotEmpty) {
      setState(() {
        _persyaratanDasarList = realItems.where((e) => e['jenis'] == 'pendidikan' || e['jenis'] == 'dasar').toList();
        _persyaratanAdministrasiList = realItems.where((e) => e['jenis'] != 'pendidikan' && e['jenis'] != 'dasar').toList();
        if (_persyaratanDasarList.isEmpty) {
          _persyaratanAdministrasiList = realItems;
        }
      });
    }
  }

  void _showPilihStatusModal(
    BuildContext context,
    String currentStatus,
    Function(String newStatus) onSelectStatus,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        String tempStatus = currentStatus;
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Material 3 drag handle pill
                  Center(
                    child: Container(
                      width: 36,
                      height: 4,
                      decoration: BoxDecoration(
                        color: const Color(0xFFCBD5E1),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Pilih Status',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildStatusRadioTile(
                    label: 'Memenuhi Syarat',
                    value: 'Memenuhi Syarat',
                    groupValue: tempStatus,
                    onChanged: (val) {
                      setModalState(() => tempStatus = val!);
                      onSelectStatus(val!);
                      Navigator.pop(context);
                    },
                  ),
                  _buildStatusRadioTile(
                    label: 'Tidak Memenuhi Syarat',
                    value: 'Tidak Memenuhi Syarat',
                    groupValue: tempStatus,
                    onChanged: (val) {
                      setModalState(() => tempStatus = val!);
                      onSelectStatus(val!);
                      Navigator.pop(context);
                    },
                  ),
                  _buildStatusRadioTile(
                    label: 'Tidak Ada',
                    value: 'Tidak Ada',
                    groupValue: tempStatus,
                    onChanged: (val) {
                      setModalState(() => tempStatus = val!);
                      onSelectStatus(val!);
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildStatusRadioTile({
    required String label,
    required String value,
    required String groupValue,
    required ValueChanged<String?> onChanged,
  }) {
    final isSelected = value == groupValue;
    return InkWell(
      onTap: () => onChanged(value),
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 6.0),
        child: Row(
          children: [
            Radio<String>(
              value: value,
              groupValue: groupValue,
              activeColor: const Color(0xFF3B82F6),
              onChanged: onChanged,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 15,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: const Color(0xFF0F172A),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDocumentCard({
    required Map<String, String> doc,
    required Function(String newStatus) onStatusChanged,
  }) {
    final status = doc['status'] ?? 'Memenuhi Syarat';

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFAFAFA),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 36,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: const Color(0xFFCBD5E1)),
                ),
                child: const Center(
                  child: Icon(
                    Icons.article_outlined,
                    color: Color(0xFF3B82F6),
                    size: 24,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      doc['title'] ?? '',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F172A),
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'File : ${doc['file'] ?? ''}',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF3B82F6),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Text(
            'Status',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 6),
          GestureDetector(
            onTap: () => _showPilihStatusModal(context, status, onStatusChanged),
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFCBD5E1)),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: const BoxDecoration(
                      color: Color(0xFF3B82F6),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      status,
                      style: const TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                  ),
                  const Icon(
                    Icons.chevron_right_rounded,
                    color: Color(0xFF64748B),
                    size: 18,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddDocumentButton(VoidCallback onPressed) {
    return SizedBox(
      width: double.infinity,
      height: 40,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF60A5FA),
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        icon: const Icon(Icons.add_rounded, size: 18),
        label: const Text(
          'Tambah Dokumen',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: const Color(0xFFD1FAE5),
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: const Center(
            child: Text(
              'Dokumen Persyaratan Asesi',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Color(0xFF10B981),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'PERSYARATAN DASAR',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: Color(0xFF0F172A),
            letterSpacing: 0.2,
          ),
        ),
        const SizedBox(height: 10),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _persyaratanDasarList.length,
          separatorBuilder: (context, index) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            final doc = _persyaratanDasarList[index];
            return _buildDocumentCard(
              doc: doc,
              onStatusChanged: (newStatus) {
                setState(() {
                  _persyaratanDasarList[index]['status'] = newStatus;
                });
              },
            );
          },
        ),
        const SizedBox(height: 12),
        _buildAddDocumentButton(() {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Fitur Tambah Dokumen Dasar'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }),
        const SizedBox(height: 20),
        const Text(
          'PERSYARATAN ADMINISTRASI',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: Color(0xFF0F172A),
            letterSpacing: 0.2,
          ),
        ),
        const SizedBox(height: 10),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _persyaratanAdministrasiList.length,
          separatorBuilder: (context, index) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            final doc = _persyaratanAdministrasiList[index];
            return _buildDocumentCard(
              doc: doc,
              onStatusChanged: (newStatus) {
                setState(() {
                  _persyaratanAdministrasiList[index]['status'] = newStatus;
                });
              },
            );
          },
        ),
        const SizedBox(height: 12),
        _buildAddDocumentButton(() {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Fitur Tambah Dokumen Administrasi'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }),
        const SizedBox(height: 16),
      ],
    );
  }
}
