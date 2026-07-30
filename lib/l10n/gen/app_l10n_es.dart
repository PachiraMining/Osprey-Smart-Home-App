// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_l10n.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppL10nEs extends AppL10n {
  AppL10nEs([String locale = 'es']) : super(locale);

  @override
  String get settingsTitle => 'Ajustes';

  @override
  String get personalInformation => 'Información personal';

  @override
  String get accountAndSecurity => 'Cuenta y seguridad';

  @override
  String get touchToneOnPanel => 'Sonido táctil del panel';

  @override
  String get aiAssistant => 'Asistente de IA';

  @override
  String get temperatureUnit => 'Unidad de temperatura';

  @override
  String get about => 'Acerca de';

  @override
  String get networkDiagnosis => 'Diagnóstico de red';

  @override
  String get clearCache => 'Borrar caché';

  @override
  String get language => 'Idioma';

  @override
  String get logOut => 'Cerrar sesión';

  @override
  String get languageSystemDefault => 'Igual que el idioma del sistema';

  @override
  String get languageEnglish => 'Inglés';

  @override
  String get languageVietnamese => 'Vietnamita';

  @override
  String get clearCacheMessage =>
      'Las escenas, los datos de la casa y las imágenes en caché se volverán a descargar cuando los uses. Tu cuenta y tus dispositivos no se verán afectados.';

  @override
  String get clear => 'Borrar';

  @override
  String get cancel => 'Cancelar';

  @override
  String freedSpace(String size) {
    return 'Se liberaron $size';
  }

  @override
  String aboutVersion(String version, String build) {
    return 'Versión $version ($build)';
  }

  @override
  String get privacyPolicy => 'Política de privacidad';

  @override
  String get termsOfService => 'Términos del servicio';

  @override
  String get bundleId => 'Bundle ID';

  @override
  String get server => 'Servidor';

  @override
  String get couldNotOpenLink => 'No se pudo abrir el enlace.';

  @override
  String get diagLocalNetwork => 'Red local';

  @override
  String get diagLocalNetworkNoWifi =>
      'Sin Wi-Fi (datos móviles o permiso denegado)';

  @override
  String get diagLocalNetworkUnreadable =>
      'No se pudo leer el nombre de la Wi-Fi';

  @override
  String get diagDnsLookup => 'Consulta DNS';

  @override
  String diagDnsFailed(String host) {
    return 'No se puede resolver $host';
  }

  @override
  String get diagServerReachable => 'Servidor accesible';

  @override
  String diagServerLatency(String ms, String status) {
    return '$ms ms · HTTP $status';
  }

  @override
  String get diagServerNoResponse => 'El servidor no responde';

  @override
  String get diagSignedIn => 'Sesión iniciada';

  @override
  String get diagSessionValid => 'Sesión válida';

  @override
  String diagSessionInvalid(String status) {
    return 'HTTP $status — inicia sesión de nuevo';
  }

  @override
  String get diagSessionUnverified => 'No se pudo verificar la sesión';

  @override
  String get diagControlChannel => 'Canal de control';

  @override
  String get diagCloudConnected => 'Nube (MQTT) conectada';

  @override
  String get diagBleFallback => 'Nube caída — usando Bluetooth';

  @override
  String get diagUnreachable => 'Sin nube ni Bluetooth cerca';

  @override
  String get diagStatusUnknown => 'Estado desconocido';

  @override
  String get runAgain => 'Repetir';

  @override
  String get accountCreatedPleaseSignIn => 'Cuenta creada: inicia sesión.';

  @override
  String get add => 'Añadir';

  @override
  String get addCondition => 'Añadir condición';

  @override
  String get addRoom => 'Añadir habitación';

  @override
  String get addTask => 'Añadir tarea';

  @override
  String get addAtLeastTwoDevicesToAGroup =>
      'Añade al menos dos dispositivos a un grupo.';

  @override
  String get alexa => 'Alexa';

  @override
  String get all => 'Todos';

  @override
  String get allDevices => 'Todos los dispositivos';

  @override
  String get alternateNetwork => 'Red alternativa';

  @override
  String get apply => 'Aplicar';

  @override
  String get areYouSureYouWantToLogOut => '¿Seguro que quieres cerrar sesión?';

  @override
  String get askAboutYourCurtainsOrTryHelp =>
      'Pregunta por tus cortinas o prueba /help…';

  @override
  String get askAboutYourCurtains => 'Pregunta por tus cortinas…';

  @override
  String get atLeast6Characters => 'Mínimo 6 caracteres';

  @override
  String get authDiagnostics => 'Diagnóstico de acceso';

  @override
  String get automationNotification => 'Aviso de automatización';

  @override
  String get changeRoom => 'Cambiar habitación';

  @override
  String get close => 'Cerrar';

  @override
  String get cloud => 'Nube';

  @override
  String get confirm => 'Confirmar';

  @override
  String get connected => 'Conectado';

  @override
  String get control => 'Control';

  @override
  String get controlSingleDevice => 'Controlar un dispositivo';

  @override
  String get copiedToClipboard => 'Copiado al portapapeles';

  @override
  String get copy => 'Copiar';

  @override
  String get couldNotChangeTheMotorDirectionPleaseTryAgai =>
      'No se pudo cambiar el sentido del motor. Inténtalo de nuevo.';

  @override
  String get couldNotConnect => 'No se pudo conectar';

  @override
  String get couldNotCreateTheGroupPleaseTryAgain =>
      'No se pudo crear el grupo. Inténtalo de nuevo.';

  @override
  String get couldNotOpenTheBrowser => 'No se pudo abrir el navegador.';

  @override
  String get couldNotSendTheCommandPleaseTryAgain =>
      'No se pudo enviar el comando. Inténtalo de nuevo.';

  @override
  String get create => 'Crear';

  @override
  String get createScene => 'Crear escena';

  @override
  String get createAHome => 'Crear una casa';

  @override
  String get createARoomFirst => 'Crea antes una habitación.';

  @override
  String get createAccount => 'Crear cuenta';

  @override
  String get createScene2 => 'Crear escena';

  @override
  String get curtainPosition => 'Posición de la cortina';

  @override
  String get curtainPositionSetting => 'Ajuste de posición de la cortina';

  @override
  String get customDeviceIconsAreNotSupportedYet =>
      'Aún no se admiten iconos personalizados.';

  @override
  String get delayTheAction => 'Retrasar la acción';

  @override
  String get delete => 'Eliminar';

  @override
  String get deleteAccount => 'Eliminar cuenta';

  @override
  String get deleteHome => 'Eliminar casa';

  @override
  String get deleteRoom => 'Eliminar habitación';

  @override
  String get deleteSchedule => 'Eliminar programación';

  @override
  String get deleteScene => '¿Eliminar la escena?';

  @override
  String get deleteThisSchedule => '¿Eliminar esta programación?';

  @override
  String get deviceNetwork => 'Red del dispositivo';

  @override
  String get deviceHasNoProfileInformation =>
      'El dispositivo no tiene información de perfil';

  @override
  String get deviceIsOffline => 'Dispositivo sin conexión';

  @override
  String get deviceIsReady => 'El dispositivo está listo.';

  @override
  String get deviceName => 'Nombre del dispositivo';

  @override
  String get deviceRemovedFromHome => 'Dispositivo eliminado de la casa.';

  @override
  String get deviceUnreachable => 'Dispositivo no accesible';

  @override
  String get devices => 'Dispositivos';

  @override
  String get disconnect => 'Desconectar';

  @override
  String get disconnectDevice => '¿Desconectar el dispositivo?';

  @override
  String get done => 'Hecho';

  @override
  String get emailAddress => 'Correo electrónico';

  @override
  String get emailOrUsername => 'Correo o usuario';

  @override
  String get enterAGroupName => 'Escribe un nombre de grupo';

  @override
  String get enterANote => 'Escribe una nota';

  @override
  String get enterDeviceName => 'Escribe el nombre del dispositivo';

  @override
  String get enterHomeName => 'Escribe el nombre de la casa';

  @override
  String get enterName => 'Escribe un nombre';

  @override
  String get enterSceneName => 'Escribe el nombre de la escena';

  @override
  String get enterValue => 'Escribe un valor...';

  @override
  String get enterYourPassword => 'Escribe tu contraseña';

  @override
  String get eraseDeviceData => '¿Borrar los datos del dispositivo?';

  @override
  String get error => 'Error';

  @override
  String get executedBy => 'Ejecutado por';

  @override
  String get executionTime => 'Hora de ejecución';

  @override
  String get faqFeedback => 'Preguntas y sugerencias';

  @override
  String get failed => 'Fallido';

  @override
  String get featureComingSoon => 'Función disponible pronto';

  @override
  String get firmware => 'Firmware';

  @override
  String get firmwareUpdateIsComingSoon =>
      'La actualización de firmware llegará pronto.';

  @override
  String get firstName => 'Nombre';

  @override
  String get firstNameOptional => 'Nombre (opcional)';

  @override
  String get goBack => 'Volver';

  @override
  String get googleAssistant => 'Google Assistant';

  @override
  String get gotIt => 'Entendido';

  @override
  String get groupName => 'Nombre del grupo';

  @override
  String get help => 'Ayuda';

  @override
  String get homeManagement => 'Gestión de casas';

  @override
  String get homeName => 'Nombre de la casa';

  @override
  String get homeName2 => 'Nombre de la casa';

  @override
  String get icon => 'Icono';

  @override
  String get conditionIf => 'Si';

  @override
  String get joinAHome => 'Unirse a una casa';

  @override
  String get joiningAHomeByInviteIsComingSoon =>
      'Unirse a una casa por invitación llegará pronto.';

  @override
  String get lastName => 'Apellidos';

  @override
  String get lastNameOptional => 'Apellidos (opcional)';

  @override
  String get later => 'Más tarde';

  @override
  String get launchTapToRun => 'Ejecutar Tap-to-Run';

  @override
  String get localAssociation => 'Asociación local';

  @override
  String get localControlOffline => 'Control local (sin conexión)';

  @override
  String get location => 'Ubicación';

  @override
  String get logCopiedToClipboard => 'Registro copiado al portapapeles';

  @override
  String get logs => 'Registros';

  @override
  String get manage => 'Gestionar';

  @override
  String get managePermissions => 'Gestionar permisos';

  @override
  String get markAllAsRead => 'Marcar todo como leído';

  @override
  String get moreSettings => 'Más ajustes';

  @override
  String get motorDirection => 'Sentido del motor';

  @override
  String get moveToTop => 'Mover arriba';

  @override
  String get moveToRoom => 'Mover a habitación';

  @override
  String get moved => 'Movido';

  @override
  String get movedToTop => 'Movido arriba';

  @override
  String get name => 'Nombre';

  @override
  String get next => 'Siguiente';

  @override
  String get noDevicesAvailable => 'No hay dispositivos disponibles';

  @override
  String get noDevicesFound => 'No se encontraron dispositivos.';

  @override
  String get noDevicesInThisHome => 'No hay dispositivos en esta casa.';

  @override
  String get noDevicesYet => 'Aún no hay dispositivos';

  @override
  String get noFunctionsAvailable => 'No hay funciones disponibles';

  @override
  String get noHomeSelectedPleaseTryAgain =>
      'No hay casa seleccionada, inténtalo de nuevo';

  @override
  String get noMatchingTimeZones => 'No hay zonas horarias coincidentes';

  @override
  String get noOtherScenesAvailable => 'No hay otras escenas disponibles';

  @override
  String get noRooms => 'Sin habitaciones';

  @override
  String get noSavedNetworksYet => 'Aún no hay redes guardadas.';

  @override
  String get noScenes => 'Sin escenas';

  @override
  String get noScenesAvailable => 'No hay escenas disponibles';

  @override
  String get note => 'Nota';

  @override
  String get notification => 'Notificación';

  @override
  String get ok => 'Aceptar';

  @override
  String get offlineNotification => 'Aviso de desconexión';

  @override
  String get open => 'Abrir';

  @override
  String get openSettings => 'Abrir ajustes';

  @override
  String get outdoorPm25 => 'PM2.5 exterior';

  @override
  String get outdoorAirPressure => 'Presión del aire exterior';

  @override
  String get outdoorHumidity => 'Humedad exterior';

  @override
  String get outdoorWindSpeed => 'Velocidad del viento exterior';

  @override
  String get pairingSuccessful => 'Emparejamiento correcto';

  @override
  String get password => 'Contraseña';

  @override
  String get sessionExpiredSignInAgain =>
      'La sesión ha caducado. Inicia sesión de nuevo.';

  @override
  String get pleaseAddAtLeast1Action => 'Añade al menos 1 acción';

  @override
  String get pleaseAddAtLeast1Condition => 'Añade al menos 1 condición';

  @override
  String get pleaseEnterAName => 'Escribe un nombre';

  @override
  String get pleaseEnterASceneName => 'Escribe un nombre de escena';

  @override
  String get pleaseSelectAFunction => 'Selecciona una función';

  @override
  String get pleaseSelectATime0 => 'Selecciona un tiempo > 0';

  @override
  String get rePairNow => 'Emparejar de nuevo';

  @override
  String get rePairRequired => 'Hay que emparejar de nuevo';

  @override
  String get reasonOptional => 'Motivo (opcional)';

  @override
  String get refresh => 'Actualizar';

  @override
  String get reload => 'Recargar';

  @override
  String get remove => 'Quitar';

  @override
  String get removeDevice => 'Quitar dispositivo';

  @override
  String get removed => 'Eliminado';

  @override
  String get rename => 'Renombrar';

  @override
  String get renameRoom => 'Renombrar habitación';

  @override
  String get renameDevice => 'Renombrar dispositivo';

  @override
  String get repeat => 'Repetir';

  @override
  String get rescan => 'Volver a buscar';

  @override
  String get retry => 'Reintentar';

  @override
  String get roomManagement => 'Gestión de habitaciones';

  @override
  String get roomName => 'Nombre de la habitación';

  @override
  String get roomUpdated => 'Habitación actualizada';

  @override
  String get running => 'En ejecución';

  @override
  String get save => 'Guardar';

  @override
  String get sceneName => 'Nombre de la escena';

  @override
  String get scenes => 'Escenas';

  @override
  String get schedule => 'Programación';

  @override
  String get searchAddress => 'Buscar dirección';

  @override
  String get searchCityOrRegion => 'Buscar ciudad o región';

  @override
  String get selectScene => 'Seleccionar escena';

  @override
  String get selectSmartScenes => 'Seleccionar escenas inteligentes';

  @override
  String get sendResetLink => 'Enviar enlace de recuperación';

  @override
  String get sendVerificationCode => 'Enviar código de verificación';

  @override
  String get showOnHomePage => 'Mostrar en la pantalla de inicio';

  @override
  String get signIn => 'Iniciar sesión';

  @override
  String get signalStrength => 'Intensidad de señal';

  @override
  String get signalStrength2 => 'Intensidad de señal';

  @override
  String get startPairing => 'Iniciar emparejamiento';

  @override
  String get stop => 'Detener';

  @override
  String get style => 'Estilo';

  @override
  String get switchNetwork => 'Cambiar';

  @override
  String get switchToThisNetwork => 'Cambiar a esta red';

  @override
  String get tapToRunNotification => 'Aviso de Tap-to-Run';

  @override
  String get conditionThen => 'Entonces';

  @override
  String get thinking => 'Pensando…';

  @override
  String get thisActionCannotBeUndone => 'Esta acción no se puede deshacer.';

  @override
  String get thisSavedNetworkWillBeRemovedFromTheDevice =>
      'Esta red guardada se eliminará del dispositivo.';

  @override
  String get timeZone => 'Zona horaria';

  @override
  String get timeZoneUpdated => 'Zona horaria actualizada';

  @override
  String get timedOut => 'Tiempo agotado';

  @override
  String get tryAgain => 'Inténtalo de nuevo';

  @override
  String get useCurrentLocation => 'Usar ubicación actual';

  @override
  String get usingSiri => 'Usar Siri';

  @override
  String get virtualId => 'ID virtual';

  @override
  String get whenDeviceStatusChanges =>
      'Cuando cambie el estado del dispositivo';

  @override
  String get whenWeatherChanges => 'Cuando cambie el tiempo';

  @override
  String get wiFi => 'Wi-Fi';

  @override
  String get wifiNameSsid => 'Nombre de la WiFi (SSID)';

  @override
  String get wifiPassword => 'Contraseña de la WiFi';

  @override
  String get navHome => 'Inicio';

  @override
  String get navScenes => 'Escenas';

  @override
  String get navChat => 'Chat';

  @override
  String get navMe => 'Yo';

  @override
  String get thirdPartyServices => 'Servicios de terceros';

  @override
  String get messageCenter => 'Centro de mensajes';

  @override
  String get appMall => 'Tienda de apps';

  @override
  String get addDevice => 'Añadir dispositivo';

  @override
  String get tapToRun => 'Pulsar para ejecutar';

  @override
  String get automationEmptyHint =>
      'La automatización del hogar te ahorra tiempo y esfuerzo automatizando tareas rutinarias.';

  @override
  String get tapToRunEmptyHint =>
      'Crea una escena de pulsar para ejecutar y controla tus dispositivos con un solo toque.';

  @override
  String get scene => 'Escena';

  @override
  String get executionFailed => 'Error de ejecución';

  @override
  String get device => 'Dispositivo';

  @override
  String get delay => 'Espera';

  @override
  String get runScene => 'Ejecutar escena';

  @override
  String get addToSiri => 'Añadir a Siri';

  @override
  String get storeUnderPreparation =>
      'La tienda está en preparación, muy pronto disponible.';

  @override
  String get commonFunctions => 'Funciones habituales';

  @override
  String get noConnection => 'Sin conexión';

  @override
  String get checkInternetAndRetry =>
      'Comprueba tu conexión a internet e inténtalo de nuevo.';

  @override
  String get noConnectionCheckInternet =>
      'Sin conexión. Comprueba tu internet e inténtalo de nuevo.';

  @override
  String get addFirstCurtainHint =>
      'Toca el botón + para añadir tu primera cortina a esta casa.';

  @override
  String get hideInvisibleDevices => 'Ocultar dispositivos no visibles';

  @override
  String get deviceRenamed => 'Dispositivo renombrado.';

  @override
  String get deviceDeletedReturningToPairing =>
      'Dispositivo eliminado. Volverá al modo de emparejamiento.';

  @override
  String get homeSettings => 'Ajustes de la casa';

  @override
  String get toBeSet => 'Sin definir';

  @override
  String get homeMember => 'Miembro de la casa';

  @override
  String get memberDetails => 'Detalles del miembro';

  @override
  String get addMember => 'Añadir miembro';

  @override
  String get pending => 'Pendiente';

  @override
  String get removesFromHomeHint =>
      'Se quita de la casa; el dispositivo vuelve al modo de emparejamiento en 1-2 minutos';

  @override
  String get unlinkAndEraseData => 'Desvincular y borrar datos';

  @override
  String get erasesAllDataHint => 'Borra todos los datos, no se puede deshacer';

  @override
  String get somethingWentWrongTryAgain => 'Algo salió mal, inténtalo de nuevo';

  @override
  String get tapToRunAndAutomation => 'Pulsar para ejecutar y automatización';

  @override
  String get thirdPartyControl => 'Control de terceros';

  @override
  String get deviceOfflineNotification => 'Aviso de dispositivo sin conexión';

  @override
  String get others => 'Otros';

  @override
  String get shareDevice => 'Compartir dispositivo';

  @override
  String get addToHomeScreen => 'Añadir a la pantalla de inicio';

  @override
  String get checkDeviceNetwork => 'Comprobar la red del dispositivo';

  @override
  String get checkNow => 'Comprobar ahora';

  @override
  String get deviceUpdate => 'Actualización del dispositivo';

  @override
  String get removeDevicesWarning =>
      'Se quitarán de esta casa y volverán al modo de emparejamiento.';

  @override
  String get shown => 'Visible';

  @override
  String get hidden => 'Oculto';

  @override
  String get devicesBackOnHome => 'Los dispositivos vuelven a estar en Inicio';

  @override
  String get hiddenFromHome => 'Ocultos de Inicio';

  @override
  String get offline => 'Sin conexión';

  @override
  String get show => 'Mostrar';

  @override
  String get hide => 'Ocultar';

  @override
  String get profilePhoto => 'Foto de perfil';

  @override
  String get nickname => 'Apodo';

  @override
  String get noRoomsYet => 'Aún no hay habitaciones';

  @override
  String get tapPlusToAddRoom => 'Toca + para añadir una habitación';

  @override
  String get emailAddressLabel => 'Correo electrónico';

  @override
  String get notSet => 'Sin definir';

  @override
  String get deviceInformation => 'Información del dispositivo';

  @override
  String get unknown => 'Desconocido';

  @override
  String get notReported => 'No informado';

  @override
  String get noScenesUseThisDevice =>
      'Todavía ninguna escena usa este dispositivo.';

  @override
  String get tapToRunLabel => 'Pulsar para ejecutar';

  @override
  String get automation => 'Automatización';

  @override
  String get forward => 'Directo';

  @override
  String get back => 'Inverso';

  @override
  String get setting => 'Ajuste';

  @override
  String get updateAvailable => 'Actualización disponible';

  @override
  String get noUpdatesAvailable => 'No hay actualizaciones';

  @override
  String get updateNow => 'Actualizar ahora';

  @override
  String get unassigned => 'Sin asignar';

  @override
  String get enterEmailOrUsername => 'Introduce tu correo o nombre de usuario';

  @override
  String get welcome => 'Bienvenido';

  @override
  String get signInSubtitle => 'Inicia sesión en tu cuenta de osprey.life.';

  @override
  String get createOne => 'Crear una';

  @override
  String get forgotPassword => '¿Olvidaste tu contraseña?';

  @override
  String get orContinueWith => 'o continúa con';

  @override
  String get enterValidEmail => 'Introduce un correo electrónico válido';

  @override
  String get resetYourPassword => 'Restablecer tu contraseña';

  @override
  String get checkYourInbox => 'Revisa tu bandeja de entrada';

  @override
  String get enterYourEmailAddress => 'Introduce tu correo electrónico';

  @override
  String get enterSixDigitCode => 'Introduce el código de 6 dígitos';

  @override
  String get enterAPassword => 'Introduce una contraseña';

  @override
  String get createYourAccount => 'Crea tu cuenta';

  @override
  String get checkYourEmail => 'Revisa tu correo';

  @override
  String get resendCode => 'Reenviar código';

  @override
  String get userAgreement => 'Acuerdo de usuario';

  @override
  String get reconnecting => 'Reconectando…';

  @override
  String get checkWifiOrBluetooth =>
      'Comprueba el Wi-Fi o acércate para usar Bluetooth.';

  @override
  String get smartScenesRequireInternet =>
      'Las escenas inteligentes necesitan internet';

  @override
  String get enterWifiName => 'Introduce el nombre del Wi-Fi';

  @override
  String get wifiNameLengthError =>
      'El nombre del Wi-Fi debe tener entre 1 y 32 caracteres';

  @override
  String get passwordMin8 => 'La contraseña debe tener al menos 8 caracteres';

  @override
  String get passwordLength863 =>
      'La contraseña debe tener entre 8 y 63 caracteres';

  @override
  String get networkAlreadySaved =>
      'Esta red ya está guardada. Para cambiar su contraseña, elimínala y añádela de nuevo.';

  @override
  String get addWifiNetwork => 'Añadir red Wi-Fi';

  @override
  String get atLeast8Characters => 'Al menos 8 caracteres';

  @override
  String get only24GhzSupported =>
      'Los dispositivos de cortina solo admiten Wi-Fi de 2,4 GHz (WPA2).';

  @override
  String get labelOptional => 'Etiqueta (opcional)';

  @override
  String get createGroup => 'Crear grupo';

  @override
  String get groupControlHint =>
      'Los dispositivos del mismo grupo se pueden controlar juntos.';

  @override
  String get devicesToBeAdded => 'Dispositivos por añadir';

  @override
  String get noSameTypeDevices =>
      'No hay otros dispositivos del mismo tipo en esta casa.';

  @override
  String get couldNotLoadNetworkDetails =>
      'No se pudieron cargar los detalles de la red. Desliza para actualizar.';

  @override
  String get alreadyOnThisNetwork => 'Ya está en esta red.';

  @override
  String get deviceOfflineTryLater =>
      'El dispositivo está sin conexión: inténtalo más tarde.';

  @override
  String get wrongPassword => 'Contraseña incorrecta';

  @override
  String get networkNotFound => 'Red no encontrada';

  @override
  String get networkRemoved => 'Red eliminada.';

  @override
  String get network => 'Red';

  @override
  String get connectedTo => 'Conectado a';

  @override
  String get savedNetworks => 'Redes guardadas';

  @override
  String get addANetwork => 'Añadir una red';

  @override
  String get notConnected => 'No conectado';

  @override
  String get pleaseKeepAppOpen => 'Mantén la app abierta.';

  @override
  String get deviceNetworkInformation => 'Información de red del dispositivo';

  @override
  String get once => 'Una vez';

  @override
  String get editSchedule => 'Editar programación';

  @override
  String get addSchedule => 'Añadir programación';

  @override
  String get timeVarianceHint => 'El margen de tiempo es de ±30 s';

  @override
  String get noTimerData => 'Sin datos de temporizador';

  @override
  String get localControlUnsupportedAction =>
      'El control local no admite esta acción';

  @override
  String get noInternetNoBluetooth =>
      'Sin internet y Bluetooth fuera de alcance';

  @override
  String get connectionError => 'Error de conexión';

  @override
  String get exampleTapToRun =>
      'Ejemplo: apagar todas las luces del dormitorio con un toque.';

  @override
  String get exampleWeather =>
      'Ejemplo: cuando la temperatura local supere los 28 °C.';

  @override
  String get weatherTrigger => 'Disparador por clima';

  @override
  String get exampleSchedule => 'Ejemplo: a las 7:00 cada mañana.';

  @override
  String get exampleDeviceStatus =>
      'Ejemplo: cuando se detecte una actividad inusual.';

  @override
  String get deviceStatusTrigger => 'Disparador por estado del dispositivo';

  @override
  String get noNotificationsYet => 'Aún no hay notificaciones';

  @override
  String get slashCommands => 'Comandos con barra';

  @override
  String get slashDevicesHint => 'Consulta y controla tus cortinas.';

  @override
  String get slashSceneHint => 'Ejecuta una escena de pulsar para ejecutar.';

  @override
  String get slashScheduleHint => 'Abre la programación de automatización.';

  @override
  String get slashHelpHint => 'Muestra esta lista.';

  @override
  String get youCanAlsoSpeak =>
      'También puedes hablar: toca el botón del micrófono.';

  @override
  String get chatInputHint => 'Escribe, habla o usa comandos con barra.';

  @override
  String get online => 'En línea';

  @override
  String get blePermissionRequired =>
      'Se necesita permiso de Bluetooth para buscar dispositivos';

  @override
  String get bleAndLocationPermissionRequired =>
      'Se necesitan permisos de Bluetooth y ubicación para buscar dispositivos';

  @override
  String get addDeviceLower => 'Añadir dispositivo';

  @override
  String get scanningStopped => 'Búsqueda detenida.';

  @override
  String get enterWifiPassword => 'Introduce la contraseña del Wi-Fi';

  @override
  String get detectingCurrentWifi => 'Detectando el Wi-Fi actual...';

  @override
  String get autoDetectedWifi =>
      'Detectado automáticamente del Wi-Fi al que está conectado tu teléfono';

  @override
  String get couldNotDetectWifi =>
      'No se pudo detectar el Wi-Fi: introduce el nombre de la red manualmente';

  @override
  String get beingAdded => 'Añadiendo';

  @override
  String get addedSuccessfully => 'Añadido correctamente';

  @override
  String get pairingFailed => 'Error de emparejamiento';

  @override
  String get allDay => 'Todo el día';

  @override
  String get whenAnyConditionMet => 'Cuando se cumpla cualquier condición';

  @override
  String get whenAllConditionsMet => 'Cuando se cumplan todas las condiciones';

  @override
  String get deleteSceneWarning =>
      'Tras eliminar el escenario, las tareas del dispositivo ya no podrán ejecutarse correctamente.';

  @override
  String get toggleAutomation => 'Activar o desactivar automatización';

  @override
  String get enable => 'Activar';

  @override
  String get disable => 'Desactivar';

  @override
  String get everyDay => 'Todos los días';

  @override
  String get monToFri => 'Lun - Vie';

  @override
  String get satToSun => 'Sáb - Dom';

  @override
  String get runOnceIfNoDaySelected =>
      'La acción se realizará solo una vez si no seleccionas ningún día de la semana.';

  @override
  String get sendNotification => 'Enviar notificación';

  @override
  String get color => 'Color';

  @override
  String get wait => 'Esperar';

  @override
  String get finish => 'Finalizar';

  @override
  String get selectFunction => 'Seleccionar función';

  @override
  String get on => 'Encendido';

  @override
  String get off => 'Apagado';

  @override
  String get siriShortcut => 'Atajo de Siri';

  @override
  String get createTapToRunFirst =>
      'Crea primero una escena de pulsar para ejecutar.';

  @override
  String get poweredByFoundationModels =>
      'Con Apple Foundation Models, en el dispositivo.';

  @override
  String get weatherClearNight => 'Noche despejada';

  @override
  String get weatherSunny => 'Soleado';

  @override
  String get weatherPartlyCloudy => 'Parcialmente nublado';

  @override
  String get weatherCloudy => 'Nublado';

  @override
  String get qualityExcellent => 'Excelente';

  @override
  String get qualityGood => 'Buena';

  @override
  String get qualityModerate => 'Moderada';

  @override
  String get qualityPoor => 'Mala';

  @override
  String get qualityVeryPoor => 'Muy mala';

  @override
  String get switchLocation => 'Cambiar ubicación';

  @override
  String get aiSuggestion => 'Sugerencia de IA';

  @override
  String get listening => 'Escuchando…';

  @override
  String get parsing => 'Analizando…';

  @override
  String get getStarted => 'Empezar';

  @override
  String get aiChatEmptyState =>
      'Pregunta al asistente de osprey.life lo que quieras sobre tus cortinas.\nCon Apple Foundation Models, en el dispositivo.';

  @override
  String get chatHeaderSubtitle =>
      'IA en el dispositivo para tus cortinas motorizadas.\nEscribe, habla o usa comandos con barra.';

  @override
  String get daySunShort => 'Dom.';

  @override
  String get dayMonShort => 'Lun.';

  @override
  String get dayTueShort => 'Mar.';

  @override
  String get dayWedShort => 'Mié.';

  @override
  String get dayThuShort => 'Jue.';

  @override
  String get dayFriShort => 'Vie.';

  @override
  String get daySatShort => 'Sáb.';

  @override
  String get dayMon => 'Lun';

  @override
  String get dayTue => 'Mar';

  @override
  String get dayWed => 'Mié';

  @override
  String get dayThu => 'Jue';

  @override
  String get dayFri => 'Vie';

  @override
  String get daySat => 'Sáb';

  @override
  String get daySun => 'Dom';

  @override
  String get accountLinkedSuccessfully => '¡Cuenta vinculada correctamente!';

  @override
  String get linkingFailed => 'Error al vincular';

  @override
  String get anErrorOccurredTryAgain =>
      'Se produjo un error. Inténtalo de nuevo.';

  @override
  String get signInWithAmazon => 'Iniciar sesión con Amazon';

  @override
  String get viewMoreWaysToLink => 'Ver más formas de vincular';

  @override
  String get alreadyLinkedWithAlexa => 'Ya vinculado con Amazon Alexa';

  @override
  String get somethingWentWrong => 'Algo salió mal';

  @override
  String get noAuthorizationCode => 'No se recibió el código de autorización';

  @override
  String get couldNotOpenGoogleHome => 'No se pudo abrir la app Google Home';

  @override
  String get reLogin => 'Volver a iniciar sesión';

  @override
  String get linkWithGoogleAssistant => 'Vincular con el Asistente de Google';

  @override
  String get linkedWithGoogleAssistant =>
      'Vinculado con el Asistente de Google';

  @override
  String get anErrorOccurred => 'Se produjo un error';

  @override
  String deleteHomeConfirm(String name) {
    return '¿Seguro que quieres eliminar \"$name\"? Esta acción no se puede deshacer.';
  }

  @override
  String get offlineScenesBody =>
      'Las escenas y programaciones se pausan hasta que vuelva tu Wi-Fi. El control local por Bluetooth sigue funcionando para abrir, cerrar y detener cada dispositivo.';

  @override
  String get blePairingLostBody =>
      'El control local por Bluetooth necesita volver a emparejarse con este dispositivo. Suele ocurrir después de borrar los datos de la app o de restablecer el dispositivo de fábrica.';

  @override
  String get alternateNetworkHint =>
      'Si la red actual no está disponible, el dispositivo se conectará automáticamente a una red alternativa.';

  @override
  String get switchNetworkWarning =>
      'El dispositivo se desconectará de su Wi-Fi actual e intentará unirse a la nueva. Suele tardar entre 5 y 30 segundos.';

  @override
  String get runOnceIfNoDayPicked =>
      'La acción se realizará solo una vez si no la seleccionas.';

  @override
  String get alexaUnlinkHint =>
      'Desactiva la skill de osprey.life en la app de Amazon Alexa o toca Yo > el botón de Ajustes en la esquina superior derecha > Cuenta y seguridad para retirar la autorización.';

  @override
  String get alexaLinkExplainer =>
      'Vincular tu cuenta de la app con tu cuenta de Amazon te permite controlar dispositivos compatibles con Alexa a través de altavoces Amazon Echo (p. ej. \"Alexa, turn on light.\")';

  @override
  String get chatScheduleHelp =>
      'Configura programaciones automáticas para tus cortinas. Abre la pestaña Escenas para crear automatizaciones diarias, semanales o de una sola vez.';

  @override
  String get chatScenesHelp =>
      'Crea y gestiona escenas de pulsar para ejecutar desde la pestaña Escenas. Las escenas te permiten encadenar varias acciones de cortina con esperas en un solo toque.';

  @override
  String get googleUnlinkHint =>
      'Desactiva la skill de osprey.life en la app Google Home o toca Yo > el botón de Ajustes en la esquina superior derecha > Cuenta y seguridad para retirar la autorización.';

  @override
  String get googleLinkExplainer =>
      'Tras conectar tu cuenta de la app y tu cuenta de Google, podrás usar altavoces inteligentes Google Home para controlar dispositivos compatibles con el Asistente de Google. Por ejemplo, puedes decir: \"OK Google, please turn on the light.\"';

  @override
  String get deviceDisconnectedFromHome =>
      'Dispositivo desconectado de la casa. Volverá al modo de emparejamiento en 1-2 minutos.';

  @override
  String get searchingNearbyDevices =>
      'Buscando dispositivos Osprey cercanos. Asegúrate de que el dispositivo esté en modo de emparejamiento.';

  @override
  String get looksLike5GhzHint =>
      'Esta red parece de 5 GHz: cambia tu teléfono a una red de 2,4 GHz y toca actualizar.';

  @override
  String get pairingWifiHint =>
      'El dispositivo se conectará al Wi-Fi que usa tu teléfono. Solo se admiten redes de 2,4 GHz.';

  @override
  String get siriShortcutsHelp =>
      'Toca una escena para grabar una frase de voz y luego di \"Hey Siri\" seguido de esa frase para ejecutarla, incluso con la app cerrada.\n\nToca una escena que ya hayas añadido para cambiar su frase o quitarla.';

  @override
  String get deleteAccountWarning =>
      'Después de eliminarla:\n• Tu cuenta se eliminará al cabo de 30 días\n• Se quitarán todos tus dispositivos y escenas\n• Puedes cancelarlo iniciando sesión de nuevo en 30 días';

  @override
  String aiSuggestionBody(String action, String weekday, String hour) {
    return 'Normalmente ejecutas \"$action\" el $weekday a las $hour:00. ¿Quieres automatizarlo?';
  }

  @override
  String removeDeviceConfirm(String name) {
    return '\"$name\" se quitará de tu casa y volverá automáticamente al modo de emparejamiento en 1-2 minutos.';
  }

  @override
  String eraseDeviceConfirm(String name) {
    return 'Se borrarán todos los datos de \"$name\" y NO se podrán recuperar. ¿Seguro que quieres continuar?';
  }

  @override
  String showInvisibleDevices(int count) {
    return 'Mostrar dispositivos no visibles ($count)';
  }

  @override
  String resetLinkSent(String email) {
    return 'Si existe una cuenta para $email, te enviaremos un enlace para restablecer la contraseña.';
  }

  @override
  String signInNotAvailable(String name) {
    return 'El inicio de sesión con $name aún no está disponible.';
  }

  @override
  String resendCodeIn(int seconds) {
    return 'Reenviar código en $seconds s';
  }

  @override
  String deleteConfirmNamed(String name) {
    return '¿Seguro que quieres eliminar \"$name\"?';
  }

  @override
  String taskCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tareas',
      one: '1 tarea',
    );
    return '$_temp0';
  }

  @override
  String featureComingSoonShort(String feature) {
    return '$feature estará disponible pronto';
  }

  @override
  String roomCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count habitaciones',
      one: '1 habitación',
    );
    return '$_temp0';
  }

  @override
  String removeDevicesQ(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '¿Quitar $count dispositivos?',
      one: '¿Quitar el dispositivo?',
    );
    return '$_temp0';
  }

  @override
  String devicesRemoved(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count dispositivos eliminados',
      one: '1 dispositivo eliminado',
    );
    return '$_temp0';
  }

  @override
  String deviceCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count dispositivos',
      one: '1 dispositivo',
    );
    return '$_temp0';
  }

  @override
  String mainModuleVersion(String version) {
    return 'Módulo principal: V$version';
  }

  @override
  String outdoorTemperatureValue(int temp) {
    return 'Temperatura exterior: $temp °C';
  }

  @override
  String occurrencesIn30Days(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count veces en 30 días',
      one: '1 vez en 30 días',
    );
    return '$_temp0';
  }

  @override
  String sceneExecuted(String name) {
    return '\"$name\" ejecutada';
  }

  @override
  String couldNotRunScene(String name) {
    return 'No se pudo ejecutar \"$name\". Inténtalo de nuevo.';
  }

  @override
  String featureComingSoonNamed(String feature) {
    return '$feature estará disponible pronto.';
  }

  @override
  String get couldNotLoadHome =>
      'No se pudo cargar tu casa. Inténtalo de nuevo.';

  @override
  String deviceCouldNotConnectTo(String ssid, String reason, String stayedOn) {
    return 'El dispositivo no pudo conectarse a \"$ssid\".\n\nMotivo: $reason\n\nEl dispositivo sigue en \"$stayedOn\".';
  }

  @override
  String makeSureNetworkInRange(String ssid) {
    return '\n\nAsegúrate de que \"$ssid\" esté encendida y dentro del alcance.';
  }

  @override
  String get noResponseFromDevice =>
      'No obtuvimos respuesta del dispositivo. Actualiza en un momento para ver su estado actual.';

  @override
  String devicesBeingAdded(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Añadiendo $count dispositivos',
      one: 'Añadiendo 1 dispositivo',
    );
    return '$_temp0';
  }

  @override
  String devicesAddedSuccessfully(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count dispositivos añadidos correctamente',
      one: '1 dispositivo añadido correctamente',
    );
    return '$_temp0';
  }

  @override
  String get alexaExamplesIntro =>
      'Puedes controlar dispositivos compatibles con Alexa\ncon altavoces Amazon Alexa, por ejemplo';

  @override
  String get googleExamplesIntro =>
      'Ya puedes usar el altavoz Google Home para\ncontrolar dispositivos del Asistente de Google, como';
}

