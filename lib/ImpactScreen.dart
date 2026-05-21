import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tiretrace/fakeData.dart';

class ImpactScreen extends StatefulWidget {
  final Location location;
  const ImpactScreen({super.key, required this.location});
  @override
  State<ImpactScreen> createState() => _ImpactScreenState();
}

class _ImpactScreenState extends State<ImpactScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _scoreController;
  late Animation<double> _scoreAnimation;
  bool _showPetition = false;
  bool _petitionCopied = false;

  Color get scoreColor {
    if (widget.location.pollutionScore >= 75) return const Color(0xFFE24B4A);
    if (widget.location.pollutionScore >= 50) return const Color(0xFFEF9F27);
    return const Color(0xFF5BA3F5);
  }

  Color get scoreColorDim {
    if (widget.location.pollutionScore >= 75) return const Color(0xFF2A0F0F);
    if (widget.location.pollutionScore >= 50) return const Color(0xFF2A1A05);
    return const Color(0xFF0F1E30);
  }

  Color get scoreBorder {
    if (widget.location.pollutionScore >= 75) return const Color(0xFF6B1F1F);
    if (widget.location.pollutionScore >= 50) return const Color(0xFF6B3D05);
    return const Color(0xFF1A2D45);
  }

  String get scoreLabel {
    if (widget.location.pollutionScore >= 75) return 'High impact';
    if (widget.location.pollutionScore >= 50) return 'Medium impact';
    return 'Low impact';
  }

  String get _petitionText =>
      '''To: Local City Council & Environmental Affairs Office

Subject: Urgent Action Needed — Tire Microplastic Runoff Entering ${widget.location.waterway}

Dear Council Members,

I am writing to raise urgent concern about tire wear microplastics entering ${widget.location.waterway} via stormwater runoff on routes near ${widget.location.name}.

Routes in this area currently score ${widget.location.pollutionScore}/100 on the TireTrace pollution index — shedding an estimated ${widget.location.particlesMg} of tire particles per trip. ${widget.location.waterwaySentence}

Tire wear particles are among the largest sources of microplastic pollution in urban waterways, yet they receive far less regulatory attention than other pollutants. These particles carry toxic chemicals including zinc, PAHs, and 6PPD-quinone — a compound linked to mass coho salmon mortality in the Pacific Northwest.

I respectfully request the council:
1. Commission a stormwater runoff audit for roads draining into ${widget.location.waterway}
2. Install bioretention filters or vegetated swales at high-risk drain outfalls
3. Consider lower-shedding road surfaces on the highest-impact corridors
4. Support regional policy requiring tire particle impact assessments for new road projects

Our waterways depend on action now, not after the damage is done.

Sincerely,
A concerned resident''';

  @override
  void initState() {
    super.initState();
    _scoreController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1200));
    _scoreAnimation =
        CurvedAnimation(parent: _scoreController, curve: Curves.easeOutCubic);
    _scoreController.forward();
  }

  @override
  void dispose() {
    _scoreController.dispose();
    super.dispose();
  }

  void _copyPetition() async {
    await Clipboard.setData(ClipboardData(text: _petitionText));
    setState(() => _petitionCopied = true);
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) setState(() => _petitionCopied = false);
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
        title: const Text('Route impact',
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Destination card
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFF0F1E30),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF1A2D45), width: 1),
              ),
              child: Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F2040),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                          color: const Color(0xFF2B7FE0).withOpacity(0.5),
                          width: 1),
                    ),
                    child: const Icon(Icons.location_on_outlined,
                        color: Color(0xFF5BA3F5), size: 18),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.location.name,
                          style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFFE8F0F8))),
                      const SizedBox(height: 2),
                      Text(widget.location.subtitle,
                          style: const TextStyle(
                              fontSize: 12, color: Color(0xFF4A7A9B))),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Score ring card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF0F1E30),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFF1A2D45), width: 1),
              ),
              child: Row(
                children: [
                  AnimatedBuilder(
                    animation: _scoreAnimation,
                    builder: (_, __) {
                      final val = _scoreAnimation.value *
                          widget.location.pollutionScore /
                          100;
                      return SizedBox(
                        width: 80,
                        height: 80,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            CircularProgressIndicator(
                              value: val,
                              strokeWidth: 5,
                              backgroundColor: scoreColorDim,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(scoreColor),
                              strokeCap: StrokeCap.round,
                            ),
                            Text(
                              '${(widget.location.pollutionScore * _scoreAnimation.value).toInt()}',
                              style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w500,
                                  color: scoreColor),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  const SizedBox(width: 18),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Pollution score',
                            style: TextStyle(
                                fontSize: 11, color: Color(0xFF4A7A9B))),
                        const SizedBox(height: 4),
                        Text('${widget.location.pollutionScore} particles/km',
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                                color: scoreColor)),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: scoreColorDim,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: scoreBorder, width: 0.5),
                          ),
                          child: Text(scoreLabel,
                              style: TextStyle(
                                  fontSize: 11,
                                  color: scoreColor,
                                  fontWeight: FontWeight.w500)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Warning card
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFF1A0F0F),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF501313), width: 0.5),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 18,
                        height: 18,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE24B4A).withOpacity(0.12),
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: const Color(0xFFA32D2D), width: 0.5),
                        ),
                        child: const Icon(Icons.info_outline,
                            color: Color(0xFFE24B4A), size: 11),
                      ),
                      const SizedBox(width: 8),
                      Text('Drains to ${widget.location.waterway}',
                          style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFFE24B4A))),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(widget.location.waterwaySentence,
                      style: const TextStyle(
                          fontSize: 12, color: Color(0xFFF09595), height: 1.6)),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Stats row
            Row(
              children: [
                Expanded(
                    child: _StatBox(
                        label: 'Tire particles shed',
                        value: widget.location.particlesMg,
                        icon: Icons.grain)),
                const SizedBox(width: 10),
                Expanded(
                    child: _StatBox(
                        label: 'At-risk waterway',
                        value: widget.location.waterway,
                        icon: Icons.water)),
              ],
            ),
            const SizedBox(height: 16),

            // ── TIRE RECOMMENDATIONS ──────────────────────────────

            // ── PETITION GENERATOR ────────────────────────────────
            const SizedBox(height: 10),
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFF0F1E30),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF1A2D45), width: 1),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header row — tap to expand

                  // Petition text (expandable)
                  if (_showPetition) ...[
                    Container(
                      height: 0.5,
                      color: const Color(0xFF1A2D45),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(14),
                      child: Text(
                        _petitionText,
                        style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF8AAFCF),
                            height: 1.7,
                            fontFamily: 'monospace'),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
                      child: SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          style: FilledButton.styleFrom(
                            backgroundColor: _petitionCopied
                                ? const Color(0xFF0F2A10)
                                : const Color(0xFF0F2040),
                            foregroundColor: _petitionCopied
                                ? const Color(0xFF5BC47A)
                                : const Color(0xFF5BA3F5),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                              side: BorderSide(
                                  color: _petitionCopied
                                      ? const Color(0xFF1A5C2A)
                                      : const Color(0xFF2B7FE0),
                                  width: 1),
                            ),
                          ),
                          onPressed: _copyPetition,
                          icon: Icon(_petitionCopied ? Icons.check : Icons.copy,
                              size: 15),
                          label: Text(_petitionCopied
                              ? 'Copied to clipboard!'
                              : 'Copy petition'),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 28),

            // CTAs
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF0F2040),
                  foregroundColor: const Color(0xFF5BA3F5),
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: const BorderSide(color: Color(0xFF2B7FE0), width: 1),
                  ),
                ),
                onPressed: () => Navigator.pushNamed(context, '/loading',
                    arguments: widget.location),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.route, size: 16),
                    SizedBox(width: 8),
                    Text('Find eco route',
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w500)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF4A7A9B),
                  side: const BorderSide(color: Color(0xFF1A2D45), width: 1),
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () => Navigator.pop(context),
                child: const Text('Continue anyway',
                    style: TextStyle(fontSize: 14)),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String label;
  const _SectionHeader({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 14, color: const Color(0xFF4A7A9B)),
        const SizedBox(width: 6),
        Text(label.toUpperCase(),
            style: const TextStyle(
                fontSize: 11,
                color: Color(0xFF4A7A9B),
                letterSpacing: 0.8,
                fontWeight: FontWeight.w500)),
      ],
    );
  }
}

