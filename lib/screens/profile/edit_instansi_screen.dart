import 'package:flutter/material.dart';
import '../../widgets/custom_app_bar.dart';

class EditInstansiScreen extends StatefulWidget {
  final String currentType;
  final Map<String, String> currentData;
  final Function(String type, Map<String, String> data) onSave;

  const EditInstansiScreen({
    super.key,
    required this.currentType,
    required this.currentData,
    required this.onSave,
  });

  @override
  State<EditInstansiScreen> createState() => _EditInstansiScreenState();
}

class _EditInstansiScreenState extends State<EditInstansiScreen> {
  late String _selectedType;
  bool _isSaving = false;

  // Controllers for Mahasiswa
  late TextEditingController _univController;
  late TextEditingController _facultyController;
  late TextEditingController _majorController;
  late TextEditingController _nimController;

  // Controllers for Karyawan
  late TextEditingController _companyController;
  late TextEditingController _jobTitleController;
  late TextEditingController _jobFieldController;
  late TextEditingController _workDurationController;

  // Controllers for Wirausaha
  late TextEditingController _businessNameController;
  late TextEditingController _businessFieldController;
  late TextEditingController _establishedYearController;

  // Shared Controller
  late TextEditingController _addressController;

  @override
  void initState() {
    super.initState();
    _selectedType = widget.currentType;

    // Initialize Mahasiswa values
    _univController = TextEditingController(
      text: widget.currentType == 'Mahasiswa' ? widget.currentData['Nama Perguruan Tinggi'] ?? '' : 'Politeknik Sampit',
    );
    _facultyController = TextEditingController(
      text: widget.currentType == 'Mahasiswa' ? widget.currentData['Falkutas'] ?? '' : 'Teknologi Informasi',
    );
    _majorController = TextEditingController(
      text: widget.currentType == 'Mahasiswa' ? widget.currentData['Program Studi'] ?? '' : 'Sisitem Informasi',
    );
    _nimController = TextEditingController(
      text: widget.currentType == 'Mahasiswa' ? widget.currentData['NIM'] ?? '' : '087685674568',
    );

    // Initialize Karyawan values
    _companyController = TextEditingController(
      text: widget.currentType == 'Karyawan' ? widget.currentData['Nama Perusahaan'] ?? '' : 'PT Digital Nusantara',
    );
    _jobTitleController = TextEditingController(
      text: widget.currentType == 'Karyawan' ? widget.currentData['Jabatan'] ?? '' : 'Senior Developer',
    );
    _jobFieldController = TextEditingController(
      text: widget.currentType == 'Karyawan' ? widget.currentData['Bidang Pekerjaan'] ?? '' : 'Teknologi Informasi',
    );
    _workDurationController = TextEditingController(
      text: widget.currentType == 'Karyawan' ? widget.currentData['Lama Bekerja'] ?? '' : '3 Tahun',
    );

    // Initialize Wirausaha values
    _businessNameController = TextEditingController(
      text: widget.currentType == 'Wirausaha' ? widget.currentData['Nama Usaha'] ?? '' : 'Creative Studio',
    );
    _businessFieldController = TextEditingController(
      text: widget.currentType == 'Wirausaha' ? widget.currentData['Bidang Usaha'] ?? '' : 'Jasa Desain',
    );
    _establishedYearController = TextEditingController(
      text: widget.currentType == 'Wirausaha' ? widget.currentData['Tahun Berdiri'] ?? '' : '2021',
    );

    // Initialize Shared Address value
    _addressController = TextEditingController(
      text: widget.currentData['Alamat'] ?? 'Jl. Wengga Metropolitan',
    );
  }

