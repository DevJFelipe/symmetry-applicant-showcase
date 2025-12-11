import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app_clean_architecture/injection_container.dart';

import '../../features/auth/presentation/bloc/auth_cubit.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/daily_news/domain/entities/article.dart';
import '../../features/daily_news/presentation/bloc/article/create/create_article_cubit.dart';
import '../../features/daily_news/presentation/bloc/article/edit/edit_article_cubit.dart';
import '../../features/daily_news/presentation/bloc/article_detail/article_detail_cubit.dart';
import '../../features/daily_news/presentation/bloc/search/search_cubit.dart';
import '../../features/daily_news/presentation/bloc/my_articles/my_articles_cubit.dart';
import '../../features/daily_news/presentation/pages/article_detail/premium_article_detail.dart';
import '../../features/daily_news/presentation/pages/create_article/create_article_page.dart';
import '../../features/daily_news/presentation/pages/edit_article/edit_article_page.dart';
import '../../features/daily_news/presentation/pages/home/premium_daily_news.dart';
import '../../features/daily_news/presentation/pages/my_articles/my_articles_page.dart';
import '../../features/daily_news/presentation/pages/profile/profile_page.dart';
import '../../features/daily_news/presentation/pages/saved_article/saved_article.dart';
import '../../features/daily_news/presentation/pages/search/search_page.dart';


class AppRoutes {
  static Route onGenerateRoutes(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return _materialRoute(const PremiumDailyNews());

      case '/login':
        return _materialRoute(
          BlocProvider<AuthCubit>(
            create: (_) => sl<AuthCubit>(),
            child: const LoginPage(),
          ),
        );

      case '/register':
        return _materialRoute(
          BlocProvider<AuthCubit>(
            create: (_) => sl<AuthCubit>(),
            child: const RegisterPage(),
          ),
        );

      case '/create-article':
        return _materialRoute(
          BlocProvider<CreateArticleCubit>(
            create: (_) => sl<CreateArticleCubit>(),
            child: const CreateArticlePage(),
          ),
        );

      case '/ArticleDetails':
        final article = settings.arguments as ArticleEntity;
        return _materialRoute(
          BlocProvider<ArticleDetailCubit>(
            create: (_) => sl<ArticleDetailCubit>()..loadArticle(article),
            child: PremiumArticleDetail(article: article),
          ),
        );

      case '/SavedArticles':
        return _materialRoute(const SavedArticles());

      case '/search':
        return _materialRoute(
          BlocProvider<SearchCubit>(
            create: (_) => sl<SearchCubit>(),
            child: const SearchPage(),
          ),
        );

      case '/profile':
        return _materialRoute(const ProfilePage());

      case '/my-articles':
        return _materialRoute(
          BlocProvider<MyArticlesCubit>(
            create: (_) => sl<MyArticlesCubit>(),
            child: const MyArticlesPage(),
          ),
        );

      case '/edit-article':
        final article = settings.arguments as ArticleEntity;
        return _materialRoute(
          BlocProvider<EditArticleCubit>(
            create: (_) => sl<EditArticleCubit>()..loadArticle(article),
            child: const EditArticlePage(),
          ),
        );
        
      default:
        return _materialRoute(const PremiumDailyNews());
    }
  }

  static Route<dynamic> _materialRoute(Widget view) {
    return MaterialPageRoute(builder: (_) => view);
  }
}

