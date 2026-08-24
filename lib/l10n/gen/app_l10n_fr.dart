// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_l10n.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppL10nFr extends AppL10n {
  AppL10nFr([String locale = 'fr']) : super(locale);

  @override
  String get settingsTitle => 'Paramètres';

  @override
  String get personalInformation => 'Informations personnelles';

  @override
  String get accountAndSecurity => 'Compte et sécurité';

  @override
  String get touchToneOnPanel => 'Son tactile du panneau';

  @override
  String get aiAssistant => 'Assistant IA';

  @override
  String get temperatureUnit => 'Unité de température';

  @override
  String get about => 'À propos';

  @override
  String get networkDiagnosis => 'Diagnostic réseau';

  @override
  String get clearCache => 'Vider le cache';

  @override
  String get language => 'Langue';

  @override
  String get logOut => 'Déconnexion';

  @override
  String get languageSystemDefault => 'Identique à la langue du système';

  @override
  String get languageEnglish => 'Anglais';

  @override
  String get languageVietnamese => 'Vietnamien';

  @override
  String get clearCacheMessage =>
      'Les scènes, données de maison et images en cache seront retéléchargées à la prochaine utilisation. Votre compte et vos appareils ne sont pas affectés.';

  @override
  String get clear => 'Vider';

  @override
  String get cancel => 'Annuler';

  @override
  String freedSpace(String size) {
    return '$size libérés';
  }

  @override
  String aboutVersion(String version, String build) {
    return 'Version $version ($build)';
  }

  @override
  String get privacyPolicy => 'Politique de confidentialité';

  @override
  String get termsOfService => 'Conditions d\'utilisation';

  @override
  String get bundleId => 'Bundle ID';

  @override
  String get server => 'Serveur';

  @override
  String get couldNotOpenLink => 'Impossible d\'ouvrir le lien.';

  @override
  String get diagLocalNetwork => 'Réseau local';

  @override
  String get diagLocalNetworkNoWifi =>
      'Pas en Wi-Fi (données mobiles ou autorisation refusée)';

  @override
  String get diagLocalNetworkUnreadable => 'Impossible de lire le nom du Wi-Fi';

  @override
  String get diagDnsLookup => 'Résolution DNS';

  @override
  String diagDnsFailed(String host) {
    return 'Impossible de résoudre $host';
  }

  @override
  String get diagServerReachable => 'Serveur joignable';

  @override
  String diagServerLatency(String ms, String status) {
    return '$ms ms · HTTP $status';
  }

  @override
  String get diagServerNoResponse => 'Aucune réponse du serveur';

  @override
  String get diagSignedIn => 'Connecté';

  @override
  String get diagSessionValid => 'Session valide';

  @override
  String diagSessionInvalid(String status) {
    return 'HTTP $status — veuillez vous reconnecter';
  }

  @override
  String get diagSessionUnverified => 'Impossible de vérifier la session';

  @override
  String get diagControlChannel => 'Canal de commande';

  @override
  String get diagCloudConnected => 'Cloud (MQTT) connecté';

  @override
  String get diagBleFallback => 'Cloud indisponible — repli sur Bluetooth';

  @override
  String get diagUnreachable => 'Ni cloud ni Bluetooth à portée';

  @override
  String get diagStatusUnknown => 'Statut inconnu';

  @override
  String get runAgain => 'Relancer';

  @override
  String get accountCreatedPleaseSignIn =>
      'Compte créé — veuillez vous connecter.';

  @override
  String get add => 'Ajouter';

  @override
  String get addCondition => 'Ajouter une condition';

  @override
  String get addRoom => 'Ajouter une pièce';

  @override
  String get addTask => 'Ajouter une tâche';

  @override
  String get addAtLeastTwoDevicesToAGroup =>
      'Ajoutez au moins deux appareils à un groupe.';

  @override
  String get alexa => 'Alexa';

  @override
  String get all => 'Tout';

  @override
  String get allDevices => 'Tous les appareils';

  @override
  String get alternateNetwork => 'Réseau secondaire';

  @override
  String get apply => 'Appliquer';

  @override
  String get areYouSureYouWantToLogOut =>
      'Voulez-vous vraiment vous déconnecter ?';

  @override
  String get askAboutYourCurtainsOrTryHelp =>
      'Posez une question sur vos rideaux, ou essayez /help…';

  @override
  String get askAboutYourCurtains => 'Posez une question sur vos rideaux…';

  @override
  String get atLeast6Characters => '6 caractères minimum';

  @override
  String get authDiagnostics => 'Diagnostic d\'authentification';

  @override
  String get automationNotification => 'Notification d\'automatisation';

  @override
  String get changeRoom => 'Changer de pièce';

  @override
  String get close => 'Fermer';

  @override
  String get cloud => 'Cloud';

  @override
  String get confirm => 'Confirmer';

  @override
  String get connected => 'Connecté';

  @override
  String get control => 'Commande';

  @override
  String get controlSingleDevice => 'Commander un appareil';

  @override
  String get copiedToClipboard => 'Copié dans le presse-papiers';

  @override
  String get copy => 'Copier';

  @override
  String get couldNotChangeTheMotorDirectionPleaseTryAgai =>
      'Impossible de changer le sens du moteur. Veuillez réessayer.';

  @override
  String get couldNotConnect => 'Connexion impossible';

  @override
  String get couldNotCreateTheGroupPleaseTryAgain =>
      'Impossible de créer le groupe. Veuillez réessayer.';

  @override
  String get couldNotOpenTheBrowser => 'Impossible d\'ouvrir le navigateur.';

  @override
  String get couldNotSendTheCommandPleaseTryAgain =>
      'Impossible d\'envoyer la commande. Veuillez réessayer.';

  @override
  String get create => 'Créer';

  @override
  String get createScene => 'Créer une scène';

  @override
  String get createAHome => 'Créer une maison';

  @override
  String get createARoomFirst => 'Créez d\'abord une pièce.';

  @override
  String get createAccount => 'Créer un compte';

  @override
  String get createScene2 => 'Créer une scène';

  @override
  String get curtainPosition => 'Position du rideau';

  @override
  String get curtainPositionSetting => 'Réglage de position du rideau';

  @override
  String get customDeviceIconsAreNotSupportedYet =>
      'Les icônes d\'appareil personnalisées ne sont pas encore prises en charge.';

  @override
  String get delayTheAction => 'Différer l\'action';

  @override
  String get delete => 'Supprimer';

  @override
  String get deleteAccount => 'Supprimer le compte';

  @override
  String get deleteHome => 'Supprimer la maison';

  @override
  String get deleteRoom => 'Supprimer la pièce';

  @override
  String get deleteSchedule => 'Supprimer la programmation';

  @override
  String get deleteScene => 'Supprimer la scène ?';

  @override
  String get deleteThisSchedule => 'Supprimer cette programmation ?';

  @override
  String get deviceNetwork => 'Réseau de l\'appareil';

  @override
  String get deviceHasNoProfileInformation =>
      'Aucune information de profil pour cet appareil';

  @override
  String get deviceIsOffline => 'Appareil hors ligne';

  @override
  String get deviceIsReady => 'L\'appareil est prêt.';

  @override
  String get deviceName => 'Nom de l\'appareil';

  @override
  String get deviceRemovedFromHome => 'Appareil retiré de la maison.';

  @override
  String get deviceUnreachable => 'Appareil injoignable';

  @override
  String get devices => 'Appareils';

  @override
  String get disconnect => 'Déconnecter';

  @override
  String get disconnectDevice => 'Déconnecter l\'appareil ?';

  @override
  String get done => 'Terminé';

  @override
  String get emailAddress => 'Adresse e-mail';

  @override
  String get emailOrUsername => 'E-mail ou identifiant';

  @override
  String get enterAGroupName => 'Saisissez un nom de groupe';

  @override
  String get enterANote => 'Saisissez une note';

  @override
  String get enterDeviceName => 'Saisissez le nom de l\'appareil';

  @override
  String get enterHomeName => 'Saisissez le nom de la maison';

  @override
  String get enterName => 'Saisissez un nom';

  @override
  String get enterSceneName => 'Saisissez le nom de la scène';

  @override
  String get enterValue => 'Saisissez une valeur...';

  @override
  String get enterYourPassword => 'Saisissez votre mot de passe';

  @override
  String get eraseDeviceData => 'Effacer les données de l\'appareil ?';

  @override
  String get error => 'Erreur';

  @override
  String get executedBy => 'Exécutée par';

  @override
  String get executionTime => 'Heure d\'exécution';

  @override
  String get faqFeedback => 'FAQ et avis';

  @override
  String get failed => 'Échec';

  @override
  String get featureComingSoon => 'Fonction bientôt disponible';

  @override
  String get firmware => 'Micrologiciel';

  @override
  String get firmwareUpdateIsComingSoon =>
      'La mise à jour du micrologiciel arrive bientôt.';

  @override
  String get firstName => 'Prénom';

  @override
  String get firstNameOptional => 'Prénom (facultatif)';

  @override
  String get goBack => 'Retour';

  @override
  String get googleAssistant => 'Google Assistant';

  @override
  String get gotIt => 'Compris';

  @override
  String get groupName => 'Nom du groupe';

  @override
  String get help => 'Aide';

  @override
  String get homeManagement => 'Gestion des maisons';

  @override
  String get homeName => 'Nom de la maison';

  @override
  String get homeName2 => 'Nom de la maison';

  @override
  String get icon => 'Icône';

  @override
  String get conditionIf => 'Si';

  @override
  String get joinAHome => 'Rejoindre une maison';

  @override
  String get joiningAHomeByInviteIsComingSoon =>
      'Rejoindre une maison sur invitation arrive bientôt.';

  @override
  String get lastName => 'Nom';

  @override
  String get lastNameOptional => 'Nom (facultatif)';

  @override
  String get later => 'Plus tard';

  @override
  String get launchTapToRun => 'Lancer un Tap-to-Run';

  @override
  String get localAssociation => 'Association locale';

  @override
  String get localControlOffline => 'Commande locale (hors ligne)';

  @override
  String get location => 'Lieu';

  @override
  String get logCopiedToClipboard => 'Journal copié dans le presse-papiers';

  @override
  String get logs => 'Journaux';

  @override
  String get manage => 'Gérer';

  @override
  String get managePermissions => 'Gérer les autorisations';

  @override
  String get markAllAsRead => 'Tout marquer comme lu';

  @override
  String get moreSettings => 'Plus de paramètres';

  @override
  String get motorDirection => 'Sens du moteur';

  @override
  String get moveToTop => 'Placer en haut';

  @override
  String get moveToRoom => 'Déplacer vers une pièce';

  @override
  String get moved => 'Déplacé';

  @override
  String get movedToTop => 'Placé en haut';

  @override
  String get name => 'Nom';

  @override
  String get next => 'Suivant';

  @override
  String get noDevicesAvailable => 'Aucun appareil disponible';

  @override
  String get noDevicesFound => 'Aucun appareil trouvé.';

  @override
  String get noDevicesInThisHome => 'Aucun appareil dans cette maison.';

  @override
  String get noDevicesYet => 'Aucun appareil';

  @override
  String get noFunctionsAvailable => 'Aucune fonction disponible';

  @override
  String get noHomeSelectedPleaseTryAgain =>
      'Aucune maison sélectionnée, veuillez réessayer';

  @override
  String get noMatchingTimeZones => 'Aucun fuseau horaire correspondant';

  @override
  String get noOtherScenesAvailable => 'Aucune autre scène disponible';

  @override
  String get noRooms => 'Aucune pièce';

  @override
  String get noSavedNetworksYet => 'Aucun réseau enregistré.';

  @override
  String get noScenes => 'Aucune scène';

  @override
  String get noScenesAvailable => 'Aucune scène disponible';

  @override
  String get note => 'Note';

  @override
  String get notification => 'Notification';

  @override
  String get ok => 'OK';

  @override
  String get offlineNotification => 'Notification hors ligne';

  @override
  String get open => 'Ouvrir';

  @override
  String get openSettings => 'Ouvrir les paramètres';

  @override
  String get outdoorPm25 => 'PM2.5 extérieur';

  @override
  String get outdoorAirPressure => 'Pression atmosphérique';

  @override
  String get outdoorHumidity => 'Humidité extérieure';

  @override
  String get outdoorWindSpeed => 'Vitesse du vent';

  @override
  String get pairingSuccessful => 'Appairage réussi';

  @override
  String get password => 'Mot de passe';

  @override
  String get sessionExpiredSignInAgain =>
      'Votre session a expiré. Veuillez vous reconnecter.';

  @override
  String get pleaseAddAtLeast1Action => 'Ajoutez au moins 1 action';

  @override
  String get pleaseAddAtLeast1Condition => 'Ajoutez au moins 1 condition';

  @override
  String get pleaseEnterAName => 'Veuillez saisir un nom';

  @override
  String get pleaseEnterASceneName => 'Veuillez saisir un nom de scène';

  @override
  String get pleaseSelectAFunction => 'Veuillez sélectionner une fonction';

  @override
  String get pleaseSelectATime0 => 'Veuillez choisir une durée > 0';

  @override
  String get rePairNow => 'Réappairer';

  @override
  String get rePairRequired => 'Réappairage requis';

  @override
  String get reasonOptional => 'Motif (facultatif)';

  @override
  String get refresh => 'Actualiser';

  @override
  String get reload => 'Recharger';

  @override
  String get remove => 'Retirer';

  @override
  String get removeDevice => 'Retirer l\'appareil';

  @override
  String get removed => 'Retiré';

  @override
  String get rename => 'Renommer';

  @override
  String get renameRoom => 'Renommer la pièce';

  @override
  String get renameDevice => 'Renommer l\'appareil';

  @override
  String get repeat => 'Répétition';

  @override
  String get rescan => 'Rechercher à nouveau';

  @override
  String get retry => 'Réessayer';

  @override
  String get roomManagement => 'Gestion des pièces';

  @override
  String get roomName => 'Nom de la pièce';

  @override
  String get roomUpdated => 'Pièce mise à jour';

  @override
  String get running => 'En cours';

  @override
  String get save => 'Enregistrer';

  @override
  String get sceneName => 'Nom de la scène';

  @override
  String get scenes => 'Scènes';

  @override
  String get schedule => 'Programmation';

  @override
  String get searchAddress => 'Rechercher une adresse';

  @override
  String get searchCityOrRegion => 'Rechercher une ville ou région';

  @override
  String get selectScene => 'Choisir une scène';

  @override
  String get selectSmartScenes => 'Choisir des scènes intelligentes';

  @override
  String get sendResetLink => 'Envoyer le lien de réinitialisation';

  @override
  String get sendVerificationCode => 'Envoyer le code de vérification';

  @override
  String get showOnHomePage => 'Afficher sur l\'accueil';

  @override
  String get signIn => 'Se connecter';

  @override
  String get signalStrength => 'Force du signal';

  @override
  String get signalStrength2 => 'Force du signal';

  @override
  String get startPairing => 'Démarrer l\'appairage';

  @override
  String get stop => 'Arrêter';

  @override
  String get style => 'Style';

  @override
  String get switchNetwork => 'Changer';

  @override
  String get switchToThisNetwork => 'Basculer sur ce réseau';

  @override
  String get tapToRunNotification => 'Notification Tap-to-Run';

  @override
  String get conditionThen => 'Alors';

  @override
  String get thinking => 'Réflexion…';

  @override
  String get thisActionCannotBeUndone => 'Cette action est irréversible.';

  @override
  String get thisSavedNetworkWillBeRemovedFromTheDevice =>
      'Ce réseau enregistré sera supprimé de l\'appareil.';

  @override
  String get timeZone => 'Fuseau horaire';

  @override
  String get timeZoneUpdated => 'Fuseau horaire mis à jour';

  @override
  String get timedOut => 'Délai dépassé';

  @override
  String get tryAgain => 'Réessayer';

  @override
  String get useCurrentLocation => 'Utiliser ma position';

  @override
  String get usingSiri => 'Utiliser Siri';

  @override
  String get virtualId => 'ID virtuel';

  @override
  String get whenDeviceStatusChanges => 'Quand l\'état d\'un appareil change';

  @override
  String get whenWeatherChanges => 'Quand la météo change';

  @override
  String get wiFi => 'Wi-Fi';

  @override
  String get wifiNameSsid => 'Nom du WiFi (SSID)';

  @override
  String get wifiPassword => 'Mot de passe WiFi';

  @override
  String get navHome => 'Accueil';

  @override
  String get navScenes => 'Scènes';

  @override
  String get navChat => 'Chat';

  @override
  String get navMe => 'Moi';

  @override
  String get thirdPartyServices => 'Services tiers';

  @override
  String get messageCenter => 'Centre de messages';

  @override
  String get appMall => 'Boutique d\'applis';

  @override
  String get addDevice => 'Ajouter un appareil';

  @override
  String get tapToRun => 'Exécution en un geste';

  @override
  String get automationEmptyHint =>
      'L\'automatisation vous fait gagner du temps en automatisant les tâches du quotidien.';

  @override
  String get tapToRunEmptyHint =>
      'Créez une scène en un geste pour piloter vos appareils d\'une seule pression.';

  @override
  String get scene => 'Scène';

  @override
  String get executionFailed => 'Échec de l\'exécution';

  @override
  String get device => 'Appareil';

  @override
  String get delay => 'Attente';

  @override
  String get runScene => 'Exécuter la scène';

  @override
  String get addToSiri => 'Ajouter à Siri';

  @override
  String get storeUnderPreparation =>
      'La boutique est en préparation, restez à l\'écoute.';

  @override
  String get commonFunctions => 'Fonctions courantes';

  @override
  String get noConnection => 'Aucune connexion';

  @override
  String get checkInternetAndRetry =>
      'Vérifiez votre connexion Internet et réessayez.';

  @override
  String get noConnectionCheckInternet =>
      'Aucune connexion. Vérifiez votre connexion Internet et réessayez.';

  @override
  String get addFirstCurtainHint =>
      'Touchez le bouton + pour ajouter votre premier rideau à cette maison.';

  @override
  String get hideInvisibleDevices => 'Masquer les appareils non visibles';

  @override
  String get deviceRenamed => 'Appareil renommé.';

  @override
  String get deviceDeletedReturningToPairing =>
      'Appareil supprimé. Il repasse en mode association.';

  @override
  String get homeSettings => 'Réglages de la maison';

  @override
  String get toBeSet => 'À définir';

  @override
  String get homeMember => 'Membre du foyer';

  @override
  String get memberDetails => 'Détails du membre';

  @override
  String get addMember => 'Ajouter un membre';

  @override
  String get pending => 'En attente';

  @override
  String get removesFromHomeHint =>
      'Retire de la maison ; l\'appareil repasse en mode association sous 1 à 2 minutes';

  @override
  String get unlinkAndEraseData => 'Dissocier et effacer les données';

  @override
  String get erasesAllDataHint =>
      'Efface toutes les données, action irréversible';

  @override
  String get somethingWentWrongTryAgain =>
      'Une erreur est survenue, veuillez réessayer';

  @override
  String get tapToRunAndAutomation => 'Exécution en un geste et automatisation';

  @override
  String get thirdPartyControl => 'Contrôle par services tiers';

  @override
  String get deviceOfflineNotification => 'Notification d\'appareil hors ligne';

  @override
  String get others => 'Autres';

  @override
  String get shareDevice => 'Partager l\'appareil';

  @override
  String get addToHomeScreen => 'Ajouter à l\'écran d\'accueil';

  @override
  String get checkDeviceNetwork => 'Vérifier le réseau de l\'appareil';

  @override
  String get checkNow => 'Vérifier maintenant';

  @override
  String get deviceUpdate => 'Mise à jour de l\'appareil';

  @override
  String get removeDevicesWarning =>
      'Ils seront retirés de cette maison et repasseront en mode association.';

  @override
  String get shown => 'Affiché';

  @override
  String get hidden => 'Masqué';

  @override
  String get devicesBackOnHome =>
      'Les appareils sont de nouveau sur l\'accueil';

  @override
  String get hiddenFromHome => 'Masqués de l\'accueil';

  @override
  String get offline => 'Hors ligne';

  @override
  String get show => 'Afficher';

  @override
  String get hide => 'Masquer';

  @override
  String get profilePhoto => 'Photo de profil';

  @override
  String get nickname => 'Pseudo';

  @override
  String get noRoomsYet => 'Aucune pièce';

  @override
  String get tapPlusToAddRoom => 'Touchez + pour ajouter une pièce';

  @override
  String get emailAddressLabel => 'Adresse e-mail';

  @override
  String get notSet => 'Non défini';

  @override
  String get deviceInformation => 'Informations sur l\'appareil';

  @override
  String get unknown => 'Inconnu';

  @override
  String get notReported => 'Non communiqué';

  @override
  String get noScenesUseThisDevice =>
      'Aucune scène n\'utilise encore cet appareil.';

  @override
  String get tapToRunLabel => 'Exécution en un geste';

  @override
  String get automation => 'Automatisation';

  @override
  String get forward => 'Sens normal';

  @override
  String get back => 'Sens inverse';

  @override
  String get setting => 'Réglage';

  @override
  String get updateAvailable => 'Mise à jour disponible';

  @override
  String get noUpdatesAvailable => 'Aucune mise à jour disponible';

  @override
  String get updateNow => 'Mettre à jour';

  @override
  String get unassigned => 'Non attribué';

  @override
  String get enterEmailOrUsername =>
      'Saisissez votre e-mail ou nom d\'utilisateur';

  @override
  String get welcome => 'Bienvenue';

  @override
  String get signInSubtitle => 'Connectez-vous à votre compte osprey.life.';

  @override
  String get createOne => 'Créer un compte';

  @override
  String get forgotPassword => 'Mot de passe oublié ?';

  @override
  String get orContinueWith => 'ou continuer avec';

  @override
  String get enterValidEmail => 'Saisissez une adresse e-mail valide';

  @override
  String get resetYourPassword => 'Réinitialiser votre mot de passe';

  @override
  String get checkYourInbox => 'Consultez votre boîte de réception';

  @override
  String get enterYourEmailAddress => 'Saisissez votre adresse e-mail';

  @override
  String get enterSixDigitCode => 'Saisissez le code à 6 chiffres';

  @override
  String get enterAPassword => 'Saisissez un mot de passe';

  @override
  String get createYourAccount => 'Créez votre compte';

  @override
  String get checkYourEmail => 'Consultez vos e-mails';

  @override
  String get resendCode => 'Renvoyer le code';

  @override
  String get userAgreement => 'Conditions d\'utilisation';

  @override
  String get reconnecting => 'Reconnexion…';

  @override
  String get checkWifiOrBluetooth =>
      'Vérifiez le Wi-Fi ou rapprochez-vous pour le Bluetooth.';

  @override
  String get smartScenesRequireInternet =>
      'Les scènes intelligentes nécessitent Internet';

  @override
  String get enterWifiName => 'Saisissez le nom du Wi-Fi';

  @override
  String get wifiNameLengthError =>
      'Le nom du Wi-Fi doit comporter de 1 à 32 caractères';

  @override
  String get passwordMin8 =>
      'Le mot de passe doit comporter au moins 8 caractères';

  @override
  String get passwordLength863 =>
      'Le mot de passe doit comporter de 8 à 63 caractères';

  @override
  String get networkAlreadySaved =>
      'Ce réseau est déjà enregistré. Pour changer son mot de passe, supprimez-le puis ajoutez-le à nouveau.';

  @override
  String get addWifiNetwork => 'Ajouter un réseau Wi-Fi';

  @override
  String get atLeast8Characters => 'Au moins 8 caractères';

  @override
  String get only24GhzSupported =>
      'Les rideaux ne prennent en charge que le Wi-Fi 2,4 GHz (WPA2).';

  @override
  String get labelOptional => 'Libellé (facultatif)';

  @override
  String get createGroup => 'Créer un groupe';

  @override
  String get groupControlHint =>
      'Les appareils d\'un même groupe peuvent être pilotés ensemble.';

  @override
  String get devicesToBeAdded => 'Appareils à ajouter';

  @override
  String get noSameTypeDevices =>
      'Aucun autre appareil du même type dans cette maison.';

  @override
  String get couldNotLoadNetworkDetails =>
      'Impossible de charger les détails du réseau. Tirez pour actualiser.';

  @override
  String get alreadyOnThisNetwork => 'Déjà connecté à ce réseau.';

  @override
  String get deviceOfflineTryLater =>
      'L\'appareil est hors ligne : réessayez plus tard.';

  @override
  String get wrongPassword => 'Mot de passe incorrect';

  @override
  String get networkNotFound => 'Réseau introuvable';

  @override
  String get networkRemoved => 'Réseau supprimé.';

  @override
  String get network => 'Réseau';

  @override
  String get connectedTo => 'Connecté à';

  @override
  String get savedNetworks => 'Réseaux enregistrés';

  @override
  String get addANetwork => 'Ajouter un réseau';

  @override
  String get notConnected => 'Non connecté';

  @override
  String get pleaseKeepAppOpen => 'Veuillez laisser l\'appli ouverte.';

  @override
  String get deviceNetworkInformation => 'Informations réseau de l\'appareil';

  @override
  String get once => 'Une seule fois';

  @override
  String get editSchedule => 'Modifier la programmation';

  @override
  String get addSchedule => 'Ajouter une programmation';

  @override
  String get timeVarianceHint => 'L\'écart de temps est d\'environ ±30 s';

  @override
  String get noTimerData => 'Aucune donnée de minuterie';

  @override
  String get localControlUnsupportedAction =>
      'Le contrôle local ne prend pas en charge cette action';

  @override
  String get noInternetNoBluetooth =>
      'Pas d\'Internet et Bluetooth hors de portée';

  @override
  String get connectionError => 'Erreur de connexion';

  @override
  String get exampleTapToRun =>
      'Exemple : éteindre toutes les lumières de la chambre d\'une seule pression.';

  @override
  String get exampleWeather =>
      'Exemple : lorsque la température locale dépasse 28 °C.';

  @override
  String get weatherTrigger => 'Déclencheur météo';

  @override
  String get exampleSchedule => 'Exemple : à 7h00 chaque matin.';

  @override
  String get exampleDeviceStatus =>
      'Exemple : lorsqu\'une activité inhabituelle est détectée.';

  @override
  String get deviceStatusTrigger => 'Déclencheur d\'état d\'appareil';

  @override
  String get noNotificationsYet => 'Aucune notification';

  @override
  String get slashCommands => 'Commandes slash';

  @override
  String get slashDevicesHint => 'Parcourir et piloter vos rideaux.';

  @override
  String get slashSceneHint => 'Exécuter une scène en un geste.';

  @override
  String get slashScheduleHint => 'Ouvrir la programmation d\'automatisation.';

  @override
  String get slashHelpHint => 'Afficher cette liste.';

  @override
  String get youCanAlsoSpeak =>
      'Vous pouvez aussi parler : touchez le bouton micro.';

  @override
  String get chatInputHint =>
      'Écrivez, parlez ou utilisez les commandes slash.';

  @override
  String get online => 'En ligne';

  @override
  String get blePermissionRequired =>
      'L\'autorisation Bluetooth est requise pour trouver des appareils';

  @override
  String get bleAndLocationPermissionRequired =>
      'Les autorisations Bluetooth et Localisation sont requises pour trouver des appareils';

  @override
  String get addDeviceLower => 'Ajouter un appareil';

  @override
  String get scanningStopped => 'Recherche arrêtée.';

  @override
  String get enterWifiPassword => 'Saisissez le mot de passe du Wi-Fi';

  @override
  String get detectingCurrentWifi => 'Détection du Wi-Fi actuel...';

  @override
  String get autoDetectedWifi =>
      'Détecté automatiquement depuis le Wi-Fi auquel votre téléphone est connecté';

  @override
  String get couldNotDetectWifi =>
      'Wi-Fi non détecté : saisissez le nom du réseau manuellement';

  @override
  String get beingAdded => 'Ajout en cours';

  @override
  String get addedSuccessfully => 'Ajouté avec succès';

  @override
  String get pairingFailed => 'Échec de l\'association';

  @override
  String get allDay => 'Toute la journée';

  @override
  String get whenAnyConditionMet => 'Lorsqu\'une condition est remplie';

  @override
  String get whenAllConditionsMet =>
      'Lorsque toutes les conditions sont remplies';

  @override
  String get deleteSceneWarning =>
      'Après la suppression du scénario, les tâches des appareils ne pourront plus s\'exécuter correctement.';

  @override
  String get toggleAutomation => 'Activer/désactiver l\'automatisation';

  @override
  String get enable => 'Activer';

  @override
  String get disable => 'Désactiver';

  @override
  String get everyDay => 'Tous les jours';

  @override
  String get monToFri => 'Lun - Ven';

  @override
  String get satToSun => 'Sam - Dim';

  @override
  String get runOnceIfNoDaySelected =>
      'L\'action ne sera exécutée qu\'une seule fois si vous ne sélectionnez aucun jour de la semaine.';

  @override
  String get sendNotification => 'Envoyer une notification';

  @override
  String get color => 'Couleur';

  @override
  String get wait => 'Attendre';

  @override
  String get finish => 'Terminer';

  @override
  String get selectFunction => 'Sélectionner une fonction';

  @override
  String get on => 'Activé';

  @override
  String get off => 'Désactivé';

  @override
  String get siriShortcut => 'Raccourci Siri';

  @override
  String get createTapToRunFirst => 'Créez d\'abord une scène en un geste.';

  @override
  String get poweredByFoundationModels =>
      'Propulsé par Apple Foundation Models, sur l\'appareil.';

  @override
  String get weatherClearNight => 'Nuit dégagée';

  @override
  String get weatherSunny => 'Ensoleillé';

  @override
  String get weatherPartlyCloudy => 'Partiellement nuageux';

  @override
  String get weatherCloudy => 'Nuageux';

  @override
  String get qualityExcellent => 'Excellente';

  @override
  String get qualityGood => 'Bonne';

  @override
  String get qualityModerate => 'Moyenne';

  @override
  String get qualityPoor => 'Mauvaise';

  @override
  String get qualityVeryPoor => 'Très mauvaise';

  @override
  String get switchLocation => 'Changer de lieu';

  @override
  String get aiSuggestion => 'Suggestion IA';

  @override
  String get listening => 'Écoute…';

  @override
  String get parsing => 'Analyse…';

  @override
  String get getStarted => 'Commencer';

  @override
  String get aiChatEmptyState =>
      'Posez à l\'assistant osprey.life toutes vos questions sur vos rideaux.\nPropulsé par Apple Foundation Models, sur l\'appareil.';

  @override
  String get chatHeaderSubtitle =>
      'L\'IA embarquée pour vos rideaux motorisés.\nÉcrivez, parlez ou utilisez les commandes slash.';

  @override
  String get daySunShort => 'Dim.';

  @override
  String get dayMonShort => 'Lun.';

  @override
  String get dayTueShort => 'Mar.';

  @override
  String get dayWedShort => 'Mer.';

  @override
  String get dayThuShort => 'Jeu.';

  @override
  String get dayFriShort => 'Ven.';

  @override
  String get daySatShort => 'Sam.';

  @override
  String get dayMon => 'Lun';

  @override
  String get dayTue => 'Mar';

  @override
  String get dayWed => 'Mer';

  @override
  String get dayThu => 'Jeu';

  @override
  String get dayFri => 'Ven';

  @override
  String get daySat => 'Sam';

  @override
  String get daySun => 'Dim';

  @override
  String get accountLinkedSuccessfully => 'Compte associé avec succès !';

  @override
  String get linkingFailed => 'Échec de l\'association';

  @override
  String get anErrorOccurredTryAgain =>
      'Une erreur est survenue. Veuillez réessayer.';

  @override
  String get signInWithAmazon => 'Se connecter avec Amazon';

  @override
  String get viewMoreWaysToLink => 'Voir d\'autres façons d\'associer';

  @override
  String get alreadyLinkedWithAlexa => 'Déjà associé à Amazon Alexa';

  @override
  String get somethingWentWrong => 'Une erreur est survenue';

  @override
  String get noAuthorizationCode => 'Aucun code d\'autorisation reçu';

  @override
  String get couldNotOpenGoogleHome =>
      'Impossible d\'ouvrir l\'appli Google Home';

  @override
  String get reLogin => 'Se reconnecter';

  @override
  String get linkWithGoogleAssistant => 'Associer à l\'Assistant Google';

  @override
  String get linkedWithGoogleAssistant => 'Associé à l\'Assistant Google';

  @override
  String get anErrorOccurred => 'Une erreur est survenue';

  @override
  String deleteHomeConfirm(String name) {
    return 'Voulez-vous vraiment supprimer « $name » ? Cette action est irréversible.';
  }

  @override
  String get offlineScenesBody =>
      'Les scènes et programmations sont suspendues jusqu\'au retour du Wi-Fi. Le contrôle local par Bluetooth continue de fonctionner pour ouvrir, fermer et arrêter chaque appareil.';

  @override
  String get blePairingLostBody =>
      'Le contrôle local par Bluetooth doit être réassocié à cet appareil. Cela arrive généralement après l\'effacement des données de l\'appli ou une réinitialisation de l\'appareil.';

  @override
  String get alternateNetworkHint =>
      'Si le réseau actuel est indisponible, l\'appareil se connectera automatiquement à un réseau de secours.';

  @override
  String get switchNetworkWarning =>
      'L\'appareil va se déconnecter de son Wi-Fi actuel et tenter de rejoindre le nouveau. Cela prend généralement de 5 à 30 secondes.';

  @override
  String get runOnceIfNoDayPicked =>
      'L\'action ne sera exécutée qu\'une seule fois si vous ne la sélectionnez pas.';

  @override
  String get alexaUnlinkHint =>
      'Désactivez la skill osprey.life dans l\'appli Amazon Alexa, ou touchez Moi > le bouton Réglages en haut à droite > Compte et sécurité pour retirer l\'autorisation.';

  @override
  String get alexaLinkExplainer =>
      'Associer votre compte de l\'appli à votre compte Amazon vous permet de piloter les appareils compatibles Alexa via les enceintes Amazon Echo (ex. « Alexa, turn on light. »)';

  @override
  String get chatScheduleHelp =>
      'Configurez des programmations automatiques pour vos rideaux. Ouvrez l\'onglet Scènes pour créer des automatisations quotidiennes, hebdomadaires ou ponctuelles.';

  @override
  String get chatScenesHelp =>
      'Créez et gérez des scènes en un geste depuis l\'onglet Scènes. Les scènes permettent d\'enchaîner plusieurs actions de rideau avec des attentes, en une seule pression.';

  @override
  String get googleUnlinkHint =>
      'Désactivez la skill osprey.life dans l\'appli Google Home, ou touchez Moi > le bouton Réglages en haut à droite > Compte et sécurité pour retirer l\'autorisation.';

  @override
  String get googleLinkExplainer =>
      'Après avoir connecté votre compte de l\'appli et votre compte Google, vous pourrez utiliser les enceintes connectées Google Home pour piloter les appareils compatibles avec l\'Assistant Google. Par exemple, vous pouvez dire : « OK Google, please turn on the light. »';

  @override
  String get deviceDisconnectedFromHome =>
      'Appareil dissocié de la maison. Il repassera en mode association sous 1 à 2 minutes.';

  @override
  String get searchingNearbyDevices =>
      'Recherche d\'appareils Osprey à proximité. Assurez-vous que l\'appareil est en mode association.';

  @override
  String get looksLike5GhzHint =>
      'Ce réseau semble être en 5 GHz : basculez votre téléphone sur un réseau 2,4 GHz, puis touchez Actualiser.';

  @override
  String get pairingWifiHint =>
      'L\'appareil se connectera au Wi-Fi utilisé par votre téléphone. Seuls les réseaux 2,4 GHz sont pris en charge.';

  @override
  String get siriShortcutsHelp =>
      'Touchez une scène pour enregistrer une phrase vocale, puis dites « Dis Siri » suivi de cette phrase pour l\'exécuter, même appli fermée.\n\nTouchez une scène déjà ajoutée pour modifier sa phrase ou la retirer.';

  @override
  String get deleteAccountWarning =>
      'Après la suppression :\n• Votre compte sera supprimé au bout de 30 jours\n• Tous vos appareils et scènes seront retirés\n• Vous pouvez annuler en vous reconnectant sous 30 jours';

  @override
  String aiSuggestionBody(String action, String weekday, String hour) {
    return 'Vous exécutez habituellement « $action » le $weekday à ${hour}h00 — l\'automatiser ?';
  }

  @override
  String removeDeviceConfirm(String name) {
    return '« $name » sera retiré de votre maison et repassera automatiquement en mode association sous 1 à 2 minutes.';
  }

  @override
  String eraseDeviceConfirm(String name) {
    return 'Toutes les données de « $name » seront effacées et NE pourront pas être récupérées. Voulez-vous continuer ?';
  }

  @override
  String showInvisibleDevices(int count) {
    return 'Afficher les appareils non visibles ($count)';
  }

  @override
  String resetLinkSent(String email) {
    return 'Si un compte existe pour $email, un lien de réinitialisation du mot de passe est en route.';
  }

  @override
  String signInNotAvailable(String name) {
    return 'La connexion via $name n\'est pas encore disponible.';
  }

  @override
  String resendCodeIn(int seconds) {
    return 'Renvoyer le code dans $seconds s';
  }

  @override
  String deleteConfirmNamed(String name) {
    return 'Voulez-vous vraiment supprimer « $name » ?';
  }

  @override
  String taskCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tâches',
      one: '1 tâche',
    );
    return '$_temp0';
  }

  @override
  String featureComingSoonShort(String feature) {
    return '$feature arrive bientôt';
  }

  @override
  String roomCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count pièces',
      one: '1 pièce',
    );
    return '$_temp0';
  }

  @override
  String removeDevicesQ(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Retirer $count appareils ?',
      one: 'Retirer l\'appareil ?',
    );
    return '$_temp0';
  }

  @override
  String devicesRemoved(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count appareils retirés',
      one: '1 appareil retiré',
    );
    return '$_temp0';
  }

  @override
  String deviceCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count appareils',
      one: '1 appareil',
    );
    return '$_temp0';
  }

  @override
  String mainModuleVersion(String version) {
    return 'Module principal : V$version';
  }

  @override
  String outdoorTemperatureValue(int temp) {
    return 'Température extérieure : $temp °C';
  }

  @override
  String occurrencesIn30Days(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count fois en 30 jours',
      one: '1 fois en 30 jours',
    );
    return '$_temp0';
  }

  @override
  String sceneExecuted(String name) {
    return '« $name » exécutée';
  }

  @override
  String couldNotRunScene(String name) {
    return 'Impossible d\'exécuter « $name ». Veuillez réessayer.';
  }

  @override
  String featureComingSoonNamed(String feature) {
    return '$feature arrive bientôt.';
  }

  @override
  String get couldNotLoadHome =>
      'Impossible de charger votre maison. Veuillez réessayer.';

  @override
  String deviceCouldNotConnectTo(String ssid, String reason, String stayedOn) {
    return 'L\'appareil n\'a pas pu se connecter à « $ssid ».\n\nRaison : $reason\n\nL\'appareil est toujours connecté à « $stayedOn ».';
  }

  @override
  String makeSureNetworkInRange(String ssid) {
    return '\n\nAssurez-vous que « $ssid » est activé et à portée.';
  }

  @override
  String get noResponseFromDevice =>
      'Nous n\'avons pas reçu de réponse de l\'appareil. Actualisez dans un instant pour voir son état actuel.';

  @override
  String devicesBeingAdded(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Ajout de $count appareils',
      one: 'Ajout de 1 appareil',
    );
    return '$_temp0';
  }

  @override
  String devicesAddedSuccessfully(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count appareils ajoutés avec succès',
      one: '1 appareil ajouté avec succès',
    );
    return '$_temp0';
  }

  @override
  String get alexaExamplesIntro =>
      'Vous pouvez piloter les appareils compatibles Alexa\navec les enceintes Amazon Alexa, par exemple';

  @override
  String get googleExamplesIntro =>
      'Vous pouvez désormais utiliser l\'enceinte Google Home pour\npiloter les appareils de l\'Assistant Google, comme';

  @override
  String get gridView => 'Vue en grille';

  @override
  String get listView => 'Vue en liste';

  @override
  String get deviceManagement => 'Gestion des appareils';

  @override
  String get sort => 'Trier';

  @override
  String get darkMode => 'Mode sombre';

  @override
  String get followSystem => 'Suivre le système';

  @override
  String get system => 'Système';

  @override
  String get systemDarkModeHint =>
      'Lorsque cette option est activée, l\'appli active ou désactive le mode sombre selon les réglages de votre système.';

  @override
  String get normalMode => 'Mode normal';

  @override
  String get deviceStatus => 'État de l\'appareil';

  @override
  String get selectDevice => 'Sélectionner un appareil';

  @override
  String get condition => 'Condition';

  @override
  String get precondition => 'Condition préalable';

  @override
  String get customTime => 'Personnalisé';

  @override
  String get startTime => 'Heure de début';

  @override
  String get endTime => 'Heure de fin';

  @override
  String get overnightNote =>
      'Cette période passe minuit. Elle est comptée à partir du jour où elle commence.';

  @override
  String get automationDelayNote =>
      'S\'exécute environ 5 secondes après le changement, puis marque une pause de 60 secondes. Une nouvelle automatisation ne s\'exécute pas si sa condition est déjà remplie — seulement au changement suivant.';

  @override
  String get selectCity => 'Sélectionner une ville';

  @override
  String get searchCity => 'Rechercher une ville';

  @override
  String get equals => 'Égal à';

  @override
  String get notEquals => 'Différent de';

  @override
  String get greaterThan => 'Supérieur à';

  @override
  String get greaterOrEqual => 'Supérieur ou égal à';

  @override
  String get lessThan => 'Inférieur à';

  @override
  String get lessOrEqual => 'Inférieur ou égal à';

  @override
  String get noReadableDataPoints =>
      'Cet appareil n\'a aucun état lisible utilisable comme condition.';

  @override
  String get bluetoothOffMessage =>
      'Le Bluetooth est désactivé — activez-le pour trouver les appareils à proximité';
}
