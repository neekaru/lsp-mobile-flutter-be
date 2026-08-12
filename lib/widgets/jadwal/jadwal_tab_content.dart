import 'package:flutter/material.dart';

/// Pembungkus tab jadwal agar tetap hidup (keep-alive) saat berpindah tab.
class JadwalTabContent extends StatefulWidget {
  final Widget child;

  const JadwalTabContent({super.key, required this.child});

  @override
  State<JadwalTabContent> createState() => _JadwalTabContentState();
}

class _JadwalTabContentState extends State<JadwalTabContent>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(
      context,
    ); // Must call super.build for AutomaticKeepAliveClientMixin
    return widget.child;
  }
}
