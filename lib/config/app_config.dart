class AppConfig {
  const AppConfig._();

  static String get apiBaseUrl {
    const rawBaseUrl = String.fromEnvironment(
      'API_BASE_URL',
      defaultValue: 'http://3.0.90.110', 
    );

    return rawBaseUrl.endsWith('/')
        ? rawBaseUrl.substring(0, rawBaseUrl.length - 1)
        : rawBaseUrl;
  }
}