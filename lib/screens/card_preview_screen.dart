import 'dart:typed_data';
import 'dart:ui' as ui;
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import '../l10n/app_localizations.dart';
import '../models/business_card.dart';
import '../models/template.dart';
import '../services/qr_service.dart';
import '../services/image_save_service.dart' if (dart.library.html) '../services/image_save_service_web.dart';
import '../widgets/card_preview_widget.dart';
import 'card_edit_screen.dart';
import 'background_input_screen.dart';
import '../services/firebase_upload_service.dart';

class CardPreviewScreen extends StatefulWidget {
  final BusinessCard card;
  final bool showQRCodeInitially;

  const CardPreviewScreen({
    super.key,
    required this.card,
    this.showQRCodeInitially = false,
  });

  @override
  State<CardPreviewScreen> createState() => _CardPreviewScreenState();
}

class _CardPreviewScreenState extends State<CardPreviewScreen> {
  bool _showQRCode = false;
  String? _qrData; // 画像共有用のQRデータ（data URI）
  bool _isGeneratingQr = false;
  int _qrRetries = 0;
  
  // 画像変換用のGlobalKey
  final GlobalKey _frontSideKey = GlobalKey();
  final GlobalKey _backSideKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    // 初回ビルド時にQR表示初期値を反映
    if (widget.showQRCodeInitially && !_showQRCode) {
      _showQRCode = true;
      _ensureQrGenerated();
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.card.name),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: _toggleQRCode,
            icon: Icon(_showQRCode ? Icons.credit_card : Icons.qr_code),
          ),
          PopupMenuButton<String>(
            onSelected: _handleMenuAction,
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    const Icon(Icons.edit),
                    const SizedBox(width: 8),
                    Text(AppLocalizations.of(context)!.edit),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'share',
                child: Row(
                  children: [
                    const Icon(Icons.share),
                    const SizedBox(width: 8),
                    Text(AppLocalizations.of(context)!.share),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'save',
                child: Row(
                  children: [
                    const Icon(Icons.save),
                    const SizedBox(width: 8),
                    Text(AppLocalizations.of(context)!.download),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            if (_showQRCode) ...[
              _buildQRCodeSection(),
              const SizedBox(height: 24),
            ],
            _buildCardSection(),
            const SizedBox(height: 24),
            _buildSocialLinksSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildQRCodeSection() {
    return Column(
      children: [
        const Text(
          '名刺QRコード',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: SizedBox(
            width: 200,
            height: 200,
            child: _qrData == null
                ? Center(
                    child: _isGeneratingQr
                        ? const CircularProgressIndicator()
                        : const Text(
                            'QRコードを生成中...',
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                  )
                : QrImageView(
                    data: _qrData!,
                    version: QrVersions.auto,
                    errorCorrectionLevel: QrErrorCorrectLevel.L,
                    backgroundColor: Colors.white,
                  ),
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'このQRコードから名刺画像を取得できます（QRコード表示まで30秒程度かかります）\n名刺画像の保存期間は2年間となっています。\n2年経つとキャリアや技術スタックが変わっている可能性が高いので名刺を作り直しましょう',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildCardSection() {
    return Column(
      children: [
        const Text(
          '完成した名刺',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        // 表面
        Container(
          margin: const EdgeInsets.only(bottom: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '表面',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: RepaintBoundary(
                  key: _frontSideKey,
                  child: CardPreviewWidget(
                    card: widget.card,
                    isBackSide: false,
                  ),
                ),
              ),
            ],
          ),
        ),
        // 裏面
        Container(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '裏面',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: RepaintBoundary(
                  key: _backSideKey,
                  child: CardPreviewWidget(
                    card: widget.card,
                    isBackSide: true,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSocialLinksSection() {
    final socialLinks = <Widget>[];

    if (widget.card.socialLinks.github != null) {
      socialLinks.add(_buildSocialLinkCard(
        'GitHub',
        widget.card.socialLinks.github!,
        Icons.code,
        Colors.black,
      ));
    }

    if (widget.card.socialLinks.twitter != null) {
      socialLinks.add(_buildSocialLinkCard(
        'Twitter/X',
        widget.card.socialLinks.twitter!,
        Icons.flutter_dash,
        Colors.blue,
      ));
    }

    if (widget.card.socialLinks.linkedin != null) {
      socialLinks.add(_buildSocialLinkCard(
        'LinkedIn',
        widget.card.socialLinks.linkedin!,
        Icons.work,
        Colors.blue[700]!,
      ));
    }

    if (widget.card.socialLinks.portfolio != null) {
      socialLinks.add(_buildSocialLinkCard(
        'ポートフォリオ',
        widget.card.socialLinks.portfolio!,
        Icons.web,
        Colors.green,
      ));
    }

    for (final app in widget.card.socialLinks.apps) {
      socialLinks.add(_buildSocialLinkCard(
        'アプリ・サービス',
        app,
        Icons.apps,
        Colors.orange,
      ));
    }

    for (final other in widget.card.socialLinks.others) {
      socialLinks.add(_buildSocialLinkCard(
        'その他',
        other,
        Icons.link,
        Colors.grey,
      ));
    }

    if (socialLinks.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        const Text(
          'SNS・リンク',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        ...socialLinks,
      ],
    );
  }

  Widget _buildSocialLinkCard(String title, String url, IconData icon, Color color) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon, color: color),
        title: Text(title),
        subtitle: Text(
          url,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 40,
              height: 40,
              child: QrImageView(
                data: url,
                version: QrVersions.auto,
                errorCorrectionLevel: QrErrorCorrectLevel.L,
                backgroundColor: Colors.white,
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              onPressed: () => _openUrl(url),
              icon: const Icon(Icons.open_in_new),
            ),
          ],
        ),
        onTap: () => _openUrl(url),
      ),
    );
  }

  void _toggleQRCode() {
    setState(() {
      _showQRCode = !_showQRCode;
    });
    if (_showQRCode) {
      _ensureQrGenerated();
    }
  }

  void _ensureQrGenerated() {
    if (_qrData != null || _isGeneratingQr) return;
    setState(() {
      _isGeneratingQr = true;
    });
    // レイアウト完了後にキャプチャ実行
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        final frontSideBytes = await _captureWidgetImageWithRetry(_frontSideKey, const Duration(milliseconds: 250), 40);
        if (frontSideBytes == null) {
          setState(() {
            _isGeneratingQr = false;
          });
          return;
        }
        // タイムアウト制御（2秒以内）
        // Firebaseへアップロード → 共有URLをQRへ。2秒以内を目安に完了を試みる
        // 背面もキャプチャして2枚をアップロード
        final backSideBytes = await _captureWidgetImageWithRetry(_backSideKey, const Duration(milliseconds: 250), 40);
        Uint8List frontForUpload = frontSideBytes;
        Uint8List? backForUpload = backSideBytes;

        // テンプレートに応じて固定サイズへ正規化
        final isVertical = _isVerticalTemplate();
        final targetW = isVertical ? 343 : 313;
        final targetH = isVertical ? 570 : 189;
        frontForUpload = FirebaseUploadService.toJpegExact(frontForUpload, width: targetW, height: targetH, quality: 95);
        if (backForUpload != null) {
          backForUpload = FirebaseUploadService.toJpegExact(backForUpload, width: targetW, height: targetH, quality: 95);
        }

        final uploadFuture = (backForUpload != null)
            ? FirebaseUploadService.uploadCardImagesAndGetShortUrl(
                frontJpeg: frontForUpload,
                backJpeg: backForUpload,
              )
            : FirebaseUploadService.uploadCardImageAndGetShortUrl(
                jpegBytes: frontForUpload,
              );
        String? url;
        try {
          url = await uploadFuture.timeout(const Duration(seconds: 25), onTimeout: () => null);
        } catch (_) {
          url = null;
        }
        if (url != null) {
          setState(() {
            _qrData = url; // URLを直接QRに埋め込み
            _isGeneratingQr = false;
            _qrRetries = 0;
          });
        } else {
          // 短縮URLが得られるまで再試行（最大2回、合計最大~30秒想定）
          if (_qrRetries < 2) {
            _qrRetries++;
            _isGeneratingQr = false;
            await Future.delayed(const Duration(milliseconds: 500));
            if (mounted) _ensureQrGenerated();
          } else {
            // 最終フォールバック: data URI でQRを確実に表示
            final dataUri = await QRService.encodeCardImageDataUriToFit(frontForUpload, maxBytes: 2300);
            setState(() {
              _qrData = dataUri;
              _isGeneratingQr = false;
            });
          }
        }
      } catch (_) {
        setState(() {
          _isGeneratingQr = false;
        });
      }
    });
  }

  Future<Uint8List?> _captureWidgetImageWithRetry(GlobalKey key, Duration interval, int maxTries) async {
    for (int i = 0; i < maxTries; i++) {
      final bytes = await _captureWidgetImage(key);
      if (bytes != null && bytes.isNotEmpty) {
        return bytes;
      }
      await Future.delayed(interval);
    }
    return null;
  }

  // 縦型テンプレート（1/2/3）かどうか判定（CardPreviewWidget と同等のロジック）
  bool _isVerticalTemplate() {
    final bg = widget.card.backgroundImage;
    final id = widget.card.templateId;
    final isT1 = (bg != null && bg.contains('1.png')) || (id.contains('background_0'));
    final isT2 = (bg != null && bg.contains('2.png')) || (id.contains('background_1') || id.contains('template_02'));
    final isT3 = (bg != null && bg.contains('背景6.png')) || (id.contains('background_2'));
    return isT1 || isT2 || isT3;
  }

  void _handleMenuAction(String action) {
    switch (action) {
      case 'edit':
        _editCard();
        break;
      case 'share':
        _shareCard();
        break;
      case 'save':
        _saveCardImage();
        break;
    }
  }

  void _editCard() {
    // 直接情報入力画面に移動
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CardEditScreen(
          card: widget.card,
        ),
      ),
    );
  }

  int _getBackgroundIndex() {
    final templateId = widget.card.templateId;
    if (templateId.contains('background_')) {
      final indexStr = templateId.replaceAll('background_', '');
      return int.tryParse(indexStr) ?? 0;
    }
    return 0;
  }

  void _shareCard() {
    // TODO: 名刺画像を生成して共有
    Share.share(
      '${widget.card.personalInfo.nameJa}の名刺です。\n'
      'Quick Cardで作成されました。',
      subject: '${widget.card.personalInfo.nameJa}の名刺',
    );
  }

  void _saveCardImage() async {
    // ローディング表示
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      // GlobalKeyを使用してWidgetを画像に変換
      final frontSideBytes = await _captureWidgetImage(_frontSideKey);
      final backSideBytes = await _captureWidgetImage(_backSideKey);

      if (frontSideBytes == null || backSideBytes == null) {
        throw Exception('画像の変換に失敗しました');
      }

      // 画像保存を実行
      final success = await ImageSaveService.saveBusinessCardImages(
        frontSideBytes: frontSideBytes,
        backSideBytes: backSideBytes,
        cardName: widget.card.personalInfo.nameJa.isNotEmpty 
            ? widget.card.personalInfo.nameJa 
            : '名刺',
      );

      // ローディングを閉じる
      Navigator.of(context).pop();

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('名刺画像を保存しました'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('画像保存に失敗しました'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      // ローディングを閉じる
      Navigator.of(context).pop();
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('エラーが発生しました: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  /// GlobalKeyを使用してWidgetを画像に変換
  Future<Uint8List?> _captureWidgetImage(GlobalKey key) async {
    try {
      final RenderRepaintBoundary? boundary = key.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) {
        debugPrint('RenderRepaintBoundaryが見つかりません');
        return null;
      }

      // 画像に変換
      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      
      return byteData?.buffer.asUint8List();
    } catch (e) {
      debugPrint('Widget to Image 変換エラー: $e');
      return null;
    }
  }

  void _openUrl(String url) {
    // TODO: URLを開く機能を実装
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('URLを開く: $url'),
        backgroundColor: Colors.blue,
      ),
    );
  }
} 