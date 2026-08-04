import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_l10n_ar.dart';
import 'app_l10n_de.dart';
import 'app_l10n_en.dart';
import 'app_l10n_es.dart';
import 'app_l10n_fr.dart';
import 'app_l10n_it.dart';
import 'app_l10n_ja.dart';
import 'app_l10n_ko.dart';
import 'app_l10n_pt.dart';
import 'app_l10n_ru.dart';
import 'app_l10n_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppL10n
/// returned by `AppL10n.of(context)`.
///
/// Applications need to include `AppL10n.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'gen/app_l10n.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppL10n.localizationsDelegates,
///   supportedLocales: AppL10n.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppL10n.supportedLocales
/// property.
abstract class AppL10n {
  AppL10n(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppL10n of(BuildContext context) {
    return Localizations.of<AppL10n>(context, AppL10n)!;
  }

  static const LocalizationsDelegate<AppL10n> delegate = _AppL10nDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('de'),
    Locale('en'),
    Locale('es'),
    Locale('es', '419'),
    Locale('fr'),
    Locale('it'),
    Locale('ja'),
    Locale('ko'),
    Locale('pt'),
    Locale('pt', 'BR'),
    Locale('ru'),
    Locale('zh'),
    Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hant'),
  ];

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @personalInformation.
  ///
  /// In en, this message translates to:
  /// **'Personal Information'**
  String get personalInformation;

  /// No description provided for @accountAndSecurity.
  ///
  /// In en, this message translates to:
  /// **'Account and Security'**
  String get accountAndSecurity;

  /// No description provided for @touchToneOnPanel.
  ///
  /// In en, this message translates to:
  /// **'Touch Tone on Panel'**
  String get touchToneOnPanel;

  /// No description provided for @aiAssistant.
  ///
  /// In en, this message translates to:
  /// **'AI Assistant'**
  String get aiAssistant;

  /// No description provided for @temperatureUnit.
  ///
  /// In en, this message translates to:
  /// **'Temperature Unit'**
  String get temperatureUnit;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @networkDiagnosis.
  ///
  /// In en, this message translates to:
  /// **'Network Diagnosis'**
  String get networkDiagnosis;

  /// No description provided for @clearCache.
  ///
  /// In en, this message translates to:
  /// **'Clear Cache'**
  String get clearCache;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @logOut.
  ///
  /// In en, this message translates to:
  /// **'Log Out'**
  String get logOut;

  /// Locale option that follows the device language
  ///
  /// In en, this message translates to:
  /// **'Same as the system language'**
  String get languageSystemDefault;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @languageVietnamese.
  ///
  /// In en, this message translates to:
  /// **'Vietnamese'**
  String get languageVietnamese;

  /// No description provided for @clearCacheMessage.
  ///
  /// In en, this message translates to:
  /// **'Cached scenes, home data and images will be re-downloaded on next use. Your account and devices are not affected.'**
  String get clearCacheMessage;

  /// No description provided for @clear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clear;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// Shown after clearing the cache
  ///
  /// In en, this message translates to:
  /// **'Freed {size}'**
  String freedSpace(String size);

  /// No description provided for @aboutVersion.
  ///
  /// In en, this message translates to:
  /// **'Version {version} ({build})'**
  String aboutVersion(String version, String build);

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// No description provided for @termsOfService.
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get termsOfService;

  /// No description provided for @bundleId.
  ///
  /// In en, this message translates to:
  /// **'Bundle ID'**
  String get bundleId;

  /// No description provided for @server.
  ///
  /// In en, this message translates to:
  /// **'Server'**
  String get server;

  /// No description provided for @couldNotOpenLink.
  ///
  /// In en, this message translates to:
  /// **'Could not open the link.'**
  String get couldNotOpenLink;

  /// No description provided for @diagLocalNetwork.
  ///
  /// In en, this message translates to:
  /// **'Local network'**
  String get diagLocalNetwork;

  /// No description provided for @diagLocalNetworkNoWifi.
  ///
  /// In en, this message translates to:
  /// **'Not on Wi-Fi (mobile data or permission denied)'**
  String get diagLocalNetworkNoWifi;

  /// No description provided for @diagLocalNetworkUnreadable.
  ///
  /// In en, this message translates to:
  /// **'Could not read Wi-Fi name'**
  String get diagLocalNetworkUnreadable;

  /// No description provided for @diagDnsLookup.
  ///
  /// In en, this message translates to:
  /// **'DNS lookup'**
  String get diagDnsLookup;

  /// No description provided for @diagDnsFailed.
  ///
  /// In en, this message translates to:
  /// **'Cannot resolve {host}'**
  String diagDnsFailed(String host);

  /// No description provided for @diagServerReachable.
  ///
  /// In en, this message translates to:
  /// **'Server reachable'**
  String get diagServerReachable;

  /// No description provided for @diagServerLatency.
  ///
  /// In en, this message translates to:
  /// **'{ms} ms · HTTP {status}'**
  String diagServerLatency(String ms, String status);

  /// No description provided for @diagServerNoResponse.
  ///
  /// In en, this message translates to:
  /// **'No response from server'**
  String get diagServerNoResponse;

  /// No description provided for @diagSignedIn.
  ///
  /// In en, this message translates to:
  /// **'Signed in'**
  String get diagSignedIn;

  /// No description provided for @diagSessionValid.
  ///
  /// In en, this message translates to:
  /// **'Session valid'**
  String get diagSessionValid;

  /// No description provided for @diagSessionInvalid.
  ///
  /// In en, this message translates to:
  /// **'HTTP {status} — please sign in again'**
  String diagSessionInvalid(String status);

  /// No description provided for @diagSessionUnverified.
  ///
  /// In en, this message translates to:
  /// **'Could not verify session'**
  String get diagSessionUnverified;

  /// No description provided for @diagControlChannel.
  ///
  /// In en, this message translates to:
  /// **'Control channel'**
  String get diagControlChannel;

  /// No description provided for @diagCloudConnected.
  ///
  /// In en, this message translates to:
  /// **'Cloud (MQTT) connected'**
  String get diagCloudConnected;

  /// No description provided for @diagBleFallback.
  ///
  /// In en, this message translates to:
  /// **'Cloud down — using Bluetooth fallback'**
  String get diagBleFallback;

  /// No description provided for @diagUnreachable.
  ///
  /// In en, this message translates to:
  /// **'No cloud and no Bluetooth in range'**
  String get diagUnreachable;

  /// No description provided for @diagStatusUnknown.
  ///
  /// In en, this message translates to:
  /// **'Status unknown'**
  String get diagStatusUnknown;

  /// No description provided for @runAgain.
  ///
  /// In en, this message translates to:
  /// **'Run Again'**
  String get runAgain;

  /// No description provided for @accountCreatedPleaseSignIn.
  ///
  /// In en, this message translates to:
  /// **'Account created — please sign in.'**
  String get accountCreatedPleaseSignIn;

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @addCondition.
  ///
  /// In en, this message translates to:
  /// **'Add Condition'**
  String get addCondition;

  /// No description provided for @addRoom.
  ///
  /// In en, this message translates to:
  /// **'Add Room'**
  String get addRoom;

  /// No description provided for @addTask.
  ///
  /// In en, this message translates to:
  /// **'Add Task'**
  String get addTask;

  /// No description provided for @addAtLeastTwoDevicesToAGroup.
  ///
  /// In en, this message translates to:
  /// **'Add at least two devices to a group.'**
  String get addAtLeastTwoDevicesToAGroup;

  /// No description provided for @alexa.
  ///
  /// In en, this message translates to:
  /// **'Alexa'**
  String get alexa;

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// No description provided for @allDevices.
  ///
  /// In en, this message translates to:
  /// **'All Devices'**
  String get allDevices;

  /// No description provided for @alternateNetwork.
  ///
  /// In en, this message translates to:
  /// **'Alternate Network'**
  String get alternateNetwork;

  /// No description provided for @apply.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get apply;

  /// No description provided for @areYouSureYouWantToLogOut.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to log out?'**
  String get areYouSureYouWantToLogOut;

  /// No description provided for @askAboutYourCurtainsOrTryHelp.
  ///
  /// In en, this message translates to:
  /// **'Ask about your curtains, or try /help…'**
  String get askAboutYourCurtainsOrTryHelp;

  /// No description provided for @askAboutYourCurtains.
  ///
  /// In en, this message translates to:
  /// **'Ask about your curtains…'**
  String get askAboutYourCurtains;

  /// No description provided for @atLeast6Characters.
  ///
  /// In en, this message translates to:
  /// **'At least 6 characters'**
  String get atLeast6Characters;

  /// No description provided for @authDiagnostics.
  ///
  /// In en, this message translates to:
  /// **'Auth Diagnostics'**
  String get authDiagnostics;

  /// No description provided for @automationNotification.
  ///
  /// In en, this message translates to:
  /// **'Automation notification'**
  String get automationNotification;

  /// No description provided for @changeRoom.
  ///
  /// In en, this message translates to:
  /// **'Change Room'**
  String get changeRoom;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @cloud.
  ///
  /// In en, this message translates to:
  /// **'Cloud'**
  String get cloud;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @connected.
  ///
  /// In en, this message translates to:
  /// **'Connected'**
  String get connected;

  /// No description provided for @control.
  ///
  /// In en, this message translates to:
  /// **'Control'**
  String get control;

  /// No description provided for @controlSingleDevice.
  ///
  /// In en, this message translates to:
  /// **'Control Single Device'**
  String get controlSingleDevice;

