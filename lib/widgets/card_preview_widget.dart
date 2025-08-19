import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../l10n/app_localizations.dart';
import 'dart:io';
import 'dart:convert';
import '../models/business_card.dart';
import '../models/template.dart';

class CardPreviewWidget extends StatelessWidget {
  final BusinessCard card;
  final double? width;
  final double? height;
  final bool isBackSide;

  const CardPreviewWidget({
    super.key,
    required this.card,
    this.width,
    this.height,
    this.isBackSide = false,
  });

  @override
  Widget build(BuildContext context) {
    final template = TemplateData.getTemplateById(card.templateId);
    
    // テンプレートに応じてサイズを調整
    double cardWidth, cardHeight;
    
    // テンプレートIDまたは背景画像名で縦長か横長かを判定
    bool isVerticalTemplate = false;
    
    // 背景画像名での判定
    if (card.backgroundImage != null) {
      isVerticalTemplate = card.backgroundImage!.contains('1.png') || 
                          card.backgroundImage!.contains('2.png') || 
                          card.backgroundImage!.contains('背景6.png');
    }
    
    // テンプレートIDでの判定（背景画像がnullの場合のフォールバック）
    if (!isVerticalTemplate && card.templateId != null) {
      isVerticalTemplate = card.templateId!.contains('background_0') || // テンプレート1
                          card.templateId!.contains('background_1') || // テンプレート2
                          card.templateId!.contains('background_2');   // テンプレート3
    }
    
    if (isVerticalTemplate) {
      // 縦長テンプレート（1.png, 2.png, 背景6.png）: 379×627px
      cardWidth = width ?? 379.0;
      cardHeight = height ?? 627.0;
    } else {
      // 横長テンプレート（3.png, 4.png）: 627×379px
      cardWidth = width ?? 627.0;
      cardHeight = height ?? 379.0;
    }
    
    // 画面サイズに合わせてスケール調整
    final screenWidth = MediaQuery.of(context).size.width;
    final scale = screenWidth / (cardWidth + 32); // パディングを考慮
    if (scale < 1.0) {
      cardWidth *= scale;
      cardHeight *= scale;
    }

    return Container(
      width: cardWidth,
      height: cardHeight,
      decoration: BoxDecoration(
        borderRadius: template.borderRadius,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: template.borderRadius,
        child: Stack(
          children: [
            // 背景画像
            if (isBackSide && card.backBackgroundImage != null)
              Image.asset(
                card.backBackgroundImage!,
                width: cardWidth,
                height: cardHeight,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: cardWidth,
                    height: cardHeight,
                    color: template.backgroundColor,
                  );
                },
              )
            else if (!isBackSide && card.backgroundImage != null)
              Image.asset(
                card.backgroundImage!,
                width: cardWidth,
                height: cardHeight,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: cardWidth,
                    height: cardHeight,
                    color: template.backgroundColor,
                  );
                },
              )
            else
              Container(
                width: cardWidth,
                height: cardHeight,
                color: template.backgroundColor,
              ),
            // コンテンツ
            Padding(
              padding: template.padding,
              child: Column(
                children: [
                  const SizedBox(height: 30), // 上部空白
                  Expanded(
                    child: isBackSide ? _buildBackSide(template, context) : _buildFrontSide(template),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFrontSide(CardTemplate template) {
    // テンプレート4、5、6の場合は横型レイアウト
    if (_isHorizontalTemplate()) {
      return _buildTemplate4FrontSide(template);
    }
    
    // その他のテンプレートは従来の縦型レイアウト
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // アイコン画像（中央揃え）- 画像がない場合もスペースを確保
        Center(
          child: Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white,
                width: 3,
              ),
            ),
            child: ClipOval(
              child: card.personalInfo.iconImage != null
                  ? _buildIconImage(card.personalInfo.iconImage!)
                  : _buildPlaceholderIcon(),
            ),
          ),
        ),
        const SizedBox(height: 6), // 12から6に変更
        // 名前情報（中央揃え）
        _buildHeader(template),
        const SizedBox(height: 4), // 8から4に変更
        // 職業（中央揃え）
        if (card.personalInfo.profession.isNotEmpty) ...[
          SizedBox(height: _isTemplate3() ? 5.0 : 10.0), // テンプレート3の場合は5px、その他は10px
          Center(
            child: Text(
              card.personalInfo.profession,
              style: TextStyle(
                color: _isTemplate1() ? Colors.red : (_isTemplate2() ? Colors.red : template.accentColor),
                fontSize: (template.fontSize - 2) * 2.25, // 1.5倍の1.5倍
                fontWeight: FontWeight.w500,
                fontFamily: template.fontFamily ?? 'Arial',
              ),
            ),
          ),
          const SizedBox(height: 4), // 8から4に変更
        ],
        // 横線（テンプレート別制御）
        if (_shouldShowUnderline()) ...[
          Container(
            margin: const EdgeInsets.only(left: 50, right: 50),
            height: 1,
            color: _getUnderlineColor(),
          ),
        ],
        SizedBox(height: _isTemplate2() ? 50.0 : 30.0),
        // SNS情報
        _buildFrontContent(template),
        const Spacer(),
        _buildFooter(template),
      ],
    );
  }

