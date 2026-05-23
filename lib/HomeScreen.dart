import 'package:flutter/material.dart';
import 'package:tiretrace/theme/app_colors.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appBg,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header ──────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 28, 20, 0),
                child: Row(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: appBlueLight,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: appBorder),
                      ),
                      padding: const EdgeInsets.all(8),
                      child: Image.asset('assets/images/preview.png'),
                    ),
                    const SizedBox(width: 14),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        RichText(
                          text: const TextSpan(
                            children: [
                              TextSpan(
                                text: 'Tire',
                                style: TextStyle(
                                  fontSize: 26,
                                  fontWeight: FontWeight.w800,
                                  color: appTextPrimary,
                                  letterSpacing: -0.5,
                                ),
                              ),
                              TextSpan(
                                text: 'Trace',
                                style: TextStyle(
                                  fontSize: 26,
                                  fontWeight: FontWeight.w800,
                                  color: appBlue,
                                  letterSpacing: -0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          'Tracking tire microplastics',
                          style: TextStyle(
                            fontSize: 12,
                            color: appTextSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // ── Hero section ────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: appSurface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: appBorder),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Reduce Tire Pollution.',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: appTextPrimary,
                                letterSpacing: -0.4,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Explore cleaner routes, hotspot roads, and tire impacts on waterways.',
                              style: TextStyle(
                                fontSize: 13,
                                color: appTextSecondary,
                                height: 1.5,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 7),
                              decoration: BoxDecoration(
                                color: appGreenLight,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: appGreen.withOpacity(0.2),
                                ),
                              ),
                              child: const Text(
                                'Live MA watershed data',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: appGreen,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 18),
                      Container(
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                          color: appBlueLight,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: appBlue.withOpacity(0.2),
                          ),
                        ),
                        child: const Icon(
                          Icons.water_drop_outlined,
                          color: appBlue,
                          size: 34,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 28),

              // ── Primary actions ──────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    _PrimaryCard(
                      icon: Icons.route_rounded,
                      title: 'Plan a route',
                      subtitle: 'See how polluting your trip is',
                      accentColor: appBlue,
                      onTap: () => Navigator.pushNamed(context, '/search'),
                    ),
                    const SizedBox(height: 12),
                    _PrimaryCard(
                      icon: Icons.map_rounded,
                      title: 'City hotspot map',
                      subtitle: 'Worst roads in your city',
                      accentColor: appGreen,
                      onTap: () => Navigator.pushNamed(context, '/hotspots'),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _SecondaryCard(
                            icon: Icons.tire_repair_rounded,
                            title: 'Tire guide',
                            accentColor: appBlue,
                            onTap: () => Navigator.pushNamed(context, '/tires'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _SecondaryCard(
                            icon: Icons.gavel_rounded,
                            title: 'Petition Generator',
                            accentColor: appHigh,
                            onTap: () =>
                                Navigator.pushNamed(context, '/petition'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // ── Stats ────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: const _StatRow(),
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Primary card ─────────────────────────────────────────────

class _PrimaryCard extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Ink(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: appBorder),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: accentColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: accentColor),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: appTextPrimary,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: appTextSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 14,
              color: accentColor.withOpacity(0.6),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Secondary card ───────────────────────────────────────────

class _SecondaryCard extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Ink(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: appBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: accentColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: accentColor, size: 20),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: appTextPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 11,
              color: accentColor.withOpacity(0.5),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Stats ────────────────────────────────────────────────────

class _StatRow extends StatelessWidget {
  const _StatRow();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: appSurface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: appBorder),
      ),
      child: Row(
        children: [
          _StatItem(
            value: '28%',
            label: 'of ocean\nmicroplastics',
          ),
          _divider(),
          _StatItem(
            value: '6M',
            label: 'particles shed\neach year',
          ),
          _divider(),
          _StatItem(
            value: '6PPD-q',
            label: 'kills coho\nsalmon',
          ),
        ],
      ),
    );
  }

  Widget _divider() => Container(
        width: 1,
        height: 34,
        margin: const EdgeInsets.symmetric(horizontal: 12),
        color: appBorder,
      );
}

class _StatItem extends StatelessWidget {
  final String value;
  final String label;

  const _StatItem({
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: appBlue,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 10,
              height: 1.4,
              color: appTextSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