  /// No description provided for @copiedToClipboard.
  ///
  /// In en, this message translates to:
  /// **'Copied to clipboard'**
  String get copiedToClipboard;

  /// No description provided for @copy.
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get copy;

  /// No description provided for @couldNotChangeTheMotorDirectionPleaseTryAgai.
  ///
  /// In en, this message translates to:
  /// **'Could not change the motor direction. Please try again.'**
  String get couldNotChangeTheMotorDirectionPleaseTryAgai;

  /// No description provided for @couldNotConnect.
  ///
  /// In en, this message translates to:
  /// **'Could not connect'**
  String get couldNotConnect;

  /// No description provided for @couldNotCreateTheGroupPleaseTryAgain.
  ///
  /// In en, this message translates to:
  /// **'Could not create the group. Please try again.'**
  String get couldNotCreateTheGroupPleaseTryAgain;

  /// No description provided for @couldNotOpenTheBrowser.
  ///
  /// In en, this message translates to:
  /// **'Could not open the browser.'**
  String get couldNotOpenTheBrowser;

  /// No description provided for @couldNotSendTheCommandPleaseTryAgain.
  ///
  /// In en, this message translates to:
  /// **'Could not send the command. Please try again.'**
  String get couldNotSendTheCommandPleaseTryAgain;

  /// No description provided for @create.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get create;

  /// No description provided for @createScene.
  ///
  /// In en, this message translates to:
  /// **'Create Scene'**
  String get createScene;

  /// No description provided for @createAHome.
  ///
  /// In en, this message translates to:
  /// **'Create a home'**
  String get createAHome;

  /// No description provided for @createARoomFirst.
  ///
  /// In en, this message translates to:
  /// **'Create a room first.'**
  String get createARoomFirst;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get createAccount;

  /// No description provided for @createScene2.
  ///
  /// In en, this message translates to:
  /// **'Create scene'**
  String get createScene2;

  /// No description provided for @curtainPosition.
  ///
  /// In en, this message translates to:
  /// **'Curtain position'**
  String get curtainPosition;

  /// No description provided for @curtainPositionSetting.
  ///
  /// In en, this message translates to:
  /// **'Curtain position setting'**
  String get curtainPositionSetting;

  /// No description provided for @customDeviceIconsAreNotSupportedYet.
  ///
  /// In en, this message translates to:
  /// **'Custom device icons are not supported yet.'**
  String get customDeviceIconsAreNotSupportedYet;

  /// No description provided for @delayTheAction.
  ///
  /// In en, this message translates to:
  /// **'Delay the action'**
  String get delayTheAction;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @deleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete Account'**
  String get deleteAccount;

  /// No description provided for @deleteHome.
  ///
  /// In en, this message translates to:
  /// **'Delete Home'**
  String get deleteHome;

  /// No description provided for @deleteRoom.
  ///
  /// In en, this message translates to:
  /// **'Delete Room'**
  String get deleteRoom;

  /// No description provided for @deleteSchedule.
  ///
  /// In en, this message translates to:
  /// **'Delete Schedule'**
  String get deleteSchedule;

  /// No description provided for @deleteScene.
  ///
  /// In en, this message translates to:
  /// **'Delete scene?'**
  String get deleteScene;

  /// No description provided for @deleteThisSchedule.
  ///
  /// In en, this message translates to:
  /// **'Delete this schedule?'**
  String get deleteThisSchedule;

  /// No description provided for @deviceNetwork.
  ///
  /// In en, this message translates to:
  /// **'Device Network'**
  String get deviceNetwork;

  /// No description provided for @deviceHasNoProfileInformation.
  ///
  /// In en, this message translates to:
  /// **'Device has no profile information'**
  String get deviceHasNoProfileInformation;

  /// No description provided for @deviceIsOffline.
  ///
  /// In en, this message translates to:
  /// **'Device is offline'**
  String get deviceIsOffline;

  /// No description provided for @deviceIsReady.
  ///
  /// In en, this message translates to:
  /// **'Device is ready.'**
  String get deviceIsReady;

  /// No description provided for @deviceName.
  ///
  /// In en, this message translates to:
  /// **'Device name'**
  String get deviceName;

  /// No description provided for @deviceRemovedFromHome.
  ///
  /// In en, this message translates to:
  /// **'Device removed from home.'**
  String get deviceRemovedFromHome;

  /// No description provided for @deviceUnreachable.
  ///
  /// In en, this message translates to:
  /// **'Device unreachable'**
  String get deviceUnreachable;

  /// No description provided for @devices.
  ///
  /// In en, this message translates to:
  /// **'Devices'**
  String get devices;

  /// No description provided for @disconnect.
  ///
  /// In en, this message translates to:
  /// **'Disconnect'**
  String get disconnect;

  /// No description provided for @disconnectDevice.
  ///
  /// In en, this message translates to:
  /// **'Disconnect device?'**
  String get disconnectDevice;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @emailAddress.
  ///
  /// In en, this message translates to:
  /// **'Email address'**
  String get emailAddress;

  /// No description provided for @emailOrUsername.
  ///
  /// In en, this message translates to:
  /// **'Email or username'**
  String get emailOrUsername;

  /// No description provided for @enterAGroupName.
  ///
  /// In en, this message translates to:
  /// **'Enter a group name'**
  String get enterAGroupName;

  /// No description provided for @enterANote.
  ///
  /// In en, this message translates to:
  /// **'Enter a note'**
  String get enterANote;

  /// No description provided for @enterDeviceName.
  ///
  /// In en, this message translates to:
  /// **'Enter device name'**
  String get enterDeviceName;

  /// No description provided for @enterHomeName.
  ///
  /// In en, this message translates to:
  /// **'Enter home name'**
  String get enterHomeName;

  /// No description provided for @enterName.
  ///
  /// In en, this message translates to:
  /// **'Enter name'**
  String get enterName;

  /// No description provided for @enterSceneName.
  ///
  /// In en, this message translates to:
  /// **'Enter scene name'**
  String get enterSceneName;

  /// No description provided for @enterValue.
  ///
  /// In en, this message translates to:
  /// **'Enter value...'**
  String get enterValue;

  /// No description provided for @enterYourPassword.
  ///
  /// In en, this message translates to:
  /// **'Enter your password'**
  String get enterYourPassword;

  /// No description provided for @eraseDeviceData.
  ///
  /// In en, this message translates to:
  /// **'Erase device data?'**
  String get eraseDeviceData;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @executedBy.
  ///
  /// In en, this message translates to:
  /// **'Executed By'**
  String get executedBy;

  /// No description provided for @executionTime.
  ///
  /// In en, this message translates to:
  /// **'Execution Time'**
  String get executionTime;

  /// No description provided for @faqFeedback.
  ///
  /// In en, this message translates to:
  /// **'FAQ & Feedback'**
  String get faqFeedback;

  /// No description provided for @failed.
  ///
  /// In en, this message translates to:
  /// **'Failed'**
  String get failed;

  /// No description provided for @featureComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Feature coming soon'**
  String get featureComingSoon;

  /// No description provided for @firmware.
  ///
  /// In en, this message translates to:
  /// **'Firmware'**
  String get firmware;

  /// No description provided for @firmwareUpdateIsComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Firmware update is coming soon.'**
  String get firmwareUpdateIsComingSoon;

  /// No description provided for @firstName.
  ///
  /// In en, this message translates to:
  /// **'First name'**
  String get firstName;

  /// No description provided for @firstNameOptional.
  ///
  /// In en, this message translates to:
  /// **'First name (optional)'**
  String get firstNameOptional;

  /// No description provided for @goBack.
  ///
  /// In en, this message translates to:
  /// **'Go back'**
  String get goBack;

  /// No description provided for @googleAssistant.
  ///
  /// In en, this message translates to:
  /// **'Google Assistant'**
  String get googleAssistant;

  /// No description provided for @gotIt.
  ///
  /// In en, this message translates to:
  /// **'Got it'**
  String get gotIt;

  /// No description provided for @groupName.
  ///
  /// In en, this message translates to:
  /// **'Group Name'**
  String get groupName;

  /// No description provided for @help.
  ///
  /// In en, this message translates to:
  /// **'Help'**
  String get help;

  /// No description provided for @homeManagement.
  ///
  /// In en, this message translates to:
  /// **'Home Management'**
  String get homeManagement;

  /// No description provided for @homeName.
  ///
  /// In en, this message translates to:
  /// **'Home Name'**
  String get homeName;

  /// No description provided for @homeName2.
  ///
  /// In en, this message translates to:
  /// **'Home name'**
  String get homeName2;

  /// No description provided for @icon.
  ///
  /// In en, this message translates to:
  /// **'Icon'**
  String get icon;

  /// No description provided for @conditionIf.
  ///
  /// In en, this message translates to:
  /// **'If'**
  String get conditionIf;

  /// No description provided for @joinAHome.
  ///
  /// In en, this message translates to:
  /// **'Join a home'**
  String get joinAHome;

  /// No description provided for @joiningAHomeByInviteIsComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Joining a home by invite is coming soon.'**
  String get joiningAHomeByInviteIsComingSoon;

  /// No description provided for @lastName.
  ///
  /// In en, this message translates to:
  /// **'Last name'**
  String get lastName;

  /// No description provided for @lastNameOptional.
  ///
  /// In en, this message translates to:
  /// **'Last name (optional)'**
  String get lastNameOptional;

  /// No description provided for @later.
  ///
  /// In en, this message translates to:
  /// **'Later'**
  String get later;

