# Changelog

All notable user-facing changes to ScanWallet are recorded here.

## [1.0.0] - 2026-09-01

### Added

- Offline-first personal finance tracking with multiple accounts and categories.
- On-device receipt OCR for common payment and receipt formats.
- Supabase email/password and optional Google authentication.
- Offline transaction queue with retry and automatic synchronization.
- Dashboard with balances, recent transactions, and category analytics.
- Supabase schema with RLS, default user data, and balance-update triggers.
- Motion and reduced-motion support across the main app flows.

### Security

- Runtime credentials are supplied through the local, gitignored `.env` file.
- The application uses only the Supabase publishable/anon key; no service-role
  key belongs in the client or database schema.
