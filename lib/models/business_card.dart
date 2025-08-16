import 'package:hive/hive.dart';

part 'business_card.g.dart';

@HiveType(typeId: 0)
class BusinessCard extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String templateId;

  @HiveField(3)
  PersonalInfo personalInfo;

  @HiveField(4)
  TechStack techStack;

  @HiveField(5)
  Experience experience;

  @HiveField(6)
  SocialLinks socialLinks;

  @HiveField(7)
  DateTime createdAt;

  @HiveField(8)
  DateTime updatedAt;

  @HiveField(9)
  String? backgroundImage;

  @HiveField(10)
  String? backBackgroundImage;

  @HiveField(11)
  BackSideInfo? backSideInfo;

  BusinessCard({
    required this.id,
    required this.name,
    required this.templateId,
    required this.personalInfo,
    required this.techStack,
    required this.experience,
    required this.socialLinks,
    required this.createdAt,
    required this.updatedAt,
    this.backgroundImage,
    this.backBackgroundImage,
    this.backSideInfo,
  });

  BusinessCard copyWith({
    String? id,
    String? name,
    String? templateId,
    PersonalInfo? personalInfo,
    TechStack? techStack,
    Experience? experience,
    SocialLinks? socialLinks,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? backgroundImage,
    String? backBackgroundImage,
    BackSideInfo? backSideInfo,
  }) {
    return BusinessCard(
      id: id ?? this.id,
      name: name ?? this.name,
      templateId: templateId ?? this.templateId,
      personalInfo: personalInfo ?? this.personalInfo,
      techStack: techStack ?? this.techStack,
      experience: experience ?? this.experience,
      socialLinks: socialLinks ?? this.socialLinks,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      backgroundImage: backgroundImage ?? this.backgroundImage,
      backBackgroundImage: backBackgroundImage ?? this.backBackgroundImage,
      backSideInfo: backSideInfo ?? this.backSideInfo,
    );
  }
}

@HiveType(typeId: 1)
class PersonalInfo {
  @HiveField(0)
  String nameJa;

  @HiveField(1)
  String nameEn;

  @HiveField(2)
  String title;

  @HiveField(3)
  String? catchphrase;

  @HiveField(4)
  String company;

  @HiveField(5)
  String email;

  @HiveField(6)
  String phone;

  @HiveField(7)
  String? address;

  @HiveField(8)
  String? website;

  // 表面の新しいフィールド
  @HiveField(9)
  String? iconImage; // アイコン画像のパス

  @HiveField(10)
  String profession; // "Engineer" or "Solo maker"

  PersonalInfo({
    required this.nameJa,
    required this.nameEn,
    required this.title,
    this.catchphrase,
    required this.company,
    required this.email,
    required this.phone,
    this.address,
    this.website,
    this.iconImage,
    required this.profession,
  });
}

@HiveType(typeId: 2)
class TechStack {
  @HiveField(0)
  List<String> languages;

  @HiveField(1)
  List<String> frameworks;

  @HiveField(2)
  List<String> specialties;

  TechStack({
    required this.languages,
    required this.frameworks,
    required this.specialties,
  });
}

@HiveType(typeId: 3)
class Experience {
  @HiveField(0)
  String career;

  @HiveField(1)
  int years;

  @HiveField(2)
  List<String> achievements;

  Experience({
    required this.career,
    required this.years,
    required this.achievements,
  });
}

@HiveType(typeId: 4)
class SocialLinks {
  @HiveField(0)
  String? github;

  @HiveField(1)
  String? twitter;

  @HiveField(2)
  String? linkedin;

  @HiveField(3)
  String? portfolio;

  @HiveField(4)
  List<String> apps;

  @HiveField(5)
  List<String> others;

  // 表面のSNS選択用（4つまで）
  @HiveField(6)
  String? frontSns1Type; // "X(Twitter)", "インスタ", "Github", "メールアドレス", "Tiktok", "Youtube"

  @HiveField(7)
  String? frontSns1Value;

  @HiveField(8)
  String? frontSns2Type;

  @HiveField(9)
  String? frontSns2Value;

  @HiveField(10)
  String? frontSns3Type;

  @HiveField(11)
  String? frontSns3Value;

  @HiveField(12)
  String? frontSns4Type;

  @HiveField(13)
  String? frontSns4Value;

  SocialLinks({
    this.github,
    this.twitter,
    this.linkedin,
    this.portfolio,
    required this.apps,
    required this.others,
    this.frontSns1Type,
    this.frontSns1Value,
    this.frontSns2Type,
    this.frontSns2Value,
    this.frontSns3Type,
    this.frontSns3Value,
    this.frontSns4Type,
    this.frontSns4Value,
  });
}

// 裏面の情報
@HiveType(typeId: 5)
class BackSideInfo {
  @HiveField(0)
  List<String> selectedCategories; // 選択された4つのカテゴリ

  @HiveField(1)
  String? language1;

  @HiveField(2)
  String? language2;

  @HiveField(3)
  String? framework1;

  @HiveField(4)
  String? framework2;

  @HiveField(5)
  String? qualification1;

  @HiveField(6)
  String? qualification2;

  @HiveField(7)
  String? career1;

  @HiveField(8)
  String? career2;

  @HiveField(9)
  String? career3;

  @HiveField(10)
  String? portfolio1;

  @HiveField(11)
  String? portfolio2;

  BackSideInfo({
    required this.selectedCategories,
    this.language1,
    this.language2,
    this.framework1,
    this.framework2,
    this.qualification1,
    this.qualification2,
    this.career1,
    this.career2,
    this.career3,
    this.portfolio1,
    this.portfolio2,
  });
} 