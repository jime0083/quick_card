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
import '../services/image_save_service.dart';
import '../services/image_save_service_web.dart';
import '../widgets/card_preview_widget.dart';
import 'card_edit_screen.dart';
import 'background_input_screen.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class CardPreviewScreen extends StatefulWidget {
  final BusinessCard card;

  const CardPreviewScreen({
    super.key,
    required this.card,
  });

  @override
  State<CardPreviewScreen> createState() => _CardPreviewScreenState();
}

class _CardPreviewScreenState extends State<CardPreviewScreen> {
  bool _showQRCode = false;
  
  // 画像変換用のGlobalKey
  final GlobalKey _frontSideKey = GlobalKey();
  final GlobalKey _backSideKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
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
            child: QrImageView(
              data: QRService.generateCardQRData(widget.card),
              version: QrVersions.auto,
              errorCorrectionLevel: QrErrorCorrectLevel.M,
              backgroundColor: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'このQRコードを読み取ると名刺の情報を取得できます',
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
    // 背景画像選択画面から編集を開始
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BackgroundInputScreen(
          backgroundIndex: _getBackgroundIndex(),
          backgroundImage: widget.card.backgroundImage ?? 'assets/images/business_cards/1.png',
          existingCard: widget.card, // 既存のカードを渡す
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
      final success = kIsWeb 
          ? await ImageSaveServiceWeb.saveBusinessCardImages(
              frontSideBytes: frontSideBytes,
              backSideBytes: backSideBytes,
              cardName: widget.card.personalInfo.nameJa.isNotEmpty 
                  ? widget.card.personalInfo.nameJa 
                  : '名刺',
            )
          : await ImageSaveService.saveBusinessCardImages(
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