  /// No description provided for @launchTapToRun.
  ///
  /// In en, this message translates to:
  /// **'Launch Tap-to-Run'**
  String get launchTapToRun;

  /// No description provided for @localAssociation.
  ///
  /// In en, this message translates to:
  /// **'Local Association'**
  String get localAssociation;

  /// No description provided for @localControlOffline.
  ///
  /// In en, this message translates to:
  /// **'Local control (offline)'**
  String get localControlOffline;

  /// No description provided for @location.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get location;

  /// No description provided for @logCopiedToClipboard.
  ///
  /// In en, this message translates to:
  /// **'Log copied to clipboard'**
  String get logCopiedToClipboard;

  /// No description provided for @logs.
  ///
  /// In en, this message translates to:
  /// **'Logs'**
  String get logs;

  /// No description provided for @manage.
  ///
  /// In en, this message translates to:
  /// **'Manage'**
  String get manage;

  /// No description provided for @managePermissions.
  ///
  /// In en, this message translates to:
  /// **'Manage Permissions'**
  String get managePermissions;

  /// No description provided for @markAllAsRead.
  ///
  /// In en, this message translates to:
  /// **'Mark all as read'**
  String get markAllAsRead;

  /// No description provided for @moreSettings.
  ///
  /// In en, this message translates to:
  /// **'More Settings'**
  String get moreSettings;

  /// No description provided for @motorDirection.
  ///
  /// In en, this message translates to:
  /// **'Motor Direction'**
  String get motorDirection;

  /// No description provided for @moveToTop.
  ///
  /// In en, this message translates to:
  /// **'Move to Top'**
  String get moveToTop;

  /// No description provided for @moveToRoom.
  ///
  /// In en, this message translates to:
  /// **'Move to room'**
  String get moveToRoom;

  /// No description provided for @moved.
  ///
  /// In en, this message translates to:
  /// **'Moved'**
  String get moved;

  /// No description provided for @movedToTop.
  ///
  /// In en, this message translates to:
  /// **'Moved to top'**
  String get movedToTop;

  /// No description provided for @name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @noDevicesAvailable.
  ///
  /// In en, this message translates to:
  /// **'No devices available'**
  String get noDevicesAvailable;

  /// No description provided for @noDevicesFound.
  ///
  /// In en, this message translates to:
  /// **'No devices found.'**
  String get noDevicesFound;

  /// No description provided for @noDevicesInThisHome.
  ///
  /// In en, this message translates to:
  /// **'No devices in this home.'**
  String get noDevicesInThisHome;

  /// No description provided for @noDevicesYet.
  ///
  /// In en, this message translates to:
  /// **'No devices yet'**
  String get noDevicesYet;

  /// No description provided for @noFunctionsAvailable.
  ///
  /// In en, this message translates to:
  /// **'No functions available'**
  String get noFunctionsAvailable;

  /// No description provided for @noHomeSelectedPleaseTryAgain.
  ///
  /// In en, this message translates to:
  /// **'No home selected, please try again'**
  String get noHomeSelectedPleaseTryAgain;

  /// No description provided for @noMatchingTimeZones.
  ///
  /// In en, this message translates to:
  /// **'No matching time zones'**
  String get noMatchingTimeZones;

  /// No description provided for @noOtherScenesAvailable.
  ///
  /// In en, this message translates to:
  /// **'No other scenes available'**
  String get noOtherScenesAvailable;

  /// No description provided for @noRooms.
  ///
  /// In en, this message translates to:
  /// **'No rooms'**
  String get noRooms;

  /// No description provided for @noSavedNetworksYet.
  ///
  /// In en, this message translates to:
  /// **'No saved networks yet.'**
  String get noSavedNetworksYet;

  /// No description provided for @noScenes.
  ///
  /// In en, this message translates to:
  /// **'No scenes'**
  String get noScenes;

  /// No description provided for @noScenesAvailable.
  ///
  /// In en, this message translates to:
  /// **'No scenes available'**
  String get noScenesAvailable;

  /// No description provided for @note.
  ///
  /// In en, this message translates to:
  /// **'Note'**
  String get note;

  /// No description provided for @notification.
  ///
  /// In en, this message translates to:
  /// **'Notification'**
  String get notification;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @offlineNotification.
  ///
  /// In en, this message translates to:
  /// **'Offline Notification'**
  String get offlineNotification;

  /// No description provided for @open.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get open;

  /// No description provided for @openSettings.
  ///
  /// In en, this message translates to:
  /// **'Open Settings'**
  String get openSettings;

  /// No description provided for @outdoorPm25.
  ///
  /// In en, this message translates to:
  /// **'Outdoor PM2.5'**
  String get outdoorPm25;

  /// No description provided for @outdoorAirPressure.
  ///
  /// In en, this message translates to:
  /// **'Outdoor air pressure'**
  String get outdoorAirPressure;

  /// No description provided for @outdoorHumidity.
  ///
  /// In en, this message translates to:
  /// **'Outdoor humidity'**
  String get outdoorHumidity;

  /// No description provided for @outdoorWindSpeed.
  ///
  /// In en, this message translates to:
  /// **'Outdoor wind speed'**
  String get outdoorWindSpeed;

  /// No description provided for @pairingSuccessful.
  ///
  /// In en, this message translates to:
  /// **'Pairing successful'**
  String get pairingSuccessful;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @sessionExpiredSignInAgain.
  ///
  /// In en, this message translates to:
  /// **'Your session has expired. Please sign in again.'**
  String get sessionExpiredSignInAgain;

  /// No description provided for @pleaseAddAtLeast1Action.
  ///
  /// In en, this message translates to:
  /// **'Please add at least 1 action'**
  String get pleaseAddAtLeast1Action;

  /// No description provided for @pleaseAddAtLeast1Condition.
  ///
  /// In en, this message translates to:
  /// **'Please add at least 1 condition'**
  String get pleaseAddAtLeast1Condition;

  /// No description provided for @pleaseEnterAName.
  ///
  /// In en, this message translates to:
  /// **'Please enter a name'**
  String get pleaseEnterAName;

  /// No description provided for @pleaseEnterASceneName.
  ///
  /// In en, this message translates to:
  /// **'Please enter a scene name'**
  String get pleaseEnterASceneName;

  /// No description provided for @pleaseSelectAFunction.
  ///
  /// In en, this message translates to:
  /// **'Please select a function'**
  String get pleaseSelectAFunction;

  /// No description provided for @pleaseSelectATime0.
  ///
  /// In en, this message translates to:
  /// **'Please select a time > 0'**
  String get pleaseSelectATime0;

  /// No description provided for @rePairNow.
  ///
  /// In en, this message translates to:
  /// **'Re-pair now'**
  String get rePairNow;

  /// No description provided for @rePairRequired.
  ///
  /// In en, this message translates to:
  /// **'Re-pair required'**
  String get rePairRequired;

  /// No description provided for @reasonOptional.
  ///
  /// In en, this message translates to:
  /// **'Reason (optional)'**
  String get reasonOptional;

  /// No description provided for @refresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get refresh;

  /// No description provided for @reload.
  ///
  /// In en, this message translates to:
  /// **'Reload'**
  String get reload;

  /// No description provided for @remove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get remove;

  /// No description provided for @removeDevice.
  ///
  /// In en, this message translates to:
  /// **'Remove Device'**
  String get removeDevice;

  /// No description provided for @removed.
  ///
  /// In en, this message translates to:
  /// **'Removed'**
  String get removed;

  /// No description provided for @rename.
  ///
  /// In en, this message translates to:
  /// **'Rename'**
  String get rename;

  /// No description provided for @renameRoom.
  ///
  /// In en, this message translates to:
  /// **'Rename Room'**
  String get renameRoom;

  /// No description provided for @renameDevice.
  ///
  /// In en, this message translates to:
  /// **'Rename device'**
  String get renameDevice;

  /// No description provided for @repeat.
  ///
  /// In en, this message translates to:
  /// **'Repeat'**
  String get repeat;

  /// No description provided for @rescan.
  ///
  /// In en, this message translates to:
  /// **'Rescan'**
  String get rescan;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @roomManagement.
  ///
  /// In en, this message translates to:
  /// **'Room Management'**
  String get roomManagement;

  /// No description provided for @roomName.
  ///
  /// In en, this message translates to:
  /// **'Room Name'**
  String get roomName;

  /// No description provided for @roomUpdated.
  ///
  /// In en, this message translates to:
  /// **'Room updated'**
  String get roomUpdated;

  /// No description provided for @running.
  ///
  /// In en, this message translates to:
  /// **'Running'**
  String get running;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @sceneName.
  ///
  /// In en, this message translates to:
  /// **'Scene Name'**
  String get sceneName;

  /// No description provided for @scenes.
  ///
  /// In en, this message translates to:
  /// **'Scenes'**
  String get scenes;

  /// No description provided for @schedule.
  ///
  /// In en, this message translates to:
  /// **'Schedule'**
  String get schedule;

  /// No description provided for @searchAddress.
  ///
  /// In en, this message translates to:
  /// **'Search address'**
  String get searchAddress;

  /// No description provided for @searchCityOrRegion.
  ///
  /// In en, this message translates to:
  /// **'Search city or region'**
  String get searchCityOrRegion;

  /// No description provided for @selectScene.
  ///
  /// In en, this message translates to:
  /// **'Select Scene'**
  String get selectScene;

  /// No description provided for @selectSmartScenes.
  ///
  /// In en, this message translates to:
  /// **'Select smart scenes'**
  String get selectSmartScenes;

