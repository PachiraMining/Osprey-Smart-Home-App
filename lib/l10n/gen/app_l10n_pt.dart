// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_l10n.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppL10nPt extends AppL10n {
  AppL10nPt([String locale = 'pt']) : super(locale);

  @override
  String get settingsTitle => 'Definições';

  @override
  String get personalInformation => 'Informações pessoais';

  @override
  String get accountAndSecurity => 'Conta e segurança';

  @override
  String get touchToneOnPanel => 'Som de toque no painel';

  @override
  String get aiAssistant => 'Assistente de IA';

  @override
  String get temperatureUnit => 'Unidade de temperatura';

  @override
  String get about => 'Acerca de';

  @override
  String get networkDiagnosis => 'Diagnóstico de rede';

  @override
  String get clearCache => 'Limpar cache';

  @override
  String get language => 'Idioma';

  @override
  String get logOut => 'Terminar sessão';

  @override
  String get languageSystemDefault => 'Igual ao idioma do sistema';

  @override
  String get languageEnglish => 'Inglês';

  @override
  String get languageVietnamese => 'Vietnamita';

  @override
  String get clearCacheMessage =>
      'As cenas, os dados da casa e as imagens em cache serão descarregados novamente na próxima utilização. A sua conta e os seus dispositivos não são afetados.';

  @override
  String get clear => 'Limpar';

  @override
  String get cancel => 'Cancelar';

  @override
  String freedSpace(String size) {
    return '$size libertados';
  }

  @override
  String aboutVersion(String version, String build) {
    return 'Versão $version ($build)';
  }

  @override
  String get privacyPolicy => 'Política de Privacidade';

  @override
  String get termsOfService => 'Termos de Serviço';

  @override
  String get bundleId => 'Bundle ID';

  @override
  String get server => 'Servidor';

  @override
  String get couldNotOpenLink => 'Não foi possível abrir o link.';

  @override
  String get diagLocalNetwork => 'Rede local';

  @override
  String get diagLocalNetworkNoWifi =>
      'Sem Wi-Fi (dados móveis ou permissão recusada)';

  @override
  String get diagLocalNetworkUnreadable =>
      'Não foi possível ler o nome da rede Wi-Fi';

  @override
  String get diagDnsLookup => 'Consulta DNS';

  @override
  String diagDnsFailed(String host) {
    return 'Não é possível resolver $host';
  }

  @override
  String get diagServerReachable => 'Servidor acessível';

  @override
  String diagServerLatency(String ms, String status) {
    return '$ms ms · HTTP $status';
  }

  @override
  String get diagServerNoResponse => 'Sem resposta do servidor';

  @override
  String get diagSignedIn => 'Sessão iniciada';

  @override
  String get diagSessionValid => 'Sessão válida';

  @override
  String diagSessionInvalid(String status) {
    return 'HTTP $status — inicie sessão novamente';
  }

  @override
  String get diagSessionUnverified => 'Não foi possível verificar a sessão';

  @override
  String get diagControlChannel => 'Canal de controlo';

  @override
  String get diagCloudConnected => 'Nuvem (MQTT) ligada';

  @override
  String get diagBleFallback => 'Nuvem indisponível — a usar Bluetooth';

  @override
  String get diagUnreachable => 'Sem nuvem nem Bluetooth ao alcance';

  @override
  String get diagStatusUnknown => 'Estado desconhecido';

  @override
  String get runAgain => 'Executar novamente';

  @override
  String get accountCreatedPleaseSignIn => 'Conta criada — inicie sessão.';

  @override
  String get add => 'Adicionar';

  @override
  String get addCondition => 'Adicionar condição';

  @override
  String get addRoom => 'Adicionar sala';

  @override
  String get addTask => 'Adicionar tarefa';

  @override
  String get addAtLeastTwoDevicesToAGroup =>
      'Adicione pelo menos dois dispositivos a um grupo.';

  @override
  String get alexa => 'Alexa';

  @override
  String get all => 'Todos';

  @override
  String get allDevices => 'Todos os dispositivos';

  @override
  String get alternateNetwork => 'Rede alternativa';

  @override
  String get apply => 'Aplicar';

  @override
  String get areYouSureYouWantToLogOut =>
      'Tem a certeza de que quer terminar a sessão?';

  @override
  String get askAboutYourCurtainsOrTryHelp =>
      'Pergunte sobre as suas cortinas ou tente /help…';

  @override
  String get askAboutYourCurtains => 'Pergunte sobre as suas cortinas…';

  @override
  String get atLeast6Characters => 'Pelo menos 6 caracteres';

  @override
  String get authDiagnostics => 'Diagnóstico de autenticação';

  @override
  String get automationNotification => 'Notificação de automação';

  @override
  String get changeRoom => 'Mudar de sala';

  @override
  String get close => 'Fechar';

  @override
  String get cloud => 'Nuvem';

  @override
  String get confirm => 'Confirmar';

  @override
  String get connected => 'Ligado';

  @override
  String get control => 'Controlo';

  @override
  String get controlSingleDevice => 'Controlar um dispositivo';

  @override
  String get copiedToClipboard => 'Copiado para a área de transferência';

  @override
  String get copy => 'Copiar';

  @override
  String get couldNotChangeTheMotorDirectionPleaseTryAgai =>
      'Não foi possível alterar a direção do motor. Tente novamente.';

  @override
  String get couldNotConnect => 'Não foi possível ligar';

  @override
  String get couldNotCreateTheGroupPleaseTryAgain =>
      'Não foi possível criar o grupo. Tente novamente.';

  @override
  String get couldNotOpenTheBrowser => 'Não foi possível abrir o navegador.';

  @override
  String get couldNotSendTheCommandPleaseTryAgain =>
      'Não foi possível enviar o comando. Tente novamente.';

  @override
  String get create => 'Criar';

  @override
  String get createScene => 'Criar cena';

  @override
  String get createAHome => 'Criar uma casa';

  @override
  String get createARoomFirst => 'Crie primeiro uma sala.';

  @override
  String get createAccount => 'Criar conta';

  @override
  String get createScene2 => 'Criar cena';

  @override
  String get curtainPosition => 'Posição da cortina';

  @override
  String get curtainPositionSetting => 'Definição da posição da cortina';

  @override
  String get customDeviceIconsAreNotSupportedYet =>
      'Os ícones de dispositivo personalizados ainda não são suportados.';

  @override
  String get delayTheAction => 'Atrasar a ação';

  @override
  String get delete => 'Eliminar';

  @override
  String get deleteAccount => 'Eliminar conta';

  @override
  String get deleteHome => 'Eliminar casa';

  @override
  String get deleteRoom => 'Eliminar sala';

  @override
  String get deleteSchedule => 'Eliminar agendamento';

  @override
  String get deleteScene => 'Eliminar cena?';

  @override
  String get deleteThisSchedule => 'Eliminar este agendamento?';

  @override
  String get deviceNetwork => 'Rede do dispositivo';

  @override
  String get deviceHasNoProfileInformation =>
      'O dispositivo não tem informações de perfil';

  @override
  String get deviceIsOffline => 'O dispositivo está offline';

  @override
  String get deviceIsReady => 'O dispositivo está pronto.';

  @override
  String get deviceName => 'Nome do dispositivo';

  @override
  String get deviceRemovedFromHome => 'Dispositivo removido da casa.';

  @override
  String get deviceUnreachable => 'Dispositivo inacessível';

  @override
  String get devices => 'Dispositivos';

  @override
  String get disconnect => 'Desligar';

  @override
  String get disconnectDevice => 'Desligar o dispositivo?';

  @override
  String get done => 'Concluído';

  @override
  String get emailAddress => 'Endereço de e-mail';

  @override
  String get emailOrUsername => 'E-mail ou nome de utilizador';

  @override
  String get enterAGroupName => 'Introduza um nome de grupo';

  @override
  String get enterANote => 'Introduza uma nota';

  @override
  String get enterDeviceName => 'Introduza o nome do dispositivo';

  @override
  String get enterHomeName => 'Introduza o nome da casa';

  @override
  String get enterName => 'Introduza o nome';

  @override
  String get enterSceneName => 'Introduza o nome da cena';

  @override
  String get enterValue => 'Introduza um valor...';

  @override
  String get enterYourPassword => 'Introduza a sua palavra-passe';

  @override
  String get eraseDeviceData => 'Apagar os dados do dispositivo?';

  @override
  String get error => 'Erro';

  @override
  String get executedBy => 'Executado por';

  @override
  String get executionTime => 'Hora de execução';

  @override
  String get faqFeedback => 'FAQ e comentários';

  @override
  String get failed => 'Falhou';

  @override
  String get featureComingSoon => 'Funcionalidade em breve';

  @override
  String get firmware => 'Firmware';

  @override
  String get firmwareUpdateIsComingSoon =>
      'A atualização do firmware chega em breve.';

  @override
  String get firstName => 'Nome';

  @override
  String get firstNameOptional => 'Nome (opcional)';

  @override
  String get goBack => 'Voltar';

  @override
  String get googleAssistant => 'Google Assistant';

  @override
  String get gotIt => 'Entendi';

  @override
  String get groupName => 'Nome do grupo';

  @override
  String get help => 'Ajuda';

  @override
  String get homeManagement => 'Gestão de casas';

  @override
  String get homeName => 'Nome da casa';

  @override
  String get homeName2 => 'Nome da casa';

  @override
  String get icon => 'Ícone';

  @override
  String get conditionIf => 'Se';

  @override
  String get joinAHome => 'Juntar-se a uma casa';

  @override
  String get joiningAHomeByInviteIsComingSoon =>
      'Juntar-se a uma casa por convite chega em breve.';

  @override
  String get lastName => 'Apelido';

  @override
  String get lastNameOptional => 'Apelido (opcional)';

  @override
  String get later => 'Mais tarde';

  @override
  String get launchTapToRun => 'Executar Tap-to-Run';

  @override
  String get localAssociation => 'Associação local';

  @override
  String get localControlOffline => 'Controlo local (offline)';

  @override
  String get location => 'Localização';

  @override
  String get logCopiedToClipboard =>
      'Registo copiado para a área de transferência';

  @override
  String get logs => 'Registos';

  @override
  String get manage => 'Gerir';

  @override
  String get managePermissions => 'Gerir permissões';

  @override
  String get markAllAsRead => 'Marcar tudo como lido';

  @override
  String get moreSettings => 'Mais definições';

  @override
  String get motorDirection => 'Direção do motor';

  @override
  String get moveToTop => 'Mover para o topo';

  @override
  String get moveToRoom => 'Mover para a sala';

  @override
  String get moved => 'Movido';

  @override
  String get movedToTop => 'Movido para o topo';

  @override
  String get name => 'Nome';

  @override
  String get next => 'Seguinte';

  @override
  String get noDevicesAvailable => 'Nenhum dispositivo disponível';

  @override
  String get noDevicesFound => 'Nenhum dispositivo encontrado.';

  @override
  String get noDevicesInThisHome => 'Nenhum dispositivo nesta casa.';

  @override
  String get noDevicesYet => 'Ainda sem dispositivos';

  @override
  String get noFunctionsAvailable => 'Nenhuma função disponível';

  @override
  String get noHomeSelectedPleaseTryAgain =>
      'Nenhuma casa selecionada, tente novamente';

  @override
  String get noMatchingTimeZones => 'Nenhum fuso horário correspondente';

  @override
  String get noOtherScenesAvailable => 'Nenhuma outra cena disponível';

  @override
  String get noRooms => 'Sem salas';

  @override
  String get noSavedNetworksYet => 'Ainda sem redes guardadas.';

  @override
  String get noScenes => 'Sem cenas';

  @override
  String get noScenesAvailable => 'Nenhuma cena disponível';

  @override
  String get note => 'Nota';

  @override
  String get notification => 'Notificação';

  @override
  String get ok => 'OK';

  @override
  String get offlineNotification => 'Notificação de offline';

  @override
  String get open => 'Abrir';

  @override
  String get openSettings => 'Abrir definições';

  @override
  String get outdoorPm25 => 'PM2.5 exterior';

  @override
  String get outdoorAirPressure => 'Pressão do ar exterior';

  @override
  String get outdoorHumidity => 'Humidade exterior';

  @override
  String get outdoorWindSpeed => 'Velocidade do vento exterior';

  @override
  String get pairingSuccessful => 'Emparelhamento concluído';

  @override
  String get password => 'Palavra-passe';

  @override
  String get sessionExpiredSignInAgain =>
      'A sessão expirou. Inicie sessão novamente.';

  @override
  String get pleaseAddAtLeast1Action => 'Adicione pelo menos 1 ação';

  @override
  String get pleaseAddAtLeast1Condition => 'Adicione pelo menos 1 condição';

  @override
  String get pleaseEnterAName => 'Introduza um nome';

  @override
  String get pleaseEnterASceneName => 'Introduza um nome para a cena';

  @override
  String get pleaseSelectAFunction => 'Selecione uma função';

  @override
  String get pleaseSelectATime0 => 'Selecione um tempo > 0';

  @override
  String get rePairNow => 'Emparelhar novamente';

  @override
  String get rePairRequired => 'É necessário emparelhar novamente';

  @override
  String get reasonOptional => 'Motivo (opcional)';

  @override
  String get refresh => 'Atualizar';

  @override
  String get reload => 'Recarregar';

  @override
  String get remove => 'Remover';

  @override
  String get removeDevice => 'Remover dispositivo';

  @override
  String get removed => 'Removido';

  @override
  String get rename => 'Renomear';

  @override
  String get renameRoom => 'Renomear sala';

  @override
  String get renameDevice => 'Renomear dispositivo';

  @override
  String get repeat => 'Repetir';

  @override
  String get rescan => 'Procurar novamente';

  @override
  String get retry => 'Tentar novamente';

  @override
  String get roomManagement => 'Gestão de salas';

  @override
  String get roomName => 'Nome da sala';

  @override
  String get roomUpdated => 'Sala atualizada';

  @override
  String get running => 'Em execução';

  @override
  String get save => 'Guardar';

  @override
  String get sceneName => 'Nome da cena';

  @override
  String get scenes => 'Cenas';

  @override
  String get schedule => 'Agendamento';

  @override
  String get searchAddress => 'Procurar endereço';

  @override
  String get searchCityOrRegion => 'Procurar cidade ou região';

  @override
  String get selectScene => 'Selecionar cena';

  @override
  String get selectSmartScenes => 'Selecionar cenas inteligentes';

  @override
  String get sendResetLink => 'Enviar link de recuperação';

  @override
  String get sendVerificationCode => 'Enviar código de verificação';

  @override
  String get showOnHomePage => 'Mostrar na página inicial';

  @override
  String get signIn => 'Iniciar sessão';

  @override
  String get signalStrength => 'Intensidade do sinal';

  @override
  String get signalStrength2 => 'Intensidade do sinal';

  @override
  String get startPairing => 'Iniciar emparelhamento';

  @override
  String get stop => 'Parar';

  @override
  String get style => 'Estilo';

  @override
  String get switchNetwork => 'Mudar';

  @override
  String get switchToThisNetwork => 'Mudar para esta rede';

  @override
  String get tapToRunNotification => 'Notificação Tap-to-Run';

  @override
  String get conditionThen => 'Então';

  @override
  String get thinking => 'A pensar…';

  @override
  String get thisActionCannotBeUndone => 'Esta ação não pode ser anulada.';

  @override
  String get thisSavedNetworkWillBeRemovedFromTheDevice =>
      'Esta rede guardada será removida do dispositivo.';

  @override
  String get timeZone => 'Fuso horário';

  @override
  String get timeZoneUpdated => 'Fuso horário atualizado';

  @override
  String get timedOut => 'Tempo esgotado';

  @override
  String get tryAgain => 'Tentar novamente';

  @override
  String get useCurrentLocation => 'Usar a localização atual';

  @override
  String get usingSiri => 'Utilizar a Siri';

  @override
  String get virtualId => 'ID virtual';

  @override
  String get whenDeviceStatusChanges => 'Quando o estado do dispositivo muda';

  @override
  String get whenWeatherChanges => 'Quando o tempo muda';

  @override
  String get wiFi => 'Wi-Fi';

  @override
  String get wifiNameSsid => 'Nome do WiFi (SSID)';

  @override
  String get wifiPassword => 'Palavra-passe do WiFi';

  @override
  String get navHome => 'Início';

  @override
  String get navScenes => 'Cenas';

  @override
  String get navChat => 'Chat';

  @override
  String get navMe => 'Eu';

  @override
  String get thirdPartyServices => 'Serviços de terceiros';

  @override
  String get messageCenter => 'Centro de mensagens';

  @override
  String get appMall => 'Loja de apps';

  @override
  String get addDevice => 'Adicionar dispositivo';

  @override
  String get tapToRun => 'Executar com um toque';

  @override
  String get automationEmptyHint =>
      'A automatização poupa-lhe tempo e esforço ao automatizar tarefas de rotina.';

  @override
  String get tapToRunEmptyHint =>
      'Crie uma cena de execução com um toque para controlar os seus dispositivos rapidamente.';

  @override
  String get scene => 'Cena';

  @override
  String get executionFailed => 'Falha na execução';

  @override
  String get device => 'Dispositivo';

  @override
  String get delay => 'Espera';

  @override
  String get runScene => 'Executar cena';

  @override
  String get addToSiri => 'Adicionar à Siri';

  @override
  String get storeUnderPreparation =>
      'A loja está em preparação, fique atento.';

  @override
  String get commonFunctions => 'Funções comuns';

  @override
  String get noConnection => 'Sem ligação';

  @override
  String get checkInternetAndRetry =>
      'Verifique a ligação à Internet e tente novamente.';

  @override
  String get noConnectionCheckInternet =>
      'Sem ligação. Verifique a Internet e tente novamente.';

  @override
  String get addFirstCurtainHint =>
      'Toque no botão + para adicionar a primeira cortina a esta casa.';

  @override
  String get hideInvisibleDevices => 'Ocultar dispositivos não visíveis';

  @override
  String get deviceRenamed => 'Dispositivo renomeado.';

  @override
  String get deviceDeletedReturningToPairing =>
      'Dispositivo eliminado. Vai voltar ao modo de emparelhamento.';

  @override
  String get homeSettings => 'Definições da casa';

  @override
  String get toBeSet => 'A definir';

  @override
  String get homeMember => 'Membro da casa';

  @override
  String get memberDetails => 'Detalhes do membro';

  @override
  String get addMember => 'Adicionar membro';

  @override
  String get pending => 'Pendente';

  @override
  String get removesFromHomeHint =>
      'Remove da casa; o dispositivo volta ao modo de emparelhamento em 1-2 minutos';

  @override
  String get unlinkAndEraseData => 'Desassociar e apagar dados';

  @override
  String get erasesAllDataHint => 'Apaga todos os dados, não é possível anular';

  @override
  String get somethingWentWrongTryAgain =>
      'Algo não funcionou, tente novamente';

  @override
  String get tapToRunAndAutomation => 'Execução com um toque e automatização';

  @override
  String get thirdPartyControl => 'Controlo por terceiros';

  @override
  String get deviceOfflineNotification => 'Notificação de dispositivo offline';

  @override
  String get others => 'Outros';

  @override
  String get shareDevice => 'Partilhar dispositivo';

  @override
  String get addToHomeScreen => 'Adicionar ao ecrã principal';

  @override
  String get checkDeviceNetwork => 'Verificar a rede do dispositivo';

  @override
  String get checkNow => 'Verificar agora';

  @override
  String get deviceUpdate => 'Atualização do dispositivo';

  @override
  String get removeDevicesWarning =>
      'Serão removidos desta casa e voltarão ao modo de emparelhamento.';

  @override
  String get shown => 'Visível';

  @override
  String get hidden => 'Oculto';

  @override
  String get devicesBackOnHome => 'Os dispositivos voltaram ao Início';

  @override
  String get hiddenFromHome => 'Ocultos do Início';

  @override
  String get offline => 'Offline';

  @override
  String get show => 'Mostrar';

  @override
  String get hide => 'Ocultar';

  @override
  String get profilePhoto => 'Fotografia de perfil';

  @override
  String get nickname => 'Alcunha';

  @override
  String get noRoomsYet => 'Ainda não existem quartos';

  @override
  String get tapPlusToAddRoom => 'Toque em + para adicionar um quarto';

  @override
  String get emailAddressLabel => 'Endereço de e-mail';

  @override
  String get notSet => 'Não definido';

  @override
  String get deviceInformation => 'Informações do dispositivo';

  @override
  String get unknown => 'Desconhecido';

  @override
  String get notReported => 'Não comunicado';

  @override
  String get noScenesUseThisDevice =>
      'Ainda nenhuma cena utiliza este dispositivo.';

  @override
  String get tapToRunLabel => 'Executar com um toque';

  @override
  String get automation => 'Automatização';

  @override
  String get forward => 'Normal';

  @override
  String get back => 'Invertido';

  @override
  String get setting => 'Definição';

  @override
  String get updateAvailable => 'Atualização disponível';

  @override
  String get noUpdatesAvailable => 'Não há atualizações disponíveis';

  @override
  String get updateNow => 'Atualizar agora';

  @override
  String get unassigned => 'Não atribuído';

  @override
  String get enterEmailOrUsername => 'Introduza o e-mail ou nome de utilizador';

  @override
  String get welcome => 'Bem-vindo';

  @override
  String get signInSubtitle => 'Inicie sessão na sua conta osprey.life.';

  @override
  String get createOne => 'Criar uma';

  @override
  String get forgotPassword => 'Esqueceu-se da palavra-passe?';

  @override
  String get orContinueWith => 'ou continue com';

  @override
  String get enterValidEmail => 'Introduza um endereço de e-mail válido';

  @override
  String get resetYourPassword => 'Redefinir a palavra-passe';

  @override
  String get checkYourInbox => 'Verifique a sua caixa de entrada';

  @override
  String get enterYourEmailAddress => 'Introduza o seu endereço de e-mail';

  @override
  String get enterSixDigitCode => 'Introduza o código de 6 dígitos';

  @override
  String get enterAPassword => 'Introduza uma palavra-passe';

  @override
  String get createYourAccount => 'Crie a sua conta';

  @override
  String get checkYourEmail => 'Verifique o seu e-mail';

  @override
  String get resendCode => 'Reenviar código';

  @override
  String get userAgreement => 'Termos de utilização';

  @override
  String get reconnecting => 'A ligar novamente…';

  @override
  String get checkWifiOrBluetooth =>
      'Verifique o Wi-Fi ou aproxime-se para usar Bluetooth.';

  @override
  String get smartScenesRequireInternet =>
      'As cenas inteligentes precisam de Internet';

  @override
  String get enterWifiName => 'Introduza o nome do Wi-Fi';

  @override
  String get wifiNameLengthError =>
      'O nome do Wi-Fi deve ter entre 1 e 32 caracteres';

  @override
  String get passwordMin8 => 'A palavra-passe deve ter pelo menos 8 caracteres';

  @override
  String get passwordLength863 =>
      'A palavra-passe deve ter entre 8 e 63 caracteres';

  @override
  String get networkAlreadySaved =>
      'Esta rede já está guardada. Para alterar a palavra-passe, elimine-a e adicione-a novamente.';

  @override
  String get addWifiNetwork => 'Adicionar rede Wi-Fi';

  @override
  String get atLeast8Characters => 'Pelo menos 8 caracteres';

  @override
  String get only24GhzSupported =>
      'Os dispositivos de cortina suportam apenas Wi-Fi de 2,4 GHz (WPA2).';

  @override
  String get labelOptional => 'Etiqueta (opcional)';

  @override
  String get createGroup => 'Criar grupo';

  @override
  String get groupControlHint =>
      'Os dispositivos do mesmo grupo podem ser controlados em conjunto.';

  @override
  String get devicesToBeAdded => 'Dispositivos a adicionar';

  @override
  String get noSameTypeDevices =>
      'Não existem outros dispositivos do mesmo tipo nesta casa.';

  @override
  String get couldNotLoadNetworkDetails =>
      'Não foi possível carregar os detalhes da rede. Arraste para atualizar.';

  @override
  String get alreadyOnThisNetwork => 'Já está nesta rede.';

  @override
  String get deviceOfflineTryLater =>
      'O dispositivo está offline — tente novamente mais tarde.';

  @override
  String get wrongPassword => 'Palavra-passe incorreta';

  @override
  String get networkNotFound => 'Rede não encontrada';

  @override
  String get networkRemoved => 'Rede removida.';

  @override
  String get network => 'Rede';

  @override
  String get connectedTo => 'Ligado a';

  @override
  String get savedNetworks => 'Redes guardadas';

  @override
  String get addANetwork => 'Adicionar uma rede';

  @override
  String get notConnected => 'Não ligado';

  @override
  String get pleaseKeepAppOpen => 'Mantenha a app aberta.';

  @override
  String get deviceNetworkInformation => 'Informações de rede do dispositivo';

  @override
  String get once => 'Uma vez';

  @override
  String get editSchedule => 'Editar agendamento';

  @override
  String get addSchedule => 'Adicionar agendamento';

  @override
  String get timeVarianceHint => 'A margem de tempo é de ±30 s';

  @override
  String get noTimerData => 'Sem dados do temporizador';

  @override
  String get localControlUnsupportedAction =>
      'O controlo local não suporta esta ação';

  @override
  String get noInternetNoBluetooth =>
      'Sem Internet e Bluetooth fora de alcance';

  @override
  String get connectionError => 'Erro de ligação';

  @override
  String get exampleTapToRun =>
      'Exemplo: desligar todas as luzes do quarto com um toque.';

  @override
  String get exampleWeather =>
      'Exemplo: quando a temperatura local for superior a 28 °C.';

  @override
  String get weatherTrigger => 'Acionador meteorológico';

  @override
  String get exampleSchedule => 'Exemplo: às 7:00 todas as manhãs.';

  @override
  String get exampleDeviceStatus =>
      'Exemplo: quando for detetada uma atividade invulgar.';

  @override
  String get deviceStatusTrigger => 'Acionador de estado do dispositivo';

  @override
  String get noNotificationsYet => 'Ainda não há notificações';

  @override
  String get slashCommands => 'Comandos com barra';

  @override
  String get slashDevicesHint => 'Consulte e controle as suas cortinas.';

  @override
  String get slashSceneHint => 'Executar uma cena com um toque.';

  @override
  String get slashScheduleHint => 'Abrir o agendamento de automatização.';

  @override
  String get slashHelpHint => 'Mostrar esta lista.';

  @override
  String get youCanAlsoSpeak =>
      'Também pode falar — toque no botão do microfone.';

  @override
  String get chatInputHint => 'Escreva, fale ou utilize comandos com barra.';

  @override
  String get online => 'Online';

  @override
  String get blePermissionRequired =>
      'É necessária a permissão de Bluetooth para encontrar dispositivos';

  @override
  String get bleAndLocationPermissionRequired =>
      'São necessárias permissões de Bluetooth e localização para encontrar dispositivos';

  @override
  String get addDeviceLower => 'Adicionar dispositivo';

  @override
  String get scanningStopped => 'Procura interrompida.';

  @override
  String get enterWifiPassword => 'Introduza a palavra-passe do Wi-Fi';

  @override
  String get detectingCurrentWifi => 'A detetar o Wi-Fi atual...';

  @override
  String get autoDetectedWifi =>
      'Detetado automaticamente a partir do Wi-Fi a que o telefone está ligado';

  @override
  String get couldNotDetectWifi =>
      'Não foi possível detetar o Wi-Fi — introduza o nome da rede manualmente';

  @override
  String get beingAdded => 'A adicionar';

  @override
  String get addedSuccessfully => 'Adicionado com êxito';

  @override
  String get pairingFailed => 'Falha no emparelhamento';

  @override
  String get allDay => 'Todo o dia';

  @override
  String get whenAnyConditionMet => 'Quando qualquer condição for cumprida';

  @override
  String get whenAllConditionsMet =>
      'Quando todas as condições forem cumpridas';

  @override
  String get deleteSceneWarning =>
      'Depois de eliminar o cenário, as tarefas dos dispositivos deixam de poder ser executadas corretamente.';

  @override
  String get toggleAutomation => 'Ativar ou desativar automatização';

  @override
  String get enable => 'Ativar';

  @override
  String get disable => 'Desativar';

  @override
  String get everyDay => 'Todos os dias';

  @override
  String get monToFri => 'Seg - Sex';

  @override
  String get satToSun => 'Sáb - Dom';

  @override
  String get runOnceIfNoDaySelected =>
      'A ação será executada apenas uma vez se não selecionar nenhum dia da semana.';

  @override
  String get sendNotification => 'Enviar notificação';

  @override
  String get color => 'Cor';

  @override
  String get wait => 'Esperar';

  @override
  String get finish => 'Concluir';

  @override
  String get selectFunction => 'Selecionar função';

  @override
  String get on => 'Ligado';

  @override
  String get off => 'Desligado';

  @override
  String get siriShortcut => 'Atalho da Siri';

  @override
  String get createTapToRunFirst =>
      'Crie primeiro uma cena de execução com um toque.';

  @override
  String get poweredByFoundationModels =>
      'Com Apple Foundation Models, no dispositivo.';

  @override
  String get weatherClearNight => 'Noite limpa';

  @override
  String get weatherSunny => 'Sol';

  @override
  String get weatherPartlyCloudy => 'Parcialmente nublado';

  @override
  String get weatherCloudy => 'Nublado';

  @override
  String get qualityExcellent => 'Excelente';

  @override
  String get qualityGood => 'Boa';

  @override
  String get qualityModerate => 'Moderada';

  @override
  String get qualityPoor => 'Fraca';

  @override
  String get qualityVeryPoor => 'Muito fraca';

  @override
  String get switchLocation => 'Mudar localização';

  @override
  String get aiSuggestion => 'Sugestão de IA';

  @override
  String get listening => 'A ouvir…';

  @override
  String get parsing => 'A analisar…';

  @override
  String get getStarted => 'Começar';

  @override
  String get aiChatEmptyState =>
      'Pergunte ao assistente osprey.life o que quiser sobre as suas cortinas.\nCom Apple Foundation Models, no dispositivo.';

  @override
  String get chatHeaderSubtitle =>
      'IA no dispositivo para as suas cortinas motorizadas.\nEscreva, fale ou utilize comandos com barra.';

  @override
  String get daySunShort => 'Dom.';

  @override
  String get dayMonShort => 'Seg.';

  @override
  String get dayTueShort => 'Ter.';

  @override
  String get dayWedShort => 'Qua.';

  @override
  String get dayThuShort => 'Qui.';

  @override
  String get dayFriShort => 'Sex.';

  @override
  String get daySatShort => 'Sáb.';

  @override
  String get dayMon => 'Seg';

  @override
  String get dayTue => 'Ter';

  @override
  String get dayWed => 'Qua';

  @override
  String get dayThu => 'Qui';

  @override
  String get dayFri => 'Sex';

  @override
  String get daySat => 'Sáb';

  @override
  String get daySun => 'Dom';

  @override
  String get accountLinkedSuccessfully => 'Conta associada com êxito!';

  @override
  String get linkingFailed => 'Falha na associação';

  @override
  String get anErrorOccurredTryAgain => 'Ocorreu um erro. Tente novamente.';

  @override
  String get signInWithAmazon => 'Iniciar sessão com a Amazon';

  @override
  String get viewMoreWaysToLink => 'Ver mais formas de associar';

  @override
  String get alreadyLinkedWithAlexa => 'Já associado à Amazon Alexa';

  @override
  String get somethingWentWrong => 'Algo não funcionou';

  @override
  String get noAuthorizationCode => 'Não foi recebido código de autorização';

  @override
  String get couldNotOpenGoogleHome =>
      'Não foi possível abrir a app Google Home';

  @override
  String get reLogin => 'Iniciar sessão novamente';

  @override
  String get linkWithGoogleAssistant => 'Associar ao Assistente Google';

  @override
  String get linkedWithGoogleAssistant => 'Associado ao Assistente Google';

  @override
  String get anErrorOccurred => 'Ocorreu um erro';

  @override
  String deleteHomeConfirm(String name) {
    return 'Tem a certeza de que quer eliminar \"$name\"? Esta ação não pode ser anulada.';
  }

  @override
  String get offlineScenesBody =>
      'As cenas e agendamentos ficam em pausa até o Wi-Fi voltar. O controlo local por Bluetooth continua a funcionar para abrir, fechar e parar cada dispositivo.';

  @override
  String get blePairingLostBody =>
      'O controlo local por Bluetooth precisa de ser novamente emparelhado com este dispositivo. Isto acontece normalmente depois de apagar os dados da app ou de reiniciar o dispositivo para as definições de origem.';

  @override
  String get alternateNetworkHint =>
      'Se a rede atual não estiver disponível, o dispositivo liga-se automaticamente a uma rede alternativa.';

  @override
  String get switchNetworkWarning =>
      'O dispositivo vai desligar-se do Wi-Fi atual e tentar ligar-se ao novo. Normalmente demora entre 5 e 30 segundos.';

  @override
  String get runOnceIfNoDayPicked =>
      'A ação será executada apenas uma vez se não a selecionar.';

  @override
  String get alexaUnlinkHint =>
      'Desative a skill osprey.life na app Amazon Alexa ou toque em Eu > o botão Definições no canto superior direito > Conta e segurança para retirar a autorização.';

  @override
  String get alexaLinkExplainer =>
      'Associar a conta da app à sua conta Amazon permite-lhe controlar dispositivos compatíveis com a Alexa através de altifalantes Amazon Echo (ex. \"Alexa, turn on light.\")';

  @override
  String get chatScheduleHelp =>
      'Configure agendamentos automáticos para as suas cortinas. Abra o separador Cenas para criar automatizações diárias, semanais ou únicas.';

  @override
  String get chatScenesHelp =>
      'Crie e gira cenas de execução com um toque no separador Cenas. As cenas permitem encadear várias ações das cortinas com esperas, num só toque.';

  @override
  String get googleUnlinkHint =>
      'Desative a skill osprey.life na app Google Home ou toque em Eu > o botão Definições no canto superior direito > Conta e segurança para retirar a autorização.';

  @override
  String get googleLinkExplainer =>
      'Depois de ligar a conta da app e a sua conta Google, pode usar altifalantes inteligentes Google Home para controlar dispositivos compatíveis com o Assistente Google. Por exemplo, pode dizer: \"OK Google, please turn on the light.\"';

  @override
  String get deviceDisconnectedFromHome =>
      'Dispositivo desassociado da casa. Vai voltar ao modo de emparelhamento em 1-2 minutos.';

  @override
  String get searchingNearbyDevices =>
      'A procurar dispositivos Osprey próximos. Certifique-se de que o dispositivo está em modo de emparelhamento.';

  @override
  String get looksLike5GhzHint =>
      'Esta rede parece ser de 5 GHz — mude o telefone para uma rede de 2,4 GHz e toque em atualizar.';

  @override
  String get pairingWifiHint =>
      'O dispositivo vai ligar-se ao Wi-Fi que o seu telefone está a usar. Apenas são suportadas redes de 2,4 GHz.';

  @override
  String get siriShortcutsHelp =>
      'Toque numa cena para gravar uma frase de voz e depois diga \"E Siri\" seguido dessa frase para executar a cena — mesmo com a app fechada.\n\nToque numa cena que já adicionou para alterar a frase ou removê-la.';

  @override
  String get deleteAccountWarning =>
      'Após a eliminação:\n• A sua conta será eliminada depois de 30 dias\n• Todos os seus dispositivos e cenas serão removidos\n• Pode cancelar iniciando sessão novamente no prazo de 30 dias';

  @override
  String aiSuggestionBody(String action, String weekday, String hour) {
    return 'Normalmente executa \"$action\" à $weekday às $hour:00 — quer automatizar?';
  }

  @override
  String removeDeviceConfirm(String name) {
    return '\"$name\" será removido da sua casa e voltará automaticamente ao modo de emparelhamento em cerca de 1-2 minutos.';
  }

  @override
  String eraseDeviceConfirm(String name) {
    return 'Todos os dados de \"$name\" serão apagados e NÃO poderão ser recuperados. Tem a certeza?';
  }

  @override
  String showInvisibleDevices(int count) {
    return 'Mostrar dispositivos não visíveis ($count)';
  }

  @override
  String resetLinkSent(String email) {
    return 'Se existir uma conta para $email, será enviado um link para redefinir a palavra-passe.';
  }

  @override
  String signInNotAvailable(String name) {
    return 'O início de sessão com $name ainda não está disponível.';
  }

  @override
  String resendCodeIn(int seconds) {
    return 'Reenviar código em $seconds s';
  }

  @override
  String deleteConfirmNamed(String name) {
    return 'Tem a certeza de que quer eliminar \"$name\"?';
  }

  @override
  String taskCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tarefas',
      one: '1 tarefa',
    );
    return '$_temp0';
  }

  @override
  String featureComingSoonShort(String feature) {
    return '$feature estará disponível em breve';
  }

  @override
  String roomCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count quartos',
      one: '1 quarto',
    );
    return '$_temp0';
  }

  @override
  String removeDevicesQ(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Remover $count dispositivos?',
      one: 'Remover o dispositivo?',
    );
    return '$_temp0';
  }

  @override
  String devicesRemoved(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count dispositivos removidos',
      one: '1 dispositivo removido',
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
      other: '$count vezes em 30 dias',
      one: '1 vez em 30 dias',
    );
    return '$_temp0';
  }

  @override
  String sceneExecuted(String name) {
    return '\"$name\" executada';
  }

  @override
  String couldNotRunScene(String name) {
    return 'Não foi possível executar \"$name\". Tente novamente.';
  }

  @override
  String featureComingSoonNamed(String feature) {
    return '$feature estará disponível em breve.';
  }

  @override
  String get couldNotLoadHome =>
      'Não foi possível carregar a sua casa. Tente novamente.';

  @override
  String deviceCouldNotConnectTo(String ssid, String reason, String stayedOn) {
    return 'O dispositivo não conseguiu ligar-se a \"$ssid\".\n\nMotivo: $reason\n\nO dispositivo continua em \"$stayedOn\".';
  }

  @override
  String makeSureNetworkInRange(String ssid) {
    return '\n\nCertifique-se de que \"$ssid\" está ligada e dentro do alcance.';
  }

  @override
  String get noResponseFromDevice =>
      'Não recebemos resposta do dispositivo. Atualize dentro de momentos para ver o estado atual.';

  @override
  String devicesBeingAdded(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'A adicionar $count dispositivos',
      one: 'A adicionar 1 dispositivo',
    );
    return '$_temp0';
  }

  @override
  String devicesAddedSuccessfully(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count dispositivos adicionados com êxito',
      one: '1 dispositivo adicionado com êxito',
    );
    return '$_temp0';
  }

  @override
  String get alexaExamplesIntro =>
      'Pode controlar dispositivos compatíveis com a Alexa\ncom altifalantes Amazon Alexa, por exemplo';

  @override
  String get googleExamplesIntro =>
      'Já pode usar o altifalante Google Home para\ncontrolar dispositivos do Assistente Google, como';

  @override
  String get gridView => 'Vista em grelha';

  @override
  String get listView => 'Vista em lista';

  @override
  String get deviceManagement => 'Gestão de dispositivos';

  @override
  String get sort => 'Ordenar';

  @override
  String get darkMode => 'Modo escuro';

  @override
  String get followSystem => 'Seguir o sistema';

  @override
  String get system => 'Sistema';

  @override
  String get systemDarkModeHint =>
      'Quando ativado, a app liga ou desliga o modo escuro de acordo com as definições do seu sistema.';

  @override
  String get normalMode => 'Modo normal';
}