/// The translations for Spanish Castilian, as used in Latin America and the Caribbean (`es_419`).
class AppL10nEs419 extends AppL10nEs {
  AppL10nEs419() : super('es_419');

  @override
  String get settingsTitle => 'Configuración';

  @override
  String get personalInformation => 'Información personal';

  @override
  String get accountAndSecurity => 'Cuenta y seguridad';

  @override
  String get touchToneOnPanel => 'Tono al tocar el panel';

  @override
  String get aiAssistant => 'Asistente de IA';

  @override
  String get temperatureUnit => 'Unidad de temperatura';

  @override
  String get about => 'Acerca de';

  @override
  String get networkDiagnosis => 'Diagnóstico de red';

  @override
  String get clearCache => 'Borrar caché';

  @override
  String get language => 'Idioma';

  @override
  String get logOut => 'Cerrar sesión';

  @override
  String get languageSystemDefault => 'Igual que el idioma del sistema';

  @override
  String get languageEnglish => 'Inglés';

  @override
  String get languageVietnamese => 'Vietnamita';

  @override
  String get clearCacheMessage =>
      'Las escenas, los datos del hogar y las imágenes en caché se descargarán de nuevo la próxima vez. Tu cuenta y tus dispositivos no se ven afectados.';

  @override
  String get clear => 'Borrar';

