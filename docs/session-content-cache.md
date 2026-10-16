# Session content and report verification

Report Details, Profile, and Notifications reuse content in memory for the authenticated session. Report content is limited to 20 least recently accessed entries. Entries expire after 10 minutes without access. Profile and Notifications each retain their current content for the same idle period. No new disk cache or persisted verification cache is introduced; the existing offline report repository remains unchanged.

Reopening displays saved content immediately and refreshes in the background. Localized banners distinguish refreshing from an unsuccessful refresh. Failure preserves readable content. Route return, previously visited Profile/Notifications tabs, reconnect while resumed, and app resume trigger refresh. Backend permissions remain authoritative; citizen review requires freshly loaded details.

## Verification

The backend supplies `protected_snapshot_token` on details and verification and UTC `verified_at` on successful checks. Success is retained only for the displayed token with current content verified, no known original mismatch, an existing anchor, and no pending/unavailable condition. The timestamp describes the checked version, not continuous chain monitoring. Older backends without tokens cannot supply retained current proof.

After fresh details arrive, reuse matching memory proof, check the backend cache, then perform a full check automatically. A changed token removes old success and rejects late old-snapshot responses. Automatic and manual requests are deduplicated.

Pending anchoring/indexing and temporary RPC/IPFS failures retry after 10, 30, and 60 seconds, refreshing details first. Attempts then stop; confirmed mismatches do not retry automatically. Timers and late results are cancelled/ignored when the route is covered/disposed, the app backgrounds, the account changes, or the token changes. Return/resume refreshes details and restores a retry opportunity. Manual checks remain available.

`verification_pending=true` / `verify_status_reason=checkpoint_pending` means a queued protected update, not verification or mismatch. `scan_incomplete` means indexing is pending; RPC failures are unavailable checks. `ipfs_unreachable` is unavailable rather than evidence of altered content. Type 3 checkpoint history uses neutral wording because existing events do not identify AI versus staff reliably.

## Isolation and notifications

Logout, expired authentication, account/role/password-access changes, and KYC permission changes discard session caches. Responses keep their original cache scope and cannot publish data or widget unread counts after that scope closes. Realtime report events evict content and proof; profile events evict profile content. Notification events refresh first-page data/unread counts while preserving loaded history. Read actions update cache/widget counts after server success. Pagination saves the actual fetched page cursor and deduplicates IDs.

## Release and checks

Deploy the compatible backend first, then release Mobile. Historical integrity repair remains a separate reviewed operation. No production mutation or deployment is performed here.

Run `flutter analyze` and `flutter test` with the repository SDK. Tests cover cache bounds/expiry, isolation, failures, snapshot rejection, retry timing, lifecycle cancellation, pending UI, pagination, unread counts, and late-account responses. Physical-device behavior and deployed end-to-end checks still need release-environment validation.
