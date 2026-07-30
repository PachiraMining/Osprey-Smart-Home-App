// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_l10n.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppL10nJa extends AppL10n {
  AppL10nJa([String locale = 'ja']) : super(locale);

  @override
  String get settingsTitle => '設定';

  @override
  String get personalInformation => '個人情報';

  @override
  String get accountAndSecurity => 'アカウントとセキュリティ';

  @override
  String get touchToneOnPanel => 'パネルの操作音';

  @override
  String get aiAssistant => 'AIアシスタント';

  @override
  String get temperatureUnit => '温度単位';

  @override
  String get about => 'このアプリについて';

  @override
  String get networkDiagnosis => 'ネットワーク診断';

  @override
  String get clearCache => 'キャッシュを削除';

  @override
  String get language => '言語';

  @override
  String get logOut => 'ログアウト';

  @override
  String get languageSystemDefault => 'システムの言語と同じ';

  @override
  String get languageEnglish => '英語';

  @override
  String get languageVietnamese => 'ベトナム語';

  @override
  String get clearCacheMessage =>
      'キャッシュされたシーン、ホームのデータ、画像は次回使用時に再ダウンロードされます。アカウントとデバイスには影響しません。';

  @override
  String get clear => '削除';

  @override
  String get cancel => 'キャンセル';

  @override
  String freedSpace(String size) {
    return '$size を解放しました';
  }

  @override
  String aboutVersion(String version, String build) {
    return 'バージョン $version（$build）';
  }

  @override
  String get privacyPolicy => 'プライバシーポリシー';

  @override
  String get termsOfService => '利用規約';

  @override
  String get bundleId => 'Bundle ID';

  @override
  String get server => 'サーバー';

  @override
  String get couldNotOpenLink => 'リンクを開けませんでした。';

  @override
  String get diagLocalNetwork => 'ローカルネットワーク';

  @override
  String get diagLocalNetworkNoWifi => 'Wi-Fi に未接続（モバイルデータまたは権限なし）';

  @override
  String get diagLocalNetworkUnreadable => 'Wi-Fi 名を取得できません';

  @override
  String get diagDnsLookup => 'DNS 参照';

  @override
  String diagDnsFailed(String host) {
    return '$host を解決できません';
  }

  @override
  String get diagServerReachable => 'サーバーに接続可能';

  @override
  String diagServerLatency(String ms, String status) {
    return '$ms ms · HTTP $status';
  }

  @override
  String get diagServerNoResponse => 'サーバーから応答がありません';

  @override
  String get diagSignedIn => 'ログイン済み';

  @override
  String get diagSessionValid => 'セッション有効';

  @override
  String diagSessionInvalid(String status) {
    return 'HTTP $status — 再度ログインしてください';
  }

  @override
  String get diagSessionUnverified => 'セッションを確認できません';

  @override
  String get diagControlChannel => '制御チャネル';

  @override
  String get diagCloudConnected => 'クラウド（MQTT）に接続';

  @override
  String get diagBleFallback => 'クラウド停止中 — Bluetooth に切り替え';

  @override
  String get diagUnreachable => 'クラウドも Bluetooth も利用できません';

  @override
  String get diagStatusUnknown => '状態不明';

  @override
  String get runAgain => '再実行';

  @override
  String get accountCreatedPleaseSignIn => 'アカウントを作成しました。ログインしてください。';

  @override
  String get add => '追加';

  @override
  String get addCondition => '条件を追加';

  @override
  String get addRoom => '部屋を追加';

  @override
  String get addTask => 'タスクを追加';

  @override
  String get addAtLeastTwoDevicesToAGroup => 'グループには2台以上のデバイスを追加してください。';

  @override
  String get alexa => 'Alexa';

  @override
  String get all => 'すべて';

  @override
  String get allDevices => 'すべてのデバイス';

  @override
  String get alternateNetwork => '代替ネットワーク';

  @override
  String get apply => '適用';

  @override
  String get areYouSureYouWantToLogOut => 'ログアウトしてもよろしいですか？';

  @override
  String get askAboutYourCurtainsOrTryHelp => 'カーテンについて質問、または /help を入力…';

  @override
  String get askAboutYourCurtains => 'カーテンについて質問…';

  @override
  String get atLeast6Characters => '6文字以上';

  @override
  String get authDiagnostics => '認証診断';

  @override
  String get automationNotification => 'オートメーション通知';

  @override
  String get changeRoom => '部屋を変更';

  @override
  String get close => '閉じる';

  @override
  String get cloud => 'クラウド';

  @override
  String get confirm => '確認';

  @override
  String get connected => '接続済み';

  @override
  String get control => '操作';

  @override
  String get controlSingleDevice => '単一デバイスを操作';

  @override
  String get copiedToClipboard => 'クリップボードにコピーしました';

  @override
  String get copy => 'コピー';

  @override
  String get couldNotChangeTheMotorDirectionPleaseTryAgai =>
      'モーターの回転方向を変更できませんでした。もう一度お試しください。';

  @override
  String get couldNotConnect => '接続できませんでした';

  @override
  String get couldNotCreateTheGroupPleaseTryAgain =>
      'グループを作成できませんでした。もう一度お試しください。';

  @override
  String get couldNotOpenTheBrowser => 'ブラウザーを開けませんでした。';

  @override
  String get couldNotSendTheCommandPleaseTryAgain =>
      'コマンドを送信できませんでした。もう一度お試しください。';

  @override
  String get create => '作成';

  @override
  String get createScene => 'シーンを作成';

  @override
  String get createAHome => 'ホームを作成';

  @override
  String get createARoomFirst => '先に部屋を作成してください。';

  @override
  String get createAccount => 'アカウントを作成';

  @override
  String get createScene2 => 'シーンを作成';

  @override
  String get curtainPosition => 'カーテンの位置';

  @override
  String get curtainPositionSetting => 'カーテン位置の設定';

  @override
  String get customDeviceIconsAreNotSupportedYet => 'カスタムデバイスアイコンはまだ対応していません。';

  @override
  String get delayTheAction => '動作を遅延';

  @override
  String get delete => '削除';

  @override
  String get deleteAccount => 'アカウントを削除';

  @override
  String get deleteHome => 'ホームを削除';

  @override
  String get deleteRoom => '部屋を削除';

  @override
  String get deleteSchedule => 'スケジュールを削除';

  @override
  String get deleteScene => 'シーンを削除しますか？';

  @override
  String get deleteThisSchedule => 'このスケジュールを削除しますか？';

  @override
  String get deviceNetwork => 'デバイスのネットワーク';

  @override
  String get deviceHasNoProfileInformation => 'デバイスのプロファイル情報がありません';

  @override
  String get deviceIsOffline => 'デバイスはオフラインです';

  @override
  String get deviceIsReady => 'デバイスの準備ができました。';

  @override
  String get deviceName => 'デバイス名';

  @override
  String get deviceRemovedFromHome => 'デバイスをホームから削除しました。';

  @override
  String get deviceUnreachable => 'デバイスに接続できません';

  @override
  String get devices => 'デバイス';

  @override
  String get disconnect => '接続解除';

  @override
  String get disconnectDevice => 'デバイスの接続を解除しますか？';

  @override
  String get done => '完了';

  @override
  String get emailAddress => 'メールアドレス';

  @override
  String get emailOrUsername => 'メールアドレスまたはユーザー名';

  @override
  String get enterAGroupName => 'グループ名を入力';

  @override
  String get enterANote => 'メモを入力';

  @override
  String get enterDeviceName => 'デバイス名を入力';

  @override
  String get enterHomeName => 'ホーム名を入力';

  @override
  String get enterName => '名前を入力';

  @override
  String get enterSceneName => 'シーン名を入力';

  @override
  String get enterValue => '値を入力...';

  @override
  String get enterYourPassword => 'パスワードを入力';

  @override
  String get eraseDeviceData => 'デバイスのデータを消去しますか？';

  @override
  String get error => 'エラー';

  @override
  String get executedBy => '実行者';

  @override
  String get executionTime => '実行時刻';

  @override
  String get faqFeedback => 'よくある質問とフィードバック';

  @override
  String get failed => '失敗';

  @override
  String get featureComingSoon => 'この機能は近日公開';

  @override
  String get firmware => 'ファームウェア';

  @override
  String get firmwareUpdateIsComingSoon => 'ファームウェア更新は近日公開予定です。';

  @override
  String get firstName => '名';

  @override
  String get firstNameOptional => '名（任意）';

  @override
  String get goBack => '戻る';

  @override
  String get googleAssistant => 'Google Assistant';

  @override
  String get gotIt => '了解';

  @override
  String get groupName => 'グループ名';

  @override
  String get help => 'ヘルプ';

  @override
  String get homeManagement => 'ホーム管理';

  @override
  String get homeName => 'ホーム名';

  @override
  String get homeName2 => 'ホーム名';

  @override
  String get icon => 'アイコン';

  @override
  String get conditionIf => 'もし';

  @override
  String get joinAHome => 'ホームに参加';

  @override
  String get joiningAHomeByInviteIsComingSoon => '招待によるホーム参加は近日公開予定です。';

  @override
  String get lastName => '姓';

  @override
  String get lastNameOptional => '姓（任意）';

  @override
  String get later => 'あとで';

  @override
  String get launchTapToRun => 'Tap-to-Run を実行';

  @override
  String get localAssociation => 'ローカル連携';

  @override
  String get localControlOffline => 'ローカル制御（オフライン）';

  @override
  String get location => '位置情報';

  @override
  String get logCopiedToClipboard => 'ログをクリップボードにコピーしました';

  @override
  String get logs => 'ログ';

  @override
  String get manage => '管理';

  @override
  String get managePermissions => '権限を管理';

  @override
  String get markAllAsRead => 'すべて既読にする';

  @override
  String get moreSettings => 'その他の設定';

  @override
  String get motorDirection => 'モーターの回転方向';

  @override
  String get moveToTop => '先頭に移動';

  @override
  String get moveToRoom => '部屋に移動';

  @override
  String get moved => '移動しました';

  @override
  String get movedToTop => '先頭に移動しました';

  @override
  String get name => '名前';

  @override
  String get next => '次へ';

  @override
  String get noDevicesAvailable => '利用できるデバイスがありません';

  @override
  String get noDevicesFound => 'デバイスが見つかりません。';

  @override
  String get noDevicesInThisHome => 'このホームにデバイスがありません。';

  @override
  String get noDevicesYet => 'デバイスがまだありません';

  @override
  String get noFunctionsAvailable => '利用できる機能がありません';

  @override
  String get noHomeSelectedPleaseTryAgain => 'ホームが選択されていません。もう一度お試しください';

  @override
  String get noMatchingTimeZones => '一致するタイムゾーンがありません';

  @override
  String get noOtherScenesAvailable => '他に利用できるシーンがありません';

  @override
  String get noRooms => '部屋がありません';

  @override
  String get noSavedNetworksYet => '保存されたネットワークがまだありません。';

  @override
  String get noScenes => 'シーンがありません';

  @override
  String get noScenesAvailable => '利用できるシーンがありません';

  @override
  String get note => 'メモ';

  @override
  String get notification => '通知';

  @override
  String get ok => 'OK';

  @override
  String get offlineNotification => 'オフライン通知';

  @override
  String get open => '開く';

  @override
  String get openSettings => '設定を開く';

  @override
  String get outdoorPm25 => '屋外 PM2.5';

  @override
  String get outdoorAirPressure => '屋外の気圧';

  @override
  String get outdoorHumidity => '屋外の湿度';

  @override
  String get outdoorWindSpeed => '屋外の風速';

  @override
  String get pairingSuccessful => 'ペアリングに成功しました';

  @override
  String get password => 'パスワード';

  @override
  String get sessionExpiredSignInAgain => 'セッションの有効期限が切れました。再度ログインしてください。';

  @override
  String get pleaseAddAtLeast1Action => 'アクションを1つ以上追加してください';

  @override
  String get pleaseAddAtLeast1Condition => '条件を1つ以上追加してください';

  @override
  String get pleaseEnterAName => '名前を入力してください';

  @override
  String get pleaseEnterASceneName => 'シーン名を入力してください';

  @override
  String get pleaseSelectAFunction => '機能を選択してください';

  @override
  String get pleaseSelectATime0 => '0より大きい時間を選択してください';

  @override
  String get rePairNow => '今すぐ再ペアリング';

  @override
  String get rePairRequired => '再ペアリングが必要';

  @override
  String get reasonOptional => '理由（任意）';

  @override
  String get refresh => '更新';

  @override
  String get reload => '再読み込み';

  @override
  String get remove => '削除';

  @override
  String get removeDevice => 'デバイスを削除';

  @override
  String get removed => '削除しました';

  @override
  String get rename => '名前を変更';

  @override
  String get renameRoom => '部屋の名前を変更';

  @override
  String get renameDevice => 'デバイス名を変更';

  @override
  String get repeat => '繰り返し';

  @override
  String get rescan => '再スキャン';

  @override
  String get retry => '再試行';

  @override
  String get roomManagement => '部屋の管理';

  @override
  String get roomName => '部屋名';

  @override
  String get roomUpdated => '部屋を更新しました';

  @override
  String get running => '実行中';

  @override
  String get save => '保存';

  @override
  String get sceneName => 'シーン名';

  @override
  String get scenes => 'シーン';

  @override
  String get schedule => 'スケジュール';

  @override
  String get searchAddress => '住所を検索';

  @override
  String get searchCityOrRegion => '都市または地域を検索';

  @override
  String get selectScene => 'シーンを選択';

  @override
  String get selectSmartScenes => 'スマートシーンを選択';

  @override
  String get sendResetLink => 'リセットリンクを送信';

  @override
  String get sendVerificationCode => '認証コードを送信';

  @override
  String get showOnHomePage => 'ホーム画面に表示';

  @override
  String get signIn => 'ログイン';

  @override
  String get signalStrength => '電波強度';

  @override
  String get signalStrength2 => '電波強度';

  @override
  String get startPairing => 'ペアリングを開始';

  @override
  String get stop => '停止';

  @override
  String get style => 'スタイル';

  @override
  String get switchNetwork => '切り替え';

  @override
  String get switchToThisNetwork => 'このネットワークに切り替える';

  @override
  String get tapToRunNotification => 'Tap-to-Run 通知';

  @override
  String get conditionThen => '実行';

  @override
  String get thinking => '考えています…';

  @override
  String get thisActionCannotBeUndone => 'この操作は取り消せません。';

  @override
  String get thisSavedNetworkWillBeRemovedFromTheDevice =>
      '保存されたこのネットワークはデバイスから削除されます。';

  @override
  String get timeZone => 'タイムゾーン';

  @override
  String get timeZoneUpdated => 'タイムゾーンを更新しました';

  @override
  String get timedOut => 'タイムアウトしました';

  @override
  String get tryAgain => 'もう一度お試しください';

  @override
  String get useCurrentLocation => '現在地を使用';

  @override
  String get usingSiri => 'Siri を使う';

  @override
  String get virtualId => '仮想 ID';

  @override
  String get whenDeviceStatusChanges => 'デバイスの状態が変化したとき';

  @override
  String get whenWeatherChanges => '天気が変化したとき';

  @override
  String get wiFi => 'Wi-Fi';

  @override
  String get wifiNameSsid => 'WiFi 名（SSID）';

  @override
  String get wifiPassword => 'WiFi パスワード';

  @override
  String get navHome => 'ホーム';

  @override
  String get navScenes => 'シーン';

  @override
  String get navChat => 'チャット';

  @override
  String get navMe => 'マイページ';

  @override
  String get thirdPartyServices => '外部サービス連携';

  @override
  String get messageCenter => 'メッセージセンター';

  @override
  String get appMall => 'アプリモール';

  @override
  String get addDevice => 'デバイスを追加';

  @override
  String get tapToRun => 'ワンタップ実行';

  @override
  String get automationEmptyHint => 'オートメーションが日常の操作を自動化し、手間と時間を省きます。';

  @override
  String get tapToRunEmptyHint => 'ワンタップ実行シーンを作成すると、一度のタップで複数のデバイスを操作できます。';

  @override
  String get scene => 'シーン';

  @override
  String get executionFailed => '実行に失敗しました';

  @override
  String get device => 'デバイス';

  @override
  String get delay => '待機';

  @override
  String get runScene => 'シーンを実行';

  @override
  String get addToSiri => 'Siri に追加';

  @override
  String get storeUnderPreparation => 'ストアは準備中です。公開までお待ちください。';

  @override
  String get commonFunctions => 'よく使う機能';

  @override
  String get noConnection => '接続がありません';

  @override
  String get checkInternetAndRetry => 'インターネット接続を確認して、もう一度お試しください。';

  @override
  String get noConnectionCheckInternet => '接続がありません。インターネットを確認して、もう一度お試しください。';

  @override
  String get addFirstCurtainHint => '＋ ボタンをタップして、このホームに最初のカーテンを追加します。';

  @override
  String get hideInvisibleDevices => '非表示のデバイスを隠す';

  @override
  String get deviceRenamed => 'デバイス名を変更しました。';

  @override
  String get deviceDeletedReturningToPairing => 'デバイスを削除しました。ペアリングモードに戻ります。';

  @override
  String get homeSettings => 'ホーム設定';

  @override
  String get toBeSet => '未設定';

  @override
  String get homeMember => 'ホームメンバー';

  @override
  String get memberDetails => 'メンバーの詳細';

  @override
  String get addMember => 'メンバーを追加';

  @override
  String get pending => '保留中';

  @override
  String get removesFromHomeHint => 'ホームから削除します。デバイスは 1〜2 分後にペアリングモードに戻ります';

  @override
  String get unlinkAndEraseData => '連携を解除してデータを消去';

  @override
  String get erasesAllDataHint => 'すべてのデータを消去します。元に戻せません';

  @override
  String get somethingWentWrongTryAgain => '問題が発生しました。もう一度お試しください';

  @override
  String get tapToRunAndAutomation => 'ワンタップ実行とオートメーション';

  @override
  String get thirdPartyControl => '外部サービスからの操作';

  @override
  String get deviceOfflineNotification => 'デバイスオフライン通知';

  @override
  String get others => 'その他';

  @override
  String get shareDevice => 'デバイスを共有';

  @override
  String get addToHomeScreen => 'ホーム画面に追加';

  @override
  String get checkDeviceNetwork => 'デバイスのネットワークを確認';

  @override
  String get checkNow => '今すぐ確認';

  @override
  String get deviceUpdate => 'デバイスの更新';

  @override
  String get removeDevicesWarning => 'このホームから削除され、ペアリングモードに戻ります。';

  @override
  String get shown => '表示中';

  @override
  String get hidden => '非表示';

  @override
  String get devicesBackOnHome => 'デバイスをホームに再表示しました';

  @override
  String get hiddenFromHome => 'ホームから非表示にしました';

  @override
  String get offline => 'オフライン';

  @override
  String get show => '表示';

  @override
  String get hide => '非表示';

  @override
  String get profilePhoto => 'プロフィール写真';

  @override
  String get nickname => 'ニックネーム';

  @override
  String get noRoomsYet => '部屋がありません';

  @override
  String get tapPlusToAddRoom => '＋ をタップして部屋を追加';

  @override
  String get emailAddressLabel => 'メールアドレス';

  @override
  String get notSet => '未設定';

  @override
  String get deviceInformation => 'デバイス情報';

  @override
  String get unknown => '不明';

  @override
  String get notReported => '未取得';

  @override
  String get noScenesUseThisDevice => 'このデバイスを使うシーンはまだありません。';

  @override
  String get tapToRunLabel => 'ワンタップ実行';

  @override
  String get automation => 'オートメーション';

  @override
  String get forward => '正転';

  @override
  String get back => '逆転';

  @override
  String get setting => '設定';

  @override
  String get updateAvailable => '更新があります';

  @override
  String get noUpdatesAvailable => '更新はありません';

  @override
  String get updateNow => '今すぐ更新';

  @override
  String get unassigned => '未割り当て';

  @override
  String get enterEmailOrUsername => 'メールアドレスまたはユーザー名を入力';

  @override
  String get welcome => 'ようこそ';

  @override
  String get signInSubtitle => 'osprey.life アカウントにサインインしてください。';

  @override
  String get createOne => '新規登録';

  @override
  String get forgotPassword => 'パスワードをお忘れですか？';

  @override
  String get orContinueWith => 'または次でサインイン';

  @override
  String get enterValidEmail => '有効なメールアドレスを入力してください';

  @override
  String get resetYourPassword => 'パスワードを再設定';

  @override
  String get checkYourInbox => '受信トレイをご確認ください';

  @override
  String get enterYourEmailAddress => 'メールアドレスを入力';

  @override
  String get enterSixDigitCode => '6 桁のコードを入力';

  @override
  String get enterAPassword => 'パスワードを入力';

  @override
  String get createYourAccount => 'アカウントを作成';

  @override
  String get checkYourEmail => 'メールをご確認ください';

  @override
  String get resendCode => 'コードを再送信';

  @override
  String get userAgreement => '利用規約';

  @override
  String get reconnecting => '再接続中…';

  @override
  String get checkWifiOrBluetooth =>
      'Wi-Fi を確認するか、Bluetooth の場合はデバイスに近づいてください。';

  @override
  String get smartScenesRequireInternet => 'スマートシーンにはインターネットが必要です';

  @override
  String get enterWifiName => 'Wi-Fi 名を入力';

  @override
  String get wifiNameLengthError => 'Wi-Fi 名は 1〜32 文字で入力してください';

  @override
  String get passwordMin8 => 'パスワードは 8 文字以上で入力してください';

  @override
  String get passwordLength863 => 'パスワードは 8〜63 文字で入力してください';

  @override
  String get networkAlreadySaved =>
      'このネットワークは既に保存されています。パスワードを変更するには、削除してから再度追加してください。';

  @override
  String get addWifiNetwork => 'Wi-Fi ネットワークを追加';

  @override
  String get atLeast8Characters => '8 文字以上';

  @override
  String get only24GhzSupported => 'カーテンデバイスは 2.4GHz Wi-Fi（WPA2）のみ対応しています。';

  @override
  String get labelOptional => 'ラベル（任意）';

  @override
  String get createGroup => 'グループを作成';

  @override
  String get groupControlHint => '同じグループのデバイスはまとめて操作できます。';

  @override
  String get devicesToBeAdded => '追加するデバイス';

  @override
  String get noSameTypeDevices => 'このホームに同じ種類のデバイスは他にありません。';

  @override
  String get couldNotLoadNetworkDetails => 'ネットワーク情報を読み込めませんでした。引っ張って更新してください。';

  @override
  String get alreadyOnThisNetwork => 'すでにこのネットワークに接続しています。';

  @override
  String get deviceOfflineTryLater => 'デバイスがオフラインです。しばらくしてからお試しください。';

  @override
  String get wrongPassword => 'パスワードが違います';

  @override
  String get networkNotFound => 'ネットワークが見つかりません';

  @override
  String get networkRemoved => 'ネットワークを削除しました。';

  @override
  String get network => 'ネットワーク';

  @override
  String get connectedTo => '接続先';

  @override
  String get savedNetworks => '保存済みのネットワーク';

  @override
  String get addANetwork => 'ネットワークを追加';

  @override
  String get notConnected => '未接続';

  @override
  String get pleaseKeepAppOpen => 'アプリを開いたままにしてください。';

  @override
  String get deviceNetworkInformation => 'デバイスのネットワーク情報';

  @override
  String get once => '1 回のみ';

  @override
  String get editSchedule => 'スケジュールを編集';

  @override
  String get addSchedule => 'スケジュールを追加';

  @override
  String get timeVarianceHint => '時刻の誤差は約 ±30 秒です';

  @override
  String get noTimerData => 'タイマーのデータがありません';

  @override
  String get localControlUnsupportedAction => 'ローカル制御はこの操作に対応していません';

  @override
  String get noInternetNoBluetooth => 'インターネットがなく、Bluetooth も範囲外です';

  @override
  String get connectionError => '接続エラー';

  @override
  String get exampleTapToRun => '例：ワンタップで寝室の照明をすべて消す。';

  @override
  String get exampleWeather => '例：現在地の気温が 28°C を超えたとき。';

  @override
  String get weatherTrigger => '天気トリガー';

  @override
  String get exampleSchedule => '例：毎朝 7:00。';

  @override
  String get exampleDeviceStatus => '例：異常な動きを検知したとき。';

  @override
  String get deviceStatusTrigger => 'デバイス状態トリガー';

  @override
  String get noNotificationsYet => '通知はまだありません';

  @override
  String get slashCommands => 'スラッシュコマンド';

  @override
  String get slashDevicesHint => 'カーテンを一覧して操作します。';

  @override
  String get slashSceneHint => 'ワンタップ実行シーンを実行します。';

  @override
  String get slashScheduleHint => 'オートメーションのスケジュールを開きます。';

  @override
  String get slashHelpHint => 'この一覧を表示します。';

  @override
  String get youCanAlsoSpeak => '音声も使えます — マイクボタンをタップしてください。';

  @override
  String get chatInputHint => '入力、音声、またはスラッシュコマンドで操作できます。';

  @override
  String get online => 'オンライン';

  @override
  String get blePermissionRequired => 'デバイスを探すには Bluetooth の許可が必要です';

  @override
  String get bleAndLocationPermissionRequired =>
      'デバイスを探すには Bluetooth と位置情報の許可が必要です';

  @override
  String get addDeviceLower => 'デバイスを追加';

  @override
  String get scanningStopped => 'スキャンを停止しました。';

  @override
  String get enterWifiPassword => 'Wi-Fi のパスワードを入力';

  @override
  String get detectingCurrentWifi => '現在の Wi-Fi を確認中…';

  @override
  String get autoDetectedWifi => 'スマートフォンが接続中の Wi-Fi から自動取得しました';

  @override
  String get couldNotDetectWifi => 'Wi-Fi を検出できませんでした。ネットワーク名を手動で入力してください';

  @override
  String get beingAdded => '追加中';

  @override
  String get addedSuccessfully => '追加しました';

  @override
  String get pairingFailed => 'ペアリングに失敗しました';

  @override
  String get allDay => '終日';

  @override
  String get whenAnyConditionMet => 'いずれかの条件を満たしたとき';

  @override
  String get whenAllConditionsMet => 'すべての条件を満たしたとき';

  @override
  String get deleteSceneWarning => 'シーンを削除すると、その中のデバイス操作は正常に実行できなくなります。';

  @override
  String get toggleAutomation => 'オートメーションの切り替え';

  @override
  String get enable => '有効';

  @override
  String get disable => '無効';

  @override
  String get everyDay => '毎日';

  @override
  String get monToFri => '月〜金';

  @override
  String get satToSun => '土〜日';

  @override
  String get runOnceIfNoDaySelected => '曜日を選択しない場合、この操作は 1 回のみ実行されます。';

  @override
  String get sendNotification => '通知を送信';

  @override
  String get color => 'カラー';

  @override
  String get wait => '待機';

  @override
  String get finish => '完了';

  @override
  String get selectFunction => '機能を選択';

  @override
  String get on => 'オン';

  @override
  String get off => 'オフ';

  @override
  String get siriShortcut => 'Siri ショートカット';

  @override
  String get createTapToRunFirst => '先にワンタップ実行シーンを作成してください。';

  @override
  String get poweredByFoundationModels =>
      'Apple Foundation Models によりデバイス上で動作します。';

  @override
  String get weatherClearNight => '晴れ（夜）';

  @override
  String get weatherSunny => '晴れ';

  @override
  String get weatherPartlyCloudy => '晴れ時々くもり';

  @override
  String get weatherCloudy => 'くもり';

  @override
  String get qualityExcellent => '非常に良い';

  @override
  String get qualityGood => '良い';

  @override
  String get qualityModerate => 'ふつう';

  @override
  String get qualityPoor => '悪い';

  @override
  String get qualityVeryPoor => '非常に悪い';

  @override
  String get switchLocation => '場所を変更';

  @override
  String get aiSuggestion => 'AI の提案';

  @override
  String get listening => '聞き取り中…';

  @override
  String get parsing => '解析中…';

  @override
  String get getStarted => 'はじめる';

  @override
  String get aiChatEmptyState =>
      'カーテンについて何でも osprey.life アシスタントに聞いてください。\nApple Foundation Models によりデバイス上で動作します。';

  @override
  String get chatHeaderSubtitle =>
      '電動カーテンのためのオンデバイス AI。\n入力、音声、またはスラッシュコマンドで操作できます。';

  @override
  String get daySunShort => '日';

  @override
  String get dayMonShort => '月';

  @override
  String get dayTueShort => '火';

  @override
  String get dayWedShort => '水';

  @override
  String get dayThuShort => '木';

  @override
  String get dayFriShort => '金';

  @override
  String get daySatShort => '土';

  @override
  String get dayMon => '月';

  @override
  String get dayTue => '火';

  @override
  String get dayWed => '水';

  @override
  String get dayThu => '木';

  @override
  String get dayFri => '金';

  @override
  String get daySat => '土';

  @override
  String get daySun => '日';

  @override
  String get accountLinkedSuccessfully => 'アカウントを連携しました！';

  @override
  String get linkingFailed => '連携に失敗しました';

  @override
  String get anErrorOccurredTryAgain => 'エラーが発生しました。もう一度お試しください。';

  @override
  String get signInWithAmazon => 'Amazon アカウントでサインイン';

  @override
  String get viewMoreWaysToLink => '他の連携方法を見る';

  @override
  String get alreadyLinkedWithAlexa => 'Amazon Alexa と連携済みです';

  @override
  String get somethingWentWrong => '問題が発生しました';

  @override
  String get noAuthorizationCode => '認証コードを受け取れませんでした';

  @override
  String get couldNotOpenGoogleHome => 'Google Home アプリを開けませんでした';

  @override
  String get reLogin => '再ログイン';

  @override
  String get linkWithGoogleAssistant => 'Google アシスタントと連携';

  @override
  String get linkedWithGoogleAssistant => 'Google アシスタントと連携済み';

  @override
  String get anErrorOccurred => 'エラーが発生しました';

  @override
  String deleteHomeConfirm(String name) {
    return '「$name」を削除してもよろしいですか？この操作は元に戻せません。';
  }

  @override
  String get offlineScenesBody =>
      'Wi-Fi が復旧するまで、シーンとスケジュールは一時停止します。Bluetooth のローカル制御では、各デバイスの開く／閉じる／停止は引き続き利用できます。';

  @override
  String get blePairingLostBody =>
      'Bluetooth のローカル制御には、このデバイスとの再ペアリングが必要です。アプリのデータを消去した後、またはデバイスを初期化した後に起こります。';

  @override
  String get alternateNetworkHint =>
      '現在のネットワークが利用できない場合、デバイスは自動的に別のネットワークに接続します。';

  @override
  String get switchNetworkWarning =>
      'デバイスは現在の Wi-Fi から切断し、新しいネットワークへの接続を試みます。通常 5〜30 秒かかります。';

  @override
  String get runOnceIfNoDayPicked => '選択しない場合、この操作は 1 回のみ実行されます。';

  @override
  String get alexaUnlinkHint =>
      'Amazon Alexa アプリで osprey.life スキルを無効にするか、「マイページ」＞右上の設定ボタン＞アカウントとセキュリティ から連携を解除してください。';

  @override
  String get alexaLinkExplainer =>
      'アプリのアカウントと Amazon アカウントを連携すると、Amazon Echo スピーカーから Alexa 対応デバイスを操作できます（例：「Alexa, turn on light.」）';

  @override
  String get chatScheduleHelp =>
      'カーテンの自動スケジュールを設定します。「シーン」タブを開くと、毎日・毎週・1 回のみのオートメーションを作成できます。';

  @override
  String get chatScenesHelp =>
      '「シーン」タブでワンタップ実行シーンを作成・管理できます。シーンでは複数のカーテン操作と待機時間をつなげて、ワンタップで実行できます。';

  @override
  String get googleUnlinkHint =>
      'Google Home アプリで osprey.life スキルを無効にするか、「マイページ」＞右上の設定ボタン＞アカウントとセキュリティ から連携を解除してください。';

  @override
  String get googleLinkExplainer =>
      'アプリのアカウントと Google アカウントを連携すると、Google Home スマートスピーカーから Google アシスタント対応デバイスを操作できます。たとえば「OK Google, please turn on the light.」と話しかけてください。';

  @override
  String get deviceDisconnectedFromHome =>
      'デバイスをホームから解除しました。1〜2 分後にペアリングモードに戻ります。';

  @override
  String get searchingNearbyDevices =>
      '近くの Osprey デバイスを検索中です。デバイスがペアリングモードになっていることを確認してください。';

  @override
  String get looksLike5GhzHint =>
      'このネットワークは 5GHz のようです。スマートフォンを 2.4GHz のネットワークに切り替えて、更新をタップしてください。';

  @override
  String get pairingWifiHint =>
      'デバイスはスマートフォンが使用中の Wi-Fi に接続します。2.4GHz のネットワークのみ対応しています。';

  @override
  String get siriShortcutsHelp =>
      'シーンをタップして音声フレーズを登録すると、「Hey Siri」に続けてそのフレーズを話すだけでシーンを実行できます（アプリを閉じていても動作します）。\n\n追加済みのシーンをタップすると、フレーズの変更や削除ができます。';

  @override
  String get deleteAccountWarning =>
      '削除後：\n• アカウントは 30 日後に削除されます\n• すべてのデバイスとシーンが削除されます\n• 30 日以内に再度ログインすると取り消せます';

  @override
  String aiSuggestionBody(String action, String weekday, String hour) {
    return 'いつも$weekdayの $hour:00 に「$action」を実行しています。オートメーションにしますか？';
  }

  @override
  String removeDeviceConfirm(String name) {
    return '「$name」はホームから削除され、約 1〜2 分後に自動的にペアリングモードに戻ります。';
  }

  @override
  String eraseDeviceConfirm(String name) {
    return '「$name」のすべてのデータが消去され、復元できません。よろしいですか？';
  }

  @override
  String showInvisibleDevices(int count) {
    return '非表示のデバイスを表示（$count）';
  }

  @override
  String resetLinkSent(String email) {
    return '$email のアカウントが存在する場合、パスワード再設定用のリンクをお送りします。';
  }

  @override
  String signInNotAvailable(String name) {
    return '$name でのサインインはまだご利用いただけません。';
  }

  @override
  String resendCodeIn(int seconds) {
    return '$seconds 秒後に再送信できます';
  }

  @override
  String deleteConfirmNamed(String name) {
    return '「$name」を削除してもよろしいですか？';
  }

  @override
  String taskCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 件のタスク',
    );
    return '$_temp0';
  }

  @override
  String featureComingSoonShort(String feature) {
    return '$featureは近日公開予定です';
  }

  @override
  String roomCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 部屋',
    );
    return '$_temp0';
  }

  @override
  String removeDevicesQ(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 台のデバイスを削除しますか？',
      one: 'このデバイスを削除しますか？',
    );
    return '$_temp0';
  }

  @override
  String devicesRemoved(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 台のデバイスを削除しました',
      one: '1 台のデバイスを削除しました',
    );
    return '$_temp0';
  }

  @override
  String deviceCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 台のデバイス',
    );
    return '$_temp0';
  }

  @override
  String mainModuleVersion(String version) {
    return 'メインモジュール：V$version';
  }

  @override
  String outdoorTemperatureValue(int temp) {
    return '外気温：$temp°C';
  }

  @override
  String occurrencesIn30Days(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '30 日間で $count 回',
    );
    return '$_temp0';
  }

  @override
  String sceneExecuted(String name) {
    return '「$name」を実行しました';
  }

  @override
  String couldNotRunScene(String name) {
    return '「$name」を実行できませんでした。もう一度お試しください。';
  }

  @override
  String featureComingSoonNamed(String feature) {
    return '$featureは近日公開予定です。';
  }

  @override
  String get couldNotLoadHome => 'ホームを読み込めませんでした。もう一度お試しください。';

  @override
  String deviceCouldNotConnectTo(String ssid, String reason, String stayedOn) {
    return 'デバイスは「$ssid」に接続できませんでした。\n\n理由：$reason\n\nデバイスは現在も「$stayedOn」に接続しています。';
  }

  @override
  String makeSureNetworkInRange(String ssid) {
    return '\n\n「$ssid」がオンで、電波の届く範囲にあることを確認してください。';
  }

  @override
  String get noResponseFromDevice =>
      'デバイスから応答がありませんでした。しばらくしてから更新して現在の状態を確認してください。';

  @override
  String devicesBeingAdded(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 台のデバイスを追加中',
    );
    return '$_temp0';
  }

  @override
  String devicesAddedSuccessfully(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 台のデバイスを追加しました',
    );
    return '$_temp0';
  }

  @override
  String get alexaExamplesIntro =>
      'Amazon Alexa スピーカーで\nAlexa 対応デバイスを操作できます。例：';

  @override
  String get googleExamplesIntro =>
      'Google Home スピーカーで\nGoogle アシスタント対応デバイスを操作できます。例：';
}
