// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_l10n.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppL10nZh extends AppL10n {
  AppL10nZh([String locale = 'zh']) : super(locale);

  @override
  String get settingsTitle => '设置';

  @override
  String get personalInformation => '个人信息';

  @override
  String get accountAndSecurity => '账号与安全';

  @override
  String get touchToneOnPanel => '面板按键音';

  @override
  String get aiAssistant => 'AI 助手';

  @override
  String get temperatureUnit => '温度单位';

  @override
  String get about => '关于';

  @override
  String get networkDiagnosis => '网络诊断';

  @override
  String get clearCache => '清除缓存';

  @override
  String get language => '语言';

  @override
  String get logOut => '退出登录';

  @override
  String get languageSystemDefault => '跟随系统语言';

  @override
  String get languageEnglish => '英语';

  @override
  String get languageVietnamese => '越南语';

  @override
  String get clearCacheMessage => '已缓存的场景、家庭数据和图片将在下次使用时重新下载。您的账号和设备不会受到影响。';

  @override
  String get clear => '清除';

  @override
  String get cancel => '取消';

  @override
  String freedSpace(String size) {
    return '已释放 $size';
  }

  @override
  String aboutVersion(String version, String build) {
    return '版本 $version（$build）';
  }

  @override
  String get privacyPolicy => '隐私政策';

  @override
  String get termsOfService => '服务条款';

  @override
  String get bundleId => 'Bundle ID';

  @override
  String get server => '服务器';

  @override
  String get couldNotOpenLink => '无法打开链接。';

  @override
  String get diagLocalNetwork => '本地网络';

  @override
  String get diagLocalNetworkNoWifi => '未连接 Wi-Fi（使用移动数据或权限被拒绝）';

  @override
  String get diagLocalNetworkUnreadable => '无法读取 Wi-Fi 名称';

  @override
  String get diagDnsLookup => 'DNS 解析';

  @override
  String diagDnsFailed(String host) {
    return '无法解析 $host';
  }

  @override
  String get diagServerReachable => '服务器可访问';

  @override
  String diagServerLatency(String ms, String status) {
    return '$ms 毫秒 · HTTP $status';
  }

  @override
  String get diagServerNoResponse => '服务器无响应';

  @override
  String get diagSignedIn => '已登录';

  @override
  String get diagSessionValid => '会话有效';

  @override
  String diagSessionInvalid(String status) {
    return 'HTTP $status — 请重新登录';
  }

  @override
  String get diagSessionUnverified => '无法验证会话';

  @override
  String get diagControlChannel => '控制通道';

  @override
  String get diagCloudConnected => '云端（MQTT）已连接';

  @override
  String get diagBleFallback => '云端不可用 — 已切换 Bluetooth 连接';

  @override
  String get diagUnreachable => '无云端连接，附近也无 Bluetooth 信号';

  @override
  String get diagStatusUnknown => '状态未知';

  @override
  String get runAgain => '重新检测';

  @override
  String get accountCreatedPleaseSignIn => '账号已创建，请登录。';

  @override
  String get add => '添加';

  @override
  String get addCondition => '添加条件';

  @override
  String get addRoom => '添加房间';

  @override
  String get addTask => '添加任务';

  @override
  String get addAtLeastTwoDevicesToAGroup => '群组至少需要两个设备。';

  @override
  String get alexa => 'Alexa';

  @override
  String get all => '全部';

  @override
  String get allDevices => '所有设备';

  @override
  String get alternateNetwork => '备用网络';

  @override
  String get apply => '应用';

  @override
  String get areYouSureYouWantToLogOut => '确定要退出登录吗？';

  @override
  String get askAboutYourCurtainsOrTryHelp => '询问窗帘相关问题，或输入 /help…';

  @override
  String get askAboutYourCurtains => '询问窗帘相关问题…';

  @override
  String get atLeast6Characters => '至少 6 个字符';

  @override
  String get authDiagnostics => '认证诊断';

  @override
  String get automationNotification => '自动化通知';

  @override
  String get changeRoom => '更换房间';

  @override
  String get close => '关闭';

  @override
  String get cloud => '云端';

  @override
  String get confirm => '确认';

  @override
  String get connected => '已连接';

  @override
  String get control => '控制';

  @override
  String get controlSingleDevice => '控制单个设备';

  @override
  String get copiedToClipboard => '已复制到剪贴板';

  @override
  String get copy => '复制';

  @override
  String get couldNotChangeTheMotorDirectionPleaseTryAgai => '无法更改电机方向，请重试。';

  @override
  String get couldNotConnect => '无法连接';

  @override
  String get couldNotCreateTheGroupPleaseTryAgain => '无法创建群组，请重试。';

  @override
  String get couldNotOpenTheBrowser => '无法打开浏览器。';

  @override
  String get couldNotSendTheCommandPleaseTryAgain => '无法发送指令，请重试。';

  @override
  String get create => '创建';

  @override
  String get createScene => '创建场景';

  @override
  String get createAHome => '创建家庭';

  @override
  String get createARoomFirst => '请先创建房间。';

  @override
  String get createAccount => '注册账号';

  @override
  String get createScene2 => '创建场景';

  @override
  String get curtainPosition => '窗帘位置';

  @override
  String get curtainPositionSetting => '窗帘位置设置';

  @override
  String get customDeviceIconsAreNotSupportedYet => '暂不支持自定义设备图标。';

  @override
  String get delayTheAction => '延迟执行';

  @override
  String get delete => '删除';

  @override
  String get deleteAccount => '注销账号';

  @override
  String get deleteHome => '删除家庭';

  @override
  String get deleteRoom => '删除房间';

  @override
  String get deleteSchedule => '删除定时';

  @override
  String get deleteScene => '删除场景？';

  @override
  String get deleteThisSchedule => '删除此定时？';

  @override
  String get deviceNetwork => '设备网络';

  @override
  String get deviceHasNoProfileInformation => '设备暂无配置信息';

  @override
  String get deviceIsOffline => '设备已离线';

  @override
  String get deviceIsReady => '设备已就绪。';

  @override
  String get deviceName => '设备名称';

  @override
  String get deviceRemovedFromHome => '设备已从家庭中移除。';

  @override
  String get deviceUnreachable => '设备无法连接';

  @override
  String get devices => '设备';

  @override
  String get disconnect => '断开连接';

  @override
  String get disconnectDevice => '断开设备连接？';

  @override
  String get done => '完成';

  @override
  String get emailAddress => '邮箱地址';

  @override
  String get emailOrUsername => '邮箱或用户名';

  @override
  String get enterAGroupName => '请输入群组名称';

  @override
  String get enterANote => '请输入备注';

  @override
  String get enterDeviceName => '请输入设备名称';

  @override
  String get enterHomeName => '请输入家庭名称';

  @override
  String get enterName => '请输入名称';

  @override
  String get enterSceneName => '请输入场景名称';

  @override
  String get enterValue => '请输入数值...';

  @override
  String get enterYourPassword => '请输入密码';

  @override
  String get eraseDeviceData => '清除设备数据？';

  @override
  String get error => '错误';

  @override
  String get executedBy => '执行者';

  @override
  String get executionTime => '执行时间';

  @override
  String get faqFeedback => '常见问题与反馈';

  @override
  String get failed => '失败';

  @override
  String get featureComingSoon => '功能即将上线';

  @override
  String get firmware => '固件';

  @override
  String get firmwareUpdateIsComingSoon => '固件更新即将上线。';

  @override
  String get firstName => '名字';

  @override
  String get firstNameOptional => '名字（选填）';

  @override
  String get goBack => '返回';

  @override
  String get googleAssistant => 'Google Assistant';

  @override
  String get gotIt => '知道了';

  @override
  String get groupName => '群组名称';

  @override
  String get help => '帮助';

  @override
  String get homeManagement => '家庭管理';

  @override
  String get homeName => '家庭名称';

  @override
  String get homeName2 => '家庭名称';

  @override
  String get icon => '图标';

  @override
  String get conditionIf => '如果';

  @override
  String get joinAHome => '加入家庭';

  @override
  String get joiningAHomeByInviteIsComingSoon => '通过邀请加入家庭即将上线。';

  @override
  String get lastName => '姓氏';

  @override
  String get lastNameOptional => '姓氏（选填）';

  @override
  String get later => '稍后';

  @override
  String get launchTapToRun => '执行 Tap-to-Run';

  @override
  String get localAssociation => '本地关联';

  @override
  String get localControlOffline => '本地控制（离线）';

  @override
  String get location => '位置';

  @override
  String get logCopiedToClipboard => '日志已复制到剪贴板';

  @override
  String get logs => '日志';

  @override
  String get manage => '管理';

  @override
  String get managePermissions => '权限管理';

  @override
  String get markAllAsRead => '全部标为已读';

  @override
  String get moreSettings => '更多设置';

  @override
  String get motorDirection => '电机方向';

  @override
  String get moveToTop => '移到顶部';

  @override
  String get moveToRoom => '移到房间';

  @override
  String get moved => '已移动';

  @override
  String get movedToTop => '已移到顶部';

  @override
  String get name => '名称';

  @override
  String get next => '下一步';

  @override
  String get noDevicesAvailable => '暂无可用设备';

  @override
  String get noDevicesFound => '未找到设备。';

  @override
  String get noDevicesInThisHome => '该家庭暂无设备。';

  @override
  String get noDevicesYet => '暂无设备';

  @override
  String get noFunctionsAvailable => '暂无可用功能';

  @override
  String get noHomeSelectedPleaseTryAgain => '未选择家庭，请重试';

  @override
  String get noMatchingTimeZones => '未找到匹配的时区';

  @override
  String get noOtherScenesAvailable => '暂无其他场景';

  @override
  String get noRooms => '暂无房间';

  @override
  String get noSavedNetworksYet => '暂无已保存的网络。';

  @override
  String get noScenes => '暂无场景';

  @override
  String get noScenesAvailable => '暂无可用场景';

  @override
  String get note => '备注';

  @override
  String get notification => '通知';

  @override
  String get ok => '确定';

  @override
  String get offlineNotification => '离线通知';

  @override
  String get open => '打开';

  @override
  String get openSettings => '打开设置';

  @override
  String get outdoorPm25 => '室外 PM2.5';

  @override
  String get outdoorAirPressure => '室外气压';

  @override
  String get outdoorHumidity => '室外湿度';

  @override
  String get outdoorWindSpeed => '室外风速';

  @override
  String get pairingSuccessful => '配对成功';

  @override
  String get password => '密码';

  @override
  String get sessionExpiredSignInAgain => '登录已过期，请重新登录。';

  @override
  String get pleaseAddAtLeast1Action => '请至少添加 1 个动作';

  @override
  String get pleaseAddAtLeast1Condition => '请至少添加 1 个条件';

  @override
  String get pleaseEnterAName => '请输入名称';

  @override
  String get pleaseEnterASceneName => '请输入场景名称';

  @override
  String get pleaseSelectAFunction => '请选择功能';

  @override
  String get pleaseSelectATime0 => '请选择大于 0 的时间';

  @override
  String get rePairNow => '立即重新配对';

  @override
  String get rePairRequired => '需要重新配对';

  @override
  String get reasonOptional => '原因（选填）';

  @override
  String get refresh => '刷新';

  @override
  String get reload => '重新加载';

  @override
  String get remove => '移除';

  @override
  String get removeDevice => '移除设备';

  @override
  String get removed => '已移除';

  @override
  String get rename => '重命名';

  @override
  String get renameRoom => '重命名房间';

  @override
  String get renameDevice => '重命名设备';

  @override
  String get repeat => '重复';

  @override
  String get rescan => '重新扫描';

  @override
  String get retry => '重试';

  @override
  String get roomManagement => '房间管理';

  @override
  String get roomName => '房间名称';

  @override
  String get roomUpdated => '房间已更新';

  @override
  String get running => '执行中';

  @override
  String get save => '保存';

  @override
  String get sceneName => '场景名称';

  @override
  String get scenes => '场景';

  @override
  String get schedule => '定时';

  @override
  String get searchAddress => '搜索地址';

  @override
  String get searchCityOrRegion => '搜索城市或地区';

  @override
  String get selectScene => '选择场景';

  @override
  String get selectSmartScenes => '选择智能场景';

  @override
  String get sendResetLink => '发送重置链接';

  @override
  String get sendVerificationCode => '发送验证码';

  @override
  String get showOnHomePage => '在首页显示';

  @override
  String get signIn => '登录';

  @override
  String get signalStrength => '信号强度';

  @override
  String get signalStrength2 => '信号强度';

  @override
  String get startPairing => '开始配对';

  @override
  String get stop => '停止';

  @override
  String get style => '样式';

  @override
  String get switchNetwork => '切换';

  @override
  String get switchToThisNetwork => '切换到此网络';

  @override
  String get tapToRunNotification => 'Tap-to-Run 通知';

  @override
  String get conditionThen => '那么';

  @override
  String get thinking => '思考中…';

  @override
  String get thisActionCannotBeUndone => '此操作无法撤销。';

  @override
  String get thisSavedNetworkWillBeRemovedFromTheDevice => '该已保存的网络将从设备中移除。';

  @override
  String get timeZone => '时区';

  @override
  String get timeZoneUpdated => '时区已更新';

  @override
  String get timedOut => '已超时';

  @override
  String get tryAgain => '请重试';

  @override
  String get useCurrentLocation => '使用当前位置';

  @override
  String get usingSiri => '使用 Siri';

  @override
  String get virtualId => '虚拟 ID';

  @override
  String get whenDeviceStatusChanges => '当设备状态变化时';

  @override
  String get whenWeatherChanges => '当天气变化时';

  @override
  String get wiFi => 'Wi-Fi';

  @override
  String get wifiNameSsid => 'WiFi 名称（SSID）';

  @override
  String get wifiPassword => 'WiFi 密码';

  @override
  String get navHome => '首页';

  @override
  String get navScenes => '场景';

  @override
  String get navChat => '对话';

  @override
  String get navMe => '我的';

  @override
  String get thirdPartyServices => '第三方服务';

  @override
  String get messageCenter => '消息中心';

  @override
  String get appMall => '应用商城';

  @override
  String get addDevice => '添加设备';

  @override
  String get tapToRun => '一键执行';

  @override
  String get automationEmptyHint => '智能自动化让日常操作自动完成，为你省时省力。';

  @override
  String get tapToRunEmptyHint => '创建一键执行场景，轻点一次即可控制多个设备。';

  @override
  String get scene => '场景';

  @override
  String get executionFailed => '执行失败';

  @override
  String get device => '设备';

  @override
  String get delay => '延时';

  @override
  String get runScene => '执行场景';

  @override
  String get addToSiri => '添加到 Siri';

  @override
  String get storeUnderPreparation => '商城正在筹备中，敬请期待。';

  @override
  String get commonFunctions => '常用功能';

  @override
  String get noConnection => '无网络连接';

  @override
  String get checkInternetAndRetry => '请检查网络连接后重试。';

  @override
  String get noConnectionCheckInternet => '无网络连接。请检查网络后重试。';

  @override
  String get addFirstCurtainHint => '点击 + 按钮，为该家庭添加第一个窗帘。';

  @override
  String get hideInvisibleDevices => '隐藏不可见设备';

  @override
  String get deviceRenamed => '设备已重命名。';

  @override
  String get deviceDeletedReturningToPairing => '设备已删除，正在恢复配网模式。';

  @override
  String get homeSettings => '家庭设置';

  @override
  String get toBeSet => '待设置';

  @override
  String get homeMember => '家庭成员';

  @override
  String get memberDetails => '成员详情';

  @override
  String get addMember => '添加成员';

  @override
  String get pending => '待确认';

  @override
  String get removesFromHomeHint => '从家庭中移除；设备将在 1-2 分钟后恢复配网模式';

  @override
  String get unlinkAndEraseData => '解除关联并清除数据';

  @override
  String get erasesAllDataHint => '清除全部数据，且无法恢复';

  @override
  String get somethingWentWrongTryAgain => '出错了，请重试';

  @override
  String get tapToRunAndAutomation => '一键执行与自动化';

  @override
  String get thirdPartyControl => '第三方控制';

  @override
  String get deviceOfflineNotification => '设备离线通知';

  @override
  String get others => '其他';

  @override
  String get shareDevice => '分享设备';

  @override
  String get addToHomeScreen => '添加到主屏幕';

  @override
  String get checkDeviceNetwork => '检测设备网络';

  @override
  String get checkNow => '立即检测';

  @override
  String get deviceUpdate => '设备升级';

  @override
  String get removeDevicesWarning => '设备将从该家庭中移除并恢复配网模式。';

  @override
  String get shown => '已显示';

  @override
  String get hidden => '已隐藏';

  @override
  String get devicesBackOnHome => '设备已恢复显示在首页';

  @override
  String get hiddenFromHome => '已从首页隐藏';

  @override
  String get offline => '离线';

  @override
  String get show => '显示';

  @override
  String get hide => '隐藏';

  @override
  String get profilePhoto => '头像';

  @override
  String get nickname => '昵称';

  @override
  String get noRoomsYet => '暂无房间';

  @override
  String get tapPlusToAddRoom => '点击 + 添加新房间';

  @override
  String get emailAddressLabel => '邮箱地址';

  @override
  String get notSet => '未设置';

  @override
  String get deviceInformation => '设备信息';

  @override
  String get unknown => '未知';

  @override
  String get notReported => '未上报';

  @override
  String get noScenesUseThisDevice => '暂无场景使用该设备。';

  @override
  String get tapToRunLabel => '一键执行';

  @override
  String get automation => '自动化';

  @override
  String get forward => '正向';

  @override
  String get back => '反向';

  @override
  String get setting => '设置';

  @override
  String get updateAvailable => '有可用更新';

  @override
  String get noUpdatesAvailable => '暂无可用更新';

  @override
  String get updateNow => '立即升级';

  @override
  String get unassigned => '未分配';

  @override
  String get enterEmailOrUsername => '请输入邮箱或用户名';

  @override
  String get welcome => '欢迎';

  @override
  String get signInSubtitle => '登录你的 osprey.life 账号。';

  @override
  String get createOne => '立即注册';

  @override
  String get forgotPassword => '忘记密码？';

  @override
  String get orContinueWith => '或使用以下方式登录';

  @override
  String get enterValidEmail => '请输入有效的邮箱地址';

  @override
  String get resetYourPassword => '重置密码';

  @override
  String get checkYourInbox => '请查看邮箱';

  @override
  String get enterYourEmailAddress => '请输入邮箱地址';

  @override
  String get enterSixDigitCode => '请输入 6 位验证码';

  @override
  String get enterAPassword => '请输入密码';

  @override
  String get createYourAccount => '创建账号';

  @override
  String get checkYourEmail => '请查看邮件';

  @override
  String get resendCode => '重新发送验证码';

  @override
  String get userAgreement => '用户协议';

  @override
  String get reconnecting => '正在重新连接…';

  @override
  String get checkWifiOrBluetooth => '请检查 Wi-Fi，或靠近设备以使用蓝牙。';

  @override
  String get smartScenesRequireInternet => '智能场景需要联网';

  @override
  String get enterWifiName => '请输入 Wi-Fi 名称';

  @override
  String get wifiNameLengthError => 'Wi-Fi 名称需为 1–32 个字符';

  @override
  String get passwordMin8 => '密码至少需要 8 个字符';

  @override
  String get passwordLength863 => '密码需为 8–63 个字符';

  @override
  String get networkAlreadySaved => '该网络已保存。若要修改密码，请先删除后重新添加。';

  @override
  String get addWifiNetwork => '添加 Wi-Fi 网络';

  @override
  String get atLeast8Characters => '至少 8 个字符';

  @override
  String get only24GhzSupported => '窗帘设备仅支持 2.4GHz Wi-Fi（WPA2）。';

  @override
  String get labelOptional => '备注（选填）';

  @override
  String get createGroup => '创建群组';

  @override
  String get groupControlHint => '同一群组内的设备可以一起控制。';

  @override
  String get devicesToBeAdded => '待添加的设备';

  @override
  String get noSameTypeDevices => '该家庭中没有其他同类型设备。';

  @override
  String get couldNotLoadNetworkDetails => '无法加载网络详情，请下拉刷新。';

  @override
  String get alreadyOnThisNetwork => '已连接该网络。';

  @override
  String get deviceOfflineTryLater => '设备离线 — 请稍后重试。';

  @override
  String get wrongPassword => '密码错误';

  @override
  String get networkNotFound => '未找到该网络';

  @override
  String get networkRemoved => '网络已删除。';

  @override
  String get network => '网络';

  @override
  String get connectedTo => '已连接';

  @override
  String get savedNetworks => '已保存的网络';

  @override
  String get addANetwork => '添加网络';

  @override
  String get notConnected => '未连接';

  @override
  String get pleaseKeepAppOpen => '请保持应用在前台运行。';

  @override
  String get deviceNetworkInformation => '设备网络信息';

  @override
  String get once => '单次';

  @override
  String get editSchedule => '编辑定时';

  @override
  String get addSchedule => '添加定时';

  @override
  String get timeVarianceHint => '时间误差约 ±30 秒';

  @override
  String get noTimerData => '暂无定时数据';

  @override
  String get localControlUnsupportedAction => '本地控制不支持该操作';

  @override
  String get noInternetNoBluetooth => '无网络且蓝牙不在范围内';

  @override
  String get connectionError => '连接失败';

  @override
  String get exampleTapToRun => '例如：一键关闭卧室所有灯光。';

  @override
  String get exampleWeather => '例如：当本地温度高于 28°C 时。';

  @override
  String get weatherTrigger => '天气触发';

  @override
  String get exampleSchedule => '例如：每天早上 7:00。';

  @override
  String get exampleDeviceStatus => '例如：检测到异常活动时。';

  @override
  String get deviceStatusTrigger => '设备状态触发';

  @override
  String get noNotificationsYet => '暂无通知';

  @override
  String get slashCommands => '斜杠命令';

  @override
  String get slashDevicesHint => '查看并控制你的窗帘。';

  @override
  String get slashSceneHint => '执行一键执行场景。';

  @override
  String get slashScheduleHint => '打开自动化定时。';

  @override
  String get slashHelpHint => '显示此列表。';

  @override
  String get youCanAlsoSpeak => '也可以说话 — 点击麦克风按钮。';

  @override
  String get chatInputHint => '输入文字、语音，或使用斜杠命令。';

  @override
  String get online => '在线';

  @override
  String get blePermissionRequired => '查找设备需要蓝牙权限';

  @override
  String get bleAndLocationPermissionRequired => '查找设备需要蓝牙和定位权限';

  @override
  String get addDeviceLower => '添加设备';

  @override
  String get scanningStopped => '已停止搜索。';

  @override
  String get enterWifiPassword => '请输入 Wi-Fi 密码';

  @override
  String get detectingCurrentWifi => '正在检测当前 Wi-Fi…';

  @override
  String get autoDetectedWifi => '已自动获取手机当前连接的 Wi-Fi';

  @override
  String get couldNotDetectWifi => '无法获取 Wi-Fi — 请手动输入网络名称';

  @override
  String get beingAdded => '正在添加';

  @override
  String get addedSuccessfully => '添加成功';

  @override
  String get pairingFailed => '配网失败';

  @override
  String get allDay => '全天';

  @override
  String get whenAnyConditionMet => '满足任一条件时';

  @override
  String get whenAllConditionsMet => '满足全部条件时';

  @override
  String get deleteSceneWarning => '场景删除后，其中的设备任务将无法正常执行。';

  @override
  String get toggleAutomation => '开关自动化';

  @override
  String get enable => '开启';

  @override
  String get disable => '关闭';

  @override
  String get everyDay => '每天';

  @override
  String get monToFri => '周一至周五';

  @override
  String get satToSun => '周六至周日';

  @override
  String get runOnceIfNoDaySelected => '若未选择任何星期，该操作仅执行一次。';

  @override
  String get sendNotification => '发送通知';

  @override
  String get color => '颜色';

  @override
  String get wait => '等待';

  @override
  String get finish => '完成';

  @override
  String get selectFunction => '选择功能';

  @override
  String get on => '开';

  @override
  String get off => '关';

  @override
  String get siriShortcut => 'Siri 快捷指令';

  @override
  String get createTapToRunFirst => '请先创建一键执行场景。';

  @override
  String get poweredByFoundationModels => '由 Apple Foundation Models 在设备端驱动。';

  @override
  String get weatherClearNight => '晴朗夜间';

  @override
  String get weatherSunny => '晴';

  @override
  String get weatherPartlyCloudy => '局部多云';

  @override
  String get weatherCloudy => '多云';

  @override
  String get qualityExcellent => '优';

  @override
  String get qualityGood => '良';

  @override
  String get qualityModerate => '中';

  @override
  String get qualityPoor => '差';

  @override
  String get qualityVeryPoor => '极差';

  @override
  String get switchLocation => '切换位置';

  @override
  String get aiSuggestion => 'AI 建议';

  @override
  String get listening => '正在聆听…';

  @override
  String get parsing => '正在解析…';

  @override
  String get getStarted => '开始使用';

  @override
  String get aiChatEmptyState =>
      '有关窗帘的任何问题，都可以问 osprey.life 助手。\n由 Apple Foundation Models 在设备端驱动。';

  @override
  String get chatHeaderSubtitle => '为你的电动窗帘打造的端侧 AI。\n输入文字、语音，或使用斜杠命令。';

  @override
  String get daySunShort => '周日';

  @override
  String get dayMonShort => '周一';

  @override
  String get dayTueShort => '周二';

  @override
  String get dayWedShort => '周三';

  @override
  String get dayThuShort => '周四';

  @override
  String get dayFriShort => '周五';

  @override
  String get daySatShort => '周六';

  @override
  String get dayMon => '周一';

  @override
  String get dayTue => '周二';

  @override
  String get dayWed => '周三';

  @override
  String get dayThu => '周四';

  @override
  String get dayFri => '周五';

  @override
  String get daySat => '周六';

  @override
  String get daySun => '周日';

  @override
  String get accountLinkedSuccessfully => '账号关联成功！';

  @override
  String get linkingFailed => '关联失败';

  @override
  String get anErrorOccurredTryAgain => '出错了，请重试。';

  @override
  String get signInWithAmazon => '使用亚马逊账号登录';

  @override
  String get viewMoreWaysToLink => '查看更多关联方式';

  @override
  String get alreadyLinkedWithAlexa => '已关联 Amazon Alexa';

  @override
  String get somethingWentWrong => '出错了';

  @override
  String get noAuthorizationCode => '未收到授权码';

  @override
  String get couldNotOpenGoogleHome => '无法打开 Google Home 应用';

  @override
  String get reLogin => '重新登录';

  @override
  String get linkWithGoogleAssistant => '关联 Google Assistant';

  @override
  String get linkedWithGoogleAssistant => '已关联 Google Assistant';

  @override
  String get anErrorOccurred => '发生错误';

  @override
  String deleteHomeConfirm(String name) {
    return '确定要删除“$name”吗？此操作无法撤销。';
  }

  @override
  String get offlineScenesBody => 'Wi-Fi 恢复前，场景和定时将暂停。蓝牙本地控制仍可对每个设备直接执行开/关/停。';

  @override
  String get blePairingLostBody => '蓝牙本地控制需要与该设备重新配对。这通常发生在清除应用数据或设备恢复出厂设置之后。';

  @override
  String get alternateNetworkHint => '当前网络不可用时，设备将自动连接到备用网络。';

  @override
  String get switchNetworkWarning => '设备将断开当前 Wi-Fi 并尝试连接新网络，通常需要 5–30 秒。';

  @override
  String get runOnceIfNoDayPicked => '若未选择，该操作仅执行一次。';

  @override
  String get alexaUnlinkHint =>
      '请在 Amazon Alexa 应用中停用 osprey.life 技能，或点击「我的」>右上角设置按钮>账号与安全，取消授权。';

  @override
  String get alexaLinkExplainer =>
      '将应用账号与亚马逊账号绑定后，即可通过 Amazon Echo 音箱控制支持 Alexa 的设备（例如“Alexa, turn on light.”）';

  @override
  String get chatScheduleHelp => '为窗帘设置自动定时。打开「场景」页即可创建每天、每周或单次的自动化定时。';

  @override
  String get chatScenesHelp => '在「场景」页创建和管理一键执行场景。场景可将多个窗帘动作与延时串联，一键完成。';

  @override
  String get googleUnlinkHint =>
      '请在 Google Home 应用中停用 osprey.life 技能，或点击「我的」>右上角设置按钮>账号与安全，取消授权。';

  @override
  String get googleLinkExplainer =>
      '关联应用账号与 Google 账号后，即可使用 Google Home 智能音箱控制支持 Google Assistant 的设备。例如，你可以说：“OK Google, please turn on the light.”';

  @override
  String get deviceDisconnectedFromHome => '设备已从家庭中移除，将在 1-2 分钟后恢复配网模式。';

  @override
  String get searchingNearbyDevices => '正在搜索附近的 Osprey 设备，请确认设备已进入配网模式。';

  @override
  String get looksLike5GhzHint => '该网络似乎是 5GHz — 请将手机切换到 2.4GHz 网络后点击刷新。';

  @override
  String get pairingWifiHint => '设备将连接手机当前使用的 Wi-Fi，仅支持 2.4GHz 网络。';

  @override
  String get siriShortcutsHelp =>
      '点击场景录制语音短语，之后说“Hey Siri”加该短语即可执行场景 — 即使应用已关闭。\n\n点击已添加的场景可修改短语或将其移除。';

  @override
  String get deleteAccountWarning =>
      '注销后：\n• 你的账号将在 30 天后被删除\n• 你的全部设备和场景将被移除\n• 30 天内重新登录可取消注销';

  @override
  String aiSuggestionBody(String action, String weekday, String hour) {
    return '你通常在$weekday $hour:00 执行“$action” — 要设为自动化吗？';
  }

  @override
  String removeDeviceConfirm(String name) {
    return '“$name”将从你的家庭中移除，并在约 1-2 分钟后自动恢复配网模式。';
  }

  @override
  String eraseDeviceConfirm(String name) {
    return '“$name”的所有数据将被清除且无法恢复。确定继续吗？';
  }

  @override
  String showInvisibleDevices(int count) {
    return '显示不可见设备（$count）';
  }

  @override
  String resetLinkSent(String email) {
    return '若 $email 已注册账号，重置密码链接即将发送。';
  }

  @override
  String signInNotAvailable(String name) {
    return '$name 登录方式暂未开放。';
  }

  @override
  String resendCodeIn(int seconds) {
    return '$seconds 秒后可重新发送';
  }

  @override
  String deleteConfirmNamed(String name) {
    return '确定要删除“$name”吗？';
  }

  @override
  String taskCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 个任务',
    );
    return '$_temp0';
  }

  @override
  String featureComingSoonShort(String feature) {
    return '$feature即将上线';
  }

  @override
  String roomCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 个房间',
    );
    return '$_temp0';
  }

  @override
  String removeDevicesQ(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '要移除 $count 个设备吗？',
      one: '要移除该设备吗？',
    );
    return '$_temp0';
  }

  @override
  String devicesRemoved(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '已移除 $count 个设备',
      one: '已移除 1 个设备',
    );
    return '$_temp0';
  }

  @override
  String deviceCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 个设备',
    );
    return '$_temp0';
  }

  @override
  String mainModuleVersion(String version) {
    return '主模块：V$version';
  }

  @override
  String outdoorTemperatureValue(int temp) {
    return '室外温度：$temp°C';
  }

  @override
  String occurrencesIn30Days(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '30 天内 $count 次',
    );
    return '$_temp0';
  }

  @override
  String sceneExecuted(String name) {
    return '“$name”已执行';
  }

  @override
  String couldNotRunScene(String name) {
    return '无法执行“$name”，请重试。';
  }

  @override
  String featureComingSoonNamed(String feature) {
    return '$feature即将上线。';
  }

  @override
  String get couldNotLoadHome => '无法加载你的家庭，请重试。';

  @override
  String deviceCouldNotConnectTo(String ssid, String reason, String stayedOn) {
    return '设备无法连接到“$ssid”。\n\n原因：$reason\n\n设备仍连接在“$stayedOn”。';
  }

  @override
  String makeSureNetworkInRange(String ssid) {
    return '\n\n请确认“$ssid”已开启且在信号范围内。';
  }

  @override
  String get noResponseFromDevice => '设备没有响应。请稍后刷新查看当前状态。';

  @override
  String devicesBeingAdded(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '正在添加 $count 个设备',
    );
    return '$_temp0';
  }

  @override
  String devicesAddedSuccessfully(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '成功添加 $count 个设备',
    );
    return '$_temp0';
  }

  @override
  String get alexaExamplesIntro => '你可以通过 Amazon Alexa 音箱\n控制支持 Alexa 的设备，例如';

  @override
  String get googleExamplesIntro =>
      '现在你可以使用 Google Home 音箱\n控制 Google Assistant 设备，例如';
}

