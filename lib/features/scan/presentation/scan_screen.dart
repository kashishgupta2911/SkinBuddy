import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/theme/app_theme.dart';
import '../../context/presentation/context_screen.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> with WidgetsBindingObserver {
  CameraController? _cameraController;
  final ImagePicker _picker = ImagePicker();
  bool _isTakingPhoto = false;
  bool _cameraFailed = false;
  FlashMode _flashMode = FlashMode.off;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initCamera();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      _cameraController?.dispose();
      _cameraController = null;
    } else if (state == AppLifecycleState.resumed) {
      _initCamera();
    }
  }

  Future<void> _initCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        if (mounted) setState(() => _cameraFailed = true);
        return;
      }

      final backCamera = cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );

      final controller = CameraController(
        backCamera,
        ResolutionPreset.high,
        enableAudio: false,
      );

      await controller.initialize();
      await controller.setFlashMode(_flashMode);

      if (!mounted) {
        controller.dispose();
        return;
      }

      setState(() {
        _cameraController = controller;
        _cameraFailed = false;
      });
    } catch (_) {
      if (mounted) setState(() => _cameraFailed = true);
    }
  }

  Future<void> _handleCapture() async {
    final controller = _cameraController;
    if (controller == null ||
        !controller.value.isInitialized ||
        _isTakingPhoto) {
      return;
    }

    setState(() => _isTakingPhoto = true);

    try {
      final file = await controller.takePicture();
      if (!mounted) return;
      _navigateToContext(file.path);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to capture photo.')),
        );
      }
    } finally {
      if (mounted) setState(() => _isTakingPhoto = false);
    }
  }

  Future<void> _handleGallery() async {
    final image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 90,
    );
    if (image == null || !mounted) return;
    _navigateToContext(image.path);
  }

  void _navigateToContext(String imagePath) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ContextScreen(imagePath: imagePath),
      ),
    );
  }

  void _handleToggleFlash() {
    final next = _flashMode == FlashMode.off ? FlashMode.torch : FlashMode.off;
    _cameraController?.setFlashMode(next);
    setState(() => _flashMode = next);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            _buildCameraPreview(),
            _buildGuideOverlay(),
            _buildTopControls(),
            _buildBottomControls(),
          ],
        ),
      ),
    );
  }

  Widget _buildCameraPreview() {
    final controller = _cameraController;

    if (_cameraFailed) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.camera_alt_outlined,
                color: Colors.white.withValues(alpha: 0.5), size: 48),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Camera not available',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.7),
                fontSize: 16,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Use the gallery to upload a photo',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.5),
                fontSize: 13,
              ),
            ),
          ],
        ),
      );
    }

    if (controller == null || !controller.value.isInitialized) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    }

    return SizedBox.expand(
      child: FittedBox(
        fit: BoxFit.cover,
        child: SizedBox(
          width: controller.value.previewSize!.height,
          height: controller.value.previewSize!.width,
          child: CameraPreview(controller),
        ),
      ),
    );
  }

  Widget _buildGuideOverlay() {
    return Center(
      child: Transform.translate(
        offset: const Offset(0, 60), // move downward
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.4),
                  width: 2,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Center your skin concern here',
              style: TextStyle(
                fontSize: 15,
                color: Colors.white.withValues(alpha: 0.8),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopControls() {
    return Positioned(
      top: AppSpacing.md,
      left: AppSpacing.md,
      right: AppSpacing.md,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildCircleButton(
            icon: Icons.close,
            onTap: () => Navigator.of(context).pop(),
          ),
          _buildCircleButton(
            icon: _flashMode == FlashMode.off
                ? Icons.flash_off
                : Icons.flash_on,
            onTap: _handleToggleFlash,
          ),
        ],
      ),
    );
  }

  Widget _buildCircleButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.black.withValues(alpha: 0.4),
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }

  Widget _buildBottomControls() {
    return Positioned(
      bottom: AppSpacing.xl,
      left: 0,
      right: 0,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(width: 72),
              GestureDetector(
                onTap: _handleCapture,
                child: AnimatedOpacity(
                  opacity: _isTakingPhoto ? 0.5 : 1.0,
                  duration: const Duration(milliseconds: 150),
                  child: Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.9),
                      border: Border.all(color: Colors.white, width: 4),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.lg),
              GestureDetector(
                onTap: _handleGallery,
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.black.withValues(alpha: 0.4),
                  ),
                  child: const Icon(
                    Icons.photo_library_outlined,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Use natural lighting for best results',
            style: TextStyle(
              fontSize: 13,
              color: Colors.white.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }
}
