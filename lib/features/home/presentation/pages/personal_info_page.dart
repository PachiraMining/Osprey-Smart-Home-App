import 'package:flutter/material.dart';
import '../../../../l10n/gen/app_l10n.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:smart_curtain_app/core/auth/token_manager.dart';
import 'package:smart_curtain_app/core/widgets/email_avatar.dart';

import '../../domain/entities/home_entity.dart';
import '../../domain/usecases/get_homes.dart';
import '../../domain/usecases/update_home.dart';
import '../bloc/home_management_bloc.dart';
import '../bloc/home_management_event.dart';
import 'timezone_picker_page.dart';

class PersonalInfoPage extends StatefulWidget {
  const PersonalInfoPage({super.key});

  @override
  State<PersonalInfoPage> createState() => _PersonalInfoPageState();
}

class _PersonalInfoPageState extends State<PersonalInfoPage> {
  HomeEntity? _home;
  bool _savingTz = false;

  @override
  void initState() {
    super.initState();
    _loadHome();
  }

  /// Loads the currently-selected home so its timezone can be shown/edited.
  Future<void> _loadHome() async {
    final result = await GetIt.instance<GetHomes>()();
    final homes = result.fold((_) => <HomeEntity>[], (h) => h);
    if (homes.isEmpty || !mounted) return;
    final selectedId = GetIt.instance<TokenManager>().getHomeIdSync();
    // Manual lookup instead of firstWhere(orElse:) — the list is reified as
    // List<HomeModel>, so an orElse closure returning HomeEntity fails the
    // runtime variance check.
    HomeEntity home = homes.first;
    for (final h in homes) {
      if (h.id == selectedId) {
        home = h;
        break;
      }
    }
    setState(() => _home = home);
  }

  String get _timezoneLabel {
    final tz = _home?.timezone;
    if (tz == null || tz.isEmpty) return AppL10n.of(context).notSet;
    return TimezonePickerPage.label(tz);
  }

  Future<void> _editTimezone() async {
    final home = _home;
    if (home == null || _savingTz) return;

    final picked = await Navigator.of(context).push<String>(
      MaterialPageRoute(
        builder: (_) => TimezonePickerPage(current: home.timezone),
      ),
    );
    if (picked == null || picked == home.timezone || !mounted) return;

    setState(() => _savingTz = true);
    final result = await GetIt.instance<UpdateHome>()(
      homeId: home.id,
      name: home.name,
      geoName: home.geoName,
      latitude: home.latitude,
      longitude: home.longitude,
      timezone: picked,
    );
    if (!mounted) return;
    result.fold(
      (failure) {
        setState(() => _savingTz = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(failure.message),
            backgroundColor: Colors.red,
          ),
        );
      },
      (updated) {
        setState(() {
          _home = updated;
          _savingTz = false;
        });
        // Keep the shared HomeManagementBloc's home list authoritative so other
        // screens don't read a stale timezone after this out-of-bloc update.
        context.read<HomeManagementBloc>().add(const LoadHomesEvent());
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppL10n.of(context).timeZoneUpdated)),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final tokenManager = GetIt.instance<TokenManager>();
    final displayName = tokenManager.getDisplayName();

    return Scaffold(
      backgroundColor: const Color(0xFFF8F5F0),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 20, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title:  Text(
          AppL10n.of(context).personalInformation,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
      ),
      body: Column(
        children: [
          // Profile Photo + Nickname section
          Container(
            color: Colors.white,
            child: Column(
              children: [
                // Profile Photo row
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  child: Row(
                    children: [
                       Text(
                        AppL10n.of(context).profilePhoto,
                        style: TextStyle(fontSize: 16, color: Colors.black87),
                      ),
                      const Spacer(),
                      EmailAvatar(
                        email: tokenManager.getEmailSync(),
                        fallback: displayName,
                        size: 44,
                      ),
                      const SizedBox(width: 8),
                      Icon(Icons.chevron_right, color: Colors.grey.shade400, size: 20),
                    ],
                  ),
                ),
                Divider(height: 1, indent: 20, endIndent: 20, color: Colors.grey.shade200),

                // Nickname row
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                  child: Row(
                    children: [
                       Text(
                        AppL10n.of(context).nickname,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        displayName,
                        style: TextStyle(fontSize: 15, color: Colors.grey.shade500),
                      ),
                      const SizedBox(width: 8),
                      Icon(Icons.chevron_right, color: Colors.grey.shade400, size: 20),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Time Zone section — controls the current Home's scene scheduler.
          Container(
            color: Colors.white,
            child: InkWell(
              onTap: _home == null ? null : _editTimezone,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                child: Row(
                  children: [
                    Text(
                      AppL10n.of(context).timeZone,
                      style: TextStyle(fontSize: 16, color: Colors.black87),
                    ),
                    const Spacer(),
                    if (_savingTz)
                      const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    else
                      Text(
                        _timezoneLabel,
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    const SizedBox(width: 8),
                    Icon(Icons.chevron_right,
                        color: Colors.grey.shade400, size: 20),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
