import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/template.dart';
import '../models/business_card.dart';
import '../services/business_card_service.dart';
import '../providers/card_provider.dart';
import 'card_edit_screen.dart';

class TemplateSelectionScreen extends StatefulWidget {
  const TemplateSelectionScreen({super.key});

  @override
  State<TemplateSelectionScreen> createState() => _TemplateSelectionScreenState();
}

class _TemplateSelectionScreenState extends State<TemplateSelectionScreen> {
  final TextEditingController _nameController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('テンプレート選択'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          _buildNameInput(),
          Expanded(
            child: _buildTemplateGrid(),
          ),
        ],
      ),
    );
  }

  Widget _buildNameInput() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '名刺の名前',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              hintText: '例: 勉強会用、転職活動用',
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 12,
              ),
            ),
            textInputAction: TextInputAction.done,
          ),
        ],
      ),
    );
  }

  Widget _buildTemplateGrid() {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.8,
      ),
      itemCount: TemplateData.templates.length,
      itemBuilder: (context, index) {
        final template = TemplateData.templates[index];
        return _buildTemplateCard(template);
      },
    );
  }

  Widget _buildTemplateCard(CardTemplate template) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () => _selectTemplate(template),
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: template.backgroundColor,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                ),
                child: Padding(
                  padding: template.padding,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'サンプル',
                        style: TextStyle(
                          color: template.textColor,
                          fontSize: template.fontSize,
                          fontWeight: FontWeight.bold,
                          fontFamily: template.fontFamily,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '山田太郎',
                        style: TextStyle(
                          color: template.textColor,
                          fontSize: template.fontSize - 2,
                          fontFamily: template.fontFamily,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Full Stack Developer',
                        style: TextStyle(
                          color: template.accentColor,
                          fontSize: template.fontSize - 4,
                          fontFamily: template.fontFamily,
                        ),
                      ),
                      const Spacer(),
                      Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: template.accentColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: template.accentColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    template.name,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    template.description,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _selectTemplate(CardTemplate template) {
    final cardName = _nameController.text.trim();
    if (cardName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('名刺の名前を入力してください'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // 新しい名刺を作成
    final newCard = BusinessCardService.createNewCard(
      name: cardName,
      templateId: template.id,
    );

    // 名刺を保存
    context.read<CardProvider>().addCard(newCard);

    // 編集画面に遷移
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => CardEditScreen(card: newCard),
      ),
    );
  }
} 