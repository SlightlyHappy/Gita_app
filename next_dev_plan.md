# Bhagavad Gita App - Development Roadmap & PRD

**Created:** February 11, 2026  
**Status:** Active Development  
**Last Updated:** Feb 11, 2026

---

## Overview

This PRD outlines the complete functionality assessment results and all required implementations to make the Bhagavad Gita app fully functional. Organized into phases, with clear acceptance criteria and architectural decisions documented.

---

## Phase 0: UI/UX Cleanup & Simplification

### 0.1 Remove Voice Search
- **Status:** ⬜ Not Started
- **Files:** `lib/screens/home_screen.dart`
- **Changes:**
  - Remove microphone icon from search bar
  - Remove audio placeholder UI elements
  - **Acceptance:** Search bar only has search icon + text input

### 0.2 Remove Notification Center
- **Status:** ⬜ Not Started
- **Files:** `lib/screens/home_screen.dart`
- **Changes:**
  - Remove notification bell icon from home header
  - Remove any notification dropdown/center UI if exists
  - **Acceptance:** Home header shows only: user avatar, daily greeting, search bar

### 0.3 Remove Settings Icon from User Journey Screen
- **Status:** ⬜ Not Started
- **Files:** `lib/screens/user_journey_screen.dart`
- **Changes:**
  - Remove settings icon from header (top right)
  - Keep back button and user info section
  - Navigation to settings should only be via bottom nav bar
  - **Acceptance:** User Journey header shows: back button, avatar, user info (no settings icon)

---

## Phase 1: Core Missing Functionality

### 1.1 Push Notification System (Daily Quotes)
- **Status:** ⬜ Not Started
- **Files:** 
  - `pubspec.yaml` (add package)
  - `lib/services/notification_service.dart` (new)
  - `lib/screens/app_settings_screen.dart` (integrate)
  - Android: `android/app/src/main/AndroidManifest.xml`
  - iOS: `ios/Runner/Info.plist`

- **Requirements:**
  - Add `flutter_local_notifications` package
  - Create NotificationService singleton
  - Schedule daily notification at user-selected time (from settings)
  - Fetch verse of the day (Chapter 2 Verse 47 or random verse)
  - Display verse text + author in notification body
  - On tap: Open app to verse detail screen
  
- **Implementation Details:**
  - Initialize notifications on app startup
  - Permission checks for Android 13+ and iOS
  - Update notification on time change in settings
  - Cancel old notification before scheduling new one
  - Store notification schedule in SharedPreferences

- **Acceptance Criteria:**
  - ✅ Notification appears at user-selected time
  - ✅ Contains verse of the day with proper formatting
  - ✅ Tapping opens verse detail screen
  - ✅ Time change in settings updates notification schedule
  - ✅ Works on both Android & iOS
  - ✅ Request notification permissions on app first launch

### 1.2 Wire "Rate the App" Button
- **Status:** ⬜ Not Started
- **Files:** `lib/screens/app_settings_screen.dart`
- **Changes:**
  - Replace empty `onTap: () {}` with actual implementation
  - Use `in_app_review` package OR
  - Direct link to Play Store/App Store using `url_launcher`
  
- **Acceptance:** Button opens app store rating page

### 1.3 Wire "Share with Friends" Button
- **Status:** ⬜ Not Started
- **Files:** `lib/screens/app_settings_screen.dart`
- **Packages:** `share_plus` (already installed)
- **Changes:**
  - Implement share functionality with app promotion text
  - Share app link (optional: deep link to specific verse)
  
- **Acceptance:** Button opens native share sheet with pre-populated app message

### 1.4 Wire "Contact Support" Button
- **Status:** ⬜ Not Started
- **Files:** `lib/screens/app_settings_screen.dart`
- **Packages:** `url_launcher` (new)
- **Changes:**
  - On tap: Open email client with pre-filled address: `admin@bearsystems.in`
  - Pre-fill subject: "Bhagavad Gita App - Support Request"
  - Pre-fill body with device info (email, app version)
  
