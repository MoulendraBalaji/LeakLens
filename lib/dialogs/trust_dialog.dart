import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/terminal_theme.dart';

/// Apple & Pixel-inspired modal sheet explaining LeakLens's air-gapped security guarantees.
class TrustDialog extends StatelessWidget {
  const TrustDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
          child: Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: const Color(0xF0111622),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: const Color(0x5906B6D4),
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.6),
                  blurRadius: 30,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: TerminalTheme.safeGreen.withValues(alpha: 0.18),
                        border: Border.all(
                          color: TerminalTheme.safeGreen.withValues(alpha: 0.5),
                        ),
                      ),
                      child: const Icon(
                        Icons.verified_user_rounded,
                        color: TerminalTheme.safeGreen,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Air-Gapped Security',
                            style: TerminalTheme.fontSans(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: TerminalTheme.textBright,
                            ),
                          ),
                          Text(
                            '100% On-Device • Zero Network Calls',
                            style: TerminalTheme.fontMono(
                              fontSize: 10,
                              color: TerminalTheme.safeGreenSoft,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  'LeakLens is engineered with verifiable cryptographic and operating system-level guarantees:',
                  style: TerminalTheme.fontSans(
                    fontSize: 12.5,
                    height: 1.4,
                    color: TerminalTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: 16),
                _buildAuditItem(
                  icon: Icons.wifi_off_rounded,
                  title: 'Zero Network Permissions',
                  description:
                      'android.permission.INTERNET is completely absent from AndroidManifest.xml. The OS physically rejects any network calls.',
                ),
                const SizedBox(height: 12),
                _buildAuditItem(
                  icon: Icons.memory_rounded,
                  title: 'Ephemeral In-Memory Only',
                  description:
                      'No local databases (no SQLite, no Hive, no SharedPreferences). All scanned text and findings vanish when the app closes.',
                ),
                const SizedBox(height: 12),
                _buildAuditItem(
                  icon: Icons.document_scanner_rounded,
                  title: 'On-Device ML Kit OCR',
                  description:
                      'Camera text recognition runs locally on your device hardware using Google ML Kit Latin model. Zero server roundtrips.',
                ),
                const SizedBox(height: 12),
                _buildAuditItem(
                  icon: Icons.shield_rounded,
                  title: 'No Analytics or Trackers',
                  description:
                      'No Firebase Analytics, Crashlytics, telemetry, or remote advertising SDKs.',
                ),
                const SizedBox(height: 22),
                Align(
                  alignment: Alignment.centerRight,
                  child: FilledButton(
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      Navigator.of(context).pop();
                    },
                    style: FilledButton.styleFrom(
                      backgroundColor: TerminalTheme.safeGreen,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Done',
                      style: TerminalTheme.fontSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAuditItem({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: const Color(0x1F06B6D4),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 16, color: TerminalTheme.infoBlue),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TerminalTheme.fontSans(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: TerminalTheme.textBright,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                description,
                style: TerminalTheme.fontSans(
                  fontSize: 11.5,
                  height: 1.4,
                  color: TerminalTheme.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
