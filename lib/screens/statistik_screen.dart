import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/dashboard_models.dart';
import '../helpers/number_format_helper.dart';
import '../widgets/statistik/indonesia_map.dart';

class StatistikScreen extends StatefulWidget {
  final VoidCallback? onBackToHome;

  const StatistikScreen({super.key, this.onBackToHome});

  @override
  State<StatistikScreen> createState() => _StatistikScreenState();
}

class _StatistikScreenState extends State<StatistikScreen> {
  bool _isActiveAsesorSelected = true; // True for Asesor Aktif, False for Sebaran Skema
  
  late Future<AsesorStats> _asesorStatsFuture;
  late Future<List<TopProvinsi>> _topProvincesFuture;
  late Future<SkemaStats> _skemaStatsFuture;
  late Future<List<TopMitra>> _topMitrasFuture;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    _asesorStatsFuture = ApiService.getAsesorStats();
    _topProvincesFuture = ApiService.getTopProvinces();
    _skemaStatsFuture = ApiService.getSkemaStats();
    _topMitrasFuture = ApiService.getTopMitras();
  }

  @override
  Widget build(BuildContext context) {
    final double statusBarHeight = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() {
            _loadData();
          });
        },
        color: const Color(0xFF2C6C9C),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: statusBarHeight + 8),
              
              // 1. Custom App Bar
              _buildAppBar(),

              // 2. Switching Tab Bar
              _buildTabBar(),

              // 3. Dynamic Metrics Cards Layout based on active tab
              _isActiveAsesorSelected ? _buildAsesorMetrics() : _buildSkemaMetrics(),

              // 4. Additional search & date picker inputs specifically for Sebaran Skema
              if (!_isActiveAsesorSelected) _buildDatePickerAndSearch(),

              const SizedBox(height: 16),

              // 5. Peta Penyebaran Title Header
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  'Peta Penyebaran Asesor',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
              const SizedBox(height: 8),

              // 6. Interactive choropleth map
              IndonesiaMap(
                onIslandSelected: (islandId) {
                  debugPrint('Island selected: $islandId');
                },
                onProvinceSelected: (province) {
                  debugPrint('Province selected: ${province.name} (ID: ${province.id})');
                  _showTUKDistributionBottomSheet(context, province.id, province.name);
                },
              ),

              const SizedBox(height: 8),

              // 7. Dynamic Top 5 Cards at bottom based on active tab
              _isActiveAsesorSelected ? _buildTopProvinsiCard() : _buildTopMitraCard(),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Circular Black Back Arrow Button
          GestureDetector(
            onTap: () {
              if (widget.onBackToHome != null) {
                widget.onBackToHome!();
              } else {
                Navigator.of(context).pop();
              }
            },
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
          
          // Bold screen title
          const Text(
            'Distribusi Asesor & Skema',
            style: TextStyle(
              color: Colors.black,
              fontSize: 16,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.2,
            ),
          ),
          
          // More options horizontal ellipsis
          const Icon(
            Icons.more_horiz_rounded,
            color: Colors.black,
            size: 24,
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Container(
        height: 44,
        decoration: BoxDecoration(
          color: const Color(0xFFF1F3F5),
          borderRadius: BorderRadius.circular(22),
        ),
        padding: const EdgeInsets.all(3),
        child: Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _isActiveAsesorSelected = true;
                  });
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: _isActiveAsesorSelected ? const Color(0xFF768CA7) : Colors.transparent,
                    borderRadius: BorderRadius.circular(19),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    'Asesor Aktif',
                    style: TextStyle(
                      color: _isActiveAsesorSelected ? Colors.white : const Color(0xFF5F6E7D),
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _isActiveAsesorSelected = false;
                  });
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: !_isActiveAsesorSelected ? const Color(0xFF768CA7) : Colors.transparent,
                    borderRadius: BorderRadius.circular(19),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    'Sebaran Skema',
                    style: TextStyle(
                      color: !_isActiveAsesorSelected ? Colors.white : const Color(0xFF5F6E7D),
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
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

  // Active Advisor metrics layout (3-column side-by-side cards)
  Widget _buildAsesorMetrics() {
    return FutureBuilder<AsesorStats>(
      future: _asesorStatsFuture,
      builder: (context, snapshot) {
        final data = snapshot.data ?? AsesorStats.fallback();
        final isLoading = snapshot.connectionState == ConnectionState.waiting;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            children: [
              Expanded(
                child: _buildMetricCard3Col(
                  title: 'Total Asesor',
                  value: isLoading ? '...' : NumberFormatHelper.formatWithDots(data.totalAsesor),
                  trend: data.trendTotalAsesor,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildMetricCard3Col(
                  title: 'Asesor Aktif',
                  value: isLoading ? '...' : NumberFormatHelper.formatWithDots(data.asesorAktif),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildMetricCard3Col(
                  title: 'Wilayah Tercover',
                  value: isLoading ? '...' : '${data.wilayahTercover} Prov',
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMetricCard3Col({
    required String title,
    required String value,
    String? trend,
  }) {
    return Container(
      height: 72,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: const [
          BoxShadow(
            color: Color(0x05000000),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2C6C9C),
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              if (trend != null) ...[
                const SizedBox(width: 3),
                Text(
                  trend,
                  style: const TextStyle(
                    fontSize: 8,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF4CAF50),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  // Schema Sebaran metrics layout (1 horizontal card divided into 4 columns)
  Widget _buildSkemaMetrics() {
    return FutureBuilder<SkemaStats>(
      future: _skemaStatsFuture,
      builder: (context, snapshot) {
        final data = snapshot.data ?? SkemaStats.fallback();
        final isLoading = snapshot.connectionState == ConnectionState.waiting;

        double activePct = data.totalSkema > 0 ? (data.skemaAktif / data.totalSkema * 100) : 0.0;
        double inactivePct = data.totalSkema > 0 ? (data.skemaNonaktif / data.totalSkema * 100) : 0.0;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x05000000),
                  blurRadius: 6,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 4.0),
            child: Row(
              children: [
                Expanded(
                  child: _buildMetricCard4Col(
                    icon: Icons.assignment_outlined,
                    iconColor: const Color(0xFF2C6C9C),
                    title: 'Total Skema',
                    value: isLoading ? '...' : NumberFormatHelper.formatWithDots(data.totalSkema),
                    subtitle: 'Semua skema',
                  ),
                ),
                _buildVerticalDivider(),
                Expanded(
                  child: _buildMetricCard4Col(
                    icon: Icons.map_outlined,
                    iconColor: const Color(0xFF4CAF50),
                    title: 'Provinsi',
                    value: isLoading ? '...' : NumberFormatHelper.formatWithDots(data.provinsi),
                    subtitle: 'Tersebar',
                  ),
                ),
                _buildVerticalDivider(),
                Expanded(
                  child: _buildMetricCard4Col(
                    icon: Icons.personal_video_outlined,
                    iconColor: const Color(0xFF2C6C9C),
                    title: 'Skema Aktif',
                    value: isLoading ? '...' : NumberFormatHelper.formatWithDots(data.skemaAktif),
                    subtitle: isLoading ? '...' : '${activePct.toStringAsFixed(1).replaceAll('.', ',')}%',
                  ),
                ),
                _buildVerticalDivider(),
                Expanded(
                  child: _buildMetricCard4Col(
                    icon: Icons.cancel_outlined,
                    iconColor: const Color(0xFFE53935),
                    title: 'Skema Nonaktif',
                    value: isLoading ? '...' : NumberFormatHelper.formatWithDots(data.skemaNonaktif),
                    subtitle: isLoading ? '...' : '${inactivePct.toStringAsFixed(1).replaceAll('.', ',')}%',
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildVerticalDivider() {
    return Container(
      height: 36,
      width: 0.8,
      color: Colors.grey[200],
    );
  }

  Widget _buildMetricCard4Col({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String value,
    required String subtitle,
  }) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: iconColor, size: 14),
            const SizedBox(width: 3),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 7.5, color: Colors.grey, fontWeight: FontWeight.w600),
                ),
                Text(
                  value,
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: iconColor),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: const TextStyle(fontSize: 8, color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildDatePickerAndSearch() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 0.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Elegant date picker trigger button
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: const Color(0xFFE9ECF0)),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(Icons.calendar_today_outlined, size: 12, color: Colors.black87),
                SizedBox(width: 6),
                Text(
                  'Mei 2025',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.black87),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          
          // Search input bar
          Container(
            height: 38,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(19),
              border: Border.all(color: const Color(0xFFE9ECF0)),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Row(
              children: const [
                Icon(Icons.search, size: 16, color: Colors.grey),
                SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Cari provinsi atau kota...',
                      hintStyle: TextStyle(fontSize: 11, color: Colors.grey),
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Active Advisor top 5 provinsi breakdown list card
  Widget _buildTopProvinsiCard() {
    return FutureBuilder<List<TopProvinsi>>(
      future: _topProvincesFuture,
      builder: (context, snapshot) {
        final items = snapshot.data ?? [];
        final isLoading = snapshot.connectionState == ConnectionState.waiting;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x05000000),
                  blurRadius: 6,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Top 5 Provinsi (Asesor Aktif)',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 12),
                if (isLoading)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: CircularProgressIndicator(strokeWidth: 2.5, color: Color(0xFF2C6C9C)),
                    ),
                  )
                else
                  ...items.map((item) => _buildListItem(_ListModel(
                    name: item.name,
                    value: NumberFormatHelper.formatWithDots(item.value),
                    percentage: item.percentage,
                    color: const Color(0xFF0F4C81),
                  ))),
                const SizedBox(height: 16),
                _buildOutlineButton('Lihat Semua Provinsi'),
              ],
            ),
          ),
        );
      },
    );
  }

  // Schema Sebaran top 5 mitra perwilayah breakdown list card
  Widget _buildTopMitraCard() {
    return FutureBuilder<List<TopMitra>>(
      future: _topMitrasFuture,
      builder: (context, snapshot) {
        final items = snapshot.data ?? [];
        final isLoading = snapshot.connectionState == ConnectionState.waiting;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x05000000),
                  blurRadius: 6,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Top 5 Mitra (Rincian Perwilayah)',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 12),
                if (isLoading)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: CircularProgressIndicator(strokeWidth: 2.5, color: Color(0xFF2C6C9C)),
                    ),
                  )
                else
                  ...items.map((item) => _buildListItem(_ListModel(
                    name: item.name,
                    value: NumberFormatHelper.formatWithDots(item.value),
                    percentage: item.percentage,
                    color: const Color(0xFF0F4C81),
                  ))),
                const SizedBox(height: 16),
                _buildOutlineButton('Lihat Semua Mitra'),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildListItem(_ListModel item) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10.0),
          child: Row(
            children: [
              Container(
                width: 14,
                height: 14,
                decoration: BoxDecoration(
                  color: item.color,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  item.name,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                item.value,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(width: 24),
              SizedBox(
                width: 48,
                child: Text(
                  item.percentage,
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ),
            ],
          ),
        ),
        Divider(height: 1, thickness: 0.5, color: Colors.grey[200]),
      ],
    );
  }

  Widget _buildOutlineButton(String label) {
    return SizedBox(
      width: double.infinity,
      height: 38,
      child: OutlinedButton(
        onPressed: () {},
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Color(0xFFE9ECF0), width: 1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          backgroundColor: const Color(0xFFF9FAFB),
          elevation: 0,
        ),
        child: Text(
          label,
          style: const TextStyle(
            color: Color(0xFF344054),
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  // Interactive Bottom Sheet to display TUK sebaran on tapped provinces
  void _showTUKDistributionBottomSheet(BuildContext context, String provinceId, String provinceName) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          height: 350,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      'Penyebaran TUK: $provinceName',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: FutureBuilder<List<TUKKabupaten>>(
                  future: ApiService.getTUKKabupaten(provinceId),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: Color(0xFF2C6C9C),
                        ),
                      );
                    }

                    final data = snapshot.data ?? [];
                    if (data.isEmpty) {
                      return const Center(
                        child: Text(
                          'Tidak ada data penyebaran TUK di provinsi ini.',
                          style: TextStyle(color: Colors.grey, fontSize: 13),
                        ),
                      );
                    }

                    return ListView.separated(
                      itemCount: data.length,
                      separatorBuilder: (context, index) => Divider(height: 1, color: Colors.grey[200]),
                      itemBuilder: (context, index) {
                        final item = data[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  item.kabupaten,
                                  style: const TextStyle(
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black87,
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE5F1FC),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  '${item.jumlah} TUK',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF2C6C9C),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ListModel {
  final String name;
  final String value;
  final String percentage;
  final Color color;

  _ListModel({
    required this.name,
    required this.value,
    required this.percentage,
    required this.color,
  });
}