- **Acceptance:** Button opens mail client with correct pre-filled fields

---

## Phase 2: Bookmark System Unification

### 2.1 Rename Favorites to Bookmarks (Semantic)
- **Status:** ⬜ Not Started
- **Files:**
  - `lib/providers/app_state_provider.dart` (refactor variable names)
  - `lib/screens/favorites_screen.dart` → rename or refactor
  - UI constants/strings
  
- **Changes:**
  - Rename `_favoriteKeys` → `_bookmarkedVerses`
  - Rename `toggleFavorite()` → `toggleBookmark()`
  - Update all UI labels from "Saved/Favorites" → "Bookmarks"
  - Keep the same underlying functionality (persistence)
  
- **Acceptance:** App uses bookmark terminology consistently everywhere

### 2.2 Bookmark Icon Unification
- **Status:** ⬜ Not Started
- **Files:** Multiple screen files
- **Changes:**
  - Replace all heart icons (❤️) with bookmark icons (📌 or similar)
  - Locations: verse cards, verse detail, chapter verses list
  - Icon should be **filled** when bookmarked, **outlined** when not
  
- **Acceptance:** 
  - ✅ All "save/favorite" interactions use bookmark icon
  - ✅ Visual state clearly shows bookmarked vs unbookmarked

### 2.3 Bookmark Verses (Short Press)
- **Status:** ⬜ Not Started
- **Files:**
  - `lib/screens/verse_detail_screen.dart`
  - `lib/widgets/verse_card.dart`
  
- **Changes:**
  - Show bookmark icon on every verse
  - Tapping icon toggles bookmark state
  - Update icon fill state immediately (optimistic UI)
  - Persist to SharedPreferences via provider
  
- **Acceptance:**
  - ✅ Tap bookmark icon to save verse
  - ✅ Icon fill state updates instantly
  - ✅ Bookmarks persist across app restarts
  - ✅ Can unbookmark the same way

### 2.4 Verse Long-Press Context Menu
- **Status:** ⬜ Not Started
- **Files:**
  - `lib/screens/verses_screen.dart` (chapter verses list)
  - `lib/widgets/verse_card.dart` (new context menu)
  
- **Changes:**
  - Long-press on any verse in chapter view shows context menu with:
    1. **Bookmark** - Toggle bookmark state
    2. **Mark as Last Read** - Manually set last read location (see Phase 3)
    3. **Copy** - Copy verse text to clipboard
    4. **Share** - Share verse via share sheet
  
- **Implementation:**
  - Use `showModalBottomSheet` or custom context menu
  - Pass verse data to menu actions
  - Feedback should be clear (toast/snackbar)
  
- **Acceptance:**
  - ✅ Long-press shows 4-action menu
  - ✅ Each action works correctly
  - ✅ Menu dismisses after action
  - ✅ Visual feedback for each action

### 2.5 Bookmark Chapters
- **Status:** ⬜ Not Started
- **Files:**
  - `lib/screens/scriptures_overview_screen.dart`
  - `lib/widgets/chapter_card.dart` (if exists)
  
- **Changes:**
  - Add bookmark icon to chapter cards
  - Long-press chapter? Or short-press icon?
  - Same bookmark persistence logic as verses
  
- **Acceptance:**
  - ✅ Can bookmark/unbookmark chapters
  - ✅ Visual state reflects bookmark status

---

## Phase 3: Reading Tracking & Achievement System

### 3.1 Architecture: Reading Session Tracking

**Data Model Additions:**

```dart
// In app_state_provider.dart

class VerseReadingSession {
  final int chapterNumber;
  final int verseNumber;
  final DateTime readAt;
  final int durationSeconds; // time before marking as "read"
  
  // Constructor, toJson, fromJson
}

class ChapterProgress {
  final int chapterNumber;
  final Set<int> versesRead; // Set of verse numbers read
  final int totalTimeSeconds;
  final DateTime? lastReadAt;
  
  // Constructor, toJson, fromJson
}
```

