import 'dart:async';
import 'package:material_ui/material_ui.dart';
import '../../../models/lead_model.dart';
import '../../../services/marketing/lead_storage_service.dart';
import '../../../services/marketing/location_service.dart';
import '../../../services/marketing/places_service.dart';

String inferCategoryFromName(String name) {
  final up = name.toUpperCase();
  if (up.contains('SMK')) return 'SMK';
  if (up.contains('UNIVERSITAS') ||
      up.contains('INSTITUT') ||
      up.contains('POLITEKNIK') ||
      up.contains('KAMPUS') ||
      up.contains('FAKULTAS') ||
      up.contains('AKADEMI')) {
    return 'Kampus';
  }
  if (up.contains('BLK')) return 'BLK';
  if (up.contains('LPK')) return 'LPK';
  if (up.contains('LKP')) return 'LKP';
  if (up.contains('DINAS')) return 'Dinas Pemda';
  return 'Perusahaan Swasta';
}

Future<void> showAddCustomLeadDialog({
  required BuildContext context,
  required int idAsesor,
  required Future<void> Function() onSaved,
}) {
  final nameCtrl = TextEditingController();
  final addressCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  final picCtrl = TextEditingController();
  final latCtrl = TextEditingController();
  final lngCtrl = TextEditingController();
  String category = 'SMK';

  List<RegisteredPlace> placeSuggestions = [];
  bool isSearchingSuggestions = false;
  bool isResolvingCoordinates = false;
  Timer? debounceTimer;

  return showDialog(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setDlgState) {
          void onNameChanged(String val) {
            debounceTimer?.cancel();
            final q = val.trim();
            if (q.length < 2) {
              setDlgState(() {
                placeSuggestions = [];
                isSearchingSuggestions = false;
              });
              return;
            }
            setDlgState(() => isSearchingSuggestions = true);
            debounceTimer = Timer(const Duration(milliseconds: 350), () async {
              final results =
                  await LeadStorageService.searchRegisteredPlaces(q);
              setDlgState(() {
                placeSuggestions = results;
                isSearchingSuggestions = false;
              });
            });
          }

          void selectPlace(RegisteredPlace place) {
            nameCtrl.text = place.namaTempat;
            addressCtrl.text = [place.alamat, place.kota]
                .where((s) => s.isNotEmpty)
                .join(', ');
            if (place.telepon.isNotEmpty) phoneCtrl.text = place.telepon;
            if (place.picName.isNotEmpty) picCtrl.text = place.picName;
            category = inferCategoryFromName(place.namaTempat);
            if (place.hasCoordinates) {
              latCtrl.text = place.latitude!.toStringAsFixed(6);
              lngCtrl.text = place.longitude!.toStringAsFixed(6);
            } else {
              setDlgState(() => isResolvingCoordinates = true);
              PlacesService.searchPlaces(
                query: '${place.namaTempat}, ${place.alamat}, ${place.kota}',
                filterRetail: false,
              ).then((res) {
                if (res.isNotEmpty) {
                  final p = res.first;
                  if (p.latitude != 0.0 && p.longitude != 0.0) {
                    latCtrl.text = p.latitude.toStringAsFixed(6);
                    lngCtrl.text = p.longitude.toStringAsFixed(6);
                  }
                }
              }).catchError((_) {}).whenComplete(() {
                setDlgState(() => isResolvingCoordinates = false);
              });
            }
            setDlgState(() {
              placeSuggestions = [];
            });
          }

          Future<void> autoFetchCoordinates() async {
            final q = [nameCtrl.text.trim(), addressCtrl.text.trim()]
                .where((s) => s.isNotEmpty)
                .join(', ');
            if (q.isEmpty) return;
            setDlgState(() => isResolvingCoordinates = true);
            try {
              final res = await PlacesService.searchPlaces(
                query: q,
                filterRetail: false,
              );
              if (res.isNotEmpty) {
                final p = res.first;
                if (p.latitude != 0.0 && p.longitude != 0.0) {
                  latCtrl.text = p.latitude.toStringAsFixed(6);
                  lngCtrl.text = p.longitude.toStringAsFixed(6);
                }
              }
            } catch (_) {
            } finally {
              setDlgState(() => isResolvingCoordinates = false);
            }
          }

          Future<void> useCurrentGpsLocation() async {
            setDlgState(() => isResolvingCoordinates = true);
            try {
              final loc = await LocationService.getCurrentLocation();
              latCtrl.text = loc.latitude.toStringAsFixed(6);
              lngCtrl.text = loc.longitude.toStringAsFixed(6);
            } catch (_) {
            } finally {
              setDlgState(() => isResolvingCoordinates = false);
            }
          }

          return AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16)),
            title: const Row(
              children: [
                Icon(Icons.add_location_alt_rounded,
                    color: Color(0xFF2563EB), size: 22),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Tambah Lead Manual',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
              ],
            ),
            content: SizedBox(
              width: double.maxFinite,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: nameCtrl,
                      onChanged: onNameChanged,
                      decoration: InputDecoration(
                        labelText: 'Nama Tempat / Institusi *',
                        hintText: 'Ketik nama tempat/sekolah/TUK...',
                        suffixIcon: isSearchingSuggestions
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: Padding(
                                  padding: EdgeInsets.all(12),
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2),
                                ),
                              )
                            : const Icon(Icons.search_rounded, size: 20),
                      ),
                    ),
                    if (placeSuggestions.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Container(
                        constraints: const BoxConstraints(maxHeight: 180),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFF93C5FD)),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x10000000),
                              blurRadius: 6,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: ListView.separated(
                          shrinkWrap: true,
                          itemCount: placeSuggestions.length,
                          separatorBuilder: (_, _) =>
                              const Divider(height: 1),
                          itemBuilder: (context, index) {
                            final p = placeSuggestions[index];
                            return ListTile(
                              dense: true,
                              leading: const Icon(Icons.domain_rounded,
                                  size: 18, color: Color(0xFF2563EB)),
                              title: Text(
                                p.namaTempat,
                                style: const TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF0F172A),
                                ),
                              ),
                              subtitle: Text(
                                [p.kota, p.alamat]
                                    .where((s) => s.isNotEmpty)
                                    .join(' • '),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 11),
                              ),
                              trailing: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFEFF6FF),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Text(
                                  'Terdaftar',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF2563EB),
                                  ),
                                ),
                              ),
                              onTap: () => selectPlace(p),
                            );
                          },
                        ),
                      ),
                    ],
                    const SizedBox(height: 12),
                    const Row(
                      children: [
                        Icon(Icons.pin_drop_rounded,
                            size: 16, color: Color(0xFF2563EB)),
                        SizedBox(width: 6),
                        Text(
                          'Koordinat Tempat',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: latCtrl,
                            keyboardType:
                                const TextInputType.numberWithOptions(
                                    signed: true, decimal: true),
                            decoration: const InputDecoration(
                              labelText: 'Latitude',
                              hintText: '-6.2088',
                              isDense: true,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: lngCtrl,
                            keyboardType:
                                const TextInputType.numberWithOptions(
                                    signed: true, decimal: true),
                            decoration: const InputDecoration(
                              labelText: 'Longitude',
                              hintText: '106.8456',
                              isDense: true,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: [
                        InkWell(
                          onTap: isResolvingCoordinates
                              ? null
                              : autoFetchCoordinates,
                          borderRadius: BorderRadius.circular(6),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEFF6FF),
                              borderRadius: BorderRadius.circular(6),
                              border:
                                  Border.all(color: const Color(0xFFBFDBFE)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (isResolvingCoordinates)
                                  const SizedBox(
                                    width: 12,
                                    height: 12,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 1.5),
                                  )
                                else
                                  const Icon(Icons.explore_rounded,
                                      size: 13, color: Color(0xFF2563EB)),
                                const SizedBox(width: 4),
                                const Text(
                                  'Cari Koordinat via Peta',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF2563EB),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        InkWell(
                          onTap: isResolvingCoordinates
                              ? null
                              : useCurrentGpsLocation,
                          borderRadius: BorderRadius.circular(6),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(6),
                              border:
                                  Border.all(color: const Color(0xFFE2E8F0)),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.my_location_rounded,
                                    size: 13, color: Color(0xFF475569)),
                                SizedBox(width: 4),
                                Text(
                                  'Gunakan GPS Saat Ini',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF475569),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      initialValue: category,
                      decoration: const InputDecoration(
                        labelText: 'Kategori Institusi',
                        isDense: true,
                      ),
                      items: [
                        'SMK',
                        'Kampus',
                        'BLK',
                        'LPK',
                        'LKP',
                        'Dinas Pemda',
                        'Perusahaan Swasta'
                      ]
                          .map((c) =>
                              DropdownMenuItem(value: c, child: Text(c)))
                          .toList(),
                      onChanged: (val) {
                        if (val != null) setDlgState(() => category = val);
                      },
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: addressCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Alamat / Kota',
                        hintText: 'Contoh: Jl. Raya Solo KM 14, Sleman',
                        isDense: true,
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: picCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Nama PIC / Kontak',
                        hintText: 'Contoh: Drs. Bambang (Kepala Sekolah)',
                        isDense: true,
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: phoneCtrl,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        labelText: 'No. WhatsApp / Telp',
                        hintText: '0853-xxxx-xxxx',
                        isDense: true,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Batal'),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (nameCtrl.text.trim().isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Nama Institusi wajib diisi')),
                    );
                    return;
                  }
                  final lat = double.tryParse(latCtrl.text.trim()) ?? 0.0;
                  final lng = double.tryParse(lngCtrl.text.trim()) ?? 0.0;
                  final customLead = LeadModel(
                    id: 'custom_${DateTime.now().millisecondsSinceEpoch}',
                    idAsesor: idAsesor,
                    namaInstitusi: nameCtrl.text.trim(),
                    leadKategori: category,
                    leadLocation: addressCtrl.text.trim(),
                    latitude: lat,
                    longitude: lng,
                    picName: picCtrl.text.trim(),
                    telepon: phoneCtrl.text.trim(),
                    leadStatus: 'lead',
                    updatedAt: DateTime.now(),
                  );
                  final aiLead =
                      await LeadStorageService.generateAiPotensi(customLead);
                  await LeadStorageService.saveLead(aiLead);
                  await onSaved();
                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                            'Lead "${nameCtrl.text.trim()}" berhasil disimpan!'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
                  foregroundColor: Colors.white,
                ),
                child: const Text('Simpan'),
              ),
            ],
          );
        },
      );
    },
  );
}
