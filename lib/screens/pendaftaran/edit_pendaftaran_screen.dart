import 'package:material_ui/material_ui.dart';
import '../../widgets/common/custom_app_bar.dart';
import '../../widgets/common/status_notification_dialog.dart';
import 'widgets/step1_persyaratan_asessi.dart';
import 'widgets/step2_data_peserta.dart';
import 'widgets/step3_jadwal.dart';
import 'widgets/step4_biodata_peserta.dart';

class EditPendaftaranScreen extends StatefulWidget {
  final String namaPemohon;
  final String skemaSertifikasi;
  final int? permohonanId;

  const EditPendaftaranScreen({
    super.key,
    this.namaPemohon = 'Asesi Demo',
    this.skemaSertifikasi = 'Digital Marketing',
    this.permohonanId,
  });

  @override
  State<EditPendaftaranScreen> createState() => _EditPendaftaranScreenState();
}

class _EditPendaftaranScreenState extends State<EditPendaftaranScreen> {
  int _currentStep = 1;
  final _step4Key = GlobalKey<Step4BiodataPesertaState>();

  void _handleNext() {
    if (_currentStep < 4) {
      setState(() {
        _currentStep++;
      });
    } else {
      // Step 4: save biodata via PUT then show success
      _step4Key.currentState?.saveData().then((_) {
        if (!mounted) return;
        StatusNotificationDialog.showSuccess(
          context: context,
          title: 'Perubahan Telah Tersimpan',
          onOk: () {
            Navigator.pop(context);
          },
        );
      });
    }
  }

  void _handleBack() {
    if (_currentStep > 1) {
      setState(() {
        _currentStep--;
      });
    } else {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            CustomAppBar(
              title: 'Edit Permohonan',
              onBack: _handleBack,
            ),
            _buildStepperHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: _buildStepContent(),
              ),
            ),
            // Bottom Action Buttons (Batal/Kembali & Selanjutnya)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 46,
                      child: ElevatedButton(
                        onPressed: _handleBack,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFCBD5E1),
                          foregroundColor: const Color(0xFF334155),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text(
                          _currentStep == 1 ? 'Batal' : 'Kembali',
                          style: const TextStyle(
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
                      height: 46,
                      child: ElevatedButton(
                        onPressed: _handleNext,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF60A5FA),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text(
                          _currentStep == 4 ? 'Simpan Perubahan' : 'Selanjutnya',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepContent() {
    switch (_currentStep) {
      case 1:
        return Step1PersyaratanAsessi(permohonanId: widget.permohonanId);
      case 2:
        return Step2DataPeserta(
          namaPemohon: widget.namaPemohon,
          skemaSertifikasi: widget.skemaSertifikasi,
          permohonanId: widget.permohonanId,
        );
      case 3:
        return Step3Jadwal(permohonanId: widget.permohonanId);
      case 4:
        return Step4BiodataPeserta(key: _step4Key, permohonanId: widget.permohonanId);
      default:
        return Step1PersyaratanAsessi(permohonanId: widget.permohonanId);
    }
  }

  // Stepper Header (4 circular steps matching screenshots exactly)
  Widget _buildStepperHeader() {
    final steps = [
      {'number': 1, 'title': 'Persyaratan Asessi'},
      {'number': 2, 'title': 'Data Peserta'},
      {'number': 3, 'title': 'Jadwal'},
      {'number': 4, 'title': 'Biodata Peserta'},
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: List.generate(steps.length, (index) {
          final stepNumber = index + 1;
          final isActive = _currentStep == stepNumber;
          final title = steps[index]['title'] as String;

          return Expanded(
            child: Column(
              children: [
                Row(
                  children: [
                    // Left connector line
                    Expanded(
                      child: Container(
                        height: 1.5,
                        color: index == 0 ? Colors.transparent : const Color(0xFFCBD5E1),
                      ),
                    ),

                    // Number Circle (Light Blue for active step)
                    Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isActive ? const Color(0xFFBFDBFE) : Colors.white,
                        border: Border.all(
                          color: isActive ? const Color(0xFF3B82F6) : const Color(0xFFCBD5E1),
                          width: 1.5,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          '$stepNumber',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: isActive ? const Color(0xFF1D4ED8) : const Color(0xFF64748B),
                          ),
                        ),
                      ),
                    ),

                    // Right connector line
                    Expanded(
                      child: Container(
                        height: 1.5,
                        color: index == steps.length - 1 ? Colors.transparent : const Color(0xFFCBD5E1),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),

                // Step Subtitle Text
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                    color: isActive ? const Color(0xFF1D4ED8) : const Color(0xFF64748B),
                    height: 1.2,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}
