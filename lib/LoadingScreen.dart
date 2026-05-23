import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:tiretrace/fakeData.dart';
import 'package:tiretrace/theme/app_colors.dart';

class LoadingScreen extends StatefulWidget {
  final Location location;
  const LoadingScreen({super.key, required this.location});
  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen>
    with TickerProviderStateMixin {
  late AnimationController _progressController;
  late AnimationController _pulseController;
  late AnimationController _rotateController;
  late AnimationController _fadeController;
  int _messageIndex = 0;

  final List<String> _messages = [
    'Analysing road surfaces...',
    'Checking storm drain connections...',
    'Calculating microplastic runoff...',
    'Finding a cleaner route...',
    'Almost there...',
  ];

  @override
  void initState() {
    super.initState();
    _progressController =
        AnimationController(vsync: this, duration: const Duration(seconds: 5))
          ..forward();
    _pulseController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1800))
      ..repeat(reverse: true);
    _rotateController =
        AnimationController(vsync: this, duration: const Duration(seconds: 3))
          ..repeat();
    _fadeController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 400))
      ..forward();
    Future.delayed(const Duration(seconds: 1), _cycleMessage);
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted)
        Navigator.pushReplacementNamed(context, '/map',
            arguments: widget.location);
    });
  }

  void _cycleMessage() {
    if (!mounted) return;
    _fadeController.reverse().then((_) {
      if (!mounted) return;
      setState(() => _messageIndex = (_messageIndex + 1) % _messages.length);
      _fadeController.forward();
    });
    if (_messageIndex < _messages.length - 2)
      Future.delayed(const Duration(seconds: 1), _cycleMessage);
  }

  @override
  void dispose() {
    _progressController.dispose();
    _pulseController.dispose();
    _rotateController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appBg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              SizedBox(
                width: 180,
                height: 180,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    AnimatedBuilder(
                      animation: _pulseController,
                      builder: (_, __) => Transform.scale(
                        scale: 0.85 + _pulseController.value * 0.15,
                        child: Container(
                          width: 180,
                          height: 180,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                                color: appBlue.withOpacity(
                                    0.08 + _pulseController.value * 0.12),
                                width: 1.5),
                          ),
                        ),
                      ),
                    ),
                    AnimatedBuilder(
                      animation: _pulseController,
                      builder: (_, __) => Transform.scale(
                        scale: 0.7 + _pulseController.value * 0.15,
                        child: Container(
                          width: 160,
                          height: 160,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                                color: appBlue.withOpacity(
                                    0.12 + _pulseController.value * 0.18),
                                width: 1),
                          ),
                        ),
                      ),
                    ),
                    AnimatedBuilder(
                      animation: _rotateController,
                      builder: (_, __) => Transform.rotate(
                        angle: _rotateController.value * 2 * math.pi,
                        child: CustomPaint(
                            size: const Size(140, 140), painter: _ArcPainter()),
                      ),
                    ),
                    AnimatedBuilder(
                      animation: _progressController,
                      builder: (_, __) => SizedBox(
                        width: 120,
                        height: 120,
                        child: CircularProgressIndicator(
                          value: _progressController.value,
                          strokeWidth: 3,
                          backgroundColor: appBorder,
                          valueColor: const AlwaysStoppedAnimation<Color>(
                              appBlue),
                        ),
                      ),
                    ),
                    AnimatedBuilder(
                      animation: _pulseController,
                      builder: (_, __) => Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: appBlueLight,
                          border: Border.all(
                              color: appBlue.withOpacity(0.7),
                              width: 1),
                          boxShadow: [
                            BoxShadow(
                                color: appBlue.withOpacity(
                                    0.2 + _pulseController.value * 0.35),
                                blurRadius: 20,
                                spreadRadius: 2)
                          ],
                        ),
                        child: const Icon(Icons.track_changes,
                            color: appBlue, size: 30),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 48),
              const Text('TireTrace',
                  style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      color: appTextPrimary,
                      letterSpacing: 0.5)),
              const SizedBox(height: 6),
              Text('Routing to ${widget.location.name}',
                  style: const TextStyle(
                      fontSize: 13,
                      color: appTextSecondary,
                      letterSpacing: 0.3)),
              const SizedBox(height: 40),
              AnimatedBuilder(
                animation: _progressController,
                builder: (_, __) => Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: _progressController.value,
                        minHeight: 3,
                        backgroundColor: appBorder,
                        valueColor: const AlwaysStoppedAnimation<Color>(
                            appBlue),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text('${(_progressController.value * 100).toInt()}%',
                        style: const TextStyle(
                            fontSize: 11,
                            color: appTextSecondary,
                            fontFeatures: [FontFeature.tabularFigures()])),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              FadeTransition(
                opacity: _fadeController,
                child: Text(_messages[_messageIndex],
                    style: const TextStyle(
                        fontSize: 14,
                        color: appBlue,
                        fontWeight: FontWeight.w400,
                        letterSpacing: 0.2),
                    textAlign: TextAlign.center),
              ),
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                    _messages.length,
                    (i) => AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          margin: const EdgeInsets.symmetric(horizontal: 3),
                          width: i == _messageIndex ? 20 : 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: i == _messageIndex
                                ? appBlue
                                : appBorder,
                            borderRadius: BorderRadius.circular(3),
                          ),
                        )),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _ArcPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    canvas.drawArc(
        rect,
        0,
        math.pi * 0.7,
        false,
        Paint()
          ..color = appBlue.withOpacity(0.5)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2
          ..strokeCap = StrokeCap.round);
    canvas.drawArc(
        rect,
        math.pi,
        math.pi * 0.5,
        false,
        Paint()
          ..color = appBlue.withOpacity(0.35)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2
          ..strokeCap = StrokeCap.round);
  }

  @override
  bool shouldRepaint(_) => false;
}
