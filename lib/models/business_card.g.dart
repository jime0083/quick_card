// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'business_card.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class BusinessCardAdapter extends TypeAdapter<BusinessCard> {
  @override
  final int typeId = 0;

  @override
  BusinessCard read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return BusinessCard(
      id: fields[0] as String,
      name: fields[1] as String,
      templateId: fields[2] as String,
      personalInfo: fields[3] as PersonalInfo,
      techStack: fields[4] as TechStack,
      experience: fields[5] as Experience,
      socialLinks: fields[6] as SocialLinks,
      createdAt: fields[7] as DateTime,
      updatedAt: fields[8] as DateTime,
      backgroundImage: fields[9] as String?,
      backBackgroundImage: fields[10] as String?,
      backSideInfo: fields[11] as BackSideInfo?,
    );
  }

  @override
  void write(BinaryWriter writer, BusinessCard obj) {
    writer
      ..writeByte(12)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.templateId)
      ..writeByte(3)
      ..write(obj.personalInfo)
      ..writeByte(4)
      ..write(obj.techStack)
      ..writeByte(5)
      ..write(obj.experience)
      ..writeByte(6)
      ..write(obj.socialLinks)
      ..writeByte(7)
      ..write(obj.createdAt)
      ..writeByte(8)
      ..write(obj.updatedAt)
      ..writeByte(9)
      ..write(obj.backgroundImage)
      ..writeByte(10)
      ..write(obj.backBackgroundImage)
      ..writeByte(11)
      ..write(obj.backSideInfo);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BusinessCardAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class PersonalInfoAdapter extends TypeAdapter<PersonalInfo> {
  @override
  final int typeId = 1;

  @override
  PersonalInfo read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PersonalInfo(
      nameJa: fields[0] as String,
      nameEn: fields[1] as String,
      title: fields[2] as String,
      catchphrase: fields[3] as String?,
      company: fields[4] as String,
      email: fields[5] as String,
      phone: fields[6] as String,
      address: fields[7] as String?,
      website: fields[8] as String?,
      iconImage: fields[9] as String?,
      profession: fields[10] as String,
    );
  }

  @override
  void write(BinaryWriter writer, PersonalInfo obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.nameJa)
      ..writeByte(1)
      ..write(obj.nameEn)
      ..writeByte(2)
      ..write(obj.title)
      ..writeByte(3)
      ..write(obj.catchphrase)
      ..writeByte(4)
      ..write(obj.company)
      ..writeByte(5)
      ..write(obj.email)
      ..writeByte(6)
      ..write(obj.phone)
      ..writeByte(7)
      ..write(obj.address)
      ..writeByte(8)
      ..write(obj.website)
      ..writeByte(9)
      ..write(obj.iconImage)
      ..writeByte(10)
      ..write(obj.profession);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PersonalInfoAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class TechStackAdapter extends TypeAdapter<TechStack> {
  @override
  final int typeId = 2;

  @override
  TechStack read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TechStack(
      languages: (fields[0] as List).cast<String>(),
      frameworks: (fields[1] as List).cast<String>(),
      specialties: (fields[2] as List).cast<String>(),
    );
  }

  @override
  void write(BinaryWriter writer, TechStack obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.languages)
      ..writeByte(1)
      ..write(obj.frameworks)
      ..writeByte(2)
      ..write(obj.specialties);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TechStackAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ExperienceAdapter extends TypeAdapter<Experience> {
  @override
  final int typeId = 3;

  @override
  Experience read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Experience(
      career: fields[0] as String,
      years: fields[1] as int,
      achievements: (fields[2] as List).cast<String>(),
    );
  }

  @override
  void write(BinaryWriter writer, Experience obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.career)
      ..writeByte(1)
      ..write(obj.years)
      ..writeByte(2)
      ..write(obj.achievements);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExperienceAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class SocialLinksAdapter extends TypeAdapter<SocialLinks> {
  @override
  final int typeId = 4;

  @override
  SocialLinks read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SocialLinks(
      github: fields[0] as String?,
      twitter: fields[1] as String?,
      linkedin: fields[2] as String?,
      portfolio: fields[3] as String?,
      apps: (fields[4] as List).cast<String>(),
      others: (fields[5] as List).cast<String>(),
      frontSns1Type: fields[6] as String?,
      frontSns1Value: fields[7] as String?,
      frontSns2Type: fields[8] as String?,
      frontSns2Value: fields[9] as String?,
      frontSns3Type: fields[10] as String?,
      frontSns3Value: fields[11] as String?,
      frontSns4Type: fields[12] as String?,
      frontSns4Value: fields[13] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, SocialLinks obj) {
    writer
      ..writeByte(14)
      ..writeByte(0)
      ..write(obj.github)
      ..writeByte(1)
      ..write(obj.twitter)
      ..writeByte(2)
      ..write(obj.linkedin)
      ..writeByte(3)
      ..write(obj.portfolio)
      ..writeByte(4)
      ..write(obj.apps)
      ..writeByte(5)
      ..write(obj.others)
      ..writeByte(6)
      ..write(obj.frontSns1Type)
      ..writeByte(7)
      ..write(obj.frontSns1Value)
      ..writeByte(8)
      ..write(obj.frontSns2Type)
      ..writeByte(9)
      ..write(obj.frontSns2Value)
      ..writeByte(10)
      ..write(obj.frontSns3Type)
      ..writeByte(11)
      ..write(obj.frontSns3Value)
      ..writeByte(12)
      ..write(obj.frontSns4Type)
      ..writeByte(13)
      ..write(obj.frontSns4Value);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SocialLinksAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class BackSideInfoAdapter extends TypeAdapter<BackSideInfo> {
  @override
  final int typeId = 5;

  @override
  BackSideInfo read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return BackSideInfo(
      selectedCategories: (fields[0] as List).cast<String>(),
      language1: fields[1] as String?,
      language2: fields[2] as String?,
      framework1: fields[3] as String?,
      framework2: fields[4] as String?,
      qualification1: fields[5] as String?,
      qualification2: fields[6] as String?,
      career1: fields[7] as String?,
      career2: fields[8] as String?,
      career3: fields[9] as String?,
      portfolio1: fields[10] as String?,
      portfolio2: fields[11] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, BackSideInfo obj) {
    writer
      ..writeByte(12)
      ..writeByte(0)
      ..write(obj.selectedCategories)
      ..writeByte(1)
      ..write(obj.language1)
      ..writeByte(2)
      ..write(obj.language2)
      ..writeByte(3)
      ..write(obj.framework1)
      ..writeByte(4)
      ..write(obj.framework2)
      ..writeByte(5)
      ..write(obj.qualification1)
      ..writeByte(6)
      ..write(obj.qualification2)
      ..writeByte(7)
      ..write(obj.career1)
      ..writeByte(8)
      ..write(obj.career2)
      ..writeByte(9)
      ..write(obj.career3)
      ..writeByte(10)
      ..write(obj.portfolio1)
      ..writeByte(11)
      ..write(obj.portfolio2);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BackSideInfoAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
