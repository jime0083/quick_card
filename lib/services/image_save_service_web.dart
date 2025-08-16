import 'dart:typed_data';
import 'dart:html' as html;
import 'package:flutter/material.dart';

class ImageSaveServiceWeb {
  /// Webプラットフォーム用の画像保存
  static Future<bool> saveImageBytes(
    Uint8List bytes, {
    required String fileName,
  }) async {
    try {
      // Web用のダウンロード処理
      final blob = html.Blob([bytes]);
      final url = html.Url.createObjectUrlFromBlob(blob);
      
      final anchor = html.AnchorElement(href: url)
        ..setAttribute('download', '$fileName.png')
        ..click();
      
      html.Url.revokeObjectUrl(url);
      return true;
    } catch (e) {
      debugPrint('Web画像保存エラー: $e');
      return false;
    }
  }

  /// 名刺の表面と裏面を保存
  static Future<bool> saveBusinessCardImages({
    required Uint8List frontSideBytes,
    required Uint8List backSideBytes,
    required String cardName,
  }) async {
    try {
      // 表面を保存
      final frontSuccess = await saveImageBytes(
        frontSideBytes,
        fileName: '${cardName}_表面',
      );

      // 裏面を保存
      final backSuccess = await saveImageBytes(
        backSideBytes,
        fileName: '${cardName}_裏面',
      );

      return frontSuccess && backSuccess;
    } catch (e) {
      debugPrint('名刺画像保存エラー: $e');
      return false;
    }
  }
} 