import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import 'dart:convert';
import 'dart:typed_data';
import '../models/business_card.dart';
import '../providers/card_provider.dart';
import '../providers/language_provider.dart';
import '../widgets/language_selector.dart';
import 'card_preview_screen.dart';

class BackSideInputScreen extends StatefulWidget {
  final int backgroundIndex;
  final String backgroundImage;
  final Map<String, dynamic> frontData;
  final BusinessCard? existingCard;

  const BackSideInputScreen({
    super.key,
    required this.backgroundIndex,
    required this.backgroundImage,
    required this.frontData,
    this.existingCard,
  });

  @override
  State<BackSideInputScreen> createState() => _BackSideInputScreenState();
}

class _BackSideInputScreenState extends State<BackSideInputScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // 裏面カテゴリ選択（言語・フレームワーク・経歴・ポートフォリオの4種類）
  final List<String> _availableCategories = ['language', 'framework', 'career', 'portfolio'];
  List<String> _selectedCategories = [];
  
  // 各カテゴリの入力フィールド（行数に応じて調整）
  final Map<String, List<TextEditingController>> _controllers = {
    'language': [TextEditingController()], // 1行
    'framework': [TextEditingController()], // 1行
    // 'qualification' を削除
    'career': [TextEditingController(), TextEditingController(), TextEditingController()], // 3行
    'portfolio': [TextEditingController(), TextEditingController()], // 2行
  };

  @override
  void initState() {
    super.initState();
    _loadExistingData();
  }

  void _loadExistingData() {
    if (widget.existingCard?.backSideInfo != null) {
      final backSideInfo = widget.existingCard!.backSideInfo!;
      _selectedCategories = List.from(backSideInfo.selectedCategories);
      
      // 各カテゴリのデータを読み込み
      if (backSideInfo.language1 != null) {
        _controllers['language']![0].text = backSideInfo.language1!;
      }
      if (backSideInfo.framework1 != null) {
        _controllers['framework']![0].text = backSideInfo.framework1!;
      }
      // qualification は入力対象から除外
      if (backSideInfo.career1 != null) {
        _controllers['career']![0].text = backSideInfo.career1!;
      }
      if (backSideInfo.career2 != null) {
        _controllers['career']![1].text = backSideInfo.career2!;
      }
      if (backSideInfo.career3 != null) {
        _controllers['career']![2].text = backSideInfo.career3!;
      }
      if (backSideInfo.portfolio1 != null) {
        _controllers['portfolio']![0].text = backSideInfo.portfolio1!;
      }
      if (backSideInfo.portfolio2 != null) {
        _controllers['portfolio']![1].text = backSideInfo.portfolio2!;
      }
    }
  }

  @override
  void dispose() {
    for (var controllerList in _controllers.values) {
      for (var controller in controllerList) {
        controller.dispose();
      }
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${AppLocalizations.of(context)!.backSide} (${AppLocalizations.of(context)!.selectTemplate} ${widget.backgroundIndex + 1})'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: const [
          LanguageSelector(),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: _buildInputForm(),
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        child: ElevatedButton(
          onPressed: _saveCard,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Text(
            AppLocalizations.of(context)!.createCard,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  String _getBackgroundImage() {
    // テンプレート1（インデックス0）の場合は裏1.png
    if (widget.backgroundIndex == 0) {
      return 'assets/images/business_cards/裏1.png';
    }
    // テンプレート2（インデックス1）の場合は裏2.png
    if (widget.backgroundIndex == 1) {
      return 'assets/images/business_cards/裏2.png';
    }
    // テンプレート3（インデックス2、背景6.png）の場合は裏1.png
    if (widget.backgroundIndex == 2) {
      return 'assets/images/business_cards/裏1.png';
    }
    // テンプレート4（インデックス3）の場合は裏4.png
    if (widget.backgroundIndex == 3) {
      return 'assets/images/business_cards/裏4.png';
    }
    if (widget.backgroundIndex == 4) {
      return 'assets/images/business_cards/裏3.png';
    }
    // テンプレート6（インデックス5）の場合も裏3.png（横型）
    if (widget.backgroundIndex == 5) {
      return 'assets/images/business_cards/裏3.png';
    }
    return widget.backgroundImage;
  }

  Widget _buildInputForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '名刺裏面情報',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        
        // カテゴリ選択セクション
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '表示する項目を1つ以上4つまで選択してください',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _availableCategories.map((category) {
                  final isSelected = _selectedCategories.contains(category);
                  return FilterChip(
                    label: Text(_getCategoryDisplayName(category)),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        if (selected && _selectedCategories.length < 4) {
                          _selectedCategories.add(category);
                        } else if (!selected) {
                          _selectedCategories.remove(category);
                        }
                      });
                    },
                    backgroundColor: Colors.grey[200],
                    selectedColor: Colors.blue[100],
                    checkmarkColor: Colors.blue[800],
                  );
                }).toList(),
              ),
              const SizedBox(height: 8),
              Text(
                '選択済み: ${_selectedCategories.length}/4',
                style: TextStyle(
                  fontSize: 12,
                  color: _selectedCategories.length >= 1 ? Colors.green : Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        
        // 選択されたカテゴリの入力フィールド
        if (_selectedCategories.isNotEmpty) ...[
          Text(
            AppLocalizations.of(context)!.enterContentForEachItem,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          
          for (String category in _selectedCategories) ...[
            _buildCategoryInput(category),
            const SizedBox(height: 20),
          ],
        ],
        
        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildCategoryInput(String category) {
    final controllers = _controllers[category]!;
    
    return Consumer<LanguageProvider>(
      builder: (context, languageProvider, child) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(8),
            color: Colors.grey[50],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _getCategoryDisplayName(category),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(height: 12),
              // カテゴリに応じて入力フィールド数を調整
              if (category == 'language' || category == 'framework') ...[
                TextFormField(
                  controller: controllers[0],
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.white,
                    // ラベルテキストを削除
                  ),
                  maxLines: 1,
                ),
              ] else if (category == 'career') ...[
                TextFormField(
                  controller: controllers[0],
                  decoration: InputDecoration(
                    labelText: languageProvider.currentLocale.languageCode == 'en' 
                        ? 'About 30 characters' 
                        : '30文字程度',
                    border: const OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  maxLines: 1,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: controllers[1],
                  decoration: InputDecoration(
                    labelText: languageProvider.currentLocale.languageCode == 'en' 
                        ? 'About 30 characters' 
                        : '30文字程度',
                    border: const OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  maxLines: 1,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: controllers[2],
                  decoration: InputDecoration(
                    labelText: languageProvider.currentLocale.languageCode == 'en' 
                        ? 'About 30 characters' 
                        : '30文字程度',
                    border: const OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  maxLines: 1,
                ),
              ] else if (category == 'portfolio') ...[
                TextFormField(
                  controller: controllers[0],
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.white,
                    // ラベルテキストを削除
                  ),
                  maxLines: 1,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: controllers[1],
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.white,
                    // ラベルテキストを削除
                  ),
                  maxLines: 1,
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  String _getCategoryDisplayName(String category) {
    switch (category) {
      case 'language':
        return AppLocalizations.of(context)!.language;
      case 'framework':
        return AppLocalizations.of(context)!.framework;
      // qualification は削除
      case 'career':
        return AppLocalizations.of(context)!.career;
      case 'portfolio':
        return AppLocalizations.of(context)!.portfolio;
      default:
        return category;
    }
  }

  String _encodeImageToBase64(Uint8List imageBytes) {
    return base64Encode(imageBytes);
  }

  void _saveCard() {
    if (_selectedCategories.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.selectAtLeastOneItem)),
      );
      return;
    }

    // 裏面の背景画像を決定
    String backImage = _getBackgroundImage();

    // BackSideInfoを作成
    final backSideInfo = BackSideInfo(
      selectedCategories: List.from(_selectedCategories),
      language1: _controllers['language']?[0].text.trim(),
      language2: null, // 1行のみ
      framework1: _controllers['framework']?[0].text.trim(),
      framework2: null, // 1行のみ
      qualification1: null,
      qualification2: null,
      career1: _controllers['career']?[0].text.trim(),
      career2: _controllers['career']?[1].text.trim(),
      career3: _controllers['career']?[2].text.trim(),
      portfolio1: _controllers['portfolio']?[0].text.trim(),
      portfolio2: _controllers['portfolio']?[1].text.trim(),
    );

    // 既存のカードがある場合は更新、ない場合は新規作成
    final card = widget.existingCard != null
        ? widget.existingCard!.copyWith(
            personalInfo: PersonalInfo(
              nameJa: widget.frontData['nameJa'],
              nameEn: widget.frontData['nameEn'],
              title: '', // 不要になったが必須フィールドなので空文字
              company: '', // 不要になったが必須フィールドなので空文字
              email: '', // 不要になったが必須フィールドなので空文字
              phone: '', // 不要になったが必須フィールドなので空文字
              profession: widget.frontData['profession'],
              iconImage: widget.frontData['iconImageBytes'] != null 
                  ? 'data:image/jpeg;base64,${_encodeImageToBase64(widget.frontData['iconImageBytes'])}'
                  : widget.frontData['iconImagePath'],
            ),
            socialLinks: SocialLinks(
              apps: [],
              others: [],
              frontSns1Type: widget.frontData['sns1Type'],
              frontSns1Value: widget.frontData['sns1Value'],
              frontSns2Type: widget.frontData['sns2Type'],
              frontSns2Value: widget.frontData['sns2Value'],
              frontSns3Type: widget.frontData['sns3Type'],
              frontSns3Value: widget.frontData['sns3Value'],
              frontSns4Type: widget.frontData['sns4Type'],
              frontSns4Value: widget.frontData['sns4Value'],
            ),
            templateId: 'background_${widget.backgroundIndex}',
            backgroundImage: widget.backgroundImage,
            backBackgroundImage: backImage,
            backSideInfo: backSideInfo,
            updatedAt: DateTime.now(),
          )
        : BusinessCard(
            id: 'my_business_card', // 固定IDで1つの名刺のみ保存
            name: 'マイ名刺',
            personalInfo: PersonalInfo(
              nameJa: widget.frontData['nameJa'],
              nameEn: widget.frontData['nameEn'],
              title: '', // 不要になったが必須フィールドなので空文字
              company: '', // 不要になったが必須フィールドなので空文字
              email: '', // 不要になったが必須フィールドなので空文字
              phone: '', // 不要になったが必須フィールドなので空文字
              profession: widget.frontData['profession'],
              iconImage: widget.frontData['iconImageBytes'] != null 
                  ? 'data:image/jpeg;base64,${_encodeImageToBase64(widget.frontData['iconImageBytes'])}'
                  : widget.frontData['iconImagePath'],
            ),
            techStack: TechStack(
              languages: [],
              frameworks: [],
              specialties: [],
            ),
            experience: Experience(
              career: '',
              years: 0,
              achievements: [],
            ),
            socialLinks: SocialLinks(
              apps: [],
              others: [],
              frontSns1Type: widget.frontData['sns1Type'],
              frontSns1Value: widget.frontData['sns1Value'],
              frontSns2Type: widget.frontData['sns2Type'],
              frontSns2Value: widget.frontData['sns2Value'],
              frontSns3Type: widget.frontData['sns3Type'],
              frontSns3Value: widget.frontData['sns3Value'],
              frontSns4Type: widget.frontData['sns4Type'],
              frontSns4Value: widget.frontData['sns4Value'],
            ),
            templateId: 'background_${widget.backgroundIndex}',
            backgroundImage: widget.backgroundImage,
            backBackgroundImage: backImage,
            backSideInfo: backSideInfo,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          );

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => CardPreviewScreen(card: card),
      ),
    );
  }
}