**Provider Additions:**
- `List<VerseReadingSession> _readingSessions`
- `Map<int, ChapterProgress> _chapterProgressMap`
- `int _consecutiveAppOpenDays`
- `DateTime? _lastAppOpenDate`

**Persistence:**
- Save reading sessions to SharedPreferences (JSON)
- Save chapter progress map to SharedPreferences (JSON)
- Limit stored sessions to last 90 days to avoid storage bloat

### 3.2 Auto-Track Verse Reading (5-Second Rule)
- **Status:** ⬜ Not Started
- **Files:**
  - `lib/screens/verses_screen.dart` (new)
  - `lib/screens/verse_detail_screen.dart`
  - `lib/providers/app_state_provider.dart`
  
- **Requirements:**
  - When verse appears on screen → start idle timer
  - After 5 seconds of no scrolling → mark verse as read
  - Track which verses are visible in viewport
  - Use `Visibility` widget or similar to detect screen presence
  
- **Implementation:**
  - Use `ScrollNotificationListener` to detect scroll activity
  - Use `Timer` to track idle time per visible verse
  - Reset timer on scroll
  - When 5s idle → call `markVerseAsRead(chapter, verse)`
  - Visual feedback: subtle checkmark or highlight on read verses
  
- **Acceptance Criteria:**
  - ✅ Verse marked as read after 5 seconds of visibility + no scroll
  - ✅ Scrolling resets the timer
  - ✅ Returned to same verse: timer continues from where left off
  - ✅ Multiple verses on screen: each tracked independently
  - ✅ Reading sessions logged to provider

### 3.3 Manual "Mark as Last Read" Action
- **Status:** ⬜ Not Started
- **Files:**
  - `lib/screens/verses_screen.dart`
  - `lib/providers/app_state_provider.dart`
  
- **Requirements:**
  - Long-press context menu option: "Mark as Last Read"
  - Immediately updates `lastReadLocation` for that chapter
  - On returning to chapter: scroll to that verse automatically
  - Visual indicator shows current "last read" position
  
- **Implementation:**
  - Add `_lastReadLocation: Map<int, int>` (chapter → verse number)
  - Function: `markLastReadLocation(int chapter, int verse)`
  - On chapter open: auto-scroll to this location
  - Show faded highlight or "Last Read" label on that verse
  
- **Acceptance Criteria:**
  - ✅ Long-press context menu has "Mark as Last Read"
  - ✅ Last read location saved and persists
  - ✅ Next time opening chapter: auto-scrolls to that verse
  - ✅ Visual label/indicator shows last read position

### 3.4 Consecutive App Open Days Tracking
- **Status:** ⬜ Not Started
- **Files:**
  - `lib/providers/app_state_provider.dart`
  - `lib/main.dart` (init tracking on app start)
  
- **Implementation:**
  - On app startup: check if today is a new day vs `_lastAppOpenDate`
  - If new day AND yesterday was the last open → increment `_consecutiveAppOpenDays`
  - If >1 day gap → reset counter to 1
  - Save `_lastAppOpenDate` and `_consecutiveAppOpenDays` to SharedPreferences
  
- **Data:**
  - `int _consecutiveAppOpenDays`
  - `DateTime _lastAppOpenDate`
  
- **Acceptance Criteria:**
  - ✅ Counter increments for consecutive days
  - ✅ Resets if gap > 1 day
  - ✅ Persists across app restarts

### 3.5 Chapter Session Duration Tracking
- **Status:** ⬜ Not Started
- **Files:**
  - `lib/screens/verses_screen.dart`
  - `lib/providers/app_state_provider.dart`
  
- **Implementation:**
  - Start timer when user enters verses_screen for a chapter
  - Stop timer when user leaves (back button, nav change)
  - Add duration to `ChapterProgress.totalTimeSeconds`
  - Do NOT count paused sessions (app backgrounded)
  
