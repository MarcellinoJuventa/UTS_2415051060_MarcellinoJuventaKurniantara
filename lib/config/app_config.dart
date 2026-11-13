/// Konfigurasi utama aplikasi North (Coffee Bar & Brew Log).
/// Menggunakan public REST API SampleAPIs Coffee dan Supabase REST API (anon/publishable key).
class AppConfig {
  static const String appName = 'North';
  static const String appTagline = 'Specialty Coffee Bar & Brew Log';

  // Identitas Mahasiswa UTS Pemrograman Mobile
  static const String studentName = 'Marcellino Juventa Kurniantara';
  static const String studentNim = '2415051060';
  static const String studentClass = 'PTI-5IKI';
  static const String githubRepoUrl =
      'https://github.com/MarcellinoJuventa/UTS_2415051060_MarcellinoJuventaKurniantara';

  // Public REST API Endpoints (SampleAPIs Coffee)
  static const String hotCoffeeApiUrl = 'https://api.sampleapis.com/coffee/hot';
  static const String icedCoffeeApiUrl =
      'https://api.sampleapis.com/coffee/iced';

  // Supabase Backend Configuration (Hanya menggunakan publishable/anon key sesuai aturan keamanan)
  static const String supabaseRestUrl =
      'https://ekzkpfwyfnprafgkbjro.supabase.co/rest/v1';
  static const String supabaseAnonKey =
      'sb_publishable_BTMgK49JnUp4QfueI9lJcA_EYse3uOM';
  static const String coffeeLogsTable = 'coffee_logs';
}
