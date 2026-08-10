class AppConfig {
  static const String appName = 'Corporate Pooling';
  static const String apiBaseUrl = 'http://localhost:3000/api/v1'; // Node.js backend
  
  // Supabase credentials
  static const String supabaseUrl = 'https://mluleqpqufjlldrdxpuy.supabase.co';
  static const String supabaseAnonKey = 'sb_publishable_vvscuV4JZjN8dRzqgleVjA_uD1ft8kk';
  
  // App Settings
  static const int defaultSeats = 3;
  static const int defaultCoinPerSeat = 10;
  static const double searchRadiusKm = 50.0;
}
