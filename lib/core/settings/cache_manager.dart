import 'dart:developer' as dev;
import 'dart:io';

import 'package:flutter/painting.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:path_provider/path_provider.dart';

/// Đo và xoá cache của app.
///
/// Chỉ tính những thứ TÁI TẠO ĐƯỢC: hộp hydrated_bloc (bản chụp scene/home để
/// mở app hiện ngay) và thư mục cache tạm. KHÔNG chạm vào secure storage
/// (token) hay database ghi nhận thói quen dùng.
class CacheManager {
  const CacheManager();

  Future<int> sizeInBytes() async {
    var total = 0;
    for (final dir in await _cacheDirs()) {
      total += await _dirSize(dir);
    }
    total += await _hydratedBoxSize();
    return total;
  }

  /// Xoá cache; trả về số byte đã giải phóng.
  Future<int> clear() async {
    final before = await sizeInBytes();

    // Bản chụp bloc — mất đi thì app chỉ tải lại từ server ở lần mở kế tiếp.
    try {
      await HydratedBloc.storage.clear();
    } catch (e) {
      dev.log('clear hydrated storage failed: $e', name: 'cache');
    }

    for (final dir in await _cacheDirs()) {
      try {
        if (dir.existsSync()) {
          for (final entity in dir.listSync()) {
            try {
              entity.deleteSync(recursive: true);
            } catch (_) {
              // File đang mở → bỏ qua, lần sau xoá.
            }
          }
        }
      } catch (e) {
        dev.log('clear dir failed: $e', name: 'cache');
      }
    }

    PaintingBinding.instance.imageCache
      ..clear()
      ..clearLiveImages();

    final after = await sizeInBytes();
    return (before - after).clamp(0, before);
  }

  Future<List<Directory>> _cacheDirs() async {
    final dirs = <Directory>[];
    try {
      dirs.add(await getTemporaryDirectory());
    } catch (_) {}
    try {
      final support = await getApplicationCacheDirectory();
      dirs.add(support);
    } catch (_) {}
    return dirs;
  }

  Future<int> _hydratedBoxSize() async {
    try {
      final docs = await getApplicationDocumentsDirectory();
      final box = File('${docs.path}/hydrated_box.hive');
      return box.existsSync() ? box.lengthSync() : 0;
    } catch (_) {
      return 0;
    }
  }

  Future<int> _dirSize(Directory dir) async {
    if (!dir.existsSync()) return 0;
    var total = 0;
    try {
      for (final entity in dir.listSync(recursive: true, followLinks: false)) {
        if (entity is File) {
          try {
            total += entity.lengthSync();
          } catch (_) {}
        }
      }
    } catch (_) {}
    return total;
  }

  /// "26.75M" / "812K" — cùng cách hiển thị như app tham chiếu.
  static String formatBytes(int bytes) {
    if (bytes >= 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(2)}M';
    }
    if (bytes >= 1024) return '${(bytes / 1024).round()}K';
    return '${bytes}B';
  }
}
