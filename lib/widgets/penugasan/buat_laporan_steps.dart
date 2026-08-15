import 'dart:async';

import 'package:flutter/material.dart';

import 'participant_widgets.dart';

// ============================================================================
// Step widgets untuk BuatLaporanScreen
//
// Form step 1-4 diekstrak dari buat_laporan_screen.dart agar file screen
// tetap ringkas. Semua state tetap dimiliki oleh screen; widget ini hanya
// menerima data + callback.
// ============================================================================

class BuatLaporanStep1Form extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController nameController;
  final TextEditingController linkController;
  final String selectedSkema;
  final String selectedDate;
  final String? uploadedFileName;
  final VoidCallback onSelectSkema;
  final VoidCallback onPickSuratTugas;
  final ValueChanged<DateTime> onDatePicked;
  final ValueChanged<String> onLinkChanged;

  const BuatLaporanStep1Form({
    super.key,
    required this.formKey,
    required this.nameController,
    required this.linkController,
    required this.selectedSkema,
    required this.selectedDate,
    required this.uploadedFileName,
    required this.onSelectSkema,
    required this.onPickSuratTugas,
    required this.onDatePicked,
    required this.onLinkChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Nama Lengkap',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: nameController,
            decoration: InputDecoration(
              hintText: 'Masukan nama lengkap anda',
              fillColor: Colors.white,
              filled: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Nama lengkap tidak boleh kosong';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),

          const Text(
            'Skema Sertifikasi (TUK)',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: onSelectSkema,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      selectedSkema,
                      style: const TextStyle(
                        color: Color(0xFF1E293B),
                        fontSize: 14,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(
                    Icons.chevron_right_rounded,
                    color: Color(0xFF94A3B8),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          const Row(
            children: [
              Icon(
                Icons.calendar_today_outlined,
                size: 16,
                color: Color(0xFF64748B),
              ),
              SizedBox(width: 6),
              Text(
                'Tanggal Pelaksanaan',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime(2020),
                lastDate: DateTime(2030),
              );
              if (picked != null) {
                onDatePicked(picked);
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    selectedDate.isEmpty ? 'Pilih tanggal' : selectedDate,
                    style: TextStyle(
                      color: selectedDate.isEmpty
                          ? const Color(0xFF94A3B8)
                          : const Color(0xFF1E293B),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          const Text(
            'Unggah Surat Tugas',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 8),
          InkWell(
            onTap: onPickSuratTugas,
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    uploadedFileName ?? 'Pilih Surat Tugas',
                    style: TextStyle(
                      color: uploadedFileName != null
                          ? const Color(0xFF1E293B)
                          : const Color(0xFF94A3B8),
                      fontSize: 14,
                    ),
                  ),
                  const Icon(
                    Icons.cloud_upload_outlined,
                    color: Color(0xFF94A3B8),
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Surat tugas harus PDF minimal 2 mb.',
            style: TextStyle(
              color: Color(0xFF0D9488),
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 20),

          const Text(
            'Link Dokumentasi',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: linkController,
            onChanged: onLinkChanged,
            style: const TextStyle(fontSize: 14, color: Color(0xFF1E293B)),
            decoration: InputDecoration(
              hintText: 'Unggah link dokumentasi',
              hintStyle: const TextStyle(
                fontSize: 14,
                color: Color(0xFF94A3B8),
              ),
              fillColor: Colors.white,
              filled: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
          ),
          if (linkController.text.isNotEmpty) ...[
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: GestureDetector(
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Membuka ${linkController.text}...'),
                      ),
                    );
                  },
                  child: Text(
                    '🔗 ${linkController.text}',
                    style: const TextStyle(
                      color: Color(0xFF2563EB),
                      decoration: TextDecoration.underline,
                      fontWeight: FontWeight.w500,
                      fontSize: 12,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ),
          ],
          const SizedBox(height: 6),
          const Text(
            'Bukti dokumentasi berupa link video/foto.',
            style: TextStyle(
              color: Color(0xFF0D9488),
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class BuatLaporanStep2Form extends StatefulWidget {
  final List<ParticipantItem> participants;
  final String selectedSkema;
  final TextEditingController searchController;
  final ValueChanged<String> onSearchChanged;

  const BuatLaporanStep2Form({
    super.key,
    required this.participants,
    required this.selectedSkema,
    required this.searchController,
    required this.onSearchChanged,
  });

  @override
  State<BuatLaporanStep2Form> createState() => _BuatLaporanStep2FormState();
}

class _BuatLaporanStep2FormState extends State<BuatLaporanStep2Form> {
  Timer? _searchDebounce;
  String _searchQuery = '';

  @override
  void dispose() {
    _searchDebounce?.cancel();
    super.dispose();
  }

  List<ParticipantItem> get _filtered {
    return widget.participants.where((p) {
      if (_searchQuery.isEmpty) return true;
      return p.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          p.nim.contains(_searchQuery);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFBFDBFE),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.people_alt_rounded,
                  color: Color(0xFF2563EB),
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total Asessi Skema ${widget.selectedSkema}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${widget.participants.length} Asessi',
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: TextFormField(
            controller: widget.searchController,
            onChanged: (val) {
              _searchDebounce?.cancel();
              _searchDebounce = Timer(const Duration(milliseconds: 300), () {
                if (!mounted) return;
                setState(() {
                  _searchQuery = val;
                });
                widget.onSearchChanged(val);
              });
            },
            decoration: const InputDecoration(
              hintText: 'Cari nama/NIM peserta',
              hintStyle: TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
              prefixIcon: Icon(Icons.search, color: Color(0xFF94A3B8)),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),

        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Column(
            children: [
              Container(
                color: const Color(0xFFDBEAFE),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                child: Row(
                  children: const [
                    Expanded(
                      flex: 2,
                      child: Text(
                        'Nama Asessi',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        'NIM',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 80,
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          'Kehadiran',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, color: Color(0xFFE2E8F0)),
              ..._filtered.map((participant) {
                return AttendanceRow(
                  key: ValueKey(participant.nim),
                  participant: participant,
                );
              }),
            ],
          ),
        ),
      ],
    );
  }
}

class BuatLaporanStep3Form extends StatelessWidget {
  final List<ParticipantItem> participants;
  final bool allKSelected;
  final bool allTKSelected;
  final VoidCallback onBulkK;
  final VoidCallback onBulkTK;
  final ValueChanged<bool> onCompetenceChanged;

  const BuatLaporanStep3Form({
    super.key,
    required this.participants,
    required this.allKSelected,
    required this.allTKSelected,
    required this.onBulkK,
    required this.onBulkTK,
    required this.onCompetenceChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Penilaian Asessi',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Tugas yang diberikan assessor dikerjakan dengan baik, Tingkat kehadiran tidak absen, dan asessi mengerjakan tugas secara mandiri.',
                style: TextStyle(
                  fontSize: 12,
                  color: Color(0xFF64748B),
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 12),
              const Row(
                children: [
                  Text(
                    '> ',
                    style: TextStyle(
                      color: Color(0xFF0F766E),
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                  Text(
                    'Kompeten [K]',
                    style: TextStyle(
                      color: Color(0xFF0F766E),
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              const Row(
                children: [
                  Text(
                    '> ',
                    style: TextStyle(
                      color: Color(0xFFBE123C),
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                  Text(
                    'Tidak Kompeten [TK]',
                    style: TextStyle(
                      color: Color(0xFFBE123C),
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12.0),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'PILIHAN MASSAL (BULK ACTION)',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF64748B),
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 38,
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(
                            color: allKSelected
                                ? const Color(0xFF10B981)
                                : const Color(0xFFCBD5E1),
                          ),
                          backgroundColor: allKSelected
                              ? const Color(0xFFECFDF5)
                              : Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          foregroundColor: allKSelected
                              ? const Color(0xFF047857)
                              : const Color(0xFF475569),
                          padding: EdgeInsets.zero,
                        ),
                        onPressed: onBulkK,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              allKSelected
                                  ? Icons.check_circle_rounded
                                  : Icons.check_circle_outline_rounded,
                              size: 16,
                              color: allKSelected
                                  ? const Color(0xFF10B981)
                                  : const Color(0xFF64748B),
                            ),
                            const SizedBox(width: 6),
                            const Text(
                              'Semua [K]',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: SizedBox(
                      height: 38,
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(
                            color: allTKSelected
                                ? const Color(0xFFEF4444)
                                : const Color(0xFFCBD5E1),
                          ),
                          backgroundColor: allTKSelected
                              ? const Color(0xFFFEF2F2)
                              : Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          foregroundColor: allTKSelected
                              ? const Color(0xFFB91C1C)
                              : const Color(0xFF475569),
                          padding: EdgeInsets.zero,
                        ),
                        onPressed: onBulkTK,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              allTKSelected
                                  ? Icons.cancel_rounded
                                  : Icons.cancel_outlined,
                              size: 16,
                              color: allTKSelected
                                  ? const Color(0xFFEF4444)
                                  : const Color(0xFF64748B),
                            ),
                            const SizedBox(width: 6),
                            const Text(
                              'Semua [TK]',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),

        Column(
          children: participants.map((participant) {
            return Step3ParticipantCard(
              key: ValueKey(participant.nim),
              participant: participant,
              onCompetenceChanged: onCompetenceChanged,
            );
          }).toList(),
        ),
      ],
    );
  }
}

class BuatLaporanStep4Form extends StatelessWidget {
  final TextEditingController notesController;
  final bool isUploadingAttachment;
  final List<String> attachments;
  final VoidCallback onPickLampiran;
  final ValueChanged<int> onRemoveAttachment;

  const BuatLaporanStep4Form({
    super.key,
    required this.notesController,
    required this.isUploadingAttachment,
    required this.attachments,
    required this.onPickLampiran,
    required this.onRemoveAttachment,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Catatan :',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E293B),
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: notesController,
          maxLines: 7,
          decoration: InputDecoration(
            fillColor: const Color(0xFFF8FAFC),
            filled: true,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            contentPadding: const EdgeInsets.all(16),
          ),
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFF1E293B),
            height: 1.5,
          ),
        ),
        const SizedBox(height: 24),

        const Text(
          'Lampiran Pendukung(Opsional)',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E293B),
          ),
        ),
        const SizedBox(height: 10),

        isUploadingAttachment
            ? const SizedBox(
                height: 40,
                width: 40,
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              )
            : InkWell(
                onTap: onPickLampiran,
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Pilih Berkas Lampiran',
                        style: TextStyle(
                          color: Color(0xFF94A3B8),
                          fontSize: 14,
                        ),
                      ),
                      Icon(
                        Icons.cloud_upload_outlined,
                        color: Color(0xFF94A3B8),
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ),

        if (attachments.isNotEmpty) ...[
          const SizedBox(height: 12),
          ...attachments.asMap().entries.map((entry) {
            final idx = entry.key;
            final file = entry.value;
            final displayName = file.contains('/')
                ? file.split('/').last
                : file;
            final isPdf = displayName.toLowerCase().endsWith('.pdf');
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Icon(
                          isPdf ? Icons.picture_as_pdf : Icons.image,
                          color: isPdf
                              ? const Color(0xFFEF4444)
                              : const Color(0xFF3B82F6),
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            displayName,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF1E293B),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.delete_outline_rounded,
                      color: Color(0xFFEF4444),
                      size: 18,
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: () => onRemoveAttachment(idx),
                  ),
                ],
              ),
            );
          }),
        ],
      ],
    );
  }
}
