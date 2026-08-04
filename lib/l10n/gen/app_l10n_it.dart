// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_l10n.dart';

// ignore_for_file: type=lint

/// The translations for Italian (`it`).
class AppL10nIt extends AppL10n {
  AppL10nIt([String locale = 'it']) : super(locale);

  @override
  String get settingsTitle => 'Impostazioni';

  @override
  String get personalInformation => 'Informazioni personali';

  @override
  String get accountAndSecurity => 'Account e sicurezza';

  @override
  String get touchToneOnPanel => 'Suono tasti sul pannello';

  @override
  String get aiAssistant => 'Assistente AI';

  @override
  String get temperatureUnit => 'Unità di temperatura';

  @override
  String get about => 'Informazioni';

  @override
  String get networkDiagnosis => 'Diagnosi di rete';

  @override
  String get clearCache => 'Svuota cache';

  @override
  String get language => 'Lingua';

  @override
  String get logOut => 'Esci';

  @override
  String get languageSystemDefault => 'Come la lingua di sistema';

  @override
  String get languageEnglish => 'Inglese';

  @override
  String get languageVietnamese => 'Vietnamita';

  @override
  String get clearCacheMessage =>
      'Le scene, i dati della casa e le immagini in cache verranno scaricati di nuovo al prossimo utilizzo. Il tuo account e i dispositivi non sono interessati.';

  @override
  String get clear => 'Svuota';

  @override
  String get cancel => 'Annulla';

  @override
  String freedSpace(String size) {
    return 'Liberati $size';
  }

  @override
  String aboutVersion(String version, String build) {
    return 'Versione $version ($build)';
  }

  @override
  String get privacyPolicy => 'Informativa sulla privacy';

  @override
  String get termsOfService => 'Termini di servizio';

  @override
  String get bundleId => 'Bundle ID';

  @override
  String get server => 'Server';

  @override
  String get couldNotOpenLink => 'Impossibile aprire il link.';

  @override
  String get diagLocalNetwork => 'Rete locale';

  @override
  String get diagLocalNetworkNoWifi =>
      'Non su Wi-Fi (dati mobili o permesso negato)';

  @override
  String get diagLocalNetworkUnreadable => 'Impossibile leggere il nome Wi-Fi';

  @override
  String get diagDnsLookup => 'Ricerca DNS';

  @override
  String diagDnsFailed(String host) {
    return 'Impossibile risolvere $host';
  }

  @override
  String get diagServerReachable => 'Server raggiungibile';

  @override
  String diagServerLatency(String ms, String status) {
    return '$ms ms · HTTP $status';
  }

  @override
  String get diagServerNoResponse => 'Nessuna risposta dal server';

  @override
  String get diagSignedIn => 'Accesso effettuato';

  @override
  String get diagSessionValid => 'Sessione valida';

  @override
  String diagSessionInvalid(String status) {
    return 'HTTP $status — accedi di nuovo';
  }

  @override
  String get diagSessionUnverified => 'Impossibile verificare la sessione';

  @override
  String get diagControlChannel => 'Canale di controllo';

  @override
  String get diagCloudConnected => 'Cloud (MQTT) connesso';

  @override
  String get diagBleFallback => 'Cloud non disponibile — uso Bluetooth';

  @override
  String get diagUnreachable => 'Nessun cloud né Bluetooth nel raggio';

  @override
  String get diagStatusUnknown => 'Stato sconosciuto';

  @override
  String get runAgain => 'Esegui di nuovo';

  @override
  String get accountCreatedPleaseSignIn => 'Account creato — accedi.';

  @override
  String get add => 'Aggiungi';

  @override
  String get addCondition => 'Aggiungi condizione';

  @override
  String get addRoom => 'Aggiungi stanza';

  @override
  String get addTask => 'Aggiungi attività';

  @override
  String get addAtLeastTwoDevicesToAGroup =>
      'Aggiungi almeno due dispositivi a un gruppo.';

  @override
  String get alexa => 'Alexa';

  @override
  String get all => 'Tutti';

  @override
  String get allDevices => 'Tutti i dispositivi';

  @override
  String get alternateNetwork => 'Rete alternativa';

  @override
  String get apply => 'Applica';

  @override
  String get areYouSureYouWantToLogOut => 'Vuoi davvero uscire?';

  @override
  String get askAboutYourCurtainsOrTryHelp =>
      'Chiedi delle tue tende o prova /help…';

  @override
  String get askAboutYourCurtains => 'Chiedi delle tue tende…';

  @override
  String get atLeast6Characters => 'Almeno 6 caratteri';

  @override
  String get authDiagnostics => 'Diagnostica accesso';

  @override
  String get automationNotification => 'Notifica automazione';

  @override
  String get changeRoom => 'Cambia stanza';

  @override
  String get close => 'Chiudi';

  @override
  String get cloud => 'Cloud';

  @override
  String get confirm => 'Conferma';

  @override
  String get connected => 'Connesso';

  @override
  String get control => 'Controllo';

  @override
  String get controlSingleDevice => 'Controlla un dispositivo';

  @override
  String get copiedToClipboard => 'Copiato negli appunti';

  @override
  String get copy => 'Copia';

