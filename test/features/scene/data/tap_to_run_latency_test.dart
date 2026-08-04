import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:smart_curtain_app/features/scene/data/datasources/tap_to_run_remote_datasource.dart';
import 'package:smart_curtain_app/features/scene/data/repositories/tap_to_run_repository_impl.dart';

class _MockDataSource extends Mock implements TapToRunRemoteDataSource {}

/// Đo độ trễ của một lượt chạy Tap-to-Run.
///
/// `executeScene` gửi lệnh NGAY (mốc log lấy song song, hoặc lấy từ bộ nhớ ở
/// lần chạm sau), rồi dò log đúng **2 lần** ở mốc 600ms và 1600ms.
///
/// Hai thứ được khoá bằng số liệu ở đây: **độ trễ lúc gửi lệnh** và **số
/// request mỗi lần chạm** — phía server đã phản ánh chuyện gọi quá nhiều API,
/// nên số lần dò là con số cần chặn hồi quy.
///
/// Mọi mốc thời gian đều nới rộng biên để không bị lung lay trên máy CI chậm —
/// cái cần khoá là *bậc độ lớn*, không phải mili-giây chính xác.
void main() {
  late _MockDataSource dataSource;
  late TapToRunRepositoryImpl repository;
  late List<String> callLog;

  setUp(() {
    dataSource = _MockDataSource();
    repository = TapToRunRepositoryImpl(remoteDataSource: dataSource);
    callLog = [];
  });

  /// Giả lập backend: [logAppearsOnCall] là lần gọi getSceneLogs thứ mấy thì
  /// log mới xuất hiện (1 = lần chụp mốc, nên không bao giờ tính là mới).
  void stubBackend({required int logAppearsOnCall}) {
    var logCalls = 0;
    when(() => dataSource.getSceneLogs('s1')).thenAnswer((_) async {
      logCalls++;
      callLog.add('getSceneLogs#$logCalls');
      if (logCalls >= logAppearsOnCall) {
        return [
          {'id': 'log-new', 'status': 'SUCCESS'},
          {'id': 'log-old', 'status': 'SUCCESS'},
        ];
      }
      return [
        {'id': 'log-old', 'status': 'SUCCESS'},
      ];
    });
    when(() => dataSource.executeScene('s1')).thenAnswer((_) async {
      callLog.add('executeScene');
    });
  }

  group('Độ trễ Tap-to-Run', () {
    test('lệnh KHÔNG phải chờ request lấy mốc trả lời', () async {
      // Cho GET /logs trả lời CHẬM 500ms. Nếu POST bị chặn bởi nó thì lệnh chỉ
      // đi sau 500ms — đúng kiểu độ trễ 1-2s người dùng thấy khi mạng chậm.
      final sw = Stopwatch()..start();
      var executeAtMs = -1;

      when(() => dataSource.getSceneLogs('s1')).thenAnswer((_) async {
        await Future<void>.delayed(const Duration(milliseconds: 500));
        return [
          {'id': 'log-old', 'status': 'SUCCESS'},
        ];
      });
      when(() => dataSource.executeScene('s1')).thenAnswer((_) async {
        executeAtMs = sw.elapsedMilliseconds;
      });

      await repository.executeScene('s1');

      // Chốt chặn hồi quy: đưa `await getSceneLogs` trở lại trước POST là con
      // số này nhảy lên ~500 và test đỏ.
      expect(executeAtMs, greaterThanOrEqualTo(0), reason: 'POST phải được gọi');
      expect(executeAtMs, lessThan(100),
          reason: 'POST phải rời máy ngay, không đợi GET mốc trả lời');
    });

    test('lần chạm THỨ HAI không tốn request nào trước khi gửi lệnh', () async {
      stubBackend(logAppearsOnCall: 2);
      await repository.executeScene('s1');
      callLog.clear();

      await repository.executeScene('s1');

      // Mốc đã nằm trong bộ nhớ từ lượt trước → đi thẳng vào POST.
      expect(callLog.first, 'executeScene');
      expect(callLog.where((c) => c.startsWith('getSceneLogs')).length, 2,
          reason: 'chỉ còn 2 lần dò, không có lượt GET lấy mốc');
    });

    test('log có sẵn ở lần dò đầu → xong sau ~600ms', () async {
      stubBackend(logAppearsOnCall: 2);

      final sw = Stopwatch()..start();
      final result = await repository.executeScene('s1');
      sw.stop();

      expect(result.isRight(), true);
      expect(sw.elapsedMilliseconds, greaterThanOrEqualTo(560));
      expect(sw.elapsedMilliseconds, lessThan(1200));
    });

    test('trường hợp CHẬM NHẤT: cửa sổ ~2.2s rồi coi như thành công', () async {
      // Log mới không bao giờ tới trong cả 2 lần dò.
      stubBackend(logAppearsOnCall: 999);

      final sw = Stopwatch()..start();
      final result = await repository.executeScene('s1');
      sw.stop();

      // Vẫn coi là thành công (server đã nhận 200) — chỉ là sau trọn cửa sổ.
      expect(result.isRight(), true);
      result.fold((_) => fail('phải là Right'),
          (data) => expect(data['status'], 'SUCCESS'));

      // 600 + 1600 = 2200ms.
      expect(sw.elapsedMilliseconds, greaterThanOrEqualTo(2100));
      expect(sw.elapsedMilliseconds, lessThan(3600));
    });

    test('SỐ REQUEST: lần chạm đầu tối đa 4, lần chạm sau tối đa 3', () async {
      stubBackend(logAppearsOnCall: 999);

      await repository.executeScene('s1');
      // Lần đầu: 1 lấy mốc (song song) + 1 execute + 2 lần dò.
      expect(callLog.length, 4,
          reason: 'server đã phản ánh gọi quá nhiều API — giữ mức này');

      callLog.clear();
      await repository.executeScene('s1');
      // Lần sau: mốc đã có trong bộ nhớ → 1 execute + 2 lần dò.
      expect(callLog.length, 3);
      expect(callLog.where((c) => c == 'executeScene').length, 1);
    });

    test('log tới ở lần dò thứ hai → ~2.2s', () async {
      // lần 1 = lấy mốc, lần 2 = dò chưa thấy, lần 3 = thấy.
      stubBackend(logAppearsOnCall: 3);

      final sw = Stopwatch()..start();
      await repository.executeScene('s1');
      sw.stop();

      expect(sw.elapsedMilliseconds, greaterThanOrEqualTo(2100));
      expect(sw.elapsedMilliseconds, lessThan(3600));
    });
  });
}
