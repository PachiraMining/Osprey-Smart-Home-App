// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_l10n.dart';

// ignore_for_file: type=lint

/// The translations for Korean (`ko`).
class AppL10nKo extends AppL10n {
  AppL10nKo([String locale = 'ko']) : super(locale);

  @override
  String get settingsTitle => '설정';

  @override
  String get personalInformation => '개인 정보';

  @override
  String get accountAndSecurity => '계정 및 보안';

  @override
  String get touchToneOnPanel => '패널 조작음';

  @override
  String get aiAssistant => 'AI 어시스턴트';

  @override
  String get temperatureUnit => '온도 단위';

  @override
  String get about => '앱 정보';

  @override
  String get networkDiagnosis => '네트워크 진단';

  @override
  String get clearCache => '캐시 삭제';

  @override
  String get language => '언어';

  @override
  String get logOut => '로그아웃';

  @override
  String get languageSystemDefault => '시스템 언어와 동일';

  @override
  String get languageEnglish => '영어';

  @override
  String get languageVietnamese => '베트남어';

  @override
  String get clearCacheMessage =>
      '캐시된 씬, 집 데이터, 이미지는 다음에 사용할 때 다시 다운로드됩니다. 계정과 기기에는 영향이 없습니다.';

  @override
  String get clear => '삭제';

  @override
  String get cancel => '취소';

  @override
  String freedSpace(String size) {
    return '$size 확보됨';
  }

  @override
  String aboutVersion(String version, String build) {
    return '버전 $version ($build)';
  }

  @override
  String get privacyPolicy => '개인정보 처리방침';

  @override
  String get termsOfService => '서비스 이용약관';

  @override
  String get bundleId => 'Bundle ID';

  @override
  String get server => '서버';

  @override
  String get couldNotOpenLink => '링크를 열 수 없습니다.';

  @override
  String get diagLocalNetwork => '로컬 네트워크';

  @override
  String get diagLocalNetworkNoWifi => 'Wi-Fi에 연결되지 않음 (모바일 데이터 또는 권한 거부)';

  @override
  String get diagLocalNetworkUnreadable => 'Wi-Fi 이름을 읽을 수 없음';

  @override
  String get diagDnsLookup => 'DNS 조회';

  @override
  String diagDnsFailed(String host) {
    return '$host를 확인할 수 없음';
  }

  @override
  String get diagServerReachable => '서버 연결 가능';

  @override
  String diagServerLatency(String ms, String status) {
    return '$ms ms · HTTP $status';
  }

  @override
  String get diagServerNoResponse => '서버 응답 없음';

  @override
  String get diagSignedIn => '로그인됨';

  @override
  String get diagSessionValid => '세션 유효';

  @override
  String diagSessionInvalid(String status) {
    return 'HTTP $status — 다시 로그인해 주세요';
  }

  @override
  String get diagSessionUnverified => '세션을 확인할 수 없음';

  @override
  String get diagControlChannel => '제어 채널';

  @override
  String get diagCloudConnected => '클라우드(MQTT) 연결됨';

  @override
  String get diagBleFallback => '클라우드 중단 — Bluetooth로 대체';

  @override
  String get diagUnreachable => '클라우드와 Bluetooth 모두 사용할 수 없음';

  @override
  String get diagStatusUnknown => '상태 알 수 없음';

  @override
  String get runAgain => '다시 실행';

  @override
  String get accountCreatedPleaseSignIn => '계정이 생성되었습니다. 로그인해 주세요.';

  @override
  String get add => '추가';

  @override
  String get addCondition => '조건 추가';

  @override
  String get addRoom => '방 추가';

  @override
  String get addTask => '작업 추가';

  @override
  String get addAtLeastTwoDevicesToAGroup => '그룹에 기기를 두 대 이상 추가하세요.';

  @override
  String get alexa => 'Alexa';

  @override
  String get all => '전체';

  @override
  String get allDevices => '모든 기기';

  @override
  String get alternateNetwork => '대체 네트워크';

  @override
  String get apply => '적용';

  @override
  String get areYouSureYouWantToLogOut => '로그아웃하시겠습니까?';

  @override
  String get askAboutYourCurtainsOrTryHelp => '커튼에 대해 물어보거나 /help를 입력하세요…';

  @override
  String get askAboutYourCurtains => '커튼에 대해 물어보세요…';

  @override
  String get atLeast6Characters => '6자 이상';

  @override
  String get authDiagnostics => '인증 진단';

  @override
  String get automationNotification => '자동화 알림';

  @override
  String get changeRoom => '방 변경';

  @override
  String get close => '닫기';

  @override
  String get cloud => '클라우드';

  @override
  String get confirm => '확인';

  @override
  String get connected => '연결됨';

  @override
  String get control => '제어';

  @override
  String get controlSingleDevice => '단일 기기 제어';

  @override
  String get copiedToClipboard => '클립보드에 복사됨';

  @override
  String get copy => '복사';

  @override
  String get couldNotChangeTheMotorDirectionPleaseTryAgai =>
      '모터 방향을 변경할 수 없습니다. 다시 시도해 주세요.';

  @override
  String get couldNotConnect => '연결할 수 없습니다';

