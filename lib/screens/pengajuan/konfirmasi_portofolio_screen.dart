import 'package:flutter/material.dart';
import '../../widgets/custom_app_bar.dart';
import 'konfirmasi_persetujuan_screen.dart';

class KonfirmasiPortofolioScreen extends StatelessWidget {
  final int skemaId;
  final String title;
  final String kodeSkema;

  const KonfirmasiPortofolioScreen({
    super.key,
    required this.skemaId,
    required this.title,
    required this.kodeSkema,
  });

  @override
  Widget build(BuildContext context) {
    final double statusBarHeight = MediaQuery.paddingOf(context).top;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          SizedBox(height: statusBarHeight + 8),
          _buildAppBar(context),
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Portofolio Utama',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3F4F6), // grey container background
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      children: [
                        _buildSchemeCard('Skema Sertifikasi', title),
                        _buildPortofolioItem('Pas Foto 4x6', 'Pas_Foto_Hanafi.PNG'),
                        _buildPortofolioItem('KTP', 'KTP_Hanafi.PDF'),
                        _buildPortofolioItem('Ijasah Terakhir', 'Ijasah_Terakhir.PDF'),
                        _buildPortofolioItem('Sertifikat Pendukung', 'Sertifikasi_pengalaman.PDF'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  _buildActionButton(context),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return const CustomAppBar(
      title: 'Konfirmasi Portofolio',
      rightWidget: SizedBox(width: 32),
    );
  }

  Widget _buildSchemeCard(String label, String value) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: Color(0xFF7E7E7E),
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPortofolioItem(String name, String fileName) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            name,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            fileName,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF7E7E7E),
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Text(
                'Status : ',
                style: TextStyle(
                  fontSize: 12,
                  color: Color(0xFF7E7E7E),
                  fontWeight: FontWeight.w400,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFE2F4E9), // very light green background
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'Terverifikasi',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2E7D32), // green text
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => KonfirmasiPersetujuanScreen(
                skemaId: skemaId,
                title: title,
                kodeSkema: kodeSkema,
              ),
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF5B9FD8), // matching the blue button color in screenshots
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: const Text(
          'Selanjutnya',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