- **Acceptance Criteria:**
  - ✅ Duration tracked per chapter
  - ✅ Resume doesn't double-count time
  - ✅ Visible in User Journey stats page

### 3.6 Achievement System - Unlockable Badges

**Achievement List (with unlock criteria):**

| Achievement | Unlock Criteria | Icon |
|-------------|-----------------|------|
| First Step | Read 1 verse | 👣 |
| Chapter Master | Complete 1 full chapter (all verses read) | 📖 |
| Seeker | Read 5 different chapters | 🔍 |
| Devoted Learner | Read 10 chapters | 🙏 |
| Wisdom Warrior | Read 15 chapters | ⚔️ |
| Complete Knowledge | Read all 18 chapters | 🌟 |
| Seven Day Sage | 7-day consecutive app opener | 🗓️ |
| Thirty Day Saint | 30-day consecutive app opener | 📅 |
| Bookmark Collector | Bookmark 10 verses | 📌 |
| Shared Wisdom | Share a verse 1 time | 🤝 |

**Data Structure:**

```dart
class Achievement {
  final String id;
  final String name;
  final String description;
  final String icon;
  final DateTime? unlockedAt;
  final Map<String, dynamic> criteria;
  
  bool get isUnlocked => unlockedAt != null;
}
```

- **Status:** ⬜ Not Started
- **Files:**
  - `lib/models/achievement_model.dart` (new)
  - `lib/providers/app_state_provider.dart` (extend)
  - `lib/screens/user_journey_screen.dart` (display)
  
- **Implementation:**
  - Check achievements every time tracking data updates
  - When criteria met → create Achievement with `unlockedAt` timestamp
  - Store achievements in SharedPreferences
  - Show locked AND unlocked achievements in UI
  - Locked show: icon + name + progress toward unlock
  
- **Acceptance Criteria:**
  - ✅ All 10 achievements defined
  - ✅ Unlock logic working correctly
  - ✅ Persistent across restarts
  - ✅ Locked achievements show progress
  - ✅ Unlocked achievements show unlock date

---

## Phase 4: API Caching & Local Search

### 4.1 Create Local Cache System
- **Status:** ⬜ Not Started
- **Files:**
  - `lib/services/local_cache_service.dart` (new)
  - `lib/models/bhagavad_gita_model.dart` (extend)
  
- **Implementation:**
  - On app startup: Load chapters from cache if available
  - After successful API fetch: Save response to cache
  - Cache timestamp + version info
  - Automatic refresh: if cache older than 24 hours, fetch fresh
  
- **Data Storage:**
  - Use `SharedPreferences` for chapters JSON
  - Use `SharedPreferences` for verses JSON (cache per chapter)
  - Limit cached data to reduce storage (e.g., no caching translations)
  
- **Acceptance Criteria:**
  - ✅ App loads chapters instantly from cache
  - ✅ Background refresh happens without UI lag
  - ✅ Stale cache is refreshed after 24 hours
  - ✅ Network errors fall back to cache gracefully

### 4.2 Fast Local Search Implementation
- **Status:** ⬜ Not Started
- **Files:**
  - `lib/screens/search_screen.dart` (already has search, refactor)
  - `lib/screens/scriptures_overview_screen.dart` (refactor filtering)
  
- **Changes:**
  - Take user input
  - Search against cached chapters locally (no network call)
  - Search fields: name, transliteration, meaning, summary, chapter number
  - Instant results as they type
  
- **Acceptance Criteria:**
  - ✅ Search returns results instantly
  - ✅ Works offline (using cache)
  - ✅ Searches all relevant fields
  - ✅ No visible lag on input

### 4.3 Dynamic Category Filtering
- **Status:** ⬜ Not Started
- **Files:**
  - `lib/screens/scriptures_overview_screen.dart`
  - `lib/providers/app_state_provider.dart`
  - `lib/utils/constants.dart` (add category mappings)
  
