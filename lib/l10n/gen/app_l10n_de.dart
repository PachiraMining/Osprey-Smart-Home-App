// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_l10n.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppL10nDe extends AppL10n {
  AppL10nDe([String locale = 'de']) : super(locale);

  @override
  String get settingsTitle => 'Einstellungen';

  @override
  String get personalInformation => 'Persönliche Daten';

  @override
  String get accountAndSecurity => 'Konto und Sicherheit';

  @override
  String get touchToneOnPanel => 'Tastenton am Panel';

  @override
  String get aiAssistant => 'KI-Assistent';

  @override
  String get temperatureUnit => 'Temperatureinheit';

  @override
  String get about => 'Über';

  @override
  String get networkDiagnosis => 'Netzwerkdiagnose';

  @override
  String get clearCache => 'Cache löschen';

  @override
  String get language => 'Sprache';

  @override
  String get logOut => 'Abmelden';

  @override
  String get languageSystemDefault => 'Wie die Systemsprache';

  @override
  String get languageEnglish => 'Englisch';

  @override
  String get languageVietnamese => 'Vietnamesisch';

  @override
  String get clearCacheMessage =>
      'Gespeicherte Szenen, Zuhause-Daten und Bilder werden bei der nächsten Nutzung neu geladen. Ihr Konto und Ihre Geräte sind nicht betroffen.';

  @override
  String get clear => 'Löschen';

  @override
  String get cancel => 'Abbrechen';

  @override
  String freedSpace(String size) {
    return '$size freigegeben';
  }

  @override
  String aboutVersion(String version, String build) {
    return 'Version $version ($build)';
  }

  @override
  String get privacyPolicy => 'Datenschutzerklärung';

  @override
  String get termsOfService => 'Nutzungsbedingungen';

  @override
  String get bundleId => 'Bundle ID';

  @override
  String get server => 'Server';

  @override
  String get couldNotOpenLink => 'Der Link konnte nicht geöffnet werden.';

  @override
  String get diagLocalNetwork => 'Lokales Netzwerk';

  @override
  String get diagLocalNetworkNoWifi =>
      'Nicht im Wi-Fi (Mobilfunk oder Berechtigung verweigert)';

  @override
  String get diagLocalNetworkUnreadable => 'Wi-Fi-Name nicht lesbar';

  @override
  String get diagDnsLookup => 'DNS-Abfrage';

  @override
  String diagDnsFailed(String host) {
    return '$host kann nicht aufgelöst werden';
  }

  @override
  String get diagServerReachable => 'Server erreichbar';

  @override
  String diagServerLatency(String ms, String status) {
    return '$ms ms · HTTP $status';
  }

  @override
  String get diagServerNoResponse => 'Keine Antwort vom Server';

  @override
  String get diagSignedIn => 'Angemeldet';

  @override
  String get diagSessionValid => 'Sitzung gültig';

  @override
  String diagSessionInvalid(String status) {
    return 'HTTP $status — bitte erneut anmelden';
  }

  @override
  String get diagSessionUnverified => 'Sitzung nicht überprüfbar';

  @override
  String get diagControlChannel => 'Steuerkanal';

  @override
  String get diagCloudConnected => 'Cloud (MQTT) verbunden';

  @override
  String get diagBleFallback => 'Cloud offline — Bluetooth wird genutzt';

  @override
  String get diagUnreachable => 'Keine Cloud und kein Bluetooth in Reichweite';

  @override
  String get diagStatusUnknown => 'Status unbekannt';

  @override
  String get runAgain => 'Erneut prüfen';

  @override
  String get accountCreatedPleaseSignIn => 'Konto erstellt — bitte anmelden.';

  @override
  String get add => 'Hinzufügen';

  @override
  String get addCondition => 'Bedingung hinzufügen';

  @override
  String get addRoom => 'Raum hinzufügen';

  @override
  String get addTask => 'Aufgabe hinzufügen';

  @override
  String get addAtLeastTwoDevicesToAGroup =>
      'Fügen Sie mindestens zwei Geräte zu einer Gruppe hinzu.';

  @override
  String get alexa => 'Alexa';

  @override
  String get all => 'Alle';

  @override
  String get allDevices => 'Alle Geräte';

  @override
  String get alternateNetwork => 'Alternatives Netzwerk';

  @override
  String get apply => 'Übernehmen';

  @override
  String get areYouSureYouWantToLogOut => 'Möchten Sie sich wirklich abmelden?';

  @override
  String get askAboutYourCurtainsOrTryHelp =>
      'Fragen Sie zu Ihren Vorhängen oder /help…';

  @override
  String get askAboutYourCurtains => 'Fragen Sie zu Ihren Vorhängen…';

  @override
  String get atLeast6Characters => 'Mindestens 6 Zeichen';

  @override
  String get authDiagnostics => 'Auth-Diagnose';

  @override
  String get automationNotification => 'Automatisierungs-Benachrichtigung';

  @override
  String get changeRoom => 'Raum ändern';

  @override
  String get close => 'Schließen';

  @override
  String get cloud => 'Cloud';

  @override
  String get confirm => 'Bestätigen';

  @override
  String get connected => 'Verbunden';

  @override
  String get control => 'Steuerung';

  @override
  String get controlSingleDevice => 'Einzelnes Gerät steuern';

  @override
  String get copiedToClipboard => 'In die Zwischenablage kopiert';

  @override
  String get copy => 'Kopieren';

  @override
  String get couldNotChangeTheMotorDirectionPleaseTryAgai =>
      'Die Motorrichtung konnte nicht geändert werden. Bitte erneut versuchen.';

  @override
  String get couldNotConnect => 'Verbindung fehlgeschlagen';

  @override
  String get couldNotCreateTheGroupPleaseTryAgain =>
      'Die Gruppe konnte nicht erstellt werden. Bitte erneut versuchen.';

  @override
  String get couldNotOpenTheBrowser =>
      'Der Browser konnte nicht geöffnet werden.';

  @override
  String get couldNotSendTheCommandPleaseTryAgain =>
      'Der Befehl konnte nicht gesendet werden. Bitte erneut versuchen.';

  @override
  String get create => 'Erstellen';

  @override
  String get createScene => 'Szene erstellen';

  @override
  String get createAHome => 'Zuhause erstellen';

  @override
  String get createARoomFirst => 'Erstellen Sie zuerst einen Raum.';

  @override
  String get createAccount => 'Konto erstellen';

  @override
  String get createScene2 => 'Szene erstellen';

  @override
  String get curtainPosition => 'Vorhangposition';

  @override
  String get curtainPositionSetting => 'Vorhangposition einstellen';

  @override
  String get customDeviceIconsAreNotSupportedYet =>
      'Eigene Gerätesymbole werden noch nicht unterstützt.';

  @override
  String get delayTheAction => 'Aktion verzögern';

  @override
  String get delete => 'Löschen';

  @override
  String get deleteAccount => 'Konto löschen';

  @override
  String get deleteHome => 'Zuhause löschen';

  @override
  String get deleteRoom => 'Raum löschen';

  @override
  String get deleteSchedule => 'Zeitplan löschen';

  @override
  String get deleteScene => 'Szene löschen?';

  @override
  String get deleteThisSchedule => 'Diesen Zeitplan löschen?';

  @override
  String get deviceNetwork => 'Gerätenetzwerk';

  @override
  String get deviceHasNoProfileInformation => 'Gerät hat keine Profildaten';

  @override
  String get deviceIsOffline => 'Gerät ist offline';

  @override
  String get deviceIsReady => 'Gerät ist bereit.';

  @override
  String get deviceName => 'Gerätename';

  @override
  String get deviceRemovedFromHome => 'Gerät aus dem Zuhause entfernt.';

  @override
  String get deviceUnreachable => 'Gerät nicht erreichbar';

  @override
  String get devices => 'Geräte';

  @override
  String get disconnect => 'Trennen';

  @override
  String get disconnectDevice => 'Gerät trennen?';

  @override
  String get done => 'Fertig';

  @override
  String get emailAddress => 'E-Mail-Adresse';

  @override
  String get emailOrUsername => 'E-Mail oder Benutzername';

  @override
  String get enterAGroupName => 'Gruppennamen eingeben';

  @override
  String get enterANote => 'Notiz eingeben';

  @override
  String get enterDeviceName => 'Gerätenamen eingeben';

  @override
  String get enterHomeName => 'Namen des Zuhauses eingeben';

  @override
  String get enterName => 'Namen eingeben';

  @override
  String get enterSceneName => 'Szenennamen eingeben';

  @override
  String get enterValue => 'Wert eingeben...';

  @override
  String get enterYourPassword => 'Passwort eingeben';

  @override
  String get eraseDeviceData => 'Gerätedaten löschen?';

  @override
  String get error => 'Fehler';

  @override
  String get executedBy => 'Ausgeführt von';

  @override
  String get executionTime => 'Ausführungszeit';

  @override
  String get faqFeedback => 'FAQ & Feedback';

  @override
  String get failed => 'Fehlgeschlagen';

  @override
  String get featureComingSoon => 'Funktion folgt bald';

  @override
  String get firmware => 'Firmware';

  @override
  String get firmwareUpdateIsComingSoon => 'Firmware-Update folgt bald.';

  @override
  String get firstName => 'Vorname';

  @override
  String get firstNameOptional => 'Vorname (optional)';

  @override
  String get goBack => 'Zurück';

  @override
  String get googleAssistant => 'Google Assistant';

  @override
  String get gotIt => 'Verstanden';

  @override
  String get groupName => 'Gruppenname';

  @override
  String get help => 'Hilfe';

  @override
  String get homeManagement => 'Zuhause-Verwaltung';

  @override
  String get homeName => 'Name des Zuhauses';

  @override
  String get homeName2 => 'Name des Zuhauses';

  @override
  String get icon => 'Symbol';

  @override
  String get conditionIf => 'Wenn';

  @override
  String get joinAHome => 'Zuhause beitreten';

  @override
  String get joiningAHomeByInviteIsComingSoon =>
      'Der Beitritt per Einladung folgt bald.';

  @override
  String get lastName => 'Nachname';

  @override
  String get lastNameOptional => 'Nachname (optional)';

  @override
  String get later => 'Später';

  @override
  String get launchTapToRun => 'Tap-to-Run starten';

  @override
  String get localAssociation => 'Lokale Verknüpfung';

  @override
  String get localControlOffline => 'Lokale Steuerung (offline)';

  @override
  String get location => 'Standort';

  @override
  String get logCopiedToClipboard => 'Protokoll in die Zwischenablage kopiert';

  @override
  String get logs => 'Protokolle';

  @override
  String get manage => 'Verwalten';

  @override
  String get managePermissions => 'Berechtigungen verwalten';

  @override
  String get markAllAsRead => 'Alle als gelesen markieren';

  @override
  String get moreSettings => 'Weitere Einstellungen';

  @override
  String get motorDirection => 'Motorrichtung';

  @override
  String get moveToTop => 'Nach oben';

  @override
  String get moveToRoom => 'In Raum verschieben';

  @override
  String get moved => 'Verschoben';

  @override
  String get movedToTop => 'Nach oben verschoben';

  @override
  String get name => 'Name';

  @override
  String get next => 'Weiter';

  @override
  String get noDevicesAvailable => 'Keine Geräte verfügbar';

  @override
  String get noDevicesFound => 'Keine Geräte gefunden.';

  @override
  String get noDevicesInThisHome => 'Keine Geräte in diesem Zuhause.';

  @override
  String get noDevicesYet => 'Noch keine Geräte';

  @override
  String get noFunctionsAvailable => 'Keine Funktionen verfügbar';

  @override
  String get noHomeSelectedPleaseTryAgain =>
      'Kein Zuhause ausgewählt, bitte erneut versuchen';

  @override
  String get noMatchingTimeZones => 'Keine passenden Zeitzonen';

  @override
  String get noOtherScenesAvailable => 'Keine weiteren Szenen verfügbar';

  @override
  String get noRooms => 'Keine Räume';

  @override
  String get noSavedNetworksYet => 'Noch keine gespeicherten Netzwerke.';

  @override
  String get noScenes => 'Keine Szenen';

  @override
  String get noScenesAvailable => 'Keine Szenen verfügbar';

  @override
  String get note => 'Notiz';

  @override
  String get notification => 'Benachrichtigung';

  @override
  String get ok => 'OK';

  @override
  String get offlineNotification => 'Offline-Benachrichtigung';

  @override
  String get open => 'Öffnen';

  @override
  String get openSettings => 'Einstellungen öffnen';

  @override
  String get outdoorPm25 => 'PM2.5 außen';

  @override
  String get outdoorAirPressure => 'Luftdruck außen';

  @override
  String get outdoorHumidity => 'Luftfeuchtigkeit außen';

  @override
  String get outdoorWindSpeed => 'Windgeschwindigkeit außen';

  @override
  String get pairingSuccessful => 'Kopplung erfolgreich';

  @override
  String get password => 'Passwort';

  @override
  String get sessionExpiredSignInAgain =>
      'Sitzung abgelaufen. Bitte erneut anmelden.';

  @override
  String get pleaseAddAtLeast1Action => 'Bitte mindestens 1 Aktion hinzufügen';

  @override
  String get pleaseAddAtLeast1Condition =>
      'Bitte mindestens 1 Bedingung hinzufügen';

  @override
  String get pleaseEnterAName => 'Bitte einen Namen eingeben';

  @override
  String get pleaseEnterASceneName => 'Bitte einen Szenennamen eingeben';

  @override
  String get pleaseSelectAFunction => 'Bitte eine Funktion auswählen';

  @override
  String get pleaseSelectATime0 => 'Bitte eine Zeit > 0 auswählen';

  @override
  String get rePairNow => 'Jetzt neu koppeln';

  @override
  String get rePairRequired => 'Neukopplung erforderlich';

  @override
  String get reasonOptional => 'Grund (optional)';

  @override
  String get refresh => 'Aktualisieren';

  @override
  String get reload => 'Neu laden';

  @override
  String get remove => 'Entfernen';

  @override
  String get removeDevice => 'Gerät entfernen';

  @override
  String get removed => 'Entfernt';

  @override
  String get rename => 'Umbenennen';

  @override
  String get renameRoom => 'Raum umbenennen';

  @override
  String get renameDevice => 'Gerät umbenennen';

  @override
  String get repeat => 'Wiederholen';

  @override
  String get rescan => 'Neu suchen';

  @override
  String get retry => 'Wiederholen';

  @override
  String get roomManagement => 'Raumverwaltung';

  @override
  String get roomName => 'Raumname';

  @override
  String get roomUpdated => 'Raum aktualisiert';

  @override
  String get running => 'Läuft';

  @override
  String get save => 'Speichern';

  @override
  String get sceneName => 'Szenenname';

  @override
  String get scenes => 'Szenen';

  @override
  String get schedule => 'Zeitplan';

  @override
  String get searchAddress => 'Adresse suchen';

  @override
  String get searchCityOrRegion => 'Stadt oder Region suchen';

  @override
  String get selectScene => 'Szene auswählen';

  @override
  String get selectSmartScenes => 'Smarte Szenen auswählen';

  @override
  String get sendResetLink => 'Reset-Link senden';

  @override
  String get sendVerificationCode => 'Bestätigungscode senden';

  @override
  String get showOnHomePage => 'Auf Startseite zeigen';

  @override
  String get signIn => 'Anmelden';

  @override
  String get signalStrength => 'Signalstärke';

  @override
  String get signalStrength2 => 'Signalstärke';

  @override
  String get startPairing => 'Kopplung starten';

  @override
  String get stop => 'Stopp';

  @override
  String get style => 'Stil';

  @override
  String get switchNetwork => 'Wechseln';

  @override
  String get switchToThisNetwork => 'Zu diesem Netzwerk wechseln';

  @override
  String get tapToRunNotification => 'Tap-to-Run-Benachrichtigung';

  @override
  String get conditionThen => 'Dann';

  @override
  String get thinking => 'Denkt nach…';

  @override
  String get thisActionCannotBeUndone =>
      'Diese Aktion kann nicht rückgängig gemacht werden.';

  @override
  String get thisSavedNetworkWillBeRemovedFromTheDevice =>
      'Dieses gespeicherte Netzwerk wird vom Gerät entfernt.';

  @override
  String get timeZone => 'Zeitzone';

  @override
  String get timeZoneUpdated => 'Zeitzone aktualisiert';

  @override
  String get timedOut => 'Zeitüberschreitung';

  @override
  String get tryAgain => 'Erneut versuchen';

  @override
  String get useCurrentLocation => 'Aktuellen Standort verwenden';

  @override
  String get usingSiri => 'Siri verwenden';

  @override
  String get virtualId => 'Virtuelle ID';

  @override
  String get whenDeviceStatusChanges => 'Wenn sich der Gerätestatus ändert';

  @override
  String get whenWeatherChanges => 'Wenn sich das Wetter ändert';

  @override
  String get wiFi => 'Wi-Fi';

  @override
  String get wifiNameSsid => 'WiFi-Name (SSID)';

  @override
  String get wifiPassword => 'WiFi-Passwort';

  @override
  String get navHome => 'Start';

  @override
  String get navScenes => 'Szenen';

  @override
  String get navChat => 'Chat';

  @override
  String get navMe => 'Ich';

  @override
  String get thirdPartyServices => 'Drittanbieter-Dienste';

  @override
  String get messageCenter => 'Nachrichten';

  @override
  String get appMall => 'App-Shop';

  @override
  String get addDevice => 'Gerät hinzufügen';

  @override
  String get tapToRun => 'Ein-Tipp-Ausführung';

  @override
  String get automationEmptyHint =>
      'Automatisierung spart Zeit und Aufwand, indem sie Routineaufgaben übernimmt.';

  @override
  String get tapToRunEmptyHint =>
      'Erstelle eine Ein-Tipp-Szene, um deine Geräte mit einem einzigen Tippen zu steuern.';

  @override
  String get scene => 'Szene';

  @override
  String get executionFailed => 'Ausführung fehlgeschlagen';

  @override
  String get device => 'Gerät';

  @override
  String get delay => 'Wartezeit';

  @override
  String get runScene => 'Szene ausführen';

  @override
  String get addToSiri => 'Zu Siri hinzufügen';

  @override
  String get storeUnderPreparation =>
      'Der Shop wird gerade vorbereitet, bleib dran.';

  @override
  String get commonFunctions => 'Häufige Funktionen';

  @override
  String get noConnection => 'Keine Verbindung';

  @override
  String get checkInternetAndRetry =>
      'Prüfe deine Internetverbindung und versuche es erneut.';

  @override
  String get noConnectionCheckInternet =>
      'Keine Verbindung. Prüfe dein Internet und versuche es erneut.';

  @override
  String get addFirstCurtainHint =>
      'Tippe auf +, um deinen ersten Vorhang zu diesem Zuhause hinzuzufügen.';

  @override
  String get hideInvisibleDevices => 'Nicht sichtbare Geräte ausblenden';

  @override
  String get deviceRenamed => 'Gerät umbenannt.';

  @override
  String get deviceDeletedReturningToPairing =>
      'Gerät gelöscht. Es wechselt zurück in den Kopplungsmodus.';

  @override
  String get homeSettings => 'Zuhause-Einstellungen';

  @override
  String get toBeSet => 'Noch festzulegen';

  @override
  String get homeMember => 'Mitglied';

  @override
  String get memberDetails => 'Mitgliedsdetails';

  @override
  String get addMember => 'Mitglied hinzufügen';

  @override
  String get pending => 'Ausstehend';

  @override
  String get removesFromHomeHint =>
      'Entfernt aus dem Zuhause; das Gerät wechselt in 1-2 Minuten in den Kopplungsmodus';

  @override
  String get unlinkAndEraseData => 'Verknüpfung lösen und Daten löschen';

  @override
  String get erasesAllDataHint =>
      'Löscht alle Daten, kann nicht widerrufen werden';

  @override
  String get somethingWentWrongTryAgain =>
      'Etwas ist schiefgelaufen, bitte erneut versuchen';

  @override
  String get tapToRunAndAutomation => 'Ein-Tipp-Ausführung und Automatisierung';

  @override
  String get thirdPartyControl => 'Steuerung über Drittanbieter';

  @override
  String get deviceOfflineNotification => 'Benachrichtigung bei offline';

  @override
  String get others => 'Sonstiges';

  @override
  String get shareDevice => 'Gerät teilen';

  @override
  String get addToHomeScreen => 'Zum Home-Bildschirm';

  @override
  String get checkDeviceNetwork => 'Gerätenetzwerk prüfen';

  @override
  String get checkNow => 'Jetzt prüfen';

  @override
  String get deviceUpdate => 'Geräte-Update';

  @override
  String get removeDevicesWarning =>
      'Sie werden aus diesem Zuhause entfernt und wechseln in den Kopplungsmodus.';

  @override
  String get shown => 'Sichtbar';

  @override
  String get hidden => 'Ausgeblendet';

  @override
  String get devicesBackOnHome => 'Geräte sind wieder auf der Startseite';

  @override
  String get hiddenFromHome => 'Von der Startseite ausgeblendet';

  @override
  String get offline => 'Offline';

  @override
  String get show => 'Anzeigen';

  @override
  String get hide => 'Ausblenden';

  @override
  String get profilePhoto => 'Profilbild';

  @override
  String get nickname => 'Anzeigename';

  @override
  String get noRoomsYet => 'Noch keine Räume';

  @override
  String get tapPlusToAddRoom => 'Tippe auf +, um einen Raum hinzuzufügen';

  @override
  String get emailAddressLabel => 'E-Mail-Adresse';

  @override
  String get notSet => 'Nicht festgelegt';

  @override
  String get deviceInformation => 'Geräteinformationen';

  @override
  String get unknown => 'Unbekannt';

  @override
  String get notReported => 'Nicht gemeldet';

  @override
  String get noScenesUseThisDevice => 'Noch keine Szene nutzt dieses Gerät.';

  @override
  String get tapToRunLabel => 'Ein-Tipp-Ausführung';

  @override
  String get automation => 'Automatisierung';

  @override
  String get forward => 'Vorwärts';

  @override
  String get back => 'Rückwärts';

  @override
  String get setting => 'Einstellung';

  @override
  String get updateAvailable => 'Update verfügbar';

  @override
  String get noUpdatesAvailable => 'Keine Updates verfügbar';

  @override
  String get updateNow => 'Jetzt aktualisieren';

  @override
  String get unassigned => 'Nicht zugewiesen';

  @override
  String get enterEmailOrUsername => 'E-Mail oder Benutzernamen eingeben';

  @override
  String get welcome => 'Willkommen';

  @override
  String get signInSubtitle => 'Melde dich bei deinem osprey.life-Konto an.';

  @override
  String get createOne => 'Konto erstellen';

  @override
  String get forgotPassword => 'Passwort vergessen?';

  @override
  String get orContinueWith => 'oder fortfahren mit';

  @override
  String get enterValidEmail => 'Gib eine gültige E-Mail-Adresse ein';

  @override
  String get resetYourPassword => 'Passwort zurücksetzen';

  @override
  String get checkYourInbox => 'Sieh in deinem Postfach nach';

  @override
  String get enterYourEmailAddress => 'E-Mail-Adresse eingeben';

  @override
  String get enterSixDigitCode => '6-stelligen Code eingeben';

  @override
  String get enterAPassword => 'Passwort eingeben';

  @override
  String get createYourAccount => 'Konto erstellen';

  @override
  String get checkYourEmail => 'Sieh in deinen E-Mails nach';

  @override
  String get resendCode => 'Code erneut senden';

  @override
  String get userAgreement => 'Nutzungsbedingungen';

  @override
  String get reconnecting => 'Verbindung wird wiederhergestellt…';

  @override
  String get checkWifiOrBluetooth =>
      'Prüfe das WLAN oder geh für Bluetooth näher heran.';

  @override
  String get smartScenesRequireInternet => 'Smarte Szenen benötigen Internet';

  @override
  String get enterWifiName => 'WLAN-Namen eingeben';

  @override
  String get wifiNameLengthError => 'Der WLAN-Name muss 1–32 Zeichen lang sein';

  @override
  String get passwordMin8 => 'Das Passwort muss mindestens 8 Zeichen lang sein';

  @override
  String get passwordLength863 => 'Das Passwort muss 8–63 Zeichen lang sein';

  @override
  String get networkAlreadySaved =>
      'Dieses Netzwerk ist bereits gespeichert. Um das Passwort zu ändern, lösche es und füge es erneut hinzu.';

  @override
  String get addWifiNetwork => 'WLAN-Netzwerk hinzufügen';

  @override
  String get atLeast8Characters => 'Mindestens 8 Zeichen';

  @override
  String get only24GhzSupported =>
      'Vorhanggeräte unterstützen nur 2,4-GHz-WLAN (WPA2).';

  @override
  String get labelOptional => 'Bezeichnung (optional)';

  @override
  String get createGroup => 'Gruppe erstellen';

  @override
  String get groupControlHint =>
      'Geräte in derselben Gruppe können gemeinsam gesteuert werden.';

  @override
  String get devicesToBeAdded => 'Hinzuzufügende Geräte';

  @override
  String get noSameTypeDevices =>
      'Keine weiteren Geräte desselben Typs in diesem Zuhause.';

  @override
  String get couldNotLoadNetworkDetails =>
      'Netzwerkdetails konnten nicht geladen werden. Zum Aktualisieren ziehen.';

  @override
  String get alreadyOnThisNetwork => 'Bereits mit diesem Netzwerk verbunden.';

  @override
  String get deviceOfflineTryLater =>
      'Das Gerät ist offline – bitte später erneut versuchen.';

  @override
  String get wrongPassword => 'Falsches Passwort';

  @override
  String get networkNotFound => 'Netzwerk nicht gefunden';

  @override
  String get networkRemoved => 'Netzwerk entfernt.';

  @override
  String get network => 'Netzwerk';

  @override
  String get connectedTo => 'Verbunden mit';

  @override
  String get savedNetworks => 'Gespeicherte Netzwerke';

  @override
  String get addANetwork => 'Netzwerk hinzufügen';

  @override
  String get notConnected => 'Nicht verbunden';

  @override
  String get pleaseKeepAppOpen => 'Bitte lass die App geöffnet.';

  @override
  String get deviceNetworkInformation => 'Netzwerkinformationen des Geräts';

  @override
  String get once => 'Einmalig';

  @override
  String get editSchedule => 'Zeitplan bearbeiten';

  @override
  String get addSchedule => 'Zeitplan hinzufügen';

  @override
  String get timeVarianceHint => 'Die Zeitabweichung beträgt ±30 s';

  @override
  String get noTimerData => 'Keine Timer-Daten';

  @override
  String get localControlUnsupportedAction =>
      'Die lokale Steuerung unterstützt diese Aktion nicht';

  @override
  String get noInternetNoBluetooth =>
      'Kein Internet und Bluetooth außer Reichweite';

  @override
  String get connectionError => 'Verbindungsfehler';

  @override
  String get exampleTapToRun =>
      'Beispiel: alle Lichter im Schlafzimmer mit einem Tippen ausschalten.';

  @override
  String get exampleWeather =>
      'Beispiel: wenn die lokale Temperatur über 28 °C liegt.';

  @override
  String get weatherTrigger => 'Wetter-Auslöser';

  @override
  String get exampleSchedule => 'Beispiel: jeden Morgen um 7:00.';

  @override
  String get exampleDeviceStatus =>
      'Beispiel: wenn eine ungewöhnliche Aktivität erkannt wird.';

  @override
  String get deviceStatusTrigger => 'Gerätestatus-Auslöser';

  @override
  String get noNotificationsYet => 'Noch keine Benachrichtigungen';

  @override
  String get slashCommands => 'Slash-Befehle';

  @override
  String get slashDevicesHint => 'Vorhänge ansehen und steuern.';

  @override
  String get slashSceneHint => 'Eine Ein-Tipp-Szene ausführen.';

  @override
  String get slashScheduleHint => 'Den Automatisierungszeitplan öffnen.';

  @override
  String get slashHelpHint => 'Diese Liste anzeigen.';

  @override
  String get youCanAlsoSpeak =>
      'Du kannst auch sprechen – tippe auf das Mikrofon.';

  @override
  String get chatInputHint => 'Tippen, sprechen oder Slash-Befehle nutzen.';

  @override
  String get online => 'Online';

  @override
  String get blePermissionRequired =>
      'Zum Finden von Geräten ist die Bluetooth-Berechtigung erforderlich';

  @override
  String get bleAndLocationPermissionRequired =>
      'Zum Finden von Geräten sind Bluetooth- und Standortberechtigungen erforderlich';

  @override
  String get addDeviceLower => 'Gerät hinzufügen';

  @override
  String get scanningStopped => 'Suche beendet.';

  @override
  String get enterWifiPassword => 'WLAN-Passwort eingeben';

  @override
  String get detectingCurrentWifi => 'Aktuelles WLAN wird erkannt...';

  @override
  String get autoDetectedWifi =>
      'Automatisch vom WLAN übernommen, mit dem dein Telefon verbunden ist';

  @override
  String get couldNotDetectWifi =>
      'WLAN konnte nicht erkannt werden – gib den Netzwerknamen manuell ein';

  @override
  String get beingAdded => 'Wird hinzugefügt';

  @override
  String get addedSuccessfully => 'Erfolgreich hinzugefügt';

  @override
  String get pairingFailed => 'Kopplung fehlgeschlagen';

  @override
  String get allDay => 'Ganztägig';

  @override
  String get whenAnyConditionMet => 'Wenn eine Bedingung erfüllt ist';

  @override
  String get whenAllConditionsMet => 'Wenn alle Bedingungen erfüllt sind';

  @override
  String get deleteSceneWarning =>
      'Nach dem Löschen des Szenarios können die Gerätaufgaben nicht mehr korrekt ausgeführt werden.';

  @override
  String get toggleAutomation => 'Automatisierung umschalten';

  @override
  String get enable => 'Aktivieren';

  @override
  String get disable => 'Deaktivieren';

  @override
  String get everyDay => 'Täglich';

  @override
  String get monToFri => 'Mo - Fr';

  @override
  String get satToSun => 'Sa - So';

  @override
  String get runOnceIfNoDaySelected =>
      'Die Aktion wird nur einmal ausgeführt, wenn du keinen Wochentag auswählst.';

  @override
  String get sendNotification => 'Benachrichtigung senden';

  @override
  String get color => 'Farbe';

  @override
  String get wait => 'Warten';

  @override
  String get finish => 'Fertig';

  @override
  String get selectFunction => 'Funktion auswählen';

  @override
  String get on => 'Ein';

  @override
  String get off => 'Aus';

  @override
  String get siriShortcut => 'Siri-Kurzbefehl';

  @override
  String get createTapToRunFirst => 'Erstelle zuerst eine Ein-Tipp-Szene.';

  @override
  String get poweredByFoundationModels =>
      'Mit Apple Foundation Models, direkt auf dem Gerät.';

  @override
  String get weatherClearNight => 'Klare Nacht';

  @override
  String get weatherSunny => 'Sonnig';

  @override
  String get weatherPartlyCloudy => 'Teils bewölkt';

  @override
  String get weatherCloudy => 'Bewölkt';

  @override
  String get qualityExcellent => 'Sehr gut';

  @override
  String get qualityGood => 'Gut';

  @override
  String get qualityModerate => 'Mittel';

  @override
  String get qualityPoor => 'Schlecht';

  @override
  String get qualityVeryPoor => 'Sehr schlecht';

  @override
  String get switchLocation => 'Ort wechseln';

  @override
  String get aiSuggestion => 'KI-Vorschlag';

  @override
  String get listening => 'Hört zu…';

  @override
  String get parsing => 'Wird ausgewertet…';

  @override
  String get getStarted => 'Los geht\'s';

  @override
  String get aiChatEmptyState =>
      'Frag den osprey.life-Assistenten alles über deine Vorhänge.\nMit Apple Foundation Models, direkt auf dem Gerät.';

  @override
  String get chatHeaderSubtitle =>
      'KI auf dem Gerät für deine motorisierten Vorhänge.\nTippen, sprechen oder Slash-Befehle nutzen.';

  @override
  String get daySunShort => 'So.';

  @override
  String get dayMonShort => 'Mo.';

  @override
  String get dayTueShort => 'Di.';

  @override
  String get dayWedShort => 'Mi.';

  @override
  String get dayThuShort => 'Do.';

  @override
  String get dayFriShort => 'Fr.';

  @override
  String get daySatShort => 'Sa.';

  @override
  String get dayMon => 'Mo';

  @override
  String get dayTue => 'Di';

  @override
  String get dayWed => 'Mi';

  @override
  String get dayThu => 'Do';

  @override
  String get dayFri => 'Fr';

  @override
  String get daySat => 'Sa';

  @override
  String get daySun => 'So';

  @override
  String get accountLinkedSuccessfully => 'Konto erfolgreich verknüpft!';

  @override
  String get linkingFailed => 'Verknüpfung fehlgeschlagen';

  @override
  String get anErrorOccurredTryAgain =>
      'Ein Fehler ist aufgetreten. Bitte versuche es erneut.';

  @override
  String get signInWithAmazon => 'Mit Amazon anmelden';

  @override
  String get viewMoreWaysToLink => 'Weitere Verknüpfungsmöglichkeiten';

  @override
  String get alreadyLinkedWithAlexa => 'Bereits mit Amazon Alexa verknüpft';

  @override
  String get somethingWentWrong => 'Etwas ist schiefgelaufen';

  @override
  String get noAuthorizationCode => 'Kein Autorisierungscode erhalten';

  @override
  String get couldNotOpenGoogleHome =>
      'Google Home-App konnte nicht geöffnet werden';

  @override
  String get reLogin => 'Erneut anmelden';

  @override
  String get linkWithGoogleAssistant => 'Mit Google Assistant verknüpfen';

  @override
  String get linkedWithGoogleAssistant => 'Mit Google Assistant verknüpft';

  @override
  String get anErrorOccurred => 'Ein Fehler ist aufgetreten';

  @override
  String deleteHomeConfirm(String name) {
    return 'Möchtest du „$name“ wirklich löschen? Diese Aktion kann nicht widerrufen werden.';
  }

  @override
  String get offlineScenesBody =>
      'Szenen und Zeitpläne pausieren, bis dein WLAN wieder da ist. Die lokale Bluetooth-Steuerung funktioniert weiterhin, um jedes Gerät direkt zu öffnen, zu schließen oder zu stoppen.';

  @override
  String get blePairingLostBody =>
      'Die lokale Bluetooth-Steuerung muss mit diesem Gerät neu gekoppelt werden. Das passiert meist, nachdem die App-Daten gelöscht oder das Gerät auf Werkseinstellungen zurückgesetzt wurde.';

  @override
  String get alternateNetworkHint =>
      'Ist das aktuelle Netzwerk nicht verfügbar, verbindet sich das Gerät automatisch mit einem Ersatznetzwerk.';

  @override
  String get switchNetworkWarning =>
      'Das Gerät trennt sich vom aktuellen WLAN und versucht, dem neuen beizutreten. Das dauert meist 5–30 Sekunden.';

  @override
  String get runOnceIfNoDayPicked =>
      'Die Aktion wird nur einmal ausgeführt, wenn du sie nicht auswählst.';

  @override
  String get alexaUnlinkHint =>
      'Deaktiviere den osprey.life-Skill in der Amazon Alexa-App oder tippe auf Ich > die Einstellungen-Schaltfläche oben rechts > Konto und Sicherheit, um die Autorisierung zu entziehen.';

  @override
  String get alexaLinkExplainer =>
      'Wenn du dein App-Konto mit deinem Amazon-Konto verknüpfst, kannst du Alexa-fähige Geräte über Amazon Echo-Lautsprecher steuern (z. B. „Alexa, turn on light.“)';

  @override
  String get chatScheduleHelp =>
      'Richte automatische Zeitpläne für deine Vorhänge ein. Öffne den Tab „Szenen“, um tägliche, wöchentliche oder einmalige Automatisierungen zu erstellen.';

  @override
  String get chatScenesHelp =>
      'Erstelle und verwalte Ein-Tipp-Szenen im Tab „Szenen“. Szenen verketten mehrere Vorhangaktionen mit Wartezeiten zu einem einzigen Tippen.';

  @override
  String get googleUnlinkHint =>
      'Deaktiviere den osprey.life-Skill in der Google Home-App oder tippe auf Ich > die Einstellungen-Schaltfläche oben rechts > Konto und Sicherheit, um die Autorisierung zu entziehen.';

  @override
  String get googleLinkExplainer =>
      'Nachdem du dein App-Konto und dein Google-Konto verbunden hast, kannst du Google Home-Lautsprecher nutzen, um Geräte zu steuern, die mit Google Assistant funktionieren. Du kannst zum Beispiel sagen: „OK Google, please turn on the light.“';

  @override
  String get deviceDisconnectedFromHome =>
      'Gerät vom Zuhause getrennt. Es wechselt in 1-2 Minuten in den Kopplungsmodus.';

  @override
  String get searchingNearbyDevices =>
      'Suche nach Osprey-Geräten in der Nähe. Stelle sicher, dass das Gerät im Kopplungsmodus ist.';

  @override
  String get looksLike5GhzHint =>
      'Dieses Netzwerk scheint 5 GHz zu sein – wechsle dein Telefon zu einem 2,4-GHz-Netzwerk und tippe dann auf Aktualisieren.';

  @override
  String get pairingWifiHint =>
      'Das Gerät verbindet sich mit dem WLAN, das dein Telefon nutzt. Es werden nur 2,4-GHz-Netzwerke unterstützt.';

  @override
  String get siriShortcutsHelp =>
      'Tippe auf eine Szene, um einen Sprachbefehl aufzunehmen. Sag dann „Hey Siri“ und diesen Satz, um die Szene auszuführen – auch bei geschlossener App.\n\nTippe auf eine bereits hinzugefügte Szene, um ihren Satz zu ändern oder sie zu entfernen.';

  @override
  String get deleteAccountWarning =>
      'Nach der Löschung:\n• Dein Konto wird nach 30 Tagen gelöscht\n• Alle deine Geräte und Szenen werden entfernt\n• Du kannst dies abbrechen, indem du dich innerhalb von 30 Tagen erneut anmeldest';

  @override
  String aiSuggestionBody(String action, String weekday, String hour) {
    return 'Du führst „$action“ meist am $weekday um $hour:00 aus – automatisieren?';
  }

  @override
  String removeDeviceConfirm(String name) {
    return '„$name“ wird aus deinem Zuhause entfernt und wechselt nach etwa 1-2 Minuten automatisch in den Kopplungsmodus.';
  }

  @override
  String eraseDeviceConfirm(String name) {
    return 'Alle Daten von „$name“ werden gelöscht und können NICHT wiederhergestellt werden. Bist du sicher?';
  }

  @override
  String showInvisibleDevices(int count) {
    return 'Nicht sichtbare Geräte anzeigen ($count)';
  }

  @override
  String resetLinkSent(String email) {
    return 'Falls ein Konto für $email existiert, ist ein Link zum Zurücksetzen des Passworts auf dem Weg.';
  }

  @override
  String signInNotAvailable(String name) {
    return 'Die Anmeldung mit $name ist noch nicht verfügbar.';
  }

  @override
  String resendCodeIn(int seconds) {
    return 'Code in $seconds s erneut senden';
  }

  @override
  String deleteConfirmNamed(String name) {
    return 'Möchtest du „$name“ wirklich löschen?';
  }

  @override
  String taskCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Aufgaben',
      one: '1 Aufgabe',
    );
    return '$_temp0';
  }

  @override
  String featureComingSoonShort(String feature) {
    return '$feature folgt bald';
  }

  @override
  String roomCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Räume',
      one: '1 Raum',
    );
    return '$_temp0';
  }

  @override
  String removeDevicesQ(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Geräte entfernen?',
      one: 'Gerät entfernen?',
    );
    return '$_temp0';
  }

  @override
  String devicesRemoved(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Geräte entfernt',
      one: '1 Gerät entfernt',
    );
    return '$_temp0';
  }

  @override
  String deviceCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Geräte',
      one: '1 Gerät',
    );
    return '$_temp0';
  }

  @override
  String mainModuleVersion(String version) {
    return 'Hauptmodul: V$version';
  }

  @override
  String outdoorTemperatureValue(int temp) {
    return 'Außentemperatur: $temp °C';
  }

  @override
  String occurrencesIn30Days(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Mal in 30 Tagen',
      one: '1 Mal in 30 Tagen',
    );
    return '$_temp0';
  }

  @override
  String sceneExecuted(String name) {
    return '„$name“ ausgeführt';
  }

  @override
  String couldNotRunScene(String name) {
    return '„$name“ konnte nicht ausgeführt werden. Bitte versuche es erneut.';
  }

  @override
  String featureComingSoonNamed(String feature) {
    return '$feature folgt bald.';
  }

  @override
  String get couldNotLoadHome =>
      'Dein Zuhause konnte nicht geladen werden. Bitte versuche es erneut.';

  @override
  String deviceCouldNotConnectTo(String ssid, String reason, String stayedOn) {
    return 'Das Gerät konnte sich nicht mit „$ssid“ verbinden.\n\nGrund: $reason\n\nDas Gerät ist weiterhin mit „$stayedOn“ verbunden.';
  }

  @override
  String makeSureNetworkInRange(String ssid) {
    return '\n\nStelle sicher, dass „$ssid“ eingeschaltet und in Reichweite ist.';
  }

  @override
  String get noResponseFromDevice =>
      'Wir haben keine Antwort vom Gerät erhalten. Aktualisiere in einem Moment, um den aktuellen Status zu sehen.';

  @override
  String devicesBeingAdded(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Geräte werden hinzugefügt',
      one: '1 Gerät wird hinzugefügt',
    );
    return '$_temp0';
  }

  @override
  String devicesAddedSuccessfully(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Geräte erfolgreich hinzugefügt',
      one: '1 Gerät erfolgreich hinzugefügt',
    );
    return '$_temp0';
  }

  @override
  String get alexaExamplesIntro =>
      'Mit Amazon Alexa-Lautsprechern kannst du\nAlexa-fähige Geräte steuern, zum Beispiel';

  @override
  String get googleExamplesIntro =>
      'Du kannst jetzt den Google Home-Lautsprecher nutzen, um\nGoogle Assistant-Geräte zu steuern, etwa';

  @override
  String get gridView => 'Rasteransicht';

  @override
  String get listView => 'Listenansicht';

  @override
  String get deviceManagement => 'Geräteverwaltung';

  @override
  String get sort => 'Sortieren';

  @override
  String get darkMode => 'Dunkelmodus';

  @override
  String get followSystem => 'Systemeinstellung folgen';

  @override
  String get system => 'System';

  @override
  String get systemDarkModeHint =>
      'Wenn aktiviert, schaltet die App den Dunkelmodus passend zu deinen Systemeinstellungen ein oder aus.';

  @override
  String get normalMode => 'Normaler Modus';
}
