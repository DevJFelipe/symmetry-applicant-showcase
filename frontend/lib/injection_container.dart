import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:news_app_clean_architecture/core/services/preferences_service.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/data_sources/remote/news_api_service.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/repository/article_repository_impl.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/repository/article_repository.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/get_article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/get_external_reactions.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/remote/remote_article_bloc.dart';
import 'features/daily_news/data/data_sources/local/app_database.dart';
import 'features/daily_news/domain/usecases/get_saved_article.dart';
import 'features/daily_news/domain/usecases/remove_article.dart';
import 'features/daily_news/domain/usecases/save_article.dart';
import 'features/daily_news/presentation/bloc/article/local/local_article_bloc.dart';

// Auth feature imports
import 'package:news_app_clean_architecture/features/auth/data/data_sources/firebase_auth_service.dart';
import 'package:news_app_clean_architecture/features/auth/data/data_sources/profile_storage_service.dart';
import 'package:news_app_clean_architecture/features/auth/data/repository/auth_repository_impl.dart';
import 'package:news_app_clean_architecture/features/auth/domain/repository/auth_repository.dart';
import 'package:news_app_clean_architecture/features/auth/domain/usecases/get_current_user.dart';
import 'package:news_app_clean_architecture/features/auth/domain/usecases/sign_in.dart';
import 'package:news_app_clean_architecture/features/auth/domain/usecases/sign_out.dart';
import 'package:news_app_clean_architecture/features/auth/domain/usecases/sign_up.dart';
import 'package:news_app_clean_architecture/features/auth/domain/usecases/update_profile_photo.dart';
import 'package:news_app_clean_architecture/features/auth/presentation/bloc/auth_cubit.dart';

// Firestore article feature imports
import 'package:news_app_clean_architecture/features/daily_news/data/data_sources/firestore_article_service.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/data_sources/reaction_service.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/repository/firestore_article_repository_impl.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/repository/reaction_repository_impl.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/repository/firestore_article_repository.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/repository/reaction_repository.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/create_article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/toggle_reaction.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/toggle_article_reaction.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/get_user_articles.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/delete_article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/update_article.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/create/create_article_cubit.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/edit/edit_article_cubit.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article_detail/article_detail_cubit.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/my_articles/my_articles_cubit.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/search/search_cubit.dart';

final sl = GetIt.instance;

