# Offline Sync Audit

## Current Local Tables / Stores

- `daily_log_drafts`: Stores local drafts for daily logs. Includes JSON columns for nested entities (labor, materials, equipment, shifts).
- `tasks_cache`: Caches project tasks for offline reading.
- `CacheHelper`: Uses `SharedPreferences` for small key-value pairs (Auth tokens, settings, localized strings).

## Current Sync Queue Fields

Current `daily_log_drafts` sync metadata:
- `local_id`: Primary Key (Auto-increment).
- `server_id`: Nullable (populated after successful sync).
- `sync_status`: `pending_create`.
- `last_error`: Stores error messages from failed attempts.
- `created_at` / `updated_at`: Timestamps.

## Current Offline-Capable Features

- **Daily Log Drafts**: Site engineers can create and save logs locally while offline.
- **Task Reading**: Tasks are cached in SQLite for offline visibility.
- **Project Reading**: Project lists are partially cached via `CacheHelper`.
- **Theme/Language Persistence**: Handled via `CacheHelper`.

## Current Online-Only Features

- **Auth**: Login/Registration.
- **Project Creation**: PM action.
- **Team Management**: Invites, role updates, removals.
- **Daily Log Submission**: The final transition from draft to `submitted` is currently online-only in the repository logic.
- **Approvals**: PM/Consultant actions.

## Current Conflict Rules

- **Local-Only Drafts**: Local wins (no server record yet).
- **Existing Records**: Implicitly "Server Wins" as local edits to already-synced records aren't fully implemented/queued yet.

## Current Failure Handling

- Basic `try-catch` in repositories.
- `sync_status` is updated to 'failed' (implied in data source update method) but no exponential backoff or automated retry loop exists.

## Missing Pieces

- **Formal Sync Queue**: No central `sync_queue` table; metadata is scattered in entity tables.
- **Idempotency**: Risk of duplicate parent logs if children sync fails and retry logic is naive.
- **Offline Project Details**: Limited caching for the full project dashboard state.
- **Sync UI**: No dedicated "Sync Queue" or "Sync Status" screen for users to manage failures.
- **Child Entity Tracking**: Labor/Material/Equipment IDs are not individually tracked for sync status.

## Proposed Fixes

1.  **Harden SQLite Schema**: Add a dedicated `sync_queue` table or expand `daily_log_drafts` with more robust metadata (`attempt_count`, `last_attempt_at`).
2.  **Idempotent Sync Service**: Implement logic to use `server_id` if it exists, skipping parent creation on retry.
3.  **Sync Queue UI**: Build a screen under `Settings -> Sync Queue` to show pending/failed items.
4.  **Network Awareness**: Enhance `NetworkInfo` to trigger sync automatically on reconnection.
5.  **Offline Banners**: Add persistent "Offline Mode" indicators to the UI.
6.  **Conflict Resolution Doc**: Define rules for "rejected" logs and server-side changes.