  @override
  String get couldNotChangeTheMotorDirectionPleaseTryAgai =>
      'Impossibile cambiare la direzione del motore. Riprova.';

  @override
  String get couldNotConnect => 'Connessione non riuscita';

  @override
  String get couldNotCreateTheGroupPleaseTryAgain =>
      'Impossibile creare il gruppo. Riprova.';

  @override
  String get couldNotOpenTheBrowser => 'Impossibile aprire il browser.';

  @override
  String get couldNotSendTheCommandPleaseTryAgain =>
      'Impossibile inviare il comando. Riprova.';

  @override
  String get create => 'Crea';

  @override
  String get createScene => 'Crea scena';

  @override
  String get createAHome => 'Crea una casa';

  @override
  String get createARoomFirst => 'Crea prima una stanza.';

  @override
  String get createAccount => 'Crea account';

  @override
  String get createScene2 => 'Crea scena';

  @override
  String get curtainPosition => 'Posizione tenda';

  @override
  String get curtainPositionSetting => 'Impostazione posizione tenda';

  @override
  String get customDeviceIconsAreNotSupportedYet =>
      'Le icone personalizzate non sono ancora supportate.';

  @override
  String get delayTheAction => 'Ritarda l\'azione';

  @override
  String get delete => 'Elimina';

  @override
  String get deleteAccount => 'Elimina account';

  @override
  String get deleteHome => 'Elimina casa';

  @override
  String get deleteRoom => 'Elimina stanza';

  @override
  String get deleteSchedule => 'Elimina programmazione';

  @override
  String get deleteScene => 'Eliminare la scena?';

  @override
  String get deleteThisSchedule => 'Eliminare questa programmazione?';

  @override
  String get deviceNetwork => 'Rete del dispositivo';

  @override
  String get deviceHasNoProfileInformation =>
      'Il dispositivo non ha informazioni sul profilo';

  @override
  String get deviceIsOffline => 'Dispositivo offline';

  @override
  String get deviceIsReady => 'Il dispositivo è pronto.';

  @override
  String get deviceName => 'Nome dispositivo';

  @override
  String get deviceRemovedFromHome => 'Dispositivo rimosso dalla casa.';

  @override
  String get deviceUnreachable => 'Dispositivo non raggiungibile';

  @override
  String get devices => 'Dispositivi';

  @override
  String get disconnect => 'Disconnetti';

  @override
  String get disconnectDevice => 'Disconnettere il dispositivo?';

  @override
  String get done => 'Fatto';

  @override
  String get emailAddress => 'Indirizzo email';

  @override
  String get emailOrUsername => 'Email o nome utente';

  @override
  String get enterAGroupName => 'Inserisci un nome per il gruppo';

  @override
  String get enterANote => 'Inserisci una nota';

  @override
  String get enterDeviceName => 'Inserisci il nome del dispositivo';

  @override
  String get enterHomeName => 'Inserisci il nome della casa';

  @override
  String get enterName => 'Inserisci il nome';

  @override
  String get enterSceneName => 'Inserisci il nome della scena';

  @override
  String get enterValue => 'Inserisci un valore...';

  @override
  String get enterYourPassword => 'Inserisci la password';

  @override
  String get eraseDeviceData => 'Cancellare i dati del dispositivo?';

  @override
  String get error => 'Errore';

  @override
  String get executedBy => 'Eseguito da';

  @override
  String get executionTime => 'Ora di esecuzione';

  @override
  String get faqFeedback => 'FAQ e feedback';

  @override
  String get failed => 'Non riuscito';

  @override
  String get featureComingSoon => 'Funzione in arrivo';

  @override
  String get firmware => 'Firmware';

  @override
  String get firmwareUpdateIsComingSoon =>
      'L\'aggiornamento del firmware sarà disponibile presto.';

  @override
  String get firstName => 'Nome';

  @override
  String get firstNameOptional => 'Nome (opzionale)';

  @override
  String get goBack => 'Indietro';

  @override
  String get googleAssistant => 'Google Assistant';

  @override
  String get gotIt => 'Ho capito';

  @override
  String get groupName => 'Nome gruppo';

  @override
  String get help => 'Aiuto';

  @override
  String get homeManagement => 'Gestione case';

  @override
  String get homeName => 'Nome casa';

  @override
  String get homeName2 => 'Nome casa';

  @override
  String get icon => 'Icona';

  @override
  String get conditionIf => 'Se';

  @override
  String get joinAHome => 'Unisciti a una casa';

  @override
  String get joiningAHomeByInviteIsComingSoon =>
      'L\'accesso a una casa tramite invito sarà disponibile presto.';

  @override
  String get lastName => 'Cognome';

  @override
  String get lastNameOptional => 'Cognome (opzionale)';

  @override
  String get later => 'Più tardi';

  @override
  String get launchTapToRun => 'Avvia Tap-to-Run';

  @override
  String get localAssociation => 'Associazione locale';

  @override
  String get localControlOffline => 'Controllo locale (offline)';

  @override
  String get location => 'Posizione';

  @override
  String get logCopiedToClipboard => 'Log copiato negli appunti';

  @override
  String get logs => 'Log';

  @override
  String get manage => 'Gestisci';

  @override
  String get managePermissions => 'Gestisci autorizzazioni';

