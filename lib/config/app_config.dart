class AppConfig {
  const AppConfig._();

  static String get apiBaseUrl {
    const rawBaseUrl = String.fromEnvironment(
      'API_BASE_URL',
      defaultValue: 'http://10.0.2.2/haumonsters_api',
    );

    return rawBaseUrl.endsWith('/')
        ? rawBaseUrl.substring(0, rawBaseUrl.length - 1)
        : rawBaseUrl;
  }
}