  /// No description provided for @sendResetLink.
  ///
  /// In en, this message translates to:
  /// **'Send reset link'**
  String get sendResetLink;

  /// No description provided for @sendVerificationCode.
  ///
  /// In en, this message translates to:
  /// **'Send verification code'**
  String get sendVerificationCode;

  /// No description provided for @showOnHomePage.
  ///
  /// In en, this message translates to:
  /// **'Show on Home Page'**
  String get showOnHomePage;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get signIn;

  /// No description provided for @signalStrength.
  ///
  /// In en, this message translates to:
  /// **'Signal Strength'**
  String get signalStrength;

  /// No description provided for @signalStrength2.
  ///
  /// In en, this message translates to:
  /// **'Signal strength'**
  String get signalStrength2;

  /// No description provided for @startPairing.
  ///
  /// In en, this message translates to:
  /// **'Start pairing'**
  String get startPairing;

  /// No description provided for @stop.
  ///
  /// In en, this message translates to:
  /// **'Stop'**
  String get stop;

  /// No description provided for @style.
  ///
  /// In en, this message translates to:
  /// **'Style'**
  String get style;

  /// No description provided for @switchNetwork.
  ///
  /// In en, this message translates to:
  /// **'Switch'**
  String get switchNetwork;

  /// No description provided for @switchToThisNetwork.
  ///
  /// In en, this message translates to:
  /// **'Switch to this network'**
  String get switchToThisNetwork;

  /// No description provided for @tapToRunNotification.
  ///
  /// In en, this message translates to:
  /// **'Tap-to-Run notification'**
  String get tapToRunNotification;

  /// No description provided for @conditionThen.
  ///
  /// In en, this message translates to:
  /// **'Then'**
  String get conditionThen;

  /// No description provided for @thinking.
  ///
  /// In en, this message translates to:
  /// **'Thinking…'**
  String get thinking;

  /// No description provided for @thisActionCannotBeUndone.
  ///
  /// In en, this message translates to:
  /// **'This action cannot be undone.'**
  String get thisActionCannotBeUndone;

  /// No description provided for @thisSavedNetworkWillBeRemovedFromTheDevice.
  ///
  /// In en, this message translates to:
  /// **'This saved network will be removed from the device.'**
  String get thisSavedNetworkWillBeRemovedFromTheDevice;

  /// No description provided for @timeZone.
  ///
  /// In en, this message translates to:
  /// **'Time Zone'**
  String get timeZone;

  /// No description provided for @timeZoneUpdated.
  ///
  /// In en, this message translates to:
  /// **'Time zone updated'**
  String get timeZoneUpdated;

  /// No description provided for @timedOut.
  ///
  /// In en, this message translates to:
  /// **'Timed out'**
  String get timedOut;

  /// No description provided for @tryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get tryAgain;

  /// No description provided for @useCurrentLocation.
  ///
  /// In en, this message translates to:
  /// **'Use current location'**
  String get useCurrentLocation;

  /// No description provided for @usingSiri.
  ///
  /// In en, this message translates to:
  /// **'Using Siri'**
  String get usingSiri;

  /// No description provided for @virtualId.
  ///
  /// In en, this message translates to:
  /// **'Virtual ID'**
  String get virtualId;

  /// No description provided for @whenDeviceStatusChanges.
  ///
  /// In en, this message translates to:
  /// **'When device status changes'**
  String get whenDeviceStatusChanges;

  /// No description provided for @whenWeatherChanges.
  ///
  /// In en, this message translates to:
  /// **'When weather changes'**
  String get whenWeatherChanges;

  /// No description provided for @wiFi.
  ///
  /// In en, this message translates to:
  /// **'Wi-Fi'**
  String get wiFi;

  /// No description provided for @wifiNameSsid.
  ///
  /// In en, this message translates to:
  /// **'WiFi name (SSID)'**
  String get wifiNameSsid;

  /// No description provided for @wifiPassword.
  ///
  /// In en, this message translates to:
  /// **'WiFi password'**
  String get wifiPassword;

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navScenes.
  ///
  /// In en, this message translates to:
  /// **'Scenes'**
  String get navScenes;

  /// No description provided for @navChat.
  ///
  /// In en, this message translates to:
  /// **'Chat'**
  String get navChat;

  /// No description provided for @navMe.
  ///
  /// In en, this message translates to:
  /// **'Me'**
  String get navMe;

  /// No description provided for @thirdPartyServices.
  ///
  /// In en, this message translates to:
  /// **'Third-Party Services'**
  String get thirdPartyServices;

  /// No description provided for @messageCenter.
  ///
  /// In en, this message translates to:
  /// **'Message Center'**
  String get messageCenter;

  /// No description provided for @appMall.
  ///
  /// In en, this message translates to:
  /// **'App Mall'**
  String get appMall;

  /// No description provided for @addDevice.
  ///
  /// In en, this message translates to:
  /// **'Add Device'**
  String get addDevice;

  /// No description provided for @tapToRun.
  ///
  /// In en, this message translates to:
  /// **'Tap-to-Run'**
  String get tapToRun;

  /// No description provided for @automationEmptyHint.
  ///
  /// In en, this message translates to:
  /// **'Home automation saves your time and effort by automating routine tasks.'**
  String get automationEmptyHint;

  /// No description provided for @tapToRunEmptyHint.
  ///
  /// In en, this message translates to:
  /// **'Create a Tap-to-Run scene to control your devices quickly with a single tap.'**
  String get tapToRunEmptyHint;

  /// No description provided for @scene.
  ///
  /// In en, this message translates to:
  /// **'Scene'**
  String get scene;

  /// No description provided for @executionFailed.
  ///
  /// In en, this message translates to:
  /// **'Execution failed'**
  String get executionFailed;

  /// No description provided for @device.
  ///
  /// In en, this message translates to:
  /// **'Device'**
  String get device;

  /// No description provided for @delay.
  ///
  /// In en, this message translates to:
  /// **'Delay'**
  String get delay;

  /// No description provided for @runScene.
  ///
  /// In en, this message translates to:
  /// **'Run Scene'**
  String get runScene;

  /// No description provided for @addToSiri.
  ///
  /// In en, this message translates to:
  /// **'Add to Siri'**
  String get addToSiri;

  /// No description provided for @storeUnderPreparation.
  ///
  /// In en, this message translates to:
  /// **'The store is under preparation, please stay tuned.'**
  String get storeUnderPreparation;

  /// No description provided for @commonFunctions.
  ///
  /// In en, this message translates to:
  /// **'Common Functions'**
  String get commonFunctions;

  /// No description provided for @noConnection.
  ///
  /// In en, this message translates to:
  /// **'No connection'**
  String get noConnection;

  /// No description provided for @checkInternetAndRetry.
  ///
  /// In en, this message translates to:
  /// **'Check your internet connection and try again.'**
  String get checkInternetAndRetry;

  /// No description provided for @noConnectionCheckInternet.
  ///
  /// In en, this message translates to:
  /// **'No connection. Check your internet and try again.'**
  String get noConnectionCheckInternet;

  /// No description provided for @addFirstCurtainHint.
  ///
  /// In en, this message translates to:
  /// **'Tap the + button to add your first curtain to this home.'**
  String get addFirstCurtainHint;

  /// No description provided for @hideInvisibleDevices.
  ///
  /// In en, this message translates to:
  /// **'Hide invisible devices'**
  String get hideInvisibleDevices;

  /// No description provided for @deviceRenamed.
  ///
  /// In en, this message translates to:
  /// **'Device renamed.'**
  String get deviceRenamed;

  /// No description provided for @deviceDeletedReturningToPairing.
  ///
  /// In en, this message translates to:
  /// **'Device deleted. It is returning to pairing mode.'**
  String get deviceDeletedReturningToPairing;

  /// No description provided for @homeSettings.
  ///
  /// In en, this message translates to:
  /// **'Home Settings'**
  String get homeSettings;

  /// No description provided for @toBeSet.
  ///
  /// In en, this message translates to:
  /// **'To Be Set'**
  String get toBeSet;

  /// No description provided for @homeMember.
  ///
  /// In en, this message translates to:
  /// **'Home Member'**
  String get homeMember;

  /// No description provided for @memberDetails.
  ///
  /// In en, this message translates to:
  /// **'Member details'**
  String get memberDetails;

  /// No description provided for @addMember.
  ///
  /// In en, this message translates to:
  /// **'Add Member'**
  String get addMember;

  /// No description provided for @pending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get pending;

  /// No description provided for @removesFromHomeHint.
  ///
  /// In en, this message translates to:
  /// **'Removes from home; device returns to pairing mode in 1-2 minutes'**
  String get removesFromHomeHint;

  /// No description provided for @unlinkAndEraseData.
  ///
  /// In en, this message translates to:
  /// **'Unlink and erase data'**
  String get unlinkAndEraseData;

  /// No description provided for @erasesAllDataHint.
  ///
  /// In en, this message translates to:
  /// **'Erases all data, cannot be undone'**
  String get erasesAllDataHint;

  /// No description provided for @somethingWentWrongTryAgain.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong, please try again'**
  String get somethingWentWrongTryAgain;

  /// No description provided for @tapToRunAndAutomation.
  ///
  /// In en, this message translates to:
  /// **'Tap-to-Run and Automation'**
  String get tapToRunAndAutomation;

  /// No description provided for @thirdPartyControl.
  ///
  /// In en, this message translates to:
  /// **'Third-party Control'**
  String get thirdPartyControl;

  /// No description provided for @deviceOfflineNotification.
  ///
  /// In en, this message translates to:
  /// **'Device Offline Notification'**
  String get deviceOfflineNotification;