  @override
  String get markAllAsRead => 'Segna tutto come letto';

  @override
  String get moreSettings => 'Altre impostazioni';

  @override
  String get motorDirection => 'Direzione motore';

  @override
  String get moveToTop => 'Sposta in cima';

  @override
  String get moveToRoom => 'Sposta nella stanza';

  @override
  String get moved => 'Spostato';

  @override
  String get movedToTop => 'Spostato in cima';

  @override
  String get name => 'Nome';

  @override
  String get next => 'Avanti';

  @override
  String get noDevicesAvailable => 'Nessun dispositivo disponibile';

  @override
  String get noDevicesFound => 'Nessun dispositivo trovato.';

  @override
  String get noDevicesInThisHome => 'Nessun dispositivo in questa casa.';

  @override
  String get noDevicesYet => 'Ancora nessun dispositivo';

  @override
  String get noFunctionsAvailable => 'Nessuna funzione disponibile';

  @override
  String get noHomeSelectedPleaseTryAgain =>
      'Nessuna casa selezionata, riprova';

  @override
  String get noMatchingTimeZones => 'Nessun fuso orario corrispondente';

  @override
  String get noOtherScenesAvailable => 'Nessun\'altra scena disponibile';

  @override
  String get noRooms => 'Nessuna stanza';

  @override
  String get noSavedNetworksYet => 'Ancora nessuna rete salvata.';

  @override
  String get noScenes => 'Nessuna scena';

  @override
  String get noScenesAvailable => 'Nessuna scena disponibile';

  @override
  String get note => 'Nota';

  @override
  String get notification => 'Notifica';

  @override
  String get ok => 'OK';

  @override
  String get offlineNotification => 'Notifica offline';

  @override
  String get open => 'Apri';

  @override
  String get openSettings => 'Apri impostazioni';

  @override
  String get outdoorPm25 => 'PM2.5 esterno';

  @override
  String get outdoorAirPressure => 'Pressione esterna';

  @override
  String get outdoorHumidity => 'Umidità esterna';

  @override
  String get outdoorWindSpeed => 'Velocità del vento';

  @override
  String get pairingSuccessful => 'Associazione completata';

  @override
  String get password => 'Password';

  @override
  String get sessionExpiredSignInAgain => 'Sessione scaduta. Accedi di nuovo.';

  @override
  String get pleaseAddAtLeast1Action => 'Aggiungi almeno 1 azione';

  @override
  String get pleaseAddAtLeast1Condition => 'Aggiungi almeno 1 condizione';

  @override
  String get pleaseEnterAName => 'Inserisci un nome';

  @override
  String get pleaseEnterASceneName => 'Inserisci il nome della scena';

  @override
  String get pleaseSelectAFunction => 'Seleziona una funzione';

  @override
  String get pleaseSelectATime0 => 'Seleziona un tempo > 0';

  @override
  String get rePairNow => 'Riassocia ora';

  @override
  String get rePairRequired => 'Riassociazione necessaria';

  @override
  String get reasonOptional => 'Motivo (opzionale)';

  @override
  String get refresh => 'Aggiorna';

  @override
  String get reload => 'Ricarica';

  @override
  String get remove => 'Rimuovi';

  @override
  String get removeDevice => 'Rimuovi dispositivo';

  @override
  String get removed => 'Rimosso';

  @override
  String get rename => 'Rinomina';

  @override
  String get renameRoom => 'Rinomina stanza';

  @override
  String get renameDevice => 'Rinomina dispositivo';

  @override
  String get repeat => 'Ripeti';

  @override
  String get rescan => 'Scansiona di nuovo';

  @override
  String get retry => 'Riprova';

  @override
  String get roomManagement => 'Gestione stanze';

  @override
  String get roomName => 'Nome stanza';

  @override
  String get roomUpdated => 'Stanza aggiornata';

  @override
  String get running => 'In esecuzione';

  @override
  String get save => 'Salva';

  @override
  String get sceneName => 'Nome scena';

  @override
  String get scenes => 'Scene';

  @override
  String get schedule => 'Programmazione';

  @override
  String get searchAddress => 'Cerca indirizzo';

  @override
  String get searchCityOrRegion => 'Cerca città o regione';

  @override
  String get selectScene => 'Seleziona scena';

  @override
  String get selectSmartScenes => 'Seleziona scene smart';

  @override
  String get sendResetLink => 'Invia link di reset';

  @override
  String get sendVerificationCode => 'Invia codice di verifica';

  @override
  String get showOnHomePage => 'Mostra nella Home';

  @override
  String get signIn => 'Accedi';

  @override
  String get signalStrength => 'Potenza segnale';

  @override
  String get signalStrength2 => 'Potenza segnale';

  @override
  String get startPairing => 'Avvia associazione';

  @override
  String get stop => 'Stop';

  @override
  String get style => 'Stile';

  @override
  String get switchNetwork => 'Cambia';

  @override
  String get switchToThisNetwork => 'Passa a questa rete';

  @override
  String get tapToRunNotification => 'Notifica Tap-to-Run';

  @override
  String get conditionThen => 'Allora';

  @override
  String get thinking => 'Sto pensando…';

