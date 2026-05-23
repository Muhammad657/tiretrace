import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:tiretrace/fakeData.dart';
import 'package:tiretrace/geojson_service.dart';
import 'package:tiretrace/theme/app_colors.dart';

// ── Nominatim search result ────────────────────────────────────────────────

class _Place {
  final String name;
  final String subtitle;
  final double lat;
  final double lng;

  const _Place({
    required this.name,
    required this.subtitle,
    required this.lat,
    required this.lng,
  });

  factory _Place.fromJson(Map<String, dynamic> j) {
    final parts = (j['display_name'] as String).split(',');

    final name = (j['name'] as String?)?.trim() ?? parts.first.trim();

    final subtitle = parts.length > 1
        ? parts
            .skip(1)
            .take(3)
            .map((s) => s.trim())
            .where((s) => s.isNotEmpty)
            .join(', ')
        : '';

    return _Place(
      name: name,
      subtitle: subtitle,
      lat: double.parse(j['lat'] as String),
      lng: double.parse(j['lon'] as String),
    );
  }

  Location toLocation(GeoJsonService svc) {
    final seg = svc.getNearestSegment(lat, lng);

    final score = seg?.pollutionScore.round() ?? 50;

    final mgStr =
        seg != null ? '${(seg.runoffMgPerMonth / 1000).round()} mg' : 'N/A';

    final waterway = seg?.nearestWaterway ?? 'Merrimack River';

    final street = seg != null ? _titleCase(seg.streetName) : 'local roads';

    final sentence = seg != null
        ? 'Routes to $name pass $street (score $score/100), '
            '${seg.distToWaterM.round()} m from $waterway. '
            'About ${(seg.runoffMgPerMonth / 1000).round()} mg of tire particles '
            'wash into the waterway each month from this corridor.'
        : 'No road segment data found near $name — '
            'tire pollution estimates are based on the surrounding area.';

    return Location(
      name: name,
      subtitle: subtitle.isNotEmpty ? subtitle : 'Merrimack watershed',
      pollutionScore: score,
      particlesMg: mgStr,
      waterway: waterway,
      waterwaySentence: sentence,
      lat: lat,
      lng: lng,
    );
  }
}

