import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../error/presentation/error_screen.dart';
import '../../report/presentation/report_screen.dart';

import '../../../core/services/triage_record_service.dart';
import '../../../core/services/inference_service.dart';

class AnalyzingScreen extends StatefulWidget {
  const AnalyzingScreen({
    super.key,
    required this.imagePath,
    this.contextData = const {},
  });

  final String imagePath;
  final Map<String, dynamic> contextData;

  @override
  State<AnalyzingScreen> createState() => _AnalyzingScreenState();
}

class _AnalyzingScreenState extends State<AnalyzingScreen>
    with TickerProviderStateMixin {
  late final AnimationController _rotationController;
  late final AnimationController _pulseController;

  final _triageRecordService = TriageRecordService();

  @override
  void initState() {
    super.initState();

    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _startAnalysis();
  }

  Future<void> _startAnalysis() async {
    try {
      await Future.delayed(const Duration(seconds: 2));

      // temporary placeholder until model is connected
      const placeholderPredictionLabel = 'Awaiting model prediction';
      const placeholderConfidence = 0.0;

      // THIS is the important part:
      // triage_level is just a string
      const placeholderTriageLevel = 'nonurgent';

      await _triageRecordService.saveRecord(
        prediction: PredictionResult(
          label: placeholderPredictionLabel,
          confidence: placeholderConfidence,
        ),

        imagePath: widget.imagePath,

        triageLevel: placeholderTriageLevel,

        relatedCategory:
        widget.contextData['related_category'] ?? '',

        texture:
        widget.contextData['texture'] ?? '',

        bodyArea: List<String>.from(
          widget.contextData['body_area'] ?? [],
        ),

        conditionSymptoms: List<String>.from(
          widget.contextData['condition_symptoms'] ?? [],
        ),

        otherSymptoms: List<String>.from(
          widget.contextData['other_symptoms'] ?? [],
        ),

        duration:
        widget.contextData['duration'] ?? '',

        nextSteps: 'Pending next steps until model integration.',
      );

      final record = await _triageRecordService.getLatestRecord();

      if (!mounted) return;

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => ReportScreen(
            imagePath: widget.imagePath,
            record: record,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      _navigateToError();
    }
  }

  void _navigateToError() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => ErrorScreen(
          imagePath: widget.imagePath,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildAnimatedLogo(),
            const SizedBox(height: AppSpacing.xxl),

            const Text(
              'Analyzing your skin',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),

            const SizedBox(height: AppSpacing.sm),

            AnimatedBuilder(
              animation: _pulseController,
              builder: (context, child) {
                return Opacity(
                  opacity: 0.4 + (_pulseController.value * 0.6),
                  child: child,
                );
              },
              child: const Text(
                'SkinBuddy is evaluating...',
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedLogo() {
    return AnimatedBuilder(
      animation: _rotationController,
      builder: (context, child) {
        return Transform.rotate(
          angle: _rotationController.value * 2 * math.pi,
          child: child,
        );
      },
      child: CustomPaint(
        size: const Size(120, 120),
        painter: _SwirlPainter(),
      ),
    );
  }
}

class _SwirlPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    final paint = Paint()
      ..color = AppColors.primary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round;

    for (int i = 0; i < 3; i++) {
      final startAngle = (i * 2 * math.pi / 3) - math.pi / 2;
      const sweepAngle = math.pi * 0.6;
      final arcRadius = radius * 0.65;

      canvas.drawArc(
        Rect.fromCircle(
          center: center,
          radius: arcRadius,
        ),
        startAngle,
        sweepAngle,
        false,
        paint,
      );

      final innerRadius = radius * 0.4;

      canvas.drawArc(
        Rect.fromCircle(
          center: center,
          radius: innerRadius,
        ),
        startAngle + math.pi / 6,
        sweepAngle * 0.7,
        false,
        paint..strokeWidth = 2.5,
      );
    }

    final dotPaint = Paint()
      ..color = AppColors.primary
      ..style = PaintingStyle.fill;

    for (int i = 0; i < 8; i++) {
      final angle = (i * 2 * math.pi / 8) - math.pi / 2;

      final dotCenter = Offset(
        center.dx + radius * 0.85 * math.cos(angle),
        center.dy + radius * 0.85 * math.sin(angle),
      );

      canvas.drawCircle(
        dotCenter,
        3.5,
        dotPaint,
      );
    }
  }

  @override
  bool shouldRepaint(
      covariant CustomPainter oldDelegate,
      ) {
    return false;
  }
}