- **Current Issue:** Categories (Karma Yoga, Bhakti Yoga, etc.) do NOT come from API. App just checks if chapter name contains filter text—this is fragile.

- **Final Decision:** Use hardcoded category mappings based on traditional Bhagavad Gita structure (most reliable, well-known)
  
- **Implementation:**
  ```dart
  const Map<String, List<int>> chapterCategories = {
    'Karma Yoga': [2, 3, 4, 5, 6],
    'Bhakti Yoga': [9, 12],
    'Jnana Yoga': [2, 4, 7, 8, 13, 15],
    'Meditation': [6, 8, 12],
    'Wisdom': [10, 11],
  };
  ```
  - Filter displays only chapters in selected category
  - Combine with text search for sub-filtering within category
  - Chapters can belong to multiple categories (overlapping allowed)
  
- **Acceptance Criteria:**
  - ✅ Categories load from constants
  - ✅ Can combine category filter + text search
  - ✅ All 18 chapters assigned to at least 1 category
  - ✅ Visual feedback shows active filter
  - ✅ "All" filter option shows all chapters

---

## Phase 5: API Response Unification & Data Integrity

### 5.1 Handle API Inconsistencies
- **Status:** ⬜ Not Started
- **Files:**
  - `lib/services/api_service.dart`
  - `lib/models/bhagavad_gita_model.dart`
  
- **Issues to Fix:**
  - **Commentary:** API returns empty commentary fields
    - **Decision:** Remove commentary section entirely from UI (no value in display)
    - Method: Don't render commentary widget if field is empty
  - **Word Meanings:** API includes word-by-word meanings
    - **Decision:** Display word-by-word meanings below verse text (maximize API utility)
    - Method: Parse `word_meanings` array from API response
    - **UI needed:** Word meanings displayed in collapsible section below verse Sanskrit text
    - Format: Display as tooltip/expandable with word + meaning pairs
  - **Translations:** API returns array of translations (different authors)
    - **Decision:** Show primary translation + horizontal scrollable pills to switch between all available translations
    - Method: Create translation selector with iOS-style horizontal scroll
    - **UI needed:** Pills below verse text showing available translations (Swami Prabhupada selected by default)
    - Interaction: Tap pill to switch translation, smooth content transition
  
- **Implementation Plan:**
  - Create unified `VerseData` response handler
  - Parse `word_meanings` array from API and store in model
  - Normalize all verse fields consistently
  - Extend `Verse` model: add `wordMeanings: List<WordMeaning>`
  - Add `getPreferredTranslation()` helper (default to Swami Prabhupada)
  - Add `getAlternativeTranslations()` helper
  - Do NOT render commentary widget if empty
  
- **New Model:**
  ```dart
  class WordMeaning {
    final String word;
    final String meaning;
    final String? transliteration;
  }
  ```
  
- **Acceptance Criteria:**
  - ✅ Commentary section hidden when not available
  - ✅ Word-by-word meanings displayed below verse
  - ✅ Translation pills show all available translations
  - ✅ Default translation is primary one (Prabhupada)
  - ✅ Switching translations updates verse text smoothly
  - ✅ API response variations handled gracefully

---

## Phase 6: User Journey Screen Enhancements

### 6.1 Display Chapter Duration & Time Spent
- **Status:** ⬜ Not Started
- **Files:**
  - `lib/screens/user_journey_screen.dart`
  - New UI section for stats
  
- **Display:**
  - "Total time on Chapter X: Y hours, Z minutes"
  - Sortable by chapter or time spent (most-to-least)
  - Optional: Show time spent per day (chart view)
  
- **Acceptance Criteria:**
  - ✅ Stats visible and properly formatted
  - ✅ Accurate time calculations

### 6.2 Expanded Achievement Display
- **Status:** ⬜ Not Started
- **Files:**
  - `lib/screens/user_journey_screen.dart`
  
