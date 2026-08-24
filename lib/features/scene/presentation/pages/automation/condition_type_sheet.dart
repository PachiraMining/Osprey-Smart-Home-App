import 'package:flutter/material.dart';

import '../../../../../core/theme/app_surfaces.dart';
import '../../../../../l10n/gen/app_l10n.dart';

/// Sheet chọn loại điều kiện khi bấm + trong thẻ If.
/// Trả `'schedule'`, `'device'`, hoặc `null` khi người dùng huỷ.
Future<String?> showConditionTypeSheet(BuildContext context) {
  return showModalBottomSheet<String>(
    context: context,
    backgroundColor: context.surfaces.sheet,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (ctx) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 8),
          ListTile(
            leading: const Icon(Icons.access_time, color: Color(0xFF42A5F5)),
            title: Text(
              AppL10n.of(ctx).schedule,
              style: TextStyle(color: ctx.surfaces.textPrimary),
            ),
            onTap: () => Navigator.pop(ctx, 'schedule'),
          ),
          ListTile(
            leading: const Icon(Icons.lightbulb, color: Color(0xFF2ECC71)),
            title: Text(
              AppL10n.of(ctx).deviceStatus,
              style: TextStyle(color: ctx.surfaces.textPrimary),
            ),
            onTap: () => Navigator.pop(ctx, 'device'),
          ),
          const SizedBox(height: 8),
        ],
      ),
    ),
  );
}
