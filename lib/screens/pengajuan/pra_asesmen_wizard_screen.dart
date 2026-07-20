import 'package:flutter/material.dart';
import '../../widgets/custom_app_bar.dart';
import 'hasil_review_pra_asesmen_screen.dart';
import 'widgets/animated_success_badge.dart';
import 'widgets/step_informasi_skema.dart';
import 'widgets/step_evaluasi_kompetensi.dart';
import 'widgets/step_pengalaman_kerja.dart';
import 'widgets/step_persetujuan_asesi.dart';
import '../../services/sertifikat_service.dart';
import '../../services/asesi_service.dart';
import '../../models/sertifikat_models.dart';

class PraAsesmenWizardScreen extends StatefulWidget {
  final int skemaId;
  final String title;
  final String kodeSkema;

  const PraAsesmenWizardScreen({
    super.key,
    required this.skemaId,
    required this.title,
    required this.kodeSkema,
  });

  @override
  State<PraAsesmenWizardScreen> createState() => _PraAsesmenWizardScreenState();
}

class _PraAsesmenWizardScreenState extends State<PraAsesmenWizardScreen> {
  int _currentStep = 1; // Step 1 to 4
  final Map<int, String> _answers = {}; // idElemen -> 'ya' or 'tidak'

  PraAsesmenInfo? _praAsesmenInfo;
  PraAsesmenKompetensi? _kompetensiData;
  bool _isLoadingInfo = true;
  bool _isLoadingKompetensi = true;
  bool _isSubmitting = false;

  // Step 3 controller/answers
  String _hasWorkExperience = 'ya'; // 'ya' or 'tidak'
  final TextEditingController _companyController = TextEditingController();
  final TextEditingController _positionController = TextEditingController();
  final TextEditingController _durationController = TextEditingController();

  // Step 4 agreements
  bool _agreement1 = false;
  bool _agreement2 = false;
  bool _agreement3 = false;
  bool _agreeTerms = false;

  @override
  void initState() {
    super.initState();
    _loadPraAsesmenInfo();
    _companyController.addListener(_rebuild);
    _positionController.addListener(_rebuild);
    _durationController.addListener(_rebuild);
  }

  Future<void> _loadPraAsesmenInfo() async {
    setState(() {
      _isLoadingInfo = true;
      _isLoadingKompetensi = true;
    });
    try {
      final info = await SertifikatService.getPraAsesmenInfo(
        widget.skemaId,
        widget.title,
        widget.kodeSkema,
      );
      setState(() {
        _praAsesmenInfo = info;
        _isLoadingInfo = false;
      });
    } catch (e) {
      debugPrint('Error loading pra-asesmen info: $e');
      setState(() {
        _isLoadingInfo = false;
      });
    }

    try {
      final komp = await SertifikatService.getPraAsesmenKompetensi(
        widget.skemaId,
        widget.title,
      );
      setState(() {
        _kompetensiData = komp;
        _isLoadingKompetensi = false;
        
        // Initialize default answers with 'ya' for each element
        _answers.clear();
        for (var unit in komp.unitKompetensi) {
          for (var el in unit.elemen) {
            _answers[el.idElemen] = 'ya';
          }
        }
      });
    } catch (e) {
      debugPrint('Error loading pra-asesmen kompetensi: $e');
      setState(() {
        _isLoadingKompetensi = false;
      });
    }
  }

