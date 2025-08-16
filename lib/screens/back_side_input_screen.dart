import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import 'dart:typed_data';
import '../models/business_card.dart';
import '../providers/card_provider.dart';
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
  
  // 裏面カテゴリ選択
  final List<String> _availableCategories = ['言語', 'FW(フレームワーク)', '資格', '経歴', 'ポートフォリオ'];
  List<String> _selectedCategories = [];
  
  // 各カテゴリの入力フィールド（行数に応じて調整）
  final Map<String, List<TextEditingController>> _controllers = {
    '言語': [TextEditingController()], // 1行
    'FW(フレームワーク)': [TextEditingController()], // 1行
    '資格': [TextEditingController()], // 1行
    '経歴': [TextEditingController(), TextEditingController(), TextEditingController()], // 3行
    'ポートフォリオ': [TextEditingController(), TextEditingController()], // 2行
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
        _controllers['言語']![0].text = backSideInfo.language1!;
      }
      if (backSideInfo.framework1 != null) {
        _controllers['FW(フレームワーク)']![0].text = backSideInfo.framework1!;
      }
      if (backSideInfo.qualification1 != null) {
        _controllers['資格']![0].text = backSideInfo.qualification1!;
      }
      if (backSideInfo.career1 != null) {
        _controllers['経歴']![0].text = backSideInfo.career1!;
      }
      if (backSideInfo.career2 != null) {
        _controllers['経歴']![1].text = backSideInfo.career2!;
      }
      if (backSideInfo.career3 != null) {
        _controllers['経歴']![2].text = backSideInfo.career3!;
      }
      if (backSideInfo.portfolio1 != null) {
        _controllers['ポートフォリオ']![0].text = backSideInfo.portfolio1!;
      }
      if (backSideInfo.portfolio2 != null) {
        _controllers['ポートフォリオ']![1].text = backSideInfo.portfolio2!;
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
        title: Text('名刺裏面情報入力 (テンプレート ${widget.backgroundIndex + 1})'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          // 背景画像プレビュー
          Container(
            width: double.infinity,
            height: 150,
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                _getBackgroundImage(),
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey[200],
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.image, size: 40, color: Colors.grey[400]),
                          const SizedBox(height: 8),
                          Text(
                            'テンプレート${widget.backgroundIndex + 1} 裏面',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          // 入力フォーム
          Expanded(
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: _buildInputForm(),
              ),
            ),
          ),
        ],
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
          child: const Text(
            '名刺を作成',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
    // テンプレート5（インデックス4、3.png）の場合は裏3.png
    if (widget.backgroundIndex == 4) {
      return 'assets/images/business_cards/裏3.png';
    }
    // テンプレート6（インデックス5、5.png）の場合は裏3.png
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
                    label: Text(category),
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
          const Text(
            '各項目の内容を入力してください',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
            category,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
          const SizedBox(height: 12),
          // カテゴリに応じて入力フィールド数を調整
          if (category == '言語' || category == 'FW(フレームワーク)' || category == '資格') ...[
            TextFormField(
              controller: controllers[0],
              decoration: const InputDecoration(
                labelText: '内容',
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.white,
              ),
              maxLines: 1,
            ),
          ] else if (category == '経歴') ...[
            TextFormField(
              controller: controllers[0],
              decoration: const InputDecoration(
                labelText: '1行目',
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.white,
              ),
              maxLines: 1,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: controllers[1],
              decoration: const InputDecoration(
                labelText: '2行目',
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.white,
              ),
              maxLines: 1,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: controllers[2],
              decoration: const InputDecoration(
                labelText: '3行目',
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.white,
              ),
              maxLines: 1,
            ),
          ] else if (category == 'ポートフォリオ') ...[
            TextFormField(
              controller: controllers[0],
              decoration: const InputDecoration(
                labelText: '1行目',
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.white,
              ),
              maxLines: 1,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: controllers[1],
              decoration: const InputDecoration(
                labelText: '2行目',
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.white,
              ),
              maxLines: 1,
            ),
          ],
        ],
      ),
    );
  }

  String _encodeImageToBase64(Uint8List imageBytes) {
    return base64Encode(imageBytes);
  }

  void _saveCard() {
    if (_selectedCategories.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('1つ以上の項目を選択してください')),
      );
      return;
    }

    // 裏面の背景画像を決定
    String backImage = _getBackgroundImage();

    // BackSideInfoを作成
    final backSideInfo = BackSideInfo(
      selectedCategories: List.from(_selectedCategories),
      language1: _controllers['言語']?[0].text.trim(),
      language2: null, // 1行のみ
      framework1: _controllers['FW(フレームワーク)']?[0].text.trim(),
      framework2: null, // 1行のみ
      qualification1: _controllers['資格']?[0].text.trim(),
      qualification2: null, // 1行のみ
      career1: _controllers['経歴']?[0].text.trim(),
      career2: _controllers['経歴']?[1].text.trim(),
      career3: _controllers['経歴']?[2].text.trim(),
      portfolio1: _controllers['ポートフォリオ']?[0].text.trim(),
      portfolio2: _controllers['ポートフォリオ']?[1].text.trim(),
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

    if (widget.existingCard != null) {
      context.read<CardProvider>().updateCard(card);
    } else {
      context.read<CardProvider>().addCard(card);
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => CardPreviewScreen(card: card),
      ),
    );
  }
}