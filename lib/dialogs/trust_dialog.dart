import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/neo_theme.dart';

/// Refined air-gap security guarantee dialog.
class TrustDialog extends StatelessWidget {
  const TrustDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final c = NeoColors.of(context);

    return Dialog(
      backgroundColor: c.surface,
      elevation: 16,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22),
        side: BorderSide(color: c.border, width: 1.2),
      ),
      child: Container(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: c.surface,
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: c.shadow,
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: c.green.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: c.green.withValues(alpha: 0.4),
                        width: 1.2,
                      ),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.verified_user_rounded,
                        color: c.green,
                        size: 24,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'AIR-GAPPED',
                          style: NeoTheme.fontDisplay(
                            fontSize: 19,
                            fontWeight: FontWeight.w800,
                            color: c.textBright,
                            letterSpacing: -0.2,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '100% ON-DEVICE — ZERO NETWORK',
                          style: NeoTheme.fontMono(
                            fontSize: 10,
                            color: c.green,
                            letterSpacing: 0.4,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                'LeakLens is engineered with verifiable on-device privacy guarantees:',
                style: NeoTheme.fontSans(
                  fontSize: 13,
                  height: 1.4,
                  color: c.textSecondary,
                ),
              ),
              const SizedBox(height: 16),
              _auditItem(c, Icons.wifi_off_rounded, 'Zero Network Permissions',
                  'android.permission.INTERNET is completely absent. The OS physically blocks any outgoing network sockets.'),
              const SizedBox(height: 12),
              _auditItem(c, Icons.memory_rounded, 'Ephemeral In-Memory Only',
                  'No local databases or persistent storage. All scanned credentials vanish when the app closes.'),
              const SizedBox(height: 12),
              _auditItem(c, Icons.document_scanner_rounded, 'On-Device ML Kit OCR',
                  'Text recognition runs strictly locally using Google ML Kit. Zero cloud inference.'),
              const SizedBox(height: 12),
              _auditItem(c, Icons.phonelink_off_rounded, 'No Analytics or Trackers',
                  'No telemetry, Firebase Analytics, Crashlytics, or advertising SDKs present.'),
              const SizedBox(height: 12),
              _auditItem(c, Icons.lock_outline_rounded, 'Minimal Local Storage',
                  'Only your UI theme preference (light/dark) is saved in SharedPreferences. Secrets are never stored.'),
              const SizedBox(height: 22),
              Align(
                alignment: Alignment.centerRight,
                child: InkWell(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    Navigator.of(context).pop();
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
                    decoration: BoxDecoration(
                      color: c.green.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: c.green.withValues(alpha: 0.4),
                        width: 1.1,
                      ),
                    ),
                    child: Text(
                      'DONE',
                      style: NeoTheme.fontSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: c.green,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
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
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: c.cyan.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: c.cyan.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: Center(
            child: Icon(icon, size: 16, color: c.cyan),
          ),
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
                  fontWeight: FontWeight.w700,
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