import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:tiretrace/fakeData.dart';

class MapScreen extends StatelessWidget {
  final Location location;
  const MapScreen({super.key, required this.location});

  LatLng get _start => LatLng(
      location.lat + 0.303, // ~3km south
      location.lng - 0.179 // ~2.5km west
      );

  List<LatLng> get ecoRoute => [
        _start,
        LatLng(_start.latitude + 0.02, _start.longitude + 0.01),
        LatLng((_start.latitude + location.lat) / 2 + 0.01,
            (_start.longitude + location.lng) / 2 - 0.005),
        LatLng(location.lat, location.lng),
      ];

  List<LatLng> get originalRoute => [
        _start,
        LatLng(_start.latitude + 0.005, _start.longitude - 0.012),
        LatLng((_start.latitude + location.lat) / 2 - 0.008,
            (_start.longitude + location.lng) / 2 + 0.01),
        LatLng(location.lat, location.lng),
      ];

  LatLng get carPosition {
    final a = ecoRoute[1];
    final b = ecoRoute[2];
    return _start;
  }

  LatLng get mapCenter => LatLng((_start.latitude + location.lat) / 2,
      (_start.longitude + location.lng) / 2);

  @override
  Widget build(BuildContext context) {
    final savedMg = (location.pollutionScore * 0.38).round();
    final scoreDrop = (location.pollutionScore * 0.35).round();

    return Scaffold(
      backgroundColor: const Color(0xFF0A1628),
      body: Stack(
        children: [
          // Dark blue map tiles
          FlutterMap(
            options: MapOptions(
              initialCameraFit: CameraFit.bounds(
                bounds: LatLngBounds.fromPoints([
                  _start,
                  ...ecoRoute,
                  ...originalRoute,
                ]),
                padding: const EdgeInsets.fromLTRB(40, 100, 40, 280),
              ),
            ),
            children: [
              TileLayer(
                urlTemplate:
                    'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}.png',
                subdomains: const ['a', 'b', 'c', 'd'],
                userAgentPackageName: 'com.tiretrace.app',
              ),

              // Original route — dim blue dashed
              PolylineLayer(polylines: [
                Polyline(
                    points: originalRoute,
                    color: const Color(0xFF1A2D45),
                    strokeWidth: 4,
                    pattern: StrokePattern.dashed(segments: [10, 6])),
              ]),

              // Eco route — bright ocean blue
              PolylineLayer(polylines: [
                Polyline(
                    points: ecoRoute,
                    color: const Color(0xFF2B7FE0),
                    strokeWidth: 6,
                    strokeCap: StrokeCap.round),
              ]),

              MarkerLayer(
                markers: [
                  // Start dot
                  Marker(
                    point: _start,
                    width: 18,
                    height: 18,
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF0A1628),
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: const Color(0xFF5BA3F5), width: 3),
                      ),
                    ),
                  ),

                  // Car marker
                  Marker(
                    point: carPosition,
                    width: 50,
                    height: 50,
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF0F2040),
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: const Color(0xFF5BA3F5), width: 2),
                        boxShadow: [
                          BoxShadow(
                              color: const Color(0xFF2B7FE0).withOpacity(0.4),
                              blurRadius: 14,
                              spreadRadius: 2)
                        ],
                      ),
                      child: const Icon(Icons.directions_car,
                          color: Color(0xFF5BA3F5), size: 22),
                    ),
                  ),

