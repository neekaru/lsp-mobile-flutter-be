import 'package:flutter/material.dart';

class StepPersetujuanAsesi extends StatelessWidget {
  final bool agreement1;
  final bool agreement2;
  final bool agreement3;
  final bool agreeTerms;
  final ValueChanged<bool> onAgreement1Changed;
  final ValueChanged<bool> onAgreement2Changed;
  final ValueChanged<bool> onAgreement3Changed;
  final ValueChanged<bool> onAgreeTermsChanged;

  const StepPersetujuanAsesi({
    super.key,
    required this.agreement1,
    required this.agreement2,
    required this.agreement3,
    required this.agreeTerms,
    required this.onAgreement1Changed,
    required this.onAgreement2Changed,
    required this.onAgreement3Changed,
    required this.onAgreeTermsChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Peach warning/info banner
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFFFEEAD2),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.info_outline_rounded,
                color: Color(0xFFD97706),
                size: 20,
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'Pastikan semua informasi sudah benar , Setelah dikirim,Anda tidak dapat lagi mengubah jawaban Anda.',
                  style: TextStyle(
                    color: Color(0xFF92400E),
                    fontSize: 12,
                    height: 1.45,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          'Pernyataan Kesiapan & Persetujuan Asessi',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E293B),
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Bacalah pernyataan berikut dengan seksama sebelum mengirimkan Pra-Asessment',
          style: TextStyle(
            fontSize: 13,
            color: Color(0xFF64748B),
            height: 1.4,
          ),
        ),
        const SizedBox(height: 20),
        _buildStatementCard(
          "Saya telah membaca dan memahami seluruh persyaratan dan peraturan asessmen yang berlaku.",
          agreement1,
          onAgreement1Changed,
        ),
        _buildStatementCard(
          "Seluruh informasi yang telah saya berikan adalah benar dan dapat dipertanggung jawabkan.",
          agreement2,
          onAgreement2Changed,
        ),
        _buildStatementCard(
          "Saya bersedia mengikuti asessmen sesuai jadwal dan ketentuan yang telah ditetapkan oleh pihak LSP.",
          agreement3,
          onAgreement3Changed,
        ),
        const SizedBox(height: 12),
        // Square Checkbox Agreement at bottom
        CheckboxListTile(
          value: agreeTerms,
          onChanged: (val) => onAgreeTermsChanged(val ?? false),
          title: const Text(
            'Saya setuju dengan syarat dan ketentuan diatas',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Color(0xFF334155)),
          ),
          controlAffinity: ListTileControlAffinity.leading,
          contentPadding: EdgeInsets.zero,
          activeColor: const Color(0xFF3B82F6),
        ),
      ],
    );
  }

  Widget _buildStatementCard(String text, bool value, ValueChanged<bool> onChanged) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: InkWell(
        onTap: () => onChanged(!value),
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFF3B82F6),
                    width: 2,
                  ),
                ),
                child: value
                    ? Center(
                        child: Container(
                          width: 10,
                          height: 10,
                          decoration: const BoxDecoration(
                            color: Color(0xFF3B82F6),
                            shape: BoxShape.circle,
                          ),
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  text,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF334155),
                    height: 1.45,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
