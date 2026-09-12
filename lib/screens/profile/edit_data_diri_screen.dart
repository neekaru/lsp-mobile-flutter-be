import 'package:material_ui/material_ui.dart';
import '../../widgets/common/custom_app_bar.dart';
import '../../services/asesor/asesor_service.dart';
import '../../services/asesi/asesi_service.dart';
import '../../services/auth/auth_repository.dart';
import '../../services/marketing/location_service.dart';
class EditDataDiriScreen extends StatefulWidget {
  final String currentName;
  final String currentPhone;
  final String currentEmail;
  final String currentAddress;
  final String currentNPWP;
  final String currentNoRekening;
  final String currentBank;
  final String currentAtasNama;
  final String currentLinkCV;
  final String currentHomebase;
  final double? currentLatitude;
  final double? currentLongitude;
  final int currentStatusPencariKerja;
  final Function(
    String name,
    String phone,
    String email,
    String address,
    String npwp,
    String noRekening,
    String bank,
    String atasNama,
    String linkCv,
    String homebase, {
    double? lat,
    double? lng,
    int? statusPencariKerja,
  }) onSave;

  const EditDataDiriScreen({
    super.key,
    required this.currentName,
    required this.currentPhone,
    required this.currentEmail,
    required this.currentAddress,
    this.currentNPWP = '',
    this.currentNoRekening = '',
    this.currentBank = '',
    this.currentAtasNama = '',
    this.currentLinkCV = '',
    this.currentHomebase = '',
    this.currentLatitude,
    this.currentLongitude,
    this.currentStatusPencariKerja = 1,
    required this.onSave,
  });

  @override
  State<EditDataDiriScreen> createState() => _EditDataDiriScreenState();
}