  Widget _buildBackSide(CardTemplate template, BuildContext context) {
    // テンプレート4、5、6の場合は横型レイアウト
    if (_isHorizontalTemplate()) {
      return _buildTemplate4BackSide(template, context);
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildBackHeader(template),
        const SizedBox(height: 12),
        Expanded(
          child: SingleChildScrollView(
            child: _buildBackContent(template, context),
          ),
        ),
        _buildFooter(template),
      ],
    );
  }

  // テンプレート4専用の表面レイアウト
  Widget _buildTemplate4FrontSide(CardTemplate template) {
    return Stack(
      children: [
        Row(
          children: [
            // 左側：画像、名前、職業
            Expanded(
              flex: 1,
              child: Padding(
                padding: const EdgeInsets.only(right: 30), // 10から30に変更（20px増加）
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // アイコン画像
                    if (card.personalInfo.iconImage != null) ...[
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white,
                            width: 2,
                          ),
                        ),
                        child: ClipOval(
                          child: _buildIconImage(card.personalInfo.iconImage!),
                        ),
                      ),
                      const SizedBox(height: 0), // 4から2に変更（半分）
                    ] else ...[
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.person,
                          color: Colors.grey[600],
                          size: 40,
                        ),
                      ),
                      const SizedBox(height: 2), // 4から2に変更（半分）
                    ],
                    // 名前（日本語）
                    if (card.personalInfo.nameJa.isNotEmpty) ...[
                      Text(
                        card.personalInfo.nameJa,
                        style: TextStyle(
                          color: _isTemplate5() ? Colors.black : Colors.white,
                          fontSize: (template.fontSize + 2) * 1.5,
                          fontWeight: FontWeight.bold,
                          fontFamily: template.fontFamily ?? 'Arial',
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 2),
                    ],
                    // 名前（英語）
                    if (card.personalInfo.nameEn.isNotEmpty) ...[
                      Text(
                        card.personalInfo.nameEn,
                        style: TextStyle(
                          color: _isTemplate5() ? Colors.black : Colors.white,
                          fontSize: (template.fontSize - 2) * 1.2,
                          fontWeight: FontWeight.w400,
                          fontFamily: template.fontFamily ?? 'Arial',
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 4),
                    ],
                    // 職業
                    if (card.personalInfo.profession.isNotEmpty) ...[
                      Text(
                        card.personalInfo.profession,
                        style: TextStyle(
                          color: _isTemplate6() ? const Color(0xFF00A8FF) : (_isTemplate5() ? const Color(0xFF3333FF) : Colors.black),
                          fontSize: (template.fontSize - 2) * 1.2,
                          fontWeight: FontWeight.w500,
                          fontFamily: template.fontFamily ?? 'Arial',
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 10), // 職業の下に10pxの空白を追加
                    ],
                  ],
                ),
              ),
            ),
            // 右側：SNS・連絡先
            Expanded(
              flex: 1,
              child: Padding(
                padding: EdgeInsets.only(
                  left: _isTemplate5() ? 40.0 : (_isTemplate6() ? -50.0 : 0.0), // テンプレート5の場合は左側に40pxの空白、テンプレート6の場合は左側に-50pxの空白（さらに20px左に移動）
                  right: _isTemplate6() ? 0.0 : 0.0, // テンプレート6の場合は右側に0pxの空白
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start, // centerからstartに変更
                  children: [
                    const SizedBox(height: 50), // 40から50に変更（10px増加）
                    _buildTemplate4SnsContent(template),
                  ],
                ),
              ),
            ),
          ],
        ),
        // テンプレート6の場合は水色の縦線を追加
        if (_isTemplate6()) ...[
          Positioned(
            left: 0,
            right: 0,
            top: 0,
            bottom: 0,
            child: Padding(
              padding: const EdgeInsets.only(top: 0, bottom: 20),
              child: Align(
                alignment: Alignment.topCenter,
                child: Container(
                  width: 2,
                  height: double.infinity,
                  color: const Color(0xFF00A8FF),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  // テンプレート4専用のSNSコンテンツ
  Widget _buildTemplate4SnsContent(CardTemplate template) {
    final snsItems = <Widget>[];
    
    if (card.socialLinks.frontSns1Type != null && card.socialLinks.frontSns1Value != null) {
      snsItems.add(_buildSnsSection(card.socialLinks.frontSns1Type!, card.socialLinks.frontSns1Value!, template));
    }
    if (card.socialLinks.frontSns2Type != null && card.socialLinks.frontSns2Value != null) {
      snsItems.add(_buildSnsSection(card.socialLinks.frontSns2Type!, card.socialLinks.frontSns2Value!, template));
    }
    if (card.socialLinks.frontSns3Type != null && card.socialLinks.frontSns3Value != null) {
      snsItems.add(_buildSnsSection(card.socialLinks.frontSns3Type!, card.socialLinks.frontSns3Value!, template));
    }
    if (card.socialLinks.frontSns4Type != null && card.socialLinks.frontSns4Value != null) {
      snsItems.add(_buildSnsSection(card.socialLinks.frontSns4Type!, card.socialLinks.frontSns4Value!, template));
    }

    if (snsItems.isEmpty) {
      return const SizedBox.shrink();
    }

    // 縦に2つずつ2列で表示
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 左列
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (int i = 0; i < snsItems.length && i < 2; i++) ...[
              snsItems[i],
              if (i < 1 && snsItems.length > 1) const SizedBox(height: 8),
            ],
          ],
        ),
        // 右列（要素が3つ以上ある場合のみ表示）
        if (snsItems.length > 2) ...[
          const SizedBox(width: 6), // 16から6に戻す
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (int i = 2; i < snsItems.length && i < 4; i++) ...[
                snsItems[i],
                if (i < 3 && snsItems.length > 3) const SizedBox(height: 8),
              ],
            ],
          ),
        ],
      ],
    );
  }

  // テンプレート4専用の裏面レイアウト
  Widget _buildTemplate4BackSide(CardTemplate template, BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: _buildTemplate4BackContent(template, context),
          ),
        ),
        _buildFooter(template),
      ],
    );
  }

  // テンプレート4専用の裏面コンテンツ（文字サイズを小さく）
  Widget _buildTemplate4BackContent(CardTemplate template, BuildContext context) {
    if (card.backSideInfo == null) {
      return const SizedBox.shrink();
    }

    final categories = card.backSideInfo!.selectedCategories;
    
    // 左側と右側のカテゴリを分離
    final leftCategories = <String>[];
    final rightCategories = <String>[];
    
    for (String category in categories) {
      if (category == 'language' || category == 'framework' || category == 'portfolio') {
        leftCategories.add(category);
      } else if (category == 'career') {
        rightCategories.add(category);
      }
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 左側：「言語」「FW」「ポートフォリオ」
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (int i = 0; i < leftCategories.length; i++) ...[
                _buildTemplate4BackSideCategory(leftCategories[i], template, context),
                if (i < leftCategories.length - 1) const SizedBox(height: 6),
              ],
            ],
          ),
        ),
        // 右側：「経歴」
        if (rightCategories.isNotEmpty) ...[
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                              for (int i = 0; i < rightCategories.length; i++) ...[
                _buildTemplate4BackSideCategory(rightCategories[i], template, context),
                if (i < rightCategories.length - 1) const SizedBox(height: 6),
              ],
              ],
            ),
          ),
        ],
      ],
    );
  }

  String _getCategoryDisplayName(String category, BuildContext context) {
    switch (category) {
      case 'language':
        return AppLocalizations.of(context)!.language;
      case 'framework':
        return AppLocalizations.of(context)!.framework;
      case 'qualification':
        return AppLocalizations.of(context)!.qualification;
      case 'career':
        return AppLocalizations.of(context)!.career;
      case 'portfolio':
        return AppLocalizations.of(context)!.portfolio;
      default:
        return category;
    }
  }

  // テンプレート4専用の裏面カテゴリ（文字サイズを小さく）
  Widget _buildTemplate4BackSideCategory(String category, CardTemplate template, BuildContext context) {
    String? content1;
    String? content2;
    String? content3;

    switch (category) {
      case 'language':
        content1 = card.backSideInfo!.language1;
        break;
      case 'framework':
        content1 = card.backSideInfo!.framework1;
        break;
      case 'qualification':
        content1 = card.backSideInfo!.qualification1;
        break;
      case 'career':
        content1 = card.backSideInfo!.career1;
        content2 = card.backSideInfo!.career2;
        content3 = card.backSideInfo!.career3;
        break;
      case 'portfolio':
        content1 = card.backSideInfo!.portfolio1;
        content2 = card.backSideInfo!.portfolio2;
        break;
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: category == 'language' ? 3.0 : 6.0), // 言語の場合は3px、その他は6px
          Text(
            _getCategoryDisplayName(category, context),
            style: TextStyle(
              color: _isTemplate6() ? const Color(0xFF00A8FF) : (_isTemplate5() ? const Color(0xFF3333FF) : const Color(0xFFFF4D85)), // テンプレート6の場合は#00A8FF、テンプレート5の場合は#3333ff
              fontSize: (template.fontSize - 6) * 1.8, // 文字サイズを小さく
              fontWeight: FontWeight.bold,
              fontFamily: template.fontFamily ?? 'Arial',
            ),
          ),
          const SizedBox(height: 3),
          if (content1 != null && content1.isNotEmpty || content2 != null && content2.isNotEmpty) ...[
            if (category == 'ポートフォリオ') ...[
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (content1 != null && content1.isNotEmpty && 
                      (content1.startsWith('http://') || content1.startsWith('https://'))) ...[
                    Container(
                      width: 40, // QRコードサイズを小さく
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(3),
                      ),
                      child: QrImageView(
                        data: content1,
                        version: QrVersions.auto,
                        errorCorrectionLevel: QrErrorCorrectLevel.M,
                        backgroundColor: Colors.white,
                        size: 40,
                      ),
                    ),
                  ] else if (content1 != null && content1.isNotEmpty) ...[
                                         Flexible(
                       fit: FlexFit.loose,
                       child: Text(
                         content1,
                         style: TextStyle(
                           color: _isTemplate5() ? Colors.black : Colors.white,
                           fontSize: (template.fontSize - 8) * 1.8, // 文字サイズを小さく
                           fontFamily: template.fontFamily ?? 'Arial',
                         ),
                       ),
                     ),
                  ],
                  if (content1 != null && content1.isNotEmpty && content2 != null && content2.isNotEmpty) ...[
                    const SizedBox(width: 6),
                  ],
                  if (content2 != null && content2.isNotEmpty && 
                      (content2.startsWith('http://') || content2.startsWith('https://'))) ...[
                    Container(
                      width: 40, // QRコードサイズを小さく
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(3),
                      ),
                      child: QrImageView(
                        data: content2,
                        version: QrVersions.auto,
                        errorCorrectionLevel: QrErrorCorrectLevel.M,
                        backgroundColor: Colors.white,
                        size: 40,
                      ),
                    ),
                  ] else if (content2 != null && content2.isNotEmpty) ...[
                                         Flexible(
                       fit: FlexFit.loose,
                       child: Text(
                         content2,
                         style: TextStyle(
                           color: _isTemplate5() ? Colors.black : Colors.white,
                           fontSize: (template.fontSize - 8) * 1.8, // 文字サイズを小さく
                           fontFamily: template.fontFamily ?? 'Arial',
                         ),
                       ),
                     ),
                  ],
                ],
              ),
                         ] else ...[
               if (content1 != null && content1.isNotEmpty) ...[
                 Text(
                   content1,
                   style: TextStyle(
                     color: _isTemplate5() ? Colors.black : Colors.white,
                     fontSize: (template.fontSize - 8) * 1.8, // 文字サイズを小さく
                     fontFamily: template.fontFamily ?? 'Arial',
                   ),
                 ),
               ],
               if (content2 != null && content2.isNotEmpty) ...[
                 const SizedBox(height: 1),
                 Text(
                   content2,
                   style: TextStyle(
                     color: _isTemplate5() ? Colors.black : Colors.white,
                     fontSize: (template.fontSize - 8) * 1.8, // 文字サイズを小さく
                     fontFamily: template.fontFamily ?? 'Arial',
                   ),
                 ),
               ],
             ],
          ],
                     if (category == '経歴' && content3 != null && content3.isNotEmpty) ...[
             const SizedBox(height: 1),
             Text(
               content3,
               style: TextStyle(
                 color: _isTemplate5() ? Colors.black : Colors.white,
                 fontSize: (template.fontSize - 8) * 1.8, // 文字サイズを小さく
                 fontFamily: template.fontFamily ?? 'Arial',
               ),
             ),
           ],
        ],
      ),
    );
  }

  Widget _buildHeader(CardTemplate template) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (card.personalInfo.nameJa.isNotEmpty)
          Center(
            child: Text(
              card.personalInfo.nameJa,
              style: TextStyle(
                color: _isTemplate2() ? Colors.black : template.textColor,
                fontSize: (template.fontSize + 4) * 2,
                fontWeight: FontWeight.bold,
                fontFamily: template.fontFamily ?? 'Arial',
              ),
            ),
          ),
        if (card.personalInfo.nameEn.isNotEmpty) ...[
          const SizedBox(height: 0.5), // 1から0.5に変更
          Center(
            child: Text(
              card.personalInfo.nameEn,
              style: TextStyle(
                color: _isTemplate2() ? Colors.black : template.textColor,
                fontSize: (template.fontSize - 2) * 2,
                fontFamily: template.fontFamily ?? 'Arial',
              ),
            ),
          ),
        ],
        if (card.personalInfo.title.isNotEmpty) ...[
          const SizedBox(height: 2), // 4から2に変更
          Center(
            child: Text(
              card.personalInfo.title,
              style: TextStyle(
                color: template.accentColor,
                fontSize: (template.fontSize - 2) * 1.75,
                fontWeight: FontWeight.w500,
                fontFamily: template.fontFamily ?? 'Arial',
              ),
            ),
          ),
        ],
        if (card.personalInfo.catchphrase != null &&
            card.personalInfo.catchphrase!.isNotEmpty) ...[
          const SizedBox(height: 2), // 4から2に変更
          Center(
            child: Text(
              card.personalInfo.catchphrase!,
              style: TextStyle(
                color: template.textColor,
                fontSize: (template.fontSize - 4) * 2,
                fontStyle: FontStyle.italic,
                fontFamily: template.fontFamily ?? 'Arial',
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildFrontContent(CardTemplate template) {
    // SNS情報を収集
    final snsItems = <Widget>[];
    
    if (card.socialLinks.frontSns1Type != null && card.socialLinks.frontSns1Value != null) {
      snsItems.add(_buildSnsSection(card.socialLinks.frontSns1Type!, card.socialLinks.frontSns1Value!, template));
    }
    if (card.socialLinks.frontSns2Type != null && card.socialLinks.frontSns2Value != null) {
      snsItems.add(_buildSnsSection(card.socialLinks.frontSns2Type!, card.socialLinks.frontSns2Value!, template));
    }
    if (card.socialLinks.frontSns3Type != null && card.socialLinks.frontSns3Value != null) {
      snsItems.add(_buildSnsSection(card.socialLinks.frontSns3Type!, card.socialLinks.frontSns3Value!, template));
    }
    if (card.socialLinks.frontSns4Type != null && card.socialLinks.frontSns4Value != null) {
      snsItems.add(_buildSnsSection(card.socialLinks.frontSns4Type!, card.socialLinks.frontSns4Value!, template));
    }

    if (snsItems.isEmpty) {
      return const SizedBox.shrink();
    }

    // 縦に2つ要素を並べる2列配置で表示（セクション全体は中央揃え、個々の要素は左揃え）
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 左列
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (int i = 0; i < snsItems.length; i += 2) ...[
                snsItems[i],
                if (i + 2 < snsItems.length) const SizedBox(height: 8),
              ],
            ],
          ),
          // 右列（要素が2つ以上ある場合のみ表示）
          if (snsItems.length > 1) ...[
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (int i = 1; i < snsItems.length; i += 2) ...[
                  snsItems[i],
                  if (i + 2 < snsItems.length) const SizedBox(height: 8),
                ],
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBackHeader(CardTemplate template) {
    return const SizedBox.shrink(); // 裏面の名前表示を削除
  }

  Widget _buildBackContent(CardTemplate template, BuildContext context) {
    if (card.backSideInfo == null) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (String category in card.backSideInfo!.selectedCategories) ...[
          _buildBackSideCategory(category, template, context),
          const SizedBox(height: 8),
        ],
      ],
    );
  }

  Widget _buildBackSideCategory(String category, CardTemplate template, BuildContext context) {
    String? content1;
    String? content2;
    String? content3;

    switch (category) {
      case 'language':
        content1 = card.backSideInfo!.language1;
        break;
      case 'framework':
        content1 = card.backSideInfo!.framework1;
        break;
      case 'qualification':
        content1 = card.backSideInfo!.qualification1;
        break;
      case 'career':
        content1 = card.backSideInfo!.career1;
        content2 = card.backSideInfo!.career2;
        content3 = card.backSideInfo!.career3;
        break;
      case 'portfolio':
        content1 = card.backSideInfo!.portfolio1;
        content2 = card.backSideInfo!.portfolio2;
        break;
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20), // 見出しの上部空白
          Text(
            _getCategoryDisplayName(category, context),
            style: TextStyle(
              color: _isTemplate2() ? Colors.red : template.accentColor,
              fontSize: (template.fontSize - 4) * 2.25,
              fontWeight: FontWeight.bold,
              fontFamily: template.fontFamily ?? 'Arial',
            ),
          ),
          const SizedBox(height: 4),
          if (content1 != null && content1.isNotEmpty || content2 != null && content2.isNotEmpty) ...[
            if (category == 'portfolio') ...[
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (content1 != null && content1.isNotEmpty && 
                      (content1.startsWith('http://') || content1.startsWith('https://'))) ...[
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: QrImageView(
                        data: content1,
                        version: QrVersions.auto,
                        errorCorrectionLevel: QrErrorCorrectLevel.M,
                        backgroundColor: Colors.white,
                        size: 60,
                      ),
                    ),
                  ] else if (content1 != null && content1.isNotEmpty) ...[
                    Flexible(
                      fit: FlexFit.loose,
                      child: Text(
                        content1,
                        style: TextStyle(
                          color: _isTemplate2() ? Colors.white : template.textColor,
                          fontSize: (template.fontSize - 6) * 2.25,
                          fontFamily: template.fontFamily ?? 'Arial',
                        ),
                      ),
                    ),
                  ],
                  if (content1 != null && content1.isNotEmpty && content2 != null && content2.isNotEmpty) ...[
                    const SizedBox(width: 8),
                  ],
                  if (content2 != null && content2.isNotEmpty && 
                      (content2.startsWith('http://') || content2.startsWith('https://'))) ...[
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: QrImageView(
                        data: content2,
                        version: QrVersions.auto,
                        errorCorrectionLevel: QrErrorCorrectLevel.M,
                        backgroundColor: Colors.white,
                        size: 60,
                      ),
                    ),
                  ] else if (content2 != null && content2.isNotEmpty) ...[
                    Flexible(
                      fit: FlexFit.loose,
                      child: Text(
                        content2,
                        style: TextStyle(
                          color: _isTemplate2() ? Colors.white : template.textColor,
                          fontSize: (template.fontSize - 6) * 2.25,
                          fontFamily: template.fontFamily ?? 'Arial',
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ] else ...[
              if (content1 != null && content1.isNotEmpty) ...[
                Text(
                  content1,
                  style: TextStyle(
                    color: _isTemplate2() ? Colors.white : template.textColor,
                    fontSize: (template.fontSize - 6) * 1.75,
                    fontFamily: template.fontFamily ?? 'Arial',
                  ),
                ),
              ],
              if (content2 != null && content2.isNotEmpty) ...[
                const SizedBox(height: 2),
                Text(
                  content2,
                  style: TextStyle(
                    color: _isTemplate2() ? Colors.white : template.textColor,
                    fontSize: (template.fontSize - 6) * 1.75,
                    fontFamily: template.fontFamily ?? 'Arial',
                  ),
                ),
              ],
            ],
          ],
          if (category == 'career' && content3 != null && content3.isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(
              content3,
              style: TextStyle(
                color: _isTemplate2() ? Colors.white : template.textColor,
                fontSize: (template.fontSize - 6) * 1.75,
                fontFamily: template.fontFamily ?? 'Arial',
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSnsSection(String type, String value, CardTemplate template) {
    // テンプレート2の場合は常にアイコンのみを表示
    if (_isTemplate2() && (type == 'Github' || type == 'メールアドレス')) {
      return Container(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildSnsIcon(type, template),
            const SizedBox(width: 8),
            // テンプレート2の場合はQRコードやテキストを表示しない
          ],
        ),
      );
    }
    
    // URLまたはメールアドレスの場合はQRコードを表示
    if (value.startsWith('http://') || value.startsWith('https://') || 
        value.startsWith('mailto:') || value.startsWith('tel:') ||
        (type == 'メールアドレス' && value.contains('@'))) {
      
      // メールアドレスの場合はmailto:プレフィックスを追加
      String qrData = value;
      if (type == 'メールアドレス' && !value.startsWith('mailto:')) {
        qrData = 'mailto:$value';
      }
      
      return Container(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildSnsIcon(type, template),
            const SizedBox(width: 8),
            Container(
              width: _isTemplate6() ? 40.90905 : (_isHorizontalTemplate() ? 38.85 : 74.0), // テンプレート6の場合はさらに10%小さく
              height: _isTemplate6() ? 40.90905 : (_isHorizontalTemplate() ? 38.85 : 74.0), // テンプレート6の場合はさらに10%小さく
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
              ),
              child: QrImageView(
                data: qrData,
                version: QrVersions.auto,
                errorCorrectionLevel: QrErrorCorrectLevel.M,
                backgroundColor: Colors.white,
                size: _isTemplate6() ? 40.90905 : (_isHorizontalTemplate() ? 38.85 : 74.0), // テンプレート6の場合はさらに10%小さく
              ),
            ),
          ],
        ),
      );
    }
    
    // 通常のテキスト表示
    return Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildSnsIcon(type, template),
          const SizedBox(width: 8),
          Flexible(
            fit: FlexFit.loose,
            child: Text(
              value,
              style: TextStyle(
                color: template.textColor,
                fontSize: (template.fontSize - 10) * 4.5, // 2倍に変更
                fontFamily: template.fontFamily ?? 'Arial',
              ),
              textAlign: TextAlign.left,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSnsIcon(String type, CardTemplate template) {
    // アセットパスを直接使用
    String assetPath = _getSnsIconPath(type);
    
    // テンプレート6の場合はさらに10%小さく、テンプレート4、5の場合は30%小さく
    double iconSize = _isTemplate6() ? 29.85255 : (_isHorizontalTemplate() ? 28.35 : 54.0); // テンプレート6: 33.1695 * 0.9 = 29.85255
    
    return Image.asset(
      assetPath,
      width: iconSize,
      height: iconSize,
      errorBuilder: (context, error, stackTrace) {
        // エラーが発生した場合はMaterial Iconsでフォールバック
        return Icon(
          _getSnsIcon(type),
          color: template.accentColor,
          size: iconSize,
        );
      },
    );
  }

  IconData _getSnsIcon(String type) {
    switch (type) {
      case 'X(Twitter)':
        return Icons.flutter_dash; // X(Twitter)用のアイコン
      case 'インスタ':
        return Icons.camera_alt; // インスタ用のアイコン
      case 'Github':
        return Icons.code; // Github用のアイコン
      case 'メールアドレス':
        return Icons.email; // メールアドレス用のアイコン
      case 'Tiktok':
        return Icons.music_note; // Tiktok用のアイコン
      case 'Youtube':
        return Icons.play_circle; // Youtube用のアイコン
      default:
        return Icons.link;
    }
  }

  String _getSnsIconPath(String type) {
    // テンプレート2専用のアイコン設定
    bool isTemplate2 = _isTemplate2();
    
    String iconPath;
    switch (type) {
      case 'X(Twitter)':
        iconPath = 'assets/icons/business_cards/X.png';
        break;
      case 'インスタ':
        iconPath = 'assets/icons/business_cards/insta.png';
        break;
      case 'Github':
        iconPath = isTemplate2 ? 'assets/icons/business_cards/github2.png' : 'assets/icons/business_cards/github.png';
        break;
      case 'メールアドレス':
        iconPath = isTemplate2 ? 'assets/icons/business_cards/mail2.png' : 'assets/icons/business_cards/mail.png';
        break;
      case 'Tiktok':
        iconPath = 'assets/icons/business_cards/tiktok.png';
        break;
      case 'Youtube':
        iconPath = 'assets/icons/business_cards/youtube.png';
        break;
      default:
        iconPath = isTemplate2 ? 'assets/icons/business_cards/mail2.png' : 'assets/icons/business_cards/mail.png';
    }
    
    return iconPath;
  }

  // テンプレート別の下線表示制御
  bool _shouldShowUnderline() {
    // テンプレート3（背景6.png）の場合は下線を非表示
    if (card.backgroundImage != null && card.backgroundImage!.contains('背景6.png')) {
      return false;
    }
    return true;
  }

  // テンプレート1かどうかを判定
  bool _isTemplate1() {
    return (card.backgroundImage != null && card.backgroundImage!.contains('1.png')) ||
           (card.templateId != null && card.templateId!.contains('background_0'));
  }

  // テンプレート2かどうかを判定
  bool _isTemplate2() {
    // 背景画像での判定（最も確実）
    if (card.backgroundImage != null && card.backgroundImage!.contains('2.png')) {
      return true;
    }
    
    // テンプレートIDでの判定
    if (card.templateId != null) {
      if (card.templateId!.contains('background_1') || 
          card.templateId!.contains('template_02') ||
          card.templateId == 'template_02') {
        return true;
      }
    }
    
    return false;
  }

  // テンプレート3かどうかを判定
  bool _isTemplate3() {
    return (card.backgroundImage != null && card.backgroundImage!.contains('背景6.png')) ||
           (card.templateId != null && card.templateId!.contains('background_2'));
  }

  // テンプレート4かどうかを判定
  bool _isTemplate4() {
    return (card.backgroundImage != null && card.backgroundImage!.contains('4.png')) ||
           (card.templateId != null && card.templateId!.contains('background_3'));
  }

  // テンプレート5かどうかを判定
  bool _isTemplate5() {
    return (card.backgroundImage != null && card.backgroundImage!.contains('5.png')) ||
           (card.templateId != null && card.templateId!.contains('background_4'));
  }

  // テンプレート6かどうかを判定
  bool _isTemplate6() {
    return (card.backgroundImage != null && card.backgroundImage!.contains('裏1.png')) ||
           (card.templateId != null && card.templateId!.contains('background_5'));
  }

  // テンプレート4、5、6かどうかを判定（横型レイアウト用）
  bool _isHorizontalTemplate() {
    return _isTemplate4() || _isTemplate5() || _isTemplate6();
  }

  // テンプレート別の下線色制御
  Color _getUnderlineColor() {
    // テンプレート1（1.png）の場合は黒い下線
    if (_isTemplate1()) {
      return Colors.black;
    }
    // テンプレート2（2.png）の場合は赤い下線
    if (_isTemplate2()) {
      return Colors.red;
    }
    // テンプレート3（背景6.png）の場合は下線を非表示（色は関係ないが、一貫性のため）
    if (_isTemplate3()) {
      return Colors.transparent;
    }
    // その他のテンプレートは現状の色（accentColor）
    final template = TemplateData.getTemplateById(card.templateId);
    return template.accentColor;
  }

  Widget _buildIconImage(String imagePath) {
    // Base64画像の場合はImage.memoryを使用
    if (imagePath.startsWith('data:image/')) {
      try {
        final base64Data = imagePath.split(',')[1];
        final imageBytes = base64Decode(base64Data);
        return Image.memory(
          imageBytes,
          width: 120,
          height: 120,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return _buildPlaceholderIcon();
          },
        );
      } catch (e) {
        return _buildPlaceholderIcon();
      }
    }
    
    // 画像パスがblob:で始まる場合はWeb用の処理
    if (imagePath.startsWith('blob:')) {
      return _buildPlaceholderIcon();
    }
    
    // ファイルパスの場合はImage.fileを使用
    if (imagePath.startsWith('/')) {
      return Image.file(
        File(imagePath),
        width: 120,
        height: 120,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return _buildPlaceholderIcon();
        },
      );
    }
    
    // アセットの場合はImage.assetを使用
    return Image.asset(
      imagePath,
      width: 120,
      height: 120,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return _buildPlaceholderIcon();
      },
    );
  }

  Widget _buildPlaceholderIcon() {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        shape: BoxShape.circle,
      ),
      child: Icon(
        Icons.person,
        color: Colors.grey[600],
        size: 60,
      ),
    );
  }

  Widget _buildContent(CardTemplate template) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (card.techStack.languages.isNotEmpty) ...[
          _buildTechSection('言語', card.techStack.languages, template),
          const SizedBox(height: 8),
        ],
        if (card.techStack.frameworks.isNotEmpty) ...[
          _buildTechSection('フレームワーク', card.techStack.frameworks, template),
          const SizedBox(height: 8),
        ],
        if (card.techStack.specialties.isNotEmpty) ...[
          _buildTechSection('専門領域', card.techStack.specialties, template),
          const SizedBox(height: 8),
        ],
        if (card.experience.career.isNotEmpty) ...[
          _buildExperienceSection(template),
        ],
      ],
    );
  }

  Widget _buildTechSection(String title, List<String> items, CardTemplate template) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: template.accentColor,
            fontSize: template.fontSize - 4,
            fontWeight: FontWeight.bold,
            fontFamily: template.fontFamily ?? 'Arial',
          ),
        ),
        const SizedBox(height: 2),
        Wrap(
          spacing: 4,
          runSpacing: 2,
          children: items.take(3).map((item) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: template.accentColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                item,
                style: TextStyle(
                  color: template.accentColor,
                  fontSize: template.fontSize - 6,
                  fontFamily: template.fontFamily ?? 'Arial',
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildExperienceSection(CardTemplate template) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '経歴',
          style: TextStyle(
            color: template.accentColor,
            fontSize: template.fontSize - 4,
            fontWeight: FontWeight.bold,
            fontFamily: template.fontFamily ?? 'Arial',
          ),
        ),
        const SizedBox(height: 2),
        Text(
          card.experience.career,
          style: TextStyle(
            color: template.textColor,
            fontSize: template.fontSize - 6,
            fontFamily: template.fontFamily ?? 'Arial',
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        if (card.experience.years > 0) ...[
          const SizedBox(height: 2),
          Text(
            '${card.experience.years}年の開発経験',
            style: TextStyle(
              color: template.textColor,
              fontSize: template.fontSize - 6,
              fontFamily: template.fontFamily ?? 'Arial',
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildFooter(CardTemplate template) {
    final socialLinks = <Widget>[];

    if (card.socialLinks.github != null) {
      // テンプレート2の場合はgithub2.pngアイコンを表示
      if (_isTemplate2()) {
        socialLinks.add(_buildSocialImageIcon('assets/icons/business_cards/github2.png'));
      } else {
        socialLinks.add(_buildSocialIcon(Icons.code, template.accentColor));
      }
    }
    if (card.socialLinks.twitter != null) {
      socialLinks.add(_buildSocialIcon(Icons.flutter_dash, template.accentColor));
    }
    if (card.socialLinks.linkedin != null) {
      socialLinks.add(_buildSocialIcon(Icons.work, template.accentColor));
    }
    if (card.socialLinks.portfolio != null) {
      socialLinks.add(_buildSocialIcon(Icons.web, template.accentColor));
    }
    if (card.socialLinks.apps.isNotEmpty) {
      socialLinks.add(_buildSocialIcon(Icons.apps, template.accentColor));
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (socialLinks.isNotEmpty)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: socialLinks.take(4).map((icon) {
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: icon,
              );
            }).toList(),
          ),
        Text(
          'Quick Card',
          style: TextStyle(
            color: template.textColor.withOpacity(0.6),
            fontSize: template.fontSize - 8,
            fontFamily: template.fontFamily ?? 'Arial',
          ),
        ),
      ],
    );
  }

  Widget _buildSocialIcon(IconData icon, Color color) {
    return Icon(
      icon,
      color: color,
      size: 16,
    );
  }

  Widget _buildSocialImageIcon(String assetPath) {
    return Image.asset(
      assetPath,
      width: 16,
      height: 16,
      errorBuilder: (context, error, stackTrace) {
        return Icon(
          Icons.code,
          color: Colors.black,
          size: 16,
        );
      },
    );
  }
} 