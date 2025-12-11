import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:news_app_clean_architecture/config/theme/app_colors.dart';
import 'package:news_app_clean_architecture/config/theme/app_spacing.dart';
import 'package:news_app_clean_architecture/config/theme/app_typography.dart';
import 'package:news_app_clean_architecture/config/theme/app_radius.dart';
import 'package:news_app_clean_architecture/core/services/haptic_service.dart';
import 'package:news_app_clean_architecture/features/auth/presentation/bloc/auth_cubit.dart';
import 'package:news_app_clean_architecture/shared/widgets/widgets.dart';

/// Premium Profile screen with user info and statistics.
///
/// Features:
/// - Avatar with gradient border
/// - User statistics (articles, reactions received)
/// - Settings and preferences
/// - Account management
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

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
              child: _buildContent(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 200,
      pinned: true,
      automaticallyImplyLeading: false, // No back button in tab navigation
      backgroundColor: AppColors.background,
      surfaceTintColor: Colors.transparent,
      actions: [
        IconButton(
          onPressed: () => _onSettingsTapped(context),
          icon: Icon(
            Icons.settings_outlined,
            color: AppColors.textPrimary,
          ),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.accent.withValues(alpha: 0.2),
                AppColors.background,
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        final user = state.user;
        final displayName = user?.displayName ?? 'Journalist';
        final email = user?.email ?? '';
        final initial = displayName.isNotEmpty ? displayName[0].toUpperCase() : 'J';

        return Padding(
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.screenPaddingH),
          child: Column(
            children: [
              // Avatar section
              _buildAvatarSection(initial, displayName, email)
                  .animate()
                  .fadeIn(duration: 400.ms)
                  .slideY(begin: 0.1, end: 0),
              
              SizedBox(height: AppSpacing.xxl),
              
              // Stats row
              _buildStatsRow()
                  .animate()
                  .fadeIn(duration: 400.ms, delay: 100.ms),
              
              SizedBox(height: AppSpacing.xxl),
              
              // Menu items
              _buildMenuSection(context),
              
              SizedBox(height: AppSpacing.xxl),
              
              // Sign out button
              _buildSignOutButton(context)
                  .animate()
                  .fadeIn(duration: 400.ms, delay: 400.ms),
              
              SizedBox(height: AppSpacing.xxxl),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAvatarSection(String initial, String name, String email) {
    return Column(
      children: [
        // Avatar with gradient border
        Container(
          padding: EdgeInsets.all(4),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: AppColors.accentGradient,
          ),
          child: CircleAvatar(
            radius: 50,
            backgroundColor: AppColors.surface,
            child: Text(
              initial,
              style: AppTypography.displaySmall.copyWith(
                color: AppColors.accent,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        
        SizedBox(height: AppSpacing.md),
        
        // Name
        Text(
          name,
          style: AppTypography.headlineMedium,
        ),
        
        SizedBox(height: AppSpacing.xxs),
        
        // Email
        Text(
          email,
          style: AppTypography.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        
        SizedBox(height: AppSpacing.sm),
        
        // Role badge
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.xxs,
          ),
          decoration: BoxDecoration(
            color: AppColors.accent.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(AppRadius.full),
            border: Border.all(
              color: AppColors.accent.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.verified_rounded,
                size: 14,
                color: AppColors.accent,
              ),
              SizedBox(width: AppSpacing.xxs),
              Text(
                'JOURNALIST',
                style: AppTypography.labelSmall.copyWith(
                  color: AppColors.accent,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatsRow() {
    return Container(
      padding: EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(
          color: AppColors.border,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildStatItem('Articles', '0', Icons.article_outlined),
          _buildStatDivider(),
          _buildStatItem('Reactions', '0', Icons.favorite_outline),
          _buildStatDivider(),
          _buildStatItem('Saved', '0', Icons.bookmark_outline),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(
          icon,
          color: AppColors.accent,
          size: 24,
        ),
        SizedBox(height: AppSpacing.xs),
        Text(
          value,
          style: AppTypography.headlineSmall.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
        Text(
          label,
          style: AppTypography.labelSmall.copyWith(
            color: AppColors.textMuted,
          ),
        ),
      ],
    );
  }

  Widget _buildStatDivider() {
    return Container(
      width: 1,
      height: 50,
      color: AppColors.border,
    );
  }

  Widget _buildMenuSection(BuildContext context) {
    return Column(
      children: [
        _buildMenuItem(
          icon: Icons.article_outlined,
          title: 'My Articles',
          subtitle: 'View and manage your articles',
          onTap: () => Navigator.pushNamed(context, '/my-articles'),
        ).animate().fadeIn(duration: 400.ms, delay: 200.ms),
        
        _buildMenuItem(
          icon: Icons.bookmark_border_rounded,
          title: 'Saved Articles',
          subtitle: 'Articles you\'ve bookmarked',
          onTap: () => Navigator.pushNamed(context, '/SavedArticles'),
        ).animate().fadeIn(duration: 400.ms, delay: 250.ms),
        
        _buildMenuItem(
          icon: Icons.notifications_outlined,
          title: 'Notifications',
          subtitle: 'Manage notification preferences',
          onTap: () {},
        ).animate().fadeIn(duration: 400.ms, delay: 300.ms),
        
        _buildMenuItem(
          icon: Icons.privacy_tip_outlined,
          title: 'Privacy',
          subtitle: 'Privacy settings and data',
          onTap: () {},
        ).animate().fadeIn(duration: 400.ms, delay: 350.ms),
      ],
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTypography.titleSmall,
                  ),
                  Text(
                    subtitle,
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
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

  Widget _buildSignOutButton(BuildContext context) {
    return GestureDetector(
      onTap: () => _showSignOutConfirmation(context),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.error.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(
            color: AppColors.error.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.logout_rounded,
              color: AppColors.error,
              size: 20,
            ),
            SizedBox(width: AppSpacing.sm),
            Text(
              'Sign Out',
              style: AppTypography.titleSmall.copyWith(
                color: AppColors.error,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onSettingsTapped(BuildContext context) {
    HapticService.lightImpact();
    Navigator.pushNamed(context, '/settings');
  }

  void _showSignOutConfirmation(BuildContext context) {
    HapticService.lightImpact();
    showDialog(
      context: context,
      builder: (context) => ConfirmationModal(
        title: 'Sign Out',
        message: 'Are you sure you want to sign out of your account?',
        confirmLabel: 'Sign Out',
        isDanger: true,
        onConfirm: () {
          Navigator.pop(context);
          context.read<AuthCubit>().signOut();
          Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
        },
        onCancel: () => Navigator.pop(context),
      ),
    );
  }
}
