import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:smart_curtain_app/features/scene/domain/entities/data_point_entity.dart';
import 'package:smart_curtain_app/features/scene/domain/entities/scene_action_entity.dart';
import 'package:smart_curtain_app/features/scene/domain/usecases/get_device_data_points.dart';

class SelectDeviceFunctionPage extends StatefulWidget {
  final String deviceId;
  final String deviceName;
  final String deviceProfileId;

  const SelectDeviceFunctionPage({
    super.key,
    required this.deviceId,
    required this.deviceName,
    required this.deviceProfileId,
  });

  @override
  State<SelectDeviceFunctionPage> createState() =>
      _SelectDeviceFunctionPageState();
}

class _SelectDeviceFunctionPageState extends State<SelectDeviceFunctionPage> {
  List<DataPointEntity>? _dataPoints;
  String? _error;
  bool _loading = true;

  // Stores selected value per dpId — null means not yet chosen
  final Map<int, dynamic> _selectedValues = {};

  @override
  void initState() {
    super.initState();
    _loadDataPoints();
  }

  Future<void> _loadDataPoints() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    final useCase = GetIt.instance<GetDeviceDataPoints>();
    final result = await useCase(widget.deviceProfileId);
    if (!mounted) return;
    result.fold(
      (failure) => setState(() {
        _error = failure.message;
        _loading = false;
      }),
      (dataPoints) {
        final writable = dataPoints.where((dp) => dp.isWritable).toList();
        setState(() {
          _dataPoints = writable;
          _loading = false;
        });
      },
    );
  }

  void _onNext() {
    // Find the last selected function and return it
    if (_selectedValues.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a function')),
      );
      return;
    }
    // Use the most recently selected entry
    final lastEntry = _selectedValues.entries.last;
    final dp =
        _dataPoints!.firstWhere((d) => d.dpId == lastEntry.key);
    Navigator.pop(
      context,
      SceneActionEntity(
        actionType: 'DEVICE_CONTROL',
        entityId: widget.deviceId,
        executorProperty: {'dpId': dp.dpId, 'dpValue': lastEntry.value},
        deviceName: widget.deviceName,
        functionName: dp.name,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        title: const Text(
          'Select Function',
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0.5,
        actions: [
          TextButton(
            onPressed: _selectedValues.isNotEmpty ? _onNext : null,
            child: Text(
              'Next',
              style: TextStyle(
                color: _selectedValues.isNotEmpty
                    ? const Color(0xFF2196F3)
                    : Colors.grey,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(_error!, style: const TextStyle(color: Colors.red)),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadDataPoints,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : _dataPoints == null || _dataPoints!.isEmpty
                  ? const Center(child: Text('No functions available'))
                  : ListView.separated(
                      itemCount: _dataPoints!.length,
                      separatorBuilder: (_, __) => Divider(
                        height: 1,
                        indent: 16,
                        color: Colors.grey.shade200,
                      ),
                      itemBuilder: (context, index) {
                        final dp = _dataPoints![index];
                        return _FunctionRow(
                          dp: dp,
                          selectedValue: _selectedValues[dp.dpId],
                          onTap: () => _showValuePicker(dp),
                        );
                      },
                    ),
    );
  }

  Future<void> _showValuePicker(DataPointEntity dp) async {
    dynamic result;
    switch (dp.dpType) {
      case 'BOOLEAN':
        result = await _showBooleanPicker(dp);
      case 'ENUM':
        result = await _showEnumPicker(dp);
      case 'VALUE':
        result = await _showValueSliderPicker(dp);
      case 'STRING':
        result = await _showStringPicker(dp);
      default:
        return;
    }
    if (result != null && mounted) {
      setState(() => _selectedValues[dp.dpId] = result);
    }
  }

  // ---------------------------------------------------------------------------
  // BOOLEAN picker — bottom sheet with On/Off radio options
  // ---------------------------------------------------------------------------
  Future<dynamic> _showBooleanPicker(DataPointEntity dp) {
    return showModalBottomSheet<dynamic>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        bool? selected;
        return SafeArea(
          child: StatefulBuilder(
          builder: (ctx, setLocal) => Container(
            margin: const EdgeInsets.fromLTRB(12, 12, 12, 0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Text(
                    dp.name,
                    style: TextStyle(fontSize: 15, color: Colors.grey.shade500),
                  ),
                ),
                _radioRow('On', true, selected, (v) => setLocal(() => selected = v)),
                Divider(height: 1, color: Colors.grey.shade200),
                _radioRow('Off', false, selected, (v) => setLocal(() => selected = v)),
                const SizedBox(height: 16),
                _bottomButtons(ctx, () => selected),
              ],
            ),
          ),
        ),
        );
      },
    );
  }

  // ---------------------------------------------------------------------------
  // ENUM picker — bottom sheet with radio options for each enum value
  // ---------------------------------------------------------------------------
  Future<dynamic> _showEnumPicker(DataPointEntity dp) {
    final options = dp.enumOptions;
    return showModalBottomSheet<dynamic>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        String? selected;
        return SafeArea(
          child: StatefulBuilder(
          builder: (ctx, setLocal) => Container(
            margin: const EdgeInsets.fromLTRB(12, 12, 12, 0),
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(ctx).size.height * 0.6,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Text(
                    dp.name,
                    style: TextStyle(fontSize: 15, color: Colors.grey.shade500),
                  ),
                ),
                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: options.length,
                    separatorBuilder: (_, __) =>
                        Divider(height: 1, color: Colors.grey.shade200),
                    itemBuilder: (_, i) => _radioRow(
                      options[i],
                      options[i],
                      selected,
                      (v) => setLocal(() => selected = v),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                _bottomButtons(ctx, () => selected),
              ],
            ),
          ),
        ),
        );
      },
    );
  }

  // ---------------------------------------------------------------------------
  // VALUE picker — bottom sheet with ◄ value ► and slider
  // ---------------------------------------------------------------------------
  Future<dynamic> _showValueSliderPicker(DataPointEntity dp) {
    final min = (dp.constraints['min'] as num?)?.toDouble() ?? 0;
    final max = (dp.constraints['max'] as num?)?.toDouble() ?? 100;
    final step = (dp.constraints['step'] as num?)?.toDouble() ?? 1;
    final unit = dp.constraints['unit'] as String? ?? '';

    return showModalBottomSheet<dynamic>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        double current = min;
        return SafeArea(
          child: StatefulBuilder(
          builder: (ctx, setLocal) => Container(
            margin: const EdgeInsets.fromLTRB(12, 12, 12, 0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Text(
                    dp.name,
                    style: TextStyle(fontSize: 15, color: Colors.grey.shade500),
                  ),
                ),
                const SizedBox(height: 16),
                // ◄ value ► display
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      onPressed: current > min
                          ? () => setLocal(() => current = (current - step).clamp(min, max))
                          : null,
                      icon: Icon(Icons.arrow_left, color: Colors.grey.shade600),
                    ),
                    Text(
                      '${current.toStringAsFixed(step < 1 ? 1 : 0)}$unit',
                      style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w500),
                    ),
                    IconButton(
                      onPressed: current < max
                          ? () => setLocal(() => current = (current + step).clamp(min, max))
                          : null,
                      icon: Icon(Icons.arrow_right, color: Colors.grey.shade600),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // Slider
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: SliderTheme(
                    data: SliderThemeData(
                      trackHeight: 24,
                      thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12),
                      activeTrackColor: const Color(0xFFD6EAF8),
                      inactiveTrackColor: Colors.grey.shade200,
                      thumbColor: Colors.white,
                      overlayShape: SliderComponentShape.noOverlay,
                    ),
                    child: Slider(
                      value: current,
                      min: min,
                      max: max,
                      divisions: ((max - min) / step).round(),
                      onChanged: (v) => setLocal(() => current = v),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                _bottomButtons(ctx, () => step < 1 ? current : current.toInt()),
              ],
            ),
          ),
        ),
        );
      },
    );
  }

  // ---------------------------------------------------------------------------
  // STRING picker — bottom sheet with text input
  // ---------------------------------------------------------------------------
  Future<dynamic> _showStringPicker(DataPointEntity dp) {
    final controller = TextEditingController();
    final maxLen = dp.constraints['maxlen'] as int?;
    return showModalBottomSheet<dynamic>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => SafeArea(
        child: Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: Container(
          margin: const EdgeInsets.fromLTRB(12, 12, 12, 0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Text(
                  dp.name,
                  style: TextStyle(fontSize: 15, color: Colors.grey.shade500),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: TextField(
                  controller: controller,
                  maxLength: maxLen,
                  autofocus: true,
                  decoration: InputDecoration(
                    hintText: 'Enter value...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              _bottomButtons(ctx, () {
                final text = controller.text.trim();
                return text.isNotEmpty ? text : null;
              }),
            ],
          ),
        ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Shared widgets
  // ---------------------------------------------------------------------------

  Widget _radioRow<T>(String label, T value, T? groupValue, ValueChanged<T> onChanged) {
    return InkWell(
      onTap: () => onChanged(value),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Row(
          children: [
            Text(label, style: const TextStyle(fontSize: 16)),
            const Spacer(),
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: groupValue == value
                      ? const Color(0xFF2196F3)
                      : Colors.grey.shade300,
                  width: 2,
                ),
              ),
              child: groupValue == value
                  ? Center(
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xFF2196F3),
                        ),
                      ),
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _bottomButtons(BuildContext ctx, dynamic Function() getValue) {
    return Container(
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text(
                'Cancel',
                style: TextStyle(fontSize: 16, color: Colors.black54),
              ),
            ),
          ),
          Container(width: 1, height: 48, color: Colors.grey.shade200),
          Expanded(
            child: TextButton(
              onPressed: () {
                final val = getValue();
                if (val != null) Navigator.pop(ctx, val);
              },
              child: const Text(
                'Save',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Function row in the list
// ---------------------------------------------------------------------------
class _FunctionRow extends StatelessWidget {
  final DataPointEntity dp;
  final dynamic selectedValue;
  final VoidCallback onTap;

  const _FunctionRow({
    required this.dp,
    this.selectedValue,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  dp.name,
                  style: const TextStyle(fontSize: 16, color: Colors.black87),
                ),
              ),
              if (selectedValue != null)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Text(
                    '$selectedValue',
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
                  ),
                ),
              Icon(Icons.chevron_right, color: Colors.grey.shade400),
            ],
          ),
        ),
      ),
    );
  }
}
