import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';
import '../models/business_card.dart';

class BusinessCardService {
  static const String _boxName = 'business_cards';
  static late Box<BusinessCard> _box;
  static const Uuid _uuid = Uuid();

  static Future<void> initialize() async {
    await Hive.initFlutter();
    Hive.registerAdapter(BusinessCardAdapter());
    Hive.registerAdapter(PersonalInfoAdapter());
    Hive.registerAdapter(TechStackAdapter());
    Hive.registerAdapter(ExperienceAdapter());
    Hive.registerAdapter(SocialLinksAdapter());
    Hive.registerAdapter(BackSideInfoAdapter());
    _box = await Hive.openBox<BusinessCard>(_boxName);
  }

  static Future<void> close() async {
    await _box.close();
  }

  // 名刺一覧を取得
  static List<BusinessCard> getAllCards() {
    return _box.values.toList();
  }

  // 名刺を保存
  static Future<void> saveCard(BusinessCard card) async {
    await _box.put(card.id, card);
  }

  // 名刺を削除
  static Future<void> deleteCard(String id) async {
    await _box.delete(id);
  }

  // 新しい名刺を作成
  static BusinessCard createNewCard({
    required String name,
    required String templateId,
  }) {
    return BusinessCard(
      id: _uuid.v4(),
      name: name,
      templateId: templateId,
      personalInfo: PersonalInfo(
        nameJa: '',
        nameEn: '',
        title: '',
        company: '',
        email: '',
        phone: '',
        profession: 'Engineer',
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
      ),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      backgroundImage: null,
      backBackgroundImage: null,
    );
  }

  // 名刺を複製
  static BusinessCard duplicateCard(BusinessCard original) {
    return BusinessCard(
      id: _uuid.v4(),
      name: '${original.name} (コピー)',
      templateId: original.templateId,
      personalInfo: PersonalInfo(
        nameJa: original.personalInfo.nameJa,
        nameEn: original.personalInfo.nameEn,
        title: original.personalInfo.title,
        catchphrase: original.personalInfo.catchphrase,
        company: original.personalInfo.company,
        email: original.personalInfo.email,
        phone: original.personalInfo.phone,
        address: original.personalInfo.address,
        website: original.personalInfo.website,
        iconImage: original.personalInfo.iconImage,
        profession: original.personalInfo.profession,
      ),
      techStack: TechStack(
        languages: List.from(original.techStack.languages),
        frameworks: List.from(original.techStack.frameworks),
        specialties: List.from(original.techStack.specialties),
      ),
      experience: Experience(
        career: original.experience.career,
        years: original.experience.years,
        achievements: List.from(original.experience.achievements),
      ),
      socialLinks: SocialLinks(
        github: original.socialLinks.github,
        twitter: original.socialLinks.twitter,
        linkedin: original.socialLinks.linkedin,
        portfolio: original.socialLinks.portfolio,
        apps: List.from(original.socialLinks.apps),
        others: List.from(original.socialLinks.others),
        frontSns1Type: original.socialLinks.frontSns1Type,
        frontSns1Value: original.socialLinks.frontSns1Value,
        frontSns2Type: original.socialLinks.frontSns2Type,
        frontSns2Value: original.socialLinks.frontSns2Value,
        frontSns3Type: original.socialLinks.frontSns3Type,
        frontSns3Value: original.socialLinks.frontSns3Value,
      ),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      backgroundImage: original.backgroundImage,
      backBackgroundImage: original.backBackgroundImage,
      backSideInfo: original.backSideInfo,
    );
  }

  // 名刺を更新
  static Future<void> updateCard(BusinessCard card) async {
    card.updatedAt = DateTime.now();
    await _box.put(card.id, card);
  }

  // 名刺をIDで取得
  static BusinessCard? getCardById(String id) {
    return _box.get(id);
  }
} 