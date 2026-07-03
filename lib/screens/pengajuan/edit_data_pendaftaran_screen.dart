import 'package:flutter/material.dart';
import '../../widgets/custom_app_bar.dart';

class EditDataPendaftaranScreen extends StatefulWidget {
  final String currentName;
  final String currentNik;
  final String currentPhone;
  final String currentEmail;
  final String currentPendidikan;
  final String currentAddress;
  final Function(
    String name,
    String nik,
    String phone,
    String email,
    String pendidikan,
    String address,
  ) onSave;

  const EditDataPendaftaranScreen({
    super.key,
    required this.currentName,
    required this.currentNik,
    required this.currentPhone,
    required this.currentEmail,
    required this.currentPendidikan,
    required this.currentAddress,
    required this.onSave,
  });

  @override
  State<EditDataPendaftaranScreen> createState() => _EditDataPendaftaranScreenState();
}

class _EditDataPendaftaranScreenState extends State<EditDataPendaftaranScreen> {
  bool _isSaving = false;
  late TextEditingController _nameController;
  late TextEditingController _nikController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  late TextEditingController _addressController;
  late String _selectedPendidikan;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.currentName);
    _nikController = TextEditingController(text: widget.currentNik);
    _phoneController = TextEditingController(text: widget.currentPhone);
    _emailController = TextEditingController(text: widget.currentEmail);
    _addressController = TextEditingController(text: widget.currentAddress);
    _selectedPendidikan = widget.currentPendidikan;
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

  void _handleSave() async {
    setState(() {
      _isSaving = true;
    });

    // Simulate saving delay
    await Future.delayed(const Duration(milliseconds: 800));

    widget.onSave(
      _nameController.text,
      _nikController.text,
      _phoneController.text,
      _emailController.text,
      _selectedPendidikan,
      _addressController.text,
    );

    if (mounted) {
      Navigator.pop(context);
    }
  }

  void _showPendidikanBottomSheet() {
    final List<String> listPendidikan = [
      'SMA / SMK / Sederajat',
      'D1',
      'D2',
      'D3 Teknik Informasi',
      'D3',
      'S1 Teknik Informatika',
      'S1',
      'S2',
      'S3',
    ];

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
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
                  itemCount: listPendidikan.length,
                  itemBuilder: (context, index) {
                    final item = listPendidikan[index];
                    final isSelected = item == _selectedPendidikan;
                    return ListTile(
                      title: Text(
                        item,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          color: isSelected ? const Color(0xFF3B82F6) : Colors.black,
                        ),
                      ),
                      trailing: isSelected
                          ? const Icon(Icons.check_rounded, color: Color(0xFF3B82F6))
                          : null,
                      onTap: () {
                        setState(() {
                          _selectedPendidikan = item;
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
      body: SafeArea(
        top: false,
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

  Widget _buildLabel(String labelText) {
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
    Widget? subtitle,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLabel(label),
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

  Widget _buildPendidikanField() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLabel('Pendidikan Terakhir'),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: _showPendidikanBottomSheet,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _selectedPendidikan.isEmpty ? 'Pilih' : _selectedPendidikan,
                    style: TextStyle(
                      fontSize: 13,
                      color: _selectedPendidikan.isEmpty ? const Color(0xFF94A3B8) : Colors.black,
                      fontWeight: _selectedPendidikan.isEmpty ? FontWeight.normal : FontWeight.w500,
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