/// The translations for Portuguese, as used in Brazil (`pt_BR`).
class AppL10nPtBr extends AppL10nPt {
  AppL10nPtBr() : super('pt_BR');

  @override
  String get settingsTitle => 'Configurações';

  @override
  String get personalInformation => 'Informações pessoais';

  @override
  String get accountAndSecurity => 'Conta e segurança';

  @override
  String get touchToneOnPanel => 'Som de toque no painel';

  @override
  String get aiAssistant => 'Assistente de IA';

  @override
  String get temperatureUnit => 'Unidade de temperatura';

  @override
  String get about => 'Sobre';

  @override
  String get networkDiagnosis => 'Diagnóstico de rede';

  @override
  String get clearCache => 'Limpar cache';

  @override
  String get language => 'Idioma';

  @override
  String get logOut => 'Sair';

  @override
  String get languageSystemDefault => 'Igual ao idioma do sistema';

  @override
  String get languageEnglish => 'Inglês';

  @override
  String get languageVietnamese => 'Vietnamita';

  @override
  String get clearCacheMessage =>
      'As cenas, os dados da casa e as imagens em cache serão baixados novamente no próximo uso. Sua conta e seus dispositivos não são afetados.';

  @override
  String get clear => 'Limpar';

  @override
  String get cancel => 'Cancelar';

