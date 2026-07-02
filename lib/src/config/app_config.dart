class AppConfig {
  const AppConfig._();

  static const apiBaseUrl = String.fromEnvironment(
    'WORD_CATCHER_API_BASE_URL',
    defaultValue: 'http://localhost:3000',
  );

  static const mockUserId = String.fromEnvironment(
    'WORD_CATCHER_USER_ID',
    defaultValue: 'demo-user',
  );

  static const useMockApi = bool.fromEnvironment(
    'WORD_CATCHER_USE_MOCK_API',
    defaultValue: true,
  );
}
