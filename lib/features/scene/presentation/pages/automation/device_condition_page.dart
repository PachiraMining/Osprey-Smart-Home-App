import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

import '../../../../../core/theme/app_surfaces.dart';
import '../../../../../l10n/gen/app_l10n.dart';
import '../../../../home/domain/entities/home_device_entity.dart';
import '../../../../home/presentation/bloc/home_management_bloc.dart';
import '../../../domain/entities/automation_condition_entity.dart';
import '../../../domain/entities/data_point_entity.dart';
import '../../../domain/usecases/get_device_data_points.dart';
import 'device_condition_rules.dart';

/// Chọn thiết bị → chức năng (DP) → toán tử + giá trị, dựng thành một
/// [DeviceStatusConditionEntity] trả về qua `Navigator.pop`.
class DeviceConditionPage extends StatefulWidget {
  /// Điều kiện đang sửa; bỏ trống là tạo mới.
  final DeviceStatusConditionEntity? existing;

  const DeviceConditionPage({super.key, this.existing});

  @override
  State<DeviceConditionPage> createState() => _DeviceConditionPageState();
}

class _DeviceConditionPageState extends State<DeviceConditionPage> {
  HomeDeviceEntity? _device;
  List<DataPointEntity>? _dataPoints;
  DataPointEntity? _dp;
  String _operator = '==';
  Object? _value;

  bool _loading = false;
  String? _error;

