import 'package:flutter/material.dart';
import '../../widgets/custom_app_bar.dart';
import '../../models/master_models.dart';
import '../../services/api_service.dart';

class EditDataPendaftaranScreen extends StatefulWidget {
  final String currentName;
  final String currentNik;
  final String currentPhone;
  final String currentEmail;
  final String currentPendidikan;
  final int? currentPendidikanId;
  final String currentAddress;
  final Function(
    String name,
    String nik,
    String phone,
    String email,
    String pendidikan,
    String address, {
    int? pendidikanId,
  }) onSave;

  const EditDataPendaftaranScreen({
    super.key,
    required this.currentName,
    required this.currentNik,
    required this.currentPhone,
    required this.currentEmail,
    required this.currentPendidikan,
    this.currentPendidikanId,
    required this.currentAddress,
    required this.onSave,
  });

  @override
  State<EditDataPendaftaranScreen> createState() =>
      _EditDataPendaftaranScreenState();
}

class _EditDataPendaftaranScreenState extends State<EditDataPendaftaranScreen> {
  bool _isSaving = false;
  late TextEditingController _nameController;
  late TextEditingController _nikController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  late TextEditingController _addressController;
  int? _selectedPendidikanId;
  String _selectedPendidikanLabel = '';
  List<MasterPendidikan> _listPendidikan = [];
  bool _isLoadingPendidikan = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.currentName);
    _nikController = TextEditingController(text: widget.currentNik);
    _phoneController = TextEditingController(text: widget.currentPhone);
    _emailController = TextEditingController(text: widget.currentEmail);
    _addressController = TextEditingController(text: widget.currentAddress);
    _selectedPendidikanId = widget.currentPendidikanId;
    _selectedPendidikanLabel = widget.currentPendidikan;
    _loadPendidikan();
  }

  Future<void> _loadPendidikan() async {
    setState(() => _isLoadingPendidikan = true);
    try {
      final list = await ApiService.getMasterPendidikanList();
      if (!mounted) return;
      setState(() {
        _listPendidikan = list;
        _isLoadingPendidikan = false;
        if (_selectedPendidikanId != null) {
          try {
            final match =
                list.firstWhere((e) => e.id == _selectedPendidikanId);
            _selectedPendidikanLabel = match.displayName;
          } catch (_) {}
        } else if (_selectedPendidikanLabel.isNotEmpty) {
          try {
            final match = list.firstWhere(
              (e) =>
                  e.displayName.toLowerCase() ==
                  _selectedPendidikanLabel.toLowerCase(),
            );
            _selectedPendidikanId = match.id;
            _selectedPendidikanLabel = match.displayName;
          } catch (_) {}
        }
      });
    } catch (e) {
      debugPrint('Error loading pendidikan: $e');
      if (mounted) setState(() => _isLoadingPendidikan = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _nikController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    setState(() => _isSaving = true);

    final body = <String, dynamic>{
      'nama_lengkap': _nameController.text.trim(),
      'nik': _nikController.text.trim(),
      'telp': _phoneController.text.trim(),
      'email': _emailController.text.trim(),
      'alamat': _addressController.text.trim(),
    };
    if (_selectedPendidikanId != null) {
      body['id_pendidikan'] = _selectedPendidikanId;
    }

    final ok = await AsesiService.updateProfile(body);
    if (!mounted) return;

    if (!ok) {
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Gagal menyimpan data diri'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    widget.onSave(
      _nameController.text,
      _nikController.text,
      _phoneController.text,
      _emailController.text,
      _selectedPendidikanLabel,
      _addressController.text,
      pendidikanId: _selectedPendidikanId,
    );

    if (mounted) {
      Navigator.pop(context);
    }
  }

  void _showPendidikanBottomSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        if (_isLoadingPendidikan) {
          return const SizedBox(
            height: 160,
            child: Center(child: CircularProgressIndicator()),
          );
        }
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Text(
                  'Pilih Pendidikan Terakhir',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
              const Divider(),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _listPendidikan.length,
                  itemBuilder: (context, index) {
                    final item = _listPendidikan[index];
                    final isSelected = item.id == _selectedPendidikanId;
                    return ListTile(
                      title: Text(
                        item.displayName,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.normal,
                          color: isSelected
                              ? const Color(0xFF3B82F6)
                              : Colors.black,
                        ),
                      ),
                      trailing: isSelected
                          ? const Icon(Icons.check_rounded,
                              color: Color(0xFF3B82F6))
                          : null,
                      onTap: () {
                        setState(() {
                          _selectedPendidikanId = item.id;
                          _selectedPendidikanLabel = item.displayName;
                        });
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final double statusBarHeight = MediaQuery.paddingOf(context).top;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          CustomAppBar(
            title: 'Edit Data Diri',
            statusBarHeight: statusBarHeight,
            onBack: () => Navigator.pop(context),
          ),
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Data Diri',
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
                          subtitle: const Text(
                            'Nama yang diinput akan tertera di sertifikat (Jika Kompeten)',
                            style: TextStyle(
                              fontSize: 11,
                              color: Color(0xFF1E824C),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        _buildTextField(
                          label: 'NIK',
                          controller: _nikController,
                          hint: 'Masukan 16 digit nomor induk kependudukan',
                          keyboardType: TextInputType.number,
                        ),
                        _buildTextField(
                          label: 'No. Handphone',
                          controller: _phoneController,
                          hint: 'Masukan nomor HP aktif',
                          keyboardType: TextInputType.phone,
                        ),
                        _buildTextField(
                          label: 'Email',
                          controller: _emailController,
                          hint: 'Masukan Email aktif',
                          keyboardType: TextInputType.emailAddress,
                        ),
                        _buildPendidikanField(),
                        _buildTextField(
                          label: 'Alamat',
                          controller: _addressController,
                          hint: 'Masukan alamat Anda sekarang',
                          maxLines: 4,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 48,
                          child: OutlinedButton(
                            onPressed: _isSaving
                                ? null
                                : () => Navigator.pop(context),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Color(0xFFE2E8F0)),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text(
                              'Batal',
                              style: TextStyle(
                                color: Color(0xFF64748B),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: SizedBox(
                          height: 48,
                          child: ElevatedButton(
                            onPressed: _isSaving ? null : _handleSave,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF0F4C81),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              elevation: 0,
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
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
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
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required String hint,
    TextInputType? keyboardType,
    int maxLines = 1,
    Widget? subtitle,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Color(0xFF334155),
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            subtitle,
          ],
          const SizedBox(height: 8),
          TextField(
            controller: controller,
            keyboardType: keyboardType,
            maxLines: maxLines,
            style: const TextStyle(fontSize: 13),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
              filled: true,
              fillColor: Colors.white,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFF0F4C81)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPendidikanField() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Pendidikan Terakhir',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Color(0xFF334155),
            ),
          ),
          const SizedBox(height: 8),
          InkWell(
            onTap: _showPendidikanBottomSheet,
            borderRadius: BorderRadius.circular(8),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
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
                      _selectedPendidikanLabel.isEmpty
                          ? 'Pilih'
                          : _selectedPendidikanLabel,
                      style: TextStyle(
                        fontSize: 13,
                        color: _selectedPendidikanLabel.isEmpty
                            ? const Color(0xFF94A3B8)
                            : Colors.black,
                        fontWeight: _selectedPendidikanLabel.isEmpty
                            ? FontWeight.normal
                            : FontWeight.w500,
                      ),
                    ),
                  ),
                  const Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 14,
                    color: Color(0xFF3B82F6),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
