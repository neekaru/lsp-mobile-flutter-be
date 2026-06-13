import 'package:flutter/material.dart';
import '../../services/auth_repository.dart';

class DataDiriScreen extends StatefulWidget {
  const DataDiriScreen({super.key});

  @override
  State<DataDiriScreen> createState() => _DataDiriScreenState();
}

class _DataDiriScreenState extends State<DataDiriScreen> {
  bool _isEditing = false;
  bool _isSaving = false;

  // Form Controllers
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _nikController;
  late TextEditingController _pobController; // Place of Birth
  late TextEditingController _dobController; // Date of Birth
  late TextEditingController _genderController;
  late TextEditingController _addressController;
  late TextEditingController _educationController;
  late TextEditingController _occupationController;

  @override
  void initState() {
    super.initState();
    final user = AuthRepository.currentUserInstance;
    
    _nameController = TextEditingController(text: user?.name ?? 'Muhammad Hanafi');
    _emailController = TextEditingController(text: user?.email ?? 'muhammad.hanafi@gmail.com');
    _phoneController = TextEditingController(text: '081234567890');
    _nikController = TextEditingController(text: '3174091211990003');
    _pobController = TextEditingController(text: 'Jakarta');
    _dobController = TextEditingController(text: '12 November 1999');
    _genderController = TextEditingController(text: 'Laki-laki');
    _addressController = TextEditingController(text: 'Jl. Kemang Raya No. 10, Mampang Prapatan, Jakarta Selatan');
    _educationController = TextEditingController(text: 'Sarjana Komputer (S1)');
    _occupationController = TextEditingController(text: 'Software Engineer');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _nikController.dispose();
    _pobController.dispose();
    _dobController.dispose();
    _genderController.dispose();
    _addressController.dispose();
    _educationController.dispose();
    _occupationController.dispose();
    super.dispose();
  }

  void _handleSave() async {
    setState(() {
      _isSaving = true;
    });

    // Simulate network delay for premium feel progress indicator
    await Future.delayed(const Duration(milliseconds: 1200));

    if (mounted) {
      setState(() {
        _isSaving = false;
        _isEditing = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.check_circle_rounded, color: Colors.white),
              SizedBox(width: 8),
              Text('Data Diri berhasil diperbarui!'),
            ],
          ),
          backgroundColor: const Color(0xFF2E7D32),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final double statusBarHeight = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            SizedBox(height: statusBarHeight + 8),
            // Circular Back Header (matching StatistikScreen header exactly)
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
                    'Data Diri',
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
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    // Profile Header card
                    _buildProfileHeaderCard(),
                    const SizedBox(height: 20),
                    
                    // Personal Data Card
                    _buildSectionCard(
                      title: 'Data Pribadi',
                      icon: Icons.person_outline_rounded,
                      fields: [
                        _buildField(
                          label: 'Nama Lengkap',
                          controller: _nameController,
                          icon: Icons.badge_outlined,
                          enabled: _isEditing,
                        ),
                        _buildField(
                          label: 'NIK (Nomor Induk Kependudukan)',
                          controller: _nikController,
                          icon: Icons.credit_card_rounded,
                          enabled: _isEditing,
                          keyboardType: TextInputType.number,
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: _buildField(
                                label: 'Tempat Lahir',
                                controller: _pobController,
                                icon: Icons.location_city_rounded,
                                enabled: _isEditing,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildField(
                                label: 'Tanggal Lahir',
                                controller: _dobController,
                                icon: Icons.calendar_today_outlined,
                                enabled: _isEditing,
                              ),
                            ),
                          ],
                        ),
                        _buildField(
                          label: 'Jenis Kelamin',
                          controller: _genderController,
                          icon: Icons.wc_rounded,
                          enabled: _isEditing,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    // Contact Data Card
                    _buildSectionCard(
                      title: 'Informasi Kontak',
                      icon: Icons.contact_mail_outlined,
                      fields: [
                        _buildField(
                          label: 'Alamat Email',
                          controller: _emailController,
                          icon: Icons.mail_outline_rounded,
                          enabled: _isEditing,
                          keyboardType: TextInputType.emailAddress,
                        ),
                        _buildField(
                          label: 'Nomor Telepon / HP',
                          controller: _phoneController,
                          icon: Icons.phone_android_rounded,
                          enabled: _isEditing,
                          keyboardType: TextInputType.phone,
                        ),
                        _buildField(
                          label: 'Alamat Rumah',
                          controller: _addressController,
                          icon: Icons.home_outlined,
                          enabled: _isEditing,
                          maxLines: 2,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    // Education & Job Card
                    _buildSectionCard(
                      title: 'Pendidikan & Pekerjaan',
                      icon: Icons.work_outline_rounded,
                      fields: [
                        _buildField(
                          label: 'Pendidikan Terakhir',
                          controller: _educationController,
                          icon: Icons.school_outlined,
                          enabled: _isEditing,
                        ),
                        _buildField(
                          label: 'Pekerjaan',
                          controller: _occupationController,
                          icon: Icons.business_center_outlined,
                          enabled: _isEditing,
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    
                    // Action Buttons (Edit / Save / Cancel)
                    if (!_isEditing)
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            setState(() {
                              _isEditing = true;
                            });
                          },
                          icon: const Icon(Icons.edit_rounded, size: 18),
                          label: const Text('Edit Data Diri'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF378CE7),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      )
                    else
                      Column(
                        children: [
                          SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: ElevatedButton.icon(
                              onPressed: _isSaving ? null : _handleSave,
                              icon: _isSaving 
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Icon(Icons.save_rounded, size: 18),
                              label: Text(_isSaving ? 'Menyimpan...' : 'Simpan Perubahan'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF10B981),
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: OutlinedButton(
                              onPressed: _isSaving 
                                ? null 
                                : () {
                                    setState(() {
                                      _isEditing = false;
                                    });
                                  },
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: Color(0xFFCBD5E1)),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                foregroundColor: const Color(0xFF64748B),
                              ),
                              child: const Text('Batal'),
                            ),
                          ),
                        ],
                      ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeaderCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF),
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFBFDBFE), width: 2),
            ),
            child: const Center(
              child: Icon(
                Icons.person_rounded,
                size: 50,
                color: Color(0xFF3B82F6),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            _nameController.text,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Asesi LSP Digital',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFF64748B),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required List<Widget> fields,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: const Color(0xFF378CE7), size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
            ],
          ),
          const Divider(height: 24, color: Color(0xFFF1F5F9)),
          ...fields,
        ],
      ),
    );
  }

  Widget _buildField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    bool enabled = false,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.bold,
              color: Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 6),
          TextFormField(
            controller: controller,
            enabled: enabled,
            maxLines: maxLines,
            keyboardType: keyboardType,
            style: TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.bold,
              color: enabled ? const Color(0xFF1E293B) : const Color(0xFF475569),
            ),
            decoration: InputDecoration(
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              prefixIcon: Icon(icon, size: 18, color: const Color(0xFF94A3B8)),
              disabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFF378CE7), width: 1.5),
              ),
              fillColor: enabled ? Colors.white : const Color(0xFFF8FAFC),
              filled: true,
            ),
          ),
        ],
      ),
    );
  }
}