/// The translations for Chinese, using the Han script (`zh_Hant`).
class AppL10nZhHant extends AppL10nZh {
  AppL10nZhHant() : super('zh_Hant');

  @override
  String get settingsTitle => '設定';

  @override
  String get personalInformation => '個人資料';

  @override
  String get accountAndSecurity => '帳號與安全';

  @override
  String get touchToneOnPanel => '面板按鍵音';

  @override
  String get aiAssistant => 'AI 助理';

  @override
  String get temperatureUnit => '溫度單位';

  @override
  String get about => '關於';

  @override
  String get networkDiagnosis => '網路診斷';

  @override
  String get clearCache => '清除快取';

  @override
  String get language => '語言';

  @override
  String get logOut => '登出';

  @override
  String get languageSystemDefault => '與系統語言相同';

  @override
  String get languageEnglish => '英文';

  @override
  String get languageVietnamese => '越南文';

  @override
  String get clearCacheMessage => '已快取的場景、家庭資料與圖片將於下次使用時重新下載。不會影響您的帳號與裝置。';

  @override
  String get clear => '清除';

  @override
  String get cancel => '取消';

  @override
  String freedSpace(String size) {
    return '已釋放 $size';
  }

  @override
  String aboutVersion(String version, String build) {
    return '版本 $version（$build）';
  }

