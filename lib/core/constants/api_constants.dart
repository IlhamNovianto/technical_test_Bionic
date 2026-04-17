class ApiConstants {
  // static const String baseUrl = 'https://newsapi.org/v2';

  static const String baseUrl = String.fromEnvironment('BASE_URL');
  static const String apiKey = String.fromEnvironment(
    'NEWS_API_KEY',
    defaultValue: '',
  );

  static const String topHeadlines = '/top-headlines';
  static const String everything = '/everything';
  static const String sources = '/top-headlines/sources';

  static const String defaultCountry = 'us';
  static const int pageSize = 20;

  static const List<String> categories = [
    'Latest',
    'Business',
    'Entertainment',
    'General',
    'Health',
    'Science',
    'Sports',
    'Technology',
  ];
}

//'2b0692bfff6e452e89fb017fbba65750';
