import 'dart:typed_data';
import 'dart:html' as html;
import 'package:flutter/material.dart';

// Web実装: ブラウザのダウンロードとして保存
class ImageSaveService {
  static Future<bool> saveImageBytes(
    Uint8List bytes, {
    required String fileName,
  }) async {
    try {
      final String safeName = fileName.endsWith('.png') ? fileName : '$fileName.png';
      final blob = html.Blob([bytes], 'image/png');
      final url = html.Url.createObjectUrlFromBlob(blob);
      final anchor = html.AnchorElement(href: url)
        ..download = safeName
        ..style.display = 'none';
      html.document.body?.append(anchor);
      anchor.click();
      anchor.remove();
      html.Url.revokeObjectUrl(url);
      return true;
    } catch (e) {
      debugPrint('Web画像保存エラー: $e');
      return false;
    }
  }

  static Future<bool> saveBusinessCardImages({
    required Uint8List frontSideBytes,
    required Uint8List backSideBytes,
    required String cardName,
  }) async {
    try {
      final frontOk = await saveImageBytes(frontSideBytes, fileName: '${cardName}_表面');
      final backOk = await saveImageBytes(backSideBytes, fileName: '${cardName}_裏面');
      return frontOk && backOk;
    } catch (e) {
      debugPrint('Web名刺画像保存エラー: $e');
      return false;
    }
  }
}