import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' as ui;

/// Boosts contrast of captured images so on-device ML Kit OCR reads terminal
/// text more reliably. Also upscales small captures (e.g. gallery picks) for
/// better character recognition.
///
/// All processing is pixel-level; no network calls.
class ImagePreprocessor {
  ImagePreprocessor._();

  /// Takes [srcPath], applies contrast enhancement and a mild upscale for
  /// screens narrower than 2 000 px, writes a temp PNG, and returns its path.
  static Future<String> enhanceForOcr(String srcPath) async {
    final bytes = await File(srcPath).readAsBytes();
    final codec = await ui.instantiateImageCodec(bytes);
    final frame = await codec.getNextFrame();
    final image = frame.image;

    // Upscale small images (typically gallery picks) to improve OCR accuracy
    final bool shouldUpscale = image.width < 2000 || image.height < 2000;
    final double scale = shouldUpscale
        ? math.min(2000 / image.width, 2000 / image.height).clamp(1.0, 2.5)
        : 1.0;

    final int outW = (image.width * scale).round();
    final int outH = (image.height * scale).round();

    final recorder = ui.PictureRecorder();
    final canvas =
        ui.Canvas(recorder, ui.Rect.fromLTWH(0, 0, outW.toDouble(), outH.toDouble()));

    // Contrast boost colour matrix:
    //  – lifts dark tones toward mid-grey so faint white-on-black text pops
    //  – pushes brights closer to pure white
    const double contrast = 1.45;
    const double brightness = -38.0;
    final paint = ui.Paint()
      ..filterQuality = ui.FilterQuality.high
      ..colorFilter = ui.ColorFilter.matrix([
        contrast, 0, 0, 0, brightness,
        0, contrast, 0, 0, brightness,
        0, 0, contrast, 0, brightness,
        0, 0, 0, 1, 0,
      ]);

    canvas.drawImageRect(
      image,
      ui.Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble()),
      ui.Rect.fromLTWH(0, 0, outW.toDouble(), outH.toDouble()),
      paint,
    );

    final picture = recorder.endRecording();
    final outImage = await picture.toImage(outW, outH);
    final byteData = await outImage.toByteData(format: ui.ImageByteFormat.png);
    if (byteData == null) throw Exception('PNG encode failed');

    // Write to temp directory
    final tempDir = Directory.systemTemp;
    final outPath =
        '${tempDir.path}${Platform.pathSeparator}leaklens_ocr_${DateTime.now().millisecondsSinceEpoch}.png';
    await File(outPath).writeAsBytes(byteData.buffer.asUint8List());

    // Cleanup native references
    image.dispose();
    outImage.dispose();

    return outPath;
  }
}