  @override
  String get cancel => 'Cancelar';

  @override
  String freedSpace(String size) {
    return 'Se liberaron $size';
  }

  @override
  String aboutVersion(String version, String build) {
    return 'Versión $version ($build)';
  }

  @override
  String get privacyPolicy => 'Política de privacidad';

  @override
  String get termsOfService => 'Términos del servicio';

  @override
  String get bundleId => 'Bundle ID';

  @override
  String get server => 'Servidor';

  @override
  String get couldNotOpenLink => 'No se pudo abrir el enlace.';

  @override
  String get diagLocalNetwork => 'Red local';

  @override
  String get diagLocalNetworkNoWifi =>
      'Sin Wi-Fi (datos móviles o permiso denegado)';

  @override
  String get diagLocalNetworkUnreadable =>
      'No se pudo leer el nombre de la red Wi-Fi';

  @override
  String get diagDnsLookup => 'Consulta DNS';

  @override
  String diagDnsFailed(String host) {
    return 'No se puede resolver $host';
  }

  @override
  String get diagServerReachable => 'Servidor accesible';

  @override
  String diagServerLatency(String ms, String status) {
    return '$ms ms · HTTP $status';
  }

  @override
  String get diagServerNoResponse => 'El servidor no responde';

  @override
  String get diagSignedIn => 'Sesión iniciada';

