// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get appTitle => 'Quick Card';

  @override
  String get appSubtitle => '名刺作成アプリ';

  @override
  String get selectLanguage => '言語を選択してください\nPlease select your language';

  @override
  String get japanese => '日本語';

  @override
  String get english => 'English';

  @override
  String get createCard => '名刺作成';

  @override
  String get myCards => 'マイカード';

  @override
  String get settings => '設定';

  @override
  String get name => '名前';

  @override
  String get company => '会社名';

  @override
  String get position => '役職';

  @override
  String get email => 'メールアドレス';

  @override
  String get phone => '電話番号';

  @override
  String get address => '住所';

  @override
  String get website => 'ウェブサイト';

  @override
  String get github => 'GitHub';

  @override
  String get twitter => 'Twitter';

  @override
  String get instagram => 'Instagram';

  @override
  String get youtube => 'YouTube';

  @override
  String get tiktok => 'TikTok';

  @override
  String get save => '保存';

  @override
  String get cancel => 'キャンセル';

  @override
  String get delete => '削除';

  @override
  String get edit => '編集';

  @override
  String get duplicate => '複製';

  @override
  String get preview => 'プレビュー';

  @override
  String get share => '共有';

  @override
  String get download => 'ダウンロード';

  @override
  String get selectTemplate => 'テンプレート選択';

  @override
  String get selectBackground => '背景選択';

  @override
  String get frontSide => '表面';

  @override
  String get backSide => '裏面';

  @override
  String get addCard => 'カード追加';

  @override
  String get noCards => 'カードがありません';

  @override
  String get createYourFirstCard => '最初の名刺を作成しましょう';

  @override
  String get cardSaved => 'カードを保存しました';

  @override
  String get cardDeleted => '名刺を削除しました';

  @override
  String get errorOccurred => 'エラーが発生しました';

  @override
  String get pleaseEnterName => '名前を入力してください';

  @override
  String get pleaseEnterCompany => '会社名を入力してください';

  @override
  String get pleaseEnterPosition => '役職を入力してください';

  @override
  String get pleaseEnterEmail => 'メールアドレスを入力してください';

  @override
  String get pleaseEnterPhone => '電話番号を入力してください';

  @override
  String get pleaseEnterAddress => '住所を入力してください';

  @override
  String get pleaseEnterWebsite => 'ウェブサイトURLを入力してください';

  @override
  String get pleaseEnterGithub => 'GitHubユーザー名を入力してください';

  @override
  String get pleaseEnterTwitter => 'Twitterユーザー名を入力してください';

  @override
  String get pleaseEnterInstagram => 'Instagramユーザー名を入力してください';

  @override
  String get pleaseEnterYoutube => 'YouTubeチャンネルを入力してください';

  @override
  String get pleaseEnterTiktok => 'TikTokユーザー名を入力してください';

  @override
  String get today => '今日';

  @override
  String get yesterday => '昨日';

  @override
  String daysAgo(Object days) {
    return '$days日前';
  }

  @override
  String updated(Object date) {
    return '更新: $date';
  }

  @override
  String get cardDuplicated => '名刺を複製しました';

  @override
  String get shareFeatureComingSoon => '共有機能は準備中です';

  @override
  String get deleteCardTitle => '名刺を削除';

  @override
  String deleteCardMessage(Object name) {
    return '「$name」を削除しますか？';
  }

  @override
  String get language => '言語';

  @override
  String get framework => 'FW(フレームワーク)';

  @override
  String get qualification => '資格';

  @override
  String get career => '経歴';

  @override
  String get portfolio => 'ポートフォリオ';

  @override
  String get selectCategories => 'カテゴリ選択';

  @override
  String get createBusinessCard => '名刺を作成';

  @override
  String get selectFromGallery => 'カメラロールから選択';

  @override
  String get deleteImage => '画像を削除';

  @override
  String get nameJapanese => '氏名（日本語）';

  @override
  String get nameEnglish => '氏名（英語）';

  @override
  String get profession => '職業';

  @override
  String get snsContact => 'SNS・連絡先（4つまで選択）';

  @override
  String get nameJapaneseRequired => '氏名（日本語）は必須です';

  @override
  String get nameEnglishRequired => '氏名（英語）は必須です';

  @override
  String get selectAtLeastOneItem => '1つ以上の項目を選択してください';

  @override
  String get enterContentForEachItem => '各項目の内容を入力してください';
}