  @override
  String get thisActionCannotBeUndone =>
      'Questa azione non può essere annullata.';

  @override
  String get thisSavedNetworkWillBeRemovedFromTheDevice =>
      'Questa rete salvata verrà rimossa dal dispositivo.';

  @override
  String get timeZone => 'Fuso orario';

  @override
  String get timeZoneUpdated => 'Fuso orario aggiornato';

  @override
  String get timedOut => 'Tempo scaduto';

  @override
  String get tryAgain => 'Riprova';

  @override
  String get useCurrentLocation => 'Usa posizione attuale';

  @override
  String get usingSiri => 'Con Siri';

  @override
  String get virtualId => 'Virtual ID';

  @override
  String get whenDeviceStatusChanges =>
      'Quando cambia lo stato del dispositivo';

  @override
  String get whenWeatherChanges => 'Quando cambia il meteo';

  @override
  String get wiFi => 'Wi-Fi';

  @override
  String get wifiNameSsid => 'Nome WiFi (SSID)';

  @override
  String get wifiPassword => 'Password WiFi';

  @override
  String get navHome => 'Casa';

  @override
  String get navScenes => 'Scene';

  @override
  String get navChat => 'Chat';

  @override
  String get navMe => 'Io';

  @override
  String get thirdPartyServices => 'Servizi di terze parti';

  @override
  String get messageCenter => 'Centro messaggi';

  @override
  String get appMall => 'Store app';

  @override
  String get addDevice => 'Aggiungi dispositivo';

  @override
  String get tapToRun => 'Esegui con un tocco';

  @override
  String get automationEmptyHint =>
      'L\'automazione ti fa risparmiare tempo e fatica automatizzando le attività di ogni giorno.';

  @override
  String get tapToRunEmptyHint =>
      'Crea una scena \"esegui con un tocco\" per controllare i tuoi dispositivi con un solo tocco.';

  @override
  String get scene => 'Scena';

  @override
  String get executionFailed => 'Esecuzione non riuscita';

  @override
  String get device => 'Dispositivo';

  @override
  String get delay => 'Attesa';

  @override
  String get runScene => 'Esegui scena';

  @override
  String get addToSiri => 'Aggiungi a Siri';

  @override
  String get storeUnderPreparation =>
      'Lo store è in preparazione, resta aggiornato.';

  @override
  String get commonFunctions => 'Funzioni comuni';

  @override
  String get noConnection => 'Nessuna connessione';

  @override
  String get checkInternetAndRetry =>
      'Controlla la connessione a Internet e riprova.';

  @override
  String get noConnectionCheckInternet =>
      'Nessuna connessione. Controlla Internet e riprova.';

  @override
  String get addFirstCurtainHint =>
      'Tocca il pulsante + per aggiungere la prima tenda a questa casa.';

  @override
  String get hideInvisibleDevices => 'Nascondi i dispositivi non visibili';

  @override
  String get deviceRenamed => 'Dispositivo rinominato.';

  @override
  String get deviceDeletedReturningToPairing =>
      'Dispositivo eliminato. Tornerà in modalità associazione.';

  @override
  String get homeSettings => 'Impostazioni casa';

  @override
  String get toBeSet => 'Da impostare';

  @override
  String get homeMember => 'Membro della casa';

  @override
  String get memberDetails => 'Dettagli del membro';

  @override
  String get addMember => 'Aggiungi membro';

  @override
  String get pending => 'In attesa';

  @override
  String get removesFromHomeHint =>
      'Rimuove dalla casa; il dispositivo torna in modalità associazione in 1-2 minuti';

  @override
  String get unlinkAndEraseData => 'Scollega ed elimina i dati';

  @override
  String get erasesAllDataHint =>
      'Elimina tutti i dati, operazione irreversibile';

  @override
  String get somethingWentWrongTryAgain => 'Qualcosa è andato storto, riprova';

  @override
  String get tapToRunAndAutomation => 'Esegui con un tocco e automazione';

  @override
  String get thirdPartyControl => 'Controllo da terze parti';

  @override
  String get deviceOfflineNotification => 'Notifica dispositivo offline';

  @override
  String get others => 'Altro';

  @override
  String get shareDevice => 'Condividi dispositivo';

  @override
  String get addToHomeScreen => 'Aggiungi alla schermata Home';

  @override
  String get checkDeviceNetwork => 'Controlla la rete del dispositivo';

  @override
  String get checkNow => 'Controlla ora';

  @override
  String get deviceUpdate => 'Aggiornamento dispositivo';

  @override
  String get removeDevicesWarning =>
      'Verranno rimossi da questa casa e torneranno in modalità associazione.';

  @override
  String get shown => 'Visibile';

  @override
  String get hidden => 'Nascosto';

  @override
  String get devicesBackOnHome => 'I dispositivi sono di nuovo nella Home';

  @override
  String get hiddenFromHome => 'Nascosti dalla Home';

  @override
  String get offline => 'Offline';

  @override
  String get show => 'Mostra';

  @override
  String get hide => 'Nascondi';

  @override
  String get profilePhoto => 'Foto profilo';

  @override
  String get nickname => 'Nickname';

  @override
  String get noRoomsYet => 'Nessuna stanza';