  @override
  String get diagSessionValid => 'Sesión válida';

  @override
  String diagSessionInvalid(String status) {
    return 'HTTP $status — inicia sesión de nuevo';
  }

  @override
  String get diagSessionUnverified => 'No se pudo verificar la sesión';

  @override
  String get diagControlChannel => 'Canal de control';

  @override
  String get diagCloudConnected => 'Nube (MQTT) conectada';

  @override
  String get diagBleFallback => 'Nube caída — usando Bluetooth';

  @override
  String get diagUnreachable => 'Sin nube ni Bluetooth cerca';

  @override
  String get diagStatusUnknown => 'Estado desconocido';

  @override
  String get runAgain => 'Ejecutar de nuevo';

  @override
  String get accountCreatedPleaseSignIn => 'Cuenta creada: inicia sesión.';

  @override
  String get add => 'Agregar';

  @override
  String get addCondition => 'Agregar condición';

  @override
  String get addRoom => 'Agregar habitación';

  @override
  String get addTask => 'Agregar tarea';

  @override
  String get addAtLeastTwoDevicesToAGroup =>
      'Agrega al menos dos dispositivos a un grupo.';

  @override
  String get alexa => 'Alexa';

  @override
  String get all => 'Todos';

  @override
  String get allDevices => 'Todos los dispositivos';

