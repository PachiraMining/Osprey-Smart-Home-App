import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:smart_curtain_app/core/error/exceptions.dart';
import 'package:smart_curtain_app/core/error/failure.dart';
import 'package:smart_curtain_app/features/scene/data/datasources/tap_to_run_remote_datasource.dart';
import 'package:smart_curtain_app/features/scene/data/repositories/tap_to_run_repository_impl.dart';

class _MockDataSource extends Mock implements TapToRunRemoteDataSource {}

void main() {
  late _MockDataSource dataSource;
  late TapToRunRepositoryImpl repository;

  setUp(() {
    dataSource = _MockDataSource();
    repository = TapToRunRepositoryImpl(remoteDataSource: dataSource);
  });

  group('executeScene', () {
    test('200 rỗng + log mới xuất hiện → trả status thật từ log', () async {
      // Backend: execute trả 200 body rỗng, kết quả ghi vào /logs.
      when(() => dataSource.getSceneLogs('s1')).thenAnswer((_) async => [
            {
              'id': 'log-new',
              'status': 'FAILURE',
              'executionDetails': {'details': 'Device not found: x'},
            },
            {'id': 'log-old', 'status': 'SUCCESS'},
          ]);
      when(() => dataSource.executeScene('s1')).thenAnswer((_) async {});

      // Lượt gọi logs đầu (snapshot trước execute) trả log-old là mới nhất.
      var calls = 0;
      when(() => dataSource.getSceneLogs('s1')).thenAnswer((_) async {
        calls++;
        if (calls == 1) {
          return [
            {'id': 'log-old', 'status': 'SUCCESS'},
          ];
        }
        return [
          {
            'id': 'log-new',
            'status': 'FAILURE',
            'executionDetails': {'details': 'Device not found: x'},
          },
          {'id': 'log-old', 'status': 'SUCCESS'},
        ];
      });

      final result = await repository.executeScene('s1');

      expect(result.isRight(), true);
      result.fold((_) => fail('expected Right'), (data) {
        expect(data['status'], 'FAILURE');
        expect(
          (data['executionDetails'] as Map)['details'],
          contains('Device not found'),
        );
      });
      verify(() => dataSource.executeScene('s1')).called(1);
    });

    test('200 rỗng nhưng log chưa kịp ghi → coi là SUCCESS (không báo lỗi sai)',
        () async {
      when(() => dataSource.getSceneLogs('s1')).thenAnswer((_) async => [
            {'id': 'log-old', 'status': 'SUCCESS'},
          ]);
      when(() => dataSource.executeScene('s1')).thenAnswer((_) async {});

      final result = await repository.executeScene('s1');

      expect(result.isRight(), true);
      result.fold(
        (_) => fail('expected Right'),
        (data) => expect(data['status'], 'SUCCESS'),
      );
    });

    test('400 Scene is disabled → SceneDisabledFailure (để bloc enable+retry)',
        () async {
      when(() => dataSource.getSceneLogs('s1')).thenAnswer((_) async => []);
      when(() => dataSource.executeScene('s1'))
          .thenThrow(SceneDisabledException(message: 'Scene is disabled'));

      final result = await repository.executeScene('s1');

      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure, isA<SceneDisabledFailure>()),
        (_) => fail('expected Left'),
      );
    });
  });
}