  /// No description provided for @others.
  ///
  /// In en, this message translates to:
  /// **'Others'**
  String get others;

  /// No description provided for @shareDevice.
  ///
  /// In en, this message translates to:
  /// **'Share Device'**
  String get shareDevice;

  /// No description provided for @addToHomeScreen.
  ///
  /// In en, this message translates to:
  /// **'Add to Home Screen'**
  String get addToHomeScreen;

  /// No description provided for @checkDeviceNetwork.
  ///
  /// In en, this message translates to:
  /// **'Check Device Network'**
  String get checkDeviceNetwork;

  /// No description provided for @checkNow.
  ///
  /// In en, this message translates to:
  /// **'Check Now'**
  String get checkNow;

  /// No description provided for @deviceUpdate.
  ///
  /// In en, this message translates to:
  /// **'Device Update'**
  String get deviceUpdate;

  /// No description provided for @removeDevicesWarning.
  ///
  /// In en, this message translates to:
  /// **'They will be removed from this home and returned to pairing mode.'**
  String get removeDevicesWarning;

  /// No description provided for @shown.
  ///
  /// In en, this message translates to:
  /// **'Shown'**
  String get shown;

  /// No description provided for @hidden.
  ///
  /// In en, this message translates to:
  /// **'Hidden'**
  String get hidden;

  /// No description provided for @devicesBackOnHome.
  ///
  /// In en, this message translates to:
  /// **'Devices are back on Home'**
  String get devicesBackOnHome;

  /// No description provided for @hiddenFromHome.
  ///
  /// In en, this message translates to:
  /// **'Hidden from Home'**
  String get hiddenFromHome;

  /// No description provided for @offline.
  ///
  /// In en, this message translates to:
  /// **'Offline'**
  String get offline;

  /// No description provided for @show.
  ///
  /// In en, this message translates to:
  /// **'Show'**
  String get show;

  /// No description provided for @hide.
  ///
  /// In en, this message translates to:
  /// **'Hide'**
  String get hide;

  /// No description provided for @profilePhoto.
  ///
  /// In en, this message translates to:
  /// **'Profile Photo'**
  String get profilePhoto;

  /// No description provided for @nickname.
  ///
  /// In en, this message translates to:
  /// **'Nickname'**
  String get nickname;

  /// No description provided for @noRoomsYet.
  ///
  /// In en, this message translates to:
  /// **'No rooms yet'**
  String get noRoomsYet;

  /// No description provided for @tapPlusToAddRoom.
  ///
  /// In en, this message translates to:
  /// **'Tap + to add a new room'**
  String get tapPlusToAddRoom;

  /// No description provided for @emailAddressLabel.
  ///
  /// In en, this message translates to:
  /// **'Email Address'**
  String get emailAddressLabel;

  /// No description provided for @notSet.
  ///
  /// In en, this message translates to:
  /// **'Not set'**
  String get notSet;

  /// No description provided for @deviceInformation.
  ///
  /// In en, this message translates to:
  /// **'Device Information'**
  String get deviceInformation;

  /// No description provided for @unknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get unknown;

  /// No description provided for @notReported.
  ///
  /// In en, this message translates to:
  /// **'Not reported'**
  String get notReported;

  /// No description provided for @noScenesUseThisDevice.
  ///
  /// In en, this message translates to:
  /// **'No scenes use this device yet.'**
  String get noScenesUseThisDevice;

  /// No description provided for @tapToRunLabel.
  ///
  /// In en, this message translates to:
  /// **'Tap to Run'**
  String get tapToRunLabel;

  /// No description provided for @automation.
  ///
  /// In en, this message translates to:
  /// **'Automation'**
  String get automation;

  /// No description provided for @forward.
  ///
  /// In en, this message translates to:
  /// **'Forward'**
  String get forward;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @setting.
  ///
  /// In en, this message translates to:
  /// **'Setting'**
  String get setting;

  /// No description provided for @updateAvailable.
  ///
  /// In en, this message translates to:
  /// **'Update available'**
  String get updateAvailable;

  /// No description provided for @noUpdatesAvailable.
  ///
  /// In en, this message translates to:
  /// **'No updates available'**
  String get noUpdatesAvailable;

  /// No description provided for @updateNow.
  ///
  /// In en, this message translates to:
  /// **'Update Now'**
  String get updateNow;

  /// No description provided for @unassigned.
  ///
  /// In en, this message translates to:
  /// **'Unassigned'**
  String get unassigned;

  /// No description provided for @enterEmailOrUsername.
  ///
  /// In en, this message translates to:
  /// **'Enter your email or username'**
  String get enterEmailOrUsername;

  /// No description provided for @welcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome'**
  String get welcome;

  /// No description provided for @signInSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in to your osprey.life account.'**
  String get signInSubtitle;

  /// No description provided for @createOne.
  ///
  /// In en, this message translates to:
  /// **'Create one'**
  String get createOne;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get forgotPassword;

  /// No description provided for @orContinueWith.
  ///
  /// In en, this message translates to:
  /// **'or continue with'**
  String get orContinueWith;

  /// No description provided for @enterValidEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email address'**
  String get enterValidEmail;

  /// No description provided for @resetYourPassword.
  ///
  /// In en, this message translates to:
  /// **'Reset your password'**
  String get resetYourPassword;

  /// No description provided for @checkYourInbox.
  ///
  /// In en, this message translates to:
  /// **'Check your inbox'**
  String get checkYourInbox;

  /// No description provided for @enterYourEmailAddress.
  ///
  /// In en, this message translates to:
  /// **'Enter your email address'**
  String get enterYourEmailAddress;

  /// No description provided for @enterSixDigitCode.
  ///
  /// In en, this message translates to:
  /// **'Enter the 6-digit code'**
  String get enterSixDigitCode;

  /// No description provided for @enterAPassword.
  ///
  /// In en, this message translates to:
  /// **'Enter a password'**
  String get enterAPassword;

  /// No description provided for @createYourAccount.
  ///
  /// In en, this message translates to:
  /// **'Create your account'**
  String get createYourAccount;

  /// No description provided for @checkYourEmail.
  ///
  /// In en, this message translates to:
  /// **'Check your email'**
  String get checkYourEmail;

  /// No description provided for @resendCode.
  ///
  /// In en, this message translates to:
  /// **'Resend code'**
  String get resendCode;

  /// No description provided for @userAgreement.
  ///
  /// In en, this message translates to:
  /// **'User Agreement'**
  String get userAgreement;

  /// No description provided for @reconnecting.
  ///
  /// In en, this message translates to:
  /// **'Reconnecting…'**
  String get reconnecting;

  /// No description provided for @checkWifiOrBluetooth.
  ///
  /// In en, this message translates to:
  /// **'Check WiFi or move closer for Bluetooth.'**
  String get checkWifiOrBluetooth;

  /// No description provided for @smartScenesRequireInternet.
  ///
  /// In en, this message translates to:
  /// **'Smart Scenes require internet'**
  String get smartScenesRequireInternet;

  /// No description provided for @enterWifiName.
  ///
  /// In en, this message translates to:
  /// **'Enter the WiFi name'**
  String get enterWifiName;

  /// No description provided for @wifiNameLengthError.
  ///
  /// In en, this message translates to:
  /// **'WiFi name must be 1–32 characters'**
  String get wifiNameLengthError;

  /// No description provided for @passwordMin8.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 8 characters'**
  String get passwordMin8;

  /// No description provided for @passwordLength863.
  ///
  /// In en, this message translates to:
  /// **'Password must be 8–63 characters'**
  String get passwordLength863;

  /// No description provided for @networkAlreadySaved.
  ///
  /// In en, this message translates to:
  /// **'This network is already saved. To change its password, delete it and add it again.'**
  String get networkAlreadySaved;

  /// No description provided for @addWifiNetwork.
  ///
  /// In en, this message translates to:
  /// **'Add WiFi network'**
  String get addWifiNetwork;

  /// No description provided for @atLeast8Characters.
  ///
  /// In en, this message translates to:
  /// **'At least 8 characters'**
  String get atLeast8Characters;

  /// No description provided for @only24GhzSupported.
  ///
  /// In en, this message translates to:
  /// **'Curtain devices only support 2.4GHz WiFi (WPA2).'**
  String get only24GhzSupported;

  /// No description provided for @labelOptional.
  ///
  /// In en, this message translates to:
  /// **'Label (optional)'**
  String get labelOptional;

  /// No description provided for @createGroup.
  ///
  /// In en, this message translates to:
  /// **'Create Group'**
  String get createGroup;

  /// No description provided for @groupControlHint.
  ///
  /// In en, this message translates to:
  /// **'Devices in the same group can be controlled together.'**
  String get groupControlHint;

  /// No description provided for @devicesToBeAdded.
  ///
  /// In en, this message translates to:
  /// **'Devices to Be Added'**
  String get devicesToBeAdded;

  /// No description provided for @noSameTypeDevices.
  ///
  /// In en, this message translates to:
  /// **'No other devices of the same type in this home.'**
  String get noSameTypeDevices;

  /// No description provided for @couldNotLoadNetworkDetails.
  ///
  /// In en, this message translates to:
  /// **'Could not load network details. Pull to refresh.'**
  String get couldNotLoadNetworkDetails;

  /// No description provided for @alreadyOnThisNetwork.
  ///
  /// In en, this message translates to:
  /// **'Already on this network.'**
  String get alreadyOnThisNetwork;

