import 'package:flutter/material.dart';
import 'unit_kompetensi_table.dart';
import 'persyaratan_dasar_table.dart';
import 'persyaratan_administratif_table.dart';

class DokumenPersyaratanForm extends StatelessWidget {
  final String selectedSkema;
  final List<Map<String, dynamic>> unitKompetensi;
  final List<Map<String, String>> persyaratanDasar;
  final List<Map<String, String>> persyaratanAdministratif;
  final bool isLoading;
  final Map<String, bool> uploadedDocs;
  final Map<String, String?> uploadedFileNames;
  final void Function(String key, String label, bool isUploaded, String? fileName, String? filePath)
      onUploadChanged;

  const DokumenPersyaratanForm({
    super.key,
    required this.selectedSkema,
    required this.unitKompetensi,
    this.persyaratanDasar = const [],
    this.persyaratanAdministratif = const [
      {'key': 'pasfoto', 'label': 'Pasfoto*'},
      {
        'key': 'identitas-pribadi-ktp-kartu-pelajar',
        'label': 'Identitas pribadi (KTP/Kartu Pelajar)*',
      },
    ],
    this.isLoading = false,
    required this.uploadedDocs,
    required this.uploadedFileNames,
    required this.onUploadChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'FR.APL.01 FORMULIR PERMOHONAN SERTIFIKASI KOMPETENSI',
            style: TextStyle(
              color: Color(0xFF0F4C81),
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Bagian 2 : Data Sertifikasi',
            style: TextStyle(
              color: Color(0xFF1E293B),
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Tuliskan Judul Skema Sertifikasi, Daftar Unit Kompetensi, serta lengkapi berkas persyaratan.',
            style: TextStyle(
              color: Color(0xFF64748B),
              fontSize: 12,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),
          if (isLoading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(child: CircularProgressIndicator()),
            )
          else ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFD4E6F1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Text(
                'c. Unit Kompetensi yang Diikuti',
                style: TextStyle(
                  color: Color(0xFF1B4F72),
                  fontSize: 12.5,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 20),
            UnitKompetensiTable(
              selectedSkema: selectedSkema,
              unitKompetensi: unitKompetensi,
            ),
            const SizedBox(height: 28),
            PersyaratanDasarTable(
              items: persyaratanDasar,
              uploadedDocs: uploadedDocs,
              uploadedFileNames: uploadedFileNames,
              onUploadChanged: onUploadChanged,
            ),
            const SizedBox(height: 28),
            PersyaratanAdministratifTable(
              items: persyaratanAdministratif,
              uploadedDocs: uploadedDocs,
              uploadedFileNames: uploadedFileNames,
              onUploadChanged: onUploadChanged,
            ),
            const SizedBox(height: 20),
          ],
        ],
      ),
    );
  }
}