  @override
  String get tapPlusToAddRoom => 'Tocca + per aggiungere una stanza';

  @override
  String get emailAddressLabel => 'Indirizzo email';

  @override
  String get notSet => 'Non impostato';

  @override
  String get deviceInformation => 'Informazioni dispositivo';

  @override
  String get unknown => 'Sconosciuto';

  @override
  String get notReported => 'Non riportato';

  @override
  String get noScenesUseThisDevice =>
      'Nessuna scena usa ancora questo dispositivo.';

  @override
  String get tapToRunLabel => 'Esegui con un tocco';

  @override
  String get automation => 'Automazione';

  @override
  String get forward => 'Normale';

  @override
  String get back => 'Invertito';

  @override
  String get setting => 'Impostazione';

  @override
  String get updateAvailable => 'Aggiornamento disponibile';

  @override
  String get noUpdatesAvailable => 'Nessun aggiornamento disponibile';

  @override
  String get updateNow => 'Aggiorna ora';

  @override
  String get unassigned => 'Non assegnato';

  @override
  String get enterEmailOrUsername => 'Inserisci email o nome utente';

  @override
  String get welcome => 'Benvenuto';

  @override
  String get signInSubtitle => 'Accedi al tuo account osprey.life.';

  @override
  String get createOne => 'Creane uno';

  @override
  String get forgotPassword => 'Password dimenticata?';

  @override
  String get orContinueWith => 'oppure continua con';

  @override
  String get enterValidEmail => 'Inserisci un indirizzo email valido';

  @override
  String get resetYourPassword => 'Reimposta la password';

  @override
  String get checkYourInbox => 'Controlla la posta in arrivo';

  @override
  String get enterYourEmailAddress => 'Inserisci il tuo indirizzo email';

  @override
  String get enterSixDigitCode => 'Inserisci il codice a 6 cifre';

  @override
  String get enterAPassword => 'Inserisci una password';

  @override
  String get createYourAccount => 'Crea il tuo account';

  @override
  String get checkYourEmail => 'Controlla la tua email';

  @override
  String get resendCode => 'Invia di nuovo il codice';

  @override
  String get userAgreement => 'Condizioni d\'uso';

  @override
  String get reconnecting => 'Riconnessione…';

  @override
  String get checkWifiOrBluetooth =>
      'Controlla il Wi-Fi o avvicinati per il Bluetooth.';

  @override
  String get smartScenesRequireInternet => 'Le scene smart richiedono Internet';

  @override
  String get enterWifiName => 'Inserisci il nome del Wi-Fi';

  @override
  String get wifiNameLengthError =>
      'Il nome del Wi-Fi deve avere da 1 a 32 caratteri';

  @override
  String get passwordMin8 => 'La password deve avere almeno 8 caratteri';

  @override
  String get passwordLength863 => 'La password deve avere da 8 a 63 caratteri';

  @override
  String get networkAlreadySaved =>
      'Questa rete è già salvata. Per cambiare la password, eliminala e aggiungila di nuovo.';

  @override
  String get addWifiNetwork => 'Aggiungi rete Wi-Fi';

  @override
  String get atLeast8Characters => 'Almeno 8 caratteri';

  @override
  String get only24GhzSupported =>
      'I dispositivi per tende supportano solo Wi-Fi a 2,4 GHz (WPA2).';

  @override
  String get labelOptional => 'Etichetta (facoltativa)';

  @override
  String get createGroup => 'Crea gruppo';

  @override
  String get groupControlHint =>
      'I dispositivi dello stesso gruppo possono essere controllati insieme.';

  @override
  String get devicesToBeAdded => 'Dispositivi da aggiungere';

  @override
  String get noSameTypeDevices =>
      'Nessun altro dispositivo dello stesso tipo in questa casa.';

  @override
  String get couldNotLoadNetworkDetails =>
      'Impossibile caricare i dettagli della rete. Trascina per aggiornare.';

  @override
  String get alreadyOnThisNetwork => 'Già connesso a questa rete.';

  @override
  String get deviceOfflineTryLater =>
      'Il dispositivo è offline: riprova più tardi.';

  @override
  String get wrongPassword => 'Password errata';

  @override
  String get networkNotFound => 'Rete non trovata';

  @override
  String get networkRemoved => 'Rete rimossa.';

  @override
  String get network => 'Rete';

  @override
  String get connectedTo => 'Connesso a';

  @override
  String get savedNetworks => 'Reti salvate';

  @override
  String get addANetwork => 'Aggiungi una rete';

  @override
  String get notConnected => 'Non connesso';

  @override
  String get pleaseKeepAppOpen => 'Tieni l\'app aperta.';

  @override
  String get deviceNetworkInformation => 'Informazioni di rete del dispositivo';

  @override
  String get once => 'Una sola volta';

  @override
  String get editSchedule => 'Modifica programmazione';

  @override
  String get addSchedule => 'Aggiungi programmazione';

  @override
  String get timeVarianceHint => 'Lo scostamento è di circa ±30 s';

  @override
  String get noTimerData => 'Nessun dato del timer';

  @override
  String get localControlUnsupportedAction =>
      'Il controllo locale non supporta questa azione';

  @override
  String get noInternetNoBluetooth =>
      'Nessuna connessione e Bluetooth fuori portata';