class _EditDataDiriScreenState extends State<EditDataDiriScreen> {
  bool _isSaving = false;
  bool _isLocating = false;
  double? _lat;
  double? _lng;
  int _statusPencariKerja = 1;
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  late TextEditingController _addressController;
  late TextEditingController _npwpController;
  late TextEditingController _noRekeningController;
  late TextEditingController _bankController;
  late TextEditingController _atasNamaController;
  late TextEditingController _linkCvController;
  late TextEditingController _homebaseController;
  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.currentName);
    _phoneController = TextEditingController(text: widget.currentPhone);
    _emailController = TextEditingController(text: widget.currentEmail);
    _addressController = TextEditingController(text: widget.currentAddress);
    _npwpController = TextEditingController(text: widget.currentNPWP);
    _noRekeningController = TextEditingController(text: widget.currentNoRekening);
    _bankController = TextEditingController(text: widget.currentBank);
    _atasNamaController = TextEditingController(text: widget.currentAtasNama);
    _linkCvController = TextEditingController(text: widget.currentLinkCV);
    _homebaseController = TextEditingController(text: widget.currentHomebase);
    _lat = widget.currentLatitude;
    _lng = widget.currentLongitude;
    _statusPencariKerja = widget.currentStatusPencariKerja;
  }

  Future<void> _getCurrentLocation() async {
    setState(() => _isLocating = true);
    try {
      final loc = await LocationService.getCurrentLocation();
      if (!mounted) return;
      setState(() {
        _lat = loc.latitude;
        _lng = loc.longitude;
        _isLocating = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Lokasi berhasil diambil: ${loc.latitude.toStringAsFixed(5)}, ${loc.longitude.toStringAsFixed(5)}',
          ),
          backgroundColor: const Color(0xFF16A34A),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLocating = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Gagal mengambil lokasi GPS. Pastikan GPS aktif.'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _npwpController.dispose();
    _noRekeningController.dispose();
    _bankController.dispose();
    _atasNamaController.dispose();
    _linkCvController.dispose();
    _homebaseController.dispose();
    super.dispose();
  }

  void _handleSave() async {
    setState(() {
      _isSaving = true;
    });

    final user = AuthRepository.currentUserInstance;
    final bool isAsesi = user?.isAsesi ?? false;

    try {
      if (isAsesi) {
        final body = <String, dynamic>{
          'nama_lengkap': _nameController.text.trim(),
          'telp': _phoneController.text.trim(),
          'email': _emailController.text.trim(),
          'alamat': _addressController.text.trim(),
          'status_pencari_kerja': _statusPencariKerja,
        };
        if (_lat != null && _lng != null) {
          body['latitude'] = _lat;
          body['longitude'] = _lng;
        }
        await AsesiService.updateProfile(body);
      } else {
        await AsesorService.updateProfile(
          noTelepon: _phoneController.text.trim(),
          alamat: _addressController.text.trim(),
          npwp: _npwpController.text.trim(),
          noRekening: _noRekeningController.text.trim(),
          bank: _bankController.text.trim(),
          atasNamaRekening: _atasNamaController.text.trim(),
          linkCv: _linkCvController.text.trim(),
          homebase: _homebaseController.text.trim(),
        );
      }
    } catch (_) {}

    widget.onSave(
      _nameController.text.trim(),
      _phoneController.text.trim(),
      _emailController.text.trim(),
      _addressController.text.trim(),
      _npwpController.text.trim(),
      _noRekeningController.text.trim(),
      _bankController.text.trim(),
      _atasNamaController.text.trim(),
      _linkCvController.text.trim(),
      _homebaseController.text.trim(),
      lat: _lat,
      lng: _lng,
      statusPencariKerja: _statusPencariKerja,
    );

    if (mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final double statusBarHeight = MediaQuery.paddingOf(context).top;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(height: statusBarHeight + 8),
            // Header Bar
            const CustomAppBar(
              title: 'Edit Data Diri',
              rightWidget: SizedBox(width: 32),
            ),
            
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.fromLTRB(
                  20.0,
                  20.0,
                  20.0,
                  MediaQuery.paddingOf(context).bottom + 24.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Data Pribadi',
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
                        color: const Color(0xFFF7F8FA),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          _buildTextField(
                            label: 'Nama Lengkap',
                            controller: _nameController,
                            hint: 'Masukan nama lengkap',
                            isRequired: true,
                          ),
                          _buildTextField(
                            label: 'No. Handphone',
                            controller: _phoneController,
                            hint: 'Masukan nomor HP aktif',
                            keyboardType: TextInputType.phone,
                            isRequired: true,
                          ),
                          _buildTextField(
                            label: 'Email',
                            controller: _emailController,
                            hint: 'Masukan Email aktif',
                            keyboardType: TextInputType.emailAddress,
                            isRequired: true,
                          ),
                          _buildTextField(
                            label: 'Alamat / Domisili',
                            controller: _addressController,
                            hint: 'Masukan alamat atau domisili Anda',
                            maxLines: 3,
                          ),
                          if (AuthRepository.currentUserInstance?.isAsesi ?? false) ...[
                            const SizedBox(height: 4),
                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton.icon(
                                onPressed: _isLocating ? null : _getCurrentLocation,
                                icon: _isLocating
                                    ? const SizedBox(
                                        width: 16,
                                        height: 16,
                                        child: CircularProgressIndicator(strokeWidth: 2),
                                      )
                                    : const Icon(
                                        Icons.my_location_rounded,
                                        size: 18,
                                        color: Color(0xFF2563EB),
                                      ),
                                label: Text(
                                  _lat == null
                                      ? 'Ambil Titik Lokasi Saya (GPS)'
                                      : 'Lokasi Terpasang: ${_lat!.toStringAsFixed(5)}, ${_lng!.toStringAsFixed(5)}',
                                  style: TextStyle(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w600,
                                    color: _lat == null
                                        ? const Color(0xFF2563EB)
                                        : const Color(0xFF16A34A),
                                  ),
                                ),
                                style: OutlinedButton.styleFrom(
                                  side: BorderSide(
                                    color: _lat == null
                                        ? const Color(0xFFBFDBFE)
                                        : const Color(0xFFBBF7D0),
                                  ),
                                  backgroundColor: _lat == null
                                      ? const Color(0xFFEFF6FF)
                                      : const Color(0xFFF0FDF4),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 10,
                                    horizontal: 12,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            _buildStatusPencariKerjaField(),
                          ] else ...[
                            _buildTextField(
                              label: 'Homebase / Wilayah',
                              controller: _homebaseController,
                              hint: 'Contoh: LSP Teknologi Digital, DKI Jakarta',
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                  if (!(AuthRepository.currentUserInstance?.isAsesi ?? false)) ...[
                    const Text(
                      'Rekening Bank & Pajak (Honorarium)',
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
                        color: const Color(0xFFF7F8FA),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          _buildTextField(
                            label: 'No. NPWP',
                            controller: _npwpController,
                            hint: 'Masukan nomor NPWP',
                            keyboardType: TextInputType.number,
                          ),
                          _buildTextField(
                            label: 'Nama Bank',
                            controller: _bankController,
                            hint: 'Contoh: BCA, Mandiri, BRI, BNI',
                          ),
                          _buildTextField(
                            label: 'No. Rekening',
                            controller: _noRekeningController,
                            hint: 'Masukan nomor rekening bank',
                            keyboardType: TextInputType.number,
                          ),
                          _buildTextField(
                            label: 'Atas Nama Rekening',
                            controller: _atasNamaController,
                            hint: 'Nama pemilik rekening buku tabungan',
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    const Text(
                      'Dokumen & Portofolio',
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
                        color: const Color(0xFFF7F8FA),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          _buildTextField(
                            label: 'Link CV / Dokumen Asesor',
                            controller: _linkCvController,
                            hint: 'https://drive.google.com/...',
                            keyboardType: TextInputType.url,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                    
                    Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 48,
                            child: ElevatedButton(
                              onPressed: _isSaving ? null : () => Navigator.pop(context),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFE2E8F0),
                                foregroundColor: const Color(0xFF64748B),
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: const Text(
                                  'Batal',
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
                            height: 48,
                            child: ElevatedButton(
                              onPressed: _isSaving ? null : _handleSave,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF3B82F6),
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: _isSaving
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Text(
                                      'Simpan',
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String labelText, {bool isRequired = false}) {
    if (!isRequired) {
      return Text(
        labelText,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      );
    }
    return RichText(
      text: TextSpan(
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
        children: [
          TextSpan(text: labelText),
          const TextSpan(
            text: ' *',
            style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    bool isRequired = false,
    Widget? subtitle,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLabel(label, isRequired: isRequired),
          const SizedBox(height: 8),
          TextFormField(
            controller: controller,
            maxLines: maxLines,
            keyboardType: keyboardType,
            style: const TextStyle(
              fontSize: 13,
              color: Colors.black,
              fontWeight: FontWeight.w500,
            ),
            decoration: InputDecoration(
              isDense: true,
              hintText: hint,
              hintStyle: const TextStyle(
                fontSize: 13,
                color: Color(0xFF94A3B8),
                fontWeight: FontWeight.normal,
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFF3B82F6), width: 1.5),
              ),
              fillColor: const Color(0xFFF3F4F6),
              filled: true,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 6),
            subtitle,
          ],
        ],
      ),
    );
  }

  Widget _buildStatusPencariKerjaField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Status Pencari Kerja',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFFF3F4F6),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<int>(
              value: _statusPencariKerja,
              isExpanded: true,
              icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF64748B)),
              items: const [
                DropdownMenuItem(
                  value: 0,
                  child: Text(
                    'Tidak sedang mencari kerja',
                    style: TextStyle(fontSize: 13, color: Color(0xFF334155)),
                  ),
                ),
                DropdownMenuItem(
                  value: 1,
                  child: Text(
                    'Sedang aktif mencari kerja (Open to Work)',
                    style: TextStyle(fontSize: 13, color: Color(0xFF16A34A), fontWeight: FontWeight.bold),
                  ),
                ),
                DropdownMenuItem(
                  value: 2,
                  child: Text(
                    'Bekerja, tapi terbuka untuk peluang baru',
                    style: TextStyle(fontSize: 13, color: Color(0xFF2563EB), fontWeight: FontWeight.bold),
                  ),
                ),
              ],
              onChanged: (val) {
                if (val != null) {
                  setState(() => _statusPencariKerja = val);
                }
              },
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          _statusPencariKerja == 0
              ? 'Profil Anda tidak akan ditampilkan di menu Talenta.'
              : 'Profil Anda akan ditampilkan kepada pencari talenta di menu Talenta.',
          style: TextStyle(
            fontSize: 11,
            color: _statusPencariKerja == 0 ? const Color(0xFF94A3B8) : const Color(0xFF2563EB),
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }
}
