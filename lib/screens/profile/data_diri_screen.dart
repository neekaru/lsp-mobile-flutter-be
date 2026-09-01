import 'package:material_ui/material_ui.dart';
import 'package:file_picker/file_picker.dart';
import '../../services/auth/auth_repository.dart';
import '../../services/asesor/asesor_service.dart';
import '../../services/api_service.dart';
import '../../utils/url_helper.dart';
import '../../widgets/profile/profile_asesor_widgets.dart';
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
  String? _fotoProfilUrl;
  bool _isLoading = true;
  bool _isUploadingPhoto = false;

  @override
  void initState() {
    super.initState();
    final user = AuthRepository.currentUserInstance;
    
    _nameController = TextEditingController(text: user?.name ?? '');
    _emailController = TextEditingController(text: user?.email ?? '');
    _phoneController = TextEditingController(text: '');
    _addressController = TextEditingController(text: '');
    _fotoProfilUrl = user?.fotoProfilUrl;
    _fetchProfile();
  }

  Future<void> _fetchProfile() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final profile = await AsesorService.getProfile();
      if (profile != null && mounted) {
        setState(() {
          _nameController.text = profile['nama_lengkap']?.toString() ?? profile['nama']?.toString() ?? '';
          _emailController.text = profile['email']?.toString() ?? '';
          _phoneController.text = profile['no_telepon']?.toString() ?? profile['telepon']?.toString() ?? profile['phone']?.toString() ?? '';
          _addressController.text = profile['alamat']?.toString() ?? '';
          if (profile['foto_profil_url'] != null && profile['foto_profil_url'].toString().isNotEmpty) {
            _fotoProfilUrl = profile['foto_profil_url'].toString();
          }
        });
      }
    } catch (_) {}
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _pickAndUploadPhoto() async {
    try {
      final file = await FilePicker.pickFile(
        type: FileType.image,
      );
      if (file != null) {
        final filePath = file.path;
        if (filePath == null) return;
        setState(() => _isUploadingPhoto = true);
        final uploaded = await ApiService.uploadProfilePhoto(filePath);
        if (!mounted) return;
        if (uploaded != null && uploaded['foto_profil_url'] != null) {
          final photoUrl = uploaded['foto_profil_url'].toString();
          setState(() {
            _fotoProfilUrl = photoUrl;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Row(
                children: [
                  Icon(Icons.check_circle_outline, color: Colors.white),
                  SizedBox(width: 8),
                  Text('Foto profil berhasil diperbarui!'),
                ],
              ),
              backgroundColor: Color(0xFF2E7D32),
              behavior: SnackBarBehavior.floating,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Gagal mengunggah foto profil'),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('Error picking profile photo: $e');
    } finally {
      if (mounted) setState(() => _isUploadingPhoto = false);
    }
  }

  void _showPhotoPicker() {
    showProfilePhotoPicker(
      context: context,
      onPickPhoto: _pickAndUploadPhoto,
    );
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
    final user = AuthRepository.currentUserInstance;

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
                Builder(
                  builder: (context) {
                    final rawPhoto = _fotoProfilUrl ?? user?.fotoProfilUrl;
                    final photoUrl = (rawPhoto != null && rawPhoto.isNotEmpty)
                        ? UrlHelper.resolveUrl(rawPhoto)
                        : null;
                    return Stack(
                      children: [
                        GestureDetector(
                          onTap: _showPhotoPicker,
                          child: Container(
                            width: 110,
                            height: 110,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.6),
                                width: 3,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.1),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: ClipOval(
                              child: _isUploadingPhoto
                                  ? const Center(
                                      child: SizedBox(
                                        width: 32,
                                        height: 32,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 3,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                  Color(0xFF5B9FD8)),
                                        ),
                                      ),
                                    )
                                  : (photoUrl != null && photoUrl.isNotEmpty)
                                      ? Image.network(
                                          photoUrl,
                                          width: 110,
                                          height: 110,
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, error,
                                                  stackTrace) =>
                                              const Center(
                                            child: Icon(
                                              Icons.person_rounded,
                                              size: 75,
                                              color: Color(0xFF94A3B8),
                                            ),
                                          ),
                                        )
                                      : const Center(
                                          child: Icon(
                                            Icons.person_rounded,
                                            size: 75,
                                            color: Color(0xFF94A3B8),
                                          ),
                                        ),
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: GestureDetector(
                            onTap: _showPhotoPicker,
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
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 16),
                
                // Badge Role
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.35),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    user?.role == 'asesor' ? 'Aktif' : 'Peserta',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (_isLoading)
            const LinearProgressIndicator(
              minHeight: 2,
              backgroundColor: Colors.transparent,
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF5B9FD8)),
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
                              currentPhone: _phoneController.text,
                              currentEmail: _emailController.text,
                              currentAddress: _addressController.text,
                              onSave: (name, phone, email, address) {
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
