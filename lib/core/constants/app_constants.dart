class AppConstants {
  static const defaultEndpoint = 'http://localhost:1234/v1';
  static const defaultTemperature = 0.7;
  static const defaultMaxTokens = 2048;
  static const sidebarWidth = 280.0;
  static const connectionTimeout = Duration(seconds: 20);
  static const streamTimeout = Duration(minutes: 5);

  static const supportedImageExtensions = {'png', 'jpg', 'jpeg', 'webp'};
  static const supportedTextExtensions = {'txt', 'md', 'csv', 'json'};
  static const supportedBinaryExtensions = {'pdf', 'docx'};
}
