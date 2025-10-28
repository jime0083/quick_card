import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image/image.dart' as img;
import 'package:firebase_core/firebase_core.dart';

class FirebaseUploadService {
  static const int ttlDays = 730; // 2 years

  static String get uid => FirebaseAuth.instance.currentUser!.uid;

  // PNG/JPEG等のバイト列からJPEGに変換
  static Uint8List toJpeg(Uint8List bytes, {int maxWidth = 1600, int quality = 85}) {
    final decoded = img.decodeImage(bytes);
    if (decoded == null) return bytes;
    img.Image resized = decoded;
    if (decoded.width > maxWidth) {
      final h = (decoded.height * (maxWidth / decoded.width)).round();
      resized = img.copyResize(decoded, width: maxWidth, height: h);
    }
    return Uint8List.fromList(img.encodeJpg(resized, quality: quality));
  }

  // 指定したサイズにリサイズしてJPEG化（正確な幅×高さ）
  static Uint8List toJpegExact(Uint8List bytes, {required int width, required int height, int quality = 90}) {
    final decoded = img.decodeImage(bytes);
    if (decoded == null) return bytes;
    final resized = img.copyResize(decoded, width: width, height: height);
    return Uint8List.fromList(img.encodeJpg(resized, quality: quality));
  }

  // 1ユーザー1枚を保証しつつアップロードし、短縮URL（簡易: 直リンク）を返す
  static Future<String?> uploadCardImageAndGetShortUrl({
    required Uint8List jpegBytes,
  }) async {
    await _deleteExistingForUser();

    final now = DateTime.now();
    final expiresAt = now.add(const Duration(days: ttlDays));

    final ref = FirebaseStorage.instance.ref().child('users').child(uid).child('card.jpg');
    await ref.putData(jpegBytes, SettableMetadata(contentType: 'image/jpeg'));
    final downloadUrl = await ref.getDownloadURL();

    final code = _generateCode();
    await FirebaseFirestore.instance.collection('short').doc(code).set({
      'uid': uid,
      'url': downloadUrl,
      'createdAt': now.millisecondsSinceEpoch,
      'expiresAt': expiresAt.millisecondsSinceEpoch,
      'type': 'card_image',
    });
    // 短いリダイレクトURL（Firebase Hosting + Functionsで /s/{code} をリダイレクトに設定）
    final projectId = Firebase.app().options.projectId;
    final shortUrl = 'https://$projectId.web.app/s/$code';
    return shortUrl;
  }

  // 表面・裏面の2枚をアップロードして短縮URLを返す
  static Future<String?> uploadCardImagesAndGetShortUrl({
    required Uint8List frontJpeg,
    required Uint8List backJpeg,
  }) async {
    await _deleteExistingForUser();

    final now = DateTime.now();
    final expiresAt = now.add(const Duration(days: ttlDays));

    final storage = FirebaseStorage.instance.ref().child('users').child(uid);
    final frontRef = storage.child('card_front.jpg');
    final backRef = storage.child('card_back.jpg');
    await frontRef.putData(frontJpeg, SettableMetadata(contentType: 'image/jpeg'));
    await backRef.putData(backJpeg, SettableMetadata(contentType: 'image/jpeg'));
    final frontUrl = await frontRef.getDownloadURL();
    final backUrl = await backRef.getDownloadURL();

    final code = _generateCode();
    await FirebaseFirestore.instance.collection('short').doc(code).set({
      'uid': uid,
      'urls': [frontUrl, backUrl],
      'createdAt': now.millisecondsSinceEpoch,
      'expiresAt': expiresAt.millisecondsSinceEpoch,
      'type': 'card_images',
    });

    final projectId = Firebase.app().options.projectId;
    final shortUrl = 'https://$projectId.web.app/s/$code';
    return shortUrl;
  }

  static Future<void> _deleteExistingForUser() async {
    final base = FirebaseStorage.instance.ref().child('users').child(uid);
    for (final name in ['card.jpg', 'card_front.jpg', 'card_back.jpg']) {
      try {
        await base.child(name).delete();
      } catch (_) {}
    }

    final snap = await FirebaseFirestore.instance
        .collection('short')
        .where('uid', isEqualTo: uid)
        .get();
    for (final d in snap.docs) {
      await d.reference.delete();
    }
  }

  static String _generateCode() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final now = DateTime.now().microsecondsSinceEpoch;
    final List<int> units = [];
    for (int i = 0; i < 6; i++) {
      units.add(chars.codeUnitAt((now + i) % chars.length));
    }
    return String.fromCharCodes(units);
  }
}