  @override
  String freedSpace(String size) {
    return '$size liberados';
  }

  @override
  String aboutVersion(String version, String build) {
    return 'Versão $version ($build)';
  }

  @override
  String get privacyPolicy => 'Política de Privacidade';

  @override
  String get termsOfService => 'Termos de Serviço';

  @override
  String get bundleId => 'Bundle ID';

  @override
  String get server => 'Servidor';

  @override
  String get couldNotOpenLink => 'Não foi possível abrir o link.';

  @override
  String get diagLocalNetwork => 'Rede local';

  @override
  String get diagLocalNetworkNoWifi =>
      'Sem Wi-Fi (dados móveis ou permissão negada)';

  @override
  String get diagLocalNetworkUnreadable =>
      'Não foi possível ler o nome da rede Wi-Fi';

  @override
  String get diagDnsLookup => 'Consulta DNS';

  @override
  String diagDnsFailed(String host) {
    return 'Não é possível resolver $host';
  }

  @override
  String get diagServerReachable => 'Servidor acessível';

  @override
  String diagServerLatency(String ms, String status) {
    return '$ms ms · HTTP $status';
  }

  @override
  String get diagServerNoResponse => 'Sem resposta do servidor';

  @override
  String get diagSignedIn => 'Login efetuado';

  @override
  String get diagSessionValid => 'Sessão válida';