  @override
  String get alternateNetwork => 'Red alterna';

  @override
  String get apply => 'Aplicar';

  @override
  String get areYouSureYouWantToLogOut => '¿Seguro que quieres cerrar sesión?';

  @override
  String get askAboutYourCurtainsOrTryHelp =>
      'Pregunta sobre tus cortinas o prueba /help…';

  @override
  String get askAboutYourCurtains => 'Pregunta sobre tus cortinas…';

  @override
  String get atLeast6Characters => 'Al menos 6 caracteres';

  @override
  String get authDiagnostics => 'Diagnóstico de autenticación';

  @override
  String get automationNotification => 'Notificación de automatización';

  @override
  String get changeRoom => 'Cambiar habitación';

  @override
  String get close => 'Cerrar';

  @override
  String get cloud => 'Nube';

  @override
  String get confirm => 'Confirmar';

  @override
  String get connected => 'Conectado';

  @override
  String get control => 'Control';

  @override
  String get controlSingleDevice => 'Controlar un dispositivo';

  @override
  String get copiedToClipboard => 'Copiado al portapapeles';

  @override
  String get copy => 'Copiar';

  @override
  String get couldNotChangeTheMotorDirectionPleaseTryAgai =>
      'No se pudo cambiar la dirección del motor. Inténtalo de nuevo.';

  @override
  String get couldNotConnect => 'No se pudo conectar';

  @override
  String get couldNotCreateTheGroupPleaseTryAgain =>
      'No se pudo crear el grupo. Inténtalo de nuevo.';

  @override
  String get couldNotOpenTheBrowser => 'No se pudo abrir el navegador.';

  @override
  String get couldNotSendTheCommandPleaseTryAgain =>
      'No se pudo enviar el comando. Inténtalo de nuevo.';

  @override
  String get create => 'Crear';

  @override
  String get createScene => 'Crear escena';

  @override
  String get createAHome => 'Crear un hogar';

  @override
  String get createARoomFirst => 'Primero crea una habitación.';

  @override
  String get createAccount => 'Crear cuenta';

  @override
  String get createScene2 => 'Crear escena';

  @override
  String get curtainPosition => 'Posición de la cortina';

  @override
  String get curtainPositionSetting => 'Ajuste de posición de la cortina';

  @override
  String get customDeviceIconsAreNotSupportedYet =>
      'Los iconos personalizados de dispositivos aún no son compatibles.';

  @override
  String get delayTheAction => 'Retrasar la acción';

  @override
  String get delete => 'Eliminar';

  @override
  String get deleteAccount => 'Eliminar cuenta';

  @override
  String get deleteHome => 'Eliminar hogar';

  @override
  String get deleteRoom => 'Eliminar habitación';

  @override
  String get deleteSchedule => 'Eliminar programación';

  @override
  String get deleteScene => '¿Eliminar escena?';

  @override
  String get deleteThisSchedule => '¿Eliminar esta programación?';

  @override
  String get deviceNetwork => 'Red del dispositivo';

  @override
  String get deviceHasNoProfileInformation =>
      'El dispositivo no tiene información de perfil';

  @override
  String get deviceIsOffline => 'El dispositivo está desconectado';

  @override
  String get deviceIsReady => 'El dispositivo está listo.';

  @override
  String get deviceName => 'Nombre del dispositivo';

  @override
  String get deviceRemovedFromHome => 'Dispositivo eliminado del hogar.';

  @override
  String get deviceUnreachable => 'Dispositivo no accesible';

  @override
  String get devices => 'Dispositivos';

  @override
  String get disconnect => 'Desconectar';

  @override
  String get disconnectDevice => '¿Desconectar el dispositivo?';

  @override
  String get done => 'Listo';

  @override
  String get emailAddress => 'Correo electrónico';

  @override
  String get emailOrUsername => 'Correo o usuario';

  @override
  String get enterAGroupName => 'Ingresa un nombre de grupo';

  @override
  String get enterANote => 'Ingresa una nota';

  @override
  String get enterDeviceName => 'Ingresa el nombre del dispositivo';

  @override
  String get enterHomeName => 'Ingresa el nombre del hogar';

  @override
  String get enterName => 'Ingresa el nombre';

  @override
  String get enterSceneName => 'Ingresa el nombre de la escena';

  @override
  String get enterValue => 'Ingresa un valor...';

  @override
  String get enterYourPassword => 'Ingresa tu contraseña';

  @override
  String get eraseDeviceData => '¿Borrar los datos del dispositivo?';

  @override
  String get error => 'Error';

  @override
  String get executedBy => 'Ejecutado por';

  @override
  String get executionTime => 'Hora de ejecución';

  @override
  String get faqFeedback => 'Preguntas frecuentes y comentarios';

  @override
  String get failed => 'Falló';

  @override
  String get featureComingSoon => 'Función disponible próximamente';

  @override
  String get firmware => 'Firmware';

  @override
  String get firmwareUpdateIsComingSoon =>
      'La actualización de firmware estará disponible próximamente.';

  @override
  String get firstName => 'Nombre';

  @override
  String get firstNameOptional => 'Nombre (opcional)';

  @override
  String get goBack => 'Regresar';

  @override
  String get googleAssistant => 'Google Assistant';

  @override
  String get gotIt => 'Entendido';

  @override
  String get groupName => 'Nombre del grupo';

  @override
  String get help => 'Ayuda';

  @override
  String get homeManagement => 'Gestión del hogar';

  @override
  String get homeName => 'Nombre del hogar';

  @override
  String get homeName2 => 'Nombre del hogar';

  @override
  String get icon => 'Icono';

  @override
  String get conditionIf => 'Si';

  @override
  String get joinAHome => 'Unirse a un hogar';

  @override
  String get joiningAHomeByInviteIsComingSoon =>
      'Unirse a un hogar por invitación estará disponible próximamente.';

  @override
  String get lastName => 'Apellido';

  @override
  String get lastNameOptional => 'Apellido (opcional)';

  @override
  String get later => 'Más tarde';

  @override
  String get launchTapToRun => 'Ejecutar Tap-to-Run';

  @override
  String get localAssociation => 'Asociación local';

  @override
  String get localControlOffline => 'Control local (sin conexión)';

  @override
  String get location => 'Ubicación';

