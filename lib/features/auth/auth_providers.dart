import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'data/datasources/auth_remote_datasource.dart';
import 'data/repositories/auth_repository_impl.dart';
import 'domain/repositories/auth_repository.dart';
import 'domain/usecases/get_current_session_usecase.dart';
import 'domain/usecases/google_login_usecase.dart';
import 'domain/usecases/login_usecase.dart';
import 'domain/usecases/logout_usecase.dart';
import 'domain/usecases/register_usecase.dart';

// Feature-level DI wiring (ARCHITECTURE.md §6.1).
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(ref.watch(authRemoteDatasourceProvider));
});

final loginUsecaseProvider = Provider<LoginUsecase>(
  (ref) => LoginUsecase(ref.watch(authRepositoryProvider)),
);

final registerUsecaseProvider = Provider<RegisterUsecase>(
  (ref) => RegisterUsecase(ref.watch(authRepositoryProvider)),
);

final googleLoginUsecaseProvider = Provider<GoogleLoginUsecase>(
  (ref) => GoogleLoginUsecase(ref.watch(authRepositoryProvider)),
);

final logoutUsecaseProvider = Provider<LogoutUsecase>(
  (ref) => LogoutUsecase(ref.watch(authRepositoryProvider)),
);

final getCurrentSessionUsecaseProvider = Provider<GetCurrentSessionUsecase>(
  (ref) => GetCurrentSessionUsecase(ref.watch(authRepositoryProvider)),
);