  @override
  String get privacyPolicy => '隱私權政策';

  @override
  String get termsOfService => '服務條款';

  @override
  String get bundleId => 'Bundle ID';

  @override
  String get server => '伺服器';

  @override
  String get couldNotOpenLink => '無法開啟連結。';

  @override
  String get diagLocalNetwork => '區域網路';

  @override
  String get diagLocalNetworkNoWifi => '未連線 Wi-Fi（使用行動網路或權限被拒）';

  @override
  String get diagLocalNetworkUnreadable => '無法讀取 Wi-Fi 名稱';

  @override
  String get diagDnsLookup => 'DNS 查詢';

  @override
  String diagDnsFailed(String host) {
    return '無法解析 $host';
  }

  @override
  String get diagServerReachable => '伺服器可連線';

  @override
  String diagServerLatency(String ms, String status) {
    return '$ms ms · HTTP $status';
  }

  @override
  String get diagServerNoResponse => '伺服器沒有回應';

  @override
  String get diagSignedIn => '已登入';

  @override
  String get diagSessionValid => '工作階段有效';

  @override
  String diagSessionInvalid(String status) {
    return 'HTTP $status — 請重新登入';
  }

  @override
  String get diagSessionUnverified => '無法驗證工作階段';

  @override
  String get diagControlChannel => '控制通道';