  void _rebuild() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _companyController.dispose();
    _positionController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  void _nextStep() async {
    if (_currentStep < 4) {
      setState(() {
        _currentStep++;
      });
    } else {
      // Step 4: Kirim Jawaban ke API
      setState(() {
        _isSubmitting = true;
      });

      // BE expects { evaluasi: [{ id_elemen, id_kuk?, nilai: K|KB }] }
      final List<Map<String, dynamic>> evaluasi = [];
      if (_kompetensiData != null) {
        for (final unit in _kompetensiData!.unitKompetensi) {
          for (final el in unit.elemen) {
            for (final item in el.assessableItems) {
              final idElemen = item['id_elemen'] as int? ?? el.idElemen;
              final idKuk = item['id_kuk'] as int? ?? 0;
              // wizard UI still keys by id_elemen (ya/tidak)
              final ans = _answers[el.idElemen] ?? 'ya';
              final row = <String, dynamic>{
                'id_elemen': idElemen,
                'nilai': ans == 'tidak' ? 'KB' : 'K',
              };
              if (idKuk > 0) row['id_kuk'] = idKuk;
              evaluasi.add(row);
            }
          }
        }
      }

      final bool success =
          await AsesiService.submitPraAsesmen(widget.skemaId, evaluasi);
      
      setState(() {
        _isSubmitting = false;
      });

      if (success) {
        _showSuccessDialog();
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Gagal mengirim jawaban Pra-Asesmen. Silakan coba lagi.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  void _prevStep() {
    if (_currentStep > 1) {
      setState(() {
        _currentStep--;
      });
    } else {
      Navigator.pop(context);
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          backgroundColor: Colors.white,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const AnimatedSuccessBadge(),
                const SizedBox(height: 24),
                const Text(
                  'Pra Asessment Telah Berhasil',
                  style: TextStyle(
                    color: Color(0xFF1E293B),
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                const Text(
                  'Terimakasih, Anda sudah berhasil mengirim Pra-Asessmen.',
                  style: TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 12.5,
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 28),
                SizedBox(
                  width: 160,
                  height: 44,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(dialogContext).pop(); // Dismiss Dialog
                      // Redirect to Hasil Review Pra-Asesmen Screen
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => HasilReviewPraAsesmenScreen(
                            skemaId: widget.skemaId,
                            title: widget.title,
                            kodeSkema: widget.kodeSkema,
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF5B9FD8),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'OK',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final double statusBarHeight = MediaQuery.paddingOf(context).top;

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: Column(
        children: [
          SizedBox(height: statusBarHeight + 8),
          _buildAppBar(),
          _buildProgressBar(),
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
              child: _buildStepContent(),
            ),
          ),
          _buildBottomActionButtons(),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return CustomAppBar(
      title: 'Pra-Asessment',
      onBack: _prevStep,
      rightWidget: const SizedBox(width: 32),
    );
  }

  Widget _buildProgressBar() {
    final double progress = _currentStep / 4.0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                '$_currentStep / 4',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF64748B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              backgroundColor: const Color(0xFFF1F5F9),
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF5B9FD8)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepContent() {
    switch (_currentStep) {
      case 1:
        return StepInformasiSkema(
          title: _praAsesmenInfo?.namaSkema ?? widget.title,
          kodeSkema: _praAsesmenInfo?.kodeSkema ?? widget.kodeSkema,
          tanggalAsesmen: _praAsesmenInfo?.tanggalAsesmen ?? '',
          tuk: _praAsesmenInfo?.tuk ?? '',
          namaAsesor: _praAsesmenInfo?.namaAsesor ?? '',
          isLoading: _isLoadingInfo,
        );
      case 2:
        return StepEvaluasiKompetensi(
          units: _kompetensiData?.unitKompetensi ?? [],
          answers: _answers,
          onAnswerChanged: (idElemen, value) {
            setState(() {
              _answers[idElemen] = value;
            });
          },
          isLoading: _isLoadingKompetensi,
        );
      case 3:
        return StepPengalamanKerja(
          hasWorkExperience: _hasWorkExperience,
          onExperienceChanged: (value) {
            setState(() {
              _hasWorkExperience = value;
              if (value == 'tidak') {
                _companyController.clear();
                _positionController.clear();
                _durationController.clear();
              }
            });
          },
          companyController: _companyController,
          positionController: _positionController,
          durationController: _durationController,
        );
      case 4:
        return StepPersetujuanAsesi(
          agreement1: _agreement1,
          agreement2: _agreement2,
          agreement3: _agreement3,
          agreeTerms: _agreeTerms,
          onAgreement1Changed: (val) => setState(() => _agreement1 = val),
          onAgreement2Changed: (val) => setState(() => _agreement2 = val),
          onAgreement3Changed: (val) => setState(() => _agreement3 = val),
          onAgreeTermsChanged: (val) => setState(() => _agreeTerms = val),
        );
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildBottomActionButtons() {
    final bool isStep3Valid = _currentStep != 3 || 
        (_hasWorkExperience == 'tidak' || 
         (_companyController.text.isNotEmpty && 
          _positionController.text.isNotEmpty && 
          _durationController.text.isNotEmpty));
          
    final bool isStep4Valid = _currentStep != 4 || 
        (_agreement1 && _agreement2 && _agreement3 && _agreeTerms);

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: SizedBox(
                height: 48,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _prevStep,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD1D1D6),
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: const Color(0xFFE5E5EA),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.arrow_back_rounded, size: 18),
                        SizedBox(width: 8),
                        Text(
                          'Kembali',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              flex: 3,
              child: SizedBox(
                height: 48,
                child: ElevatedButton(
                  onPressed: (isStep3Valid && isStep4Valid && !_isSubmitting) ? _nextStep : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF5B9FD8),
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: const Color(0xFFCBD5E1),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                _currentStep == 4 ? 'Kirim Jawaban' : 'Selanjutnya',
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Icon(
                                _currentStep == 4 ? Icons.send_rounded : Icons.arrow_forward_rounded,
                                size: 18,
                              ),
                            ],
                          ),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