                  // Destination pin
                  Marker(
                    point: LatLng(location.lat, location.lng),
                    width: 40,
                    height: 52,
                    alignment: Alignment.topCenter,
                    child: Column(
                      children: [
                        Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: const Color(0xFF0F2040),
                            borderRadius: BorderRadius.circular(19),
                            border: Border.all(
                                color: const Color(0xFF5BA3F5), width: 2),
                            boxShadow: [
                              BoxShadow(
                                  color:
                                      const Color(0xFF2B7FE0).withOpacity(0.35),
                                  blurRadius: 12,
                                  spreadRadius: 1)
                            ],
                          ),
                          child: const Icon(Icons.location_on,
                              color: Color(0xFF5BA3F5), size: 18),
                        ),
                        Container(
                          width: 2,
                          height: 10,
                          decoration: const BoxDecoration(
                            color: Color(0xFF5BA3F5),
                            borderRadius: BorderRadius.vertical(
                                bottom: Radius.circular(2)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),

          // Top bar
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: const Color(0xFF0F1E30),
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: const Color(0xFF1A2D45), width: 1),
                        ),
                        child: const Icon(Icons.arrow_back_ios_new,
                            size: 14, color: Color(0xFF5BA3F5)),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 11),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0F1E30),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: const Color(0xFF1A2D45), width: 1),
                        ),
                        child: Row(
                          children: [
                            Container(
                                width: 6,
                                height: 6,
                                decoration: const BoxDecoration(
                                    color: Color(0xFF2B7FE0),
                                    shape: BoxShape.circle)),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(location.name,
                                  style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                      color: Color(0xFFE8F0F8),
                                      letterSpacing: 0.1),
                                  overflow: TextOverflow.ellipsis),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Legend pill
          Positioned(
            top: 108,
            right: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFF0F1E30),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFF1A2D45), width: 1),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _LegendRow(color: Color(0xFF2B7FE0), label: 'Eco route'),
                  SizedBox(height: 6),
                  _LegendRow(
                      color: Color(0xFF1A2D45),
                      label: 'Original',
                      dashed: true),
                ],
              ),
            ),
          ),

          // Bottom card
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(16, 18, 16, 36),
              decoration: const BoxDecoration(
                color: Color(0xFF0A1628),
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                border:
                    Border(top: BorderSide(color: Color(0xFF1A2D45), width: 1)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 32,
                    height: 3,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                        color: const Color(0xFF1A2D45),
                        borderRadius: BorderRadius.circular(2)),
                  ),
                  Row(
                    children: [
                      Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                              color: Color(0xFF2B7FE0),
                              shape: BoxShape.circle)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text('Eco route to ${location.name}',
                            style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFFE8F0F8),
                                letterSpacing: 0.1),
                            overflow: TextOverflow.ellipsis),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                          child: _StatTile(
                              label: 'Particles saved',
                              value: '$savedMg mg',
                              valueColor: const Color(0xFF5BA3F5))),
                      const SizedBox(width: 8),
                      Expanded(
                          child: _StatTile(
                              label: 'Score drop',
                              value: '-$scoreDrop pts',
                              valueColor: const Color(0xFF5BA3F5))),
                      const SizedBox(width: 8),
                      const Expanded(
                          child: _StatTile(
                              label: 'Extra distance',
                              value: '+0.6 km',
                              valueColor: Color(0xFF4A7A9B))),
                    ],
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFF0F2040),
                        foregroundColor: const Color(0xFF5BA3F5),
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: const BorderSide(
                              color: Color(0xFF2B7FE0), width: 1),
                        ),
                      ),
                      onPressed: () {},
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.navigation_rounded, size: 16),
                          SizedBox(width: 8),
                          Text('Start navigation',
                              style: TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.w500)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  final String label;
  final String value;
  final Color valueColor;
  const _StatTile(
      {required this.label, required this.value, required this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
      decoration: BoxDecoration(
        color: const Color(0xFF0F1E30),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFF1A2D45), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(fontSize: 10, color: Color(0xFF4A7A9B))),
          const SizedBox(height: 4),
          Text(value,
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: valueColor)),
        ],
      ),
    );
  }
}

class _LegendRow extends StatelessWidget {
  final Color color;
  final String label;
  final bool dashed;
  const _LegendRow(
      {required this.color, required this.label, this.dashed = false});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
            width: 20,
            height: 12,
            child: CustomPaint(
                painter: _LinePainter(color: color, dashed: dashed))),
        const SizedBox(width: 8),
        Text(label,
            style: const TextStyle(fontSize: 11, color: Color(0xFF5BA3F5))),
      ],
    );
  }
}

class _LinePainter extends CustomPainter {
  final Color color;
  final bool dashed;
  _LinePainter({required this.color, required this.dashed});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;
    if (dashed) {
      canvas.drawLine(const Offset(0, 6), const Offset(7, 6), paint);
      canvas.drawLine(const Offset(12, 6), const Offset(20, 6), paint);
    } else {
      canvas.drawLine(const Offset(0, 6), const Offset(20, 6), paint);
    }
  }

  @override
  bool shouldRepaint(_) => false;
}
