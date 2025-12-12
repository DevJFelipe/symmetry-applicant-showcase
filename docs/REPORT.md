# 📋 Project Report: Symmetry Applicant Showcase App

> **Author:** Felipe Andrade  
> **Date:** December 11, 2025  
> **Project Duration:** ~72 hours  

---

## Table of Contents

1. [Introduction](#1-introduction)
2. [Learning Journey](#2-learning-journey)
3. [Challenges Faced](#3-challenges-faced)
4. [Reflection and Future Directions](#4-reflection-and-future-directions)
5. [Proof of Project](#5-proof-of-project)
6. [Overdelivery](#6-overdelivery)
7. [Technical Architecture](#7-technical-architecture)
8. [Final Thoughts](#8-final-thoughts)

---

## 1. Introduction

### Initial Impressions

When I first encountered this project, I felt both excited and challenged. The assignment was clear: *"You are a journalist who wants to upload articles to the app."* This simple premise opened the door to implementing a complete CRUD system with real-time database synchronization, user authentication, and a polished user interface.

### Personal Context

I approached this project with a solid foundation in Flutter development and a passion for clean, maintainable code. However, I had limited hands-on experience with:

- Flutter BLoC pattern for state management

This project represented an opportunity to not only demonstrate my existing skills but also to learn and apply new technologies in a production-grade manner.

### Project Vision

From the start, I committed to three principles that aligned with Symmetry's core values:

1. **Truth is King**: I would implement the architecture exactly as documented, without shortcuts
2. **Total Accountability**: Every line of code would be my responsibility, tested and reviewed
3. **Maximally Overdeliver**: I would go beyond the basic requirements to create something exceptional

---

## 2. Learning Journey

### Technologies Mastered

#### Flutter BLoC & Cubits

Before this project, I had used `setState` and `Provider` for state management. Learning BLoC required a paradigm shift:

**Resources Used:**
- [BLoc Library Docs](https://bloclibrary.dev/)
- [Flutter BLoc Technology Tutorial](https://youtube.com/playlist?list=PLB_RxclDAkeYBOTIJ8qUubHx9aQLoiHeM)
- [Kodeco BLoC Tutorial](https://www.kodeco.com/books/real-world-flutter-by-tutorials/v1.0/chapters/3-managing-state-with-cubits-the-bloc-library)

**Key Learning:** I discovered that Cubits are perfect for simpler state management (like form handling in `CreateArticleCubit`), while full BLoCs with events are better for complex flows (like `RemoteArticlesBloc` with its event-driven architecture).

```dart
// Example: Cubit for simple state management
class CreateArticleCubit extends Cubit<CreateArticleState> {
  CreateArticleCubit({required this.createArticleUseCase}) 
    : super(const CreateArticleInitial());
  
  Future<void> createArticle({...}) async {
    emit(CreateArticleLoading(message: 'Uploading image...'));
    // ... business logic
    emit(CreateArticleSuccess(article));
  }
}
```

#### Clean Architecture

The [tutorial by Flutter Guys](https://www.youtube.com/watch?v=7V_P6dovixg) was instrumental in understanding the layer separation:

| Layer | Responsibility | My Implementation |
|:------|:---------------|:------------------|
| **Domain** | Business logic, entities, use cases | Pure Dart, no Flutter dependencies |
| **Data** | API calls, local storage, models | Firebase services, Floor database |
| **Presentation** | UI, state management | Widgets, Cubits, BLoCs |

**Key Insight:** The beauty of Clean Architecture is that each layer can be tested and modified independently. When I needed to add reactions to articles, I only had to:
1. Update the entity
2. Create a new use case
3. Add UI components

The data layer changes were isolated and didn't affect the presentation layer.

#### Firebase Ecosystem

I deepened my understanding of:
- **Firestore**: Document structure, queries, security rules
- **Cloud Storage**: File uploads, URL generation
- **Authentication**: Email/password flow, user state management

**Resource:** [Firebase Firestore w/ Flutter Tutorial](https://www.youtube.com/playlist?list=PLB_RxclDAkeZhz0ZAJSfPrrPzt8r10gO9)

---

## 3. Challenges Faced

### Challenge 1: Floor Database with Complex Types

**Problem:** The Floor ORM (local database) doesn't support complex types like `Map<String, int>` or custom objects like `SourceEntity`.

**Initial Approach:** I tried to make `ArticleModel` extend `ArticleEntity` as per the architecture guidelines.

**Solution:** I adopted a composition pattern instead of inheritance, clearly documenting the reasoning:

```dart
/// Model for local database storage using Floor.
/// 
/// This model does NOT extend ArticleEntity to avoid Floor trying to map
/// unsupported types (SourceEntity, Map). Uses composition instead of inheritance.
@Entity(tableName: 'article', primaryKeys: ['id'])
class ArticleModel {
  // ... fields that Floor can handle
  
  ArticleEntity toEntity() {...} // Conversion method
}
```

**Lesson Learned:** Architecture guidelines are important, but pragmatic solutions that maintain the spirit of the architecture (separation of concerns, layer isolation) are acceptable when technical constraints arise.

---

### Challenge 2: Reactions System for External Articles

**Problem:** The news feed combines both Firestore articles (which store reactions directly) and external API articles (which have no backend storage).

**Solution:** I created a separate `article_reactions` collection in Firestore to store reactions for external articles, keyed by their URL:

```
/article_reactions/{hashed_url}
  ├── articleUrl: string
  ├── reactions: { fire: 5, love: 3, ... }
  └── userReactions: { fire: [uid1, uid2], ... }
```

**Implementation:**
- Created `ReactionService` for external article reactions
- Created `ReactionRepository` interface and implementation
- Created `ToggleArticleReactionUseCase` specifically for external articles

---

### Challenge 3: State Synchronization

**Problem:** When a user reacts to an article and navigates back to the feed, the reaction counts should update.

**Solution:** I implemented a refresh-on-return pattern:

```dart
void _onArticleTapped(BuildContext context, ArticleEntity article) {
  Navigator.pushNamed(context, '/ArticleDetails', arguments: article).then((_) {
    // Refresh feed when returning from article detail
    bloc.add(const GetArticles());
  });
}
```

---

### Challenge 4: Image Upload Flow

**Problem:** Creating an article requires uploading an image first, then saving the article with the image URL.

**Solution:** I implemented a multi-step process with clear loading state messages:

```dart
Future<void> createArticle({...}) async {
  emit(CreateArticleLoading(message: 'Uploading image...'));
  final imageUrl = await _uploadImage(thumbnailFile, userId);
  
  emit(CreateArticleLoading(message: 'Creating article...'));
  final article = await createArticleUseCase.createWithUserData(...);
  
  emit(CreateArticleSuccess(article));
}
```

---

## 4. Reflection and Future Directions

### What I Learned

#### Technical Growth

1. **Clean Architecture Mastery**: I now truly understand why layer separation matters—it made adding the reactions feature surprisingly straightforward

2. **State Management Expertise**: BLoC/Cubit patterns are now second nature. I understand when to use events (complex flows) vs. direct methods (simple actions)

3. **Firebase Proficiency**: From security rules to composite indexes, I gained production-level Firebase skills

4. **Code Organization**: The feature-based folder structure (`features/{feature}/data|domain|presentation`) is now my default approach

#### Professional Growth

- **Working with Guidelines**: Following Symmetry's architecture violations document taught me the value of explicit coding standards
- **Documentation**: Creating the `DB_SCHEMA.md` helped me think through design decisions before coding
- **Self-Review**: Reviewing my own code against the guidelines improved my attention to detail

### Future Improvements

If I had more time, I would implement:

| Feature | Priority | Description |
|:--------|:---------|:------------|
| **Unit Tests** | High | TDD for all use cases and repositories |
| **Rich Text Editor** | Medium | Markdown or WYSIWYG for article content |
| **Push Notifications** | Medium | Notify users of reactions on their articles |
| **Offline Support** | Medium | Full offline-first with sync |
| **Comments System** | Low | Allow users to comment on articles |
| **Categories/Tags** | Low | Article classification system |

---

## 5. Proof of Project

### Project Structure

```
frontend/lib/
├── config/                          # App configuration
│   ├── routes/                      # Navigation routes
│   └── theme/                       # Design tokens (colors, typography, etc.)
├── core/                            # Core utilities
│   ├── constants/                   # API keys, default values
│   ├── error/                       # Exception handling
│   ├── resources/                   # DataState wrapper
│   ├── services/                    # Haptic, preferences
│   └── usecase/                     # Base UseCase interface
├── features/                        # Feature modules
│   ├── auth/                        # Authentication feature
│   │   ├── data/                    # Firebase Auth service, User model
│   │   ├── domain/                  # UserEntity, AuthRepository, UseCases
│   │   └── presentation/            # AuthCubit, Login/Register pages
│   └── daily_news/                  # News feature
│       ├── data/                    # API service, Firestore service, models
│       ├── domain/                  # ArticleEntity, repositories, 12 use cases
│       └── presentation/            # BLoCs, Cubits, 9 pages, widgets
├── shared/                          # Shared components
│   └── widgets/                     # Reusable UI components
├── firebase_options.dart            # Firebase configuration
├── injection_container.dart         # Dependency injection
└── main.dart                        # App entry point
```

### Key Screens Implemented

| Screen | Description |
|:-------|:------------|
| **Home Feed** | Bento Grid layout with animated cards, pull-to-refresh |
| **Article Detail** | Full article view with reactions, save functionality |
| **Create Article** | Form with image picker, validation, loading states |
| **Edit Article** | Pre-populated form for updating existing articles |
| **My Articles** | User's published articles with edit/delete options |
| **Profile** | User info, photo upload, tabbed Articles/Saved view |
| **Search** | Real-time search across all articles |
| **Saved Articles** | Locally saved articles for offline reading |
| **Settings** | App preferences (placeholder for future features) |

### Backend Implementation

**Firestore Collections:**
- `/articles/{articleId}` - User-created articles
- `/article_reactions/{urlHash}` - Reactions for external API articles

**Cloud Storage:**
- `/thumbnails/{filename}` - Article thumbnail images

**Security Rules:** Comprehensive validation with helper functions for schema enforcement and reaction updates.

---

## 6. Overdelivery

### 6.1 New Features Implemented

#### 🔥 Reactions System

**Functionality:** Users can react to any article with 5 reaction types (🔥 Fire, ❤️ Love, 🤔 Thinking, 😢 Sad, 👏 Clap).

**Technical Implementation:**
- Reactions stored directly in article documents for Firestore articles
- Separate `article_reactions` collection for external API articles
- Atomic updates using `FieldValue.increment()` and `arrayUnion()`/`arrayRemove()`
- Real-time UI updates with optimistic state management

**Files Created:**
- `domain/entities/article.dart` - Added `ArticleReaction` enum
- `domain/usecases/toggle_reaction.dart` - For Firestore articles
- `domain/usecases/toggle_article_reaction.dart` - For external articles
- `data/data_sources/reaction_service.dart` - Firestore operations
- `presentation/bloc/article_detail/article_detail_cubit.dart`

---

#### 🎨 Premium UI with Bento Grid

**Functionality:** A modern, asymmetric grid layout inspired by Apple's design language.

**Features:**
- Staggered card sizes (large featured card, medium pair cards)
- Animated card entrance with stagger effect
- Press feedback with scale animation
- Glassmorphism overlays
- Shimmer loading skeletons

**Files Created:**
- `presentation/widgets/bento_article_grid.dart`
- `presentation/widgets/animated_bento_card.dart`
- `shared/widgets/shimmer_loading.dart`
- `shared/widgets/glass_modal.dart`

---

#### 👤 Profile Management

**Functionality:** Complete user profile with photo upload and tabbed content view.

**Features:**
- Profile photo upload (camera or gallery)
- Display name and email from Firebase Auth
- Tabs for "Articles" (user's published) and "Saved" (bookmarked)
- Sign out with confirmation modal

**Files Created:**
- `auth/domain/usecases/update_profile_photo.dart`
- `auth/data/data_sources/profile_storage_service.dart`
- `presentation/pages/profile/profile_page.dart`

---

#### 🔍 Search Functionality

**Functionality:** Search across all articles (both Firestore and API).

**Technical Implementation:**
- Debounced search input (300ms)
- Searches title, description, and author
- Combined results from both data sources
- Empty state handling

**Files Created:**
- `presentation/bloc/search/search_cubit.dart`
- `presentation/pages/search/search_page.dart`

---

#### 📱 Haptic Feedback

**Functionality:** Tactile feedback for user interactions.

**Implementation:**
- Light impact for taps
- Medium impact for long press
- Success pattern for completed actions

**Files Created:**
- `core/services/haptic_service.dart`

---

### 6.2 Design Enhancements

| Enhancement | Description |
|:------------|:------------|
| **Theme System** | Complete design token system managed by `AppTheme` and `ThemeCubit`. Supports dynamic light/dark mode switching with persistent user preference. Implemented `AppColorsLight` for a clean, professional aesthetic while maintaining the app's premium feel. Global state management using `BlocBuilder` ensures instant UI updates. |
| **Dark Mode Ready** | Color system supports dark mode extension |
| **Responsive Layout** | Adapts to different screen sizes |
| **Loading States** | Shimmer skeletons, premium spinners, loading overlays |
| **Empty States** | Friendly illustrations for empty content |
| **Error States** | Actionable error messages with retry options |

---

### 6.3 How Can This Be Improved Further

#### Short Term (1-2 weeks)
- Add unit tests for all use cases and repositories
- Implement image caching with `cached_network_image`
- Add article draft saving (auto-save)

#### Medium Term (1 month)
- Rich text editor for article content
- Push notifications for reactions
- Article analytics (view count, read time)

#### Long Term (3+ months)
- Comments and replies system
- User following/followers
- Content moderation tools
- Multi-language support

---

## 7. Technical Architecture

### Clean Architecture Compliance

I strictly followed Symmetry's architecture guidelines as documented in `APP_ARCHITECTURE.md`:

```
✅ Presentation Layer → Only imports from Domain Layer
✅ Domain Layer → Pure Dart (except equatable package)
✅ Data Layer → Implements Domain interfaces
```

### Dependency Injection

All dependencies are registered in `injection_container.dart`:

```dart
// Pattern: Data Sources → Repositories → Use Cases → Cubits/BLoCs
sl.registerSingleton<FirestoreArticleService>(FirestoreArticleService());
sl.registerSingleton<FirestoreArticleRepository>(
    FirestoreArticleRepositoryImpl(sl<FirestoreArticleService>()));
sl.registerSingleton<CreateArticleUseCase>(
    CreateArticleUseCase(sl<FirestoreArticleRepository>()));
sl.registerFactory<CreateArticleCubit>(() => CreateArticleCubit(
    createArticleUseCase: sl<CreateArticleUseCase>()));
```

### Layer Communication

```
┌─────────────────────────────────────────────────────────────┐
│                    PRESENTATION LAYER                        │
│  ┌─────────────┐    ┌─────────────┐    ┌─────────────┐     │
│  │   Widgets   │ ←→ │   Cubits    │ ←→ │    Pages    │     │
│  └─────────────┘    └──────┬──────┘    └─────────────┘     │
└────────────────────────────┼────────────────────────────────┘
                             │ Uses
┌────────────────────────────┼────────────────────────────────┐
│                    DOMAIN  │ LAYER                          │
│  ┌─────────────┐    ┌──────┴──────┐    ┌─────────────┐     │
│  │  Entities   │ ←─ │  Use Cases  │ ─→ │ Repositories│     │
│  └─────────────┘    └─────────────┘    │ (interfaces)│     │
│                                         └──────┬──────┘     │
└────────────────────────────────────────────────┼────────────┘
                                                 │ Implements
┌────────────────────────────────────────────────┼────────────┐
│                    DATA LAYER                  │            │
│  ┌─────────────┐    ┌─────────────┐    ┌──────┴──────┐     │
│  │   Models    │ ←─ │Data Sources │ ←─ │  Repository │     │
│  └─────────────┘    └─────────────┘    │   Impls     │     │
│                                         └─────────────┘     │
└─────────────────────────────────────────────────────────────┘
```

---

## 8. Final Thoughts

This project was more than an assignment—it was a comprehensive learning experience that pushed me to adopt best practices and deliver production-quality code.

### Key Takeaways

1. **Architecture Matters**: Clean Architecture isn't overhead; it's investment in maintainability
2. **Documentation Matters**: Writing `DB_SCHEMA.md` forced me to think through every design decision
3. **Guidelines Prevent Mistakes**: Following `ARCHITECTURE_VIOLATIONS.md` caught issues before they became problems
4. **Overdelivery Shows Character**: Going beyond requirements demonstrates commitment to excellence

### Gratitude

Thank you for this opportunity to showcase my skills. Whether or not this leads to a position at Symmetry, this project has made me a better developer.

---

*"We're not seeking your average Joe; we're on the hunt for authentic beasts."*  
*— Symmetry README*

I hope this project demonstrates that I'm ready to be part of that hunt.

---

**Felipe Andrade**  
December 2025