  @override
  String get couldNotCreateTheGroupPleaseTryAgain =>
      '그룹을 만들 수 없습니다. 다시 시도해 주세요.';

  @override
  String get couldNotOpenTheBrowser => '브라우저를 열 수 없습니다.';

  @override
  String get couldNotSendTheCommandPleaseTryAgain =>
      '명령을 보낼 수 없습니다. 다시 시도해 주세요.';

  @override
  String get create => '만들기';

  @override
  String get createScene => '씬 만들기';

  @override
  String get createAHome => '집 만들기';

  @override
  String get createARoomFirst => '먼저 방을 만드세요.';

  @override
  String get createAccount => '계정 만들기';

  @override
  String get createScene2 => '씬 만들기';

  @override
  String get curtainPosition => '커튼 위치';

  @override
  String get curtainPositionSetting => '커튼 위치 설정';

  @override
  String get customDeviceIconsAreNotSupportedYet =>
      '사용자 지정 기기 아이콘은 아직 지원되지 않습니다.';

  @override
  String get delayTheAction => '동작 지연';

  @override
  String get delete => '삭제';

  @override
  String get deleteAccount => '계정 삭제';

  @override
  String get deleteHome => '집 삭제';

  @override
  String get deleteRoom => '방 삭제';

  @override
  String get deleteSchedule => '예약 삭제';

  @override
  String get deleteScene => '씬을 삭제할까요?';

  @override
  String get deleteThisSchedule => '이 예약을 삭제할까요?';

  @override
  String get deviceNetwork => '기기 네트워크';

  @override
  String get deviceHasNoProfileInformation => '기기 프로필 정보가 없습니다';

  @override
  String get deviceIsOffline => '기기가 오프라인입니다';

  @override
  String get deviceIsReady => '기기가 준비되었습니다.';

  @override
  String get deviceName => '기기 이름';

  @override
  String get deviceRemovedFromHome => '기기를 집에서 삭제했습니다.';

  @override
  String get deviceUnreachable => '기기에 연결할 수 없음';

  @override
  String get devices => '기기';

  @override
  String get disconnect => '연결 해제';

  @override
  String get disconnectDevice => '기기 연결을 해제할까요?';

  @override
  String get done => '완료';

  @override
  String get emailAddress => '이메일 주소';

  @override
  String get emailOrUsername => '이메일 또는 사용자 이름';

  @override
  String get enterAGroupName => '그룹 이름 입력';

  @override
  String get enterANote => '메모 입력';

  @override
  String get enterDeviceName => '기기 이름 입력';

  @override
  String get enterHomeName => '집 이름 입력';

  @override
  String get enterName => '이름 입력';

  @override
  String get enterSceneName => '씬 이름 입력';

  @override
  String get enterValue => '값 입력...';

  @override
  String get enterYourPassword => '비밀번호 입력';

  @override
  String get eraseDeviceData => '기기 데이터를 지울까요?';

  @override
  String get error => '오류';

  @override
  String get executedBy => '실행 주체';

  @override
  String get executionTime => '실행 시간';

  @override
  String get faqFeedback => 'FAQ 및 피드백';

  @override
  String get failed => '실패';

  @override
  String get featureComingSoon => '곧 제공될 기능입니다';

  @override
  String get firmware => '펌웨어';

  @override
  String get firmwareUpdateIsComingSoon => '펌웨어 업데이트가 곧 제공됩니다.';

  @override
  String get firstName => '이름';

  @override
  String get firstNameOptional => '이름 (선택)';

  @override
  String get goBack => '돌아가기';

  @override
  String get googleAssistant => 'Google Assistant';

  @override
  String get gotIt => '확인';

  @override
  String get groupName => '그룹 이름';

  @override
  String get help => '도움말';

  @override
  String get homeManagement => '집 관리';

  @override
  String get homeName => '집 이름';

  @override
  String get homeName2 => '집 이름';

  @override
  String get icon => '아이콘';

  @override
  String get conditionIf => '조건';

  @override
  String get joinAHome => '집에 참여';

  @override
  String get joiningAHomeByInviteIsComingSoon => '초대를 통한 집 참여는 곧 제공됩니다.';

  @override
  String get lastName => '성';

  @override
  String get lastNameOptional => '성 (선택)';

  @override
  String get later => '나중에';

  @override
  String get launchTapToRun => 'Tap-to-Run 실행';

  @override
  String get localAssociation => '로컬 연동';

  @override
  String get localControlOffline => '로컬 제어 (오프라인)';

  @override
  String get location => '위치';

  @override
  String get logCopiedToClipboard => '로그를 클립보드에 복사했습니다';

  @override
  String get logs => '로그';

  @override
  String get manage => '관리';

  @override
  String get managePermissions => '권한 관리';

  @override
  String get markAllAsRead => '모두 읽음으로 표시';

  @override
  String get moreSettings => '추가 설정';

  @override
  String get motorDirection => '모터 방향';

  @override
  String get moveToTop => '맨 위로 이동';

  @override
  String get moveToRoom => '방으로 이동';

  @override
  String get moved => '이동됨';

  @override
  String get movedToTop => '맨 위로 이동했습니다';

  @override
  String get name => '이름';

  @override
  String get next => '다음';

