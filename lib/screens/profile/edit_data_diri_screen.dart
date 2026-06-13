import 'package:flutter/material.dart';

class EditDataDiriScreen extends StatefulWidget {
  final String currentName;
  final String currentEmail;
  final String currentPhone;
  final String currentAddress;
  final Function(String name, String email, String phone, String address) onSave;

  const EditDataDiriScreen({
    super.key,
    required this.currentName,
    required this.currentEmail,
    required this.currentPhone,
    required this.currentAddress,
    required this.onSave,
  });

  @override
  State<EditDataDiriScreen> createState() => _EditDataDiriScreenState();
}

class _EditDataDiriScreenState extends State<EditDataDiriScreen> {
  bool _isSaving = false;
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.currentName);
    _emailController = TextEditingController(text: widget.currentEmail);
    _phoneController = TextEditingController(text: widget.currentPhone);
    _addressController = TextEditingController(text: widget.currentAddress);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  void _handleSave() async {
    setState(() {
      _isSaving = true;
    });

    // Simulate saving delay
    await Future.delayed(const Duration(milliseconds: 1000));

    widget.onSave(
      _nameController.text,
      _emailController.text,
      _phoneController.text,
      _addressController.text,
    );

    if (mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final double statusBarHeight = MediaQuery.of(context).padding.top;
    final blueColor = const Color(0xFF5B9FD8);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            SizedBox(height: statusBarHeight + 8),
            // Header Bar (matching StatistikScreen header exactly)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
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
                    'Edit Data Diri',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(width: 32, height: 32),
                ],
              ),
            ),
            
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildField(
                      label: 'Nama Lengkap',
                      controller: _nameController,
                      hint: 'Masukan nama lengkap',
                    ),
                    _buildField(
                      label: 'Email',
                      controller: _emailController,
                      hint: 'Masukan email',
                      keyboardType: TextInputType.emailAddress,
                    ),
                    _buildField(
                      label: 'No.Handphone',
                      controller: _phoneController,
                      hint: 'Masukan nomor handphone',
                      keyboardType: TextInputType.phone,
                    ),
                    _buildField(
                      label: 'Alamat',
                      controller: _addressController,
                      hint: 'Masukan alamat',
                      maxLines: 3,
                    ),
                    const SizedBox(height: 32),
                    
                    // Bottom Buttons (Batal & Simpan)
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
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: const Text(
                                'Batal',
                                style: TextStyle(
                                  fontSize: 16,
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
                                backgroundColor: blueColor,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
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
                                        fontSize: 16,
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

  Widget _buildField({
    required String label,
    required TextEditingController controller,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: controller,
            maxLines: maxLines,
            keyboardType: keyboardType,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Color(0xFF1E293B),
            ),
            decoration: InputDecoration(
              isDense: true,
              hintText: hint,
              hintStyle: const TextStyle(
                fontSize: 14,
                color: Color(0xFF94A3B8),
                fontWeight: FontWeight.normal,
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFF5B9FD8), width: 1.5),
              ),
              fillColor: Colors.white,
              filled: true,
            ),
          ),
        ],
      ),
    );
  }
}