  @override
  String get diagCloudConnected => '雲端（MQTT）已連線';

  @override
  String get diagBleFallback => '雲端中斷 — 改用 Bluetooth 連線';

  @override
  String get diagUnreachable => '無雲端連線，附近也沒有 Bluetooth 裝置';

  @override
  String get diagStatusUnknown => '狀態未知';

  @override
  String get runAgain => '重新執行';

  @override
  String get accountCreatedPleaseSignIn => '帳號已建立 — 請登入。';

  @override
  String get add => '新增';

  @override
  String get addCondition => '新增條件';

  @override
  String get addRoom => '新增房間';

  @override
  String get addTask => '新增任務';

  @override
  String get addAtLeastTwoDevicesToAGroup => '群組至少需加入兩個裝置。';

  @override
  String get alexa => 'Alexa';

  @override
  String get all => '全部';

  @override
  String get allDevices => '所有裝置';

  @override
  String get alternateNetwork => '備用網路';

  @override
  String get apply => '套用';

  @override
  String get areYouSureYouWantToLogOut => '確定要登出嗎？';

  @override
  String get askAboutYourCurtainsOrTryHelp => '詢問窗簾相關問題，或輸入 /help…';

  @override
  String get askAboutYourCurtains => '詢問窗簾相關問題…';

