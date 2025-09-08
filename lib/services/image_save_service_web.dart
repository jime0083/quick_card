import 'dart:typed_data';
import 'package:flutter/material.dart';

// Web専用のスタブクラス - iOS/Androidでは使用されない
class ImageSaveServiceWeb {
  /// Webプラットフォーム用の画像保存
  static Future<bool> saveImageBytes(
    Uint8List bytes, {
    required String fileName,
  }) async {
    // iOS/Androidではこのメソッドは呼ばれない
    debugPrint('ImageSaveServiceWeb.saveImageBytesが呼ばれましたが、これはWeb専用です');
    return false;
  }

  /// 名刺の表面と裏面を保存
  static Future<bool> saveBusinessCardImages({
    required Uint8List frontSideBytes,
    required Uint8List backSideBytes,
    required String cardName,
  }) async {
    // iOS/Androidではこのメソッドは呼ばれない
    debugPrint('ImageSaveServiceWeb.saveBusinessCardImagesが呼ばれましたが、これはWeb専用です');
    return false;
  }
}