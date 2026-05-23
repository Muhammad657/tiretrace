import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:tiretrace/fakeData.dart';

// ── Palette ────────────────────────────────────────────────────────────────
const _navy = Color(0xFF0A1628);
const _panel = Color(0xFF0F1E30);
const _border = Color(0xFF1A2D45);
const _blue = Color(0xFF2B7FE0);
const _dim = Color(0xFF4A7A9B);
const _text = Color(0xFFE8F0F8);
const _eco = Color(0xFF34C759); // green eco route
const _warn = Color(0xFFF39C12);

class MapScreen extends StatefulWidget {
  final Location location;
  const MapScreen({super.key, required this.location});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController _map = MapController();

  LatLng? _userPos;
  bool _locating = true;
  bool _locationDenied = false;

  // ── Derived geometry ─────────────────────────────────────────────────────

  LatLng get _dest => LatLng(widget.location.lat, widget.location.lng);

  /// If GPS failed, use a point ~1.2 km south-west of the destination
  /// so the route still looks sensible rather than starting off-screen.
  LatLng get _start =>
      _userPos ??
      LatLng(widget.location.lat - 0.012, widget.location.lng - 0.009);

  List<LatLng> get _ecoRoute {
    final mid = LatLng(
      (_start.latitude + _dest.latitude) / 2 + 0.004,
      (_start.longitude + _dest.longitude) / 2 - 0.002,
    );
    return [_start, mid, _dest];
  }

  List<LatLng> get _originalRoute {
    final mid = LatLng(
      (_start.latitude + _dest.latitude) / 2 - 0.004,
      (_start.longitude + _dest.longitude) / 2 + 0.002,
    );
    return [_start, mid, _dest];
  }

  LatLng get _mapCenter => LatLng(
        (_start.latitude + _dest.latitude) / 2,
        (_start.longitude + _dest.longitude) / 2,
      );