  @override
  String get atLeast6Characters => '至少 6 個字元';

  @override
  String get authDiagnostics => '驗證診斷';

  @override
  String get automationNotification => '自動化通知';

  @override
  String get changeRoom => '變更房間';

  @override
  String get close => '關閉';

  @override
  String get cloud => '雲端';

  @override
  String get confirm => '確認';

  @override
  String get connected => '已連線';

  @override
  String get control => '控制';

  @override
  String get controlSingleDevice => '控制單一裝置';

  @override
  String get copiedToClipboard => '已複製到剪貼簿';

  @override
  String get copy => '複製';

  @override
  String get couldNotChangeTheMotorDirectionPleaseTryAgai => '無法變更馬達方向，請重試。';

  @override
  String get couldNotConnect => '無法連線';

  @override
  String get couldNotCreateTheGroupPleaseTryAgain => '無法建立群組，請重試。';

  @override
  String get couldNotOpenTheBrowser => '無法開啟瀏覽器。';

  @override
  String get couldNotSendTheCommandPleaseTryAgain => '無法傳送指令，請重試。';

  @override
  String get create => '建立';

  @override
  String get createScene => '建立場景';

  @override
  String get createAHome => '建立家庭';

  @override
  String get createARoomFirst => '請先建立房間。';

  @override
  String get createAccount => '建立帳號';

  @override
  String get createScene2 => '建立場景';

  @override
  String get curtainPosition => '窗簾位置';

  @override
  String get curtainPositionSetting => '窗簾位置設定';

  @override
  String get customDeviceIconsAreNotSupportedYet => '尚不支援自訂裝置圖示。';

  @override
  String get delayTheAction => '延遲執行';

  @override
  String get delete => '刪除';

  @override
  String get deleteAccount => '刪除帳號';

  @override
  String get deleteHome => '刪除家庭';

  @override
  String get deleteRoom => '刪除房間';

  @override
  String get deleteSchedule => '刪除定時';

  @override
  String get deleteScene => '要刪除場景嗎？';

  @override
  String get deleteThisSchedule => '要刪除此定時嗎？';

  @override
  String get deviceNetwork => '裝置網路';

  @override
  String get deviceHasNoProfileInformation => '此裝置沒有設定檔資訊';

  @override
  String get deviceIsOffline => '裝置離線';

  @override
  String get deviceIsReady => '裝置已就緒。';

  @override
  String get deviceName => '裝置名稱';

  @override
  String get deviceRemovedFromHome => '已從家庭移除裝置。';

  @override
  String get deviceUnreachable => '無法連線裝置';

  @override
  String get devices => '裝置';

  @override
  String get disconnect => '中斷連線';

  @override
  String get disconnectDevice => '要中斷裝置連線嗎？';

  @override
  String get done => '完成';

  @override
  String get emailAddress => '電子郵件地址';

  @override
  String get emailOrUsername => '電子郵件或使用者名稱';

  @override
  String get enterAGroupName => '請輸入群組名稱';

  @override
  String get enterANote => '請輸入備註';

  @override
  String get enterDeviceName => '請輸入裝置名稱';

  @override
  String get enterHomeName => '請輸入家庭名稱';

  @override
  String get enterName => '請輸入名稱';

  @override
  String get enterSceneName => '請輸入場景名稱';

  @override
  String get enterValue => '請輸入數值…';

  @override
  String get enterYourPassword => '請輸入密碼';

  @override
  String get eraseDeviceData => '要清除裝置資料嗎？';

  @override
  String get error => '錯誤';

  @override
  String get executedBy => '執行者';

  @override
  String get executionTime => '執行時間';

  @override
  String get faqFeedback => '常見問題與意見回饋';

  @override
  String get failed => '失敗';

  @override
  String get featureComingSoon => '功能即將推出';

  @override
  String get firmware => '固件';

  @override
  String get firmwareUpdateIsComingSoon => '固件更新即將推出。';

  @override
  String get firstName => '名字';

  @override
  String get firstNameOptional => '名字（選填）';

  @override
  String get goBack => '返回';

  @override
  String get googleAssistant => 'Google Assistant';

  @override
  String get gotIt => '了解';

  @override
  String get groupName => '群組名稱';

  @override
  String get help => '說明';

  @override
  String get homeManagement => '家庭管理';

  @override
  String get homeName => '家庭名稱';

  @override
  String get homeName2 => '家庭名稱';

  @override
  String get icon => '圖示';

  @override
  String get conditionIf => '若';

  @override
  String get joinAHome => '加入家庭';

  @override
  String get joiningAHomeByInviteIsComingSoon => '透過邀請加入家庭的功能即將推出。';

  @override
  String get lastName => '姓氏';

  @override
  String get lastNameOptional => '姓氏（選填）';

  @override
  String get later => '稍後';

  @override
  String get launchTapToRun => '執行 Tap-to-Run';

  @override
  String get localAssociation => '本地綁定';

  @override
  String get localControlOffline => '本地控制（離線）';

  @override
  String get location => '位置';

  @override
  String get logCopiedToClipboard => '已將記錄複製到剪貼簿';

  @override
  String get logs => '記錄';

  @override
  String get manage => '管理';

  @override
  String get managePermissions => '管理權限';

  @override
  String get markAllAsRead => '全部標為已讀';

