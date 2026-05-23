// fakeData.dart
// Class definitions stay identical — only the data changes.
// allLocations now uses real Massachusetts destinations near the Merrimack watershed.
// cityHotspots is kept as a loading fallback; HotspotScreen uses GeoJsonService for live data.

class Location {
  final String name;
  final String subtitle;
  final int pollutionScore;
  final String particlesMg;
  final String waterway;
  final String waterwaySentence;
  final double lat;
  final double lng;

  const Location({
    required this.name,
    required this.subtitle,
    required this.pollutionScore,
    required this.particlesMg,
    required this.waterway,
    required this.waterwaySentence,
    required this.lat,
    required this.lng,
  });
}

class TireRecommendation {
  final String brand;
  final String model;
  final String shedRating;
  final String reason;
  final String priceRange;

  const TireRecommendation({
    required this.brand,
    required this.model,
    required this.shedRating,
    required this.reason,
    required this.priceRange,
  });
}

class CityHotspot {
  final String city;
  final List<RoadHotspot> roads;
  const CityHotspot({required this.city, required this.roads});
}

class RoadHotspot {
  final String road;
  final String waterway;
  final int score;
  final String reason;
  const RoadHotspot({
    required this.road,
    required this.waterway,
    required this.score,
    required this.reason,
  });
}

// ── Real Massachusetts destinations ─────────────────────────────────────────
// Pollution scores and particle estimates are derived from the TireTrace
// runoff model output for roads nearest each destination.

const List<Location> allLocations = [
  Location(
    name: 'Merrimack River Greenway',
    subtitle: 'Lawrence, MA · Riverfront',
    pollutionScore: 95,
    particlesMg: '487 mg',
    waterway: 'Merrimack River',
    waterwaySentence:
        'Routes to the Greenway pass directly over outfall drains with zero buffer to the Merrimack. '
        'Merrimack Street scored 100/100 in our model — the highest runoff segment in the entire dataset.',
    lat: 42.7073,
    lng: -71.1620,
  ),
  Location(
    name: 'Lawrence City Hall',
    subtitle: 'Lawrence, MA · Essex Street',
    pollutionScore: 87,
    particlesMg: '342 mg',
    waterway: 'Merrimack River',
    waterwaySentence:
        'Downtown Lawrence routes pass over storm drains that discharge into the Merrimack within a quarter mile. '
        'Essex Street is among the highest-traffic corridors in the watershed with direct waterway connections.',
    lat: 42.7070,
    lng: -71.1631,
  ),
  Location(
    name: 'UMass Lowell',
    subtitle: 'Lowell, MA · University Ave',
    pollutionScore: 79,
    particlesMg: '298 mg',
    waterway: 'Merrimack River',
    waterwaySentence:
        'University Avenue and Pawtucket Street carry heavy commuter traffic that drains via Lowell\'s '
        'combined stormwater system into the Merrimack River, which runs directly through campus.',
    lat: 42.6518,
    lng: -71.3243,
  ),
  Location(
    name: 'Methuen Plaza',
    subtitle: 'Methuen, MA · Lowell Street',
    pollutionScore: 81,
    particlesMg: '319 mg',
    waterway: 'Spicket River',
    waterwaySentence:
        'Lowell Street\'s high traffic volume and proximity to the Spicket River creates one of Methuen\'s '
        'most critical runoff corridors, depositing tire particles into the Merrimack watershed daily.',
    lat: 42.7282,
    lng: -71.1857,
  ),
  Location(
    name: 'Haverhill Station',
    subtitle: 'Haverhill, MA · Commuter Rail',
    pollutionScore: 68,
    particlesMg: '255 mg',
    waterway: 'Merrimack River',
    waterwaySentence:
        'Routes through Haverhill cross multiple stormwater outfalls draining into the Merrimack. '
        'The Bradford Bridge corridor is one of the highest runoff segments in the northern watershed.',
    lat: 42.7762,
    lng: -71.0773,
  ),
  Location(
    name: 'Lowell General Hospital',
    subtitle: 'Lowell, MA · Chelmsford Street',
    pollutionScore: 74,
    particlesMg: '278 mg',
    waterway: 'Merrimack River',
    waterwaySentence:
        'Chelmsford Street is a high-volume arterial with direct stormwater connections to the Merrimack. '
        'The I-495 and Route 3 interchange nearby compounds runoff loads from multiple road surfaces.',
    lat: 42.6418,
    lng: -71.3188,
  ),
  Location(
    name: 'Andover Town Center',
    subtitle: 'Andover, MA · Main Street',
    pollutionScore: 52,
    particlesMg: '194 mg',
    waterway: 'Shawsheen River',
    waterwaySentence:
        'Main Street in Andover drains into the Shawsheen River, a Merrimack tributary with limited '
        'natural filtration. Though traffic is lower, the road\'s proximity to the river amplifies impact.',
    lat: 42.6584,
    lng: -71.1370,
  ),
];

