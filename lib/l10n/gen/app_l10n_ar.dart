// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_l10n.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppL10nAr extends AppL10n {
  AppL10nAr([String locale = 'ar']) : super(locale);

  @override
  String get settingsTitle => 'الإعدادات';

  @override
  String get personalInformation => 'المعلومات الشخصية';

  @override
  String get accountAndSecurity => 'الحساب والأمان';

  @override
  String get touchToneOnPanel => 'نغمة اللمس على اللوحة';

  @override
  String get aiAssistant => 'المساعد الذكي';

  @override
  String get temperatureUnit => 'وحدة الحرارة';

  @override
  String get about => 'حول';

  @override
  String get networkDiagnosis => 'تشخيص الشبكة';

  @override
  String get clearCache => 'مسح الذاكرة المؤقتة';

  @override
  String get language => 'اللغة';

  @override
  String get logOut => 'تسجيل الخروج';

  @override
  String get languageSystemDefault => 'نفس لغة النظام';

  @override
  String get languageEnglish => 'الإنجليزية';

  @override
  String get languageVietnamese => 'الفيتنامية';

  @override
  String get clearCacheMessage =>
      'سيُعاد تنزيل المشاهد وبيانات المنزل والصور المخزنة مؤقتاً عند الاستخدام التالي. لن يتأثر حسابك ولا أجهزتك.';

  @override
  String get clear => 'مسح';

  @override
  String get cancel => 'إلغاء';

  @override
  String freedSpace(String size) {
    return 'تم تحرير $size';
  }

  @override
  String aboutVersion(String version, String build) {
    return 'الإصدار $version ($build)';
  }

  @override
  String get privacyPolicy => 'سياسة الخصوصية';

  @override
  String get termsOfService => 'شروط الخدمة';

  @override
  String get bundleId => 'Bundle ID';

  @override
  String get server => 'الخادم';

  @override
  String get couldNotOpenLink => 'تعذر فتح الرابط.';

  @override
  String get diagLocalNetwork => 'الشبكة المحلية';

  @override
  String get diagLocalNetworkNoWifi =>
      'غير متصل بشبكة Wi-Fi (بيانات الجوال أو الإذن مرفوض)';

  @override
  String get diagLocalNetworkUnreadable => 'تعذر قراءة اسم شبكة Wi-Fi';

  @override
  String get diagDnsLookup => 'استعلام DNS';

  @override
  String diagDnsFailed(String host) {
    return 'تعذر تحليل $host';
  }

  @override
  String get diagServerReachable => 'الخادم متاح';

  @override
  String diagServerLatency(String ms, String status) {
    return '$ms مللي ثانية · HTTP $status';
  }

  @override
  String get diagServerNoResponse => 'لا استجابة من الخادم';

  @override
  String get diagSignedIn => 'تم تسجيل الدخول';

  @override
  String get diagSessionValid => 'الجلسة صالحة';

  @override
  String diagSessionInvalid(String status) {
    return 'HTTP $status — يرجى تسجيل الدخول مرة أخرى';
  }

  @override
  String get diagSessionUnverified => 'تعذر التحقق من الجلسة';

  @override
  String get diagControlChannel => 'قناة التحكم';

  @override
  String get diagCloudConnected => 'السحابة (MQTT) متصلة';

  @override
  String get diagBleFallback => 'السحابة متوقفة — يتم استخدام Bluetooth بديلاً';

  @override
  String get diagUnreachable => 'لا سحابة ولا Bluetooth في النطاق';

  @override
  String get diagStatusUnknown => 'الحالة غير معروفة';

  @override
  String get runAgain => 'تشغيل مرة أخرى';

  @override
  String get accountCreatedPleaseSignIn =>
      'تم إنشاء الحساب — يرجى تسجيل الدخول.';

  @override
  String get add => 'إضافة';

  @override
  String get addCondition => 'إضافة شرط';

  @override
  String get addRoom => 'إضافة غرفة';

  @override
  String get addTask => 'إضافة مهمة';

  @override
  String get addAtLeastTwoDevicesToAGroup =>
      'أضف جهازين على الأقل إلى المجموعة.';

  @override
  String get alexa => 'Alexa';

  @override
  String get all => 'الكل';

  @override
  String get allDevices => 'جميع الأجهزة';

  @override
  String get alternateNetwork => 'شبكة بديلة';

  @override
  String get apply => 'تطبيق';

  @override
  String get areYouSureYouWantToLogOut => 'هل تريد تسجيل الخروج؟';

  @override
  String get askAboutYourCurtainsOrTryHelp => 'اسأل عن ستائرك، أو جرّب /help…';

  @override
  String get askAboutYourCurtains => 'اسأل عن ستائرك…';

  @override
  String get atLeast6Characters => '6 أحرف على الأقل';

  @override
  String get authDiagnostics => 'تشخيص المصادقة';

  @override
  String get automationNotification => 'إشعار التشغيل التلقائي';

  @override
  String get changeRoom => 'تغيير الغرفة';

  @override
  String get close => 'إغلاق';

  @override
  String get cloud => 'السحابة';

  @override
  String get confirm => 'تأكيد';

  @override
  String get connected => 'متصل';

  @override
  String get control => 'تحكم';

  @override
  String get controlSingleDevice => 'التحكم بجهاز واحد';

  @override
  String get copiedToClipboard => 'تم النسخ إلى الحافظة';

  @override
  String get copy => 'نسخ';

  @override
  String get couldNotChangeTheMotorDirectionPleaseTryAgai =>
      'تعذر تغيير اتجاه المحرك. يرجى المحاولة مرة أخرى.';

  @override
  String get couldNotConnect => 'تعذر الاتصال';

  @override
  String get couldNotCreateTheGroupPleaseTryAgain =>
      'تعذر إنشاء المجموعة. يرجى المحاولة مرة أخرى.';

  @override
  String get couldNotOpenTheBrowser => 'تعذر فتح المتصفح.';

  @override
  String get couldNotSendTheCommandPleaseTryAgain =>
      'تعذر إرسال الأمر. يرجى المحاولة مرة أخرى.';

  @override
  String get create => 'إنشاء';

  @override
  String get createScene => 'إنشاء مشهد';

  @override
  String get createAHome => 'إنشاء منزل';

  @override
  String get createARoomFirst => 'أنشئ غرفة أولاً.';

  @override
  String get createAccount => 'إنشاء حساب';

  @override
  String get createScene2 => 'إنشاء مشهد';

  @override
  String get curtainPosition => 'موضع الستارة';

  @override
  String get curtainPositionSetting => 'ضبط موضع الستارة';

  @override
  String get customDeviceIconsAreNotSupportedYet =>
      'أيقونات الأجهزة المخصصة غير مدعومة بعد.';

  @override
  String get delayTheAction => 'تأخير الإجراء';

  @override
  String get delete => 'حذف';

  @override
  String get deleteAccount => 'حذف الحساب';

  @override
  String get deleteHome => 'حذف المنزل';

  @override
  String get deleteRoom => 'حذف الغرفة';

  @override
  String get deleteSchedule => 'حذف الجدولة';

  @override
  String get deleteScene => 'حذف المشهد؟';

  @override
  String get deleteThisSchedule => 'حذف هذه الجدولة؟';

  @override
  String get deviceNetwork => 'شبكة الجهاز';

  @override
  String get deviceHasNoProfileInformation =>
      'لا توجد معلومات ملف تعريف للجهاز';

  @override
  String get deviceIsOffline => 'الجهاز غير متصل';

  @override
  String get deviceIsReady => 'الجهاز جاهز.';

  @override
  String get deviceName => 'اسم الجهاز';

  @override
  String get deviceRemovedFromHome => 'تمت إزالة الجهاز من المنزل.';

  @override
  String get deviceUnreachable => 'الجهاز غير متاح';

  @override
  String get devices => 'الأجهزة';

  @override
  String get disconnect => 'قطع الاتصال';

  @override
  String get disconnectDevice => 'قطع اتصال الجهاز؟';

  @override
  String get done => 'تم';

  @override
  String get emailAddress => 'البريد الإلكتروني';

  @override
  String get emailOrUsername => 'البريد الإلكتروني أو اسم المستخدم';

  @override
  String get enterAGroupName => 'أدخل اسم المجموعة';

  @override
  String get enterANote => 'أدخل ملاحظة';

  @override
  String get enterDeviceName => 'أدخل اسم الجهاز';

  @override
  String get enterHomeName => 'أدخل اسم المنزل';

  @override
  String get enterName => 'أدخل الاسم';

  @override
  String get enterSceneName => 'أدخل اسم المشهد';

  @override
  String get enterValue => 'أدخل القيمة...';

  @override
  String get enterYourPassword => 'أدخل كلمة المرور';

  @override
  String get eraseDeviceData => 'محو بيانات الجهاز؟';

  @override
  String get error => 'خطأ';

  @override
  String get executedBy => 'تم التنفيذ بواسطة';

  @override
  String get executionTime => 'وقت التنفيذ';

  @override
  String get faqFeedback => 'الأسئلة الشائعة والملاحظات';

  @override
  String get failed => 'فشل';

  @override
  String get featureComingSoon => 'الميزة قادمة قريباً';

  @override
  String get firmware => 'البرنامج الثابت';

  @override
  String get firmwareUpdateIsComingSoon => 'تحديث البرنامج الثابت قادم قريباً.';

  @override
  String get firstName => 'الاسم الأول';

  @override
  String get firstNameOptional => 'الاسم الأول (اختياري)';

  @override
  String get goBack => 'رجوع';

  @override
  String get googleAssistant => 'Google Assistant';

  @override
  String get gotIt => 'فهمت';

  @override
  String get groupName => 'اسم المجموعة';

  @override
  String get help => 'مساعدة';

  @override
  String get homeManagement => 'إدارة المنزل';

  @override
  String get homeName => 'اسم المنزل';

  @override
  String get homeName2 => 'اسم المنزل';

  @override
  String get icon => 'أيقونة';

  @override
  String get conditionIf => 'إذا';

  @override
  String get joinAHome => 'الانضمام إلى منزل';

  @override
  String get joiningAHomeByInviteIsComingSoon =>
      'الانضمام إلى منزل بدعوة قادم قريباً.';

  @override
  String get lastName => 'اسم العائلة';

  @override
  String get lastNameOptional => 'اسم العائلة (اختياري)';

  @override
  String get later => 'لاحقاً';

  @override
  String get launchTapToRun => 'تشغيل Tap-to-Run';

  @override
  String get localAssociation => 'الربط المحلي';

  @override
  String get localControlOffline => 'التحكم المحلي (بلا اتصال)';

  @override
  String get location => 'الموقع';

  @override
  String get logCopiedToClipboard => 'تم نسخ السجل إلى الحافظة';

  @override
  String get logs => 'السجلات';

  @override
  String get manage => 'إدارة';

  @override
  String get managePermissions => 'إدارة الأذونات';

  @override
  String get markAllAsRead => 'تحديد الكل كمقروء';

  @override
  String get moreSettings => 'إعدادات أخرى';

  @override
  String get motorDirection => 'اتجاه المحرك';

  @override
  String get moveToTop => 'نقل إلى الأعلى';

  @override
  String get moveToRoom => 'نقل إلى غرفة';

  @override
  String get moved => 'تم النقل';

  @override
  String get movedToTop => 'تم النقل إلى الأعلى';

  @override
  String get name => 'الاسم';

  @override
  String get next => 'التالي';

  @override
  String get noDevicesAvailable => 'لا توجد أجهزة متاحة';

  @override
  String get noDevicesFound => 'لم يتم العثور على أجهزة.';

  @override
  String get noDevicesInThisHome => 'لا توجد أجهزة في هذا المنزل.';

  @override
  String get noDevicesYet => 'لا توجد أجهزة بعد';

  @override
  String get noFunctionsAvailable => 'لا توجد وظائف متاحة';

  @override
  String get noHomeSelectedPleaseTryAgain =>
      'لم يتم اختيار منزل، يرجى المحاولة مرة أخرى';

  @override
  String get noMatchingTimeZones => 'لا توجد مناطق زمنية مطابقة';

  @override
  String get noOtherScenesAvailable => 'لا توجد مشاهد أخرى متاحة';

  @override
  String get noRooms => 'لا توجد غرف';

  @override
  String get noSavedNetworksYet => 'لا توجد شبكات محفوظة بعد.';

  @override
  String get noScenes => 'لا توجد مشاهد';

  @override
  String get noScenesAvailable => 'لا توجد مشاهد متاحة';

  @override
  String get note => 'ملاحظة';

  @override
  String get notification => 'إشعار';

  @override
  String get ok => 'موافق';

  @override
  String get offlineNotification => 'إشعار انقطاع الاتصال';

  @override
  String get open => 'فتح';

  @override
  String get openSettings => 'فتح الإعدادات';

  @override
  String get outdoorPm25 => 'PM2.5 في الخارج';

  @override
  String get outdoorAirPressure => 'الضغط الجوي الخارجي';

  @override
  String get outdoorHumidity => 'الرطوبة الخارجية';

  @override
  String get outdoorWindSpeed => 'سرعة الرياح الخارجية';

  @override
  String get pairingSuccessful => 'تم الإقران بنجاح';

  @override
  String get password => 'كلمة المرور';

  @override
  String get sessionExpiredSignInAgain =>
      'انتهت صلاحية الجلسة. يرجى تسجيل الدخول مرة أخرى.';

  @override
  String get pleaseAddAtLeast1Action => 'يرجى إضافة إجراء واحد على الأقل';

  @override
  String get pleaseAddAtLeast1Condition => 'يرجى إضافة شرط واحد على الأقل';

  @override
  String get pleaseEnterAName => 'يرجى إدخال اسم';

  @override
  String get pleaseEnterASceneName => 'يرجى إدخال اسم المشهد';

  @override
  String get pleaseSelectAFunction => 'يرجى اختيار وظيفة';

  @override
  String get pleaseSelectATime0 => 'يرجى اختيار وقت أكبر من 0';

  @override
  String get rePairNow => 'إعادة الإقران الآن';

  @override
  String get rePairRequired => 'إعادة الإقران مطلوبة';

  @override
  String get reasonOptional => 'السبب (اختياري)';

  @override
  String get refresh => 'تحديث';

  @override
  String get reload => 'إعادة التحميل';

  @override
  String get remove => 'إزالة';

  @override
  String get removeDevice => 'إزالة الجهاز';

  @override
  String get removed => 'تمت الإزالة';

  @override
  String get rename => 'إعادة تسمية';

  @override
  String get renameRoom => 'إعادة تسمية الغرفة';

  @override
  String get renameDevice => 'إعادة تسمية الجهاز';

  @override
  String get repeat => 'تكرار';

  @override
  String get rescan => 'إعادة الفحص';

  @override
  String get retry => 'إعادة المحاولة';

  @override
  String get roomManagement => 'إدارة الغرف';

  @override
  String get roomName => 'اسم الغرفة';

  @override
  String get roomUpdated => 'تم تحديث الغرفة';

  @override
  String get running => 'قيد التشغيل';

  @override
  String get save => 'حفظ';

  @override
  String get sceneName => 'اسم المشهد';

  @override
  String get scenes => 'المشاهد';

  @override
  String get schedule => 'جدولة';

  @override
  String get searchAddress => 'البحث عن عنوان';

  @override
  String get searchCityOrRegion => 'البحث عن مدينة أو منطقة';

  @override
  String get selectScene => 'اختيار مشهد';

  @override
  String get selectSmartScenes => 'اختيار المشاهد الذكية';

  @override
  String get sendResetLink => 'إرسال رابط إعادة التعيين';

  @override
  String get sendVerificationCode => 'إرسال رمز التحقق';

  @override
  String get showOnHomePage => 'العرض في الصفحة الرئيسية';

  @override
  String get signIn => 'تسجيل الدخول';

  @override
  String get signalStrength => 'قوة الإشارة';

  @override
  String get signalStrength2 => 'قوة الإشارة';

  @override
  String get startPairing => 'بدء الإقران';

  @override
  String get stop => 'إيقاف';

  @override
  String get style => 'النمط';

  @override
  String get switchNetwork => 'تبديل';

  @override
  String get switchToThisNetwork => 'التبديل إلى هذه الشبكة';

  @override
  String get tapToRunNotification => 'إشعار Tap-to-Run';

  @override
  String get conditionThen => 'ثم';

  @override
  String get thinking => 'جارٍ التفكير…';

  @override
  String get thisActionCannotBeUndone => 'لا يمكن التراجع عن هذا الإجراء.';

  @override
  String get thisSavedNetworkWillBeRemovedFromTheDevice =>
      'ستتم إزالة هذه الشبكة المحفوظة من الجهاز.';

  @override
  String get timeZone => 'المنطقة الزمنية';

  @override
  String get timeZoneUpdated => 'تم تحديث المنطقة الزمنية';

  @override
  String get timedOut => 'انتهت المهلة';

  @override
  String get tryAgain => 'حاول مرة أخرى';

  @override
  String get useCurrentLocation => 'استخدام الموقع الحالي';

  @override
  String get usingSiri => 'استخدام Siri';

  @override
  String get virtualId => 'المعرّف الافتراضي';

  @override
  String get whenDeviceStatusChanges => 'عند تغيّر حالة الجهاز';

  @override
  String get whenWeatherChanges => 'عند تغيّر الطقس';

  @override
  String get wiFi => 'Wi-Fi';

  @override
  String get wifiNameSsid => 'اسم WiFi (SSID)';

  @override
  String get wifiPassword => 'كلمة مرور WiFi';

  @override
  String get navHome => 'المنزل';

  @override
  String get navScenes => 'المشاهد';

  @override
  String get navChat => 'المحادثة';

  @override
  String get navMe => 'حسابي';

  @override
  String get thirdPartyServices => 'خدمات الجهات الخارجية';

  @override
  String get messageCenter => 'مركز الرسائل';

  @override
  String get appMall => 'متجر التطبيقات';

  @override
  String get addDevice => 'إضافة جهاز';

  @override
  String get tapToRun => 'التنفيذ بلمسة';

  @override
  String get automationEmptyHint =>
      'تُوفّر الأتمتة وقتك وجهدك بتنفيذ المهام المتكررة تلقائيًا.';

  @override
  String get tapToRunEmptyHint =>
      'أنشئ مشهد تنفيذ بلمسة للتحكم في أجهزتك بسرعة بلمسة واحدة.';

  @override
  String get scene => 'المشهد';

  @override
  String get executionFailed => 'فشل التنفيذ';

  @override
  String get device => 'الجهاز';

  @override
  String get delay => 'انتظار';

  @override
  String get runScene => 'تشغيل المشهد';

  @override
  String get addToSiri => 'إضافة إلى Siri';

  @override
  String get storeUnderPreparation => 'المتجر قيد الإعداد، تابعنا قريبًا.';

  @override
  String get commonFunctions => 'الوظائف الشائعة';

  @override
  String get noConnection => 'لا يوجد اتصال';

  @override
  String get checkInternetAndRetry =>
      'تحقق من اتصالك بالإنترنت وحاول مرة أخرى.';

  @override
  String get noConnectionCheckInternet =>
      'لا يوجد اتصال. تحقق من الإنترنت وحاول مرة أخرى.';

  @override
  String get addFirstCurtainHint =>
      'اضغط على زر + لإضافة أول ستارة إلى هذا المنزل.';

  @override
  String get hideInvisibleDevices => 'إخفاء الأجهزة غير الظاهرة';

  @override
  String get deviceRenamed => 'تم تغيير اسم الجهاز.';

  @override
  String get deviceDeletedReturningToPairing =>
      'تم حذف الجهاز. سيعود إلى وضع الإقران.';

  @override
  String get homeSettings => 'إعدادات المنزل';

  @override
  String get toBeSet => 'لم يُحدَّد بعد';

  @override
  String get homeMember => 'عضو المنزل';

  @override
  String get memberDetails => 'تفاصيل العضو';

  @override
  String get addMember => 'إضافة عضو';

  @override
  String get pending => 'قيد الانتظار';

  @override
  String get removesFromHomeHint =>
      'يُزال من المنزل؛ ويعود الجهاز إلى وضع الإقران خلال 1-2 دقيقة';

  @override
  String get unlinkAndEraseData => 'إلغاء الربط ومحو البيانات';

  @override
  String get erasesAllDataHint => 'يمحو جميع البيانات، ولا يمكن التراجع';

  @override
  String get somethingWentWrongTryAgain => 'حدث خطأ، يُرجى المحاولة مرة أخرى';

  @override
  String get tapToRunAndAutomation => 'التنفيذ بلمسة والأتمتة';

  @override
  String get thirdPartyControl => 'التحكم عبر الجهات الخارجية';

  @override
  String get deviceOfflineNotification => 'تنبيه انقطاع اتصال الجهاز';

  @override
  String get others => 'أخرى';

  @override
  String get shareDevice => 'مشاركة الجهاز';

  @override
  String get addToHomeScreen => 'إضافة إلى الشاشة الرئيسية';

  @override
  String get checkDeviceNetwork => 'فحص شبكة الجهاز';

  @override
  String get checkNow => 'فحص الآن';

  @override
  String get deviceUpdate => 'تحديث الجهاز';

  @override
  String get removeDevicesWarning =>
      'ستُزال من هذا المنزل وتعود إلى وضع الإقران.';

  @override
  String get shown => 'ظاهر';

  @override
  String get hidden => 'مخفي';

  @override
  String get devicesBackOnHome => 'عادت الأجهزة إلى الصفحة الرئيسية';

  @override
  String get hiddenFromHome => 'مخفية عن الصفحة الرئيسية';

  @override
  String get offline => 'غير متصل';

  @override
  String get show => 'إظهار';

  @override
  String get hide => 'إخفاء';

  @override
  String get profilePhoto => 'صورة الملف الشخصي';

  @override
  String get nickname => 'الاسم المستعار';

  @override
  String get noRoomsYet => 'لا توجد غرف بعد';

  @override
  String get tapPlusToAddRoom => 'اضغط على + لإضافة غرفة';

  @override
  String get emailAddressLabel => 'عنوان البريد الإلكتروني';

  @override
  String get notSet => 'لم يُحدَّد';

  @override
  String get deviceInformation => 'معلومات الجهاز';

  @override
  String get unknown => 'غير معروف';

  @override
  String get notReported => 'غير متوفر';

  @override
  String get noScenesUseThisDevice => 'لا يوجد مشهد يستخدم هذا الجهاز بعد.';

  @override
  String get tapToRunLabel => 'التنفيذ بلمسة';

  @override
  String get automation => 'الأتمتة';

  @override
  String get forward => 'الاتجاه الأمامي';

  @override
  String get back => 'الاتجاه العكسي';

  @override
  String get setting => 'الإعداد';

  @override
  String get updateAvailable => 'يتوفر تحديث';

  @override
  String get noUpdatesAvailable => 'لا تتوفر تحديثات';

  @override
  String get updateNow => 'التحديث الآن';

  @override
  String get unassigned => 'غير مُعيَّن';

  @override
  String get enterEmailOrUsername => 'أدخل بريدك الإلكتروني أو اسم المستخدم';

  @override
  String get welcome => 'مرحبًا';

  @override
  String get signInSubtitle => 'سجّل الدخول إلى حسابك في osprey.life.';

  @override
  String get createOne => 'إنشاء حساب';

  @override
  String get forgotPassword => 'هل نسيت كلمة المرور؟';

  @override
  String get orContinueWith => 'أو المتابعة باستخدام';

  @override
  String get enterValidEmail => 'أدخل عنوان بريد إلكتروني صحيح';

  @override
  String get resetYourPassword => 'إعادة تعيين كلمة المرور';

  @override
  String get checkYourInbox => 'تحقق من صندوق بريدك';

  @override
  String get enterYourEmailAddress => 'أدخل عنوان بريدك الإلكتروني';

  @override
  String get enterSixDigitCode => 'أدخل الرمز المكوَّن من 6 أرقام';

  @override
  String get enterAPassword => 'أدخل كلمة مرور';

  @override
  String get createYourAccount => 'أنشئ حسابك';

  @override
  String get checkYourEmail => 'تحقق من بريدك الإلكتروني';

  @override
  String get resendCode => 'إعادة إرسال الرمز';

  @override
  String get userAgreement => 'اتفاقية المستخدم';

  @override
  String get reconnecting => 'جارٍ إعادة الاتصال…';

  @override
  String get checkWifiOrBluetooth =>
      'تحقق من Wi-Fi أو اقترب أكثر لاستخدام Bluetooth.';

  @override
  String get smartScenesRequireInternet => 'تحتاج المشاهد الذكية إلى الإنترنت';

  @override
  String get enterWifiName => 'أدخل اسم شبكة Wi-Fi';

  @override
  String get wifiNameLengthError =>
      'يجب أن يكون اسم شبكة Wi-Fi من 1 إلى 32 حرفًا';

  @override
  String get passwordMin8 => 'يجب أن تكون كلمة المرور 8 أحرف على الأقل';

  @override
  String get passwordLength863 => 'يجب أن تكون كلمة المرور من 8 إلى 63 حرفًا';

  @override
  String get networkAlreadySaved =>
      'هذه الشبكة محفوظة بالفعل. لتغيير كلمة المرور، احذفها ثم أضفها مرة أخرى.';

  @override
  String get addWifiNetwork => 'إضافة شبكة Wi-Fi';

  @override
  String get atLeast8Characters => '8 أحرف على الأقل';

  @override
  String get only24GhzSupported =>
      'أجهزة الستائر تدعم شبكات Wi-Fi بتردد 2.4 غيغاهرتز (WPA2) فقط.';

  @override
  String get labelOptional => 'التسمية (اختياري)';

  @override
  String get createGroup => 'إنشاء مجموعة';

  @override
  String get groupControlHint => 'يمكن التحكم في أجهزة المجموعة نفسها معًا.';

  @override
  String get devicesToBeAdded => 'الأجهزة المطلوب إضافتها';

  @override
  String get noSameTypeDevices =>
      'لا توجد أجهزة أخرى من النوع نفسه في هذا المنزل.';

  @override
  String get couldNotLoadNetworkDetails =>
      'تعذّر تحميل تفاصيل الشبكة. اسحب للتحديث.';

  @override
  String get alreadyOnThisNetwork => 'متصل بهذه الشبكة بالفعل.';

  @override
  String get deviceOfflineTryLater =>
      'الجهاز غير متصل — يُرجى المحاولة لاحقًا.';

  @override
  String get wrongPassword => 'كلمة المرور غير صحيحة';

  @override
  String get networkNotFound => 'لم يتم العثور على الشبكة';

  @override
  String get networkRemoved => 'تم حذف الشبكة.';

  @override
  String get network => 'الشبكة';

  @override
  String get connectedTo => 'متصل بـ';

  @override
  String get savedNetworks => 'الشبكات المحفوظة';

  @override
  String get addANetwork => 'إضافة شبكة';

  @override
  String get notConnected => 'غير متصل';

  @override
  String get pleaseKeepAppOpen => 'يُرجى إبقاء التطبيق مفتوحًا.';

  @override
  String get deviceNetworkInformation => 'معلومات شبكة الجهاز';

  @override
  String get once => 'مرة واحدة';

  @override
  String get editSchedule => 'تعديل الجدولة';

  @override
  String get addSchedule => 'إضافة جدولة';

  @override
  String get timeVarianceHint => 'هامش الوقت نحو ±30 ثانية';

  @override
  String get noTimerData => 'لا توجد بيانات مؤقت';

  @override
  String get localControlUnsupportedAction =>
      'التحكم المحلي لا يدعم هذا الإجراء';

  @override
  String get noInternetNoBluetooth => 'لا يوجد إنترنت وBluetooth خارج النطاق';

  @override
  String get connectionError => 'خطأ في الاتصال';

  @override
  String get exampleTapToRun =>
      'مثال: إطفاء جميع أضواء غرفة النوم بلمسة واحدة.';

  @override
  String get exampleWeather =>
      'مثال: عندما تتجاوز درجة الحرارة المحلية 28 درجة مئوية.';

  @override
  String get weatherTrigger => 'مُشغِّل حسب الطقس';

  @override
  String get exampleSchedule => 'مثال: في الساعة 7:00 صباحًا كل يوم.';

  @override
  String get exampleDeviceStatus => 'مثال: عند رصد نشاط غير معتاد.';

  @override
  String get deviceStatusTrigger => 'مُشغِّل حسب حالة الجهاز';

  @override
  String get noNotificationsYet => 'لا توجد إشعارات بعد';

  @override
  String get slashCommands => 'أوامر الشرطة المائلة';

  @override
  String get slashDevicesHint => 'استعرض ستائرك وتحكم فيها.';

  @override
  String get slashSceneHint => 'تشغيل مشهد تنفيذ بلمسة.';

  @override
  String get slashScheduleHint => 'فتح جدولة الأتمتة.';

  @override
  String get slashHelpHint => 'إظهار هذه القائمة.';

  @override
  String get youCanAlsoSpeak => 'يمكنك التحدث أيضًا — اضغط على زر الميكروفون.';

  @override
  String get chatInputHint => 'اكتب أو تحدّث أو استخدم أوامر الشرطة المائلة.';

  @override
  String get online => 'متصل';

  @override
  String get blePermissionRequired => 'يتطلب البحث عن الأجهزة إذن Bluetooth';

  @override
  String get bleAndLocationPermissionRequired =>
      'يتطلب البحث عن الأجهزة إذني Bluetooth والموقع';

  @override
  String get addDeviceLower => 'إضافة جهاز';

  @override
  String get scanningStopped => 'تم إيقاف البحث.';

  @override
  String get enterWifiPassword => 'أدخل كلمة مرور شبكة Wi-Fi';

  @override
  String get detectingCurrentWifi => 'جارٍ الكشف عن شبكة Wi-Fi الحالية...';

  @override
  String get autoDetectedWifi =>
      'تم الكشف تلقائيًا من شبكة Wi-Fi المتصل بها هاتفك';

  @override
  String get couldNotDetectWifi =>
      'تعذّر الكشف عن شبكة Wi-Fi — أدخل اسم الشبكة يدويًا';

  @override
  String get beingAdded => 'جارٍ الإضافة';

  @override
  String get addedSuccessfully => 'تمت الإضافة بنجاح';

  @override
  String get pairingFailed => 'فشل الإقران';

  @override
  String get allDay => 'طوال اليوم';

  @override
  String get whenAnyConditionMet => 'عند تحقُّق أي شرط';

  @override
  String get whenAllConditionsMet => 'عند تحقُّق جميع الشروط';

  @override
  String get deleteSceneWarning =>
      'بعد حذف السيناريو، لن يكون بالإمكان تنفيذ مهام الأجهزة بشكل صحيح.';

  @override
  String get toggleAutomation => 'تشغيل الأتمتة أو إيقافها';

  @override
  String get enable => 'تشغيل';

  @override
  String get disable => 'إيقاف';

  @override
  String get everyDay => 'كل يوم';

  @override
  String get monToFri => 'الاثنين - الجمعة';

  @override
  String get satToSun => 'السبت - الأحد';

  @override
  String get runOnceIfNoDaySelected =>
      'سيُنفَّذ الإجراء مرة واحدة فقط إذا لم تختر أي يوم من أيام الأسبوع.';

  @override
  String get sendNotification => 'إرسال إشعار';

  @override
  String get color => 'اللون';

  @override
  String get wait => 'انتظار';

  @override
  String get finish => 'إنهاء';

  @override
  String get selectFunction => 'اختيار الوظيفة';

  @override
  String get on => 'تشغيل';

  @override
  String get off => 'إيقاف';

  @override
  String get siriShortcut => 'اختصار Siri';

  @override
  String get createTapToRunFirst => 'أنشئ مشهد تنفيذ بلمسة أولًا.';

  @override
  String get poweredByFoundationModels =>
      'مدعوم بـ Apple Foundation Models، على الجهاز نفسه.';

  @override
  String get weatherClearNight => 'ليلة صافية';

  @override
  String get weatherSunny => 'مشمس';

  @override
  String get weatherPartlyCloudy => 'غائم جزئيًا';

  @override
  String get weatherCloudy => 'غائم';

  @override
  String get qualityExcellent => 'ممتازة';

  @override
  String get qualityGood => 'جيدة';

  @override
  String get qualityModerate => 'متوسطة';

  @override
  String get qualityPoor => 'سيئة';

  @override
  String get qualityVeryPoor => 'سيئة جدًا';

  @override
  String get switchLocation => 'تغيير الموقع';

  @override
  String get aiSuggestion => 'اقتراح الذكاء الاصطناعي';

  @override
  String get listening => 'جارٍ الاستماع…';

  @override
  String get parsing => 'جارٍ التحليل…';

  @override
  String get getStarted => 'ابدأ';

  @override
  String get aiChatEmptyState =>
      'اسأل مساعد osprey.life عن أي شيء يتعلق بستائرك.\nمدعوم بـ Apple Foundation Models، على الجهاز نفسه.';

  @override
  String get chatHeaderSubtitle =>
      'ذكاء اصطناعي على الجهاز لستائرك الكهربائية.\nاكتب أو تحدّث أو استخدم أوامر الشرطة المائلة.';

  @override
  String get daySunShort => 'الأحد';

  @override
  String get dayMonShort => 'الاثنين';

  @override
  String get dayTueShort => 'الثلاثاء';

  @override
  String get dayWedShort => 'الأربعاء';

  @override
  String get dayThuShort => 'الخميس';

  @override
  String get dayFriShort => 'الجمعة';

  @override
  String get daySatShort => 'السبت';

  @override
  String get dayMon => 'الاثنين';

  @override
  String get dayTue => 'الثلاثاء';

  @override
  String get dayWed => 'الأربعاء';

  @override
  String get dayThu => 'الخميس';

  @override
  String get dayFri => 'الجمعة';

  @override
  String get daySat => 'السبت';

  @override
  String get daySun => 'الأحد';

  @override
  String get accountLinkedSuccessfully => 'تم ربط الحساب بنجاح!';

  @override
  String get linkingFailed => 'فشل الربط';

  @override
  String get anErrorOccurredTryAgain => 'حدث خطأ. يُرجى المحاولة مرة أخرى.';

  @override
  String get signInWithAmazon => 'تسجيل الدخول باستخدام Amazon';

  @override
  String get viewMoreWaysToLink => 'عرض طرق ربط أخرى';

  @override
  String get alreadyLinkedWithAlexa => 'مرتبط بالفعل بـ Amazon Alexa';

  @override
  String get somethingWentWrong => 'حدث خطأ';

  @override
  String get noAuthorizationCode => 'لم يتم استلام رمز التفويض';

  @override
  String get couldNotOpenGoogleHome => 'تعذّر فتح تطبيق Google Home';

  @override
  String get reLogin => 'تسجيل الدخول مرة أخرى';

  @override
  String get linkWithGoogleAssistant => 'الربط بـ Google Assistant';

  @override
  String get linkedWithGoogleAssistant => 'مرتبط بـ Google Assistant';

  @override
  String get anErrorOccurred => 'حدث خطأ';

  @override
  String deleteHomeConfirm(String name) {
    return 'هل تريد بالتأكيد حذف \"$name\"؟ لا يمكن التراجع عن هذا الإجراء.';
  }

  @override
  String get offlineScenesBody =>
      'تتوقف المشاهد والجدولة مؤقتًا حتى يعود Wi-Fi. ويظل التحكم المحلي عبر Bluetooth متاحًا لفتح كل جهاز أو إغلاقه أو إيقافه مباشرة.';

  @override
  String get blePairingLostBody =>
      'يحتاج التحكم المحلي عبر Bluetooth إلى إعادة الإقران بهذا الجهاز. يحدث ذلك عادةً بعد محو بيانات التطبيق أو إعادة الجهاز إلى إعدادات المصنع.';

  @override
  String get alternateNetworkHint =>
      'إذا كانت الشبكة الحالية غير متاحة، سيتصل الجهاز تلقائيًا بشبكة بديلة.';

  @override
  String get switchNetworkWarning =>
      'سيقطع الجهاز الاتصال بشبكة Wi-Fi الحالية ويحاول الانضمام إلى الشبكة الجديدة. يستغرق ذلك عادةً من 5 إلى 30 ثانية.';

  @override
  String get runOnceIfNoDayPicked =>
      'سيُنفَّذ الإجراء مرة واحدة فقط إذا لم تختره.';

  @override
  String get alexaUnlinkHint =>
      'أوقف مهارة osprey.life في تطبيق Amazon Alexa، أو اضغط على \"حسابي\" > زر الإعدادات في الزاوية العليا > الحساب والأمان لإلغاء التفويض.';

  @override
  String get alexaLinkExplainer =>
      'يتيح لك ربط حساب التطبيق بحساب Amazon التحكم في الأجهزة المتوافقة مع Alexa عبر مكبرات صوت Amazon Echo (مثل \"Alexa, turn on light.\")';

  @override
  String get chatScheduleHelp =>
      'اضبط جدولة تلقائية لستائرك. افتح علامة تبويب المشاهد لإنشاء أتمتة يومية أو أسبوعية أو لمرة واحدة.';

  @override
  String get chatScenesHelp =>
      'أنشئ مشاهد التنفيذ بلمسة وأدرها من علامة تبويب المشاهد. تتيح المشاهد ربط عدة إجراءات للستائر مع فترات انتظار في لمسة واحدة.';

  @override
  String get googleUnlinkHint =>
      'أوقف مهارة osprey.life في تطبيق Google Home، أو اضغط على \"حسابي\" > زر الإعدادات في الزاوية العليا > الحساب والأمان لإلغاء التفويض.';

  @override
  String get googleLinkExplainer =>
      'بعد ربط حساب التطبيق بحساب Google، يمكنك استخدام مكبرات صوت Google Home الذكية للتحكم في الأجهزة المتوافقة مع Google Assistant. على سبيل المثال، يمكنك أن تقول: \"OK Google, please turn on the light.\"';

  @override
  String get deviceDisconnectedFromHome =>
      'تم فصل الجهاز عن المنزل. سيعود إلى وضع الإقران خلال 1-2 دقيقة.';

  @override
  String get searchingNearbyDevices =>
      'جارٍ البحث عن أجهزة Osprey القريبة. تأكد من أن الجهاز في وضع الإقران.';

  @override
  String get looksLike5GhzHint =>
      'تبدو هذه الشبكة بتردد 5 غيغاهرتز — انقل هاتفك إلى شبكة 2.4 غيغاهرتز ثم اضغط على تحديث.';

  @override
  String get pairingWifiHint =>
      'سيتصل الجهاز بشبكة Wi-Fi التي يستخدمها هاتفك. الشبكات المدعومة هي 2.4 غيغاهرتز فقط.';

  @override
  String get siriShortcutsHelp =>
      'اضغط على مشهد لتسجيل عبارة صوتية، ثم قل \"يا Siri\" متبوعة بتلك العبارة لتشغيل المشهد — حتى عندما يكون التطبيق مغلقًا.\n\nاضغط على مشهد أضفته بالفعل لتغيير عبارته أو إزالته.';

  @override
  String get deleteAccountWarning =>
      'بعد الحذف:\n• سيُحذف حسابك بعد 30 يومًا\n• ستُزال جميع أجهزتك ومشاهدك\n• يمكنك الإلغاء بتسجيل الدخول مرة أخرى خلال 30 يومًا';

  @override
  String aiSuggestionBody(String action, String weekday, String hour) {
    return 'عادةً ما تُشغّل \"$action\" يوم $weekday في الساعة $hour:00 — هل تريد أتمتتها؟';
  }

  @override
  String removeDeviceConfirm(String name) {
    return 'سيُزال \"$name\" من منزلك وسيعود تلقائيًا إلى وضع الإقران خلال نحو 1-2 دقيقة.';
  }

  @override
  String eraseDeviceConfirm(String name) {
    return 'ستُمحى جميع بيانات \"$name\" ولن يمكن استعادتها. هل تريد المتابعة؟';
  }

  @override
  String showInvisibleDevices(int count) {
    return 'إظهار الأجهزة غير الظاهرة ($count)';
  }

  @override
  String resetLinkSent(String email) {
    return 'إذا كان هناك حساب مرتبط بـ $email، فسيُرسل رابط إعادة تعيين كلمة المرور قريبًا.';
  }

  @override
  String signInNotAvailable(String name) {
    return 'تسجيل الدخول عبر $name غير متاح بعد.';
  }

  @override
  String resendCodeIn(int seconds) {
    return 'إعادة إرسال الرمز بعد $seconds ثانية';
  }

  @override
  String deleteConfirmNamed(String name) {
    return 'هل تريد بالتأكيد حذف \"$name\"؟';
  }

  @override
  String taskCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count مهمة',
      many: '$count مهمة',
      few: '$count مهام',
      two: 'مهمتان',
      one: 'مهمة واحدة',
      zero: '$count مهمة',
    );
    return '$_temp0';
  }

  @override
  String featureComingSoonShort(String feature) {
    return '$feature قريبًا';
  }

  @override
  String roomCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count غرفة',
      many: '$count غرفة',
      few: '$count غرف',
      two: 'غرفتان',
      one: 'غرفة واحدة',
      zero: '$count غرفة',
    );
    return '$_temp0';
  }

  @override
  String removeDevicesQ(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'هل تريد إزالة $count جهاز؟',
      many: 'هل تريد إزالة $count جهازًا؟',
      few: 'هل تريد إزالة $count أجهزة؟',
      two: 'هل تريد إزالة جهازين؟',
      one: 'هل تريد إزالة الجهاز؟',
    );
    return '$_temp0';
  }

  @override
  String devicesRemoved(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'تم إزالة $count جهاز',
      many: 'تم إزالة $count جهازًا',
      few: 'تم إزالة $count أجهزة',
      two: 'تم إزالة جهازين',
      one: 'تم إزالة جهاز واحد',
    );
    return '$_temp0';
  }

  @override
  String deviceCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count جهاز',
      many: '$count جهازًا',
      few: '$count أجهزة',
      two: 'جهازان',
      one: 'جهاز واحد',
      zero: '$count جهاز',
    );
    return '$_temp0';
  }

  @override
  String mainModuleVersion(String version) {
    return 'الوحدة الرئيسية: V$version';
  }

  @override
  String outdoorTemperatureValue(int temp) {
    return 'درجة الحرارة في الخارج: $temp°م';
  }

  @override
  String occurrencesIn30Days(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count مرة خلال 30 يومًا',
      many: '$count مرة خلال 30 يومًا',
      few: '$count مرات خلال 30 يومًا',
      two: 'مرتان خلال 30 يومًا',
      one: 'مرة واحدة خلال 30 يومًا',
    );
    return '$_temp0';
  }

  @override
  String sceneExecuted(String name) {
    return 'تم تنفيذ \"$name\"';
  }

  @override
  String couldNotRunScene(String name) {
    return 'تعذّر تنفيذ \"$name\". يُرجى المحاولة مرة أخرى.';
  }

  @override
  String featureComingSoonNamed(String feature) {
    return '$feature قريبًا.';
  }

  @override
  String get couldNotLoadHome => 'تعذّر تحميل منزلك. يُرجى المحاولة مرة أخرى.';

  @override
  String deviceCouldNotConnectTo(String ssid, String reason, String stayedOn) {
    return 'تعذّر على الجهاز الاتصال بـ \"$ssid\".\n\nالسبب: $reason\n\nلا يزال الجهاز متصلًا بـ \"$stayedOn\".';
  }

  @override
  String makeSureNetworkInRange(String ssid) {
    return '\n\nتأكد من أن \"$ssid\" مُشغَّلة وداخل نطاق التغطية.';
  }

  @override
  String get noResponseFromDevice =>
      'لم نتلقَّ ردًا من الجهاز. حدِّث بعد لحظات لمعرفة حالته الحالية.';

  @override
  String devicesBeingAdded(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'جارٍ إضافة $count جهاز',
      many: 'جارٍ إضافة $count جهازًا',
      few: 'جارٍ إضافة $count أجهزة',
      two: 'جارٍ إضافة جهازين',
      one: 'جارٍ إضافة جهاز واحد',
    );
    return '$_temp0';
  }

  @override
  String devicesAddedSuccessfully(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'تمت إضافة $count جهاز بنجاح',
      many: 'تمت إضافة $count جهازًا بنجاح',
      few: 'تمت إضافة $count أجهزة بنجاح',
      two: 'تمت إضافة جهازين بنجاح',
      one: 'تمت إضافة جهاز واحد بنجاح',
    );
    return '$_temp0';
  }

  @override
  String get alexaExamplesIntro =>
      'يمكنك التحكم في الأجهزة المتوافقة مع Alexa\nعبر مكبرات صوت Amazon Alexa، مثل';

  @override
  String get googleExamplesIntro =>
      'يمكنك الآن استخدام مكبر صوت Google Home\nللتحكم في أجهزة Google Assistant، مثل';

  @override
  String get gridView => 'عرض شبكي';

  @override
  String get listView => 'عرض قائمة';

  @override
  String get deviceManagement => 'إدارة الأجهزة';

  @override
  String get sort => 'ترتيب';

  @override
  String get darkMode => 'الوضع الداكن';

  @override
  String get followSystem => 'اتباع النظام';

  @override
  String get system => 'النظام';

  @override
  String get systemDarkModeHint =>
      'عند التفعيل، يقوم التطبيق بتشغيل الوضع الداكن أو إيقافه بما يطابق إعدادات نظامك.';

  @override
  String get normalMode => 'الوضع العادي';

  @override
  String get deviceStatus => 'حالة الجهاز';

  @override
  String get selectDevice => 'اختر الجهاز';

  @override
  String get condition => 'الشرط';

  @override
  String get precondition => 'شرط مسبق';

  @override
  String get customTime => 'مخصص';

  @override
  String get startTime => 'وقت البدء';

  @override
  String get endTime => 'وقت الانتهاء';

  @override
  String get overnightNote =>
      'تمتد هذه الفترة بعد منتصف الليل. تُحتسب من اليوم الذي تبدأ فيه.';

  @override
  String get automationDelayNote =>
      'يعمل خلال 5 ثوانٍ تقريبًا من التغيير، ثم يتوقف 60 ثانية. لا يعمل التشغيل التلقائي الجديد إذا كان شرطه مستوفى بالفعل — بل عند التغيير التالي فقط.';

  @override
  String get selectCity => 'اختر المدينة';

  @override
  String get searchCity => 'ابحث عن مدينة';

  @override
  String get equals => 'يساوي';

  @override
  String get notEquals => 'لا يساوي';

  @override
  String get greaterThan => 'أكبر من';

  @override
  String get greaterOrEqual => 'أكبر من أو يساوي';

  @override
  String get lessThan => 'أصغر من';

  @override
  String get lessOrEqual => 'أصغر من أو يساوي';

  @override
  String get noReadableDataPoints =>
      'لا تتوفر لهذا الجهاز حالة قابلة للقراءة لاستخدامها كشرط.';

  @override
  String get bluetoothOffMessage =>
      'البلوتوث مطفأ — شغّله للعثور على الأجهزة القريبة';
}
