import 'package:material_ui/material_ui.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/asesor_dashboard_models.dart';
import '../../utils/url_helper.dart';

Future<void> _openExternalUrl(String rawUrl) async {
  final uri = Uri.tryParse(UrlHelper.resolveUrl(rawUrl));
  if (uri != null && await canLaunchUrl(uri)) {
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}



class AsesorMitraListScreen extends StatelessWidget {
  final List<AsesorMitra> mitra;

  const AsesorMitraListScreen({super.key, required this.mitra});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Daftar Mitra')),
      body: mitra.isEmpty
          ? const Center(child: Text('Belum ada mitra terdaftar'))
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: mitra.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (context, index) => _MitraCard(mitra: mitra[index]),
            ),
    );
  }
}

class _MitraCard extends StatelessWidget {
  final AsesorMitra mitra;

  const _MitraCard({required this.mitra});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: const CircleAvatar(child: Icon(Icons.handshake_rounded)),
        title: Text(mitra.namaTuk.isNotEmpty ? mitra.namaTuk : 'Mitra'),
        subtitle: Text([
          if (mitra.kota.isNotEmpty) mitra.kota,
          if (mitra.alamat.isNotEmpty) mitra.alamat,
        ].join(' • ')),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => AsesorMitraDetailScreen(mitra: mitra)),
        ),
      ),
    );
  }
}

class AsesorMitraDetailScreen extends StatelessWidget {
  final AsesorMitra mitra;

  const AsesorMitraDetailScreen({super.key, required this.mitra});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detail Mitra')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(mitra.namaTuk.isNotEmpty ? mitra.namaTuk : 'Mitra', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          if (mitra.kota.isNotEmpty) _DetailRow(label: 'Kota', value: mitra.kota),
          if (mitra.alamat.isNotEmpty) _DetailRow(label: 'Alamat', value: mitra.alamat),
          if (mitra.tanggalBermitra.isNotEmpty) _DetailRow(label: 'Tanggal Bermitra', value: mitra.tanggalBermitra),
          if (mitra.deskripsiMitra.isNotEmpty) _DetailRow(label: 'Deskripsi', value: mitra.deskripsiMitra),
          if (mitra.proyeksiMitra.isNotEmpty) _DetailRow(label: 'Proyeksi', value: mitra.proyeksiMitra),
          if (mitra.linkMouMitra.isNotEmpty)
            TextButton.icon(
              onPressed: () => _openExternalUrl(mitra.linkMouMitra),
              icon: const Icon(Icons.open_in_new),
              label: const Text('Buka Link MoU'),
            ),
          if (mitra.hasCoordinates) ...[
            const SizedBox(height: 12),
            SizedBox(
              height: 240,
              child: GoogleMap(
                initialCameraPosition: CameraPosition(target: LatLng(mitra.latitude!, mitra.longitude!), zoom: 16),
                markers: {
                  Marker(
                    markerId: MarkerId('mitra-${mitra.id}'),
                    position: LatLng(mitra.latitude!, mitra.longitude!),
                    infoWindow: InfoWindow(title: mitra.namaTuk),
                  ),
                },
                zoomControlsEnabled: false,
                myLocationButtonEnabled: false,
              ),
            ),
            TextButton.icon(
              onPressed: () => _openExternalUrl('https://www.google.com/maps/search/?api=1&query=${mitra.latitude},${mitra.longitude}'),
              icon: const Icon(Icons.map_outlined),
              label: const Text('Buka di Google Maps'),
            ),
          ] else
            const Padding(
              padding: EdgeInsets.only(top: 16),
              child: Text('Lokasi peta belum tersedia.'),
            ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text('$label: $value'),
    );
  }
}
