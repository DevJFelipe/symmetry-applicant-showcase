import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:news_app_clean_architecture/config/theme/app_colors.dart';
import 'package:news_app_clean_architecture/config/theme/app_spacing.dart';
import 'package:news_app_clean_architecture/config/theme/app_typography.dart';
import 'package:news_app_clean_architecture/config/theme/app_radius.dart';
import 'package:news_app_clean_architecture/core/services/haptic_service.dart';
import 'package:news_app_clean_architecture/core/services/preferences_service.dart';
import 'package:news_app_clean_architecture/injection_container.dart';
import 'package:url_launcher/url_launcher.dart';

/// Settings page with app preferences and information.
///
/// Features:
/// - Toggle settings (haptic, notifications, data saver)
/// - App information section
/// - Legal links (privacy, terms)
/// - App version display
class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late final PreferencesService _prefs;

  // Local state for toggles
  late bool _hapticEnabled;
  late bool _notificationsEnabled;
  late bool _dataSaverEnabled;

  @override
  void initState() {
    super.initState();
    _prefs = sl<PreferencesService>();
    _loadPreferences();
  }

  void _loadPreferences() {
    _hapticEnabled = _prefs.hapticEnabled;
    _notificationsEnabled = _prefs.notificationsEnabled;
    _dataSaverEnabled = _prefs.dataSaverEnabled;
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            _buildAppBar(context),
            SliverToBoxAdapter(
              child: _buildContent(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 100,
      floating: true,
      pinned: true,
      backgroundColor: AppColors.background,
      surfaceTintColor: Colors.transparent,
      leading: _buildBackButton(context),
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.only(left: 56, bottom: 16),
        title: Text(
          'Settings',
          style: AppTypography.headlineSmall.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppColors.primaryDark.withValues(alpha: 0.3),
                AppColors.background,
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBackButton(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticService.lightImpact();
        Navigator.pop(context);
      },
      child: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        child: Icon(
          Icons.arrow_back_ios_new_rounded,
          color: AppColors.textPrimary,
          size: 20,
        ),
      ),
    );
  }

  Widget _buildContent() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.screenPaddingH),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Preferences Section
          _buildSectionHeader('Preferences')
              .animate()
              .fadeIn(duration: 300.ms),

          _buildToggleItem(
            icon: Icons.vibration_rounded,
            title: 'Haptic Feedback',
            subtitle: 'Vibration on interactions',
            value: _hapticEnabled,
            onChanged: _onHapticChanged,
          ).animate().fadeIn(duration: 300.ms, delay: 50.ms),

          _buildToggleItem(
            icon: Icons.notifications_outlined,
            title: 'Notifications',
            subtitle: 'Push notifications for news',
            value: _notificationsEnabled,
            onChanged: _onNotificationsChanged,
          ).animate().fadeIn(duration: 300.ms, delay: 100.ms),

          _buildToggleItem(
            icon: Icons.data_saver_on_outlined,
            title: 'Data Saver',
            subtitle: 'Reduce image quality to save data',
            value: _dataSaverEnabled,
            onChanged: _onDataSaverChanged,
          ).animate().fadeIn(duration: 300.ms, delay: 150.ms),

          SizedBox(height: AppSpacing.xxl),

          // About Section
          _buildSectionHeader('About')
              .animate()
              .fadeIn(duration: 300.ms, delay: 200.ms),

          _buildLinkItem(
            icon: Icons.privacy_tip_outlined,
            title: 'Privacy Policy',
            onTap: () => _openUrl('https://example.com/privacy'),
          ).animate().fadeIn(duration: 300.ms, delay: 250.ms),

          _buildLinkItem(
            icon: Icons.description_outlined,
            title: 'Terms of Service',
            onTap: () => _openUrl('https://example.com/terms'),
          ).animate().fadeIn(duration: 300.ms, delay: 300.ms),

          _buildLinkItem(
            icon: Icons.info_outline_rounded,
            title: 'About App',
            onTap: _showAboutDialog,
          ).animate().fadeIn(duration: 300.ms, delay: 350.ms),

          SizedBox(height: AppSpacing.xxl),

          // Version info
          Center(
            child: Text(
              'Version 1.0.0',
              style: AppTypography.caption.copyWith(
                color: AppColors.textMuted,
              ),
            ),
          ).animate().fadeIn(duration: 300.ms, delay: 400.ms),

          SizedBox(height: AppSpacing.xxxl),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: EdgeInsets.only(
        top: AppSpacing.lg,
        bottom: AppSpacing.md,
      ),
      child: Text(
        title.toUpperCase(),
        style: AppTypography.labelSmall.copyWith(
          color: AppColors.textMuted,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildToggleItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: AppSpacing.sm),
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: AppColors.border,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: AppColors.accent.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Icon(
              icon,
              color: AppColors.accent,
              size: 20,
            ),
          ),
          SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTypography.titleSmall),
                Text(
                  subtitle,
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
          Switch.adaptive(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.accent,
          ),
        ],
      ),
    );
  }

  Widget _buildLinkItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: () {
        HapticService.lightImpact();
        onTap();
      },
      child: Container(
        margin: EdgeInsets.only(bottom: AppSpacing.sm),
        padding: EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(
            color: AppColors.border,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: AppColors.accent.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Icon(
                icon,
                color: AppColors.accent,
                size: 20,
              ),
            ),
            SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(title, style: AppTypography.titleSmall),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: AppColors.textMuted,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  // ============================================
  // EVENT HANDLERS
  // ============================================

  void _onHapticChanged(bool value) {
    HapticService.lightImpact();
    setState(() => _hapticEnabled = value);
    _prefs.setHapticEnabled(value);
  }

  void _onNotificationsChanged(bool value) {
    HapticService.lightImpact();
    setState(() => _notificationsEnabled = value);
    _prefs.setNotificationsEnabled(value);
  }

  void _onDataSaverChanged(bool value) {
    HapticService.lightImpact();
    setState(() => _dataSaverEnabled = value);
    _prefs.setDataSaverEnabled(value);
  }

  Future<void> _openUrl(String url) async {
    final uri = Uri.parse(url);
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Could not open link',
              style: AppTypography.bodyMedium.copyWith(color: Colors.white),
            ),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
          ),
        );
      }
    }
  }

  void _showAboutDialog() {
    showAboutDialog(
      context: context,
      applicationName: 'News App',
      applicationVersion: '1.0.0',
      applicationIcon: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient,
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        child: const Icon(
          Icons.article_outlined,
          color: Colors.white,
          size: 28,
        ),
      ),
      applicationLegalese: '© 2025 News App. All rights reserved.',
    );
  }
}