  @override
  String get moreSettings => '更多設定';

  @override
  String get motorDirection => '馬達方向';

  @override
  String get moveToTop => '移至最上方';

  @override
  String get moveToRoom => '移至房間';

  @override
  String get moved => '已移動';

  @override
  String get movedToTop => '已移至最上方';

  @override
  String get name => '名稱';

  @override
  String get next => '下一步';

  @override
  String get noDevicesAvailable => '沒有可用的裝置';

  @override
  String get noDevicesFound => '找不到裝置。';

  @override
  String get noDevicesInThisHome => '此家庭尚無裝置。';

  @override
  String get noDevicesYet => '尚無裝置';

  @override
  String get noFunctionsAvailable => '沒有可用的功能';

  @override
  String get noHomeSelectedPleaseTryAgain => '尚未選擇家庭，請重試';

  @override
  String get noMatchingTimeZones => '沒有相符的時區';

  @override
  String get noOtherScenesAvailable => '沒有其他可用的場景';

  @override
  String get noRooms => '沒有房間';

  @override
  String get noSavedNetworksYet => '尚無已儲存的網路。';

  @override
  String get noScenes => '沒有場景';

  @override
  String get noScenesAvailable => '沒有可用的場景';

  @override
  String get note => '備註';

  @override
  String get notification => '通知';

  @override
  String get ok => '確定';

  @override
  String get offlineNotification => '離線通知';

  @override
  String get open => '開啟';

  @override
  String get openSettings => '開啟設定';

  @override
  String get outdoorPm25 => '室外 PM2.5';

  @override
  String get outdoorAirPressure => '室外氣壓';

  @override
  String get outdoorHumidity => '室外濕度';

  @override
  String get outdoorWindSpeed => '室外風速';

  @override
  String get pairingSuccessful => '配對成功';

  @override
  String get password => '密碼';

  @override
  String get sessionExpiredSignInAgain => '工作階段已過期，請重新登入。';

  @override
  String get pleaseAddAtLeast1Action => '請至少新增 1 個動作';

  @override
  String get pleaseAddAtLeast1Condition => '請至少新增 1 個條件';

  @override
  String get pleaseEnterAName => '請輸入名稱';

  @override
  String get pleaseEnterASceneName => '請輸入場景名稱';

  @override
  String get pleaseSelectAFunction => '請選擇功能';

  @override
  String get pleaseSelectATime0 => '請選擇大於 0 的時間';

  @override
  String get rePairNow => '立即重新配對';

  @override
  String get rePairRequired => '需重新配對';

  @override
  String get reasonOptional => '原因（選填）';

  @override
  String get refresh => '重新整理';

  @override
  String get reload => '重新載入';

  @override
  String get remove => '移除';

  @override
  String get removeDevice => '移除裝置';

  @override
  String get removed => '已移除';

  @override
  String get rename => '重新命名';

  @override
  String get renameRoom => '重新命名房間';

  @override
  String get renameDevice => '重新命名裝置';

  @override
  String get repeat => '重複';

  @override
  String get rescan => '重新掃描';

  @override
  String get retry => '重試';

  @override
  String get roomManagement => '房間管理';

  @override
  String get roomName => '房間名稱';

  @override
  String get roomUpdated => '房間已更新';

  @override
  String get running => '執行中';

  @override
  String get save => '儲存';

  @override
  String get sceneName => '場景名稱';

  @override
  String get scenes => '場景';

  @override
  String get schedule => '定時';

  @override
  String get searchAddress => '搜尋地址';

  @override
  String get searchCityOrRegion => '搜尋城市或地區';

  @override
  String get selectScene => '選擇場景';

  @override
  String get selectSmartScenes => '選擇智慧場景';

  @override
  String get sendResetLink => '傳送重設連結';

  @override
  String get sendVerificationCode => '傳送驗證碼';

  @override
  String get showOnHomePage => '顯示在首頁';

  @override
  String get signIn => '登入';

  @override
  String get signalStrength => '訊號強度';

  @override
  String get signalStrength2 => '訊號強度';

  @override
  String get startPairing => '開始配對';

  @override
  String get stop => '停止';

  @override
  String get style => '樣式';

  @override
  String get switchNetwork => '切換';

  @override
  String get switchToThisNetwork => '切換到此網路';

  @override
  String get tapToRunNotification => 'Tap-to-Run 通知';

  @override
  String get conditionThen => '則';

  @override
  String get thinking => '思考中…';

  @override
  String get thisActionCannotBeUndone => '此操作無法復原。';

  @override
  String get thisSavedNetworkWillBeRemovedFromTheDevice => '此已儲存的網路將從裝置中移除。';

  @override
  String get timeZone => '時區';

  @override
  String get timeZoneUpdated => '時區已更新';

  @override
  String get timedOut => '已逾時';

  @override
  String get tryAgain => '請重試';

  @override
  String get useCurrentLocation => '使用目前位置';

  @override
  String get usingSiri => '使用 Siri';

  @override
  String get virtualId => '虛擬 ID';

  @override
  String get whenDeviceStatusChanges => '當裝置狀態變更時';

  @override
  String get whenWeatherChanges => '當天氣變化時';

  @override
  String get wiFi => 'Wi-Fi';

  @override
  String get wifiNameSsid => 'WiFi 名稱（SSID）';

  @override
  String get wifiPassword => 'WiFi 密碼';

  @override
  String get navHome => '首頁';

  @override
  String get navScenes => '場景';

  @override
  String get navChat => '聊天';

  @override
  String get navMe => '我';

  @override
  String get thirdPartyServices => '第三方服務';

  @override
  String get messageCenter => '訊息中心';

  @override
  String get appMall => '應用商城';

  @override
  String get addDevice => '新增裝置';

  @override
  String get tapToRun => '一鍵執行';

  @override
  String get automationEmptyHint => '智慧自動化讓日常操作自動完成，為你省時省力。';

  @override
  String get tapToRunEmptyHint => '建立一鍵執行情境，輕觸一次即可控制多個裝置。';

  @override
  String get scene => '情境';

  @override
  String get executionFailed => '執行失敗';

  @override
  String get device => '裝置';

  @override
  String get delay => '延遲';

  @override
  String get runScene => '執行情境';

  @override
  String get addToSiri => '加入 Siri';

  @override
  String get storeUnderPreparation => '商城正在籌備中，敬請期待。';

  @override
  String get commonFunctions => '常用功能';

  @override
  String get noConnection => '無網路連線';

  @override
  String get checkInternetAndRetry => '請檢查網路連線後重試。';

  @override
  String get noConnectionCheckInternet => '無網路連線。請檢查網路後重試。';

  @override
  String get addFirstCurtainHint => '點選 + 按鈕，為此家庭新增第一個窗簾。';

  @override
  String get hideInvisibleDevices => '隱藏不可見裝置';

  @override
  String get deviceRenamed => '裝置已重新命名。';

  @override
  String get deviceDeletedReturningToPairing => '裝置已刪除，正在恢復配對模式。';

  @override
  String get homeSettings => '家庭設定';

  @override
  String get toBeSet => '待設定';

  @override
  String get homeMember => '家庭成員';

  @override
  String get memberDetails => '成員詳細資料';

  @override
  String get addMember => '新增成員';

  @override
  String get pending => '待確認';

  @override
  String get removesFromHomeHint => '從家庭中移除；裝置將在 1-2 分鐘後恢復配對模式';

  @override
  String get unlinkAndEraseData => '解除連結並清除資料';

  @override
  String get erasesAllDataHint => '清除全部資料，且無法復原';

  @override
  String get somethingWentWrongTryAgain => '發生錯誤，請重試';

  @override
  String get tapToRunAndAutomation => '一鍵執行與自動化';

  @override
  String get thirdPartyControl => '第三方控制';

  @override
  String get deviceOfflineNotification => '裝置離線通知';

  @override
  String get others => '其他';

  @override
  String get shareDevice => '分享裝置';

  @override
  String get addToHomeScreen => '加入主畫面';

  @override
  String get checkDeviceNetwork => '檢測裝置網路';

  @override
  String get checkNow => '立即檢測';

  @override
  String get deviceUpdate => '裝置更新';

  @override
  String get removeDevicesWarning => '裝置將從此家庭中移除並恢復配對模式。';

  @override
  String get shown => '已顯示';

  @override
  String get hidden => '已隱藏';

  @override
  String get devicesBackOnHome => '裝置已恢復顯示在首頁';

  @override
  String get hiddenFromHome => '已從首頁隱藏';

  @override
  String get offline => '離線';

