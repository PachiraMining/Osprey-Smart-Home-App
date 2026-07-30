import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_curtain_app/core/settings/app_settings_store.dart';
import 'package:smart_curtain_app/l10n/gen/app_l10n.dart';
import 'package:smart_curtain_app/l10n/gen/app_l10n_en.dart';
import 'package:smart_curtain_app/l10n/gen/app_l10n_ja.dart';
import 'package:smart_curtain_app/l10n/gen/app_l10n_zh.dart';

void main() {
  group('AppL10n', () {
    test('mọi ngôn ngữ trong trang Language đều được app hỗ trợ', () {
      String tag(Locale l) => [
            l.languageCode,
            if (l.scriptCode != null) l.scriptCode!,
            if (l.countryCode != null) l.countryCode!,
          ].join('_');

      final generated = AppL10n.supportedLocales.map(tag).toSet();
      for (final (locale, label) in AppSettingsStore.supportedLanguages) {
        expect(generated, contains(tag(locale)),
            reason: '"$label" (${tag(locale)}) có trong picker nhưng thiếu ARB');
      }
    });

    test('có đủ 14 ngôn ngữ và KHÔNG còn tiếng Việt', () {
      expect(AppSettingsStore.supportedLanguages.length, 14);
      final codes =
          AppSettingsStore.supportedLanguages.map((e) => e.$1.languageCode);
      expect(codes, isNot(contains('vi')));
      expect(AppL10n.supportedLocales.map((l) => l.languageCode),
          isNot(contains('vi')));
    });

    test('biến thể theo chữ viết/vùng không bị trộn vào ngôn ngữ gốc', () {
      // zh vs zh_Hant, es vs es_419, pt vs pt_BR phải là các mục riêng biệt.
      final tags = AppSettingsStore.supportedLanguages
          .map((e) => e.$1)
          .map((l) => '${l.languageCode}-${l.scriptCode}-${l.countryCode}')
          .toList();
      expect(tags.toSet().length, tags.length, reason: 'có mục trùng nhau');
      expect(tags, contains('zh-Hant-null'));
      expect(tags, contains('es-null-419'));
      expect(tags, contains('pt-null-BR'));
    });

    test('bản dịch thực sự khác tiếng Anh', () {
      final en = AppL10nEn();
      final zh = AppL10nZh();
      final ja = AppL10nJa();
      for (final l in [zh, ja]) {
        expect(l.settingsTitle, isNot(en.settingsTitle));
        expect(l.clearCache, isNot(en.clearCache));
        expect(l.networkDiagnosis, isNot(en.networkDiagnosis));
        expect(l.language, isNot(en.language));
      }
    });

    test('chuỗi có tham số chèn đúng giá trị ở mọi ngôn ngữ', () {
      expect(AppL10nEn().freedSpace('26.75M'), contains('26.75M'));
      expect(AppL10nZh().freedSpace('26.75M'), contains('26.75M'));
      expect(AppL10nJa().freedSpace('26.75M'), contains('26.75M'));
      expect(AppL10nEn().aboutVersion('1.0.5', '11'), 'Version 1.0.5 (11)');
      expect(AppL10nZh().aboutVersion('1.0.5', '11'), contains('1.0.5'));
      expect(AppL10nZh().diagDnsFailed('iot.osprey.life'),
          contains('iot.osprey.life'));
    });
  });

  group('AppSettingsStore.locale', () {
    setUp(() => SharedPreferences.setMockInitialValues({}));

    test('mặc định null = theo ngôn ngữ hệ thống', () async {
      final store = AppSettingsStore(await SharedPreferences.getInstance());
      expect(store.locale, isNull);
      expect(store.localeLabel, isNull);
    });

    test('lưu và đọc lại được ngôn ngữ đã chọn', () async {
      final store = AppSettingsStore(await SharedPreferences.getInstance());
      await store.setLocale(const Locale('ja'));
      expect(store.locale?.languageCode, 'ja');
      expect(store.localeLabel, '日本語');
    });

    test('biến thể chữ viết sống sót sau khi lưu (zh_Hant KHÔNG thành zh)',
        () async {
      final store = AppSettingsStore(await SharedPreferences.getInstance());
      await store.setLocale(
          const Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hant'));
      expect(store.locale?.scriptCode, 'Hant');
      expect(store.localeLabel, '繁體中文');
    });

    test('biến thể theo vùng sống sót sau khi lưu (pt_BR, es_419)', () async {
      final store = AppSettingsStore(await SharedPreferences.getInstance());
      await store.setLocale(const Locale('pt', 'BR'));
      expect(store.locale?.countryCode, 'BR');
      await store.setLocale(const Locale('es', '419'));
      expect(store.locale?.countryCode, '419');
      expect(store.localeLabel, 'Español (latinoamérica)');
    });

    test('ngôn ngữ đã bỏ (vi) đọc ra null chứ không crash', () async {
      SharedPreferences.setMockInitialValues({'settings_locale': 'vi'});
      final store = AppSettingsStore(await SharedPreferences.getInstance());
      expect(store.locale, isNull);
    });

    test('đặt null thì quay về theo hệ thống', () async {
      final store = AppSettingsStore(await SharedPreferences.getInstance());
      await store.setLocale(const Locale('ko'));
      await store.setLocale(null);
      expect(store.locale, isNull);
    });

    test('đổi ngôn ngữ có thông báo cho listener (app rebuild ngay)', () async {
      final store = AppSettingsStore(await SharedPreferences.getInstance());
      var notified = 0;
      store.addListener(() => notified++);
      await store.setLocale(const Locale('fr'));
      expect(notified, 1);
    });
  });
}