class _TireCard extends StatelessWidget {
  final TireRecommendation tire;
  const _TireCard({required this.tire});

  Color get ratingColor => tire.shedRating == 'Very Low'
      ? const Color(0xFF5BC47A)
      : const Color(0xFF5BA3F5);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF0F1E30),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF1A2D45), width: 1),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFF0A1628),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFF1A2D45), width: 1),
            ),
            child: const Icon(Icons.tire_repair,
                color: Color(0xFF4A7A9B), size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text('${tire.brand} ',
                        style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFFE8F0F8))),
                    Text(tire.model,
                        style: const TextStyle(
                            fontSize: 13, color: Color(0xFF8AAFCF))),
                  ],
                ),
                const SizedBox(height: 3),
                Text(tire.reason,
                    style: const TextStyle(
                        fontSize: 11, color: Color(0xFF4A7A9B), height: 1.4)),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: ratingColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(5),
                  border: Border.all(
                      color: ratingColor.withOpacity(0.3), width: 0.5),
                ),
                child: Text(tire.shedRating,
                    style: TextStyle(
                        fontSize: 10,
                        color: ratingColor,
                        fontWeight: FontWeight.w500)),
              ),
              const SizedBox(height: 4),
              Text(tire.priceRange,
                  style:
                      const TextStyle(fontSize: 11, color: Color(0xFF4A7A9B))),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatBox extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  const _StatBox(
      {required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF0F1E30),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF1A2D45), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 14, color: const Color(0xFF2B7FE0)),
          const SizedBox(height: 8),
          Text(label,
              style: const TextStyle(fontSize: 11, color: Color(0xFF4A7A9B))),
          const SizedBox(height: 4),
          Text(value,
              style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFFE8F0F8))),
        ],
      ),
    );
  }
}