  @override
  String get logCopiedToClipboard => 'Registro copiado al portapapeles';

  @override
  String get logs => 'Registros';

  @override
  String get manage => 'Administrar';

  @override
  String get managePermissions => 'Administrar permisos';

  @override
  String get markAllAsRead => 'Marcar todo como leído';

  @override
  String get moreSettings => 'Más ajustes';

  @override
  String get motorDirection => 'Dirección del motor';

  @override
  String get moveToTop => 'Mover al inicio';

  @override
  String get moveToRoom => 'Mover a habitación';

  @override
  String get moved => 'Movido';

  @override
  String get movedToTop => 'Movido al inicio';

  @override
  String get name => 'Nombre';

  @override
  String get next => 'Siguiente';

  @override
  String get noDevicesAvailable => 'No hay dispositivos disponibles';

  @override
  String get noDevicesFound => 'No se encontraron dispositivos.';

  @override
  String get noDevicesInThisHome => 'No hay dispositivos en este hogar.';

  @override
  String get noDevicesYet => 'Aún no hay dispositivos';

  @override
  String get noFunctionsAvailable => 'No hay funciones disponibles';

  @override
  String get noHomeSelectedPleaseTryAgain =>
      'No se seleccionó un hogar, inténtalo de nuevo';

  @override
  String get noMatchingTimeZones => 'No hay zonas horarias coincidentes';

  @override
  String get noOtherScenesAvailable => 'No hay otras escenas disponibles';

  @override
  String get noRooms => 'Sin habitaciones';

  @override
  String get noSavedNetworksYet => 'Aún no hay redes guardadas.';

  @override
  String get noScenes => 'Sin escenas';

  @override
  String get noScenesAvailable => 'No hay escenas disponibles';

  @override
  String get note => 'Nota';

  @override
  String get notification => 'Notificación';

  @override
  String get ok => 'Aceptar';

  @override
  String get offlineNotification => 'Notificación de desconexión';

  @override
  String get open => 'Abrir';

  @override
  String get openSettings => 'Abrir configuración';

  @override
  String get outdoorPm25 => 'PM2.5 exterior';

  @override
  String get outdoorAirPressure => 'Presión del aire exterior';

  @override
  String get outdoorHumidity => 'Humedad exterior';

  @override
  String get outdoorWindSpeed => 'Velocidad del viento exterior';

  @override
  String get pairingSuccessful => 'Emparejamiento exitoso';

  @override
  String get password => 'Contraseña';

  @override
  String get sessionExpiredSignInAgain =>
      'Tu sesión expiró. Inicia sesión de nuevo.';

  @override
  String get pleaseAddAtLeast1Action => 'Agrega al menos 1 acción';

  @override
  String get pleaseAddAtLeast1Condition => 'Agrega al menos 1 condición';

  @override
  String get pleaseEnterAName => 'Ingresa un nombre';

  @override
  String get pleaseEnterASceneName => 'Ingresa un nombre de escena';

  @override
  String get pleaseSelectAFunction => 'Selecciona una función';

  @override
  String get pleaseSelectATime0 => 'Selecciona un tiempo mayor que 0';

  @override
  String get rePairNow => 'Volver a emparejar';

  @override
  String get rePairRequired => 'Se requiere volver a emparejar';

  @override
  String get reasonOptional => 'Motivo (opcional)';

  @override
  String get refresh => 'Actualizar';

  @override
  String get reload => 'Recargar';

  @override
  String get remove => 'Quitar';

  @override
  String get removeDevice => 'Quitar dispositivo';

  @override
  String get removed => 'Eliminado';

  @override
  String get rename => 'Cambiar nombre';

  @override
  String get renameRoom => 'Cambiar nombre de la habitación';

  @override
  String get renameDevice => 'Cambiar nombre del dispositivo';

  @override
  String get repeat => 'Repetir';

  @override
  String get rescan => 'Volver a escanear';

  @override
  String get retry => 'Reintentar';

  @override
  String get roomManagement => 'Gestión de habitaciones';

  @override
  String get roomName => 'Nombre de la habitación';

  @override
  String get roomUpdated => 'Habitación actualizada';

  @override
  String get running => 'En ejecución';

  @override
  String get save => 'Guardar';

  @override
  String get sceneName => 'Nombre de la escena';

  @override
  String get scenes => 'Escenas';

  @override
  String get schedule => 'Programación';

  @override
  String get searchAddress => 'Buscar dirección';

  @override
  String get searchCityOrRegion => 'Buscar ciudad o región';

  @override
  String get selectScene => 'Seleccionar escena';

  @override
  String get selectSmartScenes => 'Seleccionar escenas inteligentes';

  @override
  String get sendResetLink => 'Enviar enlace de restablecimiento';

  @override
  String get sendVerificationCode => 'Enviar código de verificación';

  @override
  String get showOnHomePage => 'Mostrar en la pantalla de inicio';

  @override
  String get signIn => 'Iniciar sesión';

  @override
  String get signalStrength => 'Intensidad de la señal';

  @override
  String get signalStrength2 => 'Intensidad de la señal';

  @override
  String get startPairing => 'Iniciar emparejamiento';

  @override
  String get stop => 'Detener';

  @override
  String get style => 'Estilo';

  @override
  String get switchNetwork => 'Cambiar';

  @override
  String get switchToThisNetwork => 'Cambiar a esta red';

  @override
  String get tapToRunNotification => 'Notificación de Tap-to-Run';

  @override
  String get conditionThen => 'Entonces';

  @override
  String get thinking => 'Pensando…';

  @override
  String get thisActionCannotBeUndone => 'Esta acción no se puede deshacer.';

  @override
  String get thisSavedNetworkWillBeRemovedFromTheDevice =>
      'Esta red guardada se quitará del dispositivo.';

  @override
  String get timeZone => 'Zona horaria';

  @override
  String get timeZoneUpdated => 'Zona horaria actualizada';

  @override
  String get timedOut => 'Tiempo de espera agotado';

  @override
  String get tryAgain => 'Inténtalo de nuevo';

  @override
  String get useCurrentLocation => 'Usar ubicación actual';

  @override
  String get usingSiri => 'Con Siri';

  @override
  String get virtualId => 'ID virtual';

  @override
  String get whenDeviceStatusChanges =>
      'Cuando cambia el estado del dispositivo';

  @override
  String get whenWeatherChanges => 'Cuando cambia el clima';

  @override
  String get wiFi => 'Wi-Fi';

  @override
  String get wifiNameSsid => 'Nombre de WiFi (SSID)';

  @override
  String get wifiPassword => 'Contraseña de WiFi';

  @override
  String get navHome => 'Inicio';

  @override
  String get navScenes => 'Escenas';

  @override
  String get navChat => 'Chat';

  @override
  String get navMe => 'Yo';

  @override
  String get thirdPartyServices => 'Servicios de terceros';

  @override
  String get messageCenter => 'Centro de mensajes';

  @override
  String get appMall => 'Tienda de apps';

  @override
  String get addDevice => 'Agregar dispositivo';

  @override
  String get tapToRun => 'Toca para ejecutar';

  @override
  String get automationEmptyHint =>
      'La automatización del hogar te ahorra tiempo y esfuerzo al automatizar tareas rutinarias.';

  @override
  String get tapToRunEmptyHint =>
      'Crea una escena de toca para ejecutar y controla tus dispositivos con un solo toque.';

  @override
  String get scene => 'Escena';

  @override
  String get executionFailed => 'Error de ejecución';

  @override
  String get device => 'Dispositivo';

  @override
  String get delay => 'Espera';

  @override
  String get runScene => 'Ejecutar escena';

  @override
  String get addToSiri => 'Agregar a Siri';

  @override
  String get storeUnderPreparation =>
      'La tienda está en preparación, muy pronto disponible.';

  @override
  String get commonFunctions => 'Funciones frecuentes';

  @override
  String get noConnection => 'Sin conexión';

  @override
  String get checkInternetAndRetry =>
      'Revisa tu conexión a internet e inténtalo de nuevo.';

  @override
  String get noConnectionCheckInternet =>
      'Sin conexión. Revisa tu internet e inténtalo de nuevo.';

  @override
  String get addFirstCurtainHint =>
      'Toca el botón + para agregar tu primera cortina a esta casa.';

  @override
  String get hideInvisibleDevices => 'Ocultar dispositivos no visibles';

  @override
  String get deviceRenamed => 'Dispositivo renombrado.';

  @override
  String get deviceDeletedReturningToPairing =>
      'Dispositivo eliminado. Volverá al modo de emparejamiento.';

  @override
  String get homeSettings => 'Configuración de la casa';

  @override
  String get toBeSet => 'Sin definir';

  @override
  String get homeMember => 'Miembro de la casa';

  @override
  String get memberDetails => 'Detalles del miembro';

  @override
  String get addMember => 'Agregar miembro';

  @override
  String get pending => 'Pendiente';

  @override
  String get removesFromHomeHint =>
      'Se quita de la casa; el dispositivo vuelve al modo de emparejamiento en 1-2 minutos';

  @override
  String get unlinkAndEraseData => 'Desvincular y borrar datos';

  @override
  String get erasesAllDataHint => 'Borra todos los datos, no se puede deshacer';

  @override
  String get somethingWentWrongTryAgain => 'Algo salió mal, inténtalo de nuevo';

  @override
  String get tapToRunAndAutomation => 'Toca para ejecutar y automatización';

  @override
  String get thirdPartyControl => 'Control de terceros';

  @override
  String get deviceOfflineNotification => 'Aviso de dispositivo sin conexión';

  @override
  String get others => 'Otros';

  @override
  String get shareDevice => 'Compartir dispositivo';

  @override
  String get addToHomeScreen => 'Agregar a la pantalla de inicio';

  @override
  String get checkDeviceNetwork => 'Revisar la red del dispositivo';

  @override
  String get checkNow => 'Revisar ahora';

  @override
  String get deviceUpdate => 'Actualización del dispositivo';

  @override
  String get removeDevicesWarning =>
      'Se quitarán de esta casa y volverán al modo de emparejamiento.';

  @override
  String get shown => 'Visible';

