import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../models/sertifikat_models.dart';
import '../../widgets/custom_app_bar.dart';

class ValidasiSertifikatScreen extends StatefulWidget {
  final VoidCallback? onBackToHome;

  const ValidasiSertifikatScreen({super.key, this.onBackToHome});

  @override
  State<ValidasiSertifikatScreen> createState() =>
      _ValidasiSertifikatScreenState();
}

class _ValidasiSertifikatScreenState extends State<ValidasiSertifikatScreen> {
  final TextEditingController _documentController = TextEditingController();
  bool _isLoading = false;
  SertifikatValidationResult? _validationResult;
  String? _errorMessage;

  @override
  void dispose() {
    _documentController.dispose();
    super.dispose();
  }

  Future<void> _handleValidate() async {
    final String query = _documentController.text.trim();
    if (query.isEmpty) {
      setState(() {
        _errorMessage = 'No dokumen tidak boleh kosong.';
        _validationResult = null;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _validationResult = null;
    });

    try {
      final result = await ApiService.validateSertifikat(query);
      setState(() {
        _isLoading = false;
        if (result.valid) {
          _validationResult = result;
        } else {
          _errorMessage =
              result.message ?? 'Data tidak ditemukan dalam sistem.';
        }
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Terjadi kesalahan sistem. Silakan coba lagi.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final double statusBarHeight = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      body: Column(
        children: [
          SizedBox(height: statusBarHeight + 8),
          // App Bar - Following 'StatistikScreen' style exactly
          _buildAppBar(),

          Expanded(
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 12.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 1. Validation Form Card (Inspired by user screenshot, with premium styling)
                  _buildValidationInputCard(),

                  const SizedBox(height: 20),

                  // 2. Loading State
                  if (_isLoading) _buildLoadingWidget(),

                  // 3. Validation Results (Matches the API response schema exactly)
                  if (!_isLoading && _validationResult != null)
                    _buildValidationResultCard(),

                  // 4. Error / Not Found State
                  if (!_isLoading && _errorMessage != null) _buildErrorWidget(),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return CustomAppBar(
      title: 'Validasi Sertifikat',
      onBack: () {
        if (widget.onBackToHome != null) {
          widget.onBackToHome!();
        } else {
          Navigator.of(context).pop();
        }
      },
    );
  }

  Widget _buildValidationInputCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
        boxShadow: const [
          BoxShadow(
            color: Color(0x05000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Premium Certificate Shield Icon
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFFDBEAFE),
                      width: 1,
                    ),
                  ),
                  child: const Icon(
                    Icons.verified_user_rounded,
                    color: Color(0xFF2C6C9C),
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),

                // Titles
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Validasi Sertifikat',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Masukan data sertifikat Anda untuk konfirmasi ke dalam database',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey[600],
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Input TextField
            Container(
              height: 48,
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(8),
              ),
              child: TextField(
                controller: _documentController,
                textInputAction: TextInputAction.search,
                onSubmitted: (_) => _handleValidate(),
                decoration: InputDecoration(
                  hintText: 'NO Seri/No Sertifikat/NO Register',
                  hintStyle: const TextStyle(
                    color: Color(0xFF9CA3AF),
                    fontSize: 13,
                  ),
                  prefixIcon: const Icon(
                    Icons.search_rounded,
                    color: Color(0xFF9CA3AF),
                    size: 20,
                  ),
                  suffixIcon: _documentController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(
                            Icons.clear_rounded,
                            color: Color(0xFF9CA3AF),
                            size: 18,
                          ),
                          onPressed: () {
                            setState(() {
                              _documentController.clear();
                            });
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                ),
                style: const TextStyle(fontSize: 14),
                onChanged: (text) {
                  setState(() {});
                },
              ),
            ),
            const SizedBox(height: 16),

            // Submit Button
            Container(
              height: 44,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                gradient: const LinearGradient(
                  colors: [Color(0xFF2C6C9C), Color(0xFF4FA8E8)],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x222C6C9C),
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: _handleValidate,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Periksa Keabsahan',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingWidget() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            CircularProgressIndicator(color: Color(0xFF2C6C9C)),
            SizedBox(height: 16),
            Text(
              'Menghubungi database LSP...',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFFF1F2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFECDD3), width: 1),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: const BoxDecoration(
              color: Color(0xFFFFE4E6),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.warning_amber_rounded,
              color: Color(0xFFE11D48),
              size: 24,
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            'Sertifikat Tidak Ditemukan',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Color(0xFF9F1239),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            _errorMessage ?? 'Data tidak ditemukan dalam sistem.',
            style: const TextStyle(fontSize: 13, color: Color(0xFFBE123C)),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildValidationResultCard() {
    final res = _validationResult!;

    // Status Badge Logic
    Color badgeBgColor = const Color(0xFFD1FAE5);
    Color badgeTextColor = const Color(0xFF065F46);
    String badgeText = 'Aktif';
    if (res.status?.toLowerCase() != 'aktif') {
      badgeBgColor = const Color(0xFFFEE2E2);
      badgeTextColor = const Color(0xFF991B1B);
      badgeText = res.status ?? 'Non-Aktif';
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFD1FAE5), width: 1.5),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header Card Hasil Validasi
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF059669), Color(0xFF10B981)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              children: [
                const Icon(
                  Icons.check_circle_rounded,
                  color: Colors.white,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'KEABSAHAN SERTIFIKAT TERJAMIN',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFFD1FAE5),
                          letterSpacing: 0.5,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Sertifikat Terdaftar & Valid',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: badgeBgColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    badgeText.toUpperCase(),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      color: badgeTextColor,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Body Card Hasil Validasi
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoRow(
                  icon: Icons.person_rounded,
                  label: 'Nama Pemegang',
                  value: res.nama ?? '-',
                ),
                const Divider(height: 24, color: Color(0xFFF3F4F6)),
                _buildInfoRow(
                  icon: Icons.workspace_premium_rounded,
                  label: 'Skema Sertifikasi',
                  value: res.skema ?? '-',
                  valueColor: const Color(0xFF2C6C9C),
                  isBoldValue: true,
                ),
                const Divider(height: 24, color: Color(0xFFF3F4F6)),
                _buildInfoRow(
                  icon: Icons.card_membership_rounded,
                  label: 'No. Sertifikat',
                  value: res.noSertifikat ?? '-',
                ),
                const Divider(height: 24, color: Color(0xFFF3F4F6)),
                _buildInfoRow(
                  icon: Icons.badge_rounded,
                  label: 'No. Registrasi',
                  value: res.noRegistrasi ?? '-',
                ),
                const Divider(height: 24, color: Color(0xFFF3F4F6)),
                _buildInfoRow(
                  icon: Icons.calendar_today_rounded,
                  label: 'Tanggal Terbit',
                  value: res.tanggalTerbit ?? '-',
                ),
                const Divider(height: 24, color: Color(0xFFF3F4F6)),
                _buildInfoRow(
                  icon: Icons.date_range_rounded,
                  label: 'Masa Berlaku',
                  value: res.masaBerlaku ?? '-',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
    bool isBoldValue = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: const Color(0xFF64748B), size: 20),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label.toUpperCase(),
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF94A3B8),
                  letterSpacing: 0.3,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isBoldValue ? FontWeight.bold : FontWeight.w600,
                  color: valueColor ?? const Color(0xFF334155),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
