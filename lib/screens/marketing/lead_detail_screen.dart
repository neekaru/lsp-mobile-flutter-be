import 'package:material_ui/material_ui.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/lead_model.dart';
import '../../services/auth/auth_repository.dart';
import '../../services/marketing/lead_storage_service.dart';
import '../../services/marketing/proposal_generator_service.dart';
import '../../widgets/common/custom_app_bar.dart';
import 'proposal_preview_screen.dart';
import 'widgets/lead_status_badge.dart';

class LeadDetailScreen extends StatefulWidget {
  final LeadModel lead;
  final Function(LeadModel updatedLead)? onLeadUpdated;

  const LeadDetailScreen({
    super.key,
    required this.lead,
    this.onLeadUpdated,
  });

  @override
  State<LeadDetailScreen> createState() => _LeadDetailScreenState();
}

class _LeadDetailScreenState extends State<LeadDetailScreen> {
  late LeadModel _currentLead;
  bool _isAnalyzing = false;
  final TextEditingController _catatanController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _currentLead = widget.lead;
    _catatanController.text = _currentLead.catatan;
  }

  @override
  void dispose() {
    _catatanController.dispose();
    super.dispose();
  }

  Future<void> _updateStatus(String newStatus) async {
    final updated = _currentLead.copyWith(leadStatus: newStatus);
    setState(() {
      _currentLead = updated;
    });
    await LeadStorageService.updateLeadData(updated);
    widget.onLeadUpdated?.call(updated);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Tahapan diubah ke: ${newStatus.toUpperCase()}'),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _handleSaveCatatan() async {
    final updated = _currentLead.copyWith(catatan: _catatanController.text.trim());
    setState(() {
      _currentLead = updated;
    });
    await LeadStorageService.updateLeadData(updated);
    widget.onLeadUpdated?.call(updated);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Catatan berhasil disimpan'),
          duration: Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _handleRegenerateAi() async {
    setState(() {
      _isAnalyzing = true;
    });
    final updated = await LeadStorageService.generateAiPotensi(_currentLead);
    setState(() {
      _currentLead = updated;
      _isAnalyzing = false;
    });
    await LeadStorageService.updateLeadData(updated);
    widget.onLeadUpdated?.call(updated);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Analisis potensi AI berhasil diperbarui'),
          duration: Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _openWhatsApp() async {
    final asesorName =
        AuthRepository.currentUserInstance?.name ?? 'Muhammad Hanafi';
    final message = ProposalGeneratorService.generateWhatsAppPitchText(
      lead: _currentLead,
      asesorName: asesorName,
    );

    // Format phone number
    String phone = _currentLead.telepon.replaceAll(RegExp(r'[^0-9]'), '');
    if (phone.startsWith('0')) {
      phone = '62${phone.substring(1)}';
    }

    final url =
        'https://wa.me/$phone?text=${Uri.encodeComponent(message)}';
    final uri = Uri.parse(url);

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tidak dapat membuka aplikasi WhatsApp')),
        );
      }
    }
  }

  Future<void> _makePhoneCall() async {
    final phone = _currentLead.telepon.replaceAll(RegExp(r'[^0-9+]'), '');
    if (phone.isEmpty) return;
    final uri = Uri.parse('tel:$phone');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _openMap() async {
    final uri = Uri.parse(
        'https://www.google.com/maps/search/?api=1&query=${_currentLead.latitude},${_currentLead.longitude}');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  void _showEditPicDialog() {
    final picNameCtrl = TextEditingController(text: _currentLead.picName);
    final phoneCtrl = TextEditingController(text: _currentLead.telepon);
    final emailCtrl = TextEditingController(text: _currentLead.email);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Edit Kontak PIC',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: picNameCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Nama PIC / Kaprodi',
                    hintText: 'Contoh: Drs. Budi Santoso (Kaprodi TKJ)',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: phoneCtrl,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: 'Nomor Telepon / WhatsApp',
                    hintText: '0853-xxxx-xxxx',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Email Institusi / PIC',
                    hintText: 'info@sekolah.sch.id',
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () async {
                final updated = _currentLead.copyWith(
                  picName: picNameCtrl.text.trim(),
                  telepon: phoneCtrl.text.trim(),
                  email: emailCtrl.text.trim(),
                );
                setState(() {
                  _currentLead = updated;
                });
                await LeadStorageService.updateLeadData(updated);
                widget.onLeadUpdated?.call(updated);
                if (context.mounted) Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2563EB),
                foregroundColor: Colors.white,
              ),
              child: const Text('Simpan'),
            ),
          ],
        );
      },
    );
  }

  void _confirmDelete() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Hapus Prospek?',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          content: Text(
              'Apakah Anda yakin ingin menghapus "${_currentLead.namaInstitusi}" dari daftar prospek Anda?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () async {
                await LeadStorageService.deleteLead(
                    _currentLead.idAsesor, _currentLead.id);
                if (context.mounted) {
                  Navigator.pop(context); // Close dialog
                  Navigator.pop(context); // Back to previous screen
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFEF4444),
                foregroundColor: Colors.white,
              ),
              child: const Text('Hapus'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final double statusBarHeight = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Column(
        children: [
          SizedBox(height: statusBarHeight + 8),
          CustomAppBar(
            title: 'Detail Prospek',
            onBack: () => Navigator.pop(context),
            rightWidget: IconButton(
              icon: const Icon(Icons.delete_outline_rounded,
                  color: Color(0xFFEF4444)),
              onPressed: _confirmDelete,
              tooltip: 'Hapus Prospek',
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top Card Profile
                  _buildHeaderCard(),
                  const SizedBox(height: 14),

                  // Pipeline Stage Stepper
                  _buildPipelineStageSelector(),
                  const SizedBox(height: 14),

                  // Contact & PIC Section
                  _buildPicCard(),
                  const SizedBox(height: 14),

                  // AI Potential & Scheme Recommendation
                  _buildAiPotentialCard(),
                  const SizedBox(height: 14),

                  // Notes / Activity Log
                  _buildNotesCard(),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
          // Bottom Sticky Bar: Direct WA & Proposal Button
          _buildBottomActionBar(),
        ],
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
              color: Color(0x06000000), blurRadius: 8, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _currentLead.leadKategori,
                  style: const TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2563EB),
                  ),
                ),
              ),
              const Spacer(),
              LeadStatusBadge(status: _currentLead.leadStatus),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            _currentLead.namaInstitusi,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 6),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.location_on_rounded,
                  size: 16, color: Color(0xFF64748B)),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  _currentLead.leadLocation,
                  style:
                      const TextStyle(fontSize: 12.5, color: Color(0xFF64748B)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Directions Button
          InkWell(
            onTap: _openMap,
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.directions_rounded,
                      size: 16, color: Color(0xFF2563EB)),
                  SizedBox(width: 6),
                  Text(
                    'Buka di Google Maps',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2563EB),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPipelineStageSelector() {
    final stages = [
      {'key': 'lead', 'label': 'Lead'},
      {'key': 'prospek', 'label': 'Proposal'},
      {'key': 'interest', 'label': 'Follow Up'},
      {'key': 'sales', 'label': 'Deal / MoU'},
    ];

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Tahapan Prospek',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: stages.map((s) {
              final isCurrent = _currentLead.leadStatus.toLowerCase() ==
                  s['key']!.toLowerCase();
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: InkWell(
                    onTap: () => _updateStatus(s['key']!),
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: isCurrent
                            ? const Color(0xFF2563EB)
                            : const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        s['label']!,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight:
                              isCurrent ? FontWeight.bold : FontWeight.w500,
                          color:
                              isCurrent ? Colors.white : const Color(0xFF475569),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildPicCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.badge_rounded,
                  size: 18, color: Color(0xFF2563EB)),
              const SizedBox(width: 8),
              const Text(
                'Kontak PIC & Institusi',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A),
                ),
              ),
              const Spacer(),
              TextButton.icon(
                onPressed: _showEditPicDialog,
                icon: const Icon(Icons.edit_rounded, size: 14),
                label: const Text('Edit PIC', style: TextStyle(fontSize: 12)),
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: const Size(50, 30),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
            ],
          ),
          const Divider(height: 16),
          _buildInfoRow(
            icon: Icons.person_rounded,
            title: 'Nama PIC',
            value: _currentLead.picName.isNotEmpty
                ? _currentLead.picName
                : 'Belum diisi (Klik Edit PIC)',
          ),
          const SizedBox(height: 8),
          _buildInfoRow(
            icon: Icons.phone_rounded,
            title: 'No. Telepon / WA',
            value: _currentLead.telepon.isNotEmpty
                ? _currentLead.telepon
                : 'Belum diisi',
            onTap: _currentLead.telepon.isNotEmpty ? _makePhoneCall : null,
          ),
          const SizedBox(height: 8),
          _buildInfoRow(
            icon: Icons.email_rounded,
            title: 'Email',
            value: _currentLead.email.isNotEmpty
                ? _currentLead.email
                : 'Belum diisi',
          ),
        ],
      ),
    );
  }

  Widget _buildAiPotentialCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFDBEAFE)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.auto_awesome_rounded,
                  size: 18, color: Color(0xFF2563EB)),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Analisis Potensi Uji Kompetensi (AI)',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                ),
              ),
              IconButton(
                onPressed: _isAnalyzing ? null : _handleRegenerateAi,
                icon: _isAnalyzing
                    ? const SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.refresh_rounded,
                        size: 18, color: Color(0xFF2563EB)),
                tooltip: 'Hitung Ulang AI',
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.groups_rounded,
                        size: 16, color: Color(0xFF2563EB)),
                    const SizedBox(width: 6),
                    const Text(
                      'Estimasi Potensi Asesi:',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF475569),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '±${_currentLead.estimasiSiswa} Siswa/Th',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2563EB),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  _currentLead.leadPotensi.isNotEmpty
                      ? _currentLead.leadPotensi
                      : 'Potensi program sertifikasi profesi BNSP dengan estimasi kuota peserta tahunan.',
                  style: const TextStyle(
                    fontSize: 12.5,
                    color: Color(0xFF334155),
                    height: 1.4,
                  ),
                ),
                if (_currentLead.jurusanList.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: _currentLead.jurusanList.map((j) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEFF6FF),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          j,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF1D4ED8),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotesCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Catatan & Log Aktivitas Asesor',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _catatanController,
            maxLines: 3,
            decoration: InputDecoration(
              hintText:
                  'Tambahkan catatan follow up (contoh: sudah kirim proposal via email, jadwal meeting Kamis jam 10.00)...',
              hintStyle:
                  const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
              filled: true,
              fillColor: const Color(0xFFF8FAFC),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton(
              onPressed: _handleSaveCatatan,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2563EB),
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Simpan Catatan',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String title,
    required String value,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: const Color(0xFF64748B)),
          const SizedBox(width: 8),
          SizedBox(
            width: 100,
            child: Text(
              title,
              style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: onTap != null
                    ? const Color(0xFF2563EB)
                    : const Color(0xFF1E293B),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActionBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFE2E8F0))),
        boxShadow: [
          BoxShadow(
              color: Color(0x0A000000), blurRadius: 8, offset: Offset(0, -2)),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            // WhatsApp Button
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _openWhatsApp,
                icon: const Icon(Icons.chat_rounded, size: 18),
                label: const Text('Pitching WA',
                    style:
                        TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF16A34A),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            // Proposal Button
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          ProposalPreviewScreen(lead: _currentLead),
                    ),
                  );
                },
                icon: const Icon(Icons.description_rounded, size: 18),
                label: const Text('Proposal LSP',
                    style:
                        TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