// ── Screen ─────────────────────────────────────────────────────────────────

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _ctrl = TextEditingController();
  final GeoJsonService _geoSvc = GeoJsonService();

  List<_Place> _apiResults = [];
  List<Location> _localResults = [];

  bool _loading = false;
  bool _hasSearched = false;

  String _lastQuery = '';

  Timer? _debounce;

  // ── Search ──────────────────────────────────────────────────────────────

  void _onChanged(String raw) {
    final q = raw.trim();

    if (q == _lastQuery) return;

    _lastQuery = q;

    _debounce?.cancel();

    if (q.isEmpty) {
      setState(() {
        _hasSearched = false;
        _apiResults = [];
        _localResults = [];
        _loading = false;
      });

      return;
    }

    setState(() {
      _loading = true;
      _hasSearched = true;
    });

    _localResults = allLocations
        .where(
          (l) =>
              l.name.toLowerCase().contains(q.toLowerCase()) ||
              l.subtitle.toLowerCase().contains(q.toLowerCase()),
        )
        .toList();

    _debounce = Timer(
      const Duration(milliseconds: 450),
      () => _nominatim(q),
    );
  }

  Future<void> _nominatim(String q) async {
    final uri = Uri.parse(
      'https://nominatim.openstreetmap.org/search',
    ).replace(
      queryParameters: {
        'q': q,
        'format': 'json',
        'limit': '10',
        'countrycodes': 'us',
        'viewbox': '-73.8,41.0,-69.8,45.0',
        'bounded': '0',
        'addressdetails': '0',
      },
    );

    try {
      final resp = await http.get(
        uri,
        headers: {
          'User-Agent': 'TireTrace/1.0 (environmental education app)',
        },
      ).timeout(const Duration(seconds: 8));

      if (!mounted) return;

      final data = jsonDecode(resp.body) as List<dynamic>;

      final places = data
          .cast<Map<String, dynamic>>()
          .map(_Place.fromJson)
          .fold<Map<String, _Place>>({}, (map, p) {
            final key =
                '${p.lat.toStringAsFixed(4)},${p.lng.toStringAsFixed(4)}';

            map.putIfAbsent(key, () => p);

            return map;
          })
          .values
          .toList();

      setState(() {
        _apiResults = places;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _loading = false;
      });
    }
  }

  // ── Tap ─────────────────────────────────────────────────────────────────

  void _onTapLocal(Location loc) {
    Navigator.pushNamed(
      context,
      '/impact',
      arguments: loc,
    );
  }

  void _onTapApi(_Place place) {
    final loc = place.toLocation(_geoSvc);

    Navigator.pushNamed(
      context,
      '/impact',
      arguments: loc,
    );
  }

  // ── Lifecycle ───────────────────────────────────────────────────────────

  @override
  void dispose() {
    _ctrl.dispose();
    _debounce?.cancel();

    super.dispose();
  }

  // ── UI ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appBg,
      appBar: AppBar(
        backgroundColor: appBg,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            size: 16,
            color: appTextSecondary,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Plan a Route',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: appTextPrimary,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(0.5),
          child: Container(
            height: 0.5,
            color: appBorder,
          ),
        ),
      ),
      body: Column(
        children: [
          // ── Search bar ────────────────────────────────────────────────

          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Container(
              decoration: BoxDecoration(
                color: appSurface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: appBorder),
              ),
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 12),
                    child: _loading
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 1.8,
                              color: appBlue,
                            ),
                          )
                        : const Icon(
                            Icons.search,
                            color: appTextTertiary,
                            size: 18,
                          ),
                  ),
                  Expanded(
                    child: TextField(
                      controller: _ctrl,
                      autofocus: true,
                      onChanged: _onChanged,
                      cursorColor: appBlue,
                      style: const TextStyle(
                        fontSize: 14,
                        color: appTextPrimary,
                      ),
                      decoration: const InputDecoration(
                        hintText: 'Search any destination...',
                        hintStyle: TextStyle(
                          color: appTextTertiary,
                          fontSize: 13,
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 14,
                        ),
                      ),
                    ),
                  ),
                  if (_ctrl.text.isNotEmpty)
                    GestureDetector(
                      onTap: () {
                        _ctrl.clear();
                        _onChanged('');
                      },
                      child: const Padding(
                        padding: EdgeInsets.only(right: 12),
                        child: Icon(
                          Icons.close,
                          color: appTextTertiary,
                          size: 16,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),

          // ── Body ──────────────────────────────────────────────────────

          Expanded(
            child: !_hasSearched
                ? _IdleView(
                    featured: allLocations,
                    onTap: _onTapLocal,
                  )
                : _ResultsView(
                    localResults: _localResults,
                    apiResults: _apiResults,
                    loading: _loading,
                    query: _lastQuery,
                    onTapLocal: _onTapLocal,
                    onTapApi: _onTapApi,
                  ),
          ),
        ],
      ),
    );
  }
}

// ── Idle view ──────────────────────────────────────────────────────────────

class _IdleView extends StatelessWidget {
  final List<Location> featured;
  final void Function(Location) onTap;

