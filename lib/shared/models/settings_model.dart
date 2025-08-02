class SettingsModel {
  final String userId;
  final String themeMode;
  final String language;

  SettingsModel({
    required this.userId,
    required this.themeMode,
    required this.language,
  });

  factory SettingsModel.fromMap(Map<String, dynamic> map) {
    return SettingsModel(
      userId: map['userId'] ?? '',
      themeMode: map['themeMode'] ?? 'light',
      language: map['language'] ?? 'en',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'themeMode': themeMode,
      'language': language,
    };
  }
}
