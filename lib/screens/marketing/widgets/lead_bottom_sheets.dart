// ============================================================================
// Bottom sheet Lead Generator: form tambah/simpan lead & detail lead.
// Diekstrak dari lead_generator_screen.dart.
// ============================================================================

import 'package:material_ui/material_ui.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../models/lead_model.dart';
import '../../../services/marketing/lead_storage_service.dart';
import 'lead_helpers.dart';

void _openLeadInGoogleMaps(LeadModel lead) async {
  final query = Uri.encodeComponent('${lead.namaInstitusi}, ${lead.leadLocation}');
  final url = 'https://www.google.com/maps/search/?api=1&query=$query';
  final uri = Uri.parse(url);
  if (await canLaunchUrl(uri)) {
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}

// ── FORM TAMBAH / SIMPAN LEAD ──────────────────────────────────────────────
Future<void> showAddLeadSheet(
  BuildContext context, {
  required int idAsesor,
  required List<String> kategoriList,
  required String defaultKabupaten,
  String defaultKategori = 'SMK',
  String defaultName = '',
  required Future<void> Function() onSaved,
}) async {
  final namaCtrl = TextEditingController(text: defaultName);
  final lokasiCtrl = TextEditingController();
  final kabCtrl = TextEditingController(text: defaultKabupaten);
  final descCtrl = TextEditingController();
  String kategori = defaultKategori;
  String status = 'lead';

  await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (ctx) {
      return StatefulBuilder(
        builder: (context, setModalState) {
          return Padding(
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 20,
              bottom: MediaQuery.of(context).viewInsets.bottom + 20,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Simpan Lead ke Database Lokal',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(ctx),
                        icon: const Icon(Icons.close_rounded),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: namaCtrl,
                    decoration: InputDecoration(
                      labelText: 'Nama Institusi / Sekolah / Mitra',
                      hintText: 'Contoh: SMK Negeri 2 Surabaya',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    ),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: kategori,
                    decoration: InputDecoration(
                      labelText: 'Kategori Lead',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    ),
                    items: kategoriList
                        .where((e) => e != 'Semua')
                        .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                    onChanged: (v) {
                      if (v != null) setModalState(() => kategori = v);
                    },
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: lokasiCtrl,
                    decoration: InputDecoration(
                      labelText: 'Alamat Lokasi (Google Maps)',
                      hintText: 'Jl. Pemuda No. 10...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: kabCtrl,
                    decoration: InputDecoration(
                      labelText: 'Kabupaten / Kota',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: descCtrl,
                    maxLines: 2,
                    decoration: InputDecoration(
                      labelText: 'Deskripsi / Potensi Kerjasama',
                      hintText: 'Keterangan awal institusi...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    ),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: status,
                    decoration: InputDecoration(
                      labelText: 'Status Lead',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    ),
                    items: ['lead', 'prospek', 'interest', 'sales']
                        .map((e) => DropdownMenuItem(
                              value: e,
                              child: Text(formatLeadStatus(e)),
                            ))
                        .toList(),
                    onChanged: (v) {
                      if (v != null) setModalState(() => status = v);
                    },
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        if (namaCtrl.text.trim().isEmpty) return;
                        final newLead = LeadModel(
                          id: 'lead-${DateTime.now().millisecondsSinceEpoch}',
                          idAsesor: idAsesor,
                          namaInstitusi: namaCtrl.text.trim(),
                          leadKategori: kategori,
                          leadLocation: lokasiCtrl.text.trim().isNotEmpty
                              ? lokasiCtrl.text.trim()
                              : kabCtrl.text.trim(),
                          kabupaten: kabCtrl.text.trim(),
                          leadDescription: descCtrl.text.trim(),
                          leadStatus: status,
                          updatedAt: DateTime.now(),
                        );
                        Navigator.pop(ctx);
                        await LeadStorageService.saveLead(newLead);
                        await onSaved();
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Lead baru berhasil disimpan ke database lokal!'),
                              backgroundColor: Color(0xFF16A34A),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        }
                      },
                      icon: const Icon(LucideIcons.plus, size: 18),
                      label: const Text(
                        'Simpan ke Database Lokal',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2563EB),
                        foregroundColor: Colors.white,
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
        },
      );
    },
  );
}

// ── DETAIL LEAD ────────────────────────────────────────────────────────────
void showLeadDetailSheet(
  BuildContext context, {
  required LeadModel lead,
  required Future<void> Function(LeadModel lead, String newStatus) onChangeStatus,
  required Future<void> Function(LeadModel lead) onRunAi,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (ctx) {
      return StatefulBuilder(
        builder: (context, setModalState) {
          return Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: const Color(0xFFCBD5E1),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: leadCategoryColor(lead.leadKategori).withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          leadCategoryIcon(lead.leadKategori),
                          color: leadCategoryColor(lead.leadKategori),
                          size: 26,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              lead.namaInstitusi,
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF0F172A),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF1F5F9),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    lead.leadKategori,
                                    style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF475569),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: leadStatusColor(lead.leadStatus).withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    formatLeadStatus(lead.leadStatus),
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: leadStatusColor(lead.leadStatus),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Row(
                      children: [
                        const Icon(LucideIcons.map_pin, size: 18, color: Color(0xFF64748B)),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            lead.leadLocation,
                            style: const TextStyle(
                              fontSize: 13,
                              color: Color(0xFF334155),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  _buildPotensiAiCard(lead),
                  const SizedBox(height: 16),
                  const Text(
                    'Perbarui Status Lead:',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF334155),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: ['lead', 'prospek', 'interest', 'sales'].map((st) {
                      final isSel = lead.leadStatus == st;
                      return Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 3),
                          child: ChoiceChip(
                            label: Center(
                              child: Text(
                                formatLeadStatus(st),
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: isSel ? FontWeight.bold : FontWeight.w500,
                                  color: isSel ? Colors.white : const Color(0xFF475569),
                                ),
                              ),
                            ),
                            selected: isSel,
                            selectedColor: leadStatusColor(st),
                            backgroundColor: const Color(0xFFF1F5F9),
                            showCheckmark: false,
                            onSelected: (_) {
                              Navigator.pop(ctx);
                              onChangeStatus(lead, st);
                            },
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _openLeadInGoogleMaps(lead),
                          icon: const Icon(LucideIcons.map_pin, size: 16),
                          label: const Text('Buka Maps'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFF2563EB),
                            side: const BorderSide(color: Color(0xFF2563EB)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.pop(ctx);
                            onRunAi(lead);
                          },
                          icon: const Icon(Icons.auto_awesome_rounded, size: 16),
                          label: const Text('AI Analisis'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF16A34A),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}

Widget _buildPotensiAiCard(LeadModel lead) {
  return Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFFEFF6FF), Color(0xFFF0FDF4)],
      ),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: const Color(0xFFBFDBFE)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.auto_awesome_rounded, color: Color(0xFF2563EB), size: 18),
            const SizedBox(width: 6),
            const Text(
              'Analisis Potensi AI',
              style: TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E40AF),
              ),
            ),
            const Spacer(),
            if (lead.estimasiSiswa > 0)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFF16A34A),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '±${lead.estimasiSiswa} Siswa/Thn',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          lead.leadPotensi.isNotEmpty
              ? lead.leadPotensi
              : 'Klik tombol "AI Analisis" untuk mengestimasi jumlah siswa dan pemetaan skema kejuruan yang cocok.',
          style: const TextStyle(
            fontSize: 12.5,
            height: 1.45,
            color: Color(0xFF1E293B),
          ),
        ),
        if (lead.jurusanList.isNotEmpty) ...[
          const SizedBox(height: 10),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: lead.jurusanList.map((j) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: const Color(0xFF93C5FD)),
                ),
                child: Text(
                  j,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1D4ED8),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ],
    ),
  );
}
