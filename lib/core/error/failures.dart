/// Sealed failure hierarchy surfaced to the presentation layer
/// (ARCHITECTURE.md §6.4).
sealed class AppFailure {
  const AppFailure(this.message);

  final String message;
}

class ServerFailure extends AppFailure {
  const ServerFailure([super.message = 'Terjadi kesalahan pada server.']);
}

class CacheFailure extends AppFailure {
  const CacheFailure([
    super.message = 'Terjadi kesalahan pada penyimpanan lokal.',
  ]);
}

class NetworkFailure extends AppFailure {
  const NetworkFailure([super.message = 'Tidak ada koneksi internet.']);
}

class AuthFailure extends AppFailure {
  const AuthFailure([
    super.message = 'Sesi login berakhir. Silakan masuk kembali.',
  ]);
}

class OcrParsingFailure extends AppFailure {
  const OcrParsingFailure([super.message = 'Gagal membaca struk.']);
}

class ValidationFailure extends AppFailure {
  const ValidationFailure(super.message);
}
