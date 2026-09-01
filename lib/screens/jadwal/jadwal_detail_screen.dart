import 'package:material_ui/material_ui.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import '../../widgets/jadwal/detail_helpers.dart';
import '../../widgets/jadwal/jadwal_detail_views.dart';
import '../../widgets/common/custom_app_bar.dart';
import '../../models/jadwal_models.dart';
import 'jadwal_edit_screen.dart';
import '../../services/auth/auth_repository.dart';
import '../../services/api_service.dart';
import 'profil_asesor_screen.dart';
import 'asesi_list_screen.dart';

class JadwalDetailScreen extends StatefulWidget {
  final JadwalItem jadwal;
  final UserRole userRole;

  const JadwalDetailScreen({
    super.key,
    required this.jadwal,
    required this.userRole,
  });

  @override
  State<JadwalDetailScreen> createState() => _JadwalDetailScreenState();
}

class _JadwalDetailScreenState extends State<JadwalDetailScreen> {
  bool _isLoading = false;
  JadwalAsesorDetailData? _detailData;

  @override
  void initState() {
    super.initState();
    _fetchDetailData();
  }

  Future<void> _fetchDetailData() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
    });
    try {
      final res = await ApiService.getJadwalAsesorDetail(widget.jadwal.id);
      if (res != null && mounted) {
        setState(() {
          _detailData = res.data;
        });
      }
    } catch (e) {
      debugPrint('🔴 Error loading assessor detail: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final double statusBarHeight = MediaQuery.of(context).padding.top;
    final role = AuthRepository.currentUserInstance?.role;
    final bool isAsesi = role == 'asesi';
    final bool isAsesor = role == 'asesor';

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F8),
      body: Column(
        children: [
          SizedBox(height: statusBarHeight + 8),

          // Header with consistent style (Statistics Header)
          CustomAppBar(
            title: 'Detail Jadwal',
            rightWidget: (isAsesi || isAsesor)
                ? const Icon(
                    Icons.more_horiz_rounded,
                    color: Colors.black,
                    size: 24,
                  )
                : const SizedBox(width: 32),
          ),

          if (_isLoading)
            const LinearProgressIndicator(
              minHeight: 2,
              backgroundColor: Colors.transparent,
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2F80ED)),
            ),

          // Content
          Expanded(
            child: isAsesi
                ? JadwalDetailAsesiView(
                    jadwal: widget.jadwal,
                    detailData: _detailData,
                  )
                : isAsesor
                ? JadwalDetailAsesorView(
                    jadwal: widget.jadwal,
                    detailData: _detailData,
                  )
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Card 1: Title & Badge & ID (exactly matching image except dynamic details)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x0A000000),
                                blurRadius: 10,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      widget.jadwal.skema,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                        height: 1.3,
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      'ID Jadwal : OKM-2026-0606-${widget.jadwal.id.toString().padLeft(3, '0')}',
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: Colors.grey,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              JadwalStatusBadge(status: widget.jadwal.status, label: widget.jadwal.displayStatusLabel),
                            ],
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Card 2: Informasi Jadwal (exactly matching image)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x0A000000),
                                blurRadius: 10,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Title with Edit icon on the right
                              Stack(
                                alignment: Alignment.center,
                                children: [
                                  const Align(
                                    alignment: Alignment.center,
                                    child: Text(
                                      'Informasi Jadwal',
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ),
                                  if (widget.userRole.canEditSchedule)
                                    Align(
                                      alignment: Alignment.centerRight,
                                      child: GestureDetector(
                                        onTap: () async {
                                          final result =
                                              await Navigator.push<bool>(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      JadwalEditScreen(
                                                        jadwal: widget.jadwal,
                                                        userRole:
                                                            widget.userRole,
                                                      ),
                                                ),
                                              );
                                          if (!context.mounted) return;
                                          if (result == true) {
                                            Navigator.pop(context, true);
                                          }
                                        },
                                        child: Container(
                                          width: 28,
                                          height: 28,
                                          decoration: const BoxDecoration(
                                            color: Color(0xFFD3E4F6),
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(
                                            LucideIcons.pencil,
                                            color: Color(0xFF2F80ED),
                                            size: 13,
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              const Divider(
                                height: 1,
                                thickness: 1,
                                color: Color(0xFFEEEEEE),
                              ),
                              const SizedBox(height: 8),

                              // Rows
                              DetailInfoRow(
                                icon: LucideIcons.map_pin,
                                iconColor: const Color(0xFFEF5350),
                                iconBgColor: const Color(0xFFFFEBEE),
                                label: 'Tempat Uji Kompetensi',
                                value:
                                    _detailData != null &&
                                        _detailData!.alamatTuk.isNotEmpty
                                    ? '${_detailData!.tuk}\n(${_detailData!.alamatTuk})'
                                    : widget.jadwal.tuk,
                              ),
                              DetailInfoRow(
                                icon: LucideIcons.calendar,
                                iconColor: const Color(0xFF2F80ED),
                                iconBgColor: const Color(0xFFE5F1FC),
                                label: 'Periode Asesmen',
                                value:
                                    '${formatIndonesianDate(widget.jadwal.tanggalMulai)} - ${formatIndonesianDate(widget.jadwal.tanggalSelesai)}',
                              ),
                              DetailInfoRow(
                                icon: LucideIcons.clock,
                                iconColor: const Color(0xFF2F80ED),
                                iconBgColor: const Color(0xFFE5F5FC),
                                label: 'Durasi Pelaksanaan',
                                value: getDurationString(widget.jadwal),
                              ),
                              DetailInfoRow(
                                icon: LucideIcons.users,
                                iconColor: const Color(0xFF2F80ED),
                                iconBgColor: const Color(0xFFE5F1FC),
                                label: 'Jumlah asesi',
                                value: '${widget.jadwal.jumlahAsesi} Asesi',
                              ),

                              if (_detailData != null &&
                                  _detailData!.asesi.isNotEmpty) ...[
                                const SizedBox(height: 8),
                                GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => AsesiListScreen(
                                          jadwalId: widget.jadwal.id,
                                          jadwalTitle: widget.jadwal.skema,
                                          tanggal: widget.jadwal.tanggalMulai,
                                          tuk: widget.jadwal.tuk,
                                        ),
                                      ),
                                    );
                                  },
                                  child: Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 10,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFE5F1FC),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Row(
                                      children: [
                                        Icon(
                                          Icons.group_outlined,
                                          color: Color(0xFF2C6C9C),
                                          size: 16,
                                        ),
                                        SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            'Cek Detail Asesi',
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFF2C6C9C),
                                            ),
                                          ),
                                        ),
                                        Icon(
                                          Icons.chevron_right,
                                          color: Color(0xFF2C6C9C),
                                          size: 16,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],

                              const SizedBox(height: 12),
                              const Divider(
                                height: 1,
                                thickness: 1,
                                color: Color(0xFFEEEEEE),
                              ),
                              const SizedBox(height: 16),

                              // Warning/Info Banner inside card
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: const Color(
                                    0xFFFFFDE7,
                                  ), // Light yellow
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: const Color(0xFFFFF59D),
                                    width: 1,
                                  ),
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Icon(
                                      Icons.warning_rounded,
                                      color: Color(0xFFFBC02D),
                                      size: 18,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        'Pelaksanaan uji kompetensi untuk skema ${widget.jadwal.skema} sudah sesuai dengan standar yang berlaku.',
                                        style: const TextStyle(
                                          fontSize: 11,
                                          color: Colors.black87,
                                          height: 1.4,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Card 3: Daftar Asesor Tugas (Only shown when detailData has assessors)
                        if (_detailData != null &&
                            _detailData!.asesor.isNotEmpty) ...[
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0x0A000000),
                                  blurRadius: 10,
                                  offset: Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Asesor Kompetensi',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                const Divider(
                                  height: 1,
                                  thickness: 1,
                                  color: Color(0xFFEEEEEE),
                                ),
                                const SizedBox(height: 12),
                                ..._detailData!.asesor.map(
                                  (asesorItem) => Padding(
                                    padding: const EdgeInsets.only(
                                      bottom: 12.0,
                                    ),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 40,
                                          height: 40,
                                          decoration: const BoxDecoration(
                                            color: Color(0xFFF5F5F5),
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(
                                            Icons.person_outline_rounded,
                                            color: Colors.grey,
                                            size: 22,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                asesorItem.namaAsesor,
                                                style: const TextStyle(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.black87,
                                                ),
                                              ),
                                              const SizedBox(height: 2),
                                              Text(
                                                'Reg: ${asesorItem.noReg}',
                                                style: const TextStyle(
                                                  fontSize: 11,
                                                  color: Colors.grey,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: const Color(
                                              0xFFE5F1FC,
                                            ),
                                            foregroundColor: const Color(
                                              0xFF2C6C9C,
                                            ),
                                            elevation: 0,
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 12,
                                              vertical: 8,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                          ),
                                          onPressed: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    ProfilAsesorScreen(
                                                      name:
                                                          asesorItem.namaAsesor,
                                                      skema:
                                                          widget.jadwal.skema,
                                                      lokasi: asesorItem
                                                          .kabupatenKota,
                                                      asesorDetail: asesorItem,
                                                    ),
                                              ),
                                            );
                                          },
                                          child: const Text(
                                            'Profil',
                                            style: TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