  @override
  String get noDevicesAvailable => '사용 가능한 기기가 없습니다';

  @override
  String get noDevicesFound => '기기를 찾을 수 없습니다.';

  @override
  String get noDevicesInThisHome => '이 집에 기기가 없습니다.';

  @override
  String get noDevicesYet => '아직 기기가 없습니다';

  @override
  String get noFunctionsAvailable => '사용 가능한 기능이 없습니다';

  @override
  String get noHomeSelectedPleaseTryAgain => '선택된 집이 없습니다. 다시 시도해 주세요';

  @override
  String get noMatchingTimeZones => '일치하는 시간대가 없습니다';

  @override
  String get noOtherScenesAvailable => '사용 가능한 다른 씬이 없습니다';

  @override
  String get noRooms => '방이 없습니다';

  @override
  String get noSavedNetworksYet => '아직 저장된 네트워크가 없습니다.';

  @override
  String get noScenes => '씬이 없습니다';

  @override
  String get noScenesAvailable => '사용 가능한 씬이 없습니다';

  @override
  String get note => '메모';

  @override
  String get notification => '알림';

  @override
  String get ok => '확인';

  @override
  String get offlineNotification => '오프라인 알림';

  @override
  String get open => '열기';

  @override
  String get openSettings => '설정 열기';

  @override
  String get outdoorPm25 => '실외 PM2.5';

  @override
  String get outdoorAirPressure => '실외 기압';

  @override
  String get outdoorHumidity => '실외 습도';

  @override
  String get outdoorWindSpeed => '실외 풍속';

  @override
  String get pairingSuccessful => '페어링 성공';

  @override
  String get password => '비밀번호';

  @override
  String get sessionExpiredSignInAgain => '세션이 만료되었습니다. 다시 로그인해 주세요.';

  @override
  String get pleaseAddAtLeast1Action => '동작을 1개 이상 추가하세요';

  @override
  String get pleaseAddAtLeast1Condition => '조건을 1개 이상 추가하세요';

  @override
  String get pleaseEnterAName => '이름을 입력하세요';

  @override
  String get pleaseEnterASceneName => '씬 이름을 입력하세요';

  @override
  String get pleaseSelectAFunction => '기능을 선택하세요';

  @override
  String get pleaseSelectATime0 => '0보다 큰 시간을 선택하세요';

  @override
  String get rePairNow => '지금 다시 페어링';

  @override
  String get rePairRequired => '다시 페어링 필요';

  @override
  String get reasonOptional => '이유 (선택)';

  @override
  String get refresh => '새로 고침';

  @override
  String get reload => '다시 불러오기';

  @override
  String get remove => '삭제';

  @override
  String get removeDevice => '기기 삭제';

  @override
  String get removed => '삭제됨';

  @override
  String get rename => '이름 변경';

  @override
  String get renameRoom => '방 이름 변경';

  @override
  String get renameDevice => '기기 이름 변경';

  @override
  String get repeat => '반복';

  @override
  String get rescan => '다시 검색';

  @override
  String get retry => '다시 시도';

  @override
  String get roomManagement => '방 관리';

  @override
  String get roomName => '방 이름';

  @override
  String get roomUpdated => '방이 업데이트되었습니다';

  @override
  String get running => '실행 중';

  @override
  String get save => '저장';

  @override
  String get sceneName => '씬 이름';

  @override
  String get scenes => '씬';

  @override
  String get schedule => '예약';

  @override
  String get searchAddress => '주소 검색';

  @override
  String get searchCityOrRegion => '도시 또는 지역 검색';

  @override
  String get selectScene => '씬 선택';

  @override
  String get selectSmartScenes => '스마트 씬 선택';

  @override
  String get sendResetLink => '재설정 링크 보내기';

  @override
  String get sendVerificationCode => '인증 코드 보내기';

  @override
  String get showOnHomePage => '홈 화면에 표시';

  @override
  String get signIn => '로그인';

  @override
  String get signalStrength => '신호 강도';

  @override
  String get signalStrength2 => '신호 강도';

  @override
  String get startPairing => '페어링 시작';

  @override
  String get stop => '정지';

  @override
  String get style => '스타일';

  @override
  String get switchNetwork => '전환';

  @override
  String get switchToThisNetwork => '이 네트워크로 전환';

  @override
  String get tapToRunNotification => 'Tap-to-Run 알림';

  @override
  String get conditionThen => '실행';

  @override
  String get thinking => '생각 중…';

  @override
  String get thisActionCannotBeUndone => '이 작업은 취소할 수 없습니다.';

  @override
  String get thisSavedNetworkWillBeRemovedFromTheDevice =>
      '저장된 이 네트워크가 기기에서 삭제됩니다.';

  @override
  String get timeZone => '시간대';

  @override
  String get timeZoneUpdated => '시간대가 업데이트되었습니다';

  @override
  String get timedOut => '시간이 초과되었습니다';

  @override
  String get tryAgain => '다시 시도';

  @override
  String get useCurrentLocation => '현재 위치 사용';

  @override
  String get usingSiri => 'Siri 사용';

  @override
  String get virtualId => '가상 ID';

  @override
  String get whenDeviceStatusChanges => '기기 상태가 변경될 때';

