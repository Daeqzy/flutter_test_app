class AppConfig {
  AppConfig._();

  // ----------------------------------------------------------
  // API BASE URL
  // ----------------------------------------------------------
  //
  // Can be overridden when running/building:
  //
  // flutter run \
  //   --dart-define=API_BASE_URL=http://example.com/
  //
  // The current company development server remains the
  // fallback while developing locally.
  // ----------------------------------------------------------

  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.20.1.100:5541/',
  );
}
