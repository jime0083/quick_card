import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:permission_handler/permission_handler.dart';

class ImageSaveService {
  /// 画像バイトデータを保存する
  static Future<bool> saveImageBytes(
    Uint8List bytes, {
    required String fileName,
  }) async {
    try {
      // 権限を確認・要求
      if (!await _requestPermissions()) {
        return false;
      }

      // 画像をギャラリーに保存
      final result = await ImageGallerySaver.saveImage(
        bytes,
        quality: 100,
        name: fileName,
      );

      return result['isSuccess'] == true;
    } catch (e) {
      debugPrint('画像保存エラー: $e');
      return false;
    }
  }



  /// 必要な権限を要求
  static Future<bool> _requestPermissions() async {
    if (Platform.isAndroid) {
      final status = await Permission.storage.request();
      return status.isGranted;
    } else if (Platform.isIOS) {
      final status = await Permission.photos.request();
      return status.isGranted;
    }
    return true;
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