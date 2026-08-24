import 'package:material_ui/material_ui.dart';
import '../common/custom_app_bar.dart';
import 'statistics_menu_accordion.dart';
import '../../screens/statistik/statistik_detail_screen.dart';

class StatistikAppBar extends StatelessWidget {
  final String title;
  final String currentView;
  final VoidCallback onBack;
  final ValueChanged<String> onSwitchView;

  const StatistikAppBar({
    super.key,
    required this.title,
    required this.currentView,
    required this.onBack,
    required this.onSwitchView,
  });

  @override
  Widget build(BuildContext context) {
    return CustomAppBar(
      title: title,
      onBack: onBack,
      rightWidget: Theme(
        data: Theme.of(context).copyWith(
          dividerTheme: const DividerThemeData(color: Color(0xFFF1F5F9)),
        ),
        child: PopupMenuButton<String>(
          icon: const Icon(
            Icons.more_horiz_rounded,
            color: Colors.black,
            size: 24,
          ),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
          offset: const Offset(0, 40),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          color: Colors.white,
          elevation: 3,
          itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
            PopupMenuItem<String>(
              enabled: false,
              padding: EdgeInsets.zero,
              child: SizedBox(
                width: 280,
                child: StatisticsMenuAccordion(
                  onSelected: (String value) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            StatistikDetailScreen(menuKey: value),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