  /// No description provided for @deviceOfflineTryLater.
  ///
  /// In en, this message translates to:
  /// **'Device is offline — please try again later.'**
  String get deviceOfflineTryLater;

  /// No description provided for @wrongPassword.
  ///
  /// In en, this message translates to:
  /// **'Wrong password'**
  String get wrongPassword;

  /// No description provided for @networkNotFound.
  ///
  /// In en, this message translates to:
  /// **'Network not found'**
  String get networkNotFound;

  /// No description provided for @networkRemoved.
  ///
  /// In en, this message translates to:
  /// **'Network removed.'**
  String get networkRemoved;

  /// No description provided for @network.
  ///
  /// In en, this message translates to:
  /// **'Network'**
  String get network;

  /// No description provided for @connectedTo.
  ///
  /// In en, this message translates to:
  /// **'Connected to'**
  String get connectedTo;

  /// No description provided for @savedNetworks.
  ///
  /// In en, this message translates to:
  /// **'Saved networks'**
  String get savedNetworks;

  /// No description provided for @addANetwork.
  ///
  /// In en, this message translates to:
  /// **'Add a network'**
  String get addANetwork;

  /// No description provided for @notConnected.
  ///
  /// In en, this message translates to:
  /// **'Not connected'**
  String get notConnected;

  /// No description provided for @pleaseKeepAppOpen.
  ///
  /// In en, this message translates to:
  /// **'Please keep the app open.'**
  String get pleaseKeepAppOpen;

  /// No description provided for @deviceNetworkInformation.
  ///
  /// In en, this message translates to:
  /// **'Device Network Information'**
  String get deviceNetworkInformation;

  /// No description provided for @once.
  ///
  /// In en, this message translates to:
  /// **'Once'**
  String get once;

  /// No description provided for @editSchedule.
  ///
  /// In en, this message translates to:
  /// **'Edit Schedule'**
  String get editSchedule;

  /// No description provided for @addSchedule.
  ///
  /// In en, this message translates to:
  /// **'Add Schedule'**
  String get addSchedule;

  /// No description provided for @timeVarianceHint.
  ///
  /// In en, this message translates to:
  /// **'Time variance is  ±30s'**
  String get timeVarianceHint;

  /// No description provided for @noTimerData.
  ///
  /// In en, this message translates to:
  /// **'No timer data'**
  String get noTimerData;

  /// No description provided for @localControlUnsupportedAction.
  ///
  /// In en, this message translates to:
  /// **'Local control does not support this action'**
  String get localControlUnsupportedAction;

  /// No description provided for @noInternetNoBluetooth.
  ///
  /// In en, this message translates to:
  /// **'No internet and Bluetooth not in range'**
  String get noInternetNoBluetooth;

  /// No description provided for @connectionError.
  ///
  /// In en, this message translates to:
  /// **'Connection error'**
  String get connectionError;

  /// No description provided for @exampleTapToRun.
  ///
  /// In en, this message translates to:
  /// **'Example: turn off all lights in the bedroom with one tap.'**
  String get exampleTapToRun;

  /// No description provided for @exampleWeather.
  ///
  /// In en, this message translates to:
  /// **'Example: when local temperature is greater than 28°C.'**
  String get exampleWeather;

  /// No description provided for @weatherTrigger.
  ///
  /// In en, this message translates to:
  /// **'Weather trigger'**
  String get weatherTrigger;

  /// No description provided for @exampleSchedule.
  ///
  /// In en, this message translates to:
  /// **'Example: 7:00 a.m. every morning.'**
  String get exampleSchedule;

  /// No description provided for @exampleDeviceStatus.
  ///
  /// In en, this message translates to:
  /// **'Example: when an unusual activity is detected.'**
  String get exampleDeviceStatus;

  /// No description provided for @deviceStatusTrigger.
  ///
  /// In en, this message translates to:
  /// **'Device-status trigger'**
  String get deviceStatusTrigger;

  /// No description provided for @noNotificationsYet.
  ///
  /// In en, this message translates to:
  /// **'No notifications yet'**
  String get noNotificationsYet;

  /// No description provided for @slashCommands.
  ///
  /// In en, this message translates to:
  /// **'Slash commands'**
  String get slashCommands;

  /// No description provided for @slashDevicesHint.
  ///
  /// In en, this message translates to:
  /// **'Browse and control your curtains.'**
  String get slashDevicesHint;

  /// No description provided for @slashSceneHint.
  ///
  /// In en, this message translates to:
  /// **'Run a tap-to-run scene.'**
  String get slashSceneHint;

  /// No description provided for @slashScheduleHint.
  ///
  /// In en, this message translates to:
  /// **'Open the automation schedule.'**
  String get slashScheduleHint;

  /// No description provided for @slashHelpHint.
  ///
  /// In en, this message translates to:
  /// **'Show this list.'**
  String get slashHelpHint;

  /// No description provided for @youCanAlsoSpeak.
  ///
  /// In en, this message translates to:
  /// **'You can also speak — tap the mic button.'**
  String get youCanAlsoSpeak;

  /// No description provided for @chatInputHint.
  ///
  /// In en, this message translates to:
  /// **'Type, speak, or use slash commands.'**
  String get chatInputHint;

  /// No description provided for @online.
  ///
  /// In en, this message translates to:
  /// **'Online'**
  String get online;

  /// No description provided for @blePermissionRequired.
  ///
  /// In en, this message translates to:
  /// **'Bluetooth permission is required to find devices'**
  String get blePermissionRequired;

  /// No description provided for @bleAndLocationPermissionRequired.
  ///
  /// In en, this message translates to:
  /// **'Bluetooth and Location permissions are required to find devices'**
  String get bleAndLocationPermissionRequired;

  /// No description provided for @addDeviceLower.
  ///
  /// In en, this message translates to:
  /// **'Add device'**
  String get addDeviceLower;

  /// No description provided for @scanningStopped.
  ///
  /// In en, this message translates to:
  /// **'Scanning stopped.'**
  String get scanningStopped;

  /// No description provided for @enterWifiPassword.
  ///
  /// In en, this message translates to:
  /// **'Enter the WiFi password'**
  String get enterWifiPassword;

  /// No description provided for @detectingCurrentWifi.
  ///
  /// In en, this message translates to:
  /// **'Detecting current WiFi...'**
  String get detectingCurrentWifi;

  /// No description provided for @autoDetectedWifi.
  ///
  /// In en, this message translates to:
  /// **'Auto-detected from the WiFi your phone is connected to'**
  String get autoDetectedWifi;

  /// No description provided for @couldNotDetectWifi.
  ///
  /// In en, this message translates to:
  /// **'Could not detect WiFi — enter the network name manually'**
  String get couldNotDetectWifi;

  /// No description provided for @beingAdded.
  ///
  /// In en, this message translates to:
  /// **'Being added'**
  String get beingAdded;

  /// No description provided for @addedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Added successfully'**
  String get addedSuccessfully;

  /// No description provided for @pairingFailed.
  ///
  /// In en, this message translates to:
  /// **'Pairing failed'**
  String get pairingFailed;

  /// No description provided for @allDay.
  ///
  /// In en, this message translates to:
  /// **'All day'**
  String get allDay;

  /// No description provided for @whenAnyConditionMet.
  ///
  /// In en, this message translates to:
  /// **'When any condition is met'**
  String get whenAnyConditionMet;

  /// No description provided for @whenAllConditionsMet.
  ///
  /// In en, this message translates to:
  /// **'When all conditions are met'**
  String get whenAllConditionsMet;

  /// No description provided for @deleteSceneWarning.
  ///
  /// In en, this message translates to:
  /// **'After the scenario is deleted, the device tasks can no longer be executed properly.'**
  String get deleteSceneWarning;

  /// No description provided for @toggleAutomation.
  ///
  /// In en, this message translates to:
  /// **'Toggle Automation'**
  String get toggleAutomation;

  /// No description provided for @enable.
  ///
  /// In en, this message translates to:
  /// **'Enable'**
  String get enable;

  /// No description provided for @disable.
  ///
  /// In en, this message translates to:
  /// **'Disable'**
  String get disable;

  /// No description provided for @everyDay.
  ///
  /// In en, this message translates to:
  /// **'Every day'**
  String get everyDay;

  /// No description provided for @monToFri.
  ///
  /// In en, this message translates to:
  /// **'Mon - Fri'**
  String get monToFri;

  /// No description provided for @satToSun.
  ///
  /// In en, this message translates to:
  /// **'Sat - Sun'**
  String get satToSun;

  /// No description provided for @runOnceIfNoDaySelected.
  ///
  /// In en, this message translates to:
  /// **'The action will be carried out only once if you do not select any day of the week.'**
  String get runOnceIfNoDaySelected;

  /// No description provided for @sendNotification.
  ///
  /// In en, this message translates to:
  /// **'Send notification'**
  String get sendNotification;

  /// No description provided for @color.
  ///
  /// In en, this message translates to:
  /// **'Color'**
  String get color;

  /// No description provided for @wait.
  ///
  /// In en, this message translates to:
  /// **'Wait'**
  String get wait;

  /// No description provided for @finish.
  ///
  /// In en, this message translates to:
  /// **'Finish'**
  String get finish;

  /// No description provided for @selectFunction.
  ///
  /// In en, this message translates to:
  /// **'Select Function'**
  String get selectFunction;

  /// No description provided for @on.
  ///
  /// In en, this message translates to:
  /// **'On'**
  String get on;

  /// No description provided for @off.
  ///
  /// In en, this message translates to:
  /// **'Off'**
  String get off;