  @override
  String diagSessionInvalid(String status) {
    return 'HTTP $status — faça login novamente';
  }

  @override
  String get diagSessionUnverified => 'Não foi possível verificar a sessão';

  @override
  String get diagControlChannel => 'Canal de controle';

  @override
  String get diagCloudConnected => 'Nuvem (MQTT) conectada';

  @override
  String get diagBleFallback => 'Nuvem indisponível — usando Bluetooth';

  @override
  String get diagUnreachable => 'Sem nuvem nem Bluetooth ao alcance';

  @override
  String get diagStatusUnknown => 'Status desconhecido';

  @override
  String get runAgain => 'Executar novamente';

  @override
  String get accountCreatedPleaseSignIn => 'Conta criada — faça login.';

  @override
  String get add => 'Adicionar';

  @override
  String get addCondition => 'Adicionar condição';

  @override
  String get addRoom => 'Adicionar sala';

  @override
  String get addTask => 'Adicionar tarefa';

  @override
  String get addAtLeastTwoDevicesToAGroup =>
      'Adicione pelo menos dois dispositivos a um grupo.';

  @override
  String get alexa => 'Alexa';

  @override
  String get all => 'Todos';

  @override
  String get allDevices => 'Todos os dispositivos';

  @override
  String get alternateNetwork => 'Rede alternativa';

