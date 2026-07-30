// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_l10n.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppL10nEn extends AppL10n {
  AppL10nEn([String locale = 'en']) : super(locale);

  @override
  String get settingsTitle => 'Settings';

  @override
  String get personalInformation => 'Personal Information';

  @override
  String get accountAndSecurity => 'Account and Security';

  @override
  String get touchToneOnPanel => 'Touch Tone on Panel';

  @override
  String get aiAssistant => 'AI Assistant';

  @override
  String get temperatureUnit => 'Temperature Unit';

  @override
  String get about => 'About';

  @override
  String get networkDiagnosis => 'Network Diagnosis';

  @override
  String get clearCache => 'Clear Cache';

  @override
  String get language => 'Language';

  @override
  String get logOut => 'Log Out';

  @override
  String get languageSystemDefault => 'Same as the system language';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageVietnamese => 'Vietnamese';

  @override
  String get clearCacheMessage =>
      'Cached scenes, home data and images will be re-downloaded on next use. Your account and devices are not affected.';

  @override
  String get clear => 'Clear';

  @override
  String get cancel => 'Cancel';

  @override
  String freedSpace(String size) {
    return 'Freed $size';
  }

  @override
  String aboutVersion(String version, String build) {
    return 'Version $version ($build)';
  }

  @override
  String get privacyPolicy => 'Privacy Policy';

  @override
  String get termsOfService => 'Terms of Service';

  @override
  String get bundleId => 'Bundle ID';

  @override
  String get server => 'Server';

  @override
  String get couldNotOpenLink => 'Could not open the link.';

  @override
  String get diagLocalNetwork => 'Local network';

  @override
  String get diagLocalNetworkNoWifi =>
      'Not on Wi-Fi (mobile data or permission denied)';

  @override
  String get diagLocalNetworkUnreadable => 'Could not read Wi-Fi name';

  @override
  String get diagDnsLookup => 'DNS lookup';

  @override
  String diagDnsFailed(String host) {
    return 'Cannot resolve $host';
  }

  @override
  String get diagServerReachable => 'Server reachable';

  @override
  String diagServerLatency(String ms, String status) {
    return '$ms ms · HTTP $status';
  }

  @override
  String get diagServerNoResponse => 'No response from server';

  @override
  String get diagSignedIn => 'Signed in';

  @override
  String get diagSessionValid => 'Session valid';

  @override
  String diagSessionInvalid(String status) {
    return 'HTTP $status — please sign in again';
  }

  @override
  String get diagSessionUnverified => 'Could not verify session';

  @override
  String get diagControlChannel => 'Control channel';

  @override
  String get diagCloudConnected => 'Cloud (MQTT) connected';

  @override
  String get diagBleFallback => 'Cloud down — using Bluetooth fallback';

  @override
  String get diagUnreachable => 'No cloud and no Bluetooth in range';

  @override
  String get diagStatusUnknown => 'Status unknown';

  @override
  String get runAgain => 'Run Again';

  @override
  String get accountCreatedPleaseSignIn => 'Account created — please sign in.';

  @override
  String get add => 'Add';

  @override
  String get addCondition => 'Add Condition';

  @override
  String get addRoom => 'Add Room';

  @override
  String get addTask => 'Add Task';

  @override
  String get addAtLeastTwoDevicesToAGroup =>
      'Add at least two devices to a group.';

  @override
  String get alexa => 'Alexa';

  @override
  String get all => 'All';

  @override
  String get allDevices => 'All Devices';

  @override
  String get alternateNetwork => 'Alternate Network';

  @override
  String get apply => 'Apply';

  @override
  String get areYouSureYouWantToLogOut => 'Are you sure you want to log out?';

  @override
  String get askAboutYourCurtainsOrTryHelp =>
      'Ask about your curtains, or try /help…';

  @override
  String get askAboutYourCurtains => 'Ask about your curtains…';

  @override
  String get atLeast6Characters => 'At least 6 characters';

  @override
  String get authDiagnostics => 'Auth Diagnostics';

  @override
  String get automationNotification => 'Automation notification';

  @override
  String get changeRoom => 'Change Room';

  @override
  String get close => 'Close';

  @override
  String get cloud => 'Cloud';

  @override
  String get confirm => 'Confirm';

  @override
  String get connected => 'Connected';

  @override
  String get control => 'Control';

  @override
  String get controlSingleDevice => 'Control Single Device';

  @override
  String get copiedToClipboard => 'Copied to clipboard';

  @override
  String get copy => 'Copy';

  @override
  String get couldNotChangeTheMotorDirectionPleaseTryAgai =>
      'Could not change the motor direction. Please try again.';

  @override
  String get couldNotConnect => 'Could not connect';

  @override
  String get couldNotCreateTheGroupPleaseTryAgain =>
      'Could not create the group. Please try again.';

  @override
  String get couldNotOpenTheBrowser => 'Could not open the browser.';

  @override
  String get couldNotSendTheCommandPleaseTryAgain =>
      'Could not send the command. Please try again.';

  @override
  String get create => 'Create';

  @override
  String get createScene => 'Create Scene';

  @override
  String get createAHome => 'Create a home';

  @override
  String get createARoomFirst => 'Create a room first.';

  @override
  String get createAccount => 'Create account';

  @override
  String get createScene2 => 'Create scene';

  @override
  String get curtainPosition => 'Curtain position';

  @override
  String get curtainPositionSetting => 'Curtain position setting';

  @override
  String get customDeviceIconsAreNotSupportedYet =>
      'Custom device icons are not supported yet.';

  @override
  String get delayTheAction => 'Delay the action';

  @override
  String get delete => 'Delete';

  @override
  String get deleteAccount => 'Delete Account';

  @override
  String get deleteHome => 'Delete Home';

  @override
  String get deleteRoom => 'Delete Room';

  @override
  String get deleteSchedule => 'Delete Schedule';

  @override
  String get deleteScene => 'Delete scene?';

  @override
  String get deleteThisSchedule => 'Delete this schedule?';

  @override
  String get deviceNetwork => 'Device Network';

  @override
  String get deviceHasNoProfileInformation =>
      'Device has no profile information';

  @override
  String get deviceIsOffline => 'Device is offline';

  @override
  String get deviceIsReady => 'Device is ready.';

  @override
  String get deviceName => 'Device name';

  @override
  String get deviceRemovedFromHome => 'Device removed from home.';

  @override
  String get deviceUnreachable => 'Device unreachable';

  @override
  String get devices => 'Devices';

  @override
  String get disconnect => 'Disconnect';

  @override
  String get disconnectDevice => 'Disconnect device?';

  @override
  String get done => 'Done';

  @override
  String get emailAddress => 'Email address';

  @override
  String get emailOrUsername => 'Email or username';

  @override
  String get enterAGroupName => 'Enter a group name';

  @override
  String get enterANote => 'Enter a note';

  @override
  String get enterDeviceName => 'Enter device name';

  @override
  String get enterHomeName => 'Enter home name';

  @override
  String get enterName => 'Enter name';

  @override
  String get enterSceneName => 'Enter scene name';

  @override
  String get enterValue => 'Enter value...';

  @override
  String get enterYourPassword => 'Enter your password';

  @override
  String get eraseDeviceData => 'Erase device data?';

  @override
  String get error => 'Error';

  @override
  String get executedBy => 'Executed By';

  @override
  String get executionTime => 'Execution Time';

  @override
  String get faqFeedback => 'FAQ & Feedback';

  @override
  String get failed => 'Failed';

  @override
  String get featureComingSoon => 'Feature coming soon';

  @override
  String get firmware => 'Firmware';

  @override
  String get firmwareUpdateIsComingSoon => 'Firmware update is coming soon.';

  @override
  String get firstName => 'First name';

  @override
  String get firstNameOptional => 'First name (optional)';

  @override
  String get goBack => 'Go back';

  @override
  String get googleAssistant => 'Google Assistant';

  @override
  String get gotIt => 'Got it';

  @override
  String get groupName => 'Group Name';

  @override
  String get help => 'Help';

  @override
  String get homeManagement => 'Home Management';

  @override
  String get homeName => 'Home Name';

  @override
  String get homeName2 => 'Home name';

  @override
  String get icon => 'Icon';

  @override
  String get conditionIf => 'If';

  @override
  String get joinAHome => 'Join a home';

  @override
  String get joiningAHomeByInviteIsComingSoon =>
      'Joining a home by invite is coming soon.';

  @override
  String get lastName => 'Last name';

  @override
  String get lastNameOptional => 'Last name (optional)';

  @override
  String get later => 'Later';

  @override
  String get launchTapToRun => 'Launch Tap-to-Run';

  @override
  String get localAssociation => 'Local Association';

  @override
  String get localControlOffline => 'Local control (offline)';

  @override
  String get location => 'Location';

  @override
  String get logCopiedToClipboard => 'Log copied to clipboard';

  @override
  String get logs => 'Logs';

  @override
  String get manage => 'Manage';

  @override
  String get managePermissions => 'Manage Permissions';

  @override
  String get markAllAsRead => 'Mark all as read';

  @override
  String get moreSettings => 'More Settings';

  @override
  String get motorDirection => 'Motor Direction';

  @override
  String get moveToTop => 'Move to Top';

  @override
  String get moveToRoom => 'Move to room';

  @override
  String get moved => 'Moved';

  @override
  String get movedToTop => 'Moved to top';

  @override
  String get name => 'Name';

  @override
  String get next => 'Next';

  @override
  String get noDevicesAvailable => 'No devices available';

  @override
  String get noDevicesFound => 'No devices found.';

  @override
  String get noDevicesInThisHome => 'No devices in this home.';

  @override
  String get noDevicesYet => 'No devices yet';

  @override
  String get noFunctionsAvailable => 'No functions available';

  @override
  String get noHomeSelectedPleaseTryAgain =>
      'No home selected, please try again';

  @override
  String get noMatchingTimeZones => 'No matching time zones';

  @override
  String get noOtherScenesAvailable => 'No other scenes available';

  @override
  String get noRooms => 'No rooms';

  @override
  String get noSavedNetworksYet => 'No saved networks yet.';

  @override
  String get noScenes => 'No scenes';

  @override
  String get noScenesAvailable => 'No scenes available';

  @override
  String get note => 'Note';

  @override
  String get notification => 'Notification';

  @override
  String get ok => 'OK';

  @override
  String get offlineNotification => 'Offline Notification';

  @override
  String get open => 'Open';

  @override
  String get openSettings => 'Open Settings';

  @override
  String get outdoorPm25 => 'Outdoor PM2.5';

  @override
  String get outdoorAirPressure => 'Outdoor air pressure';

  @override
  String get outdoorHumidity => 'Outdoor humidity';

  @override
  String get outdoorWindSpeed => 'Outdoor wind speed';

  @override
  String get pairingSuccessful => 'Pairing successful';

  @override
  String get password => 'Password';

  @override
  String get sessionExpiredSignInAgain =>
      'Your session has expired. Please sign in again.';

  @override
  String get pleaseAddAtLeast1Action => 'Please add at least 1 action';

  @override
  String get pleaseAddAtLeast1Condition => 'Please add at least 1 condition';

  @override
  String get pleaseEnterAName => 'Please enter a name';

  @override
  String get pleaseEnterASceneName => 'Please enter a scene name';

  @override
  String get pleaseSelectAFunction => 'Please select a function';

  @override
  String get pleaseSelectATime0 => 'Please select a time > 0';

  @override
  String get rePairNow => 'Re-pair now';

  @override
  String get rePairRequired => 'Re-pair required';

  @override
  String get reasonOptional => 'Reason (optional)';

  @override
  String get refresh => 'Refresh';

  @override
  String get reload => 'Reload';

  @override
  String get remove => 'Remove';

  @override
  String get removeDevice => 'Remove Device';

  @override
  String get removed => 'Removed';

  @override
  String get rename => 'Rename';

  @override
  String get renameRoom => 'Rename Room';

  @override
  String get renameDevice => 'Rename device';

  @override
  String get repeat => 'Repeat';

  @override
  String get rescan => 'Rescan';

  @override
  String get retry => 'Retry';

  @override
  String get roomManagement => 'Room Management';

  @override
  String get roomName => 'Room Name';

  @override
  String get roomUpdated => 'Room updated';

  @override
  String get running => 'Running';

  @override
  String get save => 'Save';

  @override
  String get sceneName => 'Scene Name';

  @override
  String get scenes => 'Scenes';

  @override
  String get schedule => 'Schedule';

  @override
  String get searchAddress => 'Search address';

  @override
  String get searchCityOrRegion => 'Search city or region';

  @override
  String get selectScene => 'Select Scene';

  @override
  String get selectSmartScenes => 'Select smart scenes';

  @override
  String get sendResetLink => 'Send reset link';

  @override
  String get sendVerificationCode => 'Send verification code';

  @override
  String get showOnHomePage => 'Show on Home Page';

  @override
  String get signIn => 'Sign in';

  @override
  String get signalStrength => 'Signal Strength';

  @override
  String get signalStrength2 => 'Signal strength';

  @override
  String get startPairing => 'Start pairing';

  @override
  String get stop => 'Stop';

  @override
  String get style => 'Style';

  @override
  String get switchNetwork => 'Switch';

  @override
  String get switchToThisNetwork => 'Switch to this network';

  @override
  String get tapToRunNotification => 'Tap-to-Run notification';

  @override
  String get conditionThen => 'Then';

  @override
  String get thinking => 'Thinking…';

  @override
  String get thisActionCannotBeUndone => 'This action cannot be undone.';

  @override
  String get thisSavedNetworkWillBeRemovedFromTheDevice =>
      'This saved network will be removed from the device.';

  @override
  String get timeZone => 'Time Zone';

  @override
  String get timeZoneUpdated => 'Time zone updated';

  @override
  String get timedOut => 'Timed out';

  @override
  String get tryAgain => 'Try again';

  @override
  String get useCurrentLocation => 'Use current location';

  @override
  String get usingSiri => 'Using Siri';

  @override
  String get virtualId => 'Virtual ID';

  @override
  String get whenDeviceStatusChanges => 'When device status changes';

  @override
  String get whenWeatherChanges => 'When weather changes';

  @override
  String get wiFi => 'Wi-Fi';

  @override
  String get wifiNameSsid => 'WiFi name (SSID)';

  @override
  String get wifiPassword => 'WiFi password';

  @override
  String get navHome => 'Home';

  @override
  String get navScenes => 'Scenes';

  @override
  String get navChat => 'Chat';

  @override
  String get navMe => 'Me';

  @override
  String get thirdPartyServices => 'Third-Party Services';

  @override
  String get messageCenter => 'Message Center';

  @override
  String get appMall => 'App Mall';

  @override
  String get addDevice => 'Add Device';

  @override
  String get tapToRun => 'Tap-to-Run';

  @override
  String get automationEmptyHint =>
      'Home automation saves your time and effort by automating routine tasks.';

  @override
  String get tapToRunEmptyHint =>
      'Create a Tap-to-Run scene to control your devices quickly with a single tap.';

  @override
  String get scene => 'Scene';

  @override
  String get executionFailed => 'Execution failed';

  @override
  String get device => 'Device';

  @override
  String get delay => 'Delay';

  @override
  String get runScene => 'Run Scene';

  @override
  String get addToSiri => 'Add to Siri';

  @override
  String get storeUnderPreparation =>
      'The store is under preparation, please stay tuned.';

  @override
  String get commonFunctions => 'Common Functions';

  @override
  String get noConnection => 'No connection';

  @override
  String get checkInternetAndRetry =>
      'Check your internet connection and try again.';

  @override
  String get noConnectionCheckInternet =>
      'No connection. Check your internet and try again.';

  @override
  String get addFirstCurtainHint =>
      'Tap the + button to add your first curtain to this home.';

  @override
  String get hideInvisibleDevices => 'Hide invisible devices';

  @override
  String get deviceRenamed => 'Device renamed.';

  @override
  String get deviceDeletedReturningToPairing =>
      'Device deleted. It is returning to pairing mode.';

  @override
  String get homeSettings => 'Home Settings';

  @override
  String get toBeSet => 'To Be Set';

  @override
  String get homeMember => 'Home Member';

  @override
  String get memberDetails => 'Member details';

  @override
  String get addMember => 'Add Member';

  @override
  String get pending => 'Pending';

  @override
  String get removesFromHomeHint =>
      'Removes from home; device returns to pairing mode in 1-2 minutes';

  @override
  String get unlinkAndEraseData => 'Unlink and erase data';

  @override
  String get erasesAllDataHint => 'Erases all data, cannot be undone';

  @override
  String get somethingWentWrongTryAgain =>
      'Something went wrong, please try again';

  @override
  String get tapToRunAndAutomation => 'Tap-to-Run and Automation';

  @override
  String get thirdPartyControl => 'Third-party Control';

  @override
  String get deviceOfflineNotification => 'Device Offline Notification';

  @override
  String get others => 'Others';

  @override
  String get shareDevice => 'Share Device';

  @override
  String get addToHomeScreen => 'Add to Home Screen';

  @override
  String get checkDeviceNetwork => 'Check Device Network';

  @override
  String get checkNow => 'Check Now';

  @override
  String get deviceUpdate => 'Device Update';

  @override
  String get removeDevicesWarning =>
      'They will be removed from this home and returned to pairing mode.';

  @override
  String get shown => 'Shown';

  @override
  String get hidden => 'Hidden';

  @override
  String get devicesBackOnHome => 'Devices are back on Home';

  @override
  String get hiddenFromHome => 'Hidden from Home';

  @override
  String get offline => 'Offline';

  @override
  String get show => 'Show';

  @override
  String get hide => 'Hide';

  @override
  String get profilePhoto => 'Profile Photo';

  @override
  String get nickname => 'Nickname';

  @override
  String get noRoomsYet => 'No rooms yet';

  @override
  String get tapPlusToAddRoom => 'Tap + to add a new room';

  @override
  String get emailAddressLabel => 'Email Address';

  @override
  String get notSet => 'Not set';

  @override
  String get deviceInformation => 'Device Information';

  @override
  String get unknown => 'Unknown';

  @override
  String get notReported => 'Not reported';

  @override
  String get noScenesUseThisDevice => 'No scenes use this device yet.';

  @override
  String get tapToRunLabel => 'Tap to Run';

  @override
  String get automation => 'Automation';

  @override
  String get forward => 'Forward';

  @override
  String get back => 'Back';

  @override
  String get setting => 'Setting';

  @override
  String get updateAvailable => 'Update available';

  @override
  String get noUpdatesAvailable => 'No updates available';

  @override
  String get updateNow => 'Update Now';

  @override
  String get unassigned => 'Unassigned';

  @override
  String get enterEmailOrUsername => 'Enter your email or username';

  @override
  String get welcome => 'Welcome';

  @override
  String get signInSubtitle => 'Sign in to your osprey.life account.';

  @override
  String get createOne => 'Create one';

  @override
  String get forgotPassword => 'Forgot password?';

  @override
  String get orContinueWith => 'or continue with';

  @override
  String get enterValidEmail => 'Enter a valid email address';

  @override
  String get resetYourPassword => 'Reset your password';

  @override
  String get checkYourInbox => 'Check your inbox';

  @override
  String get enterYourEmailAddress => 'Enter your email address';

  @override
  String get enterSixDigitCode => 'Enter the 6-digit code';

  @override
  String get enterAPassword => 'Enter a password';

  @override
  String get createYourAccount => 'Create your account';

  @override
  String get checkYourEmail => 'Check your email';

  @override
  String get resendCode => 'Resend code';

  @override
  String get userAgreement => 'User Agreement';

  @override
  String get reconnecting => 'Reconnecting…';

  @override
  String get checkWifiOrBluetooth => 'Check WiFi or move closer for Bluetooth.';

  @override
  String get smartScenesRequireInternet => 'Smart Scenes require internet';

  @override
  String get enterWifiName => 'Enter the WiFi name';

  @override
  String get wifiNameLengthError => 'WiFi name must be 1–32 characters';

  @override
  String get passwordMin8 => 'Password must be at least 8 characters';

  @override
  String get passwordLength863 => 'Password must be 8–63 characters';

  @override
  String get networkAlreadySaved =>
      'This network is already saved. To change its password, delete it and add it again.';

  @override
  String get addWifiNetwork => 'Add WiFi network';

  @override
  String get atLeast8Characters => 'At least 8 characters';

  @override
  String get only24GhzSupported =>
      'Curtain devices only support 2.4GHz WiFi (WPA2).';

  @override
  String get labelOptional => 'Label (optional)';

  @override
  String get createGroup => 'Create Group';

  @override
  String get groupControlHint =>
      'Devices in the same group can be controlled together.';

  @override
  String get devicesToBeAdded => 'Devices to Be Added';

  @override
  String get noSameTypeDevices =>
      'No other devices of the same type in this home.';

  @override
  String get couldNotLoadNetworkDetails =>
      'Could not load network details. Pull to refresh.';

  @override
  String get alreadyOnThisNetwork => 'Already on this network.';

  @override
  String get deviceOfflineTryLater =>
      'Device is offline — please try again later.';

  @override
  String get wrongPassword => 'Wrong password';

  @override
  String get networkNotFound => 'Network not found';

  @override
  String get networkRemoved => 'Network removed.';

  @override
  String get network => 'Network';

  @override
  String get connectedTo => 'Connected to';

  @override
  String get savedNetworks => 'Saved networks';

  @override
  String get addANetwork => 'Add a network';

  @override
  String get notConnected => 'Not connected';

  @override
  String get pleaseKeepAppOpen => 'Please keep the app open.';

  @override
  String get deviceNetworkInformation => 'Device Network Information';

  @override
  String get once => 'Once';

  @override
  String get editSchedule => 'Edit Schedule';

  @override
  String get addSchedule => 'Add Schedule';

  @override
  String get timeVarianceHint => 'Time variance is  ±30s';

  @override
  String get noTimerData => 'No timer data';

  @override
  String get localControlUnsupportedAction =>
      'Local control does not support this action';

  @override
  String get noInternetNoBluetooth => 'No internet and Bluetooth not in range';

  @override
  String get connectionError => 'Connection error';

  @override
  String get exampleTapToRun =>
      'Example: turn off all lights in the bedroom with one tap.';

  @override
  String get exampleWeather =>
      'Example: when local temperature is greater than 28°C.';

  @override
  String get weatherTrigger => 'Weather trigger';

  @override
  String get exampleSchedule => 'Example: 7:00 a.m. every morning.';

  @override
  String get exampleDeviceStatus =>
      'Example: when an unusual activity is detected.';

  @override
  String get deviceStatusTrigger => 'Device-status trigger';

  @override
  String get noNotificationsYet => 'No notifications yet';

  @override
  String get slashCommands => 'Slash commands';

  @override
  String get slashDevicesHint => 'Browse and control your curtains.';

  @override
  String get slashSceneHint => 'Run a tap-to-run scene.';

  @override
  String get slashScheduleHint => 'Open the automation schedule.';

  @override
  String get slashHelpHint => 'Show this list.';

  @override
  String get youCanAlsoSpeak => 'You can also speak — tap the mic button.';

  @override
  String get chatInputHint => 'Type, speak, or use slash commands.';

  @override
  String get online => 'Online';

  @override
  String get blePermissionRequired =>
      'Bluetooth permission is required to find devices';

  @override
  String get bleAndLocationPermissionRequired =>
      'Bluetooth and Location permissions are required to find devices';

  @override
  String get addDeviceLower => 'Add device';

  @override
  String get scanningStopped => 'Scanning stopped.';

  @override
  String get enterWifiPassword => 'Enter the WiFi password';

  @override
  String get detectingCurrentWifi => 'Detecting current WiFi...';

  @override
  String get autoDetectedWifi =>
      'Auto-detected from the WiFi your phone is connected to';

  @override
  String get couldNotDetectWifi =>
      'Could not detect WiFi — enter the network name manually';

  @override
  String get beingAdded => 'Being added';

  @override
  String get addedSuccessfully => 'Added successfully';

  @override
  String get pairingFailed => 'Pairing failed';

  @override
  String get allDay => 'All day';

  @override
  String get whenAnyConditionMet => 'When any condition is met';

  @override
  String get whenAllConditionsMet => 'When all conditions are met';

  @override
  String get deleteSceneWarning =>
      'After the scenario is deleted, the device tasks can no longer be executed properly.';

  @override
  String get toggleAutomation => 'Toggle Automation';

  @override
  String get enable => 'Enable';

  @override
  String get disable => 'Disable';

  @override
  String get everyDay => 'Every day';

  @override
  String get monToFri => 'Mon - Fri';

  @override
  String get satToSun => 'Sat - Sun';

  @override
  String get runOnceIfNoDaySelected =>
      'The action will be carried out only once if you do not select any day of the week.';

  @override
  String get sendNotification => 'Send notification';

  @override
  String get color => 'Color';

  @override
  String get wait => 'Wait';

  @override
  String get finish => 'Finish';

  @override
  String get selectFunction => 'Select Function';

  @override
  String get on => 'On';

  @override
  String get off => 'Off';

  @override
  String get siriShortcut => 'Siri Shortcut';

  @override
  String get createTapToRunFirst => 'Create a Tap-to-Run scene first.';

  @override
  String get poweredByFoundationModels =>
      'Powered by Apple Foundation Models, on-device.';

  @override
  String get weatherClearNight => 'Clear night';

  @override
  String get weatherSunny => 'Sunny';

  @override
  String get weatherPartlyCloudy => 'Partly cloudy';

  @override
  String get weatherCloudy => 'Cloudy';

  @override
  String get qualityExcellent => 'Excellent';

  @override
  String get qualityGood => 'Good';

  @override
  String get qualityModerate => 'Moderate';

  @override
  String get qualityPoor => 'Poor';

  @override
  String get qualityVeryPoor => 'Very Poor';

  @override
  String get switchLocation => 'Switch location';

  @override
  String get aiSuggestion => 'AI Suggestion';

  @override
  String get listening => 'Listening…';

  @override
  String get parsing => 'Parsing…';

  @override
  String get getStarted => 'Get started';

  @override
  String get aiChatEmptyState =>
      'Ask the osprey.life assistant anything about your curtains.\nPowered by Apple Foundation Models, on-device.';

  @override
  String get chatHeaderSubtitle =>
      'On-device AI for your motorized curtains.\nType, speak, or use slash commands.';

  @override
  String get daySunShort => 'Sun.';

  @override
  String get dayMonShort => 'Mon.';

  @override
  String get dayTueShort => 'Tues.';

  @override
  String get dayWedShort => 'Wed.';

  @override
  String get dayThuShort => 'Thurs.';

  @override
  String get dayFriShort => 'Fri.';

  @override
  String get daySatShort => 'Sat.';

  @override
  String get dayMon => 'Mon';

  @override
  String get dayTue => 'Tue';

  @override
  String get dayWed => 'Wed';

  @override
  String get dayThu => 'Thu';

  @override
  String get dayFri => 'Fri';

  @override
  String get daySat => 'Sat';

  @override
  String get daySun => 'Sun';

  @override
  String get accountLinkedSuccessfully => 'Account linked successfully!';

  @override
  String get linkingFailed => 'Linking failed';

  @override
  String get anErrorOccurredTryAgain => 'An error occurred. Please try again.';

  @override
  String get signInWithAmazon => 'Sign In With Amazon';

  @override
  String get viewMoreWaysToLink => 'View more ways to link';

  @override
  String get alreadyLinkedWithAlexa => 'Already linked with Amazon Alexa';

  @override
  String get somethingWentWrong => 'Something went wrong';

  @override
  String get noAuthorizationCode => 'No authorization code received';

  @override
  String get couldNotOpenGoogleHome => 'Could not open Google Home app';

  @override
  String get reLogin => 'Re-Login';

  @override
  String get linkWithGoogleAssistant => 'Link with Google Assistant';

  @override
  String get linkedWithGoogleAssistant => 'Linked with Google Assistant';

  @override
  String get anErrorOccurred => 'An error occurred';

  @override
  String deleteHomeConfirm(String name) {
    return 'Are you sure you want to delete \"$name\"? This action cannot be undone.';
  }

  @override
  String get offlineScenesBody =>
      'Scenes and schedules pause until your WiFi is back. Local Bluetooth control still works for direct open/close/stop on each device.';

  @override
  String get blePairingLostBody =>
      'Local Bluetooth control needs to be re-paired with this device. This usually happens after the app data was cleared or the device was factory reset.';

  @override
  String get alternateNetworkHint =>
      'If the current network is unavailable, the device will be automatically connected to an alternate network.';

  @override
  String get switchNetworkWarning =>
      'The device will disconnect from its current WiFi and try to join the new one. This usually takes 5–30 seconds.';

  @override
  String get runOnceIfNoDayPicked =>
      'The action will be carried out only once if you do not select it.';

  @override
  String get alexaUnlinkHint =>
      'Disable osprey.life skill on the Amazon Alexa app or tap Me > the Setting button in the top right corner > Account and Security to unauthorize it.';

  @override
  String get alexaLinkExplainer =>
      'Binding your app account to your Amazon account allows you to control Alexa-enabled devices through Amazon Echo speakers (ex. \"Alexa, turn on light.\")';

  @override
  String get chatScheduleHelp =>
      'Set up automated schedules for your curtains. Open the Scenes tab to create daily, weekly, or one-time automation schedules.';

  @override
  String get chatScenesHelp =>
      'Create and manage Tap-to-Run scenes from the Scenes tab. Scenes let you chain multiple curtain actions with delays into a single tap.';

  @override
  String get googleUnlinkHint =>
      'Disable osprey.life skill on the Google Home app or tap Me > the Setting button in the top right corner > Account and Security to unauthorize it.';

  @override
  String get googleLinkExplainer =>
      'After connecting your App account and Google  account, you can use Google Home Smart Speakers to control devices that work with Google Assistant.  For example, you can say, \"OK Google, please turn on  the light.\"';

  @override
  String get deviceDisconnectedFromHome =>
      'Device disconnected from home. It will return to pairing mode in 1-2 minutes.';

  @override
  String get searchingNearbyDevices =>
      'Searching for nearby Osprey devices. Make sure the device is in pairing mode.';

  @override
  String get looksLike5GhzHint =>
      'This network looks like 5GHz — switch your phone to a 2.4GHz network, then tap refresh.';

  @override
  String get pairingWifiHint =>
      'The device will connect to the WiFi your phone is using. Only 2.4GHz networks are supported.';

  @override
  String get siriShortcutsHelp =>
      'Tap a scene to record a voice phrase, then say \"Hey Siri\" followed by that phrase to run the scene — even when the app is closed.\n\nTap a scene you already added to change its phrase or remove it.';

  @override
  String get deleteAccountWarning =>
      'After deletion:\n• Your account will be deleted after 30 days\n• All your devices and scenes will be removed\n• You can cancel by logging in again within 30 days';

  @override
  String aiSuggestionBody(String action, String weekday, String hour) {
    return 'You usually run \"$action\" at $weekday $hour:00 — automate it?';
  }

  @override
  String removeDeviceConfirm(String name) {
    return '\"$name\" will be removed from your home and automatically return to pairing mode in about 1-2 minutes.';
  }

  @override
  String eraseDeviceConfirm(String name) {
    return 'All data for \"$name\" will be erased and CANNOT be recovered. Are you sure?';
  }

  @override
  String showInvisibleDevices(int count) {
    return 'Show invisible devices ($count)';
  }

  @override
  String resetLinkSent(String email) {
    return 'If an account exists for $email, a password reset link is on its way.';
  }

  @override
  String signInNotAvailable(String name) {
    return '$name sign-in is not available yet.';
  }

  @override
  String resendCodeIn(int seconds) {
    return 'Resend code in ${seconds}s';
  }

  @override
  String deleteConfirmNamed(String name) {
    return 'Are you sure you want to delete \"$name\"?';
  }

  @override
  String taskCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tasks',
      one: '1 task',
    );
    return '$_temp0';
  }

  @override
  String featureComingSoonShort(String feature) {
    return '$feature is coming soon';
  }

  @override
  String roomCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Rooms',
      one: '1 Room',
    );
    return '$_temp0';
  }

  @override
  String removeDevicesQ(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Remove $count devices?',
      one: 'Remove device?',
    );
    return '$_temp0';
  }

  @override
  String devicesRemoved(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count devices removed',
      one: '1 device removed',
    );
    return '$_temp0';
  }

  @override
  String deviceCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count devices',
      one: '1 device',
    );
    return '$_temp0';
  }

  @override
  String mainModuleVersion(String version) {
    return 'Main Module: V$version';
  }

  @override
  String outdoorTemperatureValue(int temp) {
    return 'Outdoor temperature: $temp°C';
  }

  @override
  String occurrencesIn30Days(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count times in 30 days',
      one: '1 time in 30 days',
    );
    return '$_temp0';
  }

  @override
  String sceneExecuted(String name) {
    return '\"$name\" executed';
  }

  @override
  String couldNotRunScene(String name) {
    return 'Could not run \"$name\". Please try again.';
  }

  @override
  String featureComingSoonNamed(String feature) {
    return '$feature is coming soon.';
  }

  @override
  String get couldNotLoadHome =>
      'We couldn\'t load your home. Please try again.';

  @override
  String deviceCouldNotConnectTo(String ssid, String reason, String stayedOn) {
    return 'The device couldn\'t connect to \'$ssid\'.\n\nReason: $reason\n\nThe device is still on \'$stayedOn\'.';
  }

  @override
  String makeSureNetworkInRange(String ssid) {
    return '\n\nMake sure \'$ssid\' is on and within range.';
  }

  @override
  String get noResponseFromDevice =>
      'We didn\'t get a response from the device. Refresh in a moment to see its current status.';

  @override
  String devicesBeingAdded(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count devices being added',
      one: '1 device being added',
    );
    return '$_temp0';
  }

  @override
  String devicesAddedSuccessfully(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count devices added successfully',
      one: '1 device added successfully',
    );
    return '$_temp0';
  }

  @override
  String get alexaExamplesIntro =>
      'You can control Alexa-enabled devices with\nAmazon Alexa speakers, such as';

  @override
  String get googleExamplesIntro =>
      'You can now use Google Home voicebox to\ncontrol Google Assistant devices, like';
}
