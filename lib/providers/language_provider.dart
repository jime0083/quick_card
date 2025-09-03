import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageProvider extends ChangeNotifier {
  static const String _languageKey = 'selected_language';
  
  Locale _currentLocale = const Locale('ja', 'JP');
  
  Locale get currentLocale => _currentLocale;
  
  LanguageProvider() {
    _loadLanguageSettings();
  }
  
  Future<void> _loadLanguageSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final languageCode = prefs.getString(_languageKey);
    
    if (languageCode != null) {
      _currentLocale = Locale(languageCode);
    }
    
    notifyListeners();
  }
  
  Future<void> setLanguage(String languageCode) async {
    _currentLocale = Locale(languageCode);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languageKey, languageCode);
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