  @override
  String get hidden => 'Oculto';

  @override
  String get devicesBackOnHome => 'Los dispositivos volvieron a Inicio';

  @override
  String get hiddenFromHome => 'Ocultos de Inicio';

  @override
  String get offline => 'Sin conexión';

  @override
  String get show => 'Mostrar';

  @override
  String get hide => 'Ocultar';

  @override
  String get profilePhoto => 'Foto de perfil';

  @override
  String get nickname => 'Apodo';

  @override
  String get noRoomsYet => 'Aún no hay habitaciones';

  @override
  String get tapPlusToAddRoom => 'Toca + para agregar una habitación';

  @override
  String get emailAddressLabel => 'Correo electrónico';

  @override
  String get notSet => 'Sin definir';

  @override
  String get deviceInformation => 'Información del dispositivo';

  @override
  String get unknown => 'Desconocido';

  @override
  String get notReported => 'No informado';

  @override
  String get noScenesUseThisDevice =>
      'Todavía ninguna escena usa este dispositivo.';

  @override
  String get tapToRunLabel => 'Toca para ejecutar';

  @override
  String get automation => 'Automatización';

  @override
  String get forward => 'Directo';

  @override
  String get back => 'Inverso';

  @override
  String get setting => 'Configuración';

  @override
  String get updateAvailable => 'Actualización disponible';

  @override
  String get noUpdatesAvailable => 'No hay actualizaciones';

  @override
  String get updateNow => 'Actualizar ahora';

  @override
  String get unassigned => 'Sin asignar';

  @override
  String get enterEmailOrUsername => 'Ingresa tu correo o nombre de usuario';

  @override
  String get welcome => 'Bienvenido';

  @override
  String get signInSubtitle => 'Inicia sesión en tu cuenta de osprey.life.';

  @override
  String get createOne => 'Crear una';

  @override
  String get forgotPassword => '¿Olvidaste tu contraseña?';

  @override
  String get orContinueWith => 'o continúa con';

  @override
  String get enterValidEmail => 'Ingresa un correo electrónico válido';

  @override
  String get resetYourPassword => 'Restablecer tu contraseña';

  @override
  String get checkYourInbox => 'Revisa tu bandeja de entrada';

  @override
  String get enterYourEmailAddress => 'Ingresa tu correo electrónico';

  @override
  String get enterSixDigitCode => 'Ingresa el código de 6 dígitos';

  @override
  String get enterAPassword => 'Ingresa una contraseña';

  @override
  String get createYourAccount => 'Crea tu cuenta';

  @override
  String get checkYourEmail => 'Revisa tu correo';

  @override
  String get resendCode => 'Reenviar código';

  @override
  String get userAgreement => 'Acuerdo de usuario';

  @override
  String get reconnecting => 'Reconectando…';

  @override
  String get checkWifiOrBluetooth =>
      'Revisa el Wi-Fi o acércate para usar Bluetooth.';

  @override
  String get smartScenesRequireInternet =>
      'Las escenas inteligentes necesitan internet';

  @override
  String get enterWifiName => 'Ingresa el nombre del Wi-Fi';

  @override
  String get wifiNameLengthError =>
      'El nombre del Wi-Fi debe tener entre 1 y 32 caracteres';

  @override
  String get passwordMin8 => 'La contraseña debe tener al menos 8 caracteres';

  @override
  String get passwordLength863 =>
      'La contraseña debe tener entre 8 y 63 caracteres';

  @override
  String get networkAlreadySaved =>
      'Esta red ya está guardada. Para cambiar su contraseña, elimínala y agrégala de nuevo.';

  @override
  String get addWifiNetwork => 'Agregar red Wi-Fi';

  @override
  String get atLeast8Characters => 'Al menos 8 caracteres';

  @override
  String get only24GhzSupported =>
      'Los dispositivos de cortina solo admiten Wi-Fi de 2.4 GHz (WPA2).';

  @override
  String get labelOptional => 'Etiqueta (opcional)';

  @override
  String get createGroup => 'Crear grupo';

  @override
  String get groupControlHint =>
      'Los dispositivos del mismo grupo se pueden controlar juntos.';

  @override
  String get devicesToBeAdded => 'Dispositivos por agregar';

  @override
  String get noSameTypeDevices =>
      'No hay otros dispositivos del mismo tipo en esta casa.';

  @override
  String get couldNotLoadNetworkDetails =>
      'No se pudieron cargar los detalles de la red. Desliza para actualizar.';

  @override
  String get alreadyOnThisNetwork => 'Ya está en esta red.';

  @override
  String get deviceOfflineTryLater =>
      'El dispositivo está sin conexión: inténtalo más tarde.';

  @override
  String get wrongPassword => 'Contraseña incorrecta';

  @override
  String get networkNotFound => 'Red no encontrada';

  @override
  String get networkRemoved => 'Red eliminada.';

  @override
  String get network => 'Red';

  @override
  String get connectedTo => 'Conectado a';

  @override
  String get savedNetworks => 'Redes guardadas';

  @override
  String get addANetwork => 'Agregar una red';

  @override
  String get notConnected => 'No conectado';

  @override
  String get pleaseKeepAppOpen => 'Mantén la app abierta.';

  @override
  String get deviceNetworkInformation => 'Información de red del dispositivo';

  @override
  String get once => 'Una vez';

  @override
  String get editSchedule => 'Editar programación';

  @override
  String get addSchedule => 'Agregar programación';

  @override
  String get timeVarianceHint => 'El margen de tiempo es de ±30 s';

  @override
  String get noTimerData => 'Sin datos de temporizador';

  @override
  String get localControlUnsupportedAction =>
      'El control local no admite esta acción';

  @override
  String get noInternetNoBluetooth =>
      'Sin internet y Bluetooth fuera de alcance';

  @override
  String get connectionError => 'Error de conexión';

  @override
  String get exampleTapToRun =>
      'Ejemplo: apagar todas las luces de la recámara con un toque.';

  @override
  String get exampleWeather =>
      'Ejemplo: cuando la temperatura local supere los 28 °C.';

  @override
  String get weatherTrigger => 'Activador por clima';

  @override
  String get exampleSchedule => 'Ejemplo: a las 7:00 cada mañana.';

  @override
  String get exampleDeviceStatus =>
      'Ejemplo: cuando se detecte una actividad inusual.';

  @override
  String get deviceStatusTrigger => 'Activador por estado del dispositivo';

  @override
  String get noNotificationsYet => 'Aún no hay notificaciones';

  @override
  String get slashCommands => 'Comandos con diagonal';

  @override
  String get slashDevicesHint => 'Consulta y controla tus cortinas.';

  @override
  String get slashSceneHint => 'Ejecuta una escena de toca para ejecutar.';

  @override
  String get slashScheduleHint => 'Abre la programación de automatización.';

  @override
  String get slashHelpHint => 'Muestra esta lista.';

  @override
  String get youCanAlsoSpeak =>
      'También puedes hablar: toca el botón del micrófono.';

  @override
  String get chatInputHint => 'Escribe, habla o usa comandos con diagonal.';

  @override
  String get online => 'En línea';

  @override
  String get blePermissionRequired =>
      'Se necesita permiso de Bluetooth para buscar dispositivos';

  @override
  String get bleAndLocationPermissionRequired =>
      'Se necesitan permisos de Bluetooth y ubicación para buscar dispositivos';

  @override
  String get addDeviceLower => 'Agregar dispositivo';

  @override
  String get scanningStopped => 'Búsqueda detenida.';

  @override
  String get enterWifiPassword => 'Ingresa la contraseña del Wi-Fi';

  @override
  String get detectingCurrentWifi => 'Detectando el Wi-Fi actual...';

  @override
  String get autoDetectedWifi =>
      'Detectado automáticamente del Wi-Fi al que está conectado tu teléfono';

  @override
  String get couldNotDetectWifi =>
      'No se pudo detectar el Wi-Fi: ingresa el nombre de la red manualmente';

  @override
  String get beingAdded => 'Agregando';

  @override
  String get addedSuccessfully => 'Agregado correctamente';

  @override
  String get pairingFailed => 'Error de emparejamiento';

  @override
  String get allDay => 'Todo el día';

  @override
  String get whenAnyConditionMet => 'Cuando se cumpla cualquier condición';

  @override
  String get whenAllConditionsMet => 'Cuando se cumplan todas las condiciones';

  @override
  String get deleteSceneWarning =>
      'Tras eliminar el escenario, las tareas del dispositivo ya no podrán ejecutarse correctamente.';

  @override
  String get toggleAutomation => 'Activar o desactivar automatización';

  @override
  String get enable => 'Activar';

  @override
  String get disable => 'Desactivar';

  @override
  String get everyDay => 'Todos los días';

  @override
  String get monToFri => 'Lun - Vie';

  @override
  String get satToSun => 'Sáb - Dom';

  @override
  String get runOnceIfNoDaySelected =>
      'La acción se realizará solo una vez si no seleccionas ningún día de la semana.';

  @override
  String get sendNotification => 'Enviar notificación';

  @override
  String get color => 'Color';

  @override
  String get wait => 'Esperar';

  @override
  String get finish => 'Finalizar';

  @override
  String get selectFunction => 'Seleccionar función';

  @override
  String get on => 'Encendido';

  @override
  String get off => 'Apagado';

  @override
  String get siriShortcut => 'Atajo de Siri';

  @override
  String get createTapToRunFirst =>
      'Crea primero una escena de toca para ejecutar.';

  @override
  String get poweredByFoundationModels =>
      'Con Apple Foundation Models, en el dispositivo.';

  @override
  String get weatherClearNight => 'Noche despejada';

  @override
  String get weatherSunny => 'Soleado';

  @override
  String get weatherPartlyCloudy => 'Parcialmente nublado';

  @override
  String get weatherCloudy => 'Nublado';

  @override
  String get qualityExcellent => 'Excelente';

  @override
  String get qualityGood => 'Buena';

  @override
  String get qualityModerate => 'Moderada';

  @override
  String get qualityPoor => 'Mala';

  @override
  String get qualityVeryPoor => 'Muy mala';

  @override
  String get switchLocation => 'Cambiar ubicación';

