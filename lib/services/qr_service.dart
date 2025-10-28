import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:image/image.dart' as img;
import '../models/business_card.dart';

class QRService {
  // 名刺データをQRコード用のJSONに変換
  static String _cardToJson(BusinessCard card) {
    final Map<String, dynamic> cardData = {
      'id': card.id,
      'name': card.name,
      'templateId': card.templateId,
      'personalInfo': {
        'nameJa': card.personalInfo.nameJa,
        'nameEn': card.personalInfo.nameEn,
        'title': card.personalInfo.title,
        'catchphrase': card.personalInfo.catchphrase,
      },
      'techStack': {
        'languages': card.techStack.languages,
        'frameworks': card.techStack.frameworks,
        'specialties': card.techStack.specialties,
      },
      'experience': {
        'career': card.experience.career,
        'years': card.experience.years,
        'achievements': card.experience.achievements,
      },
      'socialLinks': {
        'github': card.socialLinks.github,
        'twitter': card.socialLinks.twitter,
        'linkedin': card.socialLinks.linkedin,
        'portfolio': card.socialLinks.portfolio,
        'apps': card.socialLinks.apps,
        'others': card.socialLinks.others,
      },
    };
    return jsonEncode(cardData);
  }

  // 名刺QRコードを生成
  static String generateCardQRData(BusinessCard card) {
    return _cardToJson(card);
  }

  // リンク用QRコードを生成
  static String generateLinkQRData(String url) {
    return url;
  }

  // 名刺画像をBase64エンコード（QRコード用）
  static Future<String> encodeCardImage(Uint8List imageBytes) async {
    // 画像を圧縮してサイズを削減
    final img.Image? image = img.decodeImage(imageBytes);
    if (image == null) return '';

    // 名刺サイズにリサイズ（800x400px）
    final img.Image resized = img.copyResize(
      image,
      width: 800,
      height: 400,
    );

    // JPEG形式で圧縮
    final Uint8List compressed = Uint8List.fromList(
      img.encodeJpg(resized, quality: 80),
    );

    return base64Encode(compressed);
  }

  // 名刺画像のデータURI（JPEG）を、指定バイト数以下になるよう圧縮して返す
  static Future<String?> encodeCardImageDataUriToFit(Uint8List imageBytes, {int maxBytes = 2300}) async {
    final img.Image? decoded = img.decodeImage(imageBytes);
    if (decoded == null) return null;

    // 試す解像度と品質の候補（小さい順）。まず確実に入るサイズを優先して2秒以内に生成。
    final List<int> targetWidths = [80, 70, 60, 50, 40, 100, 120, 140, 160];
    final List<int> qualities = [20, 18, 16, 14, 12, 10, 8, 6, 5];

    for (final w in targetWidths) {
      final double aspect = decoded.height / decoded.width;
      final int h = (w * aspect).round();
      final img.Image resized = img.copyResize(decoded, width: w, height: h);
      for (final q in qualities) {
        final Uint8List jpg = Uint8List.fromList(img.encodeJpg(resized, quality: q));
        final String b64 = base64Encode(jpg);
        final String dataUri = 'data:image/jpeg;base64,$b64';
        // QRペイロードのバイト長（ASCII）で判定
        if (utf8.encode(dataUri).length <= maxBytes) {
          return dataUri;
        }
      }
    }

    // どうしても収まらない場合はnull
    return null;
  }

  // Base64デコードして画像を復元
  static Uint8List decodeCardImage(String base64String) {
    return base64Decode(base64String);
  }

  // QRコードデータから名刺データを復元
  static BusinessCard? parseCardFromQR(String qrData) {
    try {
      final Map<String, dynamic> data = jsonDecode(qrData);
      
      return BusinessCard(
        id: data['id'] ?? '',
        name: data['name'] ?? '',
        templateId: data['templateId'] ?? 'template_01',
        personalInfo: PersonalInfo(
          nameJa: data['personalInfo']['nameJa'] ?? '',
          nameEn: data['personalInfo']['nameEn'] ?? '',
          title: data['personalInfo']['title'] ?? '',
          catchphrase: data['personalInfo']['catchphrase'],
          company: data['personalInfo']['company'] ?? '',
          email: data['personalInfo']['email'] ?? '',
          phone: data['personalInfo']['phone'] ?? '',
          address: data['personalInfo']['address'],
          website: data['personalInfo']['website'],
          iconImage: data['personalInfo']['iconImage'],
          profession: data['personalInfo']['profession'] ?? 'Engineer',
        ),
        techStack: TechStack(
          languages: List<String>.from(data['techStack']['languages'] ?? []),
          frameworks: List<String>.from(data['techStack']['frameworks'] ?? []),
          specialties: List<String>.from(data['techStack']['specialties'] ?? []),
        ),
        experience: Experience(
          career: data['experience']['career'] ?? '',
          years: data['experience']['years'] ?? 0,
          achievements: List<String>.from(data['experience']['achievements'] ?? []),
        ),
        socialLinks: SocialLinks(
          github: data['socialLinks']['github'],
          twitter: data['socialLinks']['twitter'],
          linkedin: data['socialLinks']['linkedin'],
          portfolio: data['socialLinks']['portfolio'],
          apps: List<String>.from(data['socialLinks']['apps'] ?? []),
          others: List<String>.from(data['socialLinks']['others'] ?? []),
          frontSns1Type: data['socialLinks']['frontSns1Type'],
          frontSns1Value: data['socialLinks']['frontSns1Value'],
          frontSns2Type: data['socialLinks']['frontSns2Type'],
          frontSns2Value: data['socialLinks']['frontSns2Value'],
          frontSns3Type: data['socialLinks']['frontSns3Type'],
          frontSns3Value: data['socialLinks']['frontSns3Value'],
        ),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        backgroundImage: data['backgroundImage'],
        backBackgroundImage: data['backBackgroundImage'],
        backSideInfo: data['backSideInfo'] != null 
            ? BackSideInfo(
                selectedCategories: List<String>.from(data['backSideInfo']['selectedCategories'] ?? []),
                language1: data['backSideInfo']['language1'],
                language2: data['backSideInfo']['language2'],
                framework1: data['backSideInfo']['framework1'],
                framework2: data['backSideInfo']['framework2'],
                qualification1: data['backSideInfo']['qualification1'],
                qualification2: data['backSideInfo']['qualification2'],
                career1: data['backSideInfo']['career1'],
                career2: data['backSideInfo']['career2'],
                portfolio1: data['backSideInfo']['portfolio1'],
                portfolio2: data['backSideInfo']['portfolio2'],
              )
            : null,
      );
    } catch (e) {
      print('QRコードデータの解析に失敗: $e');
      return null;
    }
  }

  // QRコードサイズをチェック（2KB制限）
  static bool isQRDataSizeValid(String data) {
    final int sizeInBytes = utf8.encode(data).length;
    return sizeInBytes <= 2048; // 2KB制限
  }

  // データサイズを削減するための最適化
  static String optimizeQRData(String data) {
    if (isQRDataSizeValid(data)) return data;

    // データサイズが大きすぎる場合の処理
    // 必要に応じてデータを簡略化
    return data.substring(0, 1000); // 簡易的な対応
  }
} 