import 'package:flutter/foundation.dart';
import '../models/business_card.dart';
import '../services/business_card_service.dart';

class CardProvider with ChangeNotifier {
  List<BusinessCard> _cards = [];
  bool _isLoading = false;

  List<BusinessCard> get cards => _cards;
  bool get isLoading => _isLoading;
  BusinessCard? get currentCard => _cards.isNotEmpty ? _cards.first : null;

  // 名刺一覧を読み込み
  Future<void> loadCards() async {
    _isLoading = true;
    notifyListeners();

    try {
      _cards = BusinessCardService.getAllCards();
    } catch (e) {
      debugPrint('名刺一覧の読み込みに失敗: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 名刺を追加（1つのみ保存）
  Future<void> addCard(BusinessCard card) async {
    try {
      await BusinessCardService.saveCard(card);
      // 既存の名刺を削除して新しい名刺のみ保持
      _cards.clear();
      _cards.add(card);
      notifyListeners();
    } catch (e) {
      debugPrint('名刺の追加に失敗: $e');
    }
  }

  // 名刺を更新
  Future<void> updateCard(BusinessCard card) async {
    try {
      await BusinessCardService.updateCard(card);
      final index = _cards.indexWhere((c) => c.id == card.id);
      if (index != -1) {
        _cards[index] = card;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('名刺の更新に失敗: $e');
    }
  }

  // 名刺を削除
  Future<void> deleteCard(String id) async {
    try {
      await BusinessCardService.deleteCard(id);
      _cards.removeWhere((card) => card.id == id);
      notifyListeners();
    } catch (e) {
      debugPrint('名刺の削除に失敗: $e');
    }
  }

  // 名刺をIDで取得
  BusinessCard? getCardById(String id) {
    try {
      return BusinessCardService.getCardById(id);
    } catch (e) {
      debugPrint('名刺の取得に失敗: $e');
      return null;
    }
  }

  // 名刺を複製
  Future<void> duplicateCard(BusinessCard card) async {
    try {
      final duplicatedCard = BusinessCardService.duplicateCard(card);
      await addCard(duplicatedCard);
    } catch (e) {
      debugPrint('名刺の複製に失敗: $e');
    }
  }

  // 名刺を検索
  List<BusinessCard> searchCards(String query) {
    if (query.isEmpty) return _cards;
    
    return _cards.where((card) {
      final searchText = query.toLowerCase();
      return card.name.toLowerCase().contains(searchText) ||
             card.personalInfo.nameJa.toLowerCase().contains(searchText) ||
             card.personalInfo.nameEn.toLowerCase().contains(searchText) ||
             card.personalInfo.title.toLowerCase().contains(searchText);
    }).toList();
  }

  // テンプレート別の名刺を取得
  List<BusinessCard> getCardsByTemplate(String templateId) {
    return _cards.where((card) => card.templateId == templateId).toList();
  }

  // 最近更新された名刺を取得
  List<BusinessCard> getRecentCards({int limit = 5}) {
    final sortedCards = List<BusinessCard>.from(_cards);
    sortedCards.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return sortedCards.take(limit).toList();
  }

  // 名刺の統計情報を取得
  Map<String, dynamic> getCardStats() {
    final totalCards = _cards.length;
    final completedCards = _cards.where((card) =>
        card.personalInfo.nameJa.isNotEmpty &&
        card.personalInfo.title.isNotEmpty).length;
    final templateStats = <String, int>{};
    
    for (final card in _cards) {
      templateStats[card.templateId] = 
          (templateStats[card.templateId] ?? 0) + 1;
    }

    return {
      'total': totalCards,
      'completed': completedCards,
      'templateStats': templateStats,
    };
  }
} 