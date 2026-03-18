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
  State<SelectDeviceFunctionPage> createState() => _SelectDeviceFunctionPageState();
}

class _SelectDeviceFunctionPageState extends State<SelectDeviceFunctionPage> {
  List<DataPointEntity>? _dataPoints;
  String? _error;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadDataPoints();
  }

  Future<void> _loadDataPoints() async {
    setState(() { _loading = true; _error = null; });
    final useCase = GetIt.instance<GetDeviceDataPoints>();
    final result = await useCase(widget.deviceProfileId);
    if (!mounted) return;
    result.fold(
      (failure) => setState(() { _error = failure.message; _loading = false; }),
      (dataPoints) {
        final writable = dataPoints.where((dp) => dp.isWritable).toList();
        setState(() { _dataPoints = writable; _loading = false; });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: Text(widget.deviceName),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0.5,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(_error!, style: const TextStyle(color: Colors.red)),
                    const SizedBox(height: 16),
                    ElevatedButton(onPressed: _loadDataPoints, child: const Text('Thử lại')),
                  ],
                ))
              : _dataPoints == null || _dataPoints!.isEmpty
                  ? const Center(child: Text('Không có chức năng nào'))
                  : ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: _dataPoints!.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (context, index) => _buildDataPointCard(_dataPoints![index]),
                    ),
    );
  }

  Widget _buildDataPointCard(DataPointEntity dp) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(dp.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Text('${dp.dpType} • dpId: ${dp.dpId}', style: TextStyle(fontSize: 12, color: Colors.grey[500])),
          const SizedBox(height: 12),
          _buildValueSelector(dp),
        ],
      ),
    );
  }

  Widget _buildValueSelector(DataPointEntity dp) {
    switch (dp.dpType) {
      case 'BOOLEAN': return _buildBooleanSelector(dp);
      case 'ENUM': return _buildEnumSelector(dp);
      case 'VALUE': return _buildValueSlider(dp);
      case 'STRING': return _buildStringInput(dp);
      default: return Text('Unsupported type: ${dp.dpType}');
    }
  }

  Widget _buildBooleanSelector(DataPointEntity dp) {
    return Row(
      children: [
        Expanded(child: ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
          onPressed: () => _returnAction(dp, true),
          child: const Text('ON'),
        )),
        const SizedBox(width: 12),
        Expanded(child: ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
          onPressed: () => _returnAction(dp, false),
          child: const Text('OFF'),
        )),
      ],
    );
  }

  Widget _buildEnumSelector(DataPointEntity dp) {
    final options = dp.enumOptions;
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: options.map((option) => ElevatedButton(
        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2196F3), foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
        onPressed: () => _returnAction(dp, option),
        child: Text(option),
      )).toList(),
    );
  }

  Widget _buildValueSlider(DataPointEntity dp) {
    final min = (dp.constraints['min'] as num?)?.toDouble() ?? 0;
    final max = (dp.constraints['max'] as num?)?.toDouble() ?? 100;
    final step = (dp.constraints['step'] as num?)?.toDouble() ?? 1;
    double currentValue = min;

    return StatefulBuilder(
      builder: (context, setLocalState) => Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('${min.toInt()}'),
              Text('${currentValue.toInt()}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF2196F3))),
              Text('${max.toInt()}'),
            ],
          ),
          Slider(
            value: currentValue,
            min: min,
            max: max,
            divisions: ((max - min) / step).round(),
            onChanged: (v) => setLocalState(() => currentValue = v),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2196F3),
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 44),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () => _returnAction(dp, currentValue.toInt()),
            child: Text('Đặt ${currentValue.toInt()}'),
          ),
        ],
      ),
    );
  }

  Widget _buildStringInput(DataPointEntity dp) {
    final controller = TextEditingController();
    final maxLen = dp.constraints['maxlen'] as int?;
    return Row(
      children: [
        Expanded(child: TextField(
          controller: controller,
          maxLength: maxLen,
          decoration: InputDecoration(hintText: 'Nhập giá trị...', border: OutlineInputBorder(borderRadius: BorderRadius.circular(8))),
        )),
        const SizedBox(width: 8),
        ElevatedButton(onPressed: () { if (controller.text.isNotEmpty) _returnAction(dp, controller.text); }, child: const Text('OK')),
      ],
    );
  }

  void _returnAction(DataPointEntity dp, dynamic value) {
    Navigator.pop(context, SceneActionEntity(
      actionType: 'DEVICE_CONTROL',
      entityId: widget.deviceId,
      executorProperty: {'dpId': dp.dpId, 'dpValue': value},
      deviceName: widget.deviceName,
      functionName: dp.name,
    ));
  }
}
