import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/services/gemini_triage_copy_service.dart';
import '../../../core/services/inference_service.dart';
import '../../../core/services/triage_record_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../error/presentation/error_screen.dart';
import '../../report/domain/triage_report_view_data.dart';
import '../../report/presentation/report_screen.dart';
import '../../result/domain/triage_logic.dart';

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
    final inference = InferenceService();
    final triageRecords = TriageRecordService();
    final gemini = GeminiTriageCopyService();

    try {
      var groups = await inference.predictGroups(widget.imagePath);
      if (groups.isEmpty) {
        groups = [const PredictedGroup(group: 'unknown', confidence: 0)];
      }
      final top = groups.first;
      final prediction =
          PredictionResult(label: top.group, confidence: top.confidence);
      final decision = TriageLogic.evaluate(prediction);

      final contextPayload = Map<String, dynamic>.from(widget.contextData);

      final docRef = await triageRecords.createReport(
        predictedGroups: groups,
        decision: decision,
        contextData: contextPayload,
        imagePath: widget.imagePath,
        modelVersion: 'mobilenetv2-skinbuddy-v1',
        consentToStoreImagePath: false,
      );

      var explanation = '';
      var nextSteps = <String>[];
      String? geminiError;

      if (gemini.isConfigured) {
        try {
          final copy = await gemini.generateExplanationAndNextSteps(
            triagePayload: _buildGeminiPayload(
              groups: groups,
              decision: decision,
              contextData: contextPayload,
            ),
          );
          explanation = copy.explanation;
          nextSteps = copy.nextSteps;
          await triageRecords.updateReportCopy(
            ref: docRef,
            explanation: explanation,
            nextSteps: nextSteps,
          );
        } catch (e) {
          geminiError = e.toString();
          await triageRecords.updateReportCopy(
            ref: docRef,
            explanation: '',
            nextSteps: const [],
            geminiError: geminiError,
          );
        }
      } else {
        geminiError = 'AI summary is unavailable (API key not configured).';
        await triageRecords.updateReportCopy(
          ref: docRef,
          explanation: '',
          nextSteps: const [],
          geminiError: geminiError,
        );
      }

      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => ReportScreen(
            viewData: TriageReportViewData(
              imagePath: widget.imagePath,
              predictedGroups: groups,
              isUrgent: decision.outcome == TriageOutcome.urgent,
              contextData: contextPayload,
              explanation: explanation,
              nextSteps: nextSteps,
              geminiError: geminiError,
            ),
          ),
        ),
      );
    } catch (_) {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => ErrorScreen(imagePath: widget.imagePath),
        ),
      );
    }
  }

  Map<String, dynamic> _buildGeminiPayload({
    required List<PredictedGroup> groups,
    required TriageDecision decision,
    required Map<String, dynamic> contextData,
  }) {
    return {
      'predicted_groups': groups
          .map(
            (g) => <String, dynamic>{
              'group': g.group,
              'confidence': g.confidence,
            },
          )
          .toList(growable: false),
      'triage_level': decision.outcome.name,
      'triage_reason': decision.reason,
      'related_category': contextData['related_category'],
      'texture': contextData['texture'],
      'body_area': contextData['body_area'],
      'condition_symptoms': contextData['condition_symptoms'],
      'other_symptoms': contextData['other_symptoms'],
      'duration': contextData['duration'],
    };
  }

  // ignore: unused_element
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