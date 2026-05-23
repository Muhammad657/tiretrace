import 'package:flutter/material.dart';
import 'package:tiretrace/fakeData.dart';
import 'package:tiretrace/geojson_service.dart';
import 'package:tiretrace/theme/app_colors.dart';


class HotspotScreen extends StatefulWidget {
  const HotspotScreen({super.key});
  @override
  State<HotspotScreen> createState() => _HotspotScreenState();
}

class _HotspotScreenState extends State<HotspotScreen> {
  final TextEditingController _controller = TextEditingController();
  final GeoJsonService _service = GeoJsonService();

  String _query = '';

  // Returns real data from GeoJsonService if loaded, else falls back to fakeData
  List<RoadHotspot> _getRoads(String city) {
    if (_service.isLoaded) {
      return _service
          .getTopRoadsForCity(city, limit: 5)
          .map((seg) => RoadHotspot(
                road: _titleCase(seg.streetName),
                waterway: seg.nearestWaterway,
                score: seg.pollutionScore.round(),
                reason: seg.reasonText,
              ))
          .toList();
    }
    return getHotspotForCity(city)?.roads ?? [];
  }

  List<String> get _availableCities {
    if (_service.isLoaded) return _service.availableCities;
    return cityHotspots.map((c) => c.city).toList();
  }

  List<RoadHotspot> get _results {
    if (_query.isEmpty) return [];
    return _getRoads(_query);
  }

  String? get _resolvedCity {
    if (_query.isEmpty) return null;
    if (_service.isLoaded) {
      final match = _service.availableCities
          .where((c) => c.toLowerCase().contains(_query.toLowerCase()))
          .firstOrNull;
      return match;
    }
    return getHotspotForCity(_query)?.city;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final searched = _query.isNotEmpty;
    final results = _results;
    final city = _resolvedCity;

    return Scaffold(
      backgroundColor: appBg,
      appBar: AppBar(
        backgroundColor: appBg,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new,
              size: 16, color: appTextSecondary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'City Hotspot Map',
          style: TextStyle(
              fontSize: 16, fontWeight: FontWeight.w600, color: appTextPrimary),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(0.5),
          child: Container(height: 0.5, color: appBorder),
        ),
      ),
      body: Column(
        children: [
          // ── Search bar ────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Container(
              decoration: BoxDecoration(
                color: appSurface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: appBorder),
              ),
              child: Row(
                children: [
                  const Padding(
                    padding: EdgeInsets.only(left: 12),
                    child: Icon(Icons.location_city,
                        color: appTextTertiary, size: 18),
                  ),
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      onChanged: (v) => setState(() => _query = v),
                      style: const TextStyle(fontSize: 14, color: appTextPrimary),
                      cursorColor: appBlue,
                      decoration: const InputDecoration(
                        hintText: 'Search a city (e.g. Lawrence, Lowell)...',
                        hintStyle:
                            TextStyle(color: appTextTertiary, fontSize: 13),
                        border: InputBorder.none,
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 10, vertical: 14),
                      ),
                    ),
                  ),
                  if (_controller.text.isNotEmpty)
                    GestureDetector(
                      onTap: () => setState(() {
                        _controller.clear();
                        _query = '';
                      }),
                      child: const Padding(
                        padding: EdgeInsets.only(right: 12),
                        child:
                            Icon(Icons.close, color: appTextTertiary, size: 16),
                      ),
                    ),
                ],
              ),
            ),
          ),

          // ── Data source badge ─────────────────────────────────────────────
          if (_service.isLoaded)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
              child: Row(
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                        color: appGreen, shape: BoxShape.circle),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Live data · ${_service.segmentCount.toString()} road segments loaded',
                    style: const TextStyle(fontSize: 11, color: appTextTertiary),
                  ),
                ],
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
              child: Row(
                children: [
                  const SizedBox(
                    width: 10,
                    height: 10,
                    child: CircularProgressIndicator(
                      strokeWidth: 1.5,
                      color: appBlue,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _service.hasError
                        ? 'Using preview data · live data unavailable'
                        : 'Loading live road data...',
                    style: TextStyle(
                      fontSize: 11,
                      color: _service.hasError ? appHigh : appTextTertiary,
                    ),
                  ),
                ],
              ),
            ),

          const SizedBox(height: 12),

          // ── City chips ────────────────────────────────────────────────────
          if (!searched)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _availableCities
                    .map((c) => GestureDetector(
                          onTap: () => setState(() {
                            _query = c;
                            _controller.text = c;
                          }),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: appBlueLight,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: appBlue.withOpacity(0.2)),
                            ),
                            child: Text(c,
                                style: const TextStyle(
                                    fontSize: 12,
                                    color: appBlue,
                                    fontWeight: FontWeight.w500)),
                          ),
                        ))
                    .toList(),
              ),
            ),

          // ── Results ───────────────────────────────────────────────────────
          Expanded(
            child: searched && results.isEmpty
                ? _EmptyState(query: _query)
                : searched
                    ? ListView(
                        padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                        children: [
                          // City header
                          if (city != null) ...[
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(Icons.location_city,
                                    color: appBlue, size: 15),
                                const SizedBox(width: 7),
                                Text(city,
                                    style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                        color: appTextPrimary)),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: appCriticalBg,
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(
                                        color: appCritical.withOpacity(0.2)),
                                  ),
                                  child: Text('${results.length} hotspots',
                                      style: const TextStyle(
                                          fontSize: 11, color: appCritical)),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                          ],

                          ...results.asMap().entries.map((e) => _HotspotCard(
                                rank: e.key + 1,
                                hotspot: e.value,
                              )),

                          // Footer note
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: appSurface,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: appBorder),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(Icons.info_outline,
                                    size: 13, color: appTextTertiary),
                                const SizedBox(width: 8),
                                const Expanded(
                                  child: Text(
                                    'Scores computed from MA DOT traffic data, MassDEP stormwater infrastructure, and USGS watershed maps. Higher score = more tire particles reaching waterways per month.',
                                    style: TextStyle(
                                        fontSize: 11,
                                        color: appTextTertiary,
                                        height: 1.5),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      )
                    : _IdleState(cities: _availableCities),
          ),
        ],
      ),
    );
  }
}