  @override
  String get connectionError => 'Errore di connessione';

  @override
  String get exampleTapToRun =>
      'Esempio: spegnere tutte le luci della camera con un tocco.';

  @override
  String get exampleWeather =>
      'Esempio: quando la temperatura locale supera i 28 °C.';

  @override
  String get weatherTrigger => 'Trigger meteo';

  @override
  String get exampleSchedule => 'Esempio: alle 7:00 ogni mattina.';

  @override
  String get exampleDeviceStatus =>
      'Esempio: quando viene rilevata un\'attività inusuale.';

  @override
  String get deviceStatusTrigger => 'Trigger stato dispositivo';

  @override
  String get noNotificationsYet => 'Nessuna notifica';

  @override
  String get slashCommands => 'Comandi slash';

  @override
  String get slashDevicesHint => 'Sfoglia e controlla le tue tende.';

  @override
  String get slashSceneHint => 'Esegui una scena con un tocco.';

  @override
  String get slashScheduleHint => 'Apri la programmazione dell\'automazione.';

  @override
  String get slashHelpHint => 'Mostra questo elenco.';

  @override
  String get youCanAlsoSpeak =>
      'Puoi anche parlare: tocca il pulsante del microfono.';

  @override
  String get chatInputHint => 'Scrivi, parla o usa i comandi slash.';

  @override
  String get online => 'Online';

  @override
  String get blePermissionRequired =>
      'Per trovare i dispositivi è necessaria l\'autorizzazione Bluetooth';

  @override
  String get bleAndLocationPermissionRequired =>
      'Per trovare i dispositivi sono necessarie le autorizzazioni Bluetooth e Posizione';

  @override
  String get addDeviceLower => 'Aggiungi dispositivo';

  @override
  String get scanningStopped => 'Ricerca interrotta.';

  @override
  String get enterWifiPassword => 'Inserisci la password del Wi-Fi';

  @override
  String get detectingCurrentWifi => 'Rilevamento del Wi-Fi attuale...';

  @override
  String get autoDetectedWifi =>
      'Rilevato automaticamente dal Wi-Fi a cui è connesso il telefono';

  @override
  String get couldNotDetectWifi =>
      'Wi-Fi non rilevato: inserisci il nome della rete manualmente';

  @override
  String get beingAdded => 'Aggiunta in corso';

  @override
  String get addedSuccessfully => 'Aggiunto correttamente';

  @override
  String get pairingFailed => 'Associazione non riuscita';

  @override
  String get allDay => 'Tutto il giorno';

  @override
  String get whenAnyConditionMet => 'Quando una condizione è soddisfatta';

  @override
  String get whenAllConditionsMet =>
      'Quando tutte le condizioni sono soddisfatte';

  @override
  String get deleteSceneWarning =>
      'Dopo l\'eliminazione dello scenario, le attività dei dispositivi non potranno più essere eseguite correttamente.';

  @override
  String get toggleAutomation => 'Attiva/disattiva automazione';

  @override
  String get enable => 'Attiva';

  @override
  String get disable => 'Disattiva';

  @override
  String get everyDay => 'Ogni giorno';

  @override
  String get monToFri => 'Lun - Ven';

  @override
  String get satToSun => 'Sab - Dom';

  @override
  String get runOnceIfNoDaySelected =>
      'L\'azione verrà eseguita una sola volta se non selezioni alcun giorno della settimana.';

  @override
  String get sendNotification => 'Invia notifica';

  @override
  String get color => 'Colore';

  @override
  String get wait => 'Attendi';

  @override
  String get finish => 'Fine';

  @override
  String get selectFunction => 'Seleziona funzione';

  @override
  String get on => 'Acceso';

  @override
  String get off => 'Spento';

  @override
  String get siriShortcut => 'Comando rapido Siri';

  @override
  String get createTapToRunFirst => 'Crea prima una scena con un tocco.';

  @override
  String get poweredByFoundationModels =>
      'Con Apple Foundation Models, direttamente sul dispositivo.';

  @override
  String get weatherClearNight => 'Notte serena';

  @override
  String get weatherSunny => 'Sereno';

  @override
  String get weatherPartlyCloudy => 'Parzialmente nuvoloso';

  @override
  String get weatherCloudy => 'Nuvoloso';

  @override
  String get qualityExcellent => 'Ottima';

  @override
  String get qualityGood => 'Buona';

  @override
  String get qualityModerate => 'Moderata';

  @override
  String get qualityPoor => 'Scarsa';

  @override
  String get qualityVeryPoor => 'Molto scarsa';

  @override
  String get switchLocation => 'Cambia posizione';

  @override
  String get aiSuggestion => 'Suggerimento IA';

  @override
  String get listening => 'In ascolto…';

  @override
  String get parsing => 'Analisi…';

  @override
  String get getStarted => 'Inizia';

  @override
  String get aiChatEmptyState =>
      'Chiedi all\'assistente osprey.life tutto quello che vuoi sulle tue tende.\nCon Apple Foundation Models, direttamente sul dispositivo.';

  @override
  String get chatHeaderSubtitle =>
      'IA sul dispositivo per le tue tende motorizzate.\nScrivi, parla o usa i comandi slash.';

