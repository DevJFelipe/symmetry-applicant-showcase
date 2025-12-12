import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app_clean_architecture/config/theme/app_spacing.dart';
import 'package:news_app_clean_architecture/config/theme/app_typography.dart';
import 'package:news_app_clean_architecture/config/theme/app_radius.dart';
import 'package:news_app_clean_architecture/core/services/haptic_service.dart';
import 'package:news_app_clean_architecture/core/services/preferences_service.dart';
import 'package:news_app_clean_architecture/injection_container.dart';
import 'package:news_app_clean_architecture/config/theme/theme_cubit.dart';
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
    return BlocBuilder<ThemeCubit, AppThemeMode>(
      builder: (context, themeMode) {
        final isDark = themeMode == AppThemeMode.dark;
        final theme = Theme.of(context);

        return AnnotatedRegion<SystemUiOverlayStyle>(
          value:
              isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
          child: Scaffold(
            backgroundColor: theme.scaffoldBackgroundColor,
            body: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                _buildAppBar(context),
                SliverToBoxAdapter(
                  child: _buildContent(context),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAppBar(BuildContext context) {
    final theme = Theme.of(context);
    return SliverAppBar(
      expandedHeight: 100,
      floating: true,
      pinned: true,
      backgroundColor: theme.scaffoldBackgroundColor,
      surfaceTintColor: Colors.transparent,
      leading: _buildBackButton(context),
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.only(left: 56, bottom: 16),
        title: Text(
          'Settings',
          style: AppTypography.headlineSmall.copyWith(
            color: theme.colorScheme.onSurface,
          ),
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                theme.colorScheme.primary.withValues(alpha: 0.1),
                theme.scaffoldBackgroundColor,
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBackButton(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: () {
        HapticService.lightImpact();
        Navigator.pop(context);
      },
      child: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        child: Icon(
          Icons.arrow_back_ios_new_rounded,
          color: theme.colorScheme.onSurface,
          size: 20,
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.screenPaddingH),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Preferences Section
          _buildSectionHeader(context, 'Preferences')
              .animate()
              .fadeIn(duration: 300.ms),

          _buildToggleItem(
            context: context,
            icon: Icons.vibration_rounded,
            title: 'Haptic Feedback',
            subtitle: 'Vibration on interactions',
            value: _hapticEnabled,
            onChanged: _onHapticChanged,
          ).animate().fadeIn(duration: 300.ms, delay: 50.ms),

          _buildToggleItem(
            context: context,
            icon: Icons.notifications_outlined,
            title: 'Notifications',
            subtitle: 'Push notifications for news',
            value: _notificationsEnabled,
            onChanged: _onNotificationsChanged,
          ).animate().fadeIn(duration: 300.ms, delay: 100.ms),

          _buildToggleItem(
            context: context,
            icon: Icons.data_saver_on_outlined,
            title: 'Data Saver',
            subtitle: 'Reduce image quality to save data',
            value: _dataSaverEnabled,
            onChanged: _onDataSaverChanged,
          ).animate().fadeIn(duration: 300.ms, delay: 150.ms),

          SizedBox(height: AppSpacing.xxl),

          // About Section
          _buildSectionHeader(context, 'About')
              .animate()
              .fadeIn(duration: 300.ms, delay: 200.ms),

          _buildLinkItem(
            context: context,
            icon: Icons.privacy_tip_outlined,
            title: 'Privacy Policy',
            onTap: () => _openUrl('https://example.com/privacy'),
          ).animate().fadeIn(duration: 300.ms, delay: 250.ms),

          _buildLinkItem(
            context: context,
            icon: Icons.description_outlined,
            title: 'Terms of Service',
            onTap: () => _openUrl('https://example.com/terms'),
          ).animate().fadeIn(duration: 300.ms, delay: 300.ms),

          _buildLinkItem(
            context: context,
            icon: Icons.info_outline_rounded,
            title: 'About App',
            onTap: () => _showAboutDialog(context),
          ).animate().fadeIn(duration: 300.ms, delay: 350.ms),

          SizedBox(height: AppSpacing.xxl),

          // Version info
          Center(
            child: Text(
              'Version 1.0.0',
              style: AppTypography.caption.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
              ),
            ),
          ).animate().fadeIn(duration: 300.ms, delay: 400.ms),

          SizedBox(height: AppSpacing.xxxl),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.only(
        top: AppSpacing.lg,
        bottom: AppSpacing.md,
      ),
      child: Text(
        title.toUpperCase(),
        style: AppTypography.labelSmall.copyWith(
          color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildToggleItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    final theme = Theme.of(context);
    return Container(
      margin: EdgeInsets.only(bottom: AppSpacing.sm),
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: theme.dividerColor,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Icon(
              icon,
              color: theme.colorScheme.primary,
              size: 20,
            ),
          ),
          SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: AppTypography.titleSmall
                        .copyWith(color: theme.colorScheme.onSurface)),
                Text(
                  subtitle,
                  style: AppTypography.bodySmall.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                ),
              ],
            ),
          ),
          Switch.adaptive(
            value: value,
            onChanged: onChanged,
            activeColor: theme.colorScheme.primary,
            inactiveTrackColor:
                theme.colorScheme.onSurface.withValues(alpha: 0.3),
          ),
        ],
      ),
    );
  }

  Widget _buildLinkItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: () {
        HapticService.lightImpact();
        onTap();
      },
      child: Container(
        margin: EdgeInsets.only(bottom: AppSpacing.sm),
        padding: EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(
            color: theme.dividerColor,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Icon(
                icon,
                color: theme.colorScheme.primary,
                size: 20,
              ),
            ),
            SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(title,
                  style: AppTypography.titleSmall
                      .copyWith(color: theme.colorScheme.onSurface)),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
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
    final theme = Theme.of(context);
    final uri = Uri.parse(url);
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Could not open link',
              style: AppTypography.bodyMedium
                  .copyWith(color: theme.colorScheme.onError),
            ),
            backgroundColor: theme.colorScheme.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
          ),
        );
      }
    }
  }

  void _showAboutDialog(BuildContext context) {
    final theme = Theme.of(context);
    showAboutDialog(
      context: context,
      applicationName: 'News App',
      applicationVersion: '1.0.0',
      applicationIcon: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [
            theme.colorScheme.primary,
            theme.colorScheme.secondary,
          ]),
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
