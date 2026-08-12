// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import '../../../services/asesi/permohonan_service.dart';

class Step2DataPeserta extends StatefulWidget {
  final String namaPemohon;
  final String skemaSertifikasi;
  final int? permohonanId;

  const Step2DataPeserta({
    super.key,
    required this.namaPemohon,
    required this.skemaSertifikasi,
    this.permohonanId,
  });

  @override
  State<Step2DataPeserta> createState() => _Step2DataPesertaState();
}

class _Step2DataPesertaState extends State<Step2DataPeserta> {
  String _rekomendasi = 'Diterima'; // 'Diterima' or 'Tidak Diterima'
  final TextEditingController _catatanController = TextEditingController();
  bool _isAgreed = true;

  @override
  void initState() {
    super.initState();
    _loadStep2Data();
  }

  Future<void> _loadStep2Data() async {
    final id = widget.permohonanId ?? 251343;
    final realData = await PermohonanService.getStep2Data(id);
    if (!mounted) return;
    if (realData != null) {
      setState(() {
        if (realData['rekomendasi'] != null && realData['rekomendasi']!.isNotEmpty) {
          _rekomendasi = realData['rekomendasi']!.contains('Tidak') ? 'Tidak Diterima' : 'Diterima';
        }
        if (realData['catatan_pemohon'] != null && realData['catatan_pemohon'] != '-') {
          _catatanController.text = realData['catatan_pemohon']!;
        }
      });
    }
  }

  @override
  void dispose() {
    _catatanController.dispose();
    super.dispose();
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
}