  @override
  String get whenWeatherChanges => '날씨가 변경될 때';

  @override
  String get wiFi => 'Wi-Fi';

  @override
  String get wifiNameSsid => 'WiFi 이름 (SSID)';

  @override
  String get wifiPassword => 'WiFi 비밀번호';

  @override
  String get navHome => '홈';

  @override
  String get navScenes => '씬';

  @override
  String get navChat => '채팅';

  @override
  String get navMe => '내 정보';

  @override
  String get thirdPartyServices => '외부 서비스 연동';

  @override
  String get messageCenter => '메시지 센터';

  @override
  String get appMall => '앱 스토어';

  @override
  String get addDevice => '기기 추가';

  @override
  String get tapToRun => '원탭 실행';

  @override
  String get automationEmptyHint => '자동화가 반복적인 작업을 대신 처리해 시간과 노력을 줄여 줍니다.';

  @override
  String get tapToRunEmptyHint => '원탭 실행 장면을 만들면 한 번의 탭으로 여러 기기를 제어할 수 있습니다.';

  @override
  String get scene => '장면';

  @override
  String get executionFailed => '실행 실패';

  @override
  String get device => '기기';

  @override
  String get delay => '지연';

  @override
  String get runScene => '장면 실행';

  @override
  String get addToSiri => 'Siri에 추가';

  @override
  String get storeUnderPreparation => '스토어를 준비 중입니다. 조금만 기다려 주세요.';

  @override
  String get commonFunctions => '자주 쓰는 기능';

  @override
  String get noConnection => '연결 없음';

  @override
  String get checkInternetAndRetry => '인터넷 연결을 확인한 후 다시 시도해 주세요.';

  @override
  String get noConnectionCheckInternet => '연결이 없습니다. 인터넷을 확인한 후 다시 시도해 주세요.';

  @override
  String get addFirstCurtainHint => '+ 버튼을 눌러 이 집에 첫 커튼을 추가하세요.';

  @override
  String get hideInvisibleDevices => '숨긴 기기 감추기';

  @override
  String get deviceRenamed => '기기 이름을 변경했습니다.';

  @override
  String get deviceDeletedReturningToPairing => '기기를 삭제했습니다. 페어링 모드로 돌아갑니다.';

  @override
  String get homeSettings => '집 설정';

  @override
  String get toBeSet => '설정 필요';

  @override
  String get homeMember => '집 구성원';

  @override
  String get memberDetails => '구성원 정보';

  @override
  String get addMember => '구성원 추가';

  @override
  String get pending => '대기 중';

  @override
  String get removesFromHomeHint => '집에서 제거되며, 기기는 1~2분 후 페어링 모드로 돌아갑니다';

  @override
  String get unlinkAndEraseData => '연결 해제 및 데이터 삭제';

  @override
  String get erasesAllDataHint => '모든 데이터를 삭제하며 되돌릴 수 없습니다';

  @override
  String get somethingWentWrongTryAgain => '문제가 발생했습니다. 다시 시도해 주세요';

  @override
  String get tapToRunAndAutomation => '원탭 실행 및 자동화';

  @override
  String get thirdPartyControl => '외부 서비스 제어';

  @override
  String get deviceOfflineNotification => '기기 오프라인 알림';

  @override
  String get others => '기타';

  @override
  String get shareDevice => '기기 공유';

  @override
  String get addToHomeScreen => '홈 화면에 추가';

  @override
  String get checkDeviceNetwork => '기기 네트워크 확인';

  @override
  String get checkNow => '지금 확인';

  @override
  String get deviceUpdate => '기기 업데이트';

  @override
  String get removeDevicesWarning => '이 집에서 제거되고 페어링 모드로 돌아갑니다.';

  @override
  String get shown => '표시됨';

  @override
  String get hidden => '숨김';

  @override
  String get devicesBackOnHome => '기기를 홈에 다시 표시했습니다';

  @override
  String get hiddenFromHome => '홈에서 숨겼습니다';

  @override
  String get offline => '오프라인';

  @override
  String get show => '표시';

  @override
  String get hide => '숨기기';

  @override
  String get profilePhoto => '프로필 사진';

  @override
  String get nickname => '닉네임';

  @override
  String get noRoomsYet => '방이 없습니다';

  @override
  String get tapPlusToAddRoom => '+ 를 눌러 방을 추가하세요';

  @override
  String get emailAddressLabel => '이메일 주소';

  @override
  String get notSet => '설정되지 않음';

  @override
  String get deviceInformation => '기기 정보';

  @override
  String get unknown => '알 수 없음';

  @override
  String get notReported => '보고되지 않음';

  @override
  String get noScenesUseThisDevice => '이 기기를 사용하는 장면이 아직 없습니다.';

  @override
  String get tapToRunLabel => '원탭 실행';

  @override
  String get automation => '자동화';

  @override
  String get forward => '정방향';

  @override
  String get back => '역방향';

  @override
  String get setting => '설정';

  @override
  String get updateAvailable => '업데이트 있음';

  @override
  String get noUpdatesAvailable => '업데이트가 없습니다';

  @override
  String get updateNow => '지금 업데이트';

  @override
  String get unassigned => '미지정';

