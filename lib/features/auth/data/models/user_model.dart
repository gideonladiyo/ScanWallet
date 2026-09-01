import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/entities/user_entity.dart';

/// Maps Supabase auth user payloads to [UserEntity].
class UserModel {
  const UserModel._();

  static UserEntity fromAuthUser(User user) {
    return UserEntity(
      id: user.id,
      email: user.email ?? '',
      fullName: user.userMetadata?['full_name'] as String?,
      emailConfirmed: user.emailConfirmedAt != null,
    );
  }

  static UserEntity? fromSession(Session? session) {
    if (session == null) return null;
    return fromAuthUser(session.user);
  }
}
