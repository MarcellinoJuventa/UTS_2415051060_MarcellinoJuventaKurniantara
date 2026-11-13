/// Konfigurasi utama aplikasi North.
class AppConfig {
  static const String appName = 'North';
  static const String appTagline = 'Coffee & Drink Bar';

  // Identitas Mahasiswa UTS Pemrograman Mobile
  static const String studentName = 'Marcellino Juventa Kurniantara';
  static const String studentNim = '2415051060';
  static const String studentClass = 'PTI-5IKI';
  static const String githubRepoUrl =
      'https://github.com/MarcellinoJuventa/UTS_2415051060_MarcellinoJuventaKurniantara';

  // Public REST API Endpoints:
  // 1. SampleAPIs Coffee (Hot & Iced Coffee)
  static const String hotCoffeeApiUrl = 'https://api.sampleapis.com/coffee/hot';
  static const String icedCoffeeApiUrl =
      'https://api.sampleapis.com/coffee/iced';

  // 2. TheCocktailDB Public API (Non-Coffee / Cocoa & Mocktails)
  static const String nonCoffeeApiUrl =
      'https://www.thecocktaildb.com/api/json/v1/1/filter.php?c=Cocoa';
  static const String mocktailApiUrl =
      'https://www.thecocktaildb.com/api/json/v1/1/filter.php?a=Non_Alcoholic';

  // Supabase Backend Configuration (Publishable / Anon Key)
  static const String supabaseRestUrl =
      'https://ekzkpfwyfnprafgkbjro.supabase.co/rest/v1';
  static const String supabaseAnonKey =
      'sb_publishable_BTMgK49JnUp4QfueI9lJcA_EYse3uOM';
  static const String coffeeLogsTable = 'coffee_logs';
}