  @override
  void dispose() {
    _univController.dispose();
    _facultyController.dispose();
    _majorController.dispose();
    _nimController.dispose();
    _companyController.dispose();
    _jobTitleController.dispose();
    _jobFieldController.dispose();
    _workDurationController.dispose();
    _businessNameController.dispose();
    _businessFieldController.dispose();
    _establishedYearController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  void _showTypeSelectorBottomSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      backgroundColor: Colors.white,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Text(
                  'Pilih Status Pekerjaan',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                ),
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.school_rounded, color: Color(0xFF378CE7)),
                title: const Text('Mahasiswa', style: TextStyle(fontWeight: FontWeight.bold)),
                onTap: () {
                  setState(() {
                    _selectedType = 'Mahasiswa';
                  });
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.business_center_rounded, color: Color(0xFF378CE7)),
                title: const Text('Karyawan', style: TextStyle(fontWeight: FontWeight.bold)),
                onTap: () {
                  setState(() {
                    _selectedType = 'Karyawan';
                  });
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.store_rounded, color: Color(0xFF378CE7)),
                title: const Text('Wirausaha', style: TextStyle(fontWeight: FontWeight.bold)),
                onTap: () {
                  setState(() {
                    _selectedType = 'Wirausaha';
                  });
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _handleSave() async {
    setState(() {
      _isSaving = true;
    });

    // Simulate saving delay
    await Future.delayed(const Duration(milliseconds: 1000));

    Map<String, String> savedData = {};
    if (_selectedType == 'Mahasiswa') {
      savedData = {
        'Nama Perguruan Tinggi': _univController.text,
        'Falkutas': _facultyController.text,
        'Program Studi': _majorController.text,
        'NIM': _nimController.text,
        'Alamat': _addressController.text,
      };
    } else if (_selectedType == 'Karyawan') {
      savedData = {
        'Nama Perusahaan': _companyController.text,
        'Jabatan': _jobTitleController.text,
        'Bidang Pekerjaan': _jobFieldController.text,
        'Lama Bekerja': _workDurationController.text,
        'Alamat': _addressController.text,
      };
    } else {
      savedData = {
        'Nama Usaha': _businessNameController.text,
        'Bidang Usaha': _businessFieldController.text,
        'Tahun Berdiri': _establishedYearController.text,
        'Alamat': _addressController.text,
      };
    }

    widget.onSave(_selectedType, savedData);

    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.check_circle_rounded, color: Colors.white),
              SizedBox(width: 8),
              Text('Informasi Instansi berhasil disimpan!'),
            ],
          ),
          backgroundColor: const Color(0xFF2E7D32),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  IconData _getTypeIcon(String type) {
    switch (type) {
      case 'Mahasiswa':
        return Icons.school_rounded;
      case 'Karyawan':
        return Icons.business_center_rounded;
      case 'Wirausaha':
        return Icons.store_rounded;
      default:
        return Icons.school_rounded;
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
            // Header Bar
            const CustomAppBar(
              title: 'Edit Instansi / Lembaga',
              rightWidget: SizedBox(width: 32),
            ),
            
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Status Selection Row
                    Row(
                      children: [
                        // Dropdown Selector Button
                        Expanded(
                          child: GestureDetector(
                            onTap: _showTypeSelectorBottomSheet,
                            child: Container(
                              height: 48,
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF1F5F9),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: const Color(0xFFE2E8F0)),
                              ),
                              child: Row(
                                children: [
                                  Icon(_getTypeIcon(_selectedType), color: const Color(0xFF378CE7), size: 20),
                                  const SizedBox(width: 10),
                                  Text(
                                    _selectedType,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF1E293B),
                                    ),
                                  ),
                                  const Spacer(),
                                  const Icon(Icons.chevron_right_rounded, color: Color(0xFF378CE7), size: 22),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        
                        // "Peserta" Badge
                        Container(
                          height: 48,
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEFF6FF),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: const Color(0xFFBFDBFE)),
                          ),
                          alignment: Alignment.center,
                          child: const Text(
                            'Peserta',
                            style: TextStyle(
                              color: Color(0xFF3B82F6),
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Dynamic Fields based on status choice
                    if (_selectedType == 'Mahasiswa') ...[
                      _buildField(
                        label: 'Nama Perguruan Tinggi',
                        controller: _univController,
                        hint: 'Masukan nama perguruan tinggi',
                      ),
                      _buildField(
                        label: 'Falkutas',
                        controller: _facultyController,
                        hint: 'Masukan nama falkutas',
                      ),
                      _buildField(
                        label: 'Program Studi',
                        controller: _majorController,
                        hint: 'Masukan nama jurusan',
                      ),
                      _buildField(
                        label: 'NIM(Nomor Induk Mahasiswa)',
                        controller: _nimController,
                        hint: 'Masukan nomor induk mahasiswa',
                        keyboardType: TextInputType.number,
                      ),
                    ] else if (_selectedType == 'Karyawan') ...[
                      _buildField(
                        label: 'Nama Perusahaan',
                        controller: _companyController,
                        hint: 'Masukan nama perusahaan lengkap',
                      ),
                      _buildField(
                        label: 'Jabatan',
                        controller: _jobTitleController,
                        hint: 'Masukan nama jabatan',
                      ),
                      _buildField(
                        label: 'Bidang Pekerjaan',
                        controller: _jobFieldController,
                        hint: 'Bidang pekerjaan apa',
                      ),
                      _buildField(
                        label: 'Lama Bekerja',
                        controller: _workDurationController,
                        hint: 'Lama bekerja',
                      ),
                    ] else ...[
                      _buildField(
                        label: 'Nama Usaha',
                        controller: _businessNameController,
                        hint: 'Masukan nama usaha lengkap',
                      ),
                      _buildField(
                        label: 'Bidang Usaha',
                        controller: _businessFieldController,
                        hint: 'Masukan nama bidang usaha',
                      ),
                      _buildField(
                        label: 'Tahun Berdiri',
                        controller: _establishedYearController,
                        hint: 'Kapan usaha berdiri',
                        keyboardType: TextInputType.number,
                      ),
                    ],

                    // Shared Address field
                    _buildField(
                      label: 'Alamat',
                      controller: _addressController,
                      hint: 'Masukan alamat lengkap',
                      maxLines: 3,
                    ),
                    const SizedBox(height: 32),

                    // Bottom Buttons
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
                                backgroundColor: const Color(0xFF378CE7),
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
              fontSize: 13,
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
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFF378CE7), width: 1.5),
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