  @override
  String get show => '顯示';

  @override
  String get hide => '隱藏';

  @override
  String get profilePhoto => '大頭貼';

  @override
  String get nickname => '暱稱';

  @override
  String get noRoomsYet => '尚無房間';

  @override
  String get tapPlusToAddRoom => '點選 + 新增房間';

  @override
  String get emailAddressLabel => '電子郵件地址';

  @override
  String get notSet => '未設定';

  @override
  String get deviceInformation => '裝置資訊';

  @override
  String get unknown => '未知';

  @override
  String get notReported => '未回報';

  @override
  String get noScenesUseThisDevice => '尚無情境使用此裝置。';

  @override
  String get tapToRunLabel => '一鍵執行';

  @override
  String get automation => '自動化';

  @override
  String get forward => '正向';

  @override
  String get back => '反向';

  @override
  String get setting => '設定';

  @override
  String get updateAvailable => '有可用更新';

  @override
  String get noUpdatesAvailable => '目前沒有可用更新';

  @override
  String get updateNow => '立即更新';

  @override
  String get unassigned => '未指派';

  @override
  String get enterEmailOrUsername => '請輸入電子郵件或使用者名稱';

  @override
  String get welcome => '歡迎';

  @override
  String get signInSubtitle => '登入你的 osprey.life 帳號。';

  @override
  String get createOne => '立即註冊';

  @override
  String get forgotPassword => '忘記密碼？';

  @override
  String get orContinueWith => '或使用以下方式登入';

  @override
  String get enterValidEmail => '請輸入有效的電子郵件地址';

  @override
  String get resetYourPassword => '重設密碼';

  @override
  String get checkYourInbox => '請查看收件匣';

  @override
  String get enterYourEmailAddress => '請輸入電子郵件地址';

  @override
  String get enterSixDigitCode => '請輸入 6 位數驗證碼';

  @override
  String get enterAPassword => '請輸入密碼';

  @override
  String get createYourAccount => '建立帳號';

  @override
  String get checkYourEmail => '請查看電子郵件';

  @override
  String get resendCode => '重新傳送驗證碼';

  @override
  String get userAgreement => '使用者協議';

  @override
  String get reconnecting => '正在重新連線…';

  @override
  String get checkWifiOrBluetooth => '請檢查 Wi-Fi，或靠近裝置以使用藍牙。';

  @override
  String get smartScenesRequireInternet => '智慧情境需要網路連線';

  @override
  String get enterWifiName => '請輸入 Wi-Fi 名稱';

  @override
  String get wifiNameLengthError => 'Wi-Fi 名稱需為 1–32 個字元';

  @override
  String get passwordMin8 => '密碼至少需要 8 個字元';

  @override
  String get passwordLength863 => '密碼需為 8–63 個字元';

  @override
  String get networkAlreadySaved => '此網路已儲存。若要變更密碼，請先刪除後重新新增。';

  @override
  String get addWifiNetwork => '新增 Wi-Fi 網路';

  @override
  String get atLeast8Characters => '至少 8 個字元';

  @override
  String get only24GhzSupported => '窗簾裝置僅支援 2.4GHz Wi-Fi（WPA2）。';

  @override
  String get labelOptional => '標籤（選填）';

  @override
  String get createGroup => '建立群組';

  @override
  String get groupControlHint => '同一群組內的裝置可以一起控制。';

  @override
  String get devicesToBeAdded => '待新增的裝置';

  @override
  String get noSameTypeDevices => '此家庭中沒有其他同類型裝置。';

  @override
  String get couldNotLoadNetworkDetails => '無法載入網路詳細資料，請下拉重新整理。';

  @override
  String get alreadyOnThisNetwork => '已連線此網路。';

  @override
  String get deviceOfflineTryLater => '裝置離線 — 請稍後重試。';

  @override
  String get wrongPassword => '密碼錯誤';

  @override
  String get networkNotFound => '找不到此網路';

  @override
  String get networkRemoved => '網路已刪除。';

  @override
  String get network => '網路';

  @override
  String get connectedTo => '已連線';

  @override
  String get savedNetworks => '已儲存的網路';

  @override
  String get addANetwork => '新增網路';

  @override
  String get notConnected => '未連線';

  @override
  String get pleaseKeepAppOpen => '請保持應用程式在前景執行。';

  @override
  String get deviceNetworkInformation => '裝置網路資訊';

  @override
  String get once => '單次';

  @override
  String get editSchedule => '編輯定時';

  @override
  String get addSchedule => '新增定時';

  @override
  String get timeVarianceHint => '時間誤差約 ±30 秒';

  @override
  String get noTimerData => '尚無定時資料';

  @override
  String get localControlUnsupportedAction => '本機控制不支援此操作';

  @override
  String get noInternetNoBluetooth => '無網路且藍牙不在範圍內';

  @override
  String get connectionError => '連線失敗';

  @override
  String get exampleTapToRun => '例如：一鍵關閉臥室所有燈光。';

  @override
  String get exampleWeather => '例如：當本地溫度高於 28°C 時。';

  @override
  String get weatherTrigger => '天氣觸發';

  @override
  String get exampleSchedule => '例如：每天早上 7:00。';

  @override
  String get exampleDeviceStatus => '例如：偵測到異常活動時。';

  @override
  String get deviceStatusTrigger => '裝置狀態觸發';

  @override
  String get noNotificationsYet => '尚無通知';

  @override
  String get slashCommands => '斜線指令';

  @override
  String get slashDevicesHint => '瀏覽並控制你的窗簾。';

  @override
  String get slashSceneHint => '執行一鍵執行情境。';

  @override
  String get slashScheduleHint => '開啟自動化定時。';

  @override
  String get slashHelpHint => '顯示此清單。';

  @override
  String get youCanAlsoSpeak => '也可以用語音 — 點選麥克風按鈕。';

  @override
  String get chatInputHint => '輸入文字、語音，或使用斜線指令。';

  @override
  String get online => '線上';

  @override
  String get blePermissionRequired => '尋找裝置需要藍牙權限';

  @override
  String get bleAndLocationPermissionRequired => '尋找裝置需要藍牙和定位權限';

  @override
  String get addDeviceLower => '新增裝置';

  @override
  String get scanningStopped => '已停止掃描。';

  @override
  String get enterWifiPassword => '請輸入 Wi-Fi 密碼';

  @override
  String get detectingCurrentWifi => '正在偵測目前的 Wi-Fi…';

  @override
  String get autoDetectedWifi => '已自動取得手機目前連線的 Wi-Fi';

  @override
  String get couldNotDetectWifi => '無法偵測 Wi-Fi — 請手動輸入網路名稱';

  @override
  String get beingAdded => '正在新增';

  @override
  String get addedSuccessfully => '新增成功';

  @override
  String get pairingFailed => '配對失敗';

  @override
  String get allDay => '全天';

  @override
  String get whenAnyConditionMet => '符合任一條件時';

  @override
  String get whenAllConditionsMet => '符合所有條件時';

  @override
  String get deleteSceneWarning => '情境刪除後，其中的裝置任務將無法正常執行。';

  @override
  String get toggleAutomation => '切換自動化';

  @override
  String get enable => '啟用';

  @override
  String get disable => '停用';

  @override
  String get everyDay => '每天';

  @override
  String get monToFri => '週一至週五';

  @override
  String get satToSun => '週六至週日';

  @override
  String get runOnceIfNoDaySelected => '若未選擇任何星期，此操作僅執行一次。';

  @override
  String get sendNotification => '傳送通知';

  @override
  String get color => '顏色';

  @override
  String get wait => '等待';

  @override
  String get finish => '完成';

  @override
  String get selectFunction => '選擇功能';

  @override
  String get on => '開';

  @override
  String get off => '關';

  @override
  String get siriShortcut => 'Siri 捷徑';

  @override
  String get createTapToRunFirst => '請先建立一鍵執行情境。';

  @override
  String get poweredByFoundationModels => '由 Apple Foundation Models 在裝置端提供。';

  @override
  String get weatherClearNight => '晴朗夜間';

  @override
  String get weatherSunny => '晴';

  @override
  String get weatherPartlyCloudy => '局部多雲';

  @override
  String get weatherCloudy => '多雲';

  @override
  String get qualityExcellent => '優';

  @override
  String get qualityGood => '良';

  @override
  String get qualityModerate => '中等';

  @override
  String get qualityPoor => '差';

  @override
  String get qualityVeryPoor => '極差';

  @override
  String get switchLocation => '切換位置';

  @override
  String get aiSuggestion => 'AI 建議';

