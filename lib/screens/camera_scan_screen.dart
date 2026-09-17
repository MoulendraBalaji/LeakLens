import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import '../models/finding.dart';
import '../services/image_preprocessor.dart';
import '../services/ocr_service.dart';
import '../services/ocr_text_cleaner.dart';
import '../services/scanner_service.dart';
import '../theme/neo_theme.dart';
import '../widgets/finding_card.dart';
import '../widgets/status_banner.dart';

/// Camera capture and OCR scanning screen.
/// Snaps a photo of a screen/terminal, preprocesses for contrast, extracts text
/// via Google ML Kit on-device, cleans OCR output and runs it through the ScannerService.
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
    if (_cameraController == null || !_cameraController!.value.isInitialized) return;
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
      setState(() => _isCameraPermissionGranted = true);
      _availableCameras = await availableCameras();
      if (_availableCameras.isEmpty) {
        if (mounted) {
          setState(() {
            _ocrError = 'No camera found. Import screenshots via the gallery button below.';
          });
        }
        return;
      }
      final camera = _availableCameras[_selectedCameraIndex];
      _cameraController = CameraController(
        camera,
        ResolutionPreset.veryHigh,
        enableAudio: false,
        imageFormatGroup: Platform.isAndroid ? ImageFormatGroup.nv21 : ImageFormatGroup.bgra8888,
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
          _ocrError = 'Unable to initialize camera. You can still test OCR using the gallery button.';
        });
      }
    }
  }

  Future<void> _toggleFlash() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) return;
    try {
      HapticFeedback.selectionClick();
      if (_isFlashOn) {
        await _cameraController!.setFlashMode(FlashMode.off);
        setState(() => _isFlashOn = false);
      } else {
        await _cameraController!.setFlashMode(FlashMode.torch);
        setState(() => _isFlashOn = true);
      }
    } catch (_) {}
  }

  Future<void> _switchCamera() async {
    if (_availableCameras.length <= 1) return;
    HapticFeedback.selectionClick();
    _selectedCameraIndex = (_selectedCameraIndex + 1) % _availableCameras.length;
    await _cameraController?.dispose();
    _cameraController = null;
    setState(() => _isCameraInitialized = false);
    await _initCamera();
  }

  Future<void> _captureAndScan() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized || _isProcessingOcr) return;
    try {
      HapticFeedback.mediumImpact();
      setState(() { _isProcessingOcr = true; _ocrError = null; });
      final xFile = await _cameraController!.takePicture();
      await _processImageWithOcr(xFile.path);
    } catch (e) {
      debugPrint('Capture error: $e');
      if (mounted) setState(() { _isProcessingOcr = false; _ocrError = 'Failed to capture photo: $e'; });
    }
  }

  Future<void> _pickImageFromGallery() async {
    try {
      HapticFeedback.selectionClick();
      final xFile = await _imagePicker.pickImage(source: ImageSource.gallery);
      if (xFile != null) {
        setState(() { _isProcessingOcr = true; _ocrError = null; });
        await _processImageWithOcr(xFile.path);
      }
    } catch (e) {
      debugPrint('Gallery picker error: $e');
      if (mounted) setState(() { _isProcessingOcr = false; _ocrError = 'Failed to load image: $e'; });
    }
  }

  Future<void> _processImageWithOcr(String imagePath) async {
    try {
      // Step 1: enhance contrast for terminal/screen captures
      var processedPath = imagePath;
      try {
        processedPath = await ImagePreprocessor.enhanceForOcr(imagePath);
      } catch (_) {
        // fallback to original if preprocessing fails
      }

      // Step 2: OCR
      final rawText = await OcrService.instance.extractTextFromImagePath(processedPath);

      // Step 3: clean OCR artifacts (invisible chars, trailing whitespace)
      final text = OcrTextCleaner.clean(rawText);

      // Step 4: scan
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
      if (mounted) setState(() { _isProcessingOcr = false; _ocrError = 'On-device OCR failed: $e'; });
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
    if (_extractedText != null) return _buildResultsView();
    return _buildCameraView();
  }

  Widget _buildCameraView() {
    final c = NeoColors.of(context);
    return Column(
      children: [
        // Viewfinder
        Expanded(
          child: Container(
            margin: const EdgeInsets.fromLTRB(16, 10, 16, 12),
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: c.border, width: 1.2),
              boxShadow: [
                BoxShadow(
                  color: c.shadow,
                  blurRadius: 18,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            clipBehavior: Clip.hardEdge,
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
                            color: c.textSecondary,
                          ),
                          const SizedBox(height: 14),
                          Text(
                            _ocrError ?? 'Initializing on-device camera...',
                            textAlign: TextAlign.center,
                            style: NeoTheme.fontSans(fontSize: 13, color: c.textSecondary),
                          ),
                          if (!_isCameraPermissionGranted) ...[
                            const SizedBox(height: 14),
                            GestureDetector(
                              onTap: openAppSettings,
                              child: NeoTheme.sticker(context,
                                  text: 'GRANT PERMISSION',
                                  color: c.cyan, fontSize: 10),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),

                _buildHudOverlay(),

                // Processing overlay
                if (_isProcessingOcr)
                  Container(
                    color: Colors.black.withValues(alpha: 0.85),
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 22),
                        decoration: BoxDecoration(
                          color: c.surface,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: c.cyan.withValues(alpha: 0.5), width: 1.2),
                          boxShadow: [
                            BoxShadow(
                              color: c.cyan.withValues(alpha: 0.15),
                              blurRadius: 20,
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              width: 32, height: 32,
                              child: CircularProgressIndicator(
                                strokeWidth: 3,
                                color: c.cyan,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'EXTRACTING TEXT',
                              style: NeoTheme.fontDisplay(
                                fontSize: 17,
                                color: c.textBright,
                                letterSpacing: 0.3,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '100% on-device · ML Kit · Zero network',
                              style: NeoTheme.fontMono(
                                fontSize: 10.5,
                                color: c.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),

        // Bottom controls
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 4, 24, 96),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Flash
              InkWell(
                onTap: _isCameraInitialized ? _toggleFlash : null,
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  width: 48, height: 48,
                  decoration: BoxDecoration(
                    color: _isFlashOn
                        ? c.yellow.withValues(alpha: 0.2)
                        : c.surface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: _isFlashOn ? c.yellow : c.border,
                      width: 1.2,
                    ),
                    boxShadow: [
                      BoxShadow(color: c.shadow, blurRadius: 8, offset: const Offset(0, 2)),
                    ],
                  ),
                  child: Icon(
                    _isFlashOn ? Icons.flash_on_rounded : Icons.flash_off_rounded,
                    color: _isFlashOn ? c.yellow : c.textSecondary,
                    size: 22,
                  ),
                ),
              ),

              // Shutter button with glowing cyan/emerald ring
              GestureDetector(
                onTap: _isCameraInitialized && !_isProcessingOcr ? _captureAndScan : null,
                child: Container(
                  width: 72, height: 72,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [c.cyan, c.green],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: c.cyan.withValues(alpha: 0.35),
                        blurRadius: 18,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(4),
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: c.surface,
                    ),
                    child: Center(
                      child: Container(
                        width: 50, height: 50,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: c.cyan,
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
              ),

              // More / Gallery menu
              PopupMenuButton<String>(
                tooltip: 'Import or switch',
                color: c.surface,
                icon: Container(
                  width: 48, height: 48,
                  decoration: BoxDecoration(
                    color: c.surface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: c.border, width: 1.2),
                    boxShadow: [
                      BoxShadow(color: c.shadow, blurRadius: 8, offset: const Offset(0, 2)),
                    ],
                  ),
                  child: Icon(Icons.more_horiz_rounded, color: c.textBright, size: 22),
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
                    child: Row(children: [
                      Icon(Icons.photo_library_rounded, size: 16, color: c.cyan),
                      const SizedBox(width: 8),
                      Text('Import Screenshot', style: NeoTheme.fontSans(fontSize: 13, color: c.textBright)),
                    ]),
                  ),
                  if (_availableCameras.length > 1)
                    PopupMenuItem(
                      value: 'switch',
                      child: Row(children: [
                        Icon(Icons.flip_camera_android_rounded, size: 16, color: c.textSecondary),
                        const SizedBox(width: 8),
                        Text('Switch Camera', style: NeoTheme.fontSans(fontSize: 13, color: c.textBright)),
                      ]),
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
    final c = NeoColors.of(context);
    return IgnorePointer(
      child: Stack(
        children: [
          // Top alignment hint
          Positioned(
            top: 14, left: 16, right: 16,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.65),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: c.cyan.withValues(alpha: 0.4), width: 1),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.center_focus_strong_rounded, size: 14, color: c.cyan),
                    const SizedBox(width: 6),
                    Text(
                      'ALIGN TERMINAL OR SCREEN',
                      style: NeoTheme.fontMono(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                        color: c.cyan,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Reticle frame
          Center(
            child: Container(
              margin: const EdgeInsets.all(36),
              decoration: BoxDecoration(
                border: Border.all(color: c.cyan.withValues(alpha: 0.25), width: 1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Stack(
                children: [
                  _cornerBracket(c.cyan, isTop: true, isLeft: true),
                  Positioned(top: 0, right: 0, child: _cornerBracket(c.cyan, isTop: true, isLeft: false)),
                  Positioned(bottom: 0, left: 0, child: _cornerBracket(c.cyan, isTop: false, isLeft: true)),
                  Positioned(bottom: 0, right: 0, child: _cornerBracket(c.cyan, isTop: false, isLeft: false)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _cornerBracket(Color color, {required bool isTop, required bool isLeft}) {
    return SizedBox(
      width: 22, height: 22,
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border(
            top: isTop ? BorderSide(color: color, width: 3) : BorderSide.none,
            bottom: !isTop ? BorderSide(color: color, width: 3) : BorderSide.none,
            left: isLeft ? BorderSide(color: color, width: 3) : BorderSide.none,
            right: !isLeft ? BorderSide(color: color, width: 3) : BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _buildResultsView() {
    final c = NeoColors.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 110),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          StatusBanner(findings: _findings, isScanning: false),
          const SizedBox(height: 14),

          // Action bar
          Row(
            children: [
              GestureDetector(
                onTap: _resetScan,
                child: NeoTheme.sticker(context,
                    text: 'SCAN ANOTHER',
                    icon: Icons.replay_rounded, fontSize: 11),
              ),
              const Spacer(),
              if (widget.onSendToPasteEditor != null && _extractedText != null)
                GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    widget.onSendToPasteEditor!(_extractedText!);
                  },
                  child: NeoTheme.sticker(context,
                      text: 'LOAD IN EDITOR',
                      icon: Icons.edit_note_rounded,
                      color: c.green, fontSize: 11),
                ),
            ],
          ),

          const SizedBox(height: 14),

          // Image preview
          if (_capturedImagePath != null && File(_capturedImagePath!).existsSync()) ...[
            Container(
              height: 140,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: c.border, width: 1.2),
              ),
              clipBehavior: Clip.hardEdge,
              child: Image.file(File(_capturedImagePath!), fit: BoxFit.cover, width: double.infinity),
            ),
            const SizedBox(height: 14),
          ],

          // OCR text box
          Container(
            decoration: BoxDecoration(
              color: c.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: c.border, width: 1.2),
              boxShadow: [
                BoxShadow(
                  color: c.shadow,
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: c.surfaceAlt,
                      border: Border(bottom: BorderSide(color: c.border, width: 1)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.document_scanner_rounded, size: 15, color: c.cyan),
                        const SizedBox(width: 8),
                        Text(
                          'OCR EXTRACTED TEXT (${_extractedText?.length ?? 0} chars)',
                          style: NeoTheme.fontMono(
                            fontSize: 10.5, fontWeight: FontWeight.w700, color: c.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(14),
                    child: SelectableText(
                      _extractedText ?? '',
                      style: NeoTheme.fontMono(fontSize: 12, height: 1.45, color: c.textPrimary),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 18),

          if (_findings.isNotEmpty) ...[
            Text(
              'OCR FINDINGS (${_findings.length})',
              style: NeoTheme.fontSans(
                fontSize: 13, fontWeight: FontWeight.w800, color: c.textSecondary, letterSpacing: 0.4,
              ),
            ),
            const SizedBox(height: 12),
            ..._findings.map((f) => FindingCard(
                  key: ValueKey('${f.type}_${f.startIndex}'),
                  finding: f,
                )),
          ],
        ],
      ),
    );
  }
}