  const _IdleView({
    required this.featured,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.only(bottom: 24),
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: Text(
            'FEATURED DESTINATIONS',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: appTextTertiary,
              letterSpacing: 0.8,
            ),
          ),
        ),
        ...featured.map(
          (loc) => _LocalTile(
            location: loc,
            onTap: () => onTap(loc),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 18, 16, 0),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: appSurface,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: appBorder),
            ),
            child: const Row(
              children: [
                Icon(
                  Icons.info_outline,
                  size: 14,
                  color: appTextTertiary,
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Search any address, park, school, business, or landmark to estimate tire particle runoff.',
                    style: TextStyle(
                      fontSize: 11,
                      color: appTextSecondary,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ── Results view ───────────────────────────────────────────────────────────

class _ResultsView extends StatelessWidget {
  final List<Location> localResults;
  final List<_Place> apiResults;
  final bool loading;
  final String query;

  final void Function(Location) onTapLocal;
  final void Function(_Place) onTapApi;

  const _ResultsView({
    required this.localResults,
    required this.apiResults,
    required this.loading,
    required this.query,
    required this.onTapLocal,
    required this.onTapApi,
  });

  bool get _hasAny => localResults.isNotEmpty || apiResults.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    if (!_hasAny && !loading) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.search_off,
              color: appBorder,
              size: 42,
            ),
            const SizedBox(height: 12),
            Text(
              'No destinations found for "$query"',
              style: const TextStyle(
                fontSize: 14,
                color: appTextSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.only(top: 4, bottom: 24),
      children: [
        if (localResults.isNotEmpty) ...[
          const _SectionHeader(label: 'FEATURED'),
          ...localResults.map(
            (l) => _LocalTile(
              location: l,
              onTap: () => onTapLocal(l),
            ),
          ),
          const _Divider(),
        ],
        if (apiResults.isNotEmpty) ...[
          const _SectionHeader(label: 'PLACES'),
          ...apiResults.map(
            (p) => _ApiTile(
              place: p,
              onTap: () => onTapApi(p),
            ),
          ),
        ],
        if (loading && apiResults.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Center(
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: appBlue,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

// ── Local tile ─────────────────────────────────────────────────────────────

class _LocalTile extends StatefulWidget {
  final Location location;
  final VoidCallback onTap;

  const _LocalTile({
    required this.location,
    required this.onTap,
  });

  @override
  State<_LocalTile> createState() => _LocalTileState();
}

class _LocalTileState extends State<_LocalTile> {
  bool _pressed = false;

  Color get _scoreColor {
    final s = widget.location.pollutionScore;

    if (s >= 75) return appCritical;
    if (s >= 50) return appHigh;
    if (s >= 25) return appBlue;

    return appGreen;
  }

  Color get _scoreBg {
    final s = widget.location.pollutionScore;

    if (s >= 75) return appCriticalBg;
    if (s >= 50) return appHighBg;
    if (s >= 25) return appBlueLight;

    return appGreenLight;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: _pressed ? appBlueLight : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: appBorder),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: appBlueLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.route_rounded,
                color: appBlue,
                size: 20,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.location.name,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: appTextPrimary,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    widget.location.subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: appTextSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 9,
                vertical: 4,
              ),
              decoration: BoxDecoration(
                color: _scoreBg,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: _scoreColor.withOpacity(0.2),
                ),
              ),
              child: Text(
                '${widget.location.pollutionScore}',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: _scoreColor,
                ),
              ),
            ),
            const SizedBox(width: 8),
            const Icon(
              Icons.chevron_right,
              color: appTextTertiary,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}

// ── API tile ───────────────────────────────────────────────────────────────

class _ApiTile extends StatefulWidget {
  final _Place place;
  final VoidCallback onTap;

  const _ApiTile({
    required this.place,
    required this.onTap,
  });

  @override
  State<_ApiTile> createState() => _ApiTileState();
}

class _ApiTileState extends State<_ApiTile> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: _pressed ? appBlueLight : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: appBorder),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: appSurface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.place_outlined,
                color: appTextSecondary,
                size: 20,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.place.name,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: appTextPrimary,
                    ),
                  ),
                  if (widget.place.subtitle.isNotEmpty) ...[
                    const SizedBox(height: 3),
                    Text(
                      widget.place.subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        color: appTextSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right,
              color: appTextTertiary,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Helpers ────────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String label;

  const _SectionHeader({
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: appTextTertiary,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        height: 0.5,
        color: appBorder,
      ),
    );
  }
}

String _titleCase(String s) => s
    .toLowerCase()
    .split(' ')
    .map(
      (w) => w.isEmpty ? w : '${w[0].toUpperCase()}${w.substring(1)}',
    )
    .join(' ');
