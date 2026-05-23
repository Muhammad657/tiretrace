import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'road_segment.dart';

class GeoJsonService {
  static final GeoJsonService _instance = GeoJsonService._internal();
  factory GeoJsonService() => _instance;
  GeoJsonService._internal();

  // ── Config — replace with your real GitHub raw URL ──────────────────────
  static const String _geojsonUrl =
      'https://raw.githubusercontent.com/Muhammad657/tiretrace/main/road_runoff_scores.geojson';

  // ── State ────────────────────────────────────────────────────────────────
  List<RoadSegment> _segments = [];
  bool _isLoaded = false;
  bool _isLoading = false;
  String? _error;

  bool get isLoaded => _isLoaded;
  bool get hasError => _error != null;
  String? get error => _error;
  int get segmentCount => _segments.length;

  // ── Initialize ───────────────────────────────────────────────────────────

  Future<void> initialize() async {
    if (_isLoaded || _isLoading) return;
    _isLoading = true;
    _error = null;

    try {
      final response = await http
          .get(Uri.parse(_geojsonUrl))
          .timeout(const Duration(seconds: 30));

      if (response.statusCode != 200) {
        throw Exception('Server returned HTTP ${response.statusCode}');
      }

      // Parse on a background isolate — never blocks the UI thread
      _segments = await compute(_parseGeoJson, response.body);
      _isLoaded = true;
      debugPrint('GeoJsonService: loaded ${_segments.length} segments');
    } catch (e) {
      _error = e.toString();
      debugPrint('GeoJsonService error: $e');
    } finally {
      _isLoading = false;
    }
  }

  // ── Geojson parser ─────────────────────────────────────

  static List<RoadSegment> _parseGeoJson(String raw) {
    final geoJson = jsonDecode(raw) as Map<String, dynamic>;
    final features = geoJson['features'] as List<dynamic>;
    final result = <RoadSegment>[];

    for (final f in features) {
      try {
        final props = f['properties'] as Map<String, dynamic>;
        final geom = f['geometry'] as Map<String, dynamic>;
        if (geom['type'] != 'LineString') continue;

        // GeoJSON coords are [lng, lat] — possibly [lng, lat, z]
        final coords = geom['coordinates'] as List<dynamic>;
        final geometry = coords.map<LatLng>((c) {
          final pt = c as List<dynamic>;
          return LatLng((pt[1] as num).toDouble(), (pt[0] as num).toDouble());
        }).toList();
        if (geometry.isEmpty) continue;

        final streetName = (props['STREETNAME'] as String? ?? 'Unknown').trim();
        final aadt = (props['AADT'] as num?)?.toInt() ?? 0;
        final dist = (props['dist_to_water_m'] as num?)?.toDouble() ?? 0.0;
        final runoff =
            (props['runoff_mg_per_month'] as num?)?.toDouble() ?? 0.0;
        final ppd = (props['ppd_mg_per_month'] as num?)?.toDouble() ?? 0.0;
        final score = (props['pollution_score'] as num?)?.toDouble() ?? 0.0;
        final length = (props['length_km'] as num?)?.toDouble() ?? 0.0;

        // city + nearest_waterway come from the Python pipeline.
        // Fall back to bounding box detection if not present.
        final city = (props['city'] as String?) ?? _detectCity(geometry);
        final waterway =
            (props['nearest_waterway'] as String?) ?? _defaultWaterway(city);

        result.add(RoadSegment(
          streetName: streetName,
          aadt: aadt,
          distToWaterM: dist,
          runoffMgPerMonth: runoff,
          ppdMgPerMonth: ppd,
          pollutionScore: score,
          lengthKm: length,
          geometry: geometry,
          city: city,
          nearestWaterway: waterway,
        ));
      } catch (_) {
        continue;
      }
    }

    result.sort((a, b) => b.runoffMgPerMonth.compareTo(a.runoffMgPerMonth));
    return result;
  }

  // ── City detection fallback ───────────────────────────────────────────────

  static String _detectCity(List<LatLng> geometry) {
    if (geometry.isEmpty) return 'Merrimack Region';
    final lat = geometry.map((p) => p.latitude).reduce((a, b) => a + b) /
        geometry.length;
    final lng = geometry.map((p) => p.longitude).reduce((a, b) => a + b) /
        geometry.length;

    const bounds = [
      ('Lawrence', 42.685, 42.730, -71.215, -71.145),
      ('Lowell', 42.615, 42.665, -71.380, -71.285),
      ('Haverhill', 42.750, 42.800, -71.130, -71.045),
      ('Andover', 42.640, 42.700, -71.175, -71.110),
      ('Methuen', 42.710, 42.760, -71.250, -71.165),
      ('North Andover', 42.680, 42.710, -71.140, -71.090),
      ('Dracut', 42.660, 42.700, -71.340, -71.270),
      ('Tewksbury', 42.595, 42.645, -71.260, -71.195),
      ('Chelmsford', 42.580, 42.640, -71.380, -71.310),
    ];

    for (final (name, minLat, maxLat, minLng, maxLng) in bounds) {
      if (lat >= minLat && lat <= maxLat && lng >= minLng && lng <= maxLng) {
        return name;
      }
    }
    return 'Merrimack Region';
  }

  static String _defaultWaterway(String city) => switch (city) {
        'Lawrence' => 'Merrimack River',
        'Lowell' => 'Merrimack River',
        'Haverhill' => 'Merrimack River',
        'Andover' => 'Shawsheen River',
        'Methuen' => 'Spicket River',
        'North Andover' => 'Cochichewick Brook',
        'Dracut' => 'Merrimack River',
        'Tewksbury' => 'Merrimack River',
        'Chelmsford' => 'Merrimack River',
        _ => 'Merrimack River',
      };

  // ── Public query API ─────────────────────────────────────────────────────

  /// Top roads for a city by runoff (highest first). Default limit = 5.
  List<RoadSegment> getTopRoadsForCity(String city, {int limit = 5}) {
    if (!_isLoaded) return [];
    final q = city.toLowerCase().trim();
    return _segments
        .where((s) => s.city.toLowerCase().contains(q))
        .take(limit)
        .toList();
  }

  /// All cities that have at least one road segment, sorted A–Z.
  List<String> get availableCities {
    if (!_isLoaded) return [];
    return _segments.map((s) => s.city).toSet().toList()..sort();
  }

  /// Nearest road segment to a lat/lng — used by SearchScreen to enrich Location data.
  RoadSegment? getNearestSegment(double lat, double lng) {
    if (!_isLoaded || _segments.isEmpty) return null;
    RoadSegment? nearest;
    double minDist = double.infinity;
    for (final seg in _segments) {
      final d = seg.distanceTo(lat, lng);
      if (d < minDist) {
        minDist = d;
        nearest = seg;
      }
    }
    return nearest;
  }

  /// All segments — used by MapScreen to render the full road layer.
  List<RoadSegment> get allSegments => List.unmodifiable(_segments);
}
