// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';

class EditPendaftaranScreen extends StatefulWidget {
  final String namaPemohon;
  final String skemaSertifikasi;

  const EditPendaftaranScreen({
    super.key,
    this.namaPemohon = 'Aldi Taher',
    this.skemaSertifikasi = 'Digital Marketing',
  });

  @override
  State<EditPendaftaranScreen> createState() => _EditPendaftaranScreenState();
}

class _EditPendaftaranScreenState extends State<EditPendaftaranScreen> {
  // Skipping step 1, directly starting at step 2 (Data Peserta)
  int _currentStep = 2;

  // Step 2 Form State
  String _rekomendasi = 'Diterima'; // 'Diterima' or 'Tidak Diterima'
  final TextEditingController _catatanController = TextEditingController();
  bool _isAgreed = true;

  // Step 3 Selected Schedule Index
  int _selectedJadwalIndex = 0;

  final List<Map<String, String>> _jadwalList = [
    {
      'jadwal': 'Sertifikasi SMA 5 Semarang - DG Muda 200726',
      'tglPra': '20/07/2026',
      'tglAsesmen': '20/07/2026',
    },
    {
      'jadwal': 'Uji Desainer Grafis Muda - Jabshun 010826',
      'tglPra': '01/08/2026',
      'tglAsesmen': '01/08/2026',
    },
    {
      'jadwal': 'Uji Desainer Grafis Muda - Jabshun 010826',
      'tglPra': '01/08/2026',
      'tglAsesmen': '01/08/2026',
    },
    {
      'jadwal': 'Uji Desainer Grafis Muda - Jabshun 010826',
      'tglPra': '01/08/2026',
      'tglAsesmen': '01/08/2026',
    },
  ];

  @override
  void dispose() {
    _catatanController.dispose();
    super.dispose();
  }

