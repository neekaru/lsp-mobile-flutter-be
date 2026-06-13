import 'package:flutter/material.dart';
import '../../services/auth_repository.dart';
import '../../models/auth_models.dart';
import 'edit_data_diri_screen.dart';

class DataDiriScreen extends StatefulWidget {
  const DataDiriScreen({super.key});

  @override
  State<DataDiriScreen> createState() => _DataDiriScreenState();
}

class _DataDiriScreenState extends State<DataDiriScreen> {
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;

  @override
  void initState() {
    super.initState();
    final user = AuthRepository.currentUserInstance;
    
    _nameController = TextEditingController(text: user?.name ?? 'Muhammad Hanafi');
    _emailController = TextEditingController(text: user?.email ?? 'muhammadhanafi_12@gmail.com');
    _phoneController = TextEditingController(text: '0858978655634');
    _addressController = TextEditingController(text: 'Jl.Pramuka km 4,5 No 34, Baamang Hulu, Kalimantan Tengah');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double statusBarHeight = MediaQuery.of(context).padding.top;
    final blueColor = const Color(0xFF5B9FD8);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Blue Header Container
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: blueColor,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(32),
                bottomRight: Radius.circular(32),
              ),
            ),
            padding: EdgeInsets.only(
              top: statusBarHeight + 12,
              bottom: 24,
              left: 20,
              right: 20,
            ),
            child: Column(
              children: [
                // Top navigation: "< Data Diri" aligned left
                Align(
                  alignment: Alignment.centerLeft,
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: const Color(0xFF1E293B),
                              width: 1.5,
                            ),
                          ),
                          child: const Icon(
                            Icons.chevron_left_rounded,
                            color: Color(0xFF1E293B),
                            size: 16,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Data Diri',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                
                // Profile Avatar Photo Stack
                Stack(
                  children: [
                    Container(
                      width: 110,
                      height: 110,
                      decoration: const BoxDecoration(
                        color: Color(0xFFE2E8F0),
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.person_rounded,
                          size: 75,
                          color: Color(0xFF94A3B8),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 4,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.photo_camera_outlined,
                          color: blueColor,
                          size: 16,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                // Badge "Peserta"
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.35),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'Peserta',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Form Fields Section
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
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
                  ),
                  _buildField(
                    label: 'No.Handphone',
                    controller: _phoneController,
                    hint: 'Masukan nomor handphone',
                  ),
                  _buildField(
                    label: 'Alamat',
                    controller: _addressController,
                    hint: 'Masukan alamat',
                    maxLines: 3,
                  ),
                  const SizedBox(height: 32),
                  
                  // Bottom Button (Edit Data Diri)
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EditDataDiriScreen(
                              currentName: _nameController.text,
                              currentEmail: _emailController.text,
                              currentPhone: _phoneController.text,
                              currentAddress: _addressController.text,
                              onSave: (name, email, phone, address) {
                                setState(() {
                                  _nameController.text = name;
                                  _emailController.text = email;
                                  _phoneController.text = phone;
                                  _addressController.text = address;
                                });
                                final user = AuthRepository.currentUserInstance;
                                if (user != null) {
                                  AuthRepository.currentUserInstance = AuthUser(
                                    id: user.id,
                                    account: user.account,
                                    name: name,
                                    role: user.role,
                                    roles: user.roles,
                                    email: email,
                                  );
                                }
                              },
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: blueColor,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        'Edit Data Diri',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildField({
    required String label,
    required TextEditingController controller,
    required String hint,
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
            readOnly: true,
            maxLines: maxLines,
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
                borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
              fillColor: const Color(0xFFFAFAFA),
              filled: true,
            ),
          ),
        ],
      ),
    );
  }
}