- **UI:**
  - Show all 10 achievements (locked + unlocked)
  - Locked: Show progress bar toward unlock (e.g., "Read 3/5 chapters")
  - Unlocked: Show unlock date
  - Click achievement for details
  
- **Acceptance Criteria:**
  - ✅ All achievements visible
  - ✅ Progress shown for locked
  - ✅ Unlock date shown for unlocked

### 6.3 Reading History Timeline
- **Status:** ⬜ Not Started
- **Files:**
  - `lib/screens/user_journey_screen.dart`
  
- **Display:**
  - Timeline of user activity (when they read specific verses/chapters)
  - Grouped by date
  - Show verse snippet + timestamp
  
- **Acceptance Criteria:**
  - ✅ Timeline entries chronological
  - ✅ Matches reading session data

---

## Summary of New Files to Create

1. `lib/services/notification_service.dart` - Push notification handling
2. `lib/services/local_cache_service.dart` - Local caching logic
3. `lib/models/achievement_model.dart` - Achievement data structures
4. `lib/models/reading_session_model.dart` - Reading tracking models
5. Updated constants and string resources for new features

---

## Summary of Dependencies to Add

- ✅ `flutter_local_notifications` - Push notifications
- ✅ `in_app_review` OR `url_launcher` - App rating
- ✅ `url_launcher` - Contact support (email)
- ✅ `share_plus` - Already installed, integrate
- ✅ `intl` - Already installed, use for date formatting

---

## Implementation Order (Recommended)

1. **Phase 0** (1-2 days) - UI cleanup, quick wins
2. **Phase 1** (3-4 days) - Push notifications + action buttons
3. **Phase 2** (2-3 days) - Bookmark system unification
4. **Phase 3** (5-7 days) - Reading tracking + achievements (most complex)
5. **Phase 4** (2 days) - API caching + local search
6. **Phase 5** (1-2 days) - Data unification
7. **Phase 6** (2 days) - UI enhancements

**Total Estimate:** 3-4 weeks for full implementation

---

## Testing Checklist

- [ ] Push notifications show at scheduled time (real device test)
- [ ] Bookmark/unbookmark works across all screens
- [ ] Reading tracking logs verses correctly (5-sec rule)
- [ ] Achievements unlock at correct criteria
- [ ] Consecutive days counter works
- [ ] Cache system reduces network calls
- [ ] Local search is instant
- [ ] All API data handled gracefully
- [ ] User Journey screen displays all stats
- [ ] App works offline with cache
- [ ] Settings changes persist across restarts

---

## Known Decisions & Rationale

| Decision | Rationale |
|----------|-----------|
| 5-second idle for marking verse "read" | Prevents accidental tracking; user must intentionally view verse |
| Immediate streak reset on missed day | Encourages consistent daily usage |
| 24-hour cache refresh | Balances freshness with offline capability |
| Both locked + unlocked achievements visible | Shows clear progression path to users |
| Auto-scroll to "last read" location | Improves UX for returning to chapters |
| Harcoded category mappings | API doesn't provide categories; traditional Gita structure is well-known |
| SharedPreferences for caching | Simple, sufficient for this app size; can upgrade to SQLite later |

---

## Status Tracking

- 🟥 **Not Started**
- 🟨 **In Progress**
- 🟩 **Complete**
- 🟦 **Blocked**

### Phase Completion:
- Phase 0: ⬜ 0%
- Phase 1: ⬜ 0%
- Phase 2: ⬜ 0%
- Phase 3: ⬜ 0%
- Phase 4: ⬜ 0%
- Phase 5: ⬜ 0%
- Phase 6: ⬜ 0%

---

## Notes for Development

- All timestamps should use UTC for consistency
- Test on both Android and iOS devices
- Use `riverpod` or `provider` patterns consistently (already using Provider)
- Keep UI responsive: use isolates for heavy calculations if needed
- Add loading states where network/cache sync happens
- Consider adding analytics to track feature usage