  /// No description provided for @siriShortcut.
  ///
  /// In en, this message translates to:
  /// **'Siri Shortcut'**
  String get siriShortcut;

  /// No description provided for @createTapToRunFirst.
  ///
  /// In en, this message translates to:
  /// **'Create a Tap-to-Run scene first.'**
  String get createTapToRunFirst;

  /// No description provided for @poweredByFoundationModels.
  ///
  /// In en, this message translates to:
  /// **'Powered by Apple Foundation Models, on-device.'**
  String get poweredByFoundationModels;

  /// No description provided for @weatherClearNight.
  ///
  /// In en, this message translates to:
  /// **'Clear night'**
  String get weatherClearNight;

  /// No description provided for @weatherSunny.
  ///
  /// In en, this message translates to:
  /// **'Sunny'**
  String get weatherSunny;

  /// No description provided for @weatherPartlyCloudy.
  ///
  /// In en, this message translates to:
  /// **'Partly cloudy'**
  String get weatherPartlyCloudy;

  /// No description provided for @weatherCloudy.
  ///
  /// In en, this message translates to:
  /// **'Cloudy'**
  String get weatherCloudy;

  /// No description provided for @qualityExcellent.
  ///
  /// In en, this message translates to:
  /// **'Excellent'**
  String get qualityExcellent;

  /// No description provided for @qualityGood.
  ///
  /// In en, this message translates to:
  /// **'Good'**
  String get qualityGood;

  /// No description provided for @qualityModerate.
  ///
  /// In en, this message translates to:
  /// **'Moderate'**
  String get qualityModerate;

  /// No description provided for @qualityPoor.
  ///
  /// In en, this message translates to:
  /// **'Poor'**
  String get qualityPoor;

  /// No description provided for @qualityVeryPoor.
  ///
  /// In en, this message translates to:
  /// **'Very Poor'**
  String get qualityVeryPoor;

  /// No description provided for @switchLocation.
  ///
  /// In en, this message translates to:
  /// **'Switch location'**
  String get switchLocation;

  /// No description provided for @aiSuggestion.
  ///
  /// In en, this message translates to:
  /// **'AI Suggestion'**
  String get aiSuggestion;

  /// No description provided for @listening.
  ///
  /// In en, this message translates to:
  /// **'Listening…'**
  String get listening;

  /// No description provided for @parsing.
  ///
  /// In en, this message translates to:
  /// **'Parsing…'**
  String get parsing;

  /// No description provided for @getStarted.
  ///
  /// In en, this message translates to:
  /// **'Get started'**
  String get getStarted;

  /// No description provided for @aiChatEmptyState.
  ///
  /// In en, this message translates to:
  /// **'Ask the osprey.life assistant anything about your curtains.\nPowered by Apple Foundation Models, on-device.'**
  String get aiChatEmptyState;

  /// No description provided for @chatHeaderSubtitle.
  ///
  /// In en, this message translates to:
  /// **'On-device AI for your motorized curtains.\nType, speak, or use slash commands.'**
  String get chatHeaderSubtitle;

  /// No description provided for @daySunShort.
  ///
  /// In en, this message translates to:
  /// **'Sun.'**
  String get daySunShort;

  /// No description provided for @dayMonShort.
  ///
  /// In en, this message translates to:
  /// **'Mon.'**
  String get dayMonShort;

  /// No description provided for @dayTueShort.
  ///
  /// In en, this message translates to:
  /// **'Tues.'**
  String get dayTueShort;

  /// No description provided for @dayWedShort.
  ///
  /// In en, this message translates to:
  /// **'Wed.'**
  String get dayWedShort;

  /// No description provided for @dayThuShort.
  ///
  /// In en, this message translates to:
  /// **'Thurs.'**
  String get dayThuShort;

  /// No description provided for @dayFriShort.
  ///
  /// In en, this message translates to:
  /// **'Fri.'**
  String get dayFriShort;

  /// No description provided for @daySatShort.
  ///
  /// In en, this message translates to:
  /// **'Sat.'**
  String get daySatShort;

  /// No description provided for @dayMon.
  ///
  /// In en, this message translates to:
  /// **'Mon'**
  String get dayMon;

  /// No description provided for @dayTue.
  ///
  /// In en, this message translates to:
  /// **'Tue'**
  String get dayTue;

  /// No description provided for @dayWed.
  ///
  /// In en, this message translates to:
  /// **'Wed'**
  String get dayWed;

  /// No description provided for @dayThu.
  ///
  /// In en, this message translates to:
  /// **'Thu'**
  String get dayThu;

  /// No description provided for @dayFri.
  ///
  /// In en, this message translates to:
  /// **'Fri'**
  String get dayFri;

  /// No description provided for @daySat.
  ///
  /// In en, this message translates to:
  /// **'Sat'**
  String get daySat;

  /// No description provided for @daySun.
  ///
  /// In en, this message translates to:
  /// **'Sun'**
  String get daySun;

  /// No description provided for @accountLinkedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Account linked successfully!'**
  String get accountLinkedSuccessfully;

  /// No description provided for @linkingFailed.
  ///
  /// In en, this message translates to:
  /// **'Linking failed'**
  String get linkingFailed;

  /// No description provided for @anErrorOccurredTryAgain.
  ///
  /// In en, this message translates to:
  /// **'An error occurred. Please try again.'**
  String get anErrorOccurredTryAgain;

  /// No description provided for @signInWithAmazon.
  ///
  /// In en, this message translates to:
  /// **'Sign In With Amazon'**
  String get signInWithAmazon;

  /// No description provided for @viewMoreWaysToLink.
  ///
  /// In en, this message translates to:
  /// **'View more ways to link'**
  String get viewMoreWaysToLink;

  /// No description provided for @alreadyLinkedWithAlexa.
  ///
  /// In en, this message translates to:
  /// **'Already linked with Amazon Alexa'**
  String get alreadyLinkedWithAlexa;

  /// No description provided for @somethingWentWrong.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get somethingWentWrong;

  /// No description provided for @noAuthorizationCode.
  ///
  /// In en, this message translates to:
  /// **'No authorization code received'**
  String get noAuthorizationCode;

  /// No description provided for @couldNotOpenGoogleHome.
  ///
  /// In en, this message translates to:
  /// **'Could not open Google Home app'**
  String get couldNotOpenGoogleHome;

  /// No description provided for @reLogin.
  ///
  /// In en, this message translates to:
  /// **'Re-Login'**
  String get reLogin;

  /// No description provided for @linkWithGoogleAssistant.
  ///
  /// In en, this message translates to:
  /// **'Link with Google Assistant'**
  String get linkWithGoogleAssistant;

  /// No description provided for @linkedWithGoogleAssistant.
  ///
  /// In en, this message translates to:
  /// **'Linked with Google Assistant'**
  String get linkedWithGoogleAssistant;

  /// No description provided for @anErrorOccurred.
  ///
  /// In en, this message translates to:
  /// **'An error occurred'**
  String get anErrorOccurred;

  /// No description provided for @deleteHomeConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete \"{name}\"? This action cannot be undone.'**
  String deleteHomeConfirm(String name);

  /// No description provided for @offlineScenesBody.
  ///
  /// In en, this message translates to:
  /// **'Scenes and schedules pause until your WiFi is back. Local Bluetooth control still works for direct open/close/stop on each device.'**
  String get offlineScenesBody;

  /// No description provided for @blePairingLostBody.
  ///
  /// In en, this message translates to:
  /// **'Local Bluetooth control needs to be re-paired with this device. This usually happens after the app data was cleared or the device was factory reset.'**
  String get blePairingLostBody;

  /// No description provided for @alternateNetworkHint.
  ///
  /// In en, this message translates to:
  /// **'If the current network is unavailable, the device will be automatically connected to an alternate network.'**
  String get alternateNetworkHint;

  /// No description provided for @switchNetworkWarning.
  ///
  /// In en, this message translates to:
  /// **'The device will disconnect from its current WiFi and try to join the new one. This usually takes 5–30 seconds.'**
  String get switchNetworkWarning;

  /// No description provided for @runOnceIfNoDayPicked.
  ///
  /// In en, this message translates to:
  /// **'The action will be carried out only once if you do not select it.'**
  String get runOnceIfNoDayPicked;

  /// No description provided for @alexaUnlinkHint.
  ///
  /// In en, this message translates to:
  /// **'Disable osprey.life skill on the Amazon Alexa app or tap Me > the Setting button in the top right corner > Account and Security to unauthorize it.'**
  String get alexaUnlinkHint;

  /// No description provided for @alexaLinkExplainer.
  ///
  /// In en, this message translates to:
  /// **'Binding your app account to your Amazon account allows you to control Alexa-enabled devices through Amazon Echo speakers (ex. \"Alexa, turn on light.\")'**
  String get alexaLinkExplainer;

  /// No description provided for @chatScheduleHelp.
  ///
  /// In en, this message translates to:
  /// **'Set up automated schedules for your curtains. Open the Scenes tab to create daily, weekly, or one-time automation schedules.'**
  String get chatScheduleHelp;

  /// No description provided for @chatScenesHelp.
  ///
  /// In en, this message translates to:
  /// **'Create and manage Tap-to-Run scenes from the Scenes tab. Scenes let you chain multiple curtain actions with delays into a single tap.'**
  String get chatScenesHelp;

  /// No description provided for @googleUnlinkHint.
  ///
  /// In en, this message translates to:
  /// **'Disable osprey.life skill on the Google Home app or tap Me > the Setting button in the top right corner > Account and Security to unauthorize it.'**
  String get googleUnlinkHint;

