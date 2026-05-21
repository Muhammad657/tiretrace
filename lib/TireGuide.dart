import 'package:flutter/material.dart';
import 'package:tiretrace/fakeData.dart';

class TireGuideScreen extends StatelessWidget {
  const TireGuideScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF060E1A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF060E1A),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new,
              size: 16, color: Color(0xFF3A5A78)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Tire guide',
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFFCCDEEE),
                letterSpacing: -0.2)),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 0.5, color: const Color(0xFF152438)),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
        children: [
          // One-liner context
          const Text(
            'Switching tire type can cut your microplastic footprint by up to 40%.',
            style:
                TextStyle(fontSize: 13, color: Color(0xFF3A5A78), height: 1.5),
          ),
          const SizedBox(height: 24),

          const _Label('Recommended'),
          const SizedBox(height: 10),
          ...tireRecommendations.map((t) => _TireCard(tire: t)),

          const SizedBox(height: 24),
          const _Label('What to look for'),
          const SizedBox(height: 10),

          // Condensed criteria — inline chips instead of full cards
          const _CriteriaChip(
              icon: Icons.science_outlined,
              text:
                  'Silica compound rubber — sheds far less than carbon black'),
          const SizedBox(height: 8),
          const _CriteriaChip(
              icon: Icons.speed_outlined,
              text: 'EU rolling resistance label B or above'),
          const SizedBox(height: 8),
          const _CriteriaChip(
              icon: Icons.repeat_outlined,
              text: 'UTQG treadwear 500+ — longer life = less shed per km'),

          const SizedBox(height: 20),
          const Text(
            'Prices are estimates. Prototype data only.',
            style: TextStyle(fontSize: 11, color: Color(0xFF1E3550)),
          ),
        ],
      ),
    );
  }
}

class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(text.toUpperCase(),
        style: const TextStyle(
            fontSize: 10,
            color: Color(0xFF3A5A78),
            letterSpacing: 1.0,
            fontWeight: FontWeight.w600));
  }
}

class _TireCard extends StatelessWidget {
  final TireRecommendation tire;
  const _TireCard({required this.tire});

  Color get ratingColor => tire.shedRating == 'Very Low'
      ? const Color(0xFF3AB89A)
      : const Color(0xFF4A9AE8);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF0C1929),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF152438), width: 1),
      ),
      child: Row(
        children: [
          // Brand initial avatar
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: ratingColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                tire.brand[0],
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: ratingColor),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${tire.brand} ${tire.model}',
                    style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFFCCDEEE),
                        letterSpacing: -0.1)),
                const SizedBox(height: 2),
                Text(tire.priceRange,
                    style: const TextStyle(
                        fontSize: 11, color: Color(0xFF3A5A78))),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: ratingColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(tire.shedRating,
                style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: ratingColor)),
          ),
        ],
      ),
    );
  }
}

class _CriteriaChip extends StatelessWidget {
  final IconData icon;
  final String text;
  const _CriteriaChip({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF0C1929),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFF152438), width: 1),
      ),
      child: Row(
        children: [
          Icon(icon, size: 14, color: const Color(0xFF4A9AE8)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(text,
                style: const TextStyle(
                    fontSize: 12, color: Color(0xFF4A7A9B), height: 1.4)),
          ),
        ],
      ),
    );
  }
}