  @override
  String get apply => 'Aplicar';

  @override
  String get areYouSureYouWantToLogOut => 'Tem certeza de que deseja sair?';

  @override
  String get askAboutYourCurtainsOrTryHelp =>
      'Pergunte sobre suas cortinas ou tente /help…';

  @override
  String get askAboutYourCurtains => 'Pergunte sobre suas cortinas…';

  @override
  String get atLeast6Characters => 'Pelo menos 6 caracteres';

  @override
  String get authDiagnostics => 'Diagnóstico de autenticação';

  @override
  String get automationNotification => 'Notificação de automação';

  @override
  String get changeRoom => 'Mudar de sala';

  @override
  String get close => 'Fechar';

  @override
  String get cloud => 'Nuvem';

  @override
  String get confirm => 'Confirmar';

  @override
  String get connected => 'Conectado';

  @override
  String get control => 'Controle';

  @override
  String get controlSingleDevice => 'Controlar um dispositivo';

  @override
  String get copiedToClipboard => 'Copiado para a área de transferência';

  @override
  String get copy => 'Copiar';

  @override
  String get couldNotChangeTheMotorDirectionPleaseTryAgai =>
      'Não foi possível alterar a direção do motor. Tente novamente.';

  @override
  String get couldNotConnect => 'Não foi possível conectar';

  @override
  String get couldNotCreateTheGroupPleaseTryAgain =>
      'Não foi possível criar o grupo. Tente novamente.';

  @override
  String get couldNotOpenTheBrowser => 'Não foi possível abrir o navegador.';

  @override
  String get couldNotSendTheCommandPleaseTryAgain =>
      'Não foi possível enviar o comando. Tente novamente.';

  @override
  String get create => 'Criar';

  @override
  String get createScene => 'Criar cena';

  @override
  String get createAHome => 'Criar uma casa';

  @override
  String get createARoomFirst => 'Crie uma sala primeiro.';

  @override
  String get createAccount => 'Criar conta';

  @override
  String get createScene2 => 'Criar cena';

  @override
  String get curtainPosition => 'Posição da cortina';

  @override
  String get curtainPositionSetting => 'Configuração da posição da cortina';

  @override
  String get customDeviceIconsAreNotSupportedYet =>
      'Ícones de dispositivo personalizados ainda não são suportados.';

  @override
  String get delayTheAction => 'Atrasar a ação';

  @override
  String get delete => 'Excluir';

  @override
  String get deleteAccount => 'Excluir conta';

  @override
  String get deleteHome => 'Excluir casa';

  @override
  String get deleteRoom => 'Excluir sala';

  @override
  String get deleteSchedule => 'Excluir agendamento';

  @override
  String get deleteScene => 'Excluir cena?';

  @override
  String get deleteThisSchedule => 'Excluir este agendamento?';

  @override
  String get deviceNetwork => 'Rede do dispositivo';

  @override
  String get deviceHasNoProfileInformation =>
      'O dispositivo não tem informações de perfil';

  @override
  String get deviceIsOffline => 'O dispositivo está offline';

  @override
  String get deviceIsReady => 'O dispositivo está pronto.';

  @override
  String get deviceName => 'Nome do dispositivo';

  @override
  String get deviceRemovedFromHome => 'Dispositivo removido da casa.';

  @override
  String get deviceUnreachable => 'Dispositivo inacessível';

  @override
  String get devices => 'Dispositivos';

  @override
  String get disconnect => 'Desconectar';

  @override
  String get disconnectDevice => 'Desconectar o dispositivo?';

  @override
  String get done => 'Concluído';

  @override
  String get emailAddress => 'Endereço de e-mail';

  @override
  String get emailOrUsername => 'E-mail ou nome de usuário';

  @override
  String get enterAGroupName => 'Digite um nome de grupo';

  @override
  String get enterANote => 'Digite uma nota';

  @override
  String get enterDeviceName => 'Digite o nome do dispositivo';

  @override
  String get enterHomeName => 'Digite o nome da casa';

  @override
  String get enterName => 'Digite o nome';

  @override
  String get enterSceneName => 'Digite o nome da cena';

  @override
  String get enterValue => 'Digite um valor...';

  @override
  String get enterYourPassword => 'Digite sua senha';

  @override
  String get eraseDeviceData => 'Apagar os dados do dispositivo?';

  @override
  String get error => 'Erro';

  @override
  String get executedBy => 'Executado por';

  @override
  String get executionTime => 'Hora de execução';

  @override
  String get faqFeedback => 'FAQ e feedback';

  @override
  String get failed => 'Falhou';

  @override
  String get featureComingSoon => 'Recurso em breve';

  @override
  String get firmware => 'Firmware';

  @override
  String get firmwareUpdateIsComingSoon =>
      'A atualização do firmware chega em breve.';

  @override
  String get firstName => 'Nome';

  @override
  String get firstNameOptional => 'Nome (opcional)';

  @override
  String get goBack => 'Voltar';

  @override
  String get googleAssistant => 'Google Assistant';

  @override
  String get gotIt => 'Entendi';

  @override
  String get groupName => 'Nome do grupo';

  @override
  String get help => 'Ajuda';

  @override
  String get homeManagement => 'Gerenciamento de casas';

  @override
  String get homeName => 'Nome da casa';

  @override
  String get homeName2 => 'Nome da casa';

  @override
  String get icon => 'Ícone';

  @override
  String get conditionIf => 'Se';

  @override
  String get joinAHome => 'Entrar em uma casa';

  @override
  String get joiningAHomeByInviteIsComingSoon =>
      'Entrar em uma casa por convite chega em breve.';

  @override
  String get lastName => 'Sobrenome';

  @override
  String get lastNameOptional => 'Sobrenome (opcional)';

  @override
  String get later => 'Mais tarde';

  @override
  String get launchTapToRun => 'Executar Tap-to-Run';

  @override
  String get localAssociation => 'Associação local';

