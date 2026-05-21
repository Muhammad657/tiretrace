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
  final String shedRating; // 'Low', 'Very Low'
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

const List<Location> allLocations = [
  Location(
    name: 'Caltrain Station',
    subtitle: 'San Jose, CA · 4.2 km',
    pollutionScore: 74,
    particlesMg: '311 mg',
    waterway: 'Guadalupe River',
    waterwaySentence:
        'Runoff from El Camino Real flows into storm drains that connect directly to the Guadalupe River, reaching the bay within hours of rain.',
    lat: 37.3297,
    lng: -121.9025,
  ),
  Location(
    name: 'Logan Airport',
    subtitle: 'Boston, MA · 44 km',
    pollutionScore: 78,
    particlesMg: '618 mg',
    waterway: 'Boston Inner Harbor',
    waterwaySentence:
        'Logan\'s four EPA-permitted outfalls discharge stormwater from terminals and access roads directly into Boston Harbor and Winthrop Bay.',
    lat: 42.3656,
    lng: -71.0096,
  ),
  Location(
    name: 'Calero Reservoir',
    subtitle: 'Santa Clara County · 18.1 km',
    pollutionScore: 61,
    particlesMg: '256 mg',
    waterway: 'Calero Creek',
    waterwaySentence:
        'Roads leading to Calero drain into Calero Creek, which feeds directly into the reservoir — a drinking water source for the region.',
    lat: 37.1712,
    lng: -121.7697,
  ),
  Location(
    name: 'Farmers Market, Palo Alto',
    subtitle: 'Palo Alto, CA · 22.4 km',
    pollutionScore: 88,
    particlesMg: '370 mg',
    waterway: 'San Francisquito Creek',
    waterwaySentence:
        'University Ave and El Camino Real are among the highest shedding corridors in the area, draining into San Francisquito Creek and eventually the Bay.',
    lat: 37.4419,
    lng: -122.1430,
  ),
  Location(
    name: 'Cal State East Bay',
    subtitle: 'Hayward, CA · 31.7 km',
    pollutionScore: 55,
    particlesMg: '231 mg',
    waterway: 'San Lorenzo Creek',
    waterwaySentence:
        'Highway 580 runoff connects to San Lorenzo Creek via several tributary drains, eventually reaching the San Francisco Bay.',
    lat: 37.6588,
    lng: -122.0572,
  ),
  Location(
    name: 'Mountain View Caltrain',
    subtitle: 'Mountain View, CA · 19.8 km',
    pollutionScore: 69,
    particlesMg: '290 mg',
    waterway: 'Stevens Creek',
    waterwaySentence:
        'Castro Street and Central Expressway runoff drains into Stevens Creek, which flows into the South Bay and its protected wetlands.',
    lat: 37.3942,
    lng: -122.0762,
  ),
  Location(
    name: 'Guadalupe River Park',
    subtitle: 'San Jose, CA · 2.8 km',
    pollutionScore: 82,
    particlesMg: '344 mg',
    waterway: 'Guadalupe River',
    waterwaySentence:
        'This route passes directly over storm drain outfalls that discharge into the Guadalupe River — one of the most microplastic-impacted waterways in the county.',
    lat: 37.3387,
    lng: -121.8952,
  ),
];

const List<TireRecommendation> tireRecommendations = [
  TireRecommendation(
    brand: 'Michelin',
    model: 'CrossClimate 2',
    shedRating: 'Very Low',
    reason: 'Optimised silica compound sheds up to 40% fewer particles',
    priceRange: '\$160–\$210',
  ),
  TireRecommendation(
    brand: 'Continental',
    model: 'EcoContact 6',
    shedRating: 'Low',
    reason: 'Green rubber technology reduces road abrasion significantly',
    priceRange: '\$120–\$165',
  ),
  TireRecommendation(
    brand: 'Bridgestone',
    model: 'Ecopia EP500',
    shedRating: 'Low',
    reason: 'Nano Pro-Tech compound minimises particle shedding on wet roads',
    priceRange: '\$135–\$180',
  ),
];

const List<CityHotspot> cityHotspots = [
  CityHotspot(
    city: 'San Jose',
    roads: [
      RoadHotspot(
        road: 'El Camino Real',
        waterway: 'Guadalupe River',
        score: 91,
        reason: 'Heavy traffic arterial with direct storm drain connections',
      ),
      RoadHotspot(
        road: 'I-280 / Hwy 101 interchange',
        waterway: 'Coyote Creek',
        score: 87,
        reason: 'High-speed merge zones cause extreme tire abrasion',
      ),
      RoadHotspot(
        road: 'Story Road',
        waterway: 'Guadalupe River',
        score: 74,
        reason: 'Stop-and-go traffic increases particle shed per km',
      ),
    ],
  ),
  CityHotspot(
    city: 'Boston',
    roads: [
      RoadHotspot(
        road: 'I-93 South (downtown)',
        waterway: 'Boston Inner Harbor',
        score: 94,
        reason: 'Elevated highway runoff drains directly into the harbor',
      ),
      RoadHotspot(
        road: 'Mass Ave Bridge',
        waterway: 'Charles River',
        score: 88,
        reason: 'Bridge deck runoff enters the Charles River immediately',
      ),
      RoadHotspot(
        road: 'Storrow Drive',
        waterway: 'Charles River',
        score: 81,
        reason: 'Road runs parallel to the river with no filtration buffer',
      ),
    ],
  ),
  CityHotspot(
    city: 'Los Angeles',
    roads: [
      RoadHotspot(
        road: 'I-405 (Sepulveda Pass)',
        waterway: 'Ballona Creek',
        score: 96,
        reason: 'One of the highest traffic volume roads in the US',
      ),
      RoadHotspot(
        road: 'Sunset Blvd',
        waterway: 'Santa Monica Bay',
        score: 83,
        reason: 'Steep gradient accelerates runoff to coastal storm drains',
      ),
      RoadHotspot(
        road: 'Olympic Blvd',
        waterway: 'Ballona Creek',
        score: 78,
        reason: 'Dense commuter corridor with degraded road surface',
      ),
    ],
  ),
  CityHotspot(
    city: 'Boston',
    roads: [
      RoadHotspot(
        road: 'I-93 (Dorchester / Neponset Circle)',
        waterway: 'Davenport Creek → Boston Harbor',
        score: 94,
        reason:
            'Stormwater from I-93 near Neponset Circle drains into Davenport Creek, which flows directly into Boston Harbor — confirmed by Boston Water and Sewer Commission outfall data.',
      ),
      RoadHotspot(
        road: 'Storrow Drive',
        waterway: 'Muddy River → Charles River',
        score: 88,
        reason:
            'Road runoff drains into the Muddy River, which flows under Storrow Drive into the Charles. The Muddy River is the most polluted tributary of the Charles, consistently graded D to C+ by the EPA.',
      ),
      RoadHotspot(
        road: 'Mass Ave Bridge',
        waterway: 'Charles River',
        score: 81,
        reason:
            'Bridge deck runoff enters the Charles River directly below. The lower Charles basin receives heavy stormwater pollution and drops in water quality grades during storm events.',
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
