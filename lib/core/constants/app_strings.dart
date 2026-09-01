/// All user-facing strings (AGENTS.md §3 — no hardcoded UI strings in widgets).
class AppStrings {
  const AppStrings._();

  // App
  static const String appName = 'ScanWallet';
  static const String ok = 'OK';
  static const String cancel = 'Batal';
  static const String save = 'Simpan';
  static const String delete = 'Hapus';
  static const String edit = 'Edit';
  static const String retry = 'Coba Lagi';
  static const String all = 'Semua';
  static const String loading = 'Memuat...';
  static const String errorGeneric = 'Terjadi kesalahan. Coba lagi.';

  // Auth
  static const String loginTitle = 'Masuk';
  static const String loginSubtitle = 'Catat keuanganmu dalam sekali scan.';
  static const String registerTitle = 'Daftar';
  static const String registerSubtitle = 'Buat akun ScanWallet baru.';
  static const String emailLabel = 'Email';
  static const String emailHint = 'nama@email.com';
  static const String passwordLabel = 'Kata Sandi';
  static const String passwordHint = 'Minimal 6 karakter';
  static const String fullNameLabel = 'Nama Lengkap';
  static const String fullNameHint = 'Nama Anda';
  static const String loginButton = 'Masuk';
  static const String registerButton = 'Daftar';
  static const String logoutButton = 'Keluar';
  static const String googleButton = 'Lanjutkan dengan Google';
  static const String orDivider = 'atau';
  static const String checkEmailTitle = 'Cek Email Anda';
  static const String checkEmailBody =
      'Link konfirmasi telah dikirim ke email di atas. Klik link tersebut untuk mengaktifkan akun Anda, lalu kembali ke layar masuk.';
  static const String backToLogin = 'Kembali ke Masuk';
  static const String emailNotConfirmed =
      'Email belum dikonfirmasi. Cek inbox Anda untuk link konfirmasi.';
  static const String googleCancelled = 'Login Google dibatalkan.';
  static const String noAccountYet = 'Belum punya akun?';
  static const String alreadyHaveAccount = 'Sudah punya akun?';
  static const String emailEmpty = 'Email tidak boleh kosong.';
  static const String emailInvalid = 'Format email tidak valid.';
  static const String passwordEmpty = 'Kata sandi tidak boleh kosong.';
  static const String passwordTooShort = 'Kata sandi minimal 6 karakter.';
  static const String fullNameEmpty = 'Nama tidak boleh kosong.';
  static const String showPassword = 'Tampilkan sandi';
  static const String hidePassword = 'Sembunyikan sandi';

  // Accounts
  static const String accountsTitle = 'Akun';
  static const String addAccount = 'Tambah Akun';
  static const String editAccount = 'Edit Akun';
  static const String accountNameLabel = 'Nama Akun';
  static const String accountTypeLabel = 'Tipe Akun';
  static const String accountCash = 'Tunai';
  static const String accountEWallet = 'E-Wallet';
  static const String accountBank = 'Bank';
  static const String initialBalanceLabel = 'Saldo Awal';
  static const String deleteAccountConfirmTitle = 'Hapus Akun?';
  static const String deleteAccountConfirmMessage =
      'Akun ini akan dihapus permanen.';
  static const String accountNameEmpty = 'Nama akun tidak boleh kosong.';

  // Categories
  static const String categoriesTitle = 'Kategori';
  static const String addCategory = 'Tambah Kategori';
  static const String editCategory = 'Edit Kategori';
  static const String categoryNameLabel = 'Nama Kategori';
  static const String categoryTypeLabel = 'Tipe Transaksi';
  static const String categoryNameEmpty = 'Nama kategori tidak boleh kosong.';
  static const String deleteCategoryConfirmTitle = 'Hapus Kategori?';
  static const String deleteCategoryConfirmMessage =
      'Kategori ini akan dihapus permanen.';
  static const String income = 'Pemasukan';
  static const String expense = 'Pengeluaran';

  // Transactions
  static const String transactionsTitle = 'Transaksi';
  static const String addTransaction = 'Tambah Transaksi';
  static const String transactionDefault = 'Transaksi';
  static const String editTransaction = 'Edit Transaksi';
  static const String amountLabel = 'Nominal';
  static const String dateLabel = 'Tanggal';
  static const String noteLabel = 'Catatan';
  static const String noteHint = 'Opsional';
  static const String merchantLabel = 'Merchant';
  static const String accountLabel = 'Akun';
  static const String categoryLabel = 'Kategori';
  static const String amountInvalid = 'Nominal harus lebih dari 0.';
  static const String accountRequired = 'Pilih akun terlebih dahulu.';
  static const String categoryRequired = 'Pilih kategori terlebih dahulu.';
  static const String noAccountsAvailable =
      'Belum ada akun. Tambahkan akun dulu di tab Akun.';
  static const String noCategoriesAvailable =
      'Belum ada kategori untuk tipe ini. Tambahkan dulu di tab Kategori.';
  static const String deleteTransactionConfirmTitle = 'Hapus Transaksi?';
  static const String deleteTransactionConfirmMessage =
      'Transaksi ini akan dihapus permanen.';
  static const String emptyTransactions =
      'Belum ada transaksi. Scan struk atau tambah manual.';
  static const String notSynced = 'Belum tersinkron';
  static const String savedOffline =
      'Tersimpan offline. Akan disinkronkan otomatis.';
  static const String syncNow = 'Sinkronkan sekarang';
  static const String syncing = 'Menyinkronkan...';
  static const String syncComplete = 'Sinkronisasi selesai.';
  static const String syncNothingPending = 'Tidak ada transaksi pending.';
  static String pendingTransactions(int count) =>
      '$count transaksi belum tersinkron';
  static const String today = 'Hari ini';
  static const String yesterday = 'Kemarin';
  static const String manualEntry = 'Input Manual';

  // Scanner
  static const String scanTitle = 'Scan Struk';
  static const String scanFromCamera = 'Ambil Foto';
  static const String scanFromGallery = 'Pilih dari Galeri';
  static const String scanProcessing = 'Memproses gambar...';
  static const String scanProcessingBase = 'Memproses gambar';
  static const String scanFailed = 'Gagal memproses gambar.';
  static const String scanResultTitle = 'Hasil Scan';
  static const String detectedAutomatically = 'Terdeteksi otomatis';
  static const String needsReview = 'Perlu dicek';
  static const String notDetected = 'Tidak terdeteksi, isi manual';
  static const String editDetail = 'Edit Detail';
  static const String saveTransaction = 'Simpan Transaksi';
  static const String transactionTypeLabel = 'Tipe Transaksi';
  static const String ocrNoResult =
      'Tidak ada data terdeteksi. Isi manual di bawah.';
  static const String sourceLabel = 'Sumber';

  // Dashboard
  static const String dashboardTitle = 'Dashboard';
  static const String totalBalance = 'Total Saldo';
  static const String incomeThisPeriod = 'Pemasukan';
  static const String expenseThisPeriod = 'Pengeluaran';
  static const String netFlow = 'Arus Bersih';
  static const String expenseBreakdown = 'Pengeluaran per Kategori';
  static const String recentTransactions = 'Transaksi Terakhir';
  static const String viewAll = 'Lihat Semua';
  static const String periodWeek = 'Minggu Ini';
  static const String periodMonth = 'Bulan Ini';
  static const String periodYear = 'Tahun Ini';
  static const String emptyBreakdown = 'Belum ada pengeluaran di periode ini.';
  static const String scanFirstTransaction = 'Scan transaksi pertama Anda';
}
