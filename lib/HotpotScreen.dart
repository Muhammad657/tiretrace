import 'package:flutter/material.dart';
import 'package:tiretrace/fakeData.dart';

class HotspotScreen extends StatefulWidget {
  const HotspotScreen({super.key});
  @override
  State<HotspotScreen> createState() => _HotspotScreenState();
}

class _HotspotScreenState extends State<HotspotScreen> {
  final TextEditingController _controller = TextEditingController();
  CityHotspot? _result;
  bool _searched = false;

  void _onSearch(String query) {
    setState(() {
      _searched = query.isNotEmpty;
      _result = query.isEmpty ? null : getHotspotForCity(query);
    });
  }

  Color _scoreColor(int score) {
    if (score >= 85) return const Color(0xFFE24B4A);
    if (score >= 70) return const Color(0xFFEF9F27);
    return const Color(0xFF5BA3F5);
  }

  String _scoreLabel(int score) {
    if (score >= 85) return 'Critical';
    if (score >= 70) return 'High';
    return 'Medium';
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A1628),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A1628),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new,
              size: 16, color: Color(0xFF4A7A9B)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('City hotspot map',
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Color(0xFFE8F0F8),
                letterSpacing: 0.2)),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 0.5, color: const Color(0xFF1A2D45)),
        ),
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF0F1E30),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF1A2D45), width: 1),
              ),
              child: Row(
                children: [
                  const Padding(
                    padding: EdgeInsets.only(left: 12),
                    child: Icon(Icons.location_city,
                        color: Color(0xFF4A7A9B), size: 18),
                  ),
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      onChanged: _onSearch,
                      style: const TextStyle(
                          fontSize: 14, color: Color(0xFFE8F0F8)),
                      cursorColor: const Color(0xFF5BA3F5),
                      decoration: const InputDecoration(
                        hintText: 'Enter a city (e.g. San Jose, Boston)...',
                        hintStyle:
                            TextStyle(color: Color(0xFF4A7A9B), fontSize: 13),
                        border: InputBorder.none,
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 10, vertical: 14),
                      ),
                    ),
                  ),
                  if (_controller.text.isNotEmpty)
                    GestureDetector(
                      onTap: () {
                        _controller.clear();
                        _onSearch('');
                      },
                      child: const Padding(
                        padding: EdgeInsets.only(right: 12),
                        child: Icon(Icons.close,
                            color: Color(0xFF4A7A9B), size: 16),
                      ),
                    ),
                ],
              ),
            ),
          ),

          // Supported cities hint
          if (!_searched)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Wrap(
                spacing: 8,
                children: cityHotspots
                    .map((c) => GestureDetector(
                          onTap: () {
                            _controller.text = c.city;
                            _onSearch(c.city);
                          },
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: const Color(0xFF0F1E30),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                  color: const Color(0xFF1A2D45), width: 1),
                            ),
                            child: Text(c.city,
                                style: const TextStyle(
                                    fontSize: 12, color: Color(0xFF5BA3F5))),
                          ),
                        ))
                    .toList(),
              ),
            ),

          // Results
          Expanded(
            child: _searched && _result == null
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.search_off,
                            color: Color(0xFF1A2D45), size: 36),
                        const SizedBox(height: 12),
                        const Text('No data for that city yet',
                            style: TextStyle(
                                fontSize: 13, color: Color(0xFF4A7A9B))),
                        const SizedBox(height: 6),
                        Text(
                            'Try: ${cityHotspots.map((c) => c.city).join(', ')}',
                            style: const TextStyle(
                                fontSize: 12, color: Color(0xFF2A4060))),
                      ],
                    ),
                  )
                : _result == null
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 52,
                              height: 52,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: const Color(0xFF0F1E30),
                                border: Border.all(
                                    color: const Color(0xFF1A2D45), width: 1),
                              ),
                              child: const Icon(Icons.map_outlined,
                                  color: Color(0xFF2B7FE0), size: 24),
                            ),
                            const SizedBox(height: 14),
                            const Text('Enter a city to see road hotspots',
                                style: TextStyle(
                                    fontSize: 13, color: Color(0xFF4A7A9B))),
                          ],
                        ),
                      )
                    : ListView(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                        children: [
                          // City header
                          Padding(
                            padding: const EdgeInsets.only(bottom: 14, top: 4),
                            child: Row(
                              children: [
                                const Icon(Icons.location_city,
                                    color: Color(0xFF2B7FE0), size: 16),
                                const SizedBox(width: 8),
                                Text(_result!.city,
                                    style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                        color: Color(0xFFE8F0F8))),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF1A0F0F),
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(
                                        color: const Color(0xFF501313),
                                        width: 0.5),
                                  ),
                                  child: Text(
                                      '${_result!.roads.length} hotspots',
                                      style: const TextStyle(
                                          fontSize: 11,
                                          color: Color(0xFFE24B4A))),
                                ),
                              ],
                            ),
                          ),

                          ..._result!.roads
                              .asMap()
                              .entries
                              .map((e) => _HotspotCard(
                                    rank: e.key + 1,
                                    hotspot: e.value,
                                    scoreColor: _scoreColor(e.value.score),
                                    scoreLabel: _scoreLabel(e.value.score),
                                  )),

                          // Note
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFF0F1E30),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                  color: const Color(0xFF1A2D45), width: 1),
                            ),
                            child: const Text(
                              'Scores are based on traffic volume, road surface condition, proximity to waterways, and storm drain density. Prototype data only.',
                              style: TextStyle(
                                  fontSize: 11,
                                  color: Color(0xFF2A4060),
                                  height: 1.5),
                            ),
                          ),
                        ],
                      ),
          ),
        ],
      ),
    );
  }
}

class _HotspotCard extends StatelessWidget {
  final int rank;
  final RoadHotspot hotspot;
  final Color scoreColor;
  final String scoreLabel;

  const _HotspotCard({
    required this.rank,
    required this.hotspot,
    required this.scoreColor,
    required this.scoreLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF0F1E30),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF1A2D45), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Rank badge
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: scoreColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                  border:
                      Border.all(color: scoreColor.withOpacity(0.3), width: 1),
                ),
                child: Center(
                  child: Text('#$rank',
                      style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: scoreColor)),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(hotspot.road,
                    style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFFE8F0F8))),
              ),
              // Score pill
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: scoreColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                      color: scoreColor.withOpacity(0.3), width: 0.5),
                ),
                child: Text('${hotspot.score}  $scoreLabel',
                    style: TextStyle(
                        fontSize: 11,
                        color: scoreColor,
                        fontWeight: FontWeight.w500)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(Icons.water_drop_outlined,
                  size: 12, color: Color(0xFF2B7FE0)),
              const SizedBox(width: 5),
              Text('Drains to ${hotspot.waterway}',
                  style:
                      const TextStyle(fontSize: 12, color: Color(0xFF5BA3F5))),
            ],
          ),
          const SizedBox(height: 4),
          Text(hotspot.reason,
              style: const TextStyle(
                  fontSize: 12, color: Color(0xFF4A7A9B), height: 1.5)),
        ],
      ),
    );
  }
}