// ── Tire recommendations — unchanged ─────────────────────────────────────────

const List<TireRecommendation> tireRecommendations = [
  TireRecommendation(
    brand: 'Michelin',
    model: 'CrossClimate 2',
    shedRating: 'Very Low',
    reason:
        'Optimised silica compound sheds up to 40% fewer particles than standard tires',
    priceRange: '\$160–\$210',
  ),
  TireRecommendation(
    brand: 'Continental',
    model: 'EcoContact 6',
    shedRating: 'Low',
    reason:
        'Green rubber technology significantly reduces road abrasion and particle shedding',
    priceRange: '\$120–\$165',
  ),
  TireRecommendation(
    brand: 'Bridgestone',
    model: 'Ecopia EP500',
    shedRating: 'Low',
    reason:
        'Nano Pro-Tech compound minimises particle shedding, especially on wet road surfaces',
    priceRange: '\$135–\$180',
  ),
];

// ── Fallback city hotspots (shown while GeoJsonService loads) ─────────────────
// HotspotScreen replaces these with live GeoJsonService data once loaded.

const List<CityHotspot> cityHotspots = [
  CityHotspot(
    city: 'Lawrence',
    roads: [
      RoadHotspot(
        road: 'Merrimack Street',
        waterway: 'Merrimack River',
        score: 100,
        reason:
            '17,820 vehicles/day, only 15m from the Merrimack. 93% of tire particles reach the water directly per rain event.',
      ),
      RoadHotspot(
        road: 'Broadway (Route 28)',
        waterway: 'Merrimack River',
        score: 84,
        reason:
            'Major arterial with 45,000+ daily vehicles and multiple drain outfalls within 100m of the river.',
      ),
      RoadHotspot(
        road: 'Essex Street',
        waterway: 'Merrimack River',
        score: 76,
        reason:
            'Dense stop-and-go traffic through downtown Lawrence feeds directly into Merrimack outfalls.',
      ),
    ],
  ),
  CityHotspot(
    city: 'Lowell',
    roads: [
      RoadHotspot(
        road: 'Pawtucket Street',
        waterway: 'Merrimack River',
        score: 91,
        reason:
            'High-speed road running parallel to the Merrimack with minimal vegetation buffer.',
      ),
      RoadHotspot(
        road: 'University Avenue',
        waterway: 'Merrimack River',
        score: 79,
        reason:
            'Heavy commuter traffic near UMass Lowell drains into the Merrimack via campus stormwater system.',
      ),
      RoadHotspot(
        road: 'Chelmsford Street',
        waterway: 'Merrimack River',
        score: 74,
        reason:
            'Major arterial connecting I-495 to downtown Lowell, feeding multiple river outfalls.',
      ),
    ],
  ),
  CityHotspot(
    city: 'Haverhill',
    roads: [
      RoadHotspot(
        road: 'Bradford Bridge (Route 97)',
        waterway: 'Merrimack River',
        score: 88,
        reason:
            'Bridge deck runoff enters the Merrimack directly below. No stormwater treatment in place.',
      ),
      RoadHotspot(
        road: 'Route 125 (Plaistow Road)',
        waterway: 'Merrimack River',
        score: 72,
        reason:
            'High-traffic state route with stormwater drains connecting to the Merrimack watershed.',
      ),
    ],
  ),
  CityHotspot(
    city: 'Methuen',
    roads: [
      RoadHotspot(
        road: 'Lowell Street',
        waterway: 'Spicket River',
        score: 83,
        reason:
            'Dense commercial corridor draining into the Spicket River, a direct Merrimack tributary.',
      ),
      RoadHotspot(
        road: 'Route 213 (Methuen Connector)',
        waterway: 'Spicket River',
        score: 78,
        reason:
            'Highway-speed road with high tire wear rates and direct stormwater connection to Spicket River.',
      ),
    ],
  ),
];

CityHotspot? getHotspotForCity(String query) {
  final q = query.toLowerCase().trim();
  for (final h in cityHotspots) {
    if (h.city.toLowerCase().contains(q)) return h;
  }
  return null;
}
