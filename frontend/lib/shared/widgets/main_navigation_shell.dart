import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app_clean_architecture/config/theme/app_colors.dart';
import 'package:news_app_clean_architecture/config/theme/app_spacing.dart';
import 'package:news_app_clean_architecture/core/services/haptic_service.dart';
import 'package:news_app_clean_architecture/features/auth/presentation/bloc/auth_cubit.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/my_articles/my_articles_cubit.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/pages/home/premium_daily_news.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/pages/my_articles/my_articles_page.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/pages/profile/profile_page.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/local/local_article_bloc.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/local/local_article_event.dart';
import 'package:news_app_clean_architecture/injection_container.dart';

/// Main navigation shell that provides bottom navigation for the app.
///
/// Contains three main tabs:
/// - Feed (Home) - News feed with Bento Grid
/// - My Articles - User's own articles
/// - Profile - User profile and settings
///
/// Uses [IndexedStack] to preserve state when switching tabs.
class MainNavigationShell extends StatefulWidget {
  const MainNavigationShell({super.key});

  @override
  State<MainNavigationShell> createState() => _MainNavigationShellState();
}

class _MainNavigationShellState extends State<MainNavigationShell> {
  int _currentIndex = 0;

  /// Pages for each navigation tab.
  /// Using late final to defer initialization until build.
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      const PremiumDailyNews(),
      const MyArticlesPage(),
      MultiBlocProvider(
        providers: [
          BlocProvider<LocalArticleBloc>(
            create: (_) =>
                sl<LocalArticleBloc>()..add(const GetSavedArticles()),
          ),
        ],
        child: const ProfilePage(),
      ),
    ];
  }

  void _onTabTapped(int index) {
    if (index == _currentIndex) return;

    HapticService.selectionClick();
    setState(() => _currentIndex = index);

    // Load user articles when switching to My Articles tab
    if (index == 1) {
      _loadUserArticles();
    }
  }

  void _loadUserArticles() {
    final authState = context.read<AuthCubit>().state;
    if (authState is AuthAuthenticated && authState.user != null) {
      context.read<MyArticlesCubit>().loadArticles(authState.user!.uid);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: IndexedStack(
          index: _currentIndex,
          children: _pages,
        ),
        bottomNavigationBar: _buildBottomNavBar(),
      ),
    );
  }

  Widget _buildBottomNavBar() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(
          top: BorderSide(
            color: AppColors.border,
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                index: 0,
                icon: Icons.home_outlined,
                activeIcon: Icons.home_rounded,
                label: 'Feed',
              ),
              _buildNavItem(
                index: 1,
                icon: Icons.article_outlined,
                activeIcon: Icons.article_rounded,
                label: 'My Articles',
              ),
              _buildNavItem(
                index: 2,
                icon: Icons.person_outline_rounded,
                activeIcon: Icons.person_rounded,
                label: 'Profile',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required IconData activeIcon,
    required String label,
  }) {
    final isSelected = _currentIndex == index;

    return GestureDetector(
      onTap: () => _onTabTapped(index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.15)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(AppSpacing.lg),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? activeIcon : icon,
              color: isSelected ? AppColors.primary : AppColors.textSecondary,
              size: 24,
            ),
            if (isSelected) ...[
              SizedBox(width: AppSpacing.xs),
              Text(
                label,
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
