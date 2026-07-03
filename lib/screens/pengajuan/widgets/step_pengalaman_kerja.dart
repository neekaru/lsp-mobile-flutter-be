import 'package:flutter/material.dart';

class StepPengalamanKerja extends StatelessWidget {
  final String hasWorkExperience;
  final void Function(String value) onExperienceChanged;
  final TextEditingController companyController;
  final TextEditingController positionController;
  final TextEditingController durationController;

  const StepPengalamanKerja({
    super.key,
    required this.hasWorkExperience,
    required this.onExperienceChanged,
    required this.companyController,
    required this.positionController,
    required this.durationController,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Pengalaman Kerja',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E293B),
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Berikan informasi pengalaman kerja dalam bidang yang anda pilih, baik dalam bidang institusi/perusahaan.',
          style: TextStyle(
            fontSize: 13,
            color: Color(0xFF64748B),
            height: 1.4,
          ),
        ),
        const SizedBox(height: 20),
        // Question Card
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '1. Apakah anda memiliki pengalaman kerja pada bidang yang anda pilih saat ini?',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 12),
              _buildStep3RadioOption('Ya, saya punya', 'ya'),
              const SizedBox(height: 4),
              _buildStep3RadioOption('Tidak,saya tidak punya', 'tidak'),
            ],
          ),
        ),
        const SizedBox(height: 20),
        // Experience details form fields
        if (hasWorkExperience == 'ya') ...[
          _buildTextField('Nama Perusahaan/Instansi', 'Masukan nama lengkap', companyController),
          const SizedBox(height: 16),
          _buildTextField('Posisi/Pekerjaan', 'Masukan jobdase atau posisi kerjaan', positionController),
          const SizedBox(height: 16),
          _buildTextField('Lama Bekerja', 'Berapa lama bekerja', durationController),
          const SizedBox(height: 16),
        ],
      ],
    );
  }

  Widget _buildStep3RadioOption(String text, String value) {
    final bool isSelected = hasWorkExperience == value;

    return GestureDetector(
      onTap: () => onExperienceChanged(value),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 6.0),
        color: Colors.transparent,
        child: Row(
          children: [
            Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0xFF3B82F6),
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 9,
                        height: 9,
                        decoration: const BoxDecoration(
                          color: Color(0xFF3B82F6),
                          shape: BoxShape.circle,
                        ),
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                text,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF334155),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, String hint, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13.5,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E293B),
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(
              fontSize: 13,
              color: Color(0xFF94A3B8),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            filled: true,
            fillColor: Colors.white,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFF3B82F6), width: 1.5),
            ),
          ),
          style: const TextStyle(fontSize: 13.5, color: Color(0xFF334155)),
        ),
      ],
    );
  }
}