Future<void> initializeDependencies() async {
  // ============================================
  // Core Services
  // ============================================

  // Preferences Service (must be initialized first - async)
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerSingleton<PreferencesService>(
      PreferencesService(sharedPreferences));

  final database =
      await $FloorAppDatabase.databaseBuilder('app_database.db').build();
  sl.registerSingleton<AppDatabase>(database);

  // Dio
  sl.registerSingleton<Dio>(Dio());

  // Dependencies
  sl.registerSingleton<NewsApiService>(NewsApiService(sl()));

  sl.registerSingleton<ArticleRepository>(ArticleRepositoryImpl(sl(), sl()));

  //UseCases
  sl.registerSingleton<GetArticleUseCase>(GetArticleUseCase(sl()));

  sl.registerSingleton<GetSavedArticleUseCase>(GetSavedArticleUseCase(sl()));

  sl.registerSingleton<SaveArticleUseCase>(SaveArticleUseCase(sl()));

  sl.registerSingleton<RemoveArticleUseCase>(RemoveArticleUseCase(sl()));

  //Blocs
  // Note: RemoteArticlesBloc depends on ReactionService via GetExternalReactionsUseCase
  // which is registered later, so we use sl.call() to defer resolution
  sl.registerFactory<RemoteArticlesBloc>(() => RemoteArticlesBloc(
        sl<GetArticleUseCase>(),
        sl<GetExternalReactionsUseCase>(),
      ));

  sl.registerFactory<LocalArticleBloc>(
      () => LocalArticleBloc(sl(), sl(), sl()));

  // ============================================
  // Auth Feature
  // ============================================

  // Auth Data Sources
  sl.registerSingleton<FirebaseAuthService>(FirebaseAuthService());
  sl.registerSingleton<ProfileStorageService>(ProfileStorageService());

  // Auth Repository
  sl.registerSingleton<AuthRepository>(
      AuthRepositoryImpl(sl<FirebaseAuthService>(), sl<ProfileStorageService>()));

  // Auth UseCases
  sl.registerSingleton<GetCurrentUserUseCase>(
      GetCurrentUserUseCase(sl<AuthRepository>()));

  sl.registerSingleton<SignInUseCase>(SignInUseCase(sl<AuthRepository>()));

  sl.registerSingleton<SignUpUseCase>(SignUpUseCase(sl<AuthRepository>()));

  sl.registerSingleton<SignOutUseCase>(SignOutUseCase(sl<AuthRepository>()));

  sl.registerSingleton<UpdateProfilePhotoUseCase>(
      UpdateProfilePhotoUseCase(sl<AuthRepository>()));

  // Auth Cubit
  sl.registerFactory<AuthCubit>(() => AuthCubit(
        getCurrentUserUseCase: sl<GetCurrentUserUseCase>(),
        signInUseCase: sl<SignInUseCase>(),
        signUpUseCase: sl<SignUpUseCase>(),
        signOutUseCase: sl<SignOutUseCase>(),
        updateProfilePhotoUseCase: sl<UpdateProfilePhotoUseCase>(),
      ));

  // ============================================
  // Firestore Article Feature
  // ============================================

  // Firestore Data Sources
  sl.registerSingleton<FirestoreArticleService>(FirestoreArticleService());

  // Reaction Service (for both Firestore and external articles)
  sl.registerSingleton<ReactionService>(ReactionService());

  // Reaction Repository
  sl.registerSingleton<ReactionRepository>(
      ReactionRepositoryImpl(sl<ReactionService>()));

  // Firestore Repository
  sl.registerSingleton<FirestoreArticleRepository>(
      FirestoreArticleRepositoryImpl(sl<FirestoreArticleService>()));

  // Firestore UseCases
  sl.registerSingleton<CreateArticleUseCase>(
      CreateArticleUseCase(sl<FirestoreArticleRepository>()));

  sl.registerSingleton<ToggleReactionUseCase>(
      ToggleReactionUseCase(sl<FirestoreArticleRepository>()));

  sl.registerSingleton<GetUserArticlesUseCase>(
      GetUserArticlesUseCase(sl<FirestoreArticleRepository>()));

  sl.registerSingleton<DeleteArticleUseCase>(
      DeleteArticleUseCase(sl<FirestoreArticleRepository>()));

  sl.registerSingleton<UpdateArticleUseCase>(
      UpdateArticleUseCase(sl<FirestoreArticleRepository>()));

  sl.registerSingleton<GetExternalReactionsUseCase>(
      GetExternalReactionsUseCase(sl<ReactionRepository>()));

  sl.registerSingleton<ToggleArticleReactionUseCase>(
      ToggleArticleReactionUseCase(sl<ReactionRepository>()));

  // Create Article Cubit
  sl.registerFactory<CreateArticleCubit>(() => CreateArticleCubit(
        createArticleUseCase: sl<CreateArticleUseCase>(),
      ));

  // My Articles Cubit
  sl.registerFactory<MyArticlesCubit>(() => MyArticlesCubit(
        getUserArticlesUseCase: sl<GetUserArticlesUseCase>(),
        deleteArticleUseCase: sl<DeleteArticleUseCase>(),
      ));

  // Search Cubit
  sl.registerFactory<SearchCubit>(() => SearchCubit(
        getUserArticlesUseCase: sl<GetUserArticlesUseCase>(),
        getArticleUseCase: sl<GetArticleUseCase>(),
      ));

  // Article Detail Cubit (for reactions)
  sl.registerFactory<ArticleDetailCubit>(() => ArticleDetailCubit(
        toggleReactionUseCase: sl<ToggleArticleReactionUseCase>(),
      ));

  // Edit Article Cubit
  sl.registerFactory<EditArticleCubit>(() => EditArticleCubit(
        updateArticleUseCase: sl<UpdateArticleUseCase>(),
      ));
}
