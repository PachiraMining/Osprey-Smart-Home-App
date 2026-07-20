import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/di/injector.dart';
import '../../../../../core/notifications/message_center.dart';
import '../../../domain/entities/automation_scene_entity.dart';
import '../../../domain/usecases/get_automations.dart';
import '../../../domain/usecases/create_automation.dart';
import '../../../domain/usecases/update_automation.dart';
import '../../../domain/usecases/delete_automation.dart';
import '../../../domain/usecases/toggle_automation.dart';
import 'automation_event.dart';
import 'automation_state.dart';

class AutomationBloc extends Bloc<AutomationEvent, AutomationState> {
  final GetAutomations getAutomations;
  final CreateAutomation createAutomation;
  final UpdateAutomation updateAutomation;
  final DeleteAutomation deleteAutomation;
  final ToggleAutomation toggleAutomation;

  String? _homeId;

  AutomationBloc({
    required this.getAutomations,
    required this.createAutomation,
    required this.updateAutomation,
    required this.deleteAutomation,
    required this.toggleAutomation,
  }) : super(AutomationInitial()) {
    on<LoadAutomationsEvent>(_onLoadAutomations);
    on<CreateAutomationEvent>(_onCreateAutomation);
    on<UpdateAutomationEvent>(_onUpdateAutomation);
    on<DeleteAutomationEvent>(_onDeleteAutomation);
    on<ToggleAutomationEvent>(_onToggleAutomation);
  }

  Future<void> _onLoadAutomations(
    LoadAutomationsEvent event,
    Emitter<AutomationState> emit,
  ) async {
    _homeId = event.homeId;
    emit(AutomationLoading());
    final result = await getAutomations(event.homeId);
    result.fold(
      (failure) => emit(AutomationError(failure.message)),
      (automations) => emit(AutomationLoaded(automations)),
    );
  }

  Future<void> _onCreateAutomation(
    CreateAutomationEvent event,
    Emitter<AutomationState> emit,
  ) async {
    if (_homeId == null) {
      emit(const AutomationError('Home not found'));
      return;
    }
    emit(AutomationCreating());
    final result = await createAutomation(
      homeId: _homeId!,
      name: event.name,
      icon: event.icon,
      conditions: event.conditions,
      conditionLogic: event.conditionLogic,
      effectiveTime: event.effectiveTime,
      actions: event.actions,
    );
    result.fold(
      (failure) => emit(AutomationError(failure.message)),
      (_) {
        if (sl.isRegistered<MessageCenter>()) {
          sl<MessageCenter>().log(
            type: AppMessageType.scene,
            title: 'Automation notification',
            body: 'Automation "${event.name}" was created.',
          );
        }
        emit(AutomationCreated());
        add(LoadAutomationsEvent(_homeId!));
      },
    );
  }

  Future<void> _onUpdateAutomation(
    UpdateAutomationEvent event,
    Emitter<AutomationState> emit,
  ) async {
    emit(AutomationCreating());
    final result = await updateAutomation(
      sceneId: event.sceneId,
      name: event.name,
      icon: event.icon,
      enabled: event.enabled,
      conditions: event.conditions,
      conditionLogic: event.conditionLogic,
      effectiveTime: event.effectiveTime,
      actions: event.actions,
    );
    result.fold(
      (failure) => emit(AutomationError(failure.message)),
      (_) {
        emit(AutomationCreated());
        if (_homeId != null) add(LoadAutomationsEvent(_homeId!));
      },
    );
  }

  Future<void> _onDeleteAutomation(
    DeleteAutomationEvent event,
    Emitter<AutomationState> emit,
  ) async {
    // Optimistic delete
    final currentAutomations = state is AutomationLoaded
        ? (state as AutomationLoaded).automations
        : <AutomationSceneEntity>[];

    final updated =
        currentAutomations.where((a) => a.id != event.sceneId).toList();
    emit(AutomationLoaded(updated));

    String deletedName() {
      for (final a in currentAutomations) {
        if (a.id == event.sceneId) return a.name;
      }
      return 'automation';
    }

    if (sl.isRegistered<MessageCenter>()) {
      sl<MessageCenter>().log(
        type: AppMessageType.scene,
        title: 'Automation notification',
        body: 'Automation "${deletedName()}" was deleted.',
      );
    }

    final result = await deleteAutomation(event.sceneId);
    result.fold(
      (failure) => emit(AutomationLoaded(currentAutomations)),
      (_) {},
    );
  }

  Future<void> _onToggleAutomation(
    ToggleAutomationEvent event,
    Emitter<AutomationState> emit,
  ) async {
    // Optimistic toggle
    if (state is AutomationLoaded) {
      final currentAutomations = (state as AutomationLoaded).automations;
      final updated = currentAutomations.map((a) {
        if (a.id == event.sceneId) {
          return AutomationSceneEntity(
            id: a.id,
            name: a.name,
            sceneType: a.sceneType,
            icon: a.icon,
            enabled: event.enabled,
            conditions: a.conditions,
            conditionLogic: a.conditionLogic,
            effectiveTime: a.effectiveTime,
            actions: a.actions,
          );
        }
        return a;
      }).toList();
      emit(AutomationLoaded(updated));

      final result = await toggleAutomation(event.sceneId, event.enabled);
      result.fold(
        (failure) => emit(AutomationLoaded(currentAutomations)),
        (_) {},
      );
    }
  }
}
