import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/language_provider.dart';

class LanguageSelector extends StatelessWidget {
  const LanguageSelector({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<LanguageProvider>(
      builder: (context, languageProvider, child) {
        return Container(
          margin: const EdgeInsets.only(right: 16),
          child: DropdownButton<String>(
            value: null, // 初期状態では何も選択されていない状態にする
            underline: Container(), // 下線を削除
            icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
            dropdownColor: Colors.blue,
            hint: const Text(
              'Language',
              style: TextStyle(color: Colors.white),
            ),
            onChanged: (String? languageCode) {
              if (languageCode != null) {
                languageProvider.setLanguage(languageCode);
              }
            },
            items: [
              DropdownMenuItem<String>(
                value: 'ja',
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('🇯🇵', style: TextStyle(fontSize: 16)),
                    const SizedBox(width: 8),
                    const Text('日本語'),
                  ],
                ),
              ),
              DropdownMenuItem<String>(
                value: 'en',
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('🇺🇸', style: TextStyle(fontSize: 16)),
                    const SizedBox(width: 8),
                    const Text('English'),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
} 