  @override
  String get enterEmailOrUsername => '이메일 또는 사용자 이름을 입력하세요';

  @override
  String get welcome => '환영합니다';

  @override
  String get signInSubtitle => 'osprey.life 계정으로 로그인하세요.';

  @override
  String get createOne => '가입하기';

  @override
  String get forgotPassword => '비밀번호를 잊으셨나요?';

  @override
  String get orContinueWith => '또는 다음으로 계속';

  @override
  String get enterValidEmail => '올바른 이메일 주소를 입력하세요';

  @override
  String get resetYourPassword => '비밀번호 재설정';

  @override
  String get checkYourInbox => '받은 편지함을 확인하세요';

  @override
  String get enterYourEmailAddress => '이메일 주소를 입력하세요';

  @override
  String get enterSixDigitCode => '6자리 코드를 입력하세요';

  @override
  String get enterAPassword => '비밀번호를 입력하세요';

  @override
  String get createYourAccount => '계정 만들기';

  @override
  String get checkYourEmail => '이메일을 확인하세요';

  @override
  String get resendCode => '코드 재전송';

  @override
  String get userAgreement => '이용약관';

  @override
  String get reconnecting => '다시 연결 중…';

  @override
  String get checkWifiOrBluetooth => 'Wi-Fi를 확인하거나, 블루투스를 사용하려면 기기에 가까이 가세요.';

  @override
  String get smartScenesRequireInternet => '스마트 장면에는 인터넷이 필요합니다';

  @override
  String get enterWifiName => 'Wi-Fi 이름을 입력하세요';

  @override
  String get wifiNameLengthError => 'Wi-Fi 이름은 1~32자여야 합니다';

  @override
  String get passwordMin8 => '비밀번호는 8자 이상이어야 합니다';

  @override
  String get passwordLength863 => '비밀번호는 8~63자여야 합니다';

  @override
  String get networkAlreadySaved =>
      '이미 저장된 네트워크입니다. 비밀번호를 바꾸려면 삭제한 후 다시 추가하세요.';

  @override
  String get addWifiNetwork => 'Wi-Fi 네트워크 추가';

  @override
  String get atLeast8Characters => '8자 이상';

  @override
  String get only24GhzSupported => '커튼 기기는 2.4GHz Wi-Fi(WPA2)만 지원합니다.';

  @override
  String get labelOptional => '라벨(선택)';

  @override
  String get createGroup => '그룹 만들기';

  @override
  String get groupControlHint => '같은 그룹의 기기는 함께 제어할 수 있습니다.';

  @override
  String get devicesToBeAdded => '추가할 기기';

  @override
  String get noSameTypeDevices => '이 집에 같은 종류의 다른 기기가 없습니다.';

  @override
  String get couldNotLoadNetworkDetails =>
      '네트워크 정보를 불러올 수 없습니다. 아래로 당겨 새로고침하세요.';

  @override
  String get alreadyOnThisNetwork => '이미 이 네트워크에 연결되어 있습니다.';

  @override
  String get deviceOfflineTryLater => '기기가 오프라인입니다. 잠시 후 다시 시도해 주세요.';

  @override
  String get wrongPassword => '비밀번호가 올바르지 않습니다';

  @override
  String get networkNotFound => '네트워크를 찾을 수 없습니다';

  @override
  String get networkRemoved => '네트워크를 삭제했습니다.';

  @override
  String get network => '네트워크';

  @override
  String get connectedTo => '연결됨';

  @override
  String get savedNetworks => '저장된 네트워크';

  @override
  String get addANetwork => '네트워크 추가';

  @override
  String get notConnected => '연결되지 않음';

  @override
  String get pleaseKeepAppOpen => '앱을 열어 둔 상태로 유지하세요.';

  @override
  String get deviceNetworkInformation => '기기 네트워크 정보';

  @override
  String get once => '한 번만';

  @override
  String get editSchedule => '예약 편집';

  @override
  String get addSchedule => '예약 추가';

  @override
  String get timeVarianceHint => '시간 오차는 약 ±30초입니다';

  @override
  String get noTimerData => '타이머 데이터가 없습니다';

  @override
  String get localControlUnsupportedAction => '로컬 제어에서는 지원하지 않는 동작입니다';

  @override
  String get noInternetNoBluetooth => '인터넷이 없고 블루투스 범위에도 없습니다';

  @override
  String get connectionError => '연결 오류';

  @override
  String get exampleTapToRun => '예: 한 번의 탭으로 침실의 모든 조명 끄기.';

  @override
  String get exampleWeather => '예: 현재 위치 기온이 28°C를 넘을 때.';

  @override
  String get weatherTrigger => '날씨 트리거';

  @override
  String get exampleSchedule => '예: 매일 오전 7:00.';

  @override
  String get exampleDeviceStatus => '예: 비정상적인 움직임이 감지될 때.';

  @override
  String get deviceStatusTrigger => '기기 상태 트리거';

  @override
  String get noNotificationsYet => '알림이 없습니다';

  @override
  String get slashCommands => '슬래시 명령';

  @override
  String get slashDevicesHint => '커튼을 보고 제어합니다.';

  @override
  String get slashSceneHint => '원탭 실행 장면을 실행합니다.';

  @override
  String get slashScheduleHint => '자동화 예약을 엽니다.';

