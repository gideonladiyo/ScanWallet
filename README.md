# ScanWallet

ScanWallet is an offline-first Flutter finance tracker with on-device receipt
OCR, multi-account wallets, categories, and an analytics dashboard. Supabase
provides optional cloud sync, authentication, PostgreSQL, and row-level
security (RLS).

## Features

- Receipt scanning with on-device ML Kit OCR
- Offline transaction queue with automatic sync when connectivity returns
- Multiple accounts, categories, balances, and analytics
- Email/password and Google sign-in through Supabase Auth
- Supabase triggers for default data and account balance updates

## Requirements

- Flutter 3.32+ / Dart 3.8+
- Android Studio (Android) or Xcode (iOS)
- A [Supabase](https://supabase.com) project

## Setup

### 1. Configure Supabase

Create a Supabase project, then run [`supabase/schema.sql`](supabase/schema.sql)
in the Supabase SQL Editor. The script creates the tables, triggers, default
accounts/categories, and RLS policies.

### 2. Install dependencies

```bash
flutter pub get
```

### 3. Run code generation (after editing Freezed entities)

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### 4. Run the app

Copy `.env.example` to `.env` at the project root. The real `.env` is ignored
by Git and must never be committed. Fill it in:

```env
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your-anon-key
GOOGLE_WEB_CLIENT_ID=your-web-client-id   # optional, for Google Sign-In
```

Then run:

```bash
flutter run --dart-define-from-file=.env
```

`GOOGLE_WEB_CLIENT_ID` is optional; provide the Web OAuth client ID from Google
Cloud Console to enable Google Sign-In. Keep Supabase email confirmation
enabled if you want users to verify their email after registration.

Credentials are never hardcoded — they only enter the build via `.env` +
`--dart-define-from-file` (see `lib/core/config/app_config.dart`).

### 5. (Optional) Google Sign-In

Create the required Web, Android, and iOS OAuth clients in Google Cloud
Console, enable the Google provider in Supabase, and configure the native
client IDs/URL schemes in the platform projects.

## Verification

```bash
flutter analyze   # static analysis (0 issues expected)
flutter test      # unit tests: OCR parser, formatters, Result, models
```

## Architecture

Clean Architecture + Feature-First structure with Riverpod state management.

```
lib/
├── core/          # config, constants, errors, network, theme, router, shared widgets
└── features/
    ├── auth/          # Supabase email/password auth
    ├── accounts/      # wallets & balances (updated by DB triggers)
    ├── categories/    # income/expense categories
    ├── transactions/  # CRUD + offline queue (pending_sync)
    ├── scanner/       # ML Kit OCR + regex parser (GoPay/ShopeePay/DANA/QRIS/mBanking/struk)
    └── dashboard/     # balance summary + category breakdown charts
```

### Offline-first behavior

- Scanning runs fully on-device (ML Kit) and works without internet.
- Transactions created offline are queued locally (`pending_sync` badge in
  the UI) and pushed to Supabase automatically when connectivity returns.
- Reads fall back to a locally cached copy when offline.

### Security notes

- Only `SUPABASE_URL`, the publishable/anon key, and the optional Google Web
  client ID belong in the client environment. Never use a Supabase
  `service_role`/secret key in the app.
- The local `.env` and internal `/agent` notes are excluded by `.gitignore`.
- RLS policies in `supabase/schema.sql` are part of the security boundary;
  review them before changing access rules.

### Notes

- The Inter font family is referenced by the theme but not bundled; add the
  font files under `assets/fonts/` and register them in `pubspec.yaml` if the
  exact typography is needed.
- Saldo akun tidak pernah ditulis langsung oleh Dart — semua update saldo
  dilakukan oleh trigger database (`update_account_balance`).

## Versioning

The app version is maintained in `pubspec.yaml` using `major.minor.patch+build`.
User-facing changes are recorded in [`CHANGELOG.md`](CHANGELOG.md). To mark a
release in Git:

```bash
git tag -a v1.0.0 -m "Initial release"
git push origin v1.0.0
```

GitHub will then show the tag as a release starting point.

### Downloadable APK releases

The workflow in [`.github/workflows/release.yml`](.github/workflows/release.yml)
builds an Android APK and attaches it to a GitHub Release whenever a `v*.*.*`
tag is pushed. Before the first release, add these repository secrets under
**Settings → Secrets and variables → Actions**:

- `SUPABASE_URL`
- `SUPABASE_ANON_KEY`
- `GOOGLE_WEB_CLIENT_ID` (optional)

Then push the branch and tag:

```bash
git push -u origin main
git push origin v1.0.0
```

Users can download the APK from the repository's **Releases** page.

## Progress

The initial implementation is complete; see [`CHANGELOG.md`](CHANGELOG.md) for
the current release summary.