  @override
  String get daySunShort => 'Dom.';

  @override
  String get dayMonShort => 'Lun.';

  @override
  String get dayTueShort => 'Mar.';

  @override
  String get dayWedShort => 'Mer.';

  @override
  String get dayThuShort => 'Gio.';

  @override
  String get dayFriShort => 'Ven.';

  @override
  String get daySatShort => 'Sab.';

  @override
  String get dayMon => 'Lun';

  @override
  String get dayTue => 'Mar';

  @override
  String get dayWed => 'Mer';

  @override
  String get dayThu => 'Gio';

  @override
  String get dayFri => 'Ven';

  @override
  String get daySat => 'Sab';

  @override
  String get daySun => 'Dom';

  @override
  String get accountLinkedSuccessfully => 'Account collegato correttamente!';

  @override
  String get linkingFailed => 'Collegamento non riuscito';

  @override
  String get anErrorOccurredTryAgain => 'Si è verificato un errore. Riprova.';

  @override
  String get signInWithAmazon => 'Accedi con Amazon';

  @override
  String get viewMoreWaysToLink => 'Altre modalità di collegamento';

  @override
  String get alreadyLinkedWithAlexa => 'Già collegato ad Amazon Alexa';

  @override
  String get somethingWentWrong => 'Qualcosa è andato storto';

  @override
  String get noAuthorizationCode => 'Nessun codice di autorizzazione ricevuto';

  @override
  String get couldNotOpenGoogleHome => 'Impossibile aprire l\'app Google Home';

  @override
  String get reLogin => 'Accedi di nuovo';

  @override
  String get linkWithGoogleAssistant => 'Collega all\'Assistente Google';

  @override
  String get linkedWithGoogleAssistant => 'Collegato all\'Assistente Google';

  @override
  String get anErrorOccurred => 'Si è verificato un errore';

  @override
  String deleteHomeConfirm(String name) {
    return 'Vuoi davvero eliminare \"$name\"? L\'operazione è irreversibile.';
  }

  @override
  String get offlineScenesBody =>
      'Scene e programmazioni sono in pausa fino al ritorno del Wi-Fi. Il controllo locale via Bluetooth continua a funzionare per aprire, chiudere e fermare ogni dispositivo.';

  @override
  String get blePairingLostBody =>
      'Il controllo locale via Bluetooth deve essere associato di nuovo a questo dispositivo. Succede in genere dopo la cancellazione dei dati dell\'app o il ripristino del dispositivo.';

  @override
  String get alternateNetworkHint =>
      'Se la rete attuale non è disponibile, il dispositivo si connetterà automaticamente a una rete alternativa.';

  @override
  String get switchNetworkWarning =>
      'Il dispositivo si disconnetterà dal Wi-Fi attuale e proverà a connettersi al nuovo. In genere richiede da 5 a 30 secondi.';

  @override
  String get runOnceIfNoDayPicked =>
      'L\'azione verrà eseguita una sola volta se non la selezioni.';

  @override
  String get alexaUnlinkHint =>
      'Disattiva la skill osprey.life nell\'app Amazon Alexa oppure tocca Io > il pulsante Impostazioni in alto a destra > Account e sicurezza per revocare l\'autorizzazione.';

  @override
  String get alexaLinkExplainer =>
      'Collegando l\'account dell\'app al tuo account Amazon puoi controllare i dispositivi compatibili con Alexa tramite gli altoparlanti Amazon Echo (es. \"Alexa, turn on light.\")';

  @override
  String get chatScheduleHelp =>
      'Imposta programmazioni automatiche per le tue tende. Apri la scheda Scene per creare automazioni giornaliere, settimanali o una sola volta.';

  @override
  String get chatScenesHelp =>
      'Crea e gestisci le scene con un tocco dalla scheda Scene. Le scene permettono di concatenare più azioni delle tende con attese, in un solo tocco.';

  @override
  String get googleUnlinkHint =>
      'Disattiva la skill osprey.life nell\'app Google Home oppure tocca Io > il pulsante Impostazioni in alto a destra > Account e sicurezza per revocare l\'autorizzazione.';

  @override
  String get googleLinkExplainer =>
      'Dopo aver collegato l\'account dell\'app e il tuo account Google, potrai usare gli altoparlanti smart Google Home per controllare i dispositivi compatibili con l\'Assistente Google. Per esempio puoi dire: \"OK Google, please turn on the light.\"';

  @override
  String get deviceDisconnectedFromHome =>
      'Dispositivo scollegato dalla casa. Tornerà in modalità associazione in 1-2 minuti.';

  @override
  String get searchingNearbyDevices =>
      'Ricerca di dispositivi Osprey nelle vicinanze. Assicurati che il dispositivo sia in modalità associazione.';

  @override
  String get looksLike5GhzHint =>
      'Questa rete sembra a 5 GHz: passa il telefono a una rete a 2,4 GHz, poi tocca aggiorna.';

  @override
  String get pairingWifiHint =>
      'Il dispositivo si connetterà al Wi-Fi che usa il tuo telefono. Sono supportate solo le reti a 2,4 GHz.';