  @override
  String get localControlOffline => 'Controle local (offline)';

  @override
  String get location => 'Localização';

  @override
  String get logCopiedToClipboard => 'Log copiado para a área de transferência';

  @override
  String get logs => 'Registros';

  @override
  String get manage => 'Gerenciar';

  @override
  String get managePermissions => 'Gerenciar permissões';

  @override
  String get markAllAsRead => 'Marcar tudo como lido';

  @override
  String get moreSettings => 'Mais configurações';

  @override
  String get motorDirection => 'Direção do motor';

  @override
  String get moveToTop => 'Mover para o topo';

  @override
  String get moveToRoom => 'Mover para a sala';

  @override
  String get moved => 'Movido';

  @override
  String get movedToTop => 'Movido para o topo';

  @override
  String get name => 'Nome';

  @override
  String get next => 'Avançar';

  @override
  String get noDevicesAvailable => 'Nenhum dispositivo disponível';

  @override
  String get noDevicesFound => 'Nenhum dispositivo encontrado.';

  @override
  String get noDevicesInThisHome => 'Nenhum dispositivo nesta casa.';

  @override
  String get noDevicesYet => 'Ainda sem dispositivos';

  @override
  String get noFunctionsAvailable => 'Nenhuma função disponível';

  @override
  String get noHomeSelectedPleaseTryAgain =>
      'Nenhuma casa selecionada, tente novamente';

  @override
  String get noMatchingTimeZones => 'Nenhum fuso horário correspondente';

  @override
  String get noOtherScenesAvailable => 'Nenhuma outra cena disponível';

  @override
  String get noRooms => 'Sem salas';

  @override
  String get noSavedNetworksYet => 'Ainda sem redes salvas.';

  @override
  String get noScenes => 'Sem cenas';

  @override
  String get noScenesAvailable => 'Nenhuma cena disponível';

  @override
  String get note => 'Nota';

  @override
  String get notification => 'Notificação';

  @override
  String get ok => 'OK';

  @override
  String get offlineNotification => 'Notificação de offline';

  @override
  String get open => 'Abrir';

  @override
  String get openSettings => 'Abrir configurações';

  @override
  String get outdoorPm25 => 'PM2.5 externo';

  @override
  String get outdoorAirPressure => 'Pressão do ar externa';

  @override
  String get outdoorHumidity => 'Umidade externa';

  @override
  String get outdoorWindSpeed => 'Velocidade do vento externa';

  @override
  String get pairingSuccessful => 'Pareamento concluído';

  @override
  String get password => 'Senha';

  @override
  String get sessionExpiredSignInAgain =>
      'Sua sessão expirou. Faça login novamente.';

  @override
  String get pleaseAddAtLeast1Action => 'Adicione pelo menos 1 ação';

  @override
  String get pleaseAddAtLeast1Condition => 'Adicione pelo menos 1 condição';

  @override
  String get pleaseEnterAName => 'Digite um nome';

  @override
  String get pleaseEnterASceneName => 'Digite um nome para a cena';

  @override
  String get pleaseSelectAFunction => 'Selecione uma função';

  @override
  String get pleaseSelectATime0 => 'Selecione um tempo > 0';

  @override
  String get rePairNow => 'Parear novamente';

  @override
  String get rePairRequired => 'É necessário parear novamente';

  @override
  String get reasonOptional => 'Motivo (opcional)';

  @override
  String get refresh => 'Atualizar';

  @override
  String get reload => 'Recarregar';

  @override
  String get remove => 'Remover';

  @override
  String get removeDevice => 'Remover dispositivo';

  @override
  String get removed => 'Removido';

  @override
  String get rename => 'Renomear';

  @override
  String get renameRoom => 'Renomear sala';

  @override
  String get renameDevice => 'Renomear dispositivo';

  @override
  String get repeat => 'Repetir';

  @override
  String get rescan => 'Buscar novamente';

  @override
  String get retry => 'Tentar novamente';

  @override
  String get roomManagement => 'Gerenciamento de salas';

  @override
  String get roomName => 'Nome da sala';

  @override
  String get roomUpdated => 'Sala atualizada';

  @override
  String get running => 'Em execução';

  @override
  String get save => 'Salvar';

  @override
  String get sceneName => 'Nome da cena';

  @override
  String get scenes => 'Cenas';

  @override
  String get schedule => 'Agendamento';

  @override
  String get searchAddress => 'Buscar endereço';

  @override
  String get searchCityOrRegion => 'Buscar cidade ou região';

  @override
  String get selectScene => 'Selecionar cena';

  @override
  String get selectSmartScenes => 'Selecionar cenas inteligentes';

  @override
  String get sendResetLink => 'Enviar link de redefinição';

  @override
  String get sendVerificationCode => 'Enviar código de verificação';

  @override
  String get showOnHomePage => 'Mostrar na página inicial';

  @override
  String get signIn => 'Entrar';

  @override
  String get signalStrength => 'Intensidade do sinal';

  @override
  String get signalStrength2 => 'Intensidade do sinal';

  @override
  String get startPairing => 'Iniciar pareamento';

  @override
  String get stop => 'Parar';

  @override
  String get style => 'Estilo';

  @override
  String get switchNetwork => 'Mudar';

  @override
  String get switchToThisNetwork => 'Mudar para esta rede';

  @override
  String get tapToRunNotification => 'Notificação Tap-to-Run';

  @override
  String get conditionThen => 'Então';

  @override
  String get thinking => 'Pensando…';

  @override
  String get thisActionCannotBeUndone => 'Esta ação não pode ser desfeita.';

  @override
  String get thisSavedNetworkWillBeRemovedFromTheDevice =>
      'Esta rede salva será removida do dispositivo.';

  @override
  String get timeZone => 'Fuso horário';

  @override
  String get timeZoneUpdated => 'Fuso horário atualizado';

  @override
  String get timedOut => 'Tempo esgotado';

  @override
  String get tryAgain => 'Tentar novamente';

  @override
  String get useCurrentLocation => 'Usar a localização atual';

  @override
  String get usingSiri => 'Usando a Siri';

  @override
  String get virtualId => 'ID virtual';

  @override
  String get whenDeviceStatusChanges => 'Quando o status do dispositivo muda';

  @override
  String get whenWeatherChanges => 'Quando o clima muda';

  @override
  String get wiFi => 'Wi-Fi';

  @override
  String get wifiNameSsid => 'Nome do WiFi (SSID)';

  @override
  String get wifiPassword => 'Senha do WiFi';

  @override
  String get navHome => 'Início';

  @override
  String get navScenes => 'Cenas';

  @override
  String get navChat => 'Chat';

  @override
  String get navMe => 'Eu';

  @override
  String get thirdPartyServices => 'Serviços de terceiros';

  @override
  String get messageCenter => 'Central de mensagens';

  @override
  String get appMall => 'Loja de apps';

  @override
  String get addDevice => 'Adicionar dispositivo';

  @override
  String get tapToRun => 'Executar com um toque';

  @override
  String get automationEmptyHint =>
      'A automação economiza seu tempo e esforço automatizando tarefas rotineiras.';

  @override
  String get tapToRunEmptyHint =>
      'Crie uma cena de execução com um toque para controlar seus dispositivos rapidamente.';

  @override
  String get scene => 'Cena';

  @override
  String get executionFailed => 'Falha na execução';

  @override
  String get device => 'Dispositivo';

  @override
  String get delay => 'Espera';

  @override
  String get runScene => 'Executar cena';

  @override
  String get addToSiri => 'Adicionar à Siri';

  @override
  String get storeUnderPreparation =>
      'A loja está em preparação, fique ligado.';

  @override
  String get commonFunctions => 'Funções comuns';

  @override
  String get noConnection => 'Sem conexão';

  @override
  String get checkInternetAndRetry =>
      'Verifique sua conexão com a internet e tente novamente.';

  @override
  String get noConnectionCheckInternet =>
      'Sem conexão. Verifique sua internet e tente novamente.';

  @override
  String get addFirstCurtainHint =>
      'Toque no botão + para adicionar sua primeira cortina a esta casa.';

  @override
  String get hideInvisibleDevices => 'Ocultar dispositivos não visíveis';

  @override
  String get deviceRenamed => 'Dispositivo renomeado.';

  @override
  String get deviceDeletedReturningToPairing =>
      'Dispositivo excluído. Ele voltará ao modo de pareamento.';

  @override
  String get homeSettings => 'Configurações da casa';

  @override
  String get toBeSet => 'A definir';

  @override
  String get homeMember => 'Membro da casa';

  @override
  String get memberDetails => 'Detalhes do membro';

  @override
  String get addMember => 'Adicionar membro';

  @override
  String get pending => 'Pendente';

  @override
  String get removesFromHomeHint =>
      'Remove da casa; o dispositivo volta ao modo de pareamento em 1-2 minutos';

  @override
  String get unlinkAndEraseData => 'Desvincular e apagar dados';

  @override
  String get erasesAllDataHint =>
      'Apaga todos os dados, não é possível desfazer';

  @override
  String get somethingWentWrongTryAgain => 'Algo deu errado, tente novamente';

  @override
  String get tapToRunAndAutomation => 'Execução com um toque e automação';

  @override
  String get thirdPartyControl => 'Controle por terceiros';

  @override
  String get deviceOfflineNotification => 'Notificação de dispositivo offline';

  @override
  String get others => 'Outros';

  @override
  String get shareDevice => 'Compartilhar dispositivo';

  @override
  String get addToHomeScreen => 'Adicionar à tela de início';

  @override
  String get checkDeviceNetwork => 'Verificar a rede do dispositivo';

  @override
  String get checkNow => 'Verificar agora';

  @override
  String get deviceUpdate => 'Atualização do dispositivo';

  @override
  String get removeDevicesWarning =>
      'Eles serão removidos desta casa e voltarão ao modo de pareamento.';

  @override
  String get shown => 'Visível';

  @override
  String get hidden => 'Oculto';

  @override
  String get devicesBackOnHome => 'Os dispositivos voltaram para a Início';

