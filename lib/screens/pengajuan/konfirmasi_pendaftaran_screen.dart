import 'package:flutter/material.dart';
import '../../widgets/pengajuan/periksa_data_banner.dart';
import '../../widgets/pengajuan/ringkasan_pendaftaran_card.dart';
import '../../widgets/pengajuan/data_diri_konfirmasi_card.dart';
import 'edit_data_pendaftaran_screen.dart';
import 'konfirmasi_portofolio_screen.dart';

class KonfirmasiPendaftaranScreen extends StatefulWidget {
  final int skemaId;
  final String title;
  final String kodeSkema;

  const KonfirmasiPendaftaranScreen({
    super.key,
    required this.skemaId,
    required this.title,
    required this.kodeSkema,
  });

  @override
  State<KonfirmasiPendaftaranScreen> createState() => _KonfirmasiPendaftaranScreenState();
}

class _KonfirmasiPendaftaranScreenState extends State<KonfirmasiPendaftaranScreen> {
  // Mock data of the candidate matching the screenshots exactly
  String _name = 'Muhammad Hanafi';
  String _email = 'HanafiMuhammad@gmail.com';
  String _phone = '085026954823';
  String _address = 'Jl. Pramuka Km 4,5 Baamang, Kalimantan Selatan';
  String _nik = '6256400136573124';
  String _pendidikan = 'D3 Teknik Informasi';

  @override
  Widget build(BuildContext context) {
    final double statusBarHeight = MediaQuery.paddingOf(context).top;

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: Column(
        children: [
          SizedBox(height: statusBarHeight + 8),
          _buildAppBar(),
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const PeriksaDataBanner(),
                  const SizedBox(height: 16),
                  RingkasanPendaftaranCard(
                    skemaTitle: widget.title,
                  ),
                  const SizedBox(height: 16),
                  DataDiriKonfirmasiCard(
                    name: _name,
                    nik: _nik,
                    phone: _phone,
                    email: _email,
                    pendidikan: _pendidikan,
                    address: _address,
                    onEdit: _navigateToEditDataDiri,
                  ),
                  const SizedBox(height: 24),
                  _buildActionButtons(),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              width: 32,
              height: 32,
              decoration: const BoxDecoration(
                color: Colors.black,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.keyboard_arrow_left_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
          const Text(
            'Konfirmasi Pendaftaran',
            style: TextStyle(
              color: Colors.black,
              fontSize: 16,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(width: 32, height: 32),
        ],
      ),
    );
  }

  void _navigateToEditDataDiri() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditDataPendaftaranScreen(
          currentName: _name,
          currentNik: _nik,
          currentPhone: _phone,
          currentEmail: _email,
          currentPendidikan: _pendidikan,
          currentAddress: _address,
          onSave: (name, nik, phone, email, pendidikan, address) {
            setState(() {
              _name = name;
              _nik = nik;
              _phone = phone;
              _email = email;
              _pendidikan = pendidikan;
              _address = address;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Data diri berhasil diperbarui'),
                behavior: SnackBarBehavior.floating,
                duration: Duration(seconds: 2),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => KonfirmasiPortofolioScreen(
                skemaId: widget.skemaId,
                title: widget.title,
                kodeSkema: widget.kodeSkema,
              ),
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF3B82F6),
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
