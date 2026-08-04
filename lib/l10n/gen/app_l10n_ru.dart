// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_l10n.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppL10nRu extends AppL10n {
  AppL10nRu([String locale = 'ru']) : super(locale);

  @override
  String get settingsTitle => 'Настройки';

  @override
  String get personalInformation => 'Личные данные';

  @override
  String get accountAndSecurity => 'Аккаунт и безопасность';

  @override
  String get touchToneOnPanel => 'Звук нажатий на панели';

  @override
  String get aiAssistant => 'AI-ассистент';

  @override
  String get temperatureUnit => 'Единица температуры';

  @override
  String get about => 'О программе';

  @override
  String get networkDiagnosis => 'Диагностика сети';

  @override
  String get clearCache => 'Очистить кэш';

  @override
  String get language => 'Язык';

  @override
  String get logOut => 'Выйти';

  @override
  String get languageSystemDefault => 'Как в системе';

  @override
  String get languageEnglish => 'Английский';

  @override
  String get languageVietnamese => 'Вьетнамский';

  @override
  String get clearCacheMessage =>
      'Сохранённые в кэше сценарии, данные дома и изображения будут загружены заново при следующем использовании. Аккаунт и устройства не затрагиваются.';

  @override
  String get clear => 'Очистить';

  @override
  String get cancel => 'Отмена';

  @override
  String freedSpace(String size) {
    return 'Освобождено $size';
  }

  @override
  String aboutVersion(String version, String build) {
    return 'Версия $version ($build)';
  }

  @override
  String get privacyPolicy => 'Политика конфиденциальности';

  @override
  String get termsOfService => 'Условия использования';

  @override
  String get bundleId => 'Bundle ID';

  @override
  String get server => 'Сервер';

  @override
  String get couldNotOpenLink => 'Не удалось открыть ссылку.';

  @override
  String get diagLocalNetwork => 'Локальная сеть';

  @override
  String get diagLocalNetworkNoWifi =>
      'Нет Wi-Fi (мобильные данные или нет разрешения)';

  @override
  String get diagLocalNetworkUnreadable => 'Не удалось получить имя Wi-Fi';

  @override
  String get diagDnsLookup => 'DNS-запрос';

  @override
  String diagDnsFailed(String host) {
    return 'Не удалось разрешить $host';
  }

  @override
  String get diagServerReachable => 'Сервер доступен';

  @override
  String diagServerLatency(String ms, String status) {
    return '$ms мс · HTTP $status';
  }

  @override
  String get diagServerNoResponse => 'Сервер не отвечает';

  @override
  String get diagSignedIn => 'Вход выполнен';

  @override
  String get diagSessionValid => 'Сессия действительна';

  @override
  String diagSessionInvalid(String status) {
    return 'HTTP $status — войдите снова';
  }

  @override
  String get diagSessionUnverified => 'Не удалось проверить сессию';

  @override
  String get diagControlChannel => 'Канал управления';

  @override
  String get diagCloudConnected => 'Облако (MQTT) подключено';

  @override
  String get diagBleFallback => 'Облако недоступно — используется Bluetooth';

  @override
  String get diagUnreachable => 'Нет облака и Bluetooth рядом';

  @override
  String get diagStatusUnknown => 'Статус неизвестен';

  @override
  String get runAgain => 'Запустить снова';

  @override
  String get accountCreatedPleaseSignIn => 'Аккаунт создан — войдите.';

  @override
  String get add => 'Добавить';

  @override
  String get addCondition => 'Добавить условие';

  @override
  String get addRoom => 'Добавить комнату';

  @override
  String get addTask => 'Добавить задачу';

  @override
  String get addAtLeastTwoDevicesToAGroup =>
      'Добавьте в группу не менее двух устройств.';

  @override
  String get alexa => 'Alexa';

  @override
  String get all => 'Все';

  @override
  String get allDevices => 'Все устройства';

  @override
  String get alternateNetwork => 'Другая сеть';

  @override
  String get apply => 'Применить';

  @override
  String get areYouSureYouWantToLogOut => 'Точно выйти из аккаунта?';

  @override
  String get askAboutYourCurtainsOrTryHelp =>
      'Спросите о шторах или введите /help…';

  @override
  String get askAboutYourCurtains => 'Спросите о шторах…';

  @override
  String get atLeast6Characters => 'Минимум 6 символов';

  @override
  String get authDiagnostics => 'Диагностика входа';

  @override
  String get automationNotification => 'Уведомление автоматизации';

  @override
  String get changeRoom => 'Сменить комнату';

  @override
  String get close => 'Закрыть';

  @override
  String get cloud => 'Облако';

  @override
  String get confirm => 'Подтвердить';

  @override
  String get connected => 'Подключено';

  @override
  String get control => 'Управление';

  @override
  String get controlSingleDevice => 'Управлять устройством';

  @override
  String get copiedToClipboard => 'Скопировано в буфер';

  @override
  String get copy => 'Копировать';

  @override
  String get couldNotChangeTheMotorDirectionPleaseTryAgai =>
      'Не удалось изменить направление мотора. Попробуйте снова.';

  @override
  String get couldNotConnect => 'Не удалось подключиться';

  @override
  String get couldNotCreateTheGroupPleaseTryAgain =>
      'Не удалось создать группу. Попробуйте снова.';

  @override
  String get couldNotOpenTheBrowser => 'Не удалось открыть браузер.';

  @override
  String get couldNotSendTheCommandPleaseTryAgain =>
      'Не удалось отправить команду. Попробуйте снова.';

  @override
  String get create => 'Создать';

  @override
  String get createScene => 'Создать сценарий';

  @override
  String get createAHome => 'Создать дом';

  @override
  String get createARoomFirst => 'Сначала создайте комнату.';

  @override
  String get createAccount => 'Создать аккаунт';

  @override
  String get createScene2 => 'Создать сценарий';

  @override
  String get curtainPosition => 'Положение шторы';

  @override
  String get curtainPositionSetting => 'Настройка положения шторы';

  @override
  String get customDeviceIconsAreNotSupportedYet =>
      'Свои значки устройств пока не поддерживаются.';

  @override
  String get delayTheAction => 'Задержать действие';

  @override
  String get delete => 'Удалить';

  @override
  String get deleteAccount => 'Удалить аккаунт';

  @override
  String get deleteHome => 'Удалить дом';

  @override
  String get deleteRoom => 'Удалить комнату';

  @override
  String get deleteSchedule => 'Удалить расписание';

  @override
  String get deleteScene => 'Удалить сценарий?';

  @override
  String get deleteThisSchedule => 'Удалить это расписание?';

  @override
  String get deviceNetwork => 'Сеть устройства';

  @override
  String get deviceHasNoProfileInformation => 'У устройства нет данных профиля';

  @override
  String get deviceIsOffline => 'Устройство офлайн';

  @override
  String get deviceIsReady => 'Устройство готово.';

  @override
  String get deviceName => 'Название устройства';

  @override
  String get deviceRemovedFromHome => 'Устройство удалено из дома.';

  @override
  String get deviceUnreachable => 'Устройство недоступно';

  @override
  String get devices => 'Устройства';

  @override
  String get disconnect => 'Отключить';

  @override
  String get disconnectDevice => 'Отключить устройство?';

  @override
  String get done => 'Готово';

  @override
  String get emailAddress => 'Адрес email';

  @override
  String get emailOrUsername => 'Email или логин';

  @override
  String get enterAGroupName => 'Введите название группы';

  @override
  String get enterANote => 'Введите заметку';

  @override
  String get enterDeviceName => 'Введите название устройства';

  @override
  String get enterHomeName => 'Введите название дома';

  @override
  String get enterName => 'Введите название';

  @override
  String get enterSceneName => 'Введите название сценария';

  @override
  String get enterValue => 'Введите значение...';

  @override
  String get enterYourPassword => 'Введите пароль';

  @override
  String get eraseDeviceData => 'Стереть данные устройства?';

  @override
  String get error => 'Ошибка';

  @override
  String get executedBy => 'Кем выполнено';

  @override
  String get executionTime => 'Время выполнения';

  @override
  String get faqFeedback => 'FAQ и отзывы';

  @override
  String get failed => 'Не удалось';

  @override
  String get featureComingSoon => 'Функция скоро появится';

  @override
  String get firmware => 'Прошивка';

  @override
  String get firmwareUpdateIsComingSoon =>
      'Обновление прошивки скоро появится.';

  @override
  String get firstName => 'Имя';

  @override
  String get firstNameOptional => 'Имя (необязательно)';

  @override
  String get goBack => 'Назад';

  @override
  String get googleAssistant => 'Google Assistant';

  @override
  String get gotIt => 'Понятно';

  @override
  String get groupName => 'Название группы';

  @override
  String get help => 'Помощь';

  @override
  String get homeManagement => 'Управление домами';

  @override
  String get homeName => 'Название дома';

  @override
  String get homeName2 => 'Название дома';

  @override
  String get icon => 'Значок';

  @override
  String get conditionIf => 'Если';

  @override
  String get joinAHome => 'Присоединиться к дому';

  @override
  String get joiningAHomeByInviteIsComingSoon =>
      'Присоединение к дому по приглашению скоро появится.';

  @override
  String get lastName => 'Фамилия';

  @override
  String get lastNameOptional => 'Фамилия (необязательно)';

  @override
  String get later => 'Позже';

  @override
  String get launchTapToRun => 'Запустить Tap-to-Run';

  @override
  String get localAssociation => 'Локальная привязка';

  @override
  String get localControlOffline => 'Локальное управление (офлайн)';

  @override
  String get location => 'Местоположение';

  @override
  String get logCopiedToClipboard => 'Журнал скопирован в буфер';

  @override
  String get logs => 'Журнал';

  @override
  String get manage => 'Управлять';

  @override
  String get managePermissions => 'Управление доступом';

  @override
  String get markAllAsRead => 'Отметить всё прочитанным';

  @override
  String get moreSettings => 'Другие настройки';

  @override
  String get motorDirection => 'Направление мотора';

  @override
  String get moveToTop => 'Переместить наверх';

  @override
  String get moveToRoom => 'Переместить в комнату';

  @override
  String get moved => 'Перемещено';

  @override
  String get movedToTop => 'Перемещено наверх';

  @override
  String get name => 'Название';

  @override
  String get next => 'Далее';

  @override
  String get noDevicesAvailable => 'Нет доступных устройств';

  @override
  String get noDevicesFound => 'Устройства не найдены.';

  @override
  String get noDevicesInThisHome => 'В этом доме нет устройств.';

  @override
  String get noDevicesYet => 'Устройств пока нет';

  @override
  String get noFunctionsAvailable => 'Нет доступных функций';

  @override
  String get noHomeSelectedPleaseTryAgain => 'Дом не выбран, попробуйте снова';

  @override
  String get noMatchingTimeZones => 'Часовые пояса не найдены';

  @override
  String get noOtherScenesAvailable => 'Других сценариев нет';

  @override
  String get noRooms => 'Нет комнат';

  @override
  String get noSavedNetworksYet => 'Сохранённых сетей пока нет.';

  @override
  String get noScenes => 'Нет сценариев';

  @override
  String get noScenesAvailable => 'Нет доступных сценариев';

  @override
  String get note => 'Заметка';

  @override
  String get notification => 'Уведомление';

  @override
  String get ok => 'OK';

  @override
  String get offlineNotification => 'Уведомление об офлайне';

  @override
  String get open => 'Открыть';

  @override
  String get openSettings => 'Открыть настройки';

  @override
  String get outdoorPm25 => 'PM2.5 на улице';

  @override
  String get outdoorAirPressure => 'Давление на улице';

  @override
  String get outdoorHumidity => 'Влажность на улице';

  @override
  String get outdoorWindSpeed => 'Скорость ветра';

  @override
  String get pairingSuccessful => 'Сопряжение выполнено';

  @override
  String get password => 'Пароль';

  @override
  String get sessionExpiredSignInAgain => 'Сессия истекла. Войдите снова.';

  @override
  String get pleaseAddAtLeast1Action => 'Добавьте хотя бы 1 действие';

  @override
  String get pleaseAddAtLeast1Condition => 'Добавьте хотя бы 1 условие';

  @override
  String get pleaseEnterAName => 'Введите название';

  @override
  String get pleaseEnterASceneName => 'Введите название сценария';

  @override
  String get pleaseSelectAFunction => 'Выберите функцию';

  @override
  String get pleaseSelectATime0 => 'Выберите время > 0';

  @override
  String get rePairNow => 'Сопрячь снова';

  @override
  String get rePairRequired => 'Нужно сопряжение заново';

  @override
  String get reasonOptional => 'Причина (необязательно)';

  @override
  String get refresh => 'Обновить';

  @override
  String get reload => 'Перезагрузить';

  @override
  String get remove => 'Убрать';

  @override
  String get removeDevice => 'Удалить устройство';

  @override
  String get removed => 'Удалено';

  @override
  String get rename => 'Переименовать';

  @override
  String get renameRoom => 'Переименовать комнату';

  @override
  String get renameDevice => 'Переименовать устройство';

  @override
  String get repeat => 'Повтор';

  @override
  String get rescan => 'Сканировать снова';

  @override
  String get retry => 'Повторить';

  @override
  String get roomManagement => 'Управление комнатами';

  @override
  String get roomName => 'Название комнаты';

  @override
  String get roomUpdated => 'Комната обновлена';

  @override
  String get running => 'Выполняется';

  @override
  String get save => 'Сохранить';

  @override
  String get sceneName => 'Название сценария';

  @override
  String get scenes => 'Сценарии';

  @override
  String get schedule => 'Расписание';

  @override
  String get searchAddress => 'Поиск адреса';

  @override
  String get searchCityOrRegion => 'Поиск города или региона';

  @override
  String get selectScene => 'Выбрать сценарий';

  @override
  String get selectSmartScenes => 'Выберите умные сценарии';

  @override
  String get sendResetLink => 'Отправить ссылку для сброса';

  @override
  String get sendVerificationCode => 'Отправить код';

  @override
  String get showOnHomePage => 'Показывать на главной';

  @override
  String get signIn => 'Войти';

  @override
  String get signalStrength => 'Уровень сигнала';

  @override
  String get signalStrength2 => 'Уровень сигнала';

  @override
  String get startPairing => 'Начать сопряжение';

  @override
  String get stop => 'Стоп';

  @override
  String get style => 'Стиль';

  @override
  String get switchNetwork => 'Сменить';

  @override
  String get switchToThisNetwork => 'Переключиться на эту сеть';

  @override
  String get tapToRunNotification => 'Уведомление Tap-to-Run';

  @override
  String get conditionThen => 'То';

  @override
  String get thinking => 'Думаю…';

  @override
  String get thisActionCannotBeUndone => 'Это действие нельзя отменить.';

  @override
  String get thisSavedNetworkWillBeRemovedFromTheDevice =>
      'Эта сохранённая сеть будет удалена с устройства.';

  @override
  String get timeZone => 'Часовой пояс';

  @override
  String get timeZoneUpdated => 'Часовой пояс обновлён';

  @override
  String get timedOut => 'Время ожидания истекло';

  @override
  String get tryAgain => 'Попробовать снова';

  @override
  String get useCurrentLocation => 'Текущее местоположение';

  @override
  String get usingSiri => 'С помощью Siri';

  @override
  String get virtualId => 'Virtual ID';

  @override
  String get whenDeviceStatusChanges => 'При изменении статуса устройства';

  @override
  String get whenWeatherChanges => 'При изменении погоды';

  @override
  String get wiFi => 'Wi-Fi';

  @override
  String get wifiNameSsid => 'Имя WiFi (SSID)';

  @override
  String get wifiPassword => 'Пароль WiFi';

  @override
  String get navHome => 'Дом';

  @override
  String get navScenes => 'Сценарии';

  @override
  String get navChat => 'Чат';

  @override
  String get navMe => 'Я';

  @override
  String get thirdPartyServices => 'Сторонние сервисы';

  @override
  String get messageCenter => 'Центр сообщений';

  @override
  String get appMall => 'Магазин приложений';

  @override
  String get addDevice => 'Добавить устройство';

  @override
  String get tapToRun => 'Запуск одним касанием';

  @override
  String get automationEmptyHint =>
      'Автоматизация экономит время и силы, выполняя рутинные задачи за вас.';

  @override
  String get tapToRunEmptyHint =>
      'Создайте сценарий запуска одним касанием, чтобы управлять устройствами одним нажатием.';

  @override
  String get scene => 'Сценарий';

  @override
  String get executionFailed => 'Не удалось выполнить';

  @override
  String get device => 'Устройство';

  @override
  String get delay => 'Пауза';

  @override
  String get runScene => 'Запустить сценарий';

  @override
  String get addToSiri => 'Добавить в Siri';

  @override
  String get storeUnderPreparation =>
      'Магазин готовится к запуску, следите за обновлениями.';

  @override
  String get commonFunctions => 'Основные функции';

  @override
  String get noConnection => 'Нет соединения';

  @override
  String get checkInternetAndRetry =>
      'Проверьте подключение к интернету и попробуйте снова.';

  @override
  String get noConnectionCheckInternet =>
      'Нет соединения. Проверьте интернет и попробуйте снова.';

  @override
  String get addFirstCurtainHint =>
      'Нажмите +, чтобы добавить первую штору в этот дом.';

  @override
  String get hideInvisibleDevices => 'Скрыть невидимые устройства';

  @override
  String get deviceRenamed => 'Устройство переименовано.';

  @override
  String get deviceDeletedReturningToPairing =>
      'Устройство удалено. Оно вернётся в режим сопряжения.';

  @override
  String get homeSettings => 'Настройки дома';

  @override
  String get toBeSet => 'Не задано';

  @override
  String get homeMember => 'Участник дома';

  @override
  String get memberDetails => 'Данные участника';

  @override
  String get addMember => 'Добавить участника';

  @override
  String get pending => 'Ожидает';

  @override
  String get removesFromHomeHint =>
      'Удаляется из дома; устройство вернётся в режим сопряжения через 1–2 минуты';

  @override
  String get unlinkAndEraseData => 'Отвязать и удалить данные';

  @override
  String get erasesAllDataHint =>
      'Удаляет все данные без возможности восстановления';

  @override
  String get somethingWentWrongTryAgain =>
      'Что-то пошло не так, попробуйте снова';

  @override
  String get tapToRunAndAutomation => 'Запуск одним касанием и автоматизация';

  @override
  String get thirdPartyControl => 'Управление через сторонние сервисы';

  @override
  String get deviceOfflineNotification =>
      'Уведомление об отключении устройства';

  @override
  String get others => 'Прочее';

  @override
  String get shareDevice => 'Поделиться устройством';

  @override
  String get addToHomeScreen => 'Добавить на экран «Домой»';

  @override
  String get checkDeviceNetwork => 'Проверить сеть устройства';

  @override
  String get checkNow => 'Проверить';

  @override
  String get deviceUpdate => 'Обновление устройства';

  @override
  String get removeDevicesWarning =>
      'Они будут удалены из этого дома и вернутся в режим сопряжения.';

  @override
  String get shown => 'Показано';

  @override
  String get hidden => 'Скрыто';

  @override
  String get devicesBackOnHome => 'Устройства снова на главной';

  @override
  String get hiddenFromHome => 'Скрыты с главной';

  @override
  String get offline => 'Не в сети';

  @override
  String get show => 'Показать';

  @override
  String get hide => 'Скрыть';

  @override
  String get profilePhoto => 'Фото профиля';

  @override
  String get nickname => 'Псевдоним';

  @override
  String get noRoomsYet => 'Комнат пока нет';

  @override
  String get tapPlusToAddRoom => 'Нажмите +, чтобы добавить комнату';

  @override
  String get emailAddressLabel => 'Адрес эл. почты';

  @override
  String get notSet => 'Не задано';

  @override
  String get deviceInformation => 'Информация об устройстве';

  @override
  String get unknown => 'Неизвестно';

  @override
  String get notReported => 'Нет данных';

  @override
  String get noScenesUseThisDevice =>
      'Пока ни один сценарий не использует это устройство.';

  @override
  String get tapToRunLabel => 'Запуск одним касанием';

  @override
  String get automation => 'Автоматизация';

  @override
  String get forward => 'Прямое';

  @override
  String get back => 'Обратное';

  @override
  String get setting => 'Настройка';

  @override
  String get updateAvailable => 'Доступно обновление';

  @override
  String get noUpdatesAvailable => 'Обновлений нет';

  @override
  String get updateNow => 'Обновить';

  @override
  String get unassigned => 'Не назначено';

  @override
  String get enterEmailOrUsername => 'Введите эл. почту или имя пользователя';

  @override
  String get welcome => 'Добро пожаловать';

  @override
  String get signInSubtitle => 'Войдите в свою учётную запись osprey.life.';

  @override
  String get createOne => 'Создать';

  @override
  String get forgotPassword => 'Забыли пароль?';

  @override
  String get orContinueWith => 'или войдите через';

  @override
  String get enterValidEmail => 'Введите корректный адрес эл. почты';

  @override
  String get resetYourPassword => 'Сброс пароля';

  @override
  String get checkYourInbox => 'Проверьте почту';

  @override
  String get enterYourEmailAddress => 'Введите адрес эл. почты';

  @override
  String get enterSixDigitCode => 'Введите 6-значный код';

  @override
  String get enterAPassword => 'Введите пароль';

  @override
  String get createYourAccount => 'Создайте учётную запись';

  @override
  String get checkYourEmail => 'Проверьте письмо';

  @override
  String get resendCode => 'Отправить код снова';

  @override
  String get userAgreement => 'Пользовательское соглашение';

  @override
  String get reconnecting => 'Переподключение…';

  @override
  String get checkWifiOrBluetooth =>
      'Проверьте Wi-Fi или подойдите ближе для Bluetooth.';

  @override
  String get smartScenesRequireInternet => 'Умным сценариям нужен интернет';

  @override
  String get enterWifiName => 'Введите имя сети Wi-Fi';

  @override
  String get wifiNameLengthError =>
      'Имя сети Wi-Fi должно содержать от 1 до 32 символов';

  @override
  String get passwordMin8 => 'Пароль должен содержать не менее 8 символов';

  @override
  String get passwordLength863 => 'Пароль должен содержать от 8 до 63 символов';

  @override
  String get networkAlreadySaved =>
      'Эта сеть уже сохранена. Чтобы изменить пароль, удалите её и добавьте снова.';

  @override
  String get addWifiNetwork => 'Добавить сеть Wi-Fi';

  @override
  String get atLeast8Characters => 'Не менее 8 символов';

  @override
  String get only24GhzSupported =>
      'Устройства для штор поддерживают только Wi-Fi 2,4 ГГц (WPA2).';

  @override
  String get labelOptional => 'Метка (необязательно)';

  @override
  String get createGroup => 'Создать группу';

  @override
  String get groupControlHint =>
      'Устройствами одной группы можно управлять вместе.';

  @override
  String get devicesToBeAdded => 'Устройства для добавления';

  @override
  String get noSameTypeDevices =>
      'В этом доме нет других устройств такого же типа.';

  @override
  String get couldNotLoadNetworkDetails =>
      'Не удалось загрузить данные о сети. Потяните, чтобы обновить.';

  @override
  String get alreadyOnThisNetwork => 'Уже подключено к этой сети.';

  @override
  String get deviceOfflineTryLater =>
      'Устройство не в сети — попробуйте позже.';

  @override
  String get wrongPassword => 'Неверный пароль';

  @override
  String get networkNotFound => 'Сеть не найдена';

  @override
  String get networkRemoved => 'Сеть удалена.';

  @override
  String get network => 'Сеть';

  @override
  String get connectedTo => 'Подключено к';

  @override
  String get savedNetworks => 'Сохранённые сети';

  @override
  String get addANetwork => 'Добавить сеть';

  @override
  String get notConnected => 'Не подключено';

  @override
  String get pleaseKeepAppOpen => 'Не закрывайте приложение.';

  @override
  String get deviceNetworkInformation => 'Сетевые данные устройства';

  @override
  String get once => 'Один раз';

  @override
  String get editSchedule => 'Изменить расписание';

  @override
  String get addSchedule => 'Добавить расписание';

  @override
  String get timeVarianceHint => 'Погрешность времени — около ±30 с';

  @override
  String get noTimerData => 'Нет данных таймера';

  @override
  String get localControlUnsupportedAction =>
      'Локальное управление не поддерживает это действие';

  @override
  String get noInternetNoBluetooth =>
      'Нет интернета, Bluetooth вне зоны действия';

  @override
  String get connectionError => 'Ошибка подключения';

  @override
  String get exampleTapToRun =>
      'Пример: выключить весь свет в спальне одним касанием.';

  @override
  String get exampleWeather => 'Пример: когда температура на улице выше 28 °C.';

  @override
  String get weatherTrigger => 'Условие по погоде';

  @override
  String get exampleSchedule => 'Пример: каждое утро в 7:00.';

  @override
  String get exampleDeviceStatus =>
      'Пример: при обнаружении необычной активности.';

  @override
  String get deviceStatusTrigger => 'Условие по состоянию устройства';

  @override
  String get noNotificationsYet => 'Уведомлений пока нет';

  @override
  String get slashCommands => 'Слэш-команды';

  @override
  String get slashDevicesHint => 'Просмотр и управление шторами.';

  @override
  String get slashSceneHint => 'Запустить сценарий одним касанием.';

  @override
  String get slashScheduleHint => 'Открыть расписание автоматизации.';

  @override
  String get slashHelpHint => 'Показать этот список.';

  @override
  String get youCanAlsoSpeak => 'Можно и голосом — нажмите кнопку микрофона.';

  @override
  String get chatInputHint => 'Пишите, говорите или используйте слэш-команды.';

  @override
  String get online => 'В сети';

  @override
  String get blePermissionRequired =>
      'Для поиска устройств нужно разрешение на Bluetooth';

  @override
  String get bleAndLocationPermissionRequired =>
      'Для поиска устройств нужны разрешения на Bluetooth и геопозицию';

  @override
  String get addDeviceLower => 'Добавить устройство';

  @override
  String get scanningStopped => 'Поиск остановлен.';

  @override
  String get enterWifiPassword => 'Введите пароль Wi-Fi';

  @override
  String get detectingCurrentWifi => 'Определение текущей сети Wi-Fi...';

  @override
  String get autoDetectedWifi =>
      'Определено автоматически по сети Wi-Fi, к которой подключён телефон';

  @override
  String get couldNotDetectWifi =>
      'Не удалось определить Wi-Fi — введите имя сети вручную';

  @override
  String get beingAdded => 'Добавляется';

  @override
  String get addedSuccessfully => 'Успешно добавлено';

  @override
  String get pairingFailed => 'Не удалось выполнить сопряжение';

  @override
  String get allDay => 'Весь день';

  @override
  String get whenAnyConditionMet => 'Когда выполнено любое условие';

  @override
  String get whenAllConditionsMet => 'Когда выполнены все условия';

  @override
  String get deleteSceneWarning =>
      'После удаления сценария задачи устройств больше не будут выполняться корректно.';

  @override
  String get toggleAutomation => 'Включить или выключить автоматизацию';

  @override
  String get enable => 'Включить';

  @override
  String get disable => 'Выключить';

  @override
  String get everyDay => 'Каждый день';

  @override
  String get monToFri => 'Пн – Пт';

  @override
  String get satToSun => 'Сб – Вс';

  @override
  String get runOnceIfNoDaySelected =>
      'Если не выбрать ни один день недели, действие выполнится только один раз.';

  @override
  String get sendNotification => 'Отправить уведомление';

  @override
  String get color => 'Цвет';

  @override
  String get wait => 'Ожидание';

  @override
  String get finish => 'Готово';

  @override
  String get selectFunction => 'Выбрать функцию';

  @override
  String get on => 'Вкл.';

  @override
  String get off => 'Выкл.';

  @override
  String get siriShortcut => 'Команда Siri';

  @override
  String get createTapToRunFirst =>
      'Сначала создайте сценарий запуска одним касанием.';

  @override
  String get poweredByFoundationModels =>
      'На основе Apple Foundation Models, прямо на устройстве.';

  @override
  String get weatherClearNight => 'Ясная ночь';

  @override
  String get weatherSunny => 'Солнечно';

  @override
  String get weatherPartlyCloudy => 'Переменная облачность';

  @override
  String get weatherCloudy => 'Облачно';

  @override
  String get qualityExcellent => 'Отлично';

  @override
  String get qualityGood => 'Хорошо';

  @override
  String get qualityModerate => 'Умеренно';

  @override
  String get qualityPoor => 'Плохо';

  @override
  String get qualityVeryPoor => 'Очень плохо';

  @override
  String get switchLocation => 'Изменить место';

  @override
  String get aiSuggestion => 'Подсказка ИИ';

  @override
  String get listening => 'Слушаю…';

  @override
  String get parsing => 'Обработка…';

  @override
  String get getStarted => 'Начать';

  @override
  String get aiChatEmptyState =>
      'Спросите ассистента osprey.life о чём угодно, что связано со шторами.\nНа основе Apple Foundation Models, прямо на устройстве.';

  @override
  String get chatHeaderSubtitle =>
      'ИИ на устройстве для ваших электрокарнизов.\nПишите, говорите или используйте слэш-команды.';

  @override
  String get daySunShort => 'Вс';

  @override
  String get dayMonShort => 'Пн';

  @override
  String get dayTueShort => 'Вт';

  @override
  String get dayWedShort => 'Ср';

  @override
  String get dayThuShort => 'Чт';

  @override
  String get dayFriShort => 'Пт';

  @override
  String get daySatShort => 'Сб';

  @override
  String get dayMon => 'Пн';

  @override
  String get dayTue => 'Вт';

  @override
  String get dayWed => 'Ср';

  @override
  String get dayThu => 'Чт';

  @override
  String get dayFri => 'Пт';

  @override
  String get daySat => 'Сб';

  @override
  String get daySun => 'Вс';

  @override
  String get accountLinkedSuccessfully => 'Учётная запись успешно привязана!';

  @override
  String get linkingFailed => 'Не удалось привязать';

  @override
  String get anErrorOccurredTryAgain => 'Произошла ошибка. Попробуйте снова.';

  @override
  String get signInWithAmazon => 'Войти через Amazon';

  @override
  String get viewMoreWaysToLink => 'Другие способы привязки';

  @override
  String get alreadyLinkedWithAlexa => 'Уже привязано к Amazon Alexa';

  @override
  String get somethingWentWrong => 'Что-то пошло не так';

  @override
  String get noAuthorizationCode => 'Код авторизации не получен';

  @override
  String get couldNotOpenGoogleHome =>
      'Не удалось открыть приложение Google Home';

  @override
  String get reLogin => 'Войти снова';

  @override
  String get linkWithGoogleAssistant => 'Привязать к Google Ассистенту';

  @override
  String get linkedWithGoogleAssistant => 'Привязано к Google Ассистенту';

  @override
  String get anErrorOccurred => 'Произошла ошибка';

  @override
  String deleteHomeConfirm(String name) {
    return 'Удалить «$name»? Это действие нельзя отменить.';
  }

  @override
  String get offlineScenesBody =>
      'Сценарии и расписания приостановлены до восстановления Wi-Fi. Локальное управление по Bluetooth по-прежнему работает для открытия, закрытия и остановки каждого устройства.';

  @override
  String get blePairingLostBody =>
      'Для локального управления по Bluetooth нужно заново выполнить сопряжение с этим устройством. Обычно это происходит после очистки данных приложения или сброса устройства к заводским настройкам.';

  @override
  String get alternateNetworkHint =>
      'Если текущая сеть недоступна, устройство автоматически подключится к резервной сети.';

  @override
  String get switchNetworkWarning =>
      'Устройство отключится от текущей сети Wi-Fi и попробует подключиться к новой. Обычно это занимает 5–30 секунд.';

  @override
  String get runOnceIfNoDayPicked =>
      'Если не выбрать, действие выполнится только один раз.';

  @override
  String get alexaUnlinkHint =>
      'Отключите навык osprey.life в приложении Amazon Alexa или нажмите «Я» > кнопку настроек в правом верхнем углу > «Учётная запись и безопасность», чтобы отозвать доступ.';

  @override
  String get alexaLinkExplainer =>
      'Привязка учётной записи приложения к учётной записи Amazon позволяет управлять устройствами с поддержкой Alexa через колонки Amazon Echo (например, «Alexa, turn on light.»)';

  @override
  String get chatScheduleHelp =>
      'Настройте автоматические расписания для штор. Откройте вкладку «Сценарии», чтобы создать ежедневную, еженедельную или разовую автоматизацию.';

  @override
  String get chatScenesHelp =>
      'Создавайте сценарии запуска одним касанием и управляйте ими на вкладке «Сценарии». Сценарий объединяет несколько действий со шторами и паузы в одно нажатие.';

  @override
  String get googleUnlinkHint =>
      'Отключите навык osprey.life в приложении Google Home или нажмите «Я» > кнопку настроек в правом верхнем углу > «Учётная запись и безопасность», чтобы отозвать доступ.';

  @override
  String get googleLinkExplainer =>
      'После привязки учётной записи приложения к учётной записи Google вы сможете управлять устройствами с поддержкой Google Ассистента через умные колонки Google Home. Например, можно сказать: «OK Google, please turn on the light.»';

  @override
  String get deviceDisconnectedFromHome =>
      'Устройство отключено от дома. Оно вернётся в режим сопряжения через 1–2 минуты.';

  @override
  String get searchingNearbyDevices =>
      'Поиск устройств Osprey рядом. Убедитесь, что устройство в режиме сопряжения.';

  @override
  String get looksLike5GhzHint =>
      'Похоже, это сеть 5 ГГц — переключите телефон на сеть 2,4 ГГц и нажмите «Обновить».';

  @override
  String get pairingWifiHint =>
      'Устройство подключится к сети Wi-Fi, которую использует ваш телефон. Поддерживаются только сети 2,4 ГГц.';

  @override
  String get siriShortcutsHelp =>
      'Нажмите на сценарий, чтобы записать голосовую фразу, а затем скажите «Привет, Siri» и эту фразу, чтобы запустить сценарий — даже когда приложение закрыто.\n\nНажмите на уже добавленный сценарий, чтобы изменить фразу или удалить её.';

  @override
  String get deleteAccountWarning =>
      'После удаления:\n• Учётная запись будет удалена через 30 дней\n• Все ваши устройства и сценарии будут удалены\n• Отменить можно, войдя снова в течение 30 дней';

  @override
  String aiSuggestionBody(String action, String weekday, String hour) {
    return 'Вы обычно запускаете «$action» в $weekday в $hour:00 — автоматизировать?';
  }

  @override
  String removeDeviceConfirm(String name) {
    return '«$name» будет удалено из вашего дома и примерно через 1–2 минуты автоматически вернётся в режим сопряжения.';
  }

  @override
  String eraseDeviceConfirm(String name) {
    return 'Все данные «$name» будут удалены БЕЗ возможности восстановления. Продолжить?';
  }

  @override
  String showInvisibleDevices(int count) {
    return 'Показать невидимые устройства ($count)';
  }

  @override
  String resetLinkSent(String email) {
    return 'Если учётная запись для $email существует, ссылка для сброса пароля уже в пути.';
  }

  @override
  String signInNotAvailable(String name) {
    return 'Вход через $name пока недоступен.';
  }

  @override
  String resendCodeIn(int seconds) {
    return 'Отправить код повторно через $seconds с';
  }

  @override
  String deleteConfirmNamed(String name) {
    return 'Удалить «$name»?';
  }

  @override
  String taskCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count задачи',
      many: '$count задач',
      few: '$count задачи',
      one: '$count задача',
    );
    return '$_temp0';
  }

  @override
  String featureComingSoonShort(String feature) {
    return '$feature скоро появится';
  }

  @override
  String roomCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count комнаты',
      many: '$count комнат',
      few: '$count комнаты',
      one: '$count комната',
    );
    return '$_temp0';
  }

  @override
  String removeDevicesQ(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Удалить $count устройства?',
      many: 'Удалить $count устройств?',
      few: 'Удалить $count устройства?',
      one: 'Удалить $count устройство?',
    );
    return '$_temp0';
  }

  @override
  String devicesRemoved(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Удалено $count устройства',
      many: 'Удалено $count устройств',
      few: 'Удалено $count устройства',
      one: 'Удалено $count устройство',
    );
    return '$_temp0';
  }

  @override
  String deviceCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count устройства',
      many: '$count устройств',
      few: '$count устройства',
      one: '$count устройство',
    );
    return '$_temp0';
  }

  @override
  String mainModuleVersion(String version) {
    return 'Основной модуль: V$version';
  }

  @override
  String outdoorTemperatureValue(int temp) {
    return 'Температура на улице: $temp °C';
  }

  @override
  String occurrencesIn30Days(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count раза за 30 дней',
      many: '$count раз за 30 дней',
      few: '$count раза за 30 дней',
      one: '$count раз за 30 дней',
    );
    return '$_temp0';
  }

  @override
  String sceneExecuted(String name) {
    return '«$name» выполнен';
  }

  @override
  String couldNotRunScene(String name) {
    return 'Не удалось выполнить «$name». Попробуйте снова.';
  }

  @override
  String featureComingSoonNamed(String feature) {
    return '$feature скоро появится.';
  }

  @override
  String get couldNotLoadHome =>
      'Не удалось загрузить ваш дом. Попробуйте снова.';

  @override
  String deviceCouldNotConnectTo(String ssid, String reason, String stayedOn) {
    return 'Устройству не удалось подключиться к «$ssid».\n\nПричина: $reason\n\nУстройство по-прежнему подключено к «$stayedOn».';
  }

  @override
  String makeSureNetworkInRange(String ssid) {
    return '\n\nУбедитесь, что «$ssid» включена и находится в зоне действия.';
  }

  @override
  String get noResponseFromDevice =>
      'Устройство не ответило. Обновите через некоторое время, чтобы увидеть текущее состояние.';

  @override
  String devicesBeingAdded(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Добавляется $count устройства',
      many: 'Добавляется $count устройств',
      few: 'Добавляется $count устройства',
      one: 'Добавляется $count устройство',
    );
    return '$_temp0';
  }

  @override
  String devicesAddedSuccessfully(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Добавлено $count устройства',
      many: 'Добавлено $count устройств',
      few: 'Добавлено $count устройства',
      one: 'Добавлено $count устройство',
    );
    return '$_temp0';
  }

  @override
  String get alexaExamplesIntro =>
      'С колонками Amazon Alexa вы можете\nуправлять устройствами с поддержкой Alexa, например';

  @override
  String get googleExamplesIntro =>
      'Теперь вы можете использовать колонку Google Home,\nчтобы управлять устройствами Google Ассистента, например';

  @override
  String get gridView => 'Сетка';

  @override
  String get listView => 'Список';

  @override
  String get deviceManagement => 'Управление устройствами';

  @override
  String get sort => 'Сортировка';

  @override
  String get darkMode => 'Тёмная тема';

  @override
  String get followSystem => 'Как в системе';

  @override
  String get system => 'Система';

  @override
  String get systemDarkModeHint =>
      'Когда включено, приложение включает или выключает тёмную тему в соответствии с настройками системы.';

  @override
  String get normalMode => 'Обычный режим';
}
