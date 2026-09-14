import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import '../models/finding.dart';
import '../services/ocr_service.dart';
import '../services/scanner_service.dart';
import '../theme/terminal_theme.dart';
import '../widgets/finding_card.dart';
import '../widgets/status_banner.dart';

/// Camera capture and OCR scanning screen.
/// Snaps a photo of a screen/terminal, extracts text via Google ML Kit on-device,
/// and runs it through the ScannerService.
class CameraScanScreen extends StatefulWidget {
  final Function(String extractedText)? onSendToPasteEditor;

  const CameraScanScreen({super.key, this.onSendToPasteEditor});

  @override
  State<CameraScanScreen> createState() => _CameraScanScreenState();
}

class _CameraScanScreenState extends State<CameraScanScreen>
    with WidgetsBindingObserver {
  CameraController? _cameraController;
  List<CameraDescription> _availableCameras = [];
  int _selectedCameraIndex = 0;
  bool _isCameraInitialized = false;
  bool _isCameraPermissionGranted = false;
  bool _isFlashOn = false;
  bool _isProcessingOcr = false;
  String? _ocrError;

  // Scan results state
  String? _capturedImagePath;
  String? _extractedText;
  List<Finding> _findings = [];

  final ImagePicker _imagePicker = ImagePicker();

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
    } else if (state == AppLifecycleState.resumed) {
      _initCamera();
    }
  }

  Future<void> _initCamera() async {
    try {
      final status = await Permission.camera.request();
      if (!status.isGranted) {
        if (mounted) {
          setState(() {
            _isCameraPermissionGranted = false;
            _ocrError = 'Camera permission is required to scan terminal screens.';
          });
        }
        return;
      }

      setState(() {
        _isCameraPermissionGranted = true;
      });

      _availableCameras = await availableCameras();
      if (_availableCameras.isEmpty) {
        if (mounted) {
          setState(() {
            _ocrError =
                'No camera hardware found on this device. You can import screenshots using the gallery button below.';
          });
        }
        return;
      }

      final camera = _availableCameras[_selectedCameraIndex];
      _cameraController = CameraController(
        camera,
        ResolutionPreset.high,
        enableAudio: false,
        imageFormatGroup: Platform.isAndroid
            ? ImageFormatGroup.nv21
            : ImageFormatGroup.bgra8888,
      );

      await _cameraController!.initialize();
      if (mounted) {
        setState(() {
          _isCameraInitialized = true;
          _ocrError = null;
        });
      }
    } catch (e) {
      debugPrint('Camera init error: $e');
      if (mounted) {
        setState(() {
          _ocrError =
              'Unable to initialize camera. You can still test OCR using the gallery button.';
        });
      }
    }
  }

  Future<void> _toggleFlash() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }
    try {
      HapticFeedback.selectionClick();
      if (_isFlashOn) {
        await _cameraController!.setFlashMode(FlashMode.off);
        setState(() => _isFlashOn = false);
      } else {
        await _cameraController!.setFlashMode(FlashMode.torch);
        setState(() => _isFlashOn = true);
      }
    } catch (e) {
      debugPrint('Flash toggle error: $e');
    }
  }

  Future<void> _switchCamera() async {
    if (_availableCameras.length <= 1) return;
    HapticFeedback.selectionClick();
    _selectedCameraIndex =
        (_selectedCameraIndex + 1) % _availableCameras.length;
    await _cameraController?.dispose();
    _cameraController = null;
    setState(() {
      _isCameraInitialized = false;
    });
    await _initCamera();
  }

  Future<void> _captureAndScan() async {
    if (_cameraController == null ||
        !_cameraController!.value.isInitialized ||
        _isProcessingOcr) {
      return;
    }

    try {
      HapticFeedback.mediumImpact();
      setState(() {
        _isProcessingOcr = true;
        _ocrError = null;
      });

      final xFile = await _cameraController!.takePicture();
      await _processImageWithOcr(xFile.path);
    } catch (e) {
      debugPrint('Capture error: $e');
      if (mounted) {
        setState(() {
          _isProcessingOcr = false;
          _ocrError = 'Failed to capture photo: $e';
        });
      }
    }
  }

  Future<void> _pickImageFromGallery() async {
    try {
      HapticFeedback.selectionClick();
      final xFile =
          await _imagePicker.pickImage(source: ImageSource.gallery);
      if (xFile != null) {
        setState(() {
          _isProcessingOcr = true;
          _ocrError = null;
        });
        await _processImageWithOcr(xFile.path);
      }
    } catch (e) {
      debugPrint('Gallery picker error: $e');
      if (mounted) {
        setState(() {
          _isProcessingOcr = false;
          _ocrError = 'Failed to load image: $e';
        });
      }
    }
  }

  Future<void> _processImageWithOcr(String imagePath) async {
    try {
      final text =
          await OcrService.instance.extractTextFromImagePath(imagePath);
      final detectedFindings = ScannerService.instance.scanText(text);

      if (mounted) {
        setState(() {
          _capturedImagePath = imagePath;
          _extractedText = text;
          _findings = detectedFindings;
          _isProcessingOcr = false;
        });
      }
    } catch (e) {
      debugPrint('OCR extraction error: $e');
      if (mounted) {
        setState(() {
          _isProcessingOcr = false;
          _ocrError = 'On-device OCR failed: $e';
        });
      }
    }
  }

  void _resetScan() {
    HapticFeedback.lightImpact();
    setState(() {
      _capturedImagePath = null;
      _extractedText = null;
      _findings = [];
      _ocrError = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_extractedText != null) {
      return _buildResultsView();
    }
    return _buildCameraView();
  }

  Widget _buildCameraView() {
    return Column(
      children: [
        // Camera Viewfinder Box
        Expanded(
          child: Container(
            margin: const EdgeInsets.fromLTRB(18, 10, 18, 12),
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: TerminalTheme.borderAccent.withValues(alpha: 0.5),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: TerminalTheme.borderAccent.withValues(alpha: 0.1),
                  blurRadius: 18,
                  spreadRadius: 1,
                ),
              ],
            ),
            clipBehavior: Clip.antiAlias,
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (_isCameraInitialized && _cameraController != null)
                  CameraPreview(_cameraController!)
                else
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _isCameraPermissionGranted
                                ? Icons.videocam_off_rounded
                                : Icons.no_photography_rounded,
                            size: 48,
                            color: TerminalTheme.textSecondary,
                          ),
                          const SizedBox(height: 14),
                          Text(
                            _ocrError ?? 'Initializing on-device camera...',
                            textAlign: TextAlign.center,
                            style: TerminalTheme.fontSans(
                              fontSize: 13,
                              color: TerminalTheme.textSecondary,
                            ),
                          ),
                          if (!_isCameraPermissionGranted) ...[
                            const SizedBox(height: 14),
                            FilledButton.tonal(
                              onPressed: openAppSettings,
                              child: Text(
                                'Grant Camera Permission',
                                style: TerminalTheme.fontSans(fontSize: 12),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),

                // Terminal HUD Overlay
                _buildHudOverlay(),

                // Processing Spinner Overlay
                if (_isProcessingOcr)
                  Container(
                    color: Colors.black.withValues(alpha: 0.85),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const SizedBox(
                            width: 36,
                            height: 36,
                            child: CircularProgressIndicator(
                              strokeWidth: 3,
                              color: TerminalTheme.safeGreen,
                            ),
                          ),
                          const SizedBox(height: 18),
                          Text(
                            'EXTRACTING TEXT VIA ML KIT',
                            style: TerminalTheme.fontMono(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: TerminalTheme.safeGreen,
                              letterSpacing: 1.0,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '100% on-device • Zero network calls',
                            style: TerminalTheme.fontSans(
                              fontSize: 12,
                              color: TerminalTheme.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),

        // Floating Action Controls Bar (padded above the 64px floating nav bar)
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 6, 24, 96),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Flash Toggle
              IconButton(
                tooltip: 'Flashlight',
                icon: Icon(
                  _isFlashOn
                      ? Icons.flash_on_rounded
                      : Icons.flash_off_rounded,
                  color: _isFlashOn
                      ? TerminalTheme.warningAmber
                      : TerminalTheme.textSecondary,
                ),
                onPressed: _isCameraInitialized ? _toggleFlash : null,
              ),

              // Capture Shutter Button
              GestureDetector(
                onTap: _isCameraInitialized && !_isProcessingOcr
                    ? _captureAndScan
                    : null,
                child: Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: TerminalTheme.safeGreen,
                      width: 3.5,
                    ),
                    color: _isCameraInitialized
                        ? TerminalTheme.safeGreen.withValues(alpha: 0.15)
                        : Colors.transparent,
                    boxShadow: [
                      BoxShadow(
                        color: TerminalTheme.safeGreen.withValues(alpha: 0.2),
                        blurRadius: 16,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Container(
                      width: 54,
                      height: 54,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _isCameraInitialized
                            ? TerminalTheme.safeGreen
                            : TerminalTheme.textSecondary.withValues(alpha: 0.3),
                      ),
                      child: const Icon(
                        Icons.camera_alt_rounded,
                        color: Colors.black,
                        size: 26,
                      ),
                    ),
                  ),
                ),
              ),

              // Gallery Fallback / Switch Camera
              PopupMenuButton<String>(
                color: TerminalTheme.surface,
                tooltip: 'Import or switch',
                icon: const Icon(Icons.more_horiz_rounded,
                    color: TerminalTheme.textPrimary),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                  side: const BorderSide(color: TerminalTheme.border),
                ),
                onSelected: (val) {
                  if (val == 'gallery') {
                    _pickImageFromGallery();
                  } else if (val == 'switch') {
                    _switchCamera();
                  }
                },
                itemBuilder: (ctx) => [
                  PopupMenuItem(
                    value: 'gallery',
                    child: Row(
                      children: [
                        const Icon(Icons.photo_library_rounded,
                            size: 16, color: TerminalTheme.infoBlue),
                        const SizedBox(width: 8),
                        Text(
                          'Import Screenshot',
                          style: TerminalTheme.fontSans(fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                  if (_availableCameras.length > 1)
                    PopupMenuItem(
                      value: 'switch',
                      child: Row(
                        children: [
                          const Icon(Icons.flip_camera_android_rounded,
                              size: 16, color: TerminalTheme.textSecondary),
                          const SizedBox(width: 8),
                          Text(
                            'Switch Camera',
                            style: TerminalTheme.fontSans(fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHudOverlay() {
    return IgnorePointer(
      child: Stack(
        children: [
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.75),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: TerminalTheme.safeGreen.withValues(alpha: 0.5),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: TerminalTheme.safeGreen,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'ALIGN TERMINAL OR SCREEN',
                        style: TerminalTheme.fontMono(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w700,
                          color: TerminalTheme.safeGreen,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Center Alignment Frame with Glowing Reticle
          Center(
            child: Container(
              margin: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                border: Border.all(
                  color: TerminalTheme.safeGreen.withValues(alpha: 0.4),
                  width: 1.5,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Stack(
                children: [
                  Positioned(
                    top: 0,
                    left: 0,
                    child: _buildCornerBracket(isTop: true, isLeft: true),
                  ),
                  Positioned(
                    top: 0,
                    right: 0,
                    child: _buildCornerBracket(isTop: true, isLeft: false),
                  ),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    child: _buildCornerBracket(isTop: false, isLeft: true),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: _buildCornerBracket(isTop: false, isLeft: false),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCornerBracket({required bool isTop, required bool isLeft}) {
    return Container(
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        border: Border(
          top: isTop
              ? const BorderSide(color: TerminalTheme.safeGreen, width: 3.5)
              : BorderSide.none,
          bottom: !isTop
              ? const BorderSide(color: TerminalTheme.safeGreen, width: 3.5)
              : BorderSide.none,
          left: isLeft
              ? const BorderSide(color: TerminalTheme.safeGreen, width: 3.5)
              : BorderSide.none,
          right: !isLeft
              ? const BorderSide(color: TerminalTheme.safeGreen, width: 3.5)
              : BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildResultsView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 110),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Live Status Banner
          StatusBanner(
            findings: _findings,
            isScanning: false,
          ),

          const SizedBox(height: 16),

          // Action Toolbar: Rescan, Send to Editor
          Row(
            children: [
              OutlinedButton.icon(
                onPressed: _resetScan,
                icon: const Icon(Icons.replay_rounded, size: 16),
                label: Text(
                  'Scan Another',
                  style: TerminalTheme.fontSans(fontSize: 12.5),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: TerminalTheme.textPrimary,
                  side: const BorderSide(color: TerminalTheme.border),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                ),
              ),
              const Spacer(),
              if (widget.onSendToPasteEditor != null &&
                  _extractedText != null) ...[
                FilledButton.icon(
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    widget.onSendToPasteEditor!(_extractedText!);
                  },
                  icon: const Icon(Icons.edit_note_rounded, size: 16),
                  label: Text(
                    'Load in Editor',
                    style: TerminalTheme.fontSans(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  style: FilledButton.styleFrom(
                    backgroundColor: TerminalTheme.infoBlue,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                  ),
                ),
              ],
            ],
          ),

          const SizedBox(height: 16),

          if (_capturedImagePath != null &&
              File(_capturedImagePath!).existsSync()) ...[
            Container(
              height: 150,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: TerminalTheme.border),
              ),
              clipBehavior: Clip.antiAlias,
              child: Image.file(
                File(_capturedImagePath!),
                fit: BoxFit.cover,
                width: double.infinity,
              ),
            ),
            const SizedBox(height: 14),
          ],

          // Extracted OCR Text Box (Collapsible / Preview)
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF090D13),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: TerminalTheme.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: const BoxDecoration(
                    color: TerminalTheme.surface,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(15),
                      topRight: Radius.circular(15),
                    ),
                    border: Border(
                      bottom: BorderSide(color: TerminalTheme.border),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.document_scanner_rounded,
                          size: 14, color: TerminalTheme.infoBlue),
                      const SizedBox(width: 8),
                      Text(
                        'OCR EXTRACTED TEXT (${_extractedText?.length ?? 0} chars)',
                        style: TerminalTheme.fontMono(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: TerminalTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(14),
                  child: SelectableText(
                    _extractedText ?? '',
                    style: TerminalTheme.fontMono(
                      fontSize: 11.5,
                      height: 1.45,
                      color: TerminalTheme.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Findings List
          if (_findings.isNotEmpty) ...[
            Text(
              'OCR FINDINGS (${_findings.length})',
              style: TerminalTheme.fontSans(
                fontSize: 12.5,
                fontWeight: FontWeight.w800,
                color: TerminalTheme.textSecondary,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 12),
            ..._findings.map((finding) => FindingCard(
                  key: ValueKey('${finding.type}_${finding.startIndex}'),
                  finding: finding,
                )),
          ],
        ],
      ),
    );
  }
}
