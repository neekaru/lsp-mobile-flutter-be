import 'package:flutter/material.dart';
import '../../models/dashboard_models.dart';
import '../../helpers/number_format_helper.dart';

class AsesorMetricsCard extends StatelessWidget {
  final Future<AsesorStats> asesorStatsFuture;

  const AsesorMetricsCard({
    super.key,
    required this.asesorStatsFuture,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<AsesorStats>(
      future: asesorStatsFuture,
      builder: (context, snapshot) {
        final data = snapshot.data ?? AsesorStats.fallback();
        final isLoading = snapshot.connectionState == ConnectionState.waiting;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Row 1: Total Asesor (Breakdown) & Total TUK
              Row(
                children: [
                  // Total Asesor Card with Breakdown
                  Expanded(
                    flex: 7,
                    child: Container(
                      height: 125,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x05000000),
                            blurRadius: 8,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Total Asesor',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF5F6E7D),
                                ),
                              ),
                              if (!isLoading)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFE8F5E9),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    data.trendTotalAsesor,
                                    style: const TextStyle(
                                      fontSize: 8,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF4CAF50),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            isLoading
                                ? '...'
                                : NumberFormatHelper.formatWithDots(
                                    data.totalAsesor),
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const Spacer(),
                          // Internal / External Breakdown
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        width: 8,
                                        height: 8,
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF2C6C9C),
                                          borderRadius:
                                              BorderRadius.circular(2),
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      const Text('Internal',
                                          style: TextStyle(
                                              fontSize: 9, color: Colors.grey)),
                                    ],
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    isLoading
                                        ? '...'
                                        : NumberFormatHelper.formatWithDots(
                                            data.asesorInternal),
                                    style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87),
                                  ),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        width: 8,
                                        height: 8,
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFE53935),
                                          borderRadius:
                                              BorderRadius.circular(2),
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      const Text('External',
                                          style: TextStyle(
                                              fontSize: 9, color: Colors.grey)),
                                    ],
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    isLoading
                                        ? '...'
                                        : NumberFormatHelper.formatWithDots(
                                            data.asesorExternal),
                                    style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          // Premium Segmented Progress Bar
                          if (!isLoading && data.totalAsesor > 0)
                            ClipRRect(
                              borderRadius: BorderRadius.circular(2),
                              child: SizedBox(
                                height: 4,
                                child: Row(
                                  children: [
                                    Expanded(
                                      flex: data.asesorInternal,
                                      child: Container(
                                          color: const Color(0xFF2C6C9C)),
                                    ),
                                    Expanded(
                                      flex: data.asesorExternal,
                                      child: Container(
                                          color: const Color(0xFFE53935)),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          else
                            const SizedBox(
                                height: 4,
                                child: LinearProgressIndicator(
                                    value: 0,
                                    backgroundColor: Color(0xFFECEFF1))),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  // Total TUK Card
                  Expanded(
                    flex: 5,
                    child: Container(
                      height: 125,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x05000000),
                            blurRadius: 8,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: const Color(0xFFE0F2F1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.domain_rounded,
                              color: Color(0xFF009688),
                              size: 18,
                            ),
                          ),
                          const Spacer(),
                          const Text(
                            'Total TUK',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF5F6E7D),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            isLoading
                                ? '...'
                                : NumberFormatHelper.formatWithDots(
                                    data.totalTuk),
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Tempat Uji Kompetensi',
                            style: TextStyle(
                              fontSize: 9,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              // Row 2: Status Asesmen Card (Online vs Offline)
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x05000000),
                      blurRadius: 8,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Status Asesmen',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2C6C9C),
                          ),
                        ),
                        Icon(
                          Icons.insights_rounded,
                          size: 16,
                          color: Color(0xFF2C6C9C),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        // Online count
                        Expanded(
                          child: Row(
                            children: [
                              Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE8F5E9),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                  Icons.cloud_done_rounded,
                                  color: Color(0xFF4CAF50),
                                  size: 18,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Online',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Colors.grey,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    isLoading
                                        ? '...'
                                        : NumberFormatHelper.formatWithDots(
                                            data.onlineAsesmen),
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF4CAF50),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        // Divider
                        Container(
                          height: 30,
                          width: 1,
                          color: Colors.grey[200],
                        ),
                        const SizedBox(width: 16),
                        // Offline count
                        Expanded(
                          child: Row(
                            children: [
                              Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE5F1FC),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                  Icons.location_on_rounded,
                                  color: Color(0xFF2C6C9C),
                                  size: 18,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Offline',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Colors.grey,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    isLoading
                                        ? '...'
                                        : NumberFormatHelper.formatWithDots(
                                            data.offlineAsesmen),
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF2C6C9C),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Segmented Bar for Online / Offline
                    if (!isLoading &&
                        (data.onlineAsesmen + data.offlineAsesmen) > 0)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(3),
                        child: SizedBox(
                          height: 6,
                          child: Row(
                            children: [
                              Expanded(
                                flex: data.onlineAsesmen,
                                child:
                                    Container(color: const Color(0xFF4CAF50)),
                              ),
                              Expanded(
                                flex: data.offlineAsesmen,
                                child:
                                    Container(color: const Color(0xFF2C6C9C)),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      const SizedBox(
                          height: 6,
                          child: LinearProgressIndicator(
                              value: 0, backgroundColor: Color(0xFFECEFF1))),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