  void _handleNext() {
    if (_currentStep == 2) {
      setState(() {
        _currentStep = 3;
      });
    } else if (_currentStep == 3) {
      setState(() {
        _currentStep = 4;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Data pendaftaran berhasil diperbarui'),
          backgroundColor: Color(0xFF10B981),
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.pop(context);
    }
  }

  void _handleBack() {
    if (_currentStep > 2) {
      setState(() {
        _currentStep--;
      });
    } else {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final double statusBarHeight = MediaQuery.paddingOf(context).top;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Header Bar matching screenshot
          Container(
            width: double.infinity,
            color: const Color(0xFFEBEBEB),
            padding: EdgeInsets.only(
              top: statusBarHeight + 8,
              bottom: 12,
              left: 16,
              right: 16,
            ),
            child: Row(
              children: [
                GestureDetector(
                  onTap: _handleBack,
                  behavior: HitTestBehavior.opaque,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 26,
                        height: 26,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color(0xFF0F172A),
                            width: 1.5,
                          ),
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.chevron_left_rounded,
                            color: Color(0xFF0F172A),
                            size: 18,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        'Edit Pendaftaran',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Stepper Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
            child: _buildStepperHeader(),
          ),

          // Content Body according to active step
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: _currentStep == 2
                  ? _buildStep2DataPeserta()
                  : _currentStep == 3
                      ? _buildStep3Jadwal()
                      : _buildStep4Biodata(),
            ),
          ),

          // Bottom Action Buttons (Kembali & Selanjutnya)
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 46,
                    child: ElevatedButton(
                      onPressed: _handleBack,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFCBD5E1),
                        foregroundColor: const Color(0xFF334155),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        'Kembali',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: SizedBox(
                    height: 46,
                    child: ElevatedButton(
                      onPressed: _handleNext,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF60A5FA),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        _currentStep == 4 ? 'Simpan' : 'Selanjutnya',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Stepper Header (4 steps)
  Widget _buildStepperHeader() {
    final steps = [
      {'number': 1, 'title': 'Persyaratan Asessi'},
      {'number': 2, 'title': 'Data Peserta'},
      {'number': 3, 'title': 'Jadwal'},
      {'number': 4, 'title': 'Biodata Peserta'},
    ];

    return Row(
      children: List.generate(steps.length, (index) {
        final stepNumber = index + 1;
        final isActive = _currentStep == stepNumber;
        final title = steps[index]['title'] as String;

        return Expanded(
          child: Column(
            children: [
              Row(
                children: [
                  if (index > 0)
                    Expanded(
                      child: Container(
                        height: 1.5,
                        color: const Color(0xFFCBD5E1),
                      ),
                    ),
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isActive ? const Color(0xFFBFDBFE) : Colors.white,
                      border: Border.all(
                        color: isActive ? const Color(0xFF3B82F6) : const Color(0xFF94A3B8),
                        width: 1.5,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        '$stepNumber',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: isActive ? const Color(0xFF1D4ED8) : const Color(0xFF64748B),
                        ),
                      ),
                    ),
                  ),
                  if (index < steps.length - 1)
                    Expanded(
                      child: Container(
                        height: 1.5,
                        color: const Color(0xFFCBD5E1),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                  color: isActive ? const Color(0xFF1D4ED8) : const Color(0xFF64748B),
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        );
      }),
    );
  }

  // Step 2: Data Peserta (Rekomendasi APL 01) - Matching Image 1
  Widget _buildStep2DataPeserta() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Green Banner Title
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: const Color(0xFFD1FAE5),
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: const Center(
            child: Text(
              'Rekomendasi APL 01',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Color(0xFF10B981),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Main Card Container
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Nama Pemohon
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Nama Pemohon',
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  Text(
                    widget.namaPemohon,
                    style: const TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Skema Sertifikasi
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Skema Sertifikasi',
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  Text(
                    widget.skemaSertifikasi,
                    style: const TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Text Statement
              const Text(
                'Berdasarkan Ketentuan Persyaratan Dasar,\nMaka pemohon :',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A),
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 10),

              // Radio Option: Rekomendasi
              Row(
                children: [
                  const Text(
                    'Rekomendasi',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Radio<String>(
                    value: 'Diterima',
                    groupValue: _rekomendasi,
                    activeColor: const Color(0xFF3B82F6),
                    onChanged: (val) => setState(() => _rekomendasi = val!),
                  ),
                  const Text(
                    'Diterima',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Radio<String>(
                    value: 'Tidak Diterima',
                    groupValue: _rekomendasi,
                    activeColor: const Color(0xFF3B82F6),
                    onChanged: (val) => setState(() => _rekomendasi = val!),
                  ),
                  const Text(
                    'Tidak Diterima',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                ],
              ),
              const Padding(
                padding: EdgeInsets.only(left: 100.0),
                child: Text(
                  'Sebagai Peserta Sertifikasi',
                  style: TextStyle(
                    fontSize: 10.5,
                    color: Color(0xFF64748B),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Catatan Pemohon Textarea
              const Text(
                'Catatan Pemohon',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _catatanController,
                maxLines: 4,
                style: const TextStyle(fontSize: 13, color: Color(0xFF0F172A)),
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.all(12),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Color(0xFF3B82F6), width: 1.5),
                  ),
                  fillColor: const Color(0xFFFAFAFA),
                  filled: true,
                ),
              ),
              const SizedBox(height: 14),

              // Checkbox Agreement
              Row(
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: Checkbox(
                      value: _isAgreed,
                      activeColor: const Color(0xFF3B82F6),
                      onChanged: (val) => setState(() => _isAgreed = val ?? false),
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text(
                      'Saya setuju menandatangani dokumen ini.',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Step 3: Jadwal (Jadwal Pra-Asesmen dan Asesmen) - Matching Image 2
  Widget _buildStep3Jadwal() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Green Banner Title
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: const Color(0xFFD1FAE5),
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: const Center(
            child: Text(
              'Jadwal Pra - Asesmen danAsesmen',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Color(0xFF10B981),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Table Grid Container
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Column(
            children: [
              // Table Header
              Container(
                decoration: const BoxDecoration(
                  color: Color(0xFFFAFAFA),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
                  border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                child: const Row(
                  children: [
                    Expanded(
                      flex: 4,
                      child: Center(
                        child: Text(
                          'Jadwal',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: Center(
                        child: Text(
                          'Tanggal Pra\nAsessmen',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: Center(
                        child: Text(
                          'Tanggal\nAsessmen',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Center(
                        child: Text(
                          'Status',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Table Body Rows
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _jadwalList.length,
                separatorBuilder: (context, index) => const Divider(height: 1, color: Color(0xFFE2E8F0)),
                itemBuilder: (context, index) {
                  final item = _jadwalList[index];
                  final isSelected = _selectedJadwalIndex == index;

                  return InkWell(
                    onTap: () => setState(() => _selectedJadwalIndex = index),
                    child: Container(
                      color: isSelected ? const Color(0xFFF1F5F9) : Colors.transparent,
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 4,
                            child: Text(
                              item['jadwal'] ?? '',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF0F172A),
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 3,
                            child: Center(
                              child: Text(
                                item['tglPra'] ?? '',
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF0F172A),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 3,
                            child: Center(
                              child: Text(
                                item['tglAsesmen'] ?? '',
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF0F172A),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Center(
                              child: Radio<int>(
                                value: index,
                                groupValue: _selectedJadwalIndex,
                                activeColor: const Color(0xFF3B82F6),
                                onChanged: (val) => setState(() => _selectedJadwalIndex = val!),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Step 4: Biodata Peserta (Fallback View)
  Widget _buildStep4Biodata() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      padding: const EdgeInsets.all(16),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Biodata Peserta',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0F172A),
            ),
          ),
          SizedBox(height: 12),
          Text(
            'Lengkapi dan periksa kembali biodata peserta sebelum menyelesaikan edit pendaftaran ini.',
            style: TextStyle(
              fontSize: 12,
              color: Color(0xFF64748B),
            ),
          ),
        ],
      ),
    );
  }
}
