import 'package:flutter/material.dart';

class CardTemplate {
  final String id;
  final String name;
  final String description;
  final Color backgroundColor;
  final Color textColor;
  final Color accentColor;
  final String? fontFamily;
  final double fontSize;
  final EdgeInsets padding;
  final BorderRadius borderRadius;

  const CardTemplate({
    required this.id,
    required this.name,
    required this.description,
    required this.backgroundColor,
    required this.textColor,
    required this.accentColor,
    this.fontFamily,
    required this.fontSize,
    required this.padding,
    required this.borderRadius,
  });
}

class TemplateData {
  static const List<CardTemplate> templates = [
    CardTemplate(
      id: 'template_01',
      name: 'シンプル・モダン',
      description: '白背景、洗練されたタイポグラフィ',
      backgroundColor: Colors.white,
      textColor: Colors.black87,
      accentColor: Colors.blue,
      fontSize: 14.0,
      padding: EdgeInsets.all(16.0),
      borderRadius: BorderRadius.all(Radius.circular(8.0)),
    ),
    CardTemplate(
      id: 'template_02',
      name: 'ダーク・テック',
      description: '黒背景、ネオン風アクセント',
      backgroundColor: Color(0xFF3333FF), // #3333ffに変更
      textColor: Colors.white,
      accentColor: Color(0xFFFF4D85), // #ff4d85に変更
      fontSize: 14.0,
      padding: EdgeInsets.all(16.0),
      borderRadius: BorderRadius.all(Radius.circular(8.0)),
    ),
    CardTemplate(
      id: 'template_03',
      name: 'カラフル・クリエイティブ',
      description: 'グラデーション、動的要素',
      backgroundColor: Colors.purple,
      textColor: Colors.white,
      accentColor: Colors.orange,
      fontSize: 14.0,
      padding: EdgeInsets.all(16.0),
      borderRadius: BorderRadius.all(Radius.circular(12.0)),
    ),
    CardTemplate(
      id: 'template_04',
      name: 'ミニマル・プロフェッショナル',
      description: '余白重視、上品なデザイン',
      backgroundColor: Color(0xFFF8F9FA),
      textColor: Color(0xFF2C3E50),
      accentColor: Color(0xFF3498DB),
      fontSize: 13.0,
      padding: EdgeInsets.all(20.0),
      borderRadius: BorderRadius.all(Radius.circular(4.0)),
    ),
    CardTemplate(
      id: 'template_05',
      name: 'イラスト・カジュアル',
      description: 'アイコン多用、親しみやすいデザイン',
      backgroundColor: Color(0xFFFFF8E1),
      textColor: Color(0xFF424242),
      accentColor: Color(0xFFFF9800),
      fontSize: 14.0,
      padding: EdgeInsets.all(16.0),
      borderRadius: BorderRadius.all(Radius.circular(16.0)),
    ),
  ];

  static CardTemplate getTemplateById(String id) {
    return templates.firstWhere(
      (template) => template.id == id,
      orElse: () => templates.first,
    );
  }
} 