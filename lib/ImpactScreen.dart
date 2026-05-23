import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tiretrace/fakeData.dart';
import 'package:tiretrace/theme/app_colors.dart';

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

  bool _showPetition = true;
  bool _petitionCopied = false;

  Color get scoreColor {
    if (widget.location.pollutionScore >= 75) return appCritical;
    if (widget.location.pollutionScore >= 50) return appHigh;
    return appBlue;
  }

  Color get scoreBg {
    if (widget.location.pollutionScore >= 75) return appCriticalBg;
    if (widget.location.pollutionScore >= 50) return appHighBg;
    return appBlueLight;
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

Tire wear particles are among the largest sources of microplastic pollution in urban waterways.

I respectfully request the council:
1. Commission a stormwater runoff audit
2. Install bioretention filters
3. Consider lower-shedding road surfaces
4. Support regional tire-particle policy

Sincerely,
A concerned resident''';

  @override
  void initState() {
    super.initState();

    _scoreController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _scoreAnimation = CurvedAnimation(
      parent: _scoreController,
      curve: Curves.easeOutCubic,
    );

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

    if (mounted) {
      setState(() => _petitionCopied = false);
    }
  }

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
          'Route impact',
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // ── Destination card ───────────────────────────────
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
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
                      Icons.location_on_outlined,
                      color: appBlue,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.location.name,
                          style: const TextStyle(
                            fontSize: 15,
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
                ],
              ),
            ),

            const SizedBox(height: 12),

            // ── Score card ─────────────────────────────────────
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
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
                  AnimatedBuilder(
                    animation: _scoreAnimation,
                    builder: (_, __) {
                      final val = _scoreAnimation.value *
                          widget.location.pollutionScore /
                          100;

                      return SizedBox(
                        width: 82,
                        height: 82,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            CircularProgressIndicator(
                              value: val,
                              strokeWidth: 6,
                              backgroundColor: scoreBg,
                              valueColor: AlwaysStoppedAnimation(scoreColor),
                              strokeCap: StrokeCap.round,
                            ),
                            Text(
                              '${(widget.location.pollutionScore * _scoreAnimation.value).toInt()}',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: scoreColor,
                              ),
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
                        const Text(
                          'Pollution score',
                          style: TextStyle(
                            fontSize: 11,
                            color: appTextTertiary,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          '${widget.location.pollutionScore} particles/km',
                          style: TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.w700,
                            color: scoreColor,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 9,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: scoreBg,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: scoreColor.withOpacity(0.2),
                            ),
                          ),
                          child: Text(
                            scoreLabel,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: scoreColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // ── Waterway warning ───────────────────────────────
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: appCriticalBg,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: appCritical.withOpacity(0.15),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 22,
                        height: 22,
                        decoration: BoxDecoration(
                          color: appCritical.withOpacity(0.08),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.water_drop_outlined,
                          size: 12,
                          color: appCritical,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Drains to ${widget.location.waterway}',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: appCritical,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    widget.location.waterwaySentence,
                    style: const TextStyle(
                      fontSize: 12,
                      color: appTextSecondary,
                      height: 1.6,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // ── Stats ──────────────────────────────────────────
            Row(
              children: [
                Expanded(
                  child: _StatBox(
                    label: 'Tire particles shed',
                    value: widget.location.particlesMg,
                    icon: Icons.grain,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _StatBox(
                    label: 'At-risk waterway',
                    value: widget.location.waterway,
                    icon: Icons.water_outlined,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // ── Petition ───────────────────────────────────────
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: appBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(14),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.campaign_outlined,
                          size: 16,
                          color: appBlue,
                        ),
                        const SizedBox(width: 8),
                        const Expanded(
                          child: Text(
                            'Generated environmental petition',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: appTextPrimary,
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _showPetition = !_showPetition;
                            });
                          },
                          child: Icon(
                            _showPetition
                                ? Icons.keyboard_arrow_up
                                : Icons.keyboard_arrow_down,
                            color: appTextSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (_showPetition) ...[
                    Container(height: 0.5, color: appBorder),
                    Padding(
                      padding: const EdgeInsets.all(14),
                      child: Text(
                        _petitionText,
                        style: const TextStyle(
                          fontSize: 12,
                          color: appTextSecondary,
                          height: 1.7,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
                      child: SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          style: FilledButton.styleFrom(
                            backgroundColor:
                                _petitionCopied ? appGreenLight : appBlueLight,
                            foregroundColor:
                                _petitionCopied ? appGreen : appBlue,
                            padding: const EdgeInsets.symmetric(vertical: 13),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                              side: BorderSide(
                                color: _petitionCopied
                                    ? appGreen.withOpacity(0.2)
                                    : appBlue.withOpacity(0.2),
                              ),
                            ),
                          ),
                          onPressed: _copyPetition,
                          icon: Icon(
                            _petitionCopied ? Icons.check : Icons.copy_rounded,
                            size: 15,
                          ),
                          label: Text(
                            _petitionCopied
                                ? 'Copied to clipboard!'
                                : 'Copy petition',
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 28),

            // ── CTA buttons ────────────────────────────────────
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: appBlue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () => Navigator.pushNamed(
                  context,
                  '/loading',
                  arguments: widget.location,
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.route, size: 16),
                    SizedBox(width: 8),
                    Text(
                      'Find eco route',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 10),

            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  foregroundColor: appTextSecondary,
                  side: const BorderSide(color: appBorder),
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'Continue anyway',
                  style: TextStyle(fontSize: 14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatBox extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _StatBox({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: appBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: appBlueLight,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              size: 16,
              color: appBlue,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: appTextTertiary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: appTextPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