  @override
  String get slashHelpHint => '이 목록을 표시합니다.';

  @override
  String get youCanAlsoSpeak => '음성으로도 가능합니다 — 마이크 버튼을 누르세요.';

  @override
  String get chatInputHint => '입력하거나 말하거나 슬래시 명령을 사용하세요.';

  @override
  String get online => '온라인';

  @override
  String get blePermissionRequired => '기기를 찾으려면 블루투스 권한이 필요합니다';

  @override
  String get bleAndLocationPermissionRequired => '기기를 찾으려면 블루투스와 위치 권한이 필요합니다';

  @override
  String get addDeviceLower => '기기 추가';

  @override
  String get scanningStopped => '검색을 중지했습니다.';

  @override
  String get enterWifiPassword => 'Wi-Fi 비밀번호를 입력하세요';

  @override
  String get detectingCurrentWifi => '현재 Wi-Fi 확인 중…';

  @override
  String get autoDetectedWifi => '휴대폰이 연결된 Wi-Fi에서 자동으로 가져왔습니다';

  @override
  String get couldNotDetectWifi => 'Wi-Fi를 확인할 수 없습니다 — 네트워크 이름을 직접 입력하세요';

  @override
  String get beingAdded => '추가 중';

  @override
  String get addedSuccessfully => '추가 완료';

  @override
  String get pairingFailed => '페어링 실패';

  @override
  String get allDay => '하루 종일';

  @override
  String get whenAnyConditionMet => '조건 중 하나라도 충족될 때';

  @override
  String get whenAllConditionsMet => '모든 조건이 충족될 때';

  @override
  String get deleteSceneWarning => '장면을 삭제하면 포함된 기기 작업이 정상적으로 실행되지 않습니다.';

  @override
  String get toggleAutomation => '자동화 켜기/끄기';

  @override
  String get enable => '사용';

  @override
  String get disable => '사용 안 함';

  @override
  String get everyDay => '매일';

  @override
  String get monToFri => '월~금';

  @override
  String get satToSun => '토~일';

  @override
  String get runOnceIfNoDaySelected => '요일을 선택하지 않으면 이 동작은 한 번만 실행됩니다.';

  @override
  String get sendNotification => '알림 보내기';

  @override
  String get color => '색상';

  @override
  String get wait => '대기';

  @override
  String get finish => '완료';

  @override
  String get selectFunction => '기능 선택';

  @override
  String get on => '켜기';

  @override
  String get off => '끄기';

  @override
  String get siriShortcut => 'Siri 단축어';

  @override
  String get createTapToRunFirst => '먼저 원탭 실행 장면을 만들어 주세요.';

  @override
  String get poweredByFoundationModels =>
      'Apple Foundation Models로 기기에서 직접 실행됩니다.';

  @override
  String get weatherClearNight => '맑은 밤';

  @override
  String get weatherSunny => '맑음';

  @override
  String get weatherPartlyCloudy => '구름 조금';

  @override
  String get weatherCloudy => '흐림';

  @override
  String get qualityExcellent => '매우 좋음';

  @override
  String get qualityGood => '좋음';

  @override
  String get qualityModerate => '보통';

  @override
  String get qualityPoor => '나쁨';

  @override
  String get qualityVeryPoor => '매우 나쁨';

  @override
  String get switchLocation => '위치 변경';

  @override
  String get aiSuggestion => 'AI 제안';

  @override
  String get listening => '듣고 있습니다…';

  @override
  String get parsing => '분석 중…';

  @override
  String get getStarted => '시작하기';

  @override
  String get aiChatEmptyState =>
      '커튼에 대해 무엇이든 osprey.life 어시스턴트에게 물어보세요.\nApple Foundation Models로 기기에서 직접 실행됩니다.';

  @override
  String get chatHeaderSubtitle =>
      '전동 커튼을 위한 온디바이스 AI.\n입력하거나 말하거나 슬래시 명령을 사용하세요.';

  @override
  String get daySunShort => '일';

  @override
  String get dayMonShort => '월';

  @override
  String get dayTueShort => '화';

  @override
  String get dayWedShort => '수';

  @override
  String get dayThuShort => '목';

  @override
  String get dayFriShort => '금';

  @override
  String get daySatShort => '토';

  @override
  String get dayMon => '월';

  @override
  String get dayTue => '화';

  @override
  String get dayWed => '수';

  @override
  String get dayThu => '목';

  @override
  String get dayFri => '금';

  @override
  String get daySat => '토';

  @override
  String get daySun => '일';

  @override
  String get accountLinkedSuccessfully => '계정을 연결했습니다!';

  @override
  String get linkingFailed => '연결 실패';

  @override
  String get anErrorOccurredTryAgain => '오류가 발생했습니다. 다시 시도해 주세요.';

  @override
  String get signInWithAmazon => 'Amazon 계정으로 로그인';

  @override
  String get viewMoreWaysToLink => '다른 연결 방법 보기';

  @override
  String get alreadyLinkedWithAlexa => 'Amazon Alexa와 연결됨';

  @override
  String get somethingWentWrong => '문제가 발생했습니다';

  @override
  String get noAuthorizationCode => '인증 코드를 받지 못했습니다';

