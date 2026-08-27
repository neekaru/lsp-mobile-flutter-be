// ignore_for_file: deprecated_member_use
import 'package:material_ui/material_ui.dart';
import '../../widgets/common/custom_app_bar.dart';

import '../../widgets/pengajuan/step_indicator.dart';
import '../../widgets/pengajuan/data_pengajuan_form.dart';
import '../../widgets/pengajuan/data_pribadi_form.dart';
import '../../widgets/pengajuan/data_pekerjaan_form.dart';
import '../../widgets/pengajuan/dokumen_portofolio_form.dart';
import '../../widgets/pengajuan/asesmen_mandiri_form.dart';
import '../../widgets/pengajuan/unit_kompetensi_detail.dart';
import '../../widgets/pengajuan/dokumen_persyaratan_form.dart';
import 'asesmen_mandiri_uji_screen.dart';
import 'pengajuan_sertifikat_data_logic.dart';
import 'pengajuan_sertifikat_flow_logic.dart';
import 'pengajuan_sertifikat_skema_logic.dart';

class PengajuanSertifikatScreen extends StatefulWidget {
  /// Pre-select skema when opened from Detail Skema → Daftar Sekarang.
  final int? initialSkemaId;
  final String? initialSkemaName;

  const PengajuanSertifikatScreen({
    super.key,
    this.initialSkemaId,
    this.initialSkemaName,
  });

  @override
  State<PengajuanSertifikatScreen> createState() => PengajuanSertifikatScreenState();
}

