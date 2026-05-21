import 'package:flutter/material.dart';
import 'package:tiretrace/fakeData.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF060E1A),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header ──────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 28, 20, 0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image.asset('assets/images/preview.png',
                        width: 44, height: 44),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        RichText(
                          text: const TextSpan(children: [
                            TextSpan(
                                text: 'Tire',
                                style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFFCCDEEE),
                                    letterSpacing: -0.5)),
                            TextSpan(
                                text: 'Trace',
                                style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFF4A9AE8),
                                    letterSpacing: -0.5)),
                          ]),
                        ),
                        const Text('Tracking tire microplastics',
                            style: TextStyle(
                                fontSize: 11,
                                color: Color(0xFF3A5A78),
                                letterSpacing: 0.4)),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 36),

              // ── Primary actions ──────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _PrimaryCard(
                      icon: Icons.route_rounded,
                      title: 'Plan a route',
                      subtitle: 'See how polluting your trip is',
                      accentColor: const Color(0xFF4A9AE8),
                      onTap: () => Navigator.pushNamed(context, '/search'),
                    ),
                    const SizedBox(height: 10),
                    _PrimaryCard(
                      icon: Icons.map_rounded,
                      title: 'City hotspot map',
                      subtitle: 'Worst roads in your city',
                      accentColor: const Color(0xFF3AB89A),
                      onTap: () => Navigator.pushNamed(context, '/hotspots'),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: _SecondaryCard(
                            icon: Icons.tire_repair_rounded,
                            title: 'Tire guide',
                            accentColor: const Color(0xFF4A9AE8),
                            onTap: () => Navigator.pushNamed(context, '/tires'),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _SecondaryCard(
                            icon: Icons.gavel_rounded,
                            title: 'Petition',
                            accentColor: const Color(0xFFE87B4A),
                            onTap: () =>
                                Navigator.pushNamed(context, '/petition'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 36),

              // ── Stats ────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: const _StatRow(),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Primary card ─────────────────────────────────────────────

class _PrimaryCard extends StatefulWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color accentColor;
  final VoidCallback onTap;

  const _PrimaryCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.accentColor,
    required this.onTap,
  });

  @override
  State<_PrimaryCard> createState() => _PrimaryCardState();
}

class _PrimaryCardState extends State<_PrimaryCard> {
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
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: const Color(0xFF0C1929),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
                color: widget.accentColor.withOpacity(0.2), width: 1),
          ),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: widget.accentColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(widget.icon, color: widget.accentColor, size: 22),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.title,
                        style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFFE2EDF8),
                            letterSpacing: -0.2)),
                    const SizedBox(height: 2),
                    Text(widget.subtitle,
                        style: const TextStyle(
                            fontSize: 12, color: Color(0xFF3A5A78))),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios_rounded,
                  color: widget.accentColor.withOpacity(0.5), size: 14),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Secondary card ───────────────────────────────────────────

class _SecondaryCard extends StatefulWidget {
  final IconData icon;
  final String title;
  final Color accentColor;
  final VoidCallback onTap;

  const _SecondaryCard({
    required this.icon,
    required this.title,
    required this.accentColor,
    required this.onTap,
  });

  @override
  State<_SecondaryCard> createState() => _SecondaryCardState();
}

class _SecondaryCardState extends State<_SecondaryCard> {
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
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF0C1929),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
                color: widget.accentColor.withOpacity(0.2), width: 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: widget.accentColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(widget.icon, color: widget.accentColor, size: 20),
              ),
              const SizedBox(height: 14),
              Text(widget.title,
                  style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFFE2EDF8),
                      letterSpacing: -0.2)),
              const SizedBox(height: 2),
              Icon(Icons.arrow_forward_ios_rounded,
                  color: widget.accentColor.withOpacity(0.4), size: 11),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Stat row ─────────────────────────────────────────────────

class _StatRow extends StatelessWidget {
  const _StatRow();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF0C1929),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF152438), width: 1),
      ),
      child: Row(
        children: [
          _StatItem(value: '28%', label: 'of ocean\nmicroplastics'),
          _divider(),
          _StatItem(value: '6M t', label: 'particles shed\neach year'),
          _divider(),
          _StatItem(value: '6PPD-q', label: 'kills coho\nsalmon'),
        ],
      ),
    );
  }

  Widget _divider() => Container(
        width: 1,
        height: 32,
        margin: const EdgeInsets.symmetric(horizontal: 12),
        color: const Color(0xFF152438),
      );
}

class _StatItem extends StatelessWidget {
  final String value;
  final String label;
  const _StatItem({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(value,
              style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF4A9AE8),
                  letterSpacing: -0.3)),
          const SizedBox(height: 3),
          Text(label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 10, color: Color(0xFF3A5A78), height: 1.4)),
        ],
      ),
    );
  }
}