  @override
  String get siriShortcutsHelp =>
      'Tocca una scena per registrare una frase vocale, poi di\' \"Ehi Siri\" seguito da quella frase per eseguire la scena, anche con l\'app chiusa.\n\nTocca una scena già aggiunta per cambiarne la frase o rimuoverla.';

  @override
  String get deleteAccountWarning =>
      'Dopo l\'eliminazione:\n• Il tuo account verrà eliminato dopo 30 giorni\n• Tutti i tuoi dispositivi e le tue scene verranno rimossi\n• Puoi annullare accedendo di nuovo entro 30 giorni';

  @override
  String aiSuggestionBody(String action, String weekday, String hour) {
    return 'Di solito esegui \"$action\" il $weekday alle $hour:00 — vuoi automatizzarlo?';
  }

  @override
  String removeDeviceConfirm(String name) {
    return '\"$name\" verrà rimosso dalla tua casa e tornerà automaticamente in modalità associazione in circa 1-2 minuti.';
  }

  @override
  String eraseDeviceConfirm(String name) {
    return 'Tutti i dati di \"$name\" verranno eliminati e NON potranno essere recuperati. Vuoi continuare?';
  }

  @override
  String showInvisibleDevices(int count) {
    return 'Mostra i dispositivi non visibili ($count)';
  }

  @override
  String resetLinkSent(String email) {
    return 'Se esiste un account per $email, ti invieremo un link per reimpostare la password.';
  }

  @override
  String signInNotAvailable(String name) {
    return 'L\'accesso con $name non è ancora disponibile.';
  }

  @override
  String resendCodeIn(int seconds) {
    return 'Invia di nuovo il codice tra $seconds s';
  }

  @override
  String deleteConfirmNamed(String name) {
    return 'Vuoi davvero eliminare \"$name\"?';
  }

  @override
  String taskCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count attività',
      one: '1 attività',
    );
    return '$_temp0';
  }

  @override
  String featureComingSoonShort(String feature) {
    return '$feature sarà disponibile a breve';
  }

  @override
  String roomCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count stanze',
      one: '1 stanza',
    );
    return '$_temp0';
  }

  @override
  String removeDevicesQ(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Rimuovere $count dispositivi?',
      one: 'Rimuovere il dispositivo?',
    );
    return '$_temp0';
  }

  @override
  String devicesRemoved(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count dispositivi rimossi',
      one: '1 dispositivo rimosso',
    );
    return '$_temp0';
  }

  @override
  String deviceCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count dispositivi',
      one: '1 dispositivo',
    );
    return '$_temp0';
  }

  @override
  String mainModuleVersion(String version) {
    return 'Modulo principale: V$version';
  }

  @override
  String outdoorTemperatureValue(int temp) {
    return 'Temperatura esterna: $temp °C';
  }

  @override
  String occurrencesIn30Days(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count volte in 30 giorni',
      one: '1 volta in 30 giorni',
    );
    return '$_temp0';
  }

  @override
  String sceneExecuted(String name) {
    return '\"$name\" eseguita';
  }

  @override
  String couldNotRunScene(String name) {
    return 'Impossibile eseguire \"$name\". Riprova.';
  }

  @override
  String featureComingSoonNamed(String feature) {
    return '$feature sarà disponibile a breve.';
  }

  @override
  String get couldNotLoadHome => 'Impossibile caricare la tua casa. Riprova.';

  @override
  String deviceCouldNotConnectTo(String ssid, String reason, String stayedOn) {
    return 'Il dispositivo non è riuscito a connettersi a \"$ssid\".\n\nMotivo: $reason\n\nIl dispositivo è ancora su \"$stayedOn\".';
  }

  @override
  String makeSureNetworkInRange(String ssid) {
    return '\n\nAssicurati che \"$ssid\" sia attiva e a portata.';
  }

  @override
  String get noResponseFromDevice =>
      'Non abbiamo ricevuto risposta dal dispositivo. Aggiorna tra poco per vederne lo stato attuale.';

  @override
  String devicesBeingAdded(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Aggiunta di $count dispositivi',
      one: 'Aggiunta di 1 dispositivo',
    );
    return '$_temp0';
  }

  @override
  String devicesAddedSuccessfully(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count dispositivi aggiunti correttamente',
      one: '1 dispositivo aggiunto correttamente',
    );
    return '$_temp0';
  }

  @override
  String get alexaExamplesIntro =>
      'Puoi controllare i dispositivi compatibili con Alexa\ncon gli altoparlanti Amazon Alexa, per esempio';

  @override
  String get googleExamplesIntro =>
      'Ora puoi usare l\'altoparlante Google Home per\ncontrollare i dispositivi dell\'Assistente Google, come';

  @override
  String get gridView => 'Vista a griglia';

  @override
  String get listView => 'Vista a elenco';

  @override
  String get deviceManagement => 'Gestione dispositivi';

  @override
  String get sort => 'Ordina';

  @override
  String get darkMode => 'Modalità scura';

  @override
  String get followSystem => 'Segui il sistema';

  @override
  String get system => 'Sistema';

  @override
  String get systemDarkModeHint =>
      'Se attivata, l\'app attiva o disattiva la modalità scura in base alle impostazioni del sistema.';

  @override
  String get normalMode => 'Modalità normale';
}