class PengajuanSertifikatScreenState extends State<PengajuanSertifikatScreen>
    with
        PengajuanSertifikatSkemaLogic,
        PengajuanSertifikatDataLogic,
        PengajuanSertifikatFlowLogic {
  @override
  void initState() {
    super.initState();
    cachedUnitKompetensi = [];
    loadInitialData();
  }


  @override
  void dispose() {
    nikController.dispose();
    namaLengkapController.dispose();
    tempatLahirController.dispose();
    tanggalLahirController.dispose();
    alamatDomisiliController.dispose();
    noTelpController.dispose();
    emailController.dispose();
    namaSekolahController.dispose();
    jurusanController.dispose();
    namaPerusahaanController.dispose();
    jabatanController.dispose();
    alamatPerusahaanController.dispose();
    kodeposPerusahaanController.dispose();
    telpPerusahaanController.dispose();
    emailPerusahaanController.dispose();
    super.dispose();
  }


  String get appBarTitle {
    switch (currentStep) {
      case 0:
        return 'Pengajuan Sertifikat';
      case 1:
      case 2:
      case 3:
        return 'Profil Peserta';
      case 4:
        return 'Dokumen Portofolio';
      case 5:
        return activeUnitDetailIndex != null ? 'Detail Uji Kompetensi' : 'Asesmen Mandiri';
      default:
        return 'Pengajuan Sertifikat';
    }
  }

  @override
  Widget build(BuildContext context) {
    // PERF: paddingOf only subscribes to padding changes (status bar).
    // MediaQuery.of(context) subscribes to ALL changes including keyboard
    // viewInsets — causing a full tree rebuild (15+ fields) on every
    // keyboard open/close. That was the #1 cause of lag.
    final double statusBarHeight = MediaQuery.paddingOf(context).top;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F8),
      body: Column(
        children: [
          SizedBox(height: statusBarHeight + 8),
          buildAppBar(),
          if (currentStep != 5 || activeUnitDetailIndex == null)
            StepIndicator(currentStep: currentStep),
          Expanded(
            child: RepaintBoundary(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  padding: const EdgeInsets.all(20.0),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(Radius.circular(16)),
                    boxShadow: [
                      BoxShadow(
                        color: Color(0x0A000000), // black with 4% opacity
                        blurRadius: 10,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: buildCurrentFormStep(),
                ),
              ),
            ),
          ),
          buildBottomActionButtons(),
        ],
      ),
    );
  }

  Widget buildAppBar() {
    return CustomAppBar(
      title: appBarTitle,
      onBack: previousStep,
    );
  }

  Widget buildCurrentFormStep() {
    switch (currentStep) {
      case 0:
        return DataPengajuanForm(
          selectedSkema: selectedSkemaId,
          selectedJadwal: selectedJadwalId,
          selectedSumberAnggaran: selectedSumberAnggaranId,
          selectedPemberiAnggaran: selectedPemberiAnggaranId,
          listSkema: masterSkemaList,
          listJadwal: masterJadwalList,
          listSumberAnggaran: masterSumberAnggaranList,
          listPemberiAnggaran: masterPemberiAnggaranList,
          isLoadingSkema: isLoadingSkema,
          isLoadingJadwal: isLoadingJadwal,
          isLoadingSumberAnggaran: isLoadingSumberAnggaran,
          isLoadingPemberiAnggaran: isLoadingPemberiAnggaran,
          onSkemaChanged: (val) async {
            String? skemaName;
            setState(() {
              selectedSkemaId = val;
              selectedJadwalId = null;
              masterJadwalList = [];
              if (val != null) {
                try {
                  final selected =
                      masterSkemaList.firstWhere((item) => item.id == val);
                  selectedSkema = selected.namaSkema;
                  skemaName = selected.namaSkema;
                } catch (_) {
                  selectedSkema = null;
                }
                clearUnitPersyaratan();
              } else {
                selectedSkema = null;
                clearUnitPersyaratan();
              }
            });
            // Warning FE saat pilih skema (jika sudah login asesi)
            if (val != null && val > 0) {
              final already = await isAlreadyRegisteredOnSkema(val);
              if (already && mounted) {
                await showAlreadyRegisteredWarning(skemaName: skemaName);
                return; // skema/jadwal sudah di-reset di warning
              }
            }
            if (val != null && mounted && selectedSkemaId == val) {
              fetchMasterJadwal(val);
              fetchSkemaUnitPersyaratan(val);
            }
          },
          onJadwalChanged: (val) {
            // Larang pilih jadwal jika skema belum valid
            if (selectedSkemaId == null) return;
            setState(() {
              selectedJadwalId = val;
            });
          },
          onSumberAnggaranChanged: (val) {
            setState(() {
              selectedSumberAnggaranId = val;
              selectedPemberiAnggaranId = null;
              masterPemberiAnggaranList = [];
            });
            if (val != null) {
              fetchMasterPemberiAnggaran(val);
            }
          },
          onPemberiAnggaranChanged: (val) {
            setState(() {
              selectedPemberiAnggaranId = val;
            });
          },
        );
      case 1:
        return DataPribadiForm(
          nikController: nikController,
          namaLengkapController: namaLengkapController,
          jenisKelamin: jenisKelamin,
          tempatLahirController: tempatLahirController,
          tanggalLahirController: tanggalLahirController,
          alamatDomisiliController: alamatDomisiliController,
          selectedProvinsi: selectedProvinsi,
          selectedKota: selectedKota,
          selectedKecamatan: selectedKecamatan,
          noTelpController: noTelpController,
          emailController: emailController,
          selectedPendidikanId: selectedPendidikanId,
          namaSekolahController: namaSekolahController,
          jurusanController: jurusanController,
          listProvinsi: listProvinsi,
          listKabupaten: listKabupaten,
          listKecamatan: listKecamatan,
          listPendidikan: listPendidikan,
          isLoadingProvinsi: isLoadingProvinsi,
          isLoadingKabupaten: isLoadingKabupaten,
          isLoadingKecamatan: isLoadingKecamatan,
          isLoadingPendidikan: isLoadingPendidikan,
          onJenisKelaminChanged: (val) {
            setState(() {
              jenisKelamin = val!;
            });
          },
          onProvinsiChanged: (val) {
            setState(() {
              selectedProvinsi = val;
              selectedKota = null;
              selectedKecamatan = null;
              listKabupaten = [];
              listKecamatan = [];
            });
            if (val != null) {
              fetchKabupaten(val);
            }
          },
          onKotaChanged: (val) {
            setState(() {
              selectedKota = val;
              selectedKecamatan = null;
              listKecamatan = [];
            });
            if (val != null) {
              fetchKecamatan(val);
            }
          },
          onKecamatanChanged: (val) {
            setState(() {
              selectedKecamatan = val;
            });
          },
          onPendidikanChanged: (val) {
            setState(() {
              selectedPendidikanId = val;
            });
          },
          onTanggalLahirTap: () async {
            DateTime? pickedDate = await showDatePicker(
              context: context,
              initialDate: DateTime.now().subtract(const Duration(days: 365 * 18)),
              firstDate: DateTime(1950),
              lastDate: DateTime.now(),
            );
            if (pickedDate != null) {
              setState(() {
                tanggalLahirController.text =
                    "${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}";
              });
            }
          },
        );
      case 2:
        return DataPekerjaanForm(
          selectedPekerjaanId: selectedPekerjaanId,
          listPekerjaan: listPekerjaan,
          isLoadingPekerjaan: isLoadingPekerjaan,
          namaPerusahaanController: namaPerusahaanController,
          jabatanController: jabatanController,
          alamatPerusahaanController: alamatPerusahaanController,
          kodeposPerusahaanController: kodeposPerusahaanController,
          telpPerusahaanController: telpPerusahaanController,
          emailPerusahaanController: emailPerusahaanController,
          onPekerjaanChanged: (val) {
            setState(() {
              selectedPekerjaanId = val;
            });
          },
        );
      case 3:
        return DokumenPersyaratanForm(
          selectedSkema: selectedSkema ?? 'Pilih skema dulu',
          unitKompetensi: cachedUnitKompetensi,
          persyaratanDasar: persyaratanDasar,
          persyaratanAdministratif: persyaratanAdministratif,
          isLoading: isLoadingUnitPersyaratan,
          uploadedDocs: uploadedDocs,
          uploadedFileNames: uploadedFileNames,
          onUploadChanged: onPersyaratanUpload,
        );
      case 4:
        return DokumenPortofolioForm(
          selectedSkema: selectedSkema ?? '',
          unitKompetensi: asesmenUnits,
          isLoading: isLoadingKompetensi,
          skemaBelumDipilih: selectedSkemaId == null || selectedSkemaId! <= 0,
          loadFailed: kompetensiLoadFailed,
          onRetry: () => ensureKompetensiLoaded(),
          onBuktiTap: navigateToBuktiPortofolio,
          onUnitTap: () async {
            final completed = await Navigator.push<bool>(
              context,
              MaterialPageRoute(
                builder: (context) => AsesmenMandiriUjiScreen(
                  selectedSkema: selectedSkema ?? '',
                  unitKompetensi: asesmenUnits,
                  uploadedFileNames: uploadedFileNames,
                  kukAssessments: kukAssessments,
                  kukEvidence: kukEvidence,
                  onAssessmentChanged: (elemenKey, isK) {
                    setState(() {
                      kukAssessments[elemenKey] = isK;
                    });
                  },
                  onEvidenceChanged: (elemenKey, fileName) {
                    setState(() {
                      kukEvidence[elemenKey] = fileName;
                    });
                  },
                ),
              ),
            );
            if (completed == true) {
              setState(() {
                currentStep = 5;
              });
            }
          },
        );
      case 5:
        if (activeUnitDetailIndex != null &&
            activeUnitDetailIndex! < asesmenUnits.length) {
          final unit = asesmenUnits[activeUnitDetailIndex!];
          final String kode = unit['kode'] as String? ?? '';
          final String judul = unit['judul'] as String? ?? '';
          final elemenRaw = unit['elemen'];
          final elemenGroups = elemenRaw is List
              ? elemenRaw
                  .map((e) => e is Map<String, dynamic>
                      ? e
                      : Map<String, dynamic>.from(e as Map))
                  .toList()
              : <Map<String, dynamic>>[];
          final kukCount =
              unit['kuk_count'] as String? ?? '${elemenGroups.length} elemen';

          return UnitKompetensiDetail(
            unitKode: kode,
            unitJudul: judul,
            kukCount: kukCount,
            elemenGroups: elemenGroups,
            uploadedFileNames: uploadedFileNames,
            kukAssessments: kukAssessments,
            kukEvidence: kukEvidence,
            onAssessmentChanged: (elemenKey, isK) {
              setState(() {
                kukAssessments[elemenKey] = isK;
              });
            },
            onEvidenceChanged: (elemenKey, fileName) {
              setState(() {
                kukEvidence[elemenKey] = fileName;
              });
            },
            onKembali: () {
              setState(() {
                activeUnitDetailIndex = null;
              });
            },
            onSelesai: () {
              setState(() {
                activeUnitDetailIndex = null;
              });
            },
          );
        }

        return AsesmenMandiriForm(
          selectedSkema: selectedSkema ?? '',
          unitKompetensi: asesmenUnits,
          isLoading: isLoadingKompetensi,
          skemaBelumDipilih: selectedSkemaId == null || selectedSkemaId! <= 0,
          loadFailed: kompetensiLoadFailed,
          onRetry: () => ensureKompetensiLoaded(),
          onUnitTap: (index) {
            setState(() {
              activeUnitDetailIndex = index;
            });
          },
          onBuktiTap: navigateToBuktiPortofolio,
        );
      default:
        return Container();
    }
  }

  Widget buildBottomActionButtons() {
    if (currentStep == 5 && activeUnitDetailIndex != null) {
      return Container(
        color: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: SafeArea(
          top: false,
          child: Row(
            children: [
              Expanded(
                flex: 2,
                child: SizedBox(
                  height: 48,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      setState(() {
                        activeUnitDetailIndex = null;
                      });
                    },
                    icon: const Icon(Icons.arrow_back_rounded, size: 18),
                    label: const Text(
                      'Kembali',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF64748B),
                      backgroundColor: const Color(0xFFE2E8F0),
                      side: BorderSide.none,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
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
                    onPressed: () {
                      setState(() {
                        activeUnitDetailIndex = null;
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF378CE7),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Selesai dan Kirim',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.arrow_forward_rounded, size: 18),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final bool isStep4 = currentStep == 4;

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            if (currentStep > 0) ...[
              Expanded(
                flex: 2,
                child: SizedBox(
                  height: 48,
                  child: OutlinedButton.icon(
                    onPressed: previousStep,
                    icon: const Icon(Icons.arrow_back_rounded, size: 18),
                    label: const Text(
                      'Kembali',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF64748B),
                      backgroundColor: const Color(0xFFE2E8F0),
                      side: BorderSide.none,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ),
            ],
            if (!isStep4) ...[
              if (currentStep > 0) const SizedBox(width: 16),
              Expanded(
                flex: 3,
                child: SizedBox(
                  height: 48,
                  child: ElevatedButton(
                    onPressed: isSubmitting ? null : nextStep,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF378CE7),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: isSubmitting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                currentStep == 5 ? 'Kirim Pengajuan' : 'Selanjutnya',
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              if (currentStep < 5) ...[
                                const SizedBox(width: 8),
                                const Icon(Icons.arrow_forward_rounded, size: 18),
                              ],
                            ],
                          ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
