import 'package:flutter/material.dart';

import '../../models/admin_laporan_models.dart';

/// Tab Informasi Asessmen — menampilkan detail laporan pelaporan.
class InformasiContent extends StatelessWidget {
  final AdminLaporanDetailData detail;
  final bool isApproved;

  const InformasiContent({
    super.key,
    required this.detail,
    required this.isApproved,
  });

  @override
  Widget build(BuildContext context) {
    final String namaSkema = detail.skemaSertifikasi.isNotEmpty
        ? detail.skemaSertifikasi
        : 'Digital Marketing';
    final String kodeSkema = detail.kodeLaporan.isNotEmpty
        ? detail.kodeLaporan
        : 'JNA - 002';
    final String tuk = detail.tuk.isNotEmpty ? detail.tuk : 'LPK Digital Center';
    final String jenisAsessmen = detail.jenisAsesmen.isNotEmpty
        ? detail.jenisAsesmen
        : 'Offline';
    final String tanggalAsessmen = detail.tanggalPelaksanaan.isNotEmpty
        ? detail.tanggalPelaksanaan
        : '20 Juli 2026';
    final String asesor = detail.namaAsesor.isNotEmpty
        ? detail.namaAsesor
        : 'Karina';
    final String jumlahAsessi = '${detail.ringkasan.totalPeserta} Peserta';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Main Informasi Asessmen Card Box
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Informasi Asessmen',
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 14),
              InfoRow(label: 'Nama Skema', value: namaSkema),
              InfoRow(label: 'Kode Skema', value: kodeSkema),
              InfoRow(label: 'TUK', value: tuk),
              InfoRow(label: 'Jenis Asessmen', value: jenisAsessmen),
              InfoRow(label: 'Tanggal Asessmen', value: tanggalAsessmen),
              InfoRow(label: 'Asessor', value: asesor),
              InfoRow(label: 'Jumlah Asessi', value: jumlahAsessi),
            ],
          ),
        ),

        // Status Banner ONLY shown if Disetujui
        if (isApproved) ...[
          const SizedBox(height: 16),
          const GreenStatusBanner(),
        ],
      ],
    );
  }
}

/// Banner status hijau "Laporan Telah Disetujui".
class GreenStatusBanner extends StatelessWidget {
  const GreenStatusBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFD1FAE5),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: const Color(0xFF34D399),
          width: 1,
        ),
      ),
      padding: const EdgeInsets.all(14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.check_circle_rounded,
            color: Color(0xFF10B981),
            size: 32,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Laporan Telah Lengkap',
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF065F46),
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Tidak ada dokumen yang perlu direvisi. Laporan dinyatakan lengkap.',
                  style: TextStyle(
                    fontSize: 11.5,
                    color: Color(0xFF047857),
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Baris label + nilai untuk detail laporan.
class InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const InfoRow({super.key, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 135,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF1E293B),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const Text(
            ': ',
            style: TextStyle(
              fontSize: 12,
              color: Color(0xFF1E293B),
              fontWeight: FontWeight.w500,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
