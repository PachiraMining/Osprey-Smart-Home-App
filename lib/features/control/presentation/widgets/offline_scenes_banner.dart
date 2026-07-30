import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/cloud_health.dart';
import '../bloc/cloud_health_cubit.dart';
import '../../../../l10n/gen/app_l10n.dart';

/// Banner cảnh báo trên màn Smart Scenes khi cloud-down — Smart Scenes
/// (Tap-to-run + schedules) chỉ chạy khi backend online (backend note §2).
///
/// Insert ở đầu danh sách scenes. Trả `SizedBox.shrink()` khi cloud online.
class OfflineScenesBanner extends StatelessWidget {
  const OfflineScenesBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CloudHealthCubit, CloudHealth>(
      builder: (context, health) {
        if (health == CloudHealth.online) return const SizedBox.shrink();
        return Container(
          margin: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFFEF3C7),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFFCD34D)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.cloud_off_outlined,
                  size: 20, color: Color(0xFFB54708)),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children:  [
                    Text(
                      AppL10n.of(context).smartScenesRequireInternet,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFFB54708),
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      AppL10n.of(context).offlineScenesBody,
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF92400E),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
