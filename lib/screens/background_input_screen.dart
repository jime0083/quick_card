import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../l10n/app_localizations.dart';
import 'dart:io';
import 'dart:typed_data';
import 'dart:convert';
import 'dart:html' as html;
import '../models/business_card.dart';
import '../providers/card_provider.dart';
import 'card_preview_screen.dart';
import 'back_side_input_screen.dart';

class BackgroundInputScreen extends StatefulWidget {
  final int backgroundIndex;
  final String backgroundImage;
  final BusinessCard? existingCard;

  const BackgroundInputScreen({
    super.key,
    required this.backgroundIndex,
    required this.backgroundImage,
    this.existingCard,
  });

  @override
  State<BackgroundInputScreen> createState() => _BackgroundInputScreenState();
}

class _BackgroundInputScreenState extends State<BackgroundInputScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // 表面フィールド
  final _nameJaController = TextEditingController();
  final _nameEnController = TextEditingController();
  
  // 画像選択用
  File? _selectedIconImage;
  Uint8List? _selectedIconImageBytes;
  final ImagePicker _imagePicker = ImagePicker();
  
  String _selectedProfession = 'Engineer';
  final List<String> _professionOptions = ['Engineer', 'Solo maker'];
  
  // SNS選択用
  final List<String> _snsOptions = ['X(Twitter)', 'インスタ', 'Github', 'メールアドレス', 'Tiktok', 'Youtube'];
  String? _sns1Type;
  String? _sns2Type;
  String? _sns3Type;
  String? _sns4Type;
  final TextEditingController _sns1Controller = TextEditingController();
  final TextEditingController _sns2Controller = TextEditingController();
  final TextEditingController _sns3Controller = TextEditingController();
  final TextEditingController _sns4Controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadExistingData();
  }

  void _loadExistingData() {
    if (widget.existingCard != null) {
      final card = widget.existingCard!;
      _nameJaController.text = card.personalInfo.nameJa;
      _nameEnController.text = card.personalInfo.nameEn;
      _selectedProfession = card.personalInfo.profession;
      
      // 既存の画像データを読み込み
      if (card.personalInfo.iconImage != null) {
        if (card.personalInfo.iconImage!.startsWith('data:image/')) {
          // Base64画像の場合
          try {
            final base64Data = card.personalInfo.iconImage!.split(',')[1];
            _selectedIconImageBytes = base64Decode(base64Data);
          } catch (e) {
            // Base64デコードに失敗した場合は無視
          }
        } else if (card.personalInfo.iconImage!.startsWith('/')) {
          // ファイルパスの場合
          _selectedIconImage = File(card.personalInfo.iconImage!);
        }
      }
      
      // SNS情報を読み込み
      _sns1Type = card.socialLinks.frontSns1Type;
      _sns1Controller.text = card.socialLinks.frontSns1Value ?? '';
      _sns2Type = card.socialLinks.frontSns2Type;
      _sns2Controller.text = card.socialLinks.frontSns2Value ?? '';
      _sns3Type = card.socialLinks.frontSns3Type;
      _sns3Controller.text = card.socialLinks.frontSns3Value ?? '';
      _sns4Type = card.socialLinks.frontSns4Type;
      _sns4Controller.text = card.socialLinks.frontSns4Value ?? '';
    }
  }

  @override
  void dispose() {
    _nameJaController.dispose();
    _nameEnController.dispose();
    _sns1Controller.dispose();
    _sns2Controller.dispose();
    _sns3Controller.dispose();
    _sns4Controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${AppLocalizations.of(context)!.frontSide} (${AppLocalizations.of(context)!.selectTemplate} ${widget.backgroundIndex + 1})'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        elevation: 0,
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
          onPressed: _proceedToBackSide,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Text(
            AppLocalizations.of(context)!.backSide,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  Widget _buildInputForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context)!.frontSide,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        
        // アイコン画像選択（テンプレート2の場合は非表示）
        if (!_isTemplate2()) ...[
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('アイコン画像', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                if (_selectedIconImageBytes != null) ...[
                  Center(
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[300]!),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.memory(
                          _selectedIconImageBytes!,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
                Center(
                  child: ElevatedButton.icon(
                    onPressed: _pickImageFromGallery,
                    icon: const Icon(Icons.photo_library),
                    label: Text(AppLocalizations.of(context)!.selectFromGallery),
                  ),
                ),
                if (_selectedIconImageBytes != null) ...[
                  const SizedBox(height: 8),
                  Center(
                    child: TextButton.icon(
                      onPressed: () {
                        setState(() {
                          _selectedIconImage = null;
                          _selectedIconImageBytes = null;
                        });
                      },
                      icon: const Icon(Icons.delete, color: Colors.red),
                      label: Text(AppLocalizations.of(context)!.deleteImage, style: const TextStyle(color: Colors.red)),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
        const SizedBox(height: 16),
        
        // 氏名（日本語）
        TextFormField(
          controller: _nameJaController,
          decoration: InputDecoration(
            labelText: AppLocalizations.of(context)!.nameJapanese,
            border: const OutlineInputBorder(),
            prefixIcon: const Icon(Icons.person),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return AppLocalizations.of(context)!.nameJapaneseRequired;
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        
        // 氏名（英語）
        TextFormField(
          controller: _nameEnController,
          decoration: InputDecoration(
            labelText: AppLocalizations.of(context)!.nameEnglish,
            border: const OutlineInputBorder(),
            prefixIcon: const Icon(Icons.person_outline),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return AppLocalizations.of(context)!.nameEnglishRequired;
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        
        // 職業選択
        DropdownButtonFormField<String>(
          value: _selectedProfession,
          decoration: InputDecoration(
            labelText: AppLocalizations.of(context)!.profession,
            border: const OutlineInputBorder(),
            prefixIcon: const Icon(Icons.work),
          ),
          items: _professionOptions.map((profession) {
            return DropdownMenuItem(
              value: profession,
              child: Text(profession),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _selectedProfession = value!;
            });
          },
        ),
        const SizedBox(height: 24),
        
        // SNS選択セクション
        Text(
          AppLocalizations.of(context)!.snsContact,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        
        _buildSnsSelector(1),
        const SizedBox(height: 16),
        _buildSnsSelector(2),
        const SizedBox(height: 16),
        _buildSnsSelector(3),
        const SizedBox(height: 16),
        _buildSnsSelector(4),
        
        const SizedBox(height: 32),
      ],
    );
  }

  // SNS選択ウィジェット
  Widget _buildSnsSelector(int index) {
    String? selectedType;
    TextEditingController controller;
    
    switch (index) {
      case 1:
        selectedType = _sns1Type;
        controller = _sns1Controller;
        break;
      case 2:
        selectedType = _sns2Type;
        controller = _sns2Controller;
        break;
      case 3:
        selectedType = _sns3Type;
        controller = _sns3Controller;
        break;
      case 4:
        selectedType = _sns4Type;
        controller = _sns4Controller;
        break;
      default:
        return Container();
    }
    
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: DropdownButtonFormField<String>(
            value: selectedType,
            decoration: InputDecoration(
              labelText: 'SNS $index',
              border: const OutlineInputBorder(),
            ),
            items: _snsOptions.map((option) {
              return DropdownMenuItem(
                value: option,
                child: Text(option),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                switch (index) {
                  case 1:
                    _sns1Type = value;
                    break;
                  case 2:
                    _sns2Type = value;
                    break;
                  case 3:
                    _sns3Type = value;
                    break;
                  case 4:
                    _sns4Type = value;
                    break;
                }
              });
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 3,
          child: TextFormField(
            controller: controller,
            enabled: selectedType != null,
            decoration: InputDecoration(
              labelText: selectedType == 'メールアドレス' ? 'アドレス' : 'URL',
              border: const OutlineInputBorder(),
            ),
            keyboardType: selectedType == 'メールアドレス' 
                ? TextInputType.emailAddress 
                : TextInputType.url,
          ),
        ),
      ],
    );
  }

  // 画像選択メソッド
  Future<void> _pickImageFromGallery() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 500,
        maxHeight: 500,
        imageQuality: 85,
      );
      
      if (image != null) {
        final bytes = await image.readAsBytes();
        setState(() {
          _selectedIconImage = File(image.path);
          _selectedIconImageBytes = bytes;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('画像の選択に失敗しました: $e')),
      );
    }
  }

  // テンプレート2かどうかを判定
  bool _isTemplate2() {
    return (widget.backgroundImage != null && widget.backgroundImage!.contains('2.png')) ||
           (widget.backgroundIndex == 1);
  }

  // 表面情報を保存して裏面入力に進む
  void _proceedToBackSide() {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BackSideInputScreen(
          backgroundIndex: widget.backgroundIndex,
          backgroundImage: widget.backgroundImage,
          frontData: _getFrontData(),
          existingCard: widget.existingCard, // 既存のカードを渡す
        ),
      ),
    );
  }
  
  Map<String, dynamic> _getFrontData() {
    return {
      'nameJa': _nameJaController.text.trim(),
      'nameEn': _nameEnController.text.trim(),
      'profession': _selectedProfession,
      'iconImagePath': _selectedIconImage?.path,
      'iconImageBytes': _selectedIconImageBytes,
      'sns1Type': _sns1Type,
      'sns1Value': _sns1Controller.text.trim(),
      'sns2Type': _sns2Type,
      'sns2Value': _sns2Controller.text.trim(),
      'sns3Type': _sns3Type,
      'sns3Value': _sns3Controller.text.trim(),
      'sns4Type': _sns4Type,
      'sns4Value': _sns4Controller.text.trim(),
    };
  }
}