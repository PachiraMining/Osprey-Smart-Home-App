import 'package:flutter_test/flutter_test.dart';
import 'package:smart_curtain_app/features/scene/data/models/effective_time_model.dart';

void main() {
  test('ALL_DAY chỉ gửi type', () {
    const m = EffectiveTimeModel(type: 'ALL_DAY');
    expect(m.toJson(), {'type': 'ALL_DAY'});
  });

  test('CUSTOM gửi start/end/loops, KHÔNG gửi timeZoneId khi để trống', () {
    const m = EffectiveTimeModel(
      type: 'CUSTOM',
      startTime: '18:00',
      endTime: '06:00',
      loops: '1111100',
    );
    final j = m.toJson();
    expect(j['type'], 'CUSTOM');
    expect(j['start'], '18:00');
    expect(j['end'], '06:00');
    expect(j['loops'], '1111100');
    // Bỏ trống để backend lấy timezone của home — ghi cứng ở đây sẽ thắng
    // home.timezone và gây bug automation không nổ.
    expect(j.containsKey('timeZoneId'), isFalse);
  });

  test('round-trip giữ nguyên khung qua đêm', () {
    const m = EffectiveTimeModel(
      type: 'CUSTOM',
      startTime: '22:00',
      endTime: '05:00',
      loops: '1111111',
    );
    final back = EffectiveTimeModel.fromJson(m.toJson());
    expect(back.startTime, '22:00');
    expect(back.endTime, '05:00');
    expect(back.loops, '1111111');
  });

  test('fromJson đọc khoá start/end chứ không phải startTime/endTime', () {
    final m = EffectiveTimeModel.fromJson({
      'type': 'CUSTOM',
      'start': '07:30',
      'end': '19:45',
      'loops': '0111110',
    });
    expect(m.startTime, '07:30');
    expect(m.endTime, '19:45');
    expect(m.isAllDay, isFalse);
  });
}
