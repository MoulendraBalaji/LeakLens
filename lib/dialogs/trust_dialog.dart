import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/neo_theme.dart';

/// Neo-brutalist air-gap security guarantee dialog.
class TrustDialog extends StatelessWidget {
  const TrustDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final c = NeoColors.of(context);

    return Dialog(
      backgroundColor: c.surface,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(0),
        side: BorderSide(color: c.border, width: NeoTheme.borderWidth),
      ),
      child: Container(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: c.surface,
          boxShadow: [NeoTheme.hardShadow(c.shadow, offset: const Offset(8, 8))],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header slab
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: c.green,
                    borderRadius: BorderRadius.circular(0),
                    border: Border.all(color: c.border, width: 2.5),
                  ),
                  child: Icon(
                    Icons.verified_user_rounded,
                    color: c.border,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'AIR-GAPPED',
                        style: NeoTheme.fontDisplay(
                          fontSize: 20,
                          color: c.textBright,
                        ),
                      ),
                      Text(
                        '100% ON-DEVICE — ZERO NETWORK',
                        style: NeoTheme.fontMono(
                          fontSize: 10,
                          color: c.textSecondary,
                          letterSpacing: 0.6,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Text(
              'LeakLens is designed with verifiable on-device-only guarantees:',
              style: NeoTheme.fontSans(
                fontSize: 13,
                height: 1.4,
                color: c.textSecondary,
              ),
            ),
            const SizedBox(height: 16),
            _auditItem(c, Icons.wifi_off_rounded, 'Zero Network Permissions',
                'android.permission.INTERNET is absent from AndroidManifest.xml. The OS physically blocks any network calls.'),
            const SizedBox(height: 12),
            _auditItem(c, Icons.memory_rounded, 'Ephemeral In-Memory Only',
                'No databases, no Hive, no room. All scanned text and findings vanish when the app closes.'),
            const SizedBox(height: 12),
            _auditItem(c, Icons.document_scanner_rounded, 'On-Device ML Kit OCR',
                'Camera text recognition runs entirely on your hardware via Google ML Kit Latin model. Zero roundtrips.'),
            const SizedBox(height: 12),
            _auditItem(c, Icons.phonelink_off_rounded, 'No Analytics or Trackers',
                'No Firebase Analytics, Crashlytics, telemetry, or advertising SDKs present.'),
            const SizedBox(height: 12),
            _auditItem(c, Icons.lock_outline_rounded, 'Minimal Storage',
                'Only your theme preference (light/dark) is stored locally via SharedPreferences. No secrets are ever saved.'),
            const SizedBox(height: 22),
            Align(
              alignment: Alignment.centerRight,
              child: GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  Navigator.of(context).pop();
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                  decoration: BoxDecoration(
                    color: c.green,
                    borderRadius: BorderRadius.circular(0),
                    border: Border.all(color: c.border, width: 2.5),
                    boxShadow: [
                      NeoTheme.hardShadow(c.border, offset: const Offset(3, 3)),
                    ],
                  ),
                  child: Text(
                    'DONE',
                    style: NeoTheme.fontSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: c.border,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _auditItem(
      NeoColors c, IconData icon, String title, String description) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: c.cyan,
            borderRadius: BorderRadius.circular(0),
            border: Border.all(color: c.border, width: 2),
          ),
          child: Icon(icon, size: 16, color: c.border),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: NeoTheme.fontSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: c.textBright,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                description,
                style: NeoTheme.fontSans(
                  fontSize: 11.5,
                  height: 1.4,
                  color: c.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}