  // ── Lifecycle ─────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _fetchLocation();
  }

  @override
  void dispose() {
    _map.dispose();
    super.dispose();
  }

  // ── Location ──────────────────────────────────────────────────────────────

  Future<void> _fetchLocation() async {
    setState(() {
      _locating = true;
      _locationDenied = false;
    });

    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        throw const _LocationException('Location services disabled');
      }

      var perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }
      if (perm == LocationPermission.denied ||
          perm == LocationPermission.deniedForever) {
        throw const _LocationException('Permission denied');
      }

      final pos = await Geolocator.getCurrentPosition(
        locationSettings:
            const LocationSettings(accuracy: LocationAccuracy.medium),
      ).timeout(const Duration(seconds: 10));

      if (!mounted) return;
      setState(() {
        _userPos = LatLng(pos.latitude, pos.longitude);
        _locating = false;
      });

      // Small delay so the map controller is ready after setState
      await Future<void>.delayed(const Duration(milliseconds: 100));
      if (mounted) _fitToRoute();
    } on _LocationException {
      if (!mounted) return;
      setState(() {
        _locating = false;
        _locationDenied = true;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _locating = false;
        _locationDenied = true;
      });
    }
  }

  void _fitToRoute() {
    final pts = [_start, _dest];
    final bounds = LatLngBounds.fromPoints(pts);
    _map.fitCamera(
      CameraFit.bounds(
        bounds: bounds,
        padding: const EdgeInsets.fromLTRB(48, 120, 48, 300),
        maxZoom: 15,
      ),
    );
  }

  void _recenter() {
    if (_userPos != null) {
      _fitToRoute();
    } else {
      _fetchLocation();
    }
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final savedMg = (widget.location.pollutionScore * 0.38).round();
    final scoreDrop = (widget.location.pollutionScore * 0.35).round();

    return Scaffold(
      backgroundColor: _navy,
      body: Stack(
        children: [
          // ── Map ──────────────────────────────────────────────────────────
          FlutterMap(
            mapController: _map,
            options: MapOptions(
              initialCenter: _mapCenter,
              initialZoom: 13.5,
              minZoom: 4.0, // allow zooming all the way out
              maxZoom: 18.0,
              interactionOptions: const InteractionOptions(
                flags: InteractiveFlag.all, // pinch, scroll, drag — all enabled
              ),
            ),
            children: [
              // CartoDB Voyager — readable light basemap, free, no key needed
              TileLayer(
                urlTemplate:
                    'https://{s}.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}.png',
                subdomains: const ['a', 'b', 'c', 'd'],
                userAgentPackageName: 'com.tiretrace.app',
                maxZoom: 19,
              ),

              // Original route — dashed grey
              PolylineLayer(polylines: [
                Polyline(
                  points: _originalRoute,
                  color: Colors.grey.withOpacity(0.55),
                  strokeWidth: 4,
                  pattern: StrokePattern.dashed(segments: const [8, 6]),
                ),
              ]),

              // Eco route — bright green
              PolylineLayer(polylines: [
                Polyline(
                  points: _ecoRoute,
                  color: _eco,
                  strokeWidth: 5.5,
                  strokeCap: StrokeCap.round,
                ),
              ]),

              MarkerLayer(
                markers: [
                  // User blue dot
                  if (_userPos != null)
                    Marker(
                      point: _userPos!,
                      width: 26,
                      height: 26,
                      child: Container(
                        decoration: BoxDecoration(
                          color: _blue,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 3),
                          boxShadow: [
                            BoxShadow(
                              color: _blue.withOpacity(0.45),
                              blurRadius: 12,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                      ),
                    ),

                  // Destination pin
                  Marker(
                    point: _dest,
                    width: 44,
                    height: 56,
                    alignment: Alignment.topCenter,
                    child: Column(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: _eco,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2.5),
                            boxShadow: [
                              BoxShadow(
                                color: _eco.withOpacity(0.5),
                                blurRadius: 14,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.location_on,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                        Container(width: 2, height: 12, color: _eco),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),

          // ── Top bar (white card on light map) ───────────────────────────
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
                child: Row(
                  children: [
                    _MapButton(
                      onTap: () => Navigator.pop(context),
                      child: const Icon(
                        Icons.arrow_back_ios_new,
                        size: 14,
                        color: Color(0xFF1A2332),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.12),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 7,
                              height: 7,
                              decoration: const BoxDecoration(
                                  color: _eco, shape: BoxShape.circle),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                widget.location.name,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF1A2332),
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
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

          // ── Loading pill ─────────────────────────────────────────────────
          if (_locating)
            Positioned(
              top: 100,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.12),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 12,
                        height: 12,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: _blue,
                        ),
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Finding your location…',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF1A2332),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // ── Permission denied banner ──────────────────────────────────────
          if (_locationDenied && !_locating)
            Positioned(
              top: 100,
              left: 16,
              right: 16,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF8EE),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: _warn.withOpacity(0.4)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 6,
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const Icon(Icons.location_off, color: _warn, size: 16),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'Location unavailable — showing approximate route',
                        style: TextStyle(color: _warn, fontSize: 11),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Geolocator.openAppSettings(),
                      child: const Text(
                        'Enable',
                        style: TextStyle(
                          color: _blue,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // ── Legend ────────────────────────────────────────────────────────
          Positioned(
            top: 100,
            right: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.10),
                    blurRadius: 6,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _LegendRow(color: _eco, label: 'Eco route'),
                  const SizedBox(height: 6),
                  _LegendRow(
                      color: Colors.grey, label: 'Original', dashed: true),
                ],
              ),
            ),
          ),

          // ── Zoom + recenter controls ──────────────────────────────────────
          Positioned(
            right: 12,
            bottom: 300,
            child: Column(
              children: [
                _MapButton(
                  onTap: () => _map.move(
                    _map.camera.center,
                    (_map.camera.zoom + 1).clamp(4.0, 18.0),
                  ),
                  child:
                      const Icon(Icons.add, size: 18, color: Color(0xFF1A2332)),
                ),
                const SizedBox(height: 2),
                _MapButton(
                  onTap: () => _map.move(
                    _map.camera.center,
                    (_map.camera.zoom - 1).clamp(4.0, 18.0),
                  ),
                  child: const Icon(Icons.remove,
                      size: 18, color: Color(0xFF1A2332)),
                ),
                const SizedBox(height: 8),
                _MapButton(
                  onTap: _recenter,
                  child: Icon(
                    _userPos != null
                        ? Icons.my_location
                        : Icons.location_searching,
                    size: 18,
                    color: _userPos != null ? _blue : const Color(0xFF1A2332),
                  ),
                ),
              ],
            ),
          ),

          // ── Bottom card ───────────────────────────────────────────────────
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(16, 18, 16, 36),
              decoration: const BoxDecoration(
                color: _navy,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 32,
                    height: 3,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: _border,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                            color: _eco, shape: BoxShape.circle),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Eco route to ${widget.location.name}',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: _text,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
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
                          color: const Color(0xFF5BA3F5),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _StatTile(
                          label: 'Score drop',
                          value: '-$scoreDrop pts',
                          color: const Color(0xFF5BA3F5),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: _StatTile(
                          label: 'Extra distance',
                          value: '+0.6 km',
                          color: _dim,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: _eco,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {},
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.navigation_rounded, size: 16),
                          SizedBox(width: 8),
                          Text(
                            'Start navigation',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
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

// ── Reusable map button (white card, shadow) ───────────────────────────────

class _MapButton extends StatelessWidget {
  final Widget child;
  final VoidCallback onTap;
  const _MapButton({required this.child, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(child: child),
      ),
    );
  }
}

// ── Stat tile ──────────────────────────────────────────────────────────────

class _StatTile extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _StatTile(
      {required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
      decoration: BoxDecoration(
        color: const Color(0xFF0F1E30),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFF1A2D45)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 10, color: Color(0xFF4A7A9B)),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Legend row ─────────────────────────────────────────────────────────────

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
            painter: _LinePainter(color: color, dashed: dashed),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: Color(0xFF1A2332)),
        ),
      ],
    );
  }
}

class _LinePainter extends CustomPainter {
  final Color color;
  final bool dashed;
  const _LinePainter({required this.color, required this.dashed});

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

// ── Internal exception ────────────────────────────────────────────────────

class _LocationException implements Exception {
  final String message;
  const _LocationException(this.message);
}