  @override
  String get couldNotOpenGoogleHome => 'Google Home 앱을 열 수 없습니다';

  @override
  String get reLogin => '다시 로그인';

  @override
  String get linkWithGoogleAssistant => 'Google 어시스턴트 연결';

  @override
  String get linkedWithGoogleAssistant => 'Google 어시스턴트와 연결됨';

  @override
  String get anErrorOccurred => '오류가 발생했습니다';

  @override
  String deleteHomeConfirm(String name) {
    return '\"$name\"을(를) 삭제하시겠습니까? 이 작업은 되돌릴 수 없습니다.';
  }

  @override
  String get offlineScenesBody =>
      'Wi-Fi가 복구될 때까지 장면과 예약은 일시 중지됩니다. 블루투스 로컬 제어로는 각 기기의 열기/닫기/정지를 계속 사용할 수 있습니다.';

  @override
  String get blePairingLostBody =>
      '블루투스 로컬 제어를 위해 이 기기와 다시 페어링해야 합니다. 보통 앱 데이터를 삭제했거나 기기를 초기화한 후에 발생합니다.';

  @override
  String get alternateNetworkHint =>
      '현재 네트워크를 사용할 수 없으면 기기가 자동으로 대체 네트워크에 연결됩니다.';

  @override
  String get switchNetworkWarning =>
      '기기가 현재 Wi-Fi 연결을 끊고 새 네트워크에 연결을 시도합니다. 보통 5~30초가 걸립니다.';

  @override
  String get runOnceIfNoDayPicked => '선택하지 않으면 이 동작은 한 번만 실행됩니다.';

  @override
  String get alexaUnlinkHint =>
      'Amazon Alexa 앱에서 osprey.life 스킬을 비활성화하거나, [나] > 오른쪽 상단 설정 버튼 > 계정 및 보안에서 권한을 해제하세요.';

  @override
  String get alexaLinkExplainer =>
      '앱 계정을 Amazon 계정과 연결하면 Amazon Echo 스피커로 Alexa 지원 기기를 제어할 수 있습니다(예: \"Alexa, turn on light.\").';

  @override
  String get chatScheduleHelp =>
      '커튼의 자동 예약을 설정하세요. [장면] 탭에서 매일, 매주 또는 한 번만 실행되는 자동화를 만들 수 있습니다.';

  @override
  String get chatScenesHelp =>
      '[장면] 탭에서 원탭 실행 장면을 만들고 관리하세요. 여러 커튼 동작과 지연을 이어 붙여 한 번의 탭으로 실행할 수 있습니다.';

  @override
  String get googleUnlinkHint =>
      'Google Home 앱에서 osprey.life 스킬을 비활성화하거나, [나] > 오른쪽 상단 설정 버튼 > 계정 및 보안에서 권한을 해제하세요.';

  @override
  String get googleLinkExplainer =>
      '앱 계정과 Google 계정을 연결하면 Google Home 스마트 스피커로 Google 어시스턴트 지원 기기를 제어할 수 있습니다. 예를 들어 \"OK Google, please turn on the light.\"라고 말해 보세요.';

  @override
  String get deviceDisconnectedFromHome =>
      '기기를 집에서 해제했습니다. 1~2분 후 페어링 모드로 돌아갑니다.';

  @override
  String get searchingNearbyDevices =>
      '주변의 Osprey 기기를 검색하고 있습니다. 기기가 페어링 모드인지 확인하세요.';

  @override
  String get looksLike5GhzHint =>
      '이 네트워크는 5GHz인 것 같습니다 — 휴대폰을 2.4GHz 네트워크로 변경한 후 새로고침을 누르세요.';

  @override
  String get pairingWifiHint =>
      '기기는 휴대폰이 사용 중인 Wi-Fi에 연결됩니다. 2.4GHz 네트워크만 지원합니다.';

  @override
  String get siriShortcutsHelp =>
      '장면을 눌러 음성 문구를 등록하면 \"Hey Siri\" 뒤에 그 문구를 말해 장면을 실행할 수 있습니다 — 앱이 닫혀 있어도 동작합니다.\n\n이미 추가한 장면을 누르면 문구를 바꾸거나 삭제할 수 있습니다.';

  @override
  String get deleteAccountWarning =>
      '삭제 후:\n• 계정은 30일 후에 삭제됩니다\n• 모든 기기와 장면이 제거됩니다\n• 30일 이내에 다시 로그인하면 취소할 수 있습니다';

  @override
  String aiSuggestionBody(String action, String weekday, String hour) {
    return '보통 $weekday $hour:00에 \"$action\"을(를) 실행하시네요 — 자동화할까요?';
  }

  @override
  String removeDeviceConfirm(String name) {
    return '\"$name\"이(가) 집에서 제거되고 약 1~2분 후 자동으로 페어링 모드로 돌아갑니다.';
  }

  @override
  String eraseDeviceConfirm(String name) {
    return '\"$name\"의 모든 데이터가 삭제되며 복구할 수 없습니다. 계속하시겠습니까?';
  }

  @override
  String showInvisibleDevices(int count) {
    return '숨긴 기기 표시($count)';
  }