  final TextEditingController _textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final existing = widget.existing;
    if (existing != null) {
      _operator = existing.operator;
      _value = existing.value;
      _textController.text = '${existing.value}';
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  List<HomeDeviceEntity> get _devices => context
      .read<HomeManagementBloc>()
      .state
      .devices
      // Không có deviceProfileId thì không tra được danh sách DP.
      .where((d) => (d.deviceProfileId ?? '').isNotEmpty)
      .toList();

  Future<void> _selectDevice(HomeDeviceEntity device) async {
    setState(() {
      _device = device;
      _dataPoints = null;
      _dp = null;
      _value = null;
      _loading = true;
      _error = null;
    });
    final result =
        await GetIt.instance<GetDeviceDataPoints>()(device.deviceProfileId!);
    if (!mounted) return;
    result.fold(
      (failure) => setState(() {
        _error = failure.message;
        _loading = false;
      }),
      (dataPoints) => setState(() {
        _dataPoints = conditionDataPoints(dataPoints);
        _loading = false;
      }),
    );
  }

  void _selectDataPoint(DataPointEntity dp) {
    setState(() {
      _dp = dp;
      _operator = defaultOperatorFor(dp.dpType);
      // Giá trị của DP trước không còn nghĩa với DP mới.
      _value = dp.dpType == 'BOOLEAN' ? true : null;
      _textController.clear();
    });
  }

  bool get _canSave => _device != null && _dp != null && _value != null;

  void _save() {
    if (!_canSave) return;
    Navigator.pop(
      context,
      DeviceStatusConditionEntity(
        entityId: _device!.deviceId,
        dpCode: _dp!.code,
        operator: _operator,
        value: _value!,
        valueType: valueTypeFor(_dp!.dpType),
        dpName: _dp!.name,
      ),
    );
  }

  String _operatorLabel(String op, AppL10n l10n) => switch (op) {
        '==' => l10n.equals,
        '!=' => l10n.notEquals,
        '>' => l10n.greaterThan,
        '>=' => l10n.greaterOrEqual,
        '<' => l10n.lessThan,
        _ => l10n.lessOrEqual,
      };

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    return Scaffold(
      backgroundColor: context.surfaces.pageBg,
      appBar: AppBar(
        title: Text(
          l10n.condition,
          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        backgroundColor: context.surfaces.sheet,
        foregroundColor: context.surfaces.textPrimary,
        elevation: 0.5,
        actions: [
          TextButton(
            onPressed: _canSave ? _save : null,
            child: Text(
              l10n.save,
              style: TextStyle(
                color: _canSave
                    ? context.surfaces.navActive
                    : context.surfaces.textMuted,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 12),
        children: [
          _SectionLabel(l10n.selectDevice),
          ..._devices.map(
            (d) => _PickerRow(
              label: d.displayName,
              selected: _device?.deviceId == d.deviceId,
              onTap: () => _selectDevice(d),
            ),
          ),
          if (_loading)
            const Padding(
              padding: EdgeInsets.all(24),
              child: Center(child: CircularProgressIndicator()),
            ),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(_error!,
                  style: const TextStyle(color: Colors.red, fontSize: 13)),
            ),
          if (_dataPoints != null) ...[
            const SizedBox(height: 8),
            _SectionLabel(l10n.selectFunction),
            if (_dataPoints!.isEmpty)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  l10n.noReadableDataPoints,
                  style: TextStyle(
                      fontSize: 13, color: context.surfaces.textSecondary),
                ),
              ),
            ..._dataPoints!.map(
              (dp) => _PickerRow(
                label: dp.name,
                selected: _dp?.dpId == dp.dpId,
                onTap: () => _selectDataPoint(dp),
              ),
            ),
          ],
          if (_dp != null) ...[
            const SizedBox(height: 8),
            _SectionLabel(l10n.condition),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: context.surfaces.card,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  if (operatorsFor(_dp!.dpType).length > 1)
                    Row(
                      children: [
                        Expanded(
                          child: Text(l10n.condition,
                              style: TextStyle(
                                  fontSize: 15,
                                  color: context.surfaces.textPrimary)),
                        ),
                        DropdownButton<String>(
                          value: _operator,
                          underline: const SizedBox.shrink(),
                          dropdownColor: context.surfaces.sheet,
                          items: operatorsFor(_dp!.dpType)
                              .map((op) => DropdownMenuItem(
                                    value: op,
                                    child: Text(_operatorLabel(op, l10n)),
                                  ))
                              .toList(),
                          onChanged: (v) =>
                              setState(() => _operator = v ?? '=='),
                        ),
                      ],
                    ),
                  _valueEditor(_dp!, l10n),
                ],
              ),
            ),
          ],
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _valueEditor(DataPointEntity dp, AppL10n l10n) {
    final labelStyle =
        TextStyle(fontSize: 15, color: context.surfaces.textPrimary);
    switch (dp.dpType) {
      case 'ENUM':
        return Row(
          children: [
            Expanded(child: Text(dp.name, style: labelStyle)),
            DropdownButton<String>(
              value: _value as String?,
              hint: Text(l10n.selectFunction),
              underline: const SizedBox.shrink(),
              dropdownColor: context.surfaces.sheet,
              items: dp.enumOptions
                  .map((o) => DropdownMenuItem(value: o, child: Text(o)))
                  .toList(),
              onChanged: (v) => setState(() => _value = v),
            ),
          ],
        );
      case 'BOOLEAN':
        return Row(
          children: [
            Expanded(
              child: Text(_value == true ? l10n.on : l10n.off,
                  style: labelStyle),
            ),
            Switch(
              value: _value == true,
              onChanged: (v) => setState(() => _value = v),
            ),
          ],
        );
      case 'VALUE':
        return Row(
          children: [
            Expanded(child: Text(dp.name, style: labelStyle)),
            SizedBox(
              width: 120,
              child: TextField(
                controller: _textController,
                textAlign: TextAlign.end,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(border: InputBorder.none),
                style: labelStyle,
                onChanged: (t) => setState(() => _value = num.tryParse(t)),
              ),
            ),
          ],
        );
      default:
        return Row(
          children: [
            Expanded(child: Text(dp.name, style: labelStyle)),
            SizedBox(
              width: 160,
              child: TextField(
                controller: _textController,
                textAlign: TextAlign.end,
                decoration: const InputDecoration(border: InputBorder.none),
                style: labelStyle,
                onChanged: (t) =>
                    setState(() => _value = t.isEmpty ? null : t),
              ),
            ),
          ],
        );
    }
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: context.surfaces.textSecondary,
          ),
        ),
      );
}

class _PickerRow extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _PickerRow({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 3),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: context.surfaces.card,
          borderRadius: BorderRadius.circular(12),
          border: selected
              ? Border.all(color: context.surfaces.navActive, width: 1.6)
              : null,
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                    fontSize: 15, color: context.surfaces.textPrimary),
              ),
            ),
            if (selected)
              Icon(Icons.check, size: 20, color: context.surfaces.navActive),
          ],
        ),
      ),
    );
  }
}