  @override
  String get hiddenFromHome => 'Ocultos da Início';

  @override
  String get offline => 'Offline';

  @override
  String get show => 'Mostrar';

  @override
  String get hide => 'Ocultar';

  @override
  String get profilePhoto => 'Foto do perfil';

  @override
  String get nickname => 'Apelido';

  @override
  String get noRoomsYet => 'Ainda não há quartos';

  @override
  String get tapPlusToAddRoom => 'Toque em + para adicionar um quarto';

  @override
  String get emailAddressLabel => 'Endereço de e-mail';

  @override
  String get notSet => 'Não definido';

  @override
  String get deviceInformation => 'Informações do dispositivo';

  @override
  String get unknown => 'Desconhecido';

  @override
  String get notReported => 'Não informado';

  @override
  String get noScenesUseThisDevice =>
      'Ainda nenhuma cena usa este dispositivo.';

  @override
  String get tapToRunLabel => 'Executar com um toque';

  @override
  String get automation => 'Automação';

  @override
  String get forward => 'Normal';

  @override
  String get back => 'Invertido';

  @override
  String get setting => 'Configuração';

  @override
  String get updateAvailable => 'Atualização disponível';

  @override
  String get noUpdatesAvailable => 'Nenhuma atualização disponível';

  @override
  String get updateNow => 'Atualizar agora';

  @override
  String get unassigned => 'Não atribuído';

  @override
  String get enterEmailOrUsername => 'Digite seu e-mail ou nome de usuário';

  @override
  String get welcome => 'Bem-vindo';

  @override
  String get signInSubtitle => 'Entre na sua conta osprey.life.';

  @override
  String get createOne => 'Criar uma';

  @override
  String get forgotPassword => 'Esqueceu a senha?';

  @override
  String get orContinueWith => 'ou continue com';

  @override
  String get enterValidEmail => 'Digite um endereço de e-mail válido';

  @override
  String get resetYourPassword => 'Redefinir sua senha';

  @override
  String get checkYourInbox => 'Confira sua caixa de entrada';

  @override
  String get enterYourEmailAddress => 'Digite seu endereço de e-mail';

  @override
  String get enterSixDigitCode => 'Digite o código de 6 dígitos';

  @override
  String get enterAPassword => 'Digite uma senha';

  @override
  String get createYourAccount => 'Crie sua conta';

  @override
  String get checkYourEmail => 'Confira seu e-mail';

  @override
  String get resendCode => 'Reenviar código';

  @override
  String get userAgreement => 'Termos de uso';

  @override
  String get reconnecting => 'Reconectando…';

  @override
  String get checkWifiOrBluetooth =>
      'Verifique o Wi-Fi ou aproxime-se para usar o Bluetooth.';

  @override
  String get smartScenesRequireInternet =>
      'As cenas inteligentes precisam de internet';

  @override
  String get enterWifiName => 'Digite o nome do Wi-Fi';

  @override
  String get wifiNameLengthError =>
      'O nome do Wi-Fi deve ter de 1 a 32 caracteres';

  @override
  String get passwordMin8 => 'A senha deve ter pelo menos 8 caracteres';

  @override
  String get passwordLength863 => 'A senha deve ter de 8 a 63 caracteres';

  @override
  String get networkAlreadySaved =>
      'Esta rede já está salva. Para mudar a senha, exclua-a e adicione novamente.';

  @override
  String get addWifiNetwork => 'Adicionar rede Wi-Fi';

  @override
  String get atLeast8Characters => 'Pelo menos 8 caracteres';

  @override
  String get only24GhzSupported =>
      'Dispositivos de cortina só funcionam com Wi-Fi de 2,4 GHz (WPA2).';

  @override
  String get labelOptional => 'Etiqueta (opcional)';

  @override
  String get createGroup => 'Criar grupo';

  @override
  String get groupControlHint =>
      'Dispositivos do mesmo grupo podem ser controlados juntos.';

  @override
  String get devicesToBeAdded => 'Dispositivos a adicionar';

  @override
  String get noSameTypeDevices =>
      'Não há outros dispositivos do mesmo tipo nesta casa.';

  @override
  String get couldNotLoadNetworkDetails =>
      'Não foi possível carregar os detalhes da rede. Arraste para atualizar.';

  @override
  String get alreadyOnThisNetwork => 'Já está nesta rede.';

  @override
  String get deviceOfflineTryLater =>
      'O dispositivo está offline — tente novamente mais tarde.';

  @override
  String get wrongPassword => 'Senha incorreta';

  @override
  String get networkNotFound => 'Rede não encontrada';

  @override
  String get networkRemoved => 'Rede removida.';

  @override
  String get network => 'Rede';

  @override
  String get connectedTo => 'Conectado a';

  @override
  String get savedNetworks => 'Redes salvas';

  @override
  String get addANetwork => 'Adicionar uma rede';

  @override
  String get notConnected => 'Não conectado';

  @override
  String get pleaseKeepAppOpen => 'Mantenha o app aberto.';

  @override
  String get deviceNetworkInformation => 'Informações de rede do dispositivo';

  @override
  String get once => 'Uma vez';

  @override
  String get editSchedule => 'Editar programação';

  @override
  String get addSchedule => 'Adicionar programação';

  @override
  String get timeVarianceHint => 'A variação de tempo é de ±30 s';

  @override
  String get noTimerData => 'Sem dados do timer';

  @override
  String get localControlUnsupportedAction =>
      'O controle local não suporta esta ação';

  @override
  String get noInternetNoBluetooth =>
      'Sem internet e Bluetooth fora de alcance';

  @override
  String get connectionError => 'Erro de conexão';

  @override
  String get exampleTapToRun =>
      'Exemplo: apagar todas as luzes do quarto com um toque.';

  @override
  String get exampleWeather =>
      'Exemplo: quando a temperatura local passar de 28 °C.';

  @override
  String get weatherTrigger => 'Acionador de clima';

  @override
  String get exampleSchedule => 'Exemplo: às 7:00 toda manhã.';

  @override
  String get exampleDeviceStatus =>
      'Exemplo: quando uma atividade incomum for detectada.';

  @override
  String get deviceStatusTrigger => 'Acionador de status do dispositivo';

  @override
  String get noNotificationsYet => 'Ainda não há notificações';

  @override
  String get slashCommands => 'Comandos com barra';

  @override
  String get slashDevicesHint => 'Veja e controle suas cortinas.';

  @override
  String get slashSceneHint => 'Executar uma cena com um toque.';

  @override
  String get slashScheduleHint => 'Abrir a programação de automação.';

  @override
  String get slashHelpHint => 'Mostrar esta lista.';

  @override
  String get youCanAlsoSpeak =>
      'Você também pode falar — toque no botão do microfone.';

  @override
  String get chatInputHint => 'Digite, fale ou use comandos com barra.';

  @override
  String get online => 'Online';

  @override
  String get blePermissionRequired =>
      'É necessária a permissão de Bluetooth para encontrar dispositivos';

  @override
  String get bleAndLocationPermissionRequired =>
      'São necessárias as permissões de Bluetooth e localização para encontrar dispositivos';

  @override
  String get addDeviceLower => 'Adicionar dispositivo';

  @override
  String get scanningStopped => 'Busca interrompida.';

  @override
  String get enterWifiPassword => 'Digite a senha do Wi-Fi';

  @override
  String get detectingCurrentWifi => 'Detectando o Wi-Fi atual...';

  @override
  String get autoDetectedWifi =>
      'Detectado automaticamente do Wi-Fi ao qual seu celular está conectado';

  @override
  String get couldNotDetectWifi =>
      'Não foi possível detectar o Wi-Fi — digite o nome da rede manualmente';

  @override
  String get beingAdded => 'Adicionando';

  @override
  String get addedSuccessfully => 'Adicionado com sucesso';

  @override
  String get pairingFailed => 'Falha no pareamento';

  @override
  String get allDay => 'Todo o dia';

  @override
  String get whenAnyConditionMet => 'Quando qualquer condição for atendida';

  @override
  String get whenAllConditionsMet =>
      'Quando todas as condições forem atendidas';

  @override
  String get deleteSceneWarning =>
      'Depois que o cenário for excluído, as tarefas dos dispositivos não poderão mais ser executadas corretamente.';

  @override
  String get toggleAutomation => 'Ativar ou desativar automação';

  @override
  String get enable => 'Ativar';

  @override
  String get disable => 'Desativar';

  @override
  String get everyDay => 'Todos os dias';

  @override
  String get monToFri => 'Seg - Sex';

  @override
  String get satToSun => 'Sáb - Dom';

  @override
  String get runOnceIfNoDaySelected =>
      'A ação será executada apenas uma vez se você não selecionar nenhum dia da semana.';

  @override
  String get sendNotification => 'Enviar notificação';

  @override
  String get color => 'Cor';

  @override
  String get wait => 'Esperar';

  @override
  String get finish => 'Concluir';

  @override
  String get selectFunction => 'Selecionar função';

  @override
  String get on => 'Ligado';

  @override
  String get off => 'Desligado';

  @override
  String get siriShortcut => 'Atalho da Siri';

  @override
  String get createTapToRunFirst =>
      'Crie primeiro uma cena de execução com um toque.';

  @override
  String get poweredByFoundationModels =>
      'Com Apple Foundation Models, no próprio dispositivo.';

  @override
  String get weatherClearNight => 'Noite limpa';

  @override
  String get weatherSunny => 'Sol';

  @override
  String get weatherPartlyCloudy => 'Parcialmente nublado';

  @override
  String get weatherCloudy => 'Nublado';

  @override
  String get qualityExcellent => 'Excelente';

  @override
  String get qualityGood => 'Boa';

  @override
  String get qualityModerate => 'Moderada';

  @override
  String get qualityPoor => 'Ruim';

  @override
  String get qualityVeryPoor => 'Muito ruim';

  @override
  String get switchLocation => 'Mudar local';

  @override
  String get aiSuggestion => 'Sugestão de IA';

  @override
  String get listening => 'Ouvindo…';

