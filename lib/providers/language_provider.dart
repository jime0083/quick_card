import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageProvider extends ChangeNotifier {
  static const String _languageKey = 'selected_language';
  static const String _isFirstLaunchKey = 'is_first_launch';
  
  Locale _currentLocale = const Locale('ja', 'JP');
  bool _isFirstLaunch = true;
  
  Locale get currentLocale => _currentLocale;
  bool get isFirstLaunch => _isFirstLaunch;
  
  LanguageProvider() {
    _loadLanguageSettings();
  }
  
  Future<void> _loadLanguageSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final languageCode = prefs.getString(_languageKey);
    final isFirstLaunch = prefs.getBool(_isFirstLaunchKey) ?? true;
    
    _isFirstLaunch = isFirstLaunch;
    
    if (languageCode != null) {
      _currentLocale = Locale(languageCode);
    }
    
    notifyListeners();
  }
  
  Future<void> setLanguage(String languageCode) async {
    _currentLocale = Locale(languageCode);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languageKey, languageCode);
    await prefs.setBool(_isFirstLaunchKey, false);
    _isFirstLaunch = false;
    notifyListeners();
  }
  
  String getLanguageName(String languageCode) {
    switch (languageCode) {
      case 'ja':
        return '日本語';
      case 'en':
        return 'English';
      default:
        return '日本語';
    }
  }
} 