  @override
  String get listening => '正在聆聽…';

  @override
  String get parsing => '正在解析…';

  @override
  String get getStarted => '開始使用';

  @override
  String get aiChatEmptyState =>
      '有關窗簾的任何問題，都可以問 osprey.life 助理。\n由 Apple Foundation Models 在裝置端提供。';

  @override
  String get chatHeaderSubtitle => '為你的電動窗簾打造的裝置端 AI。\n輸入文字、語音，或使用斜線指令。';

  @override
  String get daySunShort => '週日';

  @override
  String get dayMonShort => '週一';

  @override
  String get dayTueShort => '週二';

  @override
  String get dayWedShort => '週三';

  @override
  String get dayThuShort => '週四';

  @override
  String get dayFriShort => '週五';

  @override
  String get daySatShort => '週六';

  @override
  String get dayMon => '週一';

  @override
  String get dayTue => '週二';

  @override
  String get dayWed => '週三';

  @override
  String get dayThu => '週四';

  @override
  String get dayFri => '週五';

  @override
  String get daySat => '週六';

  @override
  String get daySun => '週日';

  @override
  String get accountLinkedSuccessfully => '帳號連結成功！';

  @override
  String get linkingFailed => '連結失敗';

  @override
  String get anErrorOccurredTryAgain => '發生錯誤，請重試。';

  @override
  String get signInWithAmazon => '使用 Amazon 帳號登入';

  @override
  String get viewMoreWaysToLink => '查看更多連結方式';

  @override
  String get alreadyLinkedWithAlexa => '已連結 Amazon Alexa';

  @override
  String get somethingWentWrong => '發生錯誤';

  @override
  String get noAuthorizationCode => '未收到授權碼';

  @override
  String get couldNotOpenGoogleHome => '無法開啟 Google Home 應用程式';

  @override
  String get reLogin => '重新登入';

  @override
  String get linkWithGoogleAssistant => '連結 Google Assistant';

  @override
  String get linkedWithGoogleAssistant => '已連結 Google Assistant';

  @override
  String get anErrorOccurred => '發生錯誤';

  @override
  String deleteHomeConfirm(String name) {
    return '確定要刪除「$name」嗎？此操作無法復原。';
  }

  @override
  String get offlineScenesBody => 'Wi-Fi 恢復前，情境和定時將暫停。藍牙本機控制仍可對每個裝置直接執行開/關/停。';

  @override
  String get blePairingLostBody =>
      '藍牙本機控制需要與此裝置重新配對。這通常發生在清除應用程式資料或裝置恢復原廠設定之後。';

  @override
  String get alternateNetworkHint => '當目前網路不可用時，裝置將自動連線到備用網路。';

  @override
  String get switchNetworkWarning => '裝置將中斷目前的 Wi-Fi 並嘗試連線新網路，通常需要 5–30 秒。';

  @override
  String get runOnceIfNoDayPicked => '若未選擇，此操作僅執行一次。';

  @override
  String get alexaUnlinkHint =>
      '請在 Amazon Alexa 應用程式中停用 osprey.life 技能，或點選「我的」>右上角設定按鈕>帳號與安全性，取消授權。';

  @override
  String get alexaLinkExplainer =>
      '將應用程式帳號與 Amazon 帳號綁定後，即可透過 Amazon Echo 喇叭控制支援 Alexa 的裝置（例如「Alexa, turn on light.」）';

  @override
  String get chatScheduleHelp => '為窗簾設定自動定時。開啟「情境」頁即可建立每天、每週或單次的自動化定時。';

  @override
  String get chatScenesHelp => '在「情境」頁建立與管理一鍵執行情境。情境可將多個窗簾動作與延遲串接，一鍵完成。';

  @override
  String get googleUnlinkHint =>
      '請在 Google Home 應用程式中停用 osprey.life 技能，或點選「我的」>右上角設定按鈕>帳號與安全性，取消授權。';

  @override
  String get googleLinkExplainer =>
      '連結應用程式帳號與 Google 帳號後，即可使用 Google Home 智慧喇叭控制支援 Google Assistant 的裝置。例如，你可以說：「OK Google, please turn on the light.」';

  @override
  String get deviceDisconnectedFromHome => '裝置已從家庭中移除，將在 1-2 分鐘後恢復配對模式。';

  @override
  String get searchingNearbyDevices => '正在搜尋附近的 Osprey 裝置，請確認裝置已進入配對模式。';

  @override
  String get looksLike5GhzHint => '此網路似乎是 5GHz — 請將手機切換到 2.4GHz 網路後點選重新整理。';

  @override
  String get pairingWifiHint => '裝置將連線手機目前使用的 Wi-Fi，僅支援 2.4GHz 網路。';

  @override
  String get siriShortcutsHelp =>
      '點選情境錄製語音短語，之後說「Hey Siri」加上該短語即可執行情境 — 即使應用程式已關閉。\n\n點選已加入的情境可修改短語或將其移除。';

  @override
  String get deleteAccountWarning =>
      '刪除後：\n• 你的帳號將在 30 天後被刪除\n• 你的所有裝置和情境將被移除\n• 30 天內重新登入可取消刪除';

  @override
  String aiSuggestionBody(String action, String weekday, String hour) {
    return '你通常在$weekday $hour:00 執行「$action」 — 要設為自動化嗎？';
  }

  @override
  String removeDeviceConfirm(String name) {
    return '「$name」將從你的家庭中移除，並在約 1-2 分鐘後自動恢復配對模式。';
  }

  @override
  String eraseDeviceConfirm(String name) {
    return '「$name」的所有資料將被清除且無法復原。確定要繼續嗎？';
  }

  @override
  String showInvisibleDevices(int count) {
    return '顯示不可見裝置（$count）';
  }

  @override
  String resetLinkSent(String email) {
    return '若 $email 已註冊帳號，重設密碼連結即將寄出。';
  }

  @override
  String signInNotAvailable(String name) {
    return '$name 登入方式尚未開放。';
  }

  @override
  String resendCodeIn(int seconds) {
    return '$seconds 秒後可重新傳送';
  }

  @override
  String deleteConfirmNamed(String name) {
    return '確定要刪除「$name」嗎？';
  }

  @override
  String taskCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 個任務',
    );
    return '$_temp0';
  }

  @override
  String featureComingSoonShort(String feature) {
    return '$feature即將推出';
  }

  @override
  String roomCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 個房間',
    );
    return '$_temp0';
  }

  @override
  String removeDevicesQ(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '要移除 $count 個裝置嗎？',
      one: '要移除此裝置嗎？',
    );
    return '$_temp0';
  }

  @override
  String devicesRemoved(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '已移除 $count 個裝置',
      one: '已移除 1 個裝置',
    );
    return '$_temp0';
  }

  @override
  String deviceCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 個裝置',
    );
    return '$_temp0';
  }

  @override
  String mainModuleVersion(String version) {
    return '主模組：V$version';
  }

  @override
  String outdoorTemperatureValue(int temp) {
    return '室外溫度：$temp°C';
  }

  @override
  String occurrencesIn30Days(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '30 天內 $count 次',
    );
    return '$_temp0';
  }

  @override
  String sceneExecuted(String name) {
    return '「$name」已執行';
  }

  @override
  String couldNotRunScene(String name) {
    return '無法執行「$name」，請重試。';
  }

  @override
  String featureComingSoonNamed(String feature) {
    return '$feature即將推出。';
  }

  @override
  String get couldNotLoadHome => '無法載入你的家庭，請重試。';

  @override
  String deviceCouldNotConnectTo(String ssid, String reason, String stayedOn) {
    return '裝置無法連線到「$ssid」。\n\n原因：$reason\n\n裝置仍連線在「$stayedOn」。';
  }

  @override
  String makeSureNetworkInRange(String ssid) {
    return '\n\n請確認「$ssid」已開啟且在訊號範圍內。';
  }

  @override
  String get noResponseFromDevice => '裝置沒有回應。請稍後重新整理查看目前狀態。';

  @override
  String devicesBeingAdded(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '正在新增 $count 個裝置',
    );
    return '$_temp0';
  }

  @override
  String devicesAddedSuccessfully(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '成功新增 $count 個裝置',
    );
    return '$_temp0';
  }

  @override
  String get alexaExamplesIntro => '你可以透過 Amazon Alexa 喇叭\n控制支援 Alexa 的裝置，例如';

  @override
  String get googleExamplesIntro =>
      '現在你可以使用 Google Home 喇叭\n控制 Google Assistant 裝置，例如';
}