  @override
  String get aiSuggestion => 'Sugerencia de IA';

  @override
  String get listening => 'Escuchando…';

  @override
  String get parsing => 'Analizando…';

  @override
  String get getStarted => 'Comenzar';

  @override
  String get aiChatEmptyState =>
      'Pregúntale al asistente de osprey.life lo que quieras sobre tus cortinas.\nCon Apple Foundation Models, en el dispositivo.';

  @override
  String get chatHeaderSubtitle =>
      'IA en el dispositivo para tus cortinas motorizadas.\nEscribe, habla o usa comandos con diagonal.';

  @override
  String get daySunShort => 'Dom.';

  @override
  String get dayMonShort => 'Lun.';

  @override
  String get dayTueShort => 'Mar.';

  @override
  String get dayWedShort => 'Mié.';

  @override
  String get dayThuShort => 'Jue.';

  @override
  String get dayFriShort => 'Vie.';

  @override
  String get daySatShort => 'Sáb.';

  @override
  String get dayMon => 'Lun';

  @override
  String get dayTue => 'Mar';

  @override
  String get dayWed => 'Mié';

  @override
  String get dayThu => 'Jue';

  @override
  String get dayFri => 'Vie';

  @override
  String get daySat => 'Sáb';

  @override
  String get daySun => 'Dom';

  @override
  String get accountLinkedSuccessfully => '¡Cuenta vinculada correctamente!';

  @override
  String get linkingFailed => 'Error al vincular';

  @override
  String get anErrorOccurredTryAgain => 'Ocurrió un error. Inténtalo de nuevo.';

  @override
  String get signInWithAmazon => 'Iniciar sesión con Amazon';

  @override
  String get viewMoreWaysToLink => 'Ver más formas de vincular';

  @override
  String get alreadyLinkedWithAlexa => 'Ya vinculado con Amazon Alexa';

  @override
  String get somethingWentWrong => 'Algo salió mal';

  @override
  String get noAuthorizationCode => 'No se recibió el código de autorización';

  @override
  String get couldNotOpenGoogleHome => 'No se pudo abrir la app Google Home';

  @override
  String get reLogin => 'Volver a iniciar sesión';

  @override
  String get linkWithGoogleAssistant => 'Vincular con el Asistente de Google';

  @override
  String get linkedWithGoogleAssistant =>
      'Vinculado con el Asistente de Google';

  @override
  String get anErrorOccurred => 'Ocurrió un error';

  @override
  String deleteHomeConfirm(String name) {
    return '¿Seguro que quieres eliminar \"$name\"? Esta acción no se puede deshacer.';
  }

  @override
  String get offlineScenesBody =>
      'Las escenas y programaciones se pausan hasta que vuelva tu Wi-Fi. El control local por Bluetooth sigue funcionando para abrir, cerrar y detener cada dispositivo.';

  @override
  String get blePairingLostBody =>
      'El control local por Bluetooth necesita volver a emparejarse con este dispositivo. Suele pasar después de borrar los datos de la app o de restablecer el dispositivo de fábrica.';

  @override
  String get alternateNetworkHint =>
      'Si la red actual no está disponible, el dispositivo se conectará automáticamente a una red alternativa.';

  @override
  String get switchNetworkWarning =>
      'El dispositivo se desconectará de su Wi-Fi actual e intentará unirse a la nueva. Suele tardar entre 5 y 30 segundos.';

  @override
  String get runOnceIfNoDayPicked =>
      'La acción se realizará solo una vez si no la seleccionas.';

  @override
  String get alexaUnlinkHint =>
      'Desactiva la skill de osprey.life en la app de Amazon Alexa o toca Yo > el botón de Configuración en la esquina superior derecha > Cuenta y seguridad para retirar la autorización.';

  @override
  String get alexaLinkExplainer =>
      'Vincular tu cuenta de la app con tu cuenta de Amazon te permite controlar dispositivos compatibles con Alexa a través de bocinas Amazon Echo (p. ej. \"Alexa, turn on light.\")';

  @override
  String get chatScheduleHelp =>
      'Configura programaciones automáticas para tus cortinas. Abre la pestaña Escenas para crear automatizaciones diarias, semanales o de una sola vez.';

  @override
  String get chatScenesHelp =>
      'Crea y administra escenas de toca para ejecutar desde la pestaña Escenas. Las escenas te permiten encadenar varias acciones de cortina con esperas en un solo toque.';

  @override
  String get googleUnlinkHint =>
      'Desactiva la skill de osprey.life en la app Google Home o toca Yo > el botón de Configuración en la esquina superior derecha > Cuenta y seguridad para retirar la autorización.';

  @override
  String get googleLinkExplainer =>
      'Tras conectar tu cuenta de la app y tu cuenta de Google, podrás usar bocinas inteligentes Google Home para controlar dispositivos compatibles con el Asistente de Google. Por ejemplo, puedes decir: \"OK Google, please turn on the light.\"';

  @override
  String get deviceDisconnectedFromHome =>
      'Dispositivo desconectado de la casa. Volverá al modo de emparejamiento en 1-2 minutos.';

  @override
  String get searchingNearbyDevices =>
      'Buscando dispositivos Osprey cercanos. Asegúrate de que el dispositivo esté en modo de emparejamiento.';

  @override
  String get looksLike5GhzHint =>
      'Esta red parece de 5 GHz: cambia tu teléfono a una red de 2.4 GHz y toca actualizar.';

  @override
  String get pairingWifiHint =>
      'El dispositivo se conectará al Wi-Fi que usa tu teléfono. Solo se admiten redes de 2.4 GHz.';

  @override
  String get siriShortcutsHelp =>
      'Toca una escena para grabar una frase de voz y luego di \"Hey Siri\" seguido de esa frase para ejecutarla, incluso con la app cerrada.\n\nToca una escena que ya hayas agregado para cambiar su frase o quitarla.';

  @override
  String get deleteAccountWarning =>
      'Después de eliminarla:\n• Tu cuenta se eliminará al cabo de 30 días\n• Se quitarán todos tus dispositivos y escenas\n• Puedes cancelarlo iniciando sesión de nuevo en 30 días';

  @override
  String aiSuggestionBody(String action, String weekday, String hour) {
    return 'Normalmente ejecutas \"$action\" el $weekday a las $hour:00. ¿Quieres automatizarlo?';
  }

  @override
  String removeDeviceConfirm(String name) {
    return '\"$name\" se quitará de tu casa y volverá automáticamente al modo de emparejamiento en 1-2 minutos.';
  }

  @override
  String eraseDeviceConfirm(String name) {
    return 'Se borrarán todos los datos de \"$name\" y NO se podrán recuperar. ¿Seguro que quieres continuar?';
  }

  @override
  String showInvisibleDevices(int count) {
    return 'Mostrar dispositivos no visibles ($count)';
  }

  @override
  String resetLinkSent(String email) {
    return 'Si existe una cuenta para $email, te enviaremos un enlace para restablecer la contraseña.';
  }

  @override
  String signInNotAvailable(String name) {
    return 'El inicio de sesión con $name aún no está disponible.';
  }

  @override
  String resendCodeIn(int seconds) {
    return 'Reenviar código en $seconds s';
  }

  @override
  String deleteConfirmNamed(String name) {
    return '¿Seguro que quieres eliminar \"$name\"?';
  }

  @override
  String taskCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tareas',
      one: '1 tarea',
    );
    return '$_temp0';
  }

  @override
  String featureComingSoonShort(String feature) {
    return '$feature estará disponible pronto';
  }

  @override
  String roomCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count habitaciones',
      one: '1 habitación',
    );
    return '$_temp0';
  }

  @override
  String removeDevicesQ(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '¿Quitar $count dispositivos?',
      one: '¿Quitar el dispositivo?',
    );
    return '$_temp0';
  }

  @override
  String devicesRemoved(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count dispositivos eliminados',
      one: '1 dispositivo eliminado',
    );
    return '$_temp0';
  }

  @override
  String deviceCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count dispositivos',
      one: '1 dispositivo',
    );
    return '$_temp0';
  }

  @override
  String mainModuleVersion(String version) {
    return 'Módulo principal: V$version';
  }

  @override
  String outdoorTemperatureValue(int temp) {
    return 'Temperatura exterior: $temp °C';
  }

  @override
  String occurrencesIn30Days(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count veces en 30 días',
      one: '1 vez en 30 días',
    );
    return '$_temp0';
  }

  @override
  String sceneExecuted(String name) {
    return '\"$name\" ejecutada';
  }

  @override
  String couldNotRunScene(String name) {
    return 'No se pudo ejecutar \"$name\". Inténtalo de nuevo.';
  }

  @override
  String featureComingSoonNamed(String feature) {
    return '$feature estará disponible pronto.';
  }

  @override
  String get couldNotLoadHome =>
      'No se pudo cargar tu casa. Inténtalo de nuevo.';

  @override
  String deviceCouldNotConnectTo(String ssid, String reason, String stayedOn) {
    return 'El dispositivo no pudo conectarse a \"$ssid\".\n\nMotivo: $reason\n\nEl dispositivo sigue en \"$stayedOn\".';
  }

  @override
  String makeSureNetworkInRange(String ssid) {
    return '\n\nAsegúrate de que \"$ssid\" esté encendida y dentro del alcance.';
  }

  @override
  String get noResponseFromDevice =>
      'No obtuvimos respuesta del dispositivo. Actualiza en un momento para ver su estado actual.';

  @override
  String devicesBeingAdded(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Agregando $count dispositivos',
      one: 'Agregando 1 dispositivo',
    );
    return '$_temp0';
  }

  @override
  String devicesAddedSuccessfully(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count dispositivos agregados correctamente',
      one: '1 dispositivo agregado correctamente',
    );
    return '$_temp0';
  }

  @override
  String get alexaExamplesIntro =>
      'Puedes controlar dispositivos compatibles con Alexa\ncon bocinas Amazon Alexa, por ejemplo';

  @override
  String get googleExamplesIntro =>
      'Ya puedes usar la bocina Google Home para\ncontrolar dispositivos del Asistente de Google, como';
}