  /// No description provided for @googleLinkExplainer.
  ///
  /// In en, this message translates to:
  /// **'After connecting your App account and Google  account, you can use Google Home Smart Speakers to control devices that work with Google Assistant.  For example, you can say, \"OK Google, please turn on  the light.\"'**
  String get googleLinkExplainer;

  /// No description provided for @deviceDisconnectedFromHome.
  ///
  /// In en, this message translates to:
  /// **'Device disconnected from home. It will return to pairing mode in 1-2 minutes.'**
  String get deviceDisconnectedFromHome;

  /// No description provided for @searchingNearbyDevices.
  ///
  /// In en, this message translates to:
  /// **'Searching for nearby Osprey devices. Make sure the device is in pairing mode.'**
  String get searchingNearbyDevices;

  /// No description provided for @looksLike5GhzHint.
  ///
  /// In en, this message translates to:
  /// **'This network looks like 5GHz — switch your phone to a 2.4GHz network, then tap refresh.'**
  String get looksLike5GhzHint;

  /// No description provided for @pairingWifiHint.
  ///
  /// In en, this message translates to:
  /// **'The device will connect to the WiFi your phone is using. Only 2.4GHz networks are supported.'**
  String get pairingWifiHint;

  /// No description provided for @siriShortcutsHelp.
  ///
  /// In en, this message translates to:
  /// **'Tap a scene to record a voice phrase, then say \"Hey Siri\" followed by that phrase to run the scene — even when the app is closed.\n\nTap a scene you already added to change its phrase or remove it.'**
  String get siriShortcutsHelp;

  /// No description provided for @deleteAccountWarning.
  ///
  /// In en, this message translates to:
  /// **'After deletion:\n• Your account will be deleted after 30 days\n• All your devices and scenes will be removed\n• You can cancel by logging in again within 30 days'**
  String get deleteAccountWarning;

  /// No description provided for @aiSuggestionBody.
  ///
  /// In en, this message translates to:
  /// **'You usually run \"{action}\" at {weekday} {hour}:00 — automate it?'**
  String aiSuggestionBody(String action, String weekday, String hour);

  /// No description provided for @removeDeviceConfirm.
  ///
  /// In en, this message translates to:
  /// **'\"{name}\" will be removed from your home and automatically return to pairing mode in about 1-2 minutes.'**
  String removeDeviceConfirm(String name);

  /// No description provided for @eraseDeviceConfirm.
  ///
  /// In en, this message translates to:
  /// **'All data for \"{name}\" will be erased and CANNOT be recovered. Are you sure?'**
  String eraseDeviceConfirm(String name);

  /// No description provided for @showInvisibleDevices.
  ///
  /// In en, this message translates to:
  /// **'Show invisible devices ({count})'**
  String showInvisibleDevices(int count);

  /// No description provided for @resetLinkSent.
  ///
  /// In en, this message translates to:
  /// **'If an account exists for {email}, a password reset link is on its way.'**
  String resetLinkSent(String email);

  /// No description provided for @signInNotAvailable.
  ///
  /// In en, this message translates to:
  /// **'{name} sign-in is not available yet.'**
  String signInNotAvailable(String name);

  /// No description provided for @resendCodeIn.
  ///
  /// In en, this message translates to:
  /// **'Resend code in {seconds}s'**
  String resendCodeIn(int seconds);

  /// No description provided for @deleteConfirmNamed.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete \"{name}\"?'**
  String deleteConfirmNamed(String name);

  /// No description provided for @taskCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 task} other{{count} tasks}}'**
  String taskCount(int count);

  /// No description provided for @featureComingSoonShort.
  ///
  /// In en, this message translates to:
  /// **'{feature} is coming soon'**
  String featureComingSoonShort(String feature);

  /// No description provided for @roomCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 Room} other{{count} Rooms}}'**
  String roomCount(int count);

  /// No description provided for @removeDevicesQ.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Remove device?} other{Remove {count} devices?}}'**
  String removeDevicesQ(int count);

  /// No description provided for @devicesRemoved.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 device removed} other{{count} devices removed}}'**
  String devicesRemoved(int count);

  /// No description provided for @deviceCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 device} other{{count} devices}}'**
  String deviceCount(int count);

  /// No description provided for @mainModuleVersion.
  ///
  /// In en, this message translates to:
  /// **'Main Module: V{version}'**
  String mainModuleVersion(String version);

  /// No description provided for @outdoorTemperatureValue.
  ///
  /// In en, this message translates to:
  /// **'Outdoor temperature: {temp}°C'**
  String outdoorTemperatureValue(int temp);

  /// No description provided for @occurrencesIn30Days.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 time in 30 days} other{{count} times in 30 days}}'**
  String occurrencesIn30Days(int count);

  /// No description provided for @sceneExecuted.
  ///
  /// In en, this message translates to:
  /// **'\"{name}\" executed'**
  String sceneExecuted(String name);

  /// No description provided for @couldNotRunScene.
  ///
  /// In en, this message translates to:
  /// **'Could not run \"{name}\". Please try again.'**
  String couldNotRunScene(String name);

  /// No description provided for @featureComingSoonNamed.
  ///
  /// In en, this message translates to:
  /// **'{feature} is coming soon.'**
  String featureComingSoonNamed(String feature);

  /// No description provided for @couldNotLoadHome.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t load your home. Please try again.'**
  String get couldNotLoadHome;

  /// No description provided for @deviceCouldNotConnectTo.
  ///
  /// In en, this message translates to:
  /// **'The device couldn\'t connect to \'{ssid}\'.\n\nReason: {reason}\n\nThe device is still on \'{stayedOn}\'.'**
  String deviceCouldNotConnectTo(String ssid, String reason, String stayedOn);

  /// No description provided for @makeSureNetworkInRange.
  ///
  /// In en, this message translates to:
  /// **'\n\nMake sure \'{ssid}\' is on and within range.'**
  String makeSureNetworkInRange(String ssid);

  /// No description provided for @noResponseFromDevice.
  ///
  /// In en, this message translates to:
  /// **'We didn\'t get a response from the device. Refresh in a moment to see its current status.'**
  String get noResponseFromDevice;

  /// No description provided for @devicesBeingAdded.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 device being added} other{{count} devices being added}}'**
  String devicesBeingAdded(int count);

  /// No description provided for @devicesAddedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 device added successfully} other{{count} devices added successfully}}'**
  String devicesAddedSuccessfully(int count);

  /// No description provided for @alexaExamplesIntro.
  ///
  /// In en, this message translates to:
  /// **'You can control Alexa-enabled devices with\nAmazon Alexa speakers, such as'**
  String get alexaExamplesIntro;

  /// No description provided for @googleExamplesIntro.
  ///
  /// In en, this message translates to:
  /// **'You can now use Google Home voicebox to\ncontrol Google Assistant devices, like'**
  String get googleExamplesIntro;

  /// No description provided for @gridView.
  ///
  /// In en, this message translates to:
  /// **'Grid View'**
  String get gridView;

  /// No description provided for @listView.
  ///
  /// In en, this message translates to:
  /// **'List View'**
  String get listView;

  /// No description provided for @deviceManagement.
  ///
  /// In en, this message translates to:
  /// **'Device Management'**
  String get deviceManagement;

  /// No description provided for @sort.
  ///
  /// In en, this message translates to:
  /// **'Sort'**
  String get sort;

  /// No description provided for @darkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get darkMode;

  /// No description provided for @followSystem.
  ///
  /// In en, this message translates to:
  /// **'Follow system'**
  String get followSystem;

  /// No description provided for @system.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get system;

  /// No description provided for @systemDarkModeHint.
  ///
  /// In en, this message translates to:
  /// **'When enabled, the app will switch the dark mode on or off to match your system settings.'**
  String get systemDarkModeHint;

  /// No description provided for @normalMode.
  ///
  /// In en, this message translates to:
  /// **'Normal Mode'**
  String get normalMode;
}

class _AppL10nDelegate extends LocalizationsDelegate<AppL10n> {
  const _AppL10nDelegate();

  @override
  Future<AppL10n> load(Locale locale) {
    return SynchronousFuture<AppL10n>(lookupAppL10n(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
    'ar',
    'de',
    'en',
    'es',
    'fr',
    'it',
    'ja',
    'ko',
    'pt',
    'ru',
    'zh',
  ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppL10nDelegate old) => false;
}

AppL10n lookupAppL10n(Locale locale) {
  // Lookup logic when language+script codes are specified.
  switch (locale.languageCode) {
    case 'zh':
      {
        switch (locale.scriptCode) {
          case 'Hant':
            return AppL10nZhHant();
        }
        break;
      }
  }

  // Lookup logic when language+country codes are specified.
  switch (locale.languageCode) {
    case 'es':
      {
        switch (locale.countryCode) {
          case '419':
            return AppL10nEs419();
        }
        break;
      }
    case 'pt':
      {
        switch (locale.countryCode) {
          case 'BR':
            return AppL10nPtBr();
        }
        break;
      }
  }

  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppL10nAr();
    case 'de':
      return AppL10nDe();
    case 'en':
      return AppL10nEn();
    case 'es':
      return AppL10nEs();
    case 'fr':
      return AppL10nFr();
    case 'it':
      return AppL10nIt();
    case 'ja':
      return AppL10nJa();
    case 'ko':
      return AppL10nKo();
    case 'pt':
      return AppL10nPt();
    case 'ru':
      return AppL10nRu();
    case 'zh':
      return AppL10nZh();
  }

  throw FlutterError(
    'AppL10n.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