  @override
  String get parsing => 'Analisando…';

  @override
  String get getStarted => 'Começar';

  @override
  String get aiChatEmptyState =>
      'Pergunte ao assistente osprey.life o que quiser sobre suas cortinas.\nCom Apple Foundation Models, no próprio dispositivo.';

  @override
  String get chatHeaderSubtitle =>
      'IA no próprio dispositivo para suas cortinas motorizadas.\nDigite, fale ou use comandos com barra.';

  @override
  String get daySunShort => 'Dom.';

  @override
  String get dayMonShort => 'Seg.';

  @override
  String get dayTueShort => 'Ter.';

  @override
  String get dayWedShort => 'Qua.';

  @override
  String get dayThuShort => 'Qui.';

  @override
  String get dayFriShort => 'Sex.';

  @override
  String get daySatShort => 'Sáb.';

  @override
  String get dayMon => 'Seg';

  @override
  String get dayTue => 'Ter';

  @override
  String get dayWed => 'Qua';

  @override
  String get dayThu => 'Qui';

  @override
  String get dayFri => 'Sex';

  @override
  String get daySat => 'Sáb';

  @override
  String get daySun => 'Dom';

  @override
  String get accountLinkedSuccessfully => 'Conta vinculada com sucesso!';

  @override
  String get linkingFailed => 'Falha na vinculação';

  @override
  String get anErrorOccurredTryAgain => 'Ocorreu um erro. Tente novamente.';

  @override
  String get signInWithAmazon => 'Entrar com a Amazon';

  @override
  String get viewMoreWaysToLink => 'Ver mais formas de vincular';

  @override
  String get alreadyLinkedWithAlexa => 'Já vinculado à Amazon Alexa';

  @override
  String get somethingWentWrong => 'Algo deu errado';

  @override
  String get noAuthorizationCode => 'Nenhum código de autorização recebido';

  @override
  String get couldNotOpenGoogleHome =>
      'Não foi possível abrir o app Google Home';

  @override
  String get reLogin => 'Entrar novamente';

  @override
  String get linkWithGoogleAssistant => 'Vincular ao Google Assistente';

  @override
  String get linkedWithGoogleAssistant => 'Vinculado ao Google Assistente';

  @override
  String get anErrorOccurred => 'Ocorreu um erro';

  @override
  String deleteHomeConfirm(String name) {
    return 'Tem certeza de que quer excluir \"$name\"? Esta ação não pode ser desfeita.';
  }

  @override
  String get offlineScenesBody =>
      'As cenas e programações ficam pausadas até o Wi-Fi voltar. O controle local por Bluetooth continua funcionando para abrir, fechar e parar cada dispositivo.';

  @override
  String get blePairingLostBody =>
      'O controle local por Bluetooth precisa ser pareado novamente com este dispositivo. Isso costuma acontecer depois que os dados do app são apagados ou o dispositivo é restaurado para o padrão de fábrica.';

  @override
  String get alternateNetworkHint =>
      'Se a rede atual não estiver disponível, o dispositivo se conectará automaticamente a uma rede alternativa.';

  @override
  String get switchNetworkWarning =>
      'O dispositivo vai se desconectar do Wi-Fi atual e tentar entrar no novo. Isso costuma levar de 5 a 30 segundos.';

  @override
  String get runOnceIfNoDayPicked =>
      'A ação será executada apenas uma vez se você não a selecionar.';

  @override
  String get alexaUnlinkHint =>
      'Desative a skill osprey.life no app Amazon Alexa ou toque em Eu > o botão Configurações no canto superior direito > Conta e segurança para retirar a autorização.';

  @override
  String get alexaLinkExplainer =>
      'Vincular a conta do app à sua conta Amazon permite controlar dispositivos compatíveis com a Alexa pelas caixas de som Amazon Echo (ex. \"Alexa, turn on light.\")';

  @override
  String get chatScheduleHelp =>
      'Configure programações automáticas para suas cortinas. Abra a aba Cenas para criar automações diárias, semanais ou de uma única vez.';

  @override
  String get chatScenesHelp =>
      'Crie e gerencie cenas de execução com um toque na aba Cenas. As cenas permitem encadear várias ações das cortinas com esperas, em um só toque.';

  @override
  String get googleUnlinkHint =>
      'Desative a skill osprey.life no app Google Home ou toque em Eu > o botão Configurações no canto superior direito > Conta e segurança para retirar a autorização.';

  @override
  String get googleLinkExplainer =>
      'Depois de conectar a conta do app e sua conta Google, você poderá usar as caixas de som inteligentes Google Home para controlar dispositivos compatíveis com o Google Assistente. Por exemplo, você pode dizer: \"OK Google, please turn on the light.\"';

  @override
  String get deviceDisconnectedFromHome =>
      'Dispositivo desvinculado da casa. Ele voltará ao modo de pareamento em 1-2 minutos.';

  @override
  String get searchingNearbyDevices =>
      'Procurando dispositivos Osprey por perto. Verifique se o dispositivo está no modo de pareamento.';

  @override
  String get looksLike5GhzHint =>
      'Esta rede parece ser de 5 GHz — mude seu celular para uma rede de 2,4 GHz e toque em atualizar.';

  @override
  String get pairingWifiHint =>
      'O dispositivo vai se conectar ao Wi-Fi que seu celular está usando. Só há suporte para redes de 2,4 GHz.';

  @override
  String get siriShortcutsHelp =>
      'Toque em uma cena para gravar uma frase de voz e depois diga \"E Siri\" seguido dessa frase para executar a cena — mesmo com o app fechado.\n\nToque em uma cena que você já adicionou para mudar a frase ou removê-la.';

  @override
  String get deleteAccountWarning =>
      'Após a exclusão:\n• Sua conta será excluída depois de 30 dias\n• Todos os seus dispositivos e cenas serão removidos\n• Você pode cancelar entrando novamente dentro de 30 dias';

  @override
  String aiSuggestionBody(String action, String weekday, String hour) {
    return 'Você costuma executar \"$action\" na $weekday às $hour:00 — quer automatizar?';
  }

  @override
  String removeDeviceConfirm(String name) {
    return '\"$name\" será removido da sua casa e voltará automaticamente ao modo de pareamento em cerca de 1-2 minutos.';
  }

  @override
  String eraseDeviceConfirm(String name) {
    return 'Todos os dados de \"$name\" serão apagados e NÃO poderão ser recuperados. Tem certeza?';
  }

  @override
  String showInvisibleDevices(int count) {
    return 'Mostrar dispositivos não visíveis ($count)';
  }

  @override
  String resetLinkSent(String email) {
    return 'Se existir uma conta para $email, um link para redefinir a senha está a caminho.';
  }

  @override
  String signInNotAvailable(String name) {
    return 'O login com $name ainda não está disponível.';
  }

  @override
  String resendCodeIn(int seconds) {
    return 'Reenviar código em $seconds s';
  }

  @override
  String deleteConfirmNamed(String name) {
    return 'Tem certeza de que quer excluir \"$name\"?';
  }

  @override
  String taskCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tarefas',
      one: '1 tarefa',
    );
    return '$_temp0';
  }

  @override
  String featureComingSoonShort(String feature) {
    return '$feature chega em breve';
  }

  @override
  String roomCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count quartos',
      one: '1 quarto',
    );
    return '$_temp0';
  }

  @override
  String removeDevicesQ(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Remover $count dispositivos?',
      one: 'Remover o dispositivo?',
    );
    return '$_temp0';
  }

  @override
  String devicesRemoved(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count dispositivos removidos',
      one: '1 dispositivo removido',
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
    return 'Temperatura externa: $temp °C';
  }

  @override
  String occurrencesIn30Days(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count vezes em 30 dias',
      one: '1 vez em 30 dias',
    );
    return '$_temp0';
  }

  @override
  String sceneExecuted(String name) {
    return '\"$name\" executada';
  }

  @override
  String couldNotRunScene(String name) {
    return 'Não foi possível executar \"$name\". Tente novamente.';
  }

  @override
  String featureComingSoonNamed(String feature) {
    return '$feature chega em breve.';
  }

  @override
  String get couldNotLoadHome =>
      'Não foi possível carregar sua casa. Tente novamente.';

  @override
  String deviceCouldNotConnectTo(String ssid, String reason, String stayedOn) {
    return 'O dispositivo não conseguiu se conectar a \"$ssid\".\n\nMotivo: $reason\n\nO dispositivo continua em \"$stayedOn\".';
  }

  @override
  String makeSureNetworkInRange(String ssid) {
    return '\n\nVerifique se \"$ssid\" está ligada e dentro do alcance.';
  }

  @override
  String get noResponseFromDevice =>
      'Não recebemos resposta do dispositivo. Atualize em instantes para ver o status atual.';

  @override
  String devicesBeingAdded(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Adicionando $count dispositivos',
      one: 'Adicionando 1 dispositivo',
    );
    return '$_temp0';
  }

  @override
  String devicesAddedSuccessfully(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count dispositivos adicionados com sucesso',
      one: '1 dispositivo adicionado com sucesso',
    );
    return '$_temp0';
  }

  @override
  String get alexaExamplesIntro =>
      'Você pode controlar dispositivos compatíveis com a Alexa\ncom caixas de som Amazon Alexa, por exemplo';

  @override
  String get googleExamplesIntro =>
      'Agora você pode usar a caixa de som Google Home para\ncontrolar dispositivos do Google Assistente, como';

  @override
  String get gridView => 'Visualização em grade';

  @override
  String get listView => 'Visualização em lista';

  @override
  String get deviceManagement => 'Gerenciamento de dispositivos';

  @override
  String get sort => 'Ordenar';

  @override
  String get darkMode => 'Modo escuro';

  @override
  String get followSystem => 'Seguir o sistema';

  @override
  String get system => 'Sistema';

  @override
  String get systemDarkModeHint =>
      'Quando ativado, o app liga ou desliga o modo escuro de acordo com as configurações do seu sistema.';

  @override
  String get normalMode => 'Modo normal';
}
