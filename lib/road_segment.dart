import 'package:latlong2/latlong.dart';

/// Represents one road segment from the TireTrace GeoJSON.
/// Produced by the Python pipeline and loaded via GeoJsonService.
class RoadSegment {
  final String streetName;
  final int aadt;
  final double distToWaterM;
  final double runoffMgPerMonth;
  final double ppdMgPerMonth;
  final double pollutionScore; // 0–100 normalized
  final double lengthKm;
  final List<LatLng> geometry;
  final String city;
  final String nearestWaterway;

  const RoadSegment({
    required this.streetName,
    required this.aadt,
    required this.distToWaterM,
    required this.runoffMgPerMonth,
    required this.ppdMgPerMonth,
    required this.pollutionScore,
    required this.lengthKm,
    required this.geometry,
    required this.city,
    required this.nearestWaterway,
  });

  /// Centroid of the road segment — used for distance calculations
  LatLng get centroid {
    if (geometry.isEmpty) return const LatLng(42.707, -71.163);
    final lat = geometry.map((p) => p.latitude).reduce((a, b) => a + b) /
        geometry.length;
    final lng = geometry.map((p) => p.longitude).reduce((a, b) => a + b) /
        geometry.length;
    return LatLng(lat, lng);
  }

  /// Straight-line distance in meters from this segment's centroid to a point
  double distanceTo(double lat, double lng) {
    const dist = Distance();
    return dist.as(LengthUnit.Meter, centroid, LatLng(lat, lng));
  }

  /// Human-readable monthly runoff string
  String get runoffFormatted {
    if (runoffMgPerMonth >= 1000000) {
      return '${(runoffMgPerMonth / 1000000).toStringAsFixed(1)}M mg/mo';
    }
    if (runoffMgPerMonth >= 1000) {
      return '${(runoffMgPerMonth / 1000).toStringAsFixed(0)}K mg/mo';
    }
    return '${runoffMgPerMonth.toStringAsFixed(0)} mg/mo';
  }

  /// Score label based on pollution_score
  String get scoreLabel {
    if (pollutionScore >= 75) return 'Critical';
    if (pollutionScore >= 50) return 'High';
    if (pollutionScore >= 25) return 'Medium';
    return 'Low';
  }

  /// Auto-generated reason text from real data fields
  String get reasonText {
    final trafficDesc = aadt > 50000
        ? 'extremely high traffic ($aadt vehicles/day)'
        : aadt > 20000
            ? 'high traffic ($aadt vehicles/day)'
            : 'moderate traffic ($aadt vehicles/day)';

    final proximityDesc = distToWaterM < 50
        ? 'drains directly into waterway (${distToWaterM.toStringAsFixed(0)}m)'
        : distToWaterM < 200
            ? 'very close to waterway (${distToWaterM.toStringAsFixed(0)}m)'
            : 'connects via stormwater system (${(distToWaterM / 1000).toStringAsFixed(1)}km)';

    return '$runoffFormatted of tire particles reach $nearestWaterway monthly. '
        '${trafficDesc[0].toUpperCase()}${trafficDesc.substring(1)}, $proximityDesc.';
  }
}