  @override
  String resetLinkSent(String email) {
    return '$email로 등록된 계정이 있으면 비밀번호 재설정 링크를 보내드립니다.';
  }

  @override
  String signInNotAvailable(String name) {
    return '$name 로그인은 아직 지원되지 않습니다.';
  }

  @override
  String resendCodeIn(int seconds) {
    return '$seconds초 후 재전송 가능';
  }

  @override
  String deleteConfirmNamed(String name) {
    return '\"$name\"을(를) 삭제하시겠습니까?';
  }

  @override
  String taskCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '작업 $count개',
    );
    return '$_temp0';
  }

  @override
  String featureComingSoonShort(String feature) {
    return '$feature은(는) 곧 제공됩니다';
  }

  @override
  String roomCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count개의 방',
    );
    return '$_temp0';
  }

  @override
  String removeDevicesQ(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '기기 $count개를 제거하시겠습니까?',
      one: '이 기기를 제거하시겠습니까?',
    );
    return '$_temp0';
  }

  @override
  String devicesRemoved(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '기기 $count개를 제거했습니다',
      one: '기기 1개를 제거했습니다',
    );
    return '$_temp0';
  }

  @override
  String deviceCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '기기 $count개',
    );
    return '$_temp0';
  }

  @override
  String mainModuleVersion(String version) {
    return '메인 모듈: V$version';
  }

  @override
  String outdoorTemperatureValue(int temp) {
    return '실외 온도: $temp°C';
  }

  @override
  String occurrencesIn30Days(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '30일 동안 $count회',
    );
    return '$_temp0';
  }

  @override
  String sceneExecuted(String name) {
    return '\"$name\" 실행됨';
  }

  @override
  String couldNotRunScene(String name) {
    return '\"$name\"을(를) 실행할 수 없습니다. 다시 시도해 주세요.';
  }

  @override
  String featureComingSoonNamed(String feature) {
    return '$feature은(는) 곧 제공됩니다.';
  }

  @override
  String get couldNotLoadHome => '집 정보를 불러올 수 없습니다. 다시 시도해 주세요.';

  @override
  String deviceCouldNotConnectTo(String ssid, String reason, String stayedOn) {
    return '기기가 \"$ssid\"에 연결하지 못했습니다.\n\n이유: $reason\n\n기기는 여전히 \"$stayedOn\"에 연결되어 있습니다.';
  }

  @override
  String makeSureNetworkInRange(String ssid) {
    return '\n\n\"$ssid\"가 켜져 있고 신호 범위 내에 있는지 확인하세요.';
  }

  @override
  String get noResponseFromDevice => '기기에서 응답이 없습니다. 잠시 후 새로고침해 현재 상태를 확인하세요.';

  @override
  String devicesBeingAdded(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '기기 $count개 추가 중',
    );
    return '$_temp0';
  }

  @override
  String devicesAddedSuccessfully(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '기기 $count개를 추가했습니다',
    );
    return '$_temp0';
  }

  @override
  String get alexaExamplesIntro =>
      'Amazon Alexa 스피커로\nAlexa 지원 기기를 제어할 수 있습니다. 예:';

  @override
  String get googleExamplesIntro =>
      '이제 Google Home 스피커로\nGoogle 어시스턴트 기기를 제어할 수 있습니다. 예:';

  @override
  String get gridView => '그리드 보기';

  @override
  String get listView => '목록 보기';

  @override
  String get deviceManagement => '기기 관리';

  @override
  String get sort => '정렬';

  @override
  String get darkMode => '다크 모드';

  @override
  String get followSystem => '시스템 설정 따르기';

  @override
  String get system => '시스템';

  @override
  String get systemDarkModeHint => '켜면 시스템 설정에 맞춰 다크 모드가 자동으로 전환됩니다.';

  @override
  String get normalMode => '일반 모드';

  @override
  String get deviceStatus => '기기 상태';

  @override
  String get selectDevice => '기기 선택';

  @override
  String get condition => '조건';

  @override
  String get precondition => '사전 조건';

  @override
  String get customTime => '사용자 지정';

  @override
  String get startTime => '시작 시간';

  @override
  String get endTime => '종료 시간';

  @override
  String get overnightNote => '이 시간대는 자정을 넘깁니다. 시작하는 날을 기준으로 계산됩니다.';

  @override
  String get automationDelayNote =>
      '상태가 바뀐 뒤 약 5초 안에 실행되고, 그 후 60초 동안 멈춥니다. 새로 만든 자동화는 조건이 이미 충족되어 있으면 바로 실행되지 않고 다음에 바뀔 때 실행됩니다.';

  @override
  String get selectCity => '도시 선택';

  @override
  String get searchCity => '도시 검색';

  @override
  String get equals => '같음';

  @override
  String get notEquals => '같지 않음';

  @override
  String get greaterThan => '초과';

  @override
  String get greaterOrEqual => '이상';

  @override
  String get lessThan => '미만';

  @override
  String get lessOrEqual => '이하';

  @override
  String get noReadableDataPoints => '이 기기에는 조건으로 사용할 수 있는 읽기 가능한 상태가 없습니다.';

  @override
  String get bluetoothOffMessage => '블루투스가 꺼져 있습니다. 켜면 주변 기기를 찾을 수 있습니다';
}
