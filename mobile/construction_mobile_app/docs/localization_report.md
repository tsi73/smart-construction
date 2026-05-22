# Localization Report

## Supported Languages
- **English (en)**: Default
- **Amharic (am)**: Ethiopia Local Language (አማርኛ)

## Localized Screens
| Screen | English | Amharic | Notes |
| :--- | :--- | :--- | :--- |
| **Splash** | ✅ | ✅ | Title localized |
| **Login** | ✅ | ✅ | All labels & buttons |
| **Register** | ✅ | ✅ | Phone validation added |
| **Project List** | ✅ | ✅ | Title & Empty states |
| **Settings** | ✅ | ✅ | Selection UI localized |
| **Daily Log Wizard** | ✅ | ✅ | Core step titles |
| **Sync/Offline** | ✅ | ✅ | Banners & Statuses |

## Settings Features
- **Language Switcher**: Works instantly and persists via `SharedPreferences`.
- **Theme Switcher**: Supports Light/Dark/System modes.
- **Calendar Preference**: Toggle between Gregorian and Ethiopian (Display-only logic).

## Ethiopia-Specific Formatting
- **Currency**: `ETB 1,250.00` format implemented in `EthiopiaFormatters`.
- **Phone Validation**: Supports `+251`, `09`, `07` formats for Ethiopia.
- **City Suggestions**: Major Ethiopian cities (Addis, Adama, etc.) provided in utils.

## Calendar Support
- **Implementation**: **Partial (UI-Only)**.
- **Status**: Preference persists, but full date conversion logic is pending a reliable package addition. Backend still receives Gregorian ISO strings.

## Translation Review Notes
- Amharic translations used natural phrasing (e.g., "ሪፖርት አስገባ" for Submit Log).
- Some technical terms like "Sync" kept as "አመሳስል" (Synchronize).

## Known Limitations
1. **Ethiopian Calendar Logic**: No external package was available for reliable conversion during this turn. UI toggle exists but logic defaults to Gregorian display for now.
2. **Font Overflow**: Amharic characters are taller; verified standard card heights, but dense lists might need expansion.