// ── Hotspot card ──────────────────────────────────────────────────────────────

class _HotspotCard extends StatelessWidget {
  final int rank;
  final RoadHotspot hotspot;
  const _HotspotCard({required this.rank, required this.hotspot});

  Color get _scoreColor {
    if (hotspot.score >= 75) return appCritical;
    if (hotspot.score >= 50) return appHigh;
    if (hotspot.score >= 25) return appBlue;
    return appGreen;
  }

  Color get _scoreBg {
    if (hotspot.score >= 75) return appCriticalBg;
    if (hotspot.score >= 50) return appHighBg;
    if (hotspot.score >= 25) return appBlueLight;
    return appGreenLight;
  }

  String get _scoreLabel {
    if (hotspot.score >= 75) return 'Critical';
    if (hotspot.score >= 50) return 'High';
    if (hotspot.score >= 25) return 'Medium';
    return 'Low';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: appBorder),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 8,
              offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        children: [
          // Header row
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
            child: Row(
              children: [
                // Rank
                Container(
                  width: 26,
                  height: 26,
                  decoration: BoxDecoration(
                    color: _scoreBg,
                    shape: BoxShape.circle,
                    border: Border.all(color: _scoreColor.withOpacity(0.25)),
                  ),
                  child: Center(
                    child: Text('#$rank',
                        style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: _scoreColor)),
                  ),
                ),
                const SizedBox(width: 10),
                // Road name
                Expanded(
                  child: Text(hotspot.road,
                      style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: appTextPrimary)),
                ),
                // Score pill
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                  decoration: BoxDecoration(
                    color: _scoreBg,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: _scoreColor.withOpacity(0.2)),
                  ),
                  child: Text('${hotspot.score}  $_scoreLabel',
                      style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: _scoreColor)),
                ),
              ],
            ),
          ),

          // Divider
          Container(height: 0.5, color: appBorder),

          // Footer
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.water_drop_outlined,
                        size: 12, color: appBlue),
                    const SizedBox(width: 5),
                    Text('Drains to ${hotspot.waterway}',
                        style: const TextStyle(
                            fontSize: 12,
                            color: appBlue,
                            fontWeight: FontWeight.w500)),
                  ],
                ),
                const SizedBox(height: 5),
                Text(hotspot.reason,
                    style: const TextStyle(
                        fontSize: 12, color: appTextSecondary, height: 1.5)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Idle state (no search yet) ────────────────────────────────────────────────

class _IdleState extends StatelessWidget {
  final List<String> cities;
  const _IdleState({required this.cities});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: appGreenLight,
              shape: BoxShape.circle,
              border: Border.all(color: appGreen.withOpacity(0.3)),
            ),
            child: const Icon(Icons.map_outlined, color: appGreen, size: 26),
          ),
          const SizedBox(height: 14),
          const Text('Enter a city to see road hotspots',
              style: TextStyle(
                  fontSize: 14,
                  color: appTextSecondary,
                  fontWeight: FontWeight.w500)),
          const SizedBox(height: 6),
          Text('Covering ${cities.length} cities in the Merrimack watershed',
              style: const TextStyle(fontSize: 12, color: appTextTertiary)),
        ],
      ),
    );
  }
}

// ── Empty state (search returned nothing) ────────────────────────────────────

class _EmptyState extends StatelessWidget {
  final String query;
  const _EmptyState({required this.query});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.search_off, color: appBorder, size: 40),
          const SizedBox(height: 12),
          Text('No data for "$query"',
              style: const TextStyle(fontSize: 14, color: appTextSecondary)),
          const SizedBox(height: 6),
          const Text('Try: Lawrence, Lowell, Haverhill, Methuen, Andover',
              style: TextStyle(fontSize: 12, color: appTextTertiary)),
        ],
      ),
    );
  }
}

// ── Helpers ───────────────────────────────────────────────────────────────────

String _titleCase(String s) => s
    .toLowerCase()
    .split(' ')
    .map((w) => w.isEmpty ? w : '${w[0].toUpperCase()}${w.substring(1)}')
    .join(' ');
