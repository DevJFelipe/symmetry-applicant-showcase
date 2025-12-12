# Database Schema

## Table of Contents

1. [Introduction](#1-introduction)
2. [Data Model](#2-data-model)
   - 2.1 [Articles Collection](#21-articles-collection)
   - 2.2 [Reactions System](#22-reactions-system)
3. [Cloud Storage](#3-cloud-storage)
4. [Authentication](#4-authentication)
5. [Security Rules](#5-security-rules)
6. [Design Decisions](#6-design-decisions)
7. [Query Patterns](#7-query-patterns)
8. [Document Examples](#8-document-examples)

---

## 1. Introduction

This document specifies the database schema for the News Application's journalist functionality. The schema is designed for Firebase Cloud Firestore, a NoSQL document database, and follows the architectural principles defined in `APP_ARCHITECTURE.md`.

### Scope

The schema covers:

- Article storage and retrieval for the news feed
- **Reaction system for user engagement**
- Media file organization in Cloud Storage
- User authentication data structure
- Security rules for data access control

### Technologies

| Component | Technology |
|:----------|:-----------|
| Database | Firebase Cloud Firestore |
| File Storage | Firebase Cloud Storage |
| Authentication | Firebase Authentication (Email/Password) |

---

## 2. Data Model

### 2.1 Articles Collection

The `articles` collection stores all news articles created by authenticated journalists.

**Collection Path:** `/articles/{articleId}`

#### Document Structure

| Field | Type | Description | Required | Constraints |
|:------|:-----|:------------|:--------:|:------------|
| `title` | `string` | Article headline | Yes | 1-200 characters |
| `description` | `string` | Brief summary for feed display | Yes | 1-500 characters |
| `content` | `string` | Full article body | Yes | Min 1 character |
| `author` | `string` | Author display name | Yes | 1-100 characters |
| `userId` | `string` | Firebase Auth UID of the creator | Yes | Must match authenticated user |
| `urlToImage` | `string` | Cloud Storage download URL | Yes | Valid URL format |
| `url` | `string` | External article URL | No | Valid URL format |
| `source` | `string` | Article source name (e.g., "TechCrunch") | No | 1-100 characters |
| `reactions` | `map` | Reaction counts by type | No | See [Reactions System](#22-reactions-system) |
| `userReactions` | `map` | User IDs who reacted by type | No | See [Reactions System](#22-reactions-system) |
| `publishedAt` | `Timestamp` | Publication date and time | Yes | Firestore Timestamp |
| `createdAt` | `Timestamp` | Document creation timestamp | Yes | Firestore Timestamp |

#### Field Specifications

**title**
- Primary identifier for user-facing display
- Used in search functionality
- Should be concise and descriptive

**description**
- Displayed in article cards on the feed
- Provides context without requiring full article load
- Optimizes initial page load performance

**content**
- Full article text
- May contain plain text or formatted content
- No maximum length enforced at database level

**author**
- Human-readable author name
- Separate from `userId` for display flexibility
- Can be updated independently of authentication data

**userId**
- Links article to Firebase Authentication user
- Used for authorization in security rules
- Immutable after document creation

**urlToImage**
- Full download URL from Cloud Storage
- Format: `https://firebasestorage.googleapis.com/v0/b/{bucket}/o/{path}?alt=media`
- Referenced image stored in `/thumbnails/` directory

**source**
- Optional field for article attribution
- Display name of the news source
- Useful for aggregated or syndicated content

**publishedAt**
- Primary sort field for feed queries
- Enables chronological article ordering
- Supports pagination with `startAfter` queries

**createdAt**
- Audit field for document lifecycle tracking
- Set once at document creation
- Immutable after creation

---

### 2.2 Reactions System

The reactions system allows users to express engagement with articles through predefined reaction types.

#### Supported Reaction Types

| Type | Emoji | Description |
|:-----|:------|:------------|
| `fire` | 🔥 | Trending/Hot content |
| `love` | ❤️ | Love/Appreciate |
| `thinking` | 🤔 | Thought-provoking |
| `sad` | 😢 | Sad/Emotional |
| `clap` | 👏 | Applause/Well done |

#### Reactions Field Structure

**`reactions`** - Aggregated count of reactions by type

```json
{
  "reactions": {
    "fire": 15,
    "love": 42,
    "thinking": 8,
    "sad": 3,
    "clap": 27
  }
}
```

| Property | Type | Description |
|:---------|:-----|:------------|
| `fire` | `number` | Count of fire reactions |
| `love` | `number` | Count of love reactions |
| `thinking` | `number` | Count of thinking reactions |
| `sad` | `number` | Count of sad reactions |
| `clap` | `number` | Count of clap reactions |

**`userReactions`** - Tracks which users have reacted with each type

```json
{
  "userReactions": {
    "fire": ["uid123", "uid456", "uid789"],
    "love": ["uid123", "uid999"],
    "clap": ["uid456"]
  }
}
```

| Property | Type | Description |
|:---------|:-----|:------------|
| `{reactionType}` | `array<string>` | List of user UIDs who reacted with this type |

#### Reaction Operations

All reaction updates are handles via **Transactions** to ensure consistency between the `reactions` count map and the `userReactions` user list map.

**Toggle Logic**:
1. Read the document within a transaction.
2. Check if user has already reacted.
   - If **Same Reaction**: Remove user from `userReactions.{type}` and decrement `reactions.{type}`.
   - If **Different Reaction**: Remove old reaction (decrement old count) and add new reaction (increment new count).
   - If **No Reaction**: Add user to `userReactions.{type}` and increment `reactions.{type}`.
3. Write the updated maps back to the document.

**Transaction Example**:

```javascript
firestore.runTransaction(async (transaction) => {
  const doc = await transaction.get(docRef);
  // ... calculate new state ...
  transaction.update(docRef, {
    'reactions': newReactionsMap,
    'userReactions': newUserReactionsMap
  });
});
```

#### Design Considerations

- **Embedded in Article Document**: Reactions are stored within the article document for efficient single-read access
- **User Tracking**: `userReactions` allows checking if current user has reacted without additional queries
- **Consistency**: Using Firestore Transactions prevents race conditions and ensures synchronization
- **Privacy Trade-off**: User IDs in `userReactions` are visible to anyone reading the article; acceptable for this use case

---

### 2.3 External Article Reactions Collection

The `article_reactions` collection stores reactions for external news articles (those fetched from APIs) that do not exist in the main `articles` collection.

**Collection Path:** `/article_reactions/{articleId}`

#### Document ID Strategy
The `articleId` is generated by creating an **MD5 hash** of the external article's URL. This ensures a consistent, unique identifier for every URL.

#### Document Structure

| Field | Type | Description |
|:------|:-----|:------------|
| `articleUrl` | `string` | Original URL of the external article |
| `reactions` | `map` | Reaction counts by type |
| `userReactions` | `map` | User IDs who reacted by type |
| `createdAt` | `Timestamp` | Creation timestamp |
| `updatedAt` | `Timestamp` | Last update timestamp |

---

## 3. Cloud Storage

### Directory Structure

```text
/thumbnails
    /{filename}.{extension}
```

### Thumbnails Directory

**Path:** `thumbnails/{filename}.{extension}`

| Property | Specification |
|:---------|:--------------|
| Allowed MIME Types | `image/jpeg`, `image/png`, `image/webp`, `image/gif` |
| Maximum File Size | 5 MB (5,242,880 bytes) |
| Read Access | Public |
| Write Access | Authenticated users only |

### URL Format

Storage URLs follow the Firebase Cloud Storage format:

```text
https://firebasestorage.googleapis.com/v0/b/{bucket}/o/{encoded-path}?alt=media
```

Example:

```text
https://firebasestorage.googleapis.com/v0/b/starter-project-1319e.firebasestorage.app/o/thumbnails%2Farticle-001.jpg?alt=media
```

---

## 4. Authentication

### Provider

Firebase Authentication with Email/Password sign-in method.

### User Properties

Firebase Authentication automatically manages the following user properties:

| Property | Type | Description |
|:---------|:-----|:------------|
| `uid` | `string` | Unique identifier for the user |
| `email` | `string` | User's email address |
| `displayName` | `string` | User's display name (optional) |
| `emailVerified` | `boolean` | Email verification status |
| `creationTime` | `string` | Account creation timestamp |
| `lastSignInTime` | `string` | Last authentication timestamp |

### Authentication Flow

1. User registers with email and password
2. Firebase creates user record with unique UID
3. User signs in to obtain authentication token
4. Token is validated in security rules for protected operations

---

## 5. Security Rules

### Firestore Security Rules

#### Read Operations

| Operation | Permission | Condition |
|:----------|:-----------|:----------|
| `get` | Public | None |
| `list` | Public | None |

#### Write Operations

| Operation | Permission | Conditions |
|:----------|:-----------|:-----------|
| `create` | Authenticated | Schema validation, `userId == auth.uid` |
| `update` | Owner only | Schema validation, `userId == auth.uid`, `userId` immutable |
| `delete` | Owner only | `userId == auth.uid` |

#### Schema Validation

The following validations are enforced on create and update operations:

- All required fields must be present
- Field types must match specification
- String fields must meet length constraints
- `publishedAt` and `createdAt` must be Firestore Timestamps
- `userId` must be a non-empty string

### Storage Security Rules

#### Read Operations

| Path | Permission |
|:-----|:-----------|
| `thumbnails/{file}` | Public |

#### Write Operations

| Path | Permission | Conditions |
|:-----|:-----------|:-----------|
| `thumbnails/{file}` | Authenticated | Valid image type, size < 5MB |

---

## 6. Design Decisions

### 6.1 Firestore Native Timestamps

**Decision:** Use Firestore `Timestamp` type instead of ISO 8601 strings.

**Rationale:**

| Aspect | Timestamp | ISO 8601 String |
|:-------|:----------|:----------------|
| Query Performance | Native indexing | String comparison |
| Range Queries | Optimized | Less efficient |
| Storage Size | Compact | Larger |
| Timezone Handling | Automatic | Manual parsing required |

### 6.2 Document ID Strategy

**Decision:** Use Firestore auto-generated document IDs.

**Rationale:**

- Guaranteed uniqueness without additional logic
- No collision risk in distributed writes
- Follows Firestore best practices
- Document ID accessible via `document.id` in queries

### 6.3 Media Separation

**Decision:** Store images in Cloud Storage, reference by URL in Firestore.

**Rationale:**

- Firestore document size limit: 1 MiB
- Cloud Storage optimized for binary data
- Direct URL access for efficient image loading
- Separate scaling for database and media storage

### 6.4 Flat Author Field

**Decision:** Store author name as string field, not embedded object.

**Rationale:**

- Matches existing `ArticleEntity` structure in the application
- Simpler security rules validation
- Direct mapping to domain layer entities
- Author updates independent of user profile changes

### 6.5 User Ownership Model

**Decision:** Use `userId` field for ownership, validate against `auth.uid`.

**Rationale:**

- Standard Firebase pattern for user-owned resources
- Enables security rules without additional queries
- Supports future multi-author scenarios
- Clear separation of display name (`author`) and ownership (`userId`)

---

## 7. Query Patterns

### Feed Query (Paginated)

Retrieve articles ordered by publication date, paginated:

```javascript
firestore
  .collection('articles')
  .orderBy('publishedAt', 'desc')
  .limit(10)
  .startAfter(lastDocumentSnapshot)
```

### User Articles Query

Retrieve articles by specific user:

```javascript
firestore
  .collection('articles')
  .where('userId', '==', userId)
  .orderBy('publishedAt', 'desc')
```

### Single Article Query

Retrieve single article by ID:

```javascript
firestore
  .collection('articles')
  .doc(articleId)
  .get()
```

### Recommended Indexes

| Fields | Order | Use Case |
|:-------|:------|:---------|
| `publishedAt` | Descending | Feed pagination |
| `userId`, `publishedAt` | Ascending, Descending | User articles list |

---

## 8. Document Examples

### Complete Article Document (with Reactions)

```json
{
  "title": "Flutter 4.0 Released with Major Performance Improvements",
  "description": "Google announces Flutter 4.0 with significant rendering optimizations and new Material 3 components.",
  "content": "Flutter 4.0 represents a major milestone in cross-platform development. The release includes a completely rewritten rendering engine that delivers up to 40% performance improvements on complex UIs. Additionally, the new Material 3 component library provides modern, accessible widgets out of the box.\n\nKey highlights include:\n- Impeller rendering engine now default on all platforms\n- New DevTools performance profiling capabilities\n- Improved hot reload reliability\n- Enhanced accessibility features",
  "author": "Jane Developer",
  "userId": "abc123def456ghi789",
  "urlToImage": "https://firebasestorage.googleapis.com/v0/b/starter-project-1319e.firebasestorage.app/o/thumbnails%2Fflutter-4-announcement.jpg?alt=media",
  "url": "https://flutter.dev/blog/flutter-4-release",
  "source": "Flutter Blog",
  "reactions": {
    "fire": 15,
    "love": 42,
    "thinking": 8,
    "sad": 0,
    "clap": 27
  },
  "userReactions": {
    "fire": ["uid123", "uid456", "uid789"],
    "love": ["uid123", "uid999", "uid456"],
    "thinking": ["uid789"],
    "clap": ["uid123", "uid456"]
  },
  "publishedAt": {
    "_seconds": 1733833800,
    "_nanoseconds": 0
  },
  "createdAt": {
    "_seconds": 1733832000,
    "_nanoseconds": 0
  }
}
```

### Minimal Article Document (Required Fields Only)

```json
{
  "title": "Breaking News Headline",
  "description": "Brief description of the breaking news story.",
  "content": "Full article content goes here.",
  "author": "John Reporter",
  "userId": "xyz789abc123def456",
  "urlToImage": "https://firebasestorage.googleapis.com/v0/b/starter-project-1319e.firebasestorage.app/o/thumbnails%2Fbreaking-news.png?alt=media",
  "publishedAt": {
    "_seconds": 1733836000,
    "_nanoseconds": 0
  },
  "createdAt": {
    "_seconds": 1733836000,
    "_nanoseconds": 0
  }
}
```

---

## Revision History

| Version | Date | Author | Changes |
|:--------|:-----|:-------|:--------|
| 1.0 | 2025-12-09 | Felipe Andrade | Initial schema definition |
| 1.1 | 2025-12-11 | Felipe Andrade | Added Reactions System (reactions, userReactions fields), added source field |
| 1.2 | 2025-12-12 | Felipe Andrade | Added External Article Reactions collection and updated reaction toggle logic |
