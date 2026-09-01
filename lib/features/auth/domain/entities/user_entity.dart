import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_entity.freezed.dart';

/// Authenticated user profile (Freezed — AGENTS.md §3).
@freezed
class UserEntity with _$UserEntity {
  const factory UserEntity({
    required String id,
    required String email,
    String? fullName,

    /// True when Supabase reports `email_confirmed_at` — with "Confirm
    /// email" enabled a freshly registered user is false until they click
    /// the link, and no session is issued meanwhile.
    @Default(false) bool emailConfirmed,
  }) = _UserEntity;
}
