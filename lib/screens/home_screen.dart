import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/business_card.dart';
import '../services/business_card_service.dart';
import '../providers/card_provider.dart';
import 'template_selection_screen.dart';
import 'card_preview_screen.dart';
import 'background_input_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<String> backgroundImages = [
    'assets/images/business_cards/1.png',
    'assets/images/business_cards/2.png',
    'assets/images/business_cards/背景6.png',
    'assets/images/business_cards/4.png',
    'assets/images/business_cards/3.png',
    'assets/images/business_cards/5.png',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CardProvider>().loadCards();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Quick Card',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Consumer<CardProvider>(
        builder: (context, cardProvider, child) {
          final cards = cardProvider.cards;

          return SingleChildScrollView(
            child: Column(
              children: [
                // 背景画像選択セクション
                Container(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '背景画像を選択してください',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Column(
                        children: [
                          for (int index = 0; index < backgroundImages.length; index++)
                            _buildBackgroundOption(index),
                        ],
                      ),
                    ],
                  ),
                ),
                // 作成済みの名刺
                if (cards.isNotEmpty) ...[
                  const Divider(),
                  Container(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '作成済みの名刺',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildCardItem(cards.first),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildBackgroundOption(int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () => _navigateToBackgroundInput(index),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: double.infinity,
          height: 160,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[300]!),
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
            child: Stack(
              children: [
                Image.asset(
                  backgroundImages[index],
                  width: double.infinity,
                  height: 160,
                  fit: BoxFit.contain,
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
                              'テンプレート${index + 1}',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.4),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  bottom: 12,
                  left: 12,
                  child: Text(
                    'テンプレート${index + 1}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }




  Widget _buildCardItem(BusinessCard card) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () => _navigateToCardPreview(card),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          card.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          card.personalInfo.nameJa.isNotEmpty
                              ? card.personalInfo.nameJa
                              : '名前未設定',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                        if (card.personalInfo.title.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            card.personalInfo.title,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  PopupMenuButton<String>(
                    onSelected: (value) => _handleCardAction(value, card),
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit),
                            SizedBox(width: 8),
                            Text('編集'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'duplicate',
                        child: Row(
                          children: [
                            Icon(Icons.copy),
                            SizedBox(width: 8),
                            Text('複製'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'share',
                        child: Row(
                          children: [
                            Icon(Icons.share),
                            SizedBox(width: 8),
                            Text('共有'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, color: Colors.red),
                            SizedBox(width: 8),
                            Text('削除', style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                    ],
                    child: const Icon(Icons.more_vert),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    Icons.access_time,
                    size: 16,
                    color: Colors.grey[500],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '更新: ${_formatDate(card.updatedAt)}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return '今日';
    } else if (difference.inDays == 1) {
      return '昨日';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}日前';
    } else {
      return '${date.month}/${date.day}';
    }
  }

  void _navigateToBackgroundInput(int backgroundIndex) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BackgroundInputScreen(
          backgroundIndex: backgroundIndex,
          backgroundImage: backgroundImages[backgroundIndex],
        ),
      ),
    );
  }

  void _navigateToTemplateSelection() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const TemplateSelectionScreen(),
      ),
    );
  }

  void _navigateToCardPreview(BusinessCard card) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CardPreviewScreen(card: card),
      ),
    );
  }

  void _handleCardAction(String action, BusinessCard card) {
    switch (action) {
      case 'edit':
        _navigateToCardPreview(card);
        break;
      case 'duplicate':
        _duplicateCard(card);
        break;
      case 'share':
        _shareCard(card);
        break;
      case 'delete':
        _deleteCard(card);
        break;
    }
  }

  void _duplicateCard(BusinessCard card) {
    final duplicatedCard = BusinessCardService.duplicateCard(card);
    context.read<CardProvider>().addCard(duplicatedCard);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('名刺を複製しました'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _shareCard(BusinessCard card) {
    // TODO: 共有機能を実装
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('共有機能は準備中です'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  void _deleteCard(BusinessCard card) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('名刺を削除'),
        content: Text('「${card.name}」を削除しますか？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('キャンセル'),
          ),
          TextButton(
            onPressed: () {
              context.read<CardProvider>().deleteCard(card.id);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('名刺を削除しました'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            child: const Text(
              '削除',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
} 