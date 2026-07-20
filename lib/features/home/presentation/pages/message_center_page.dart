import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../../../../core/notifications/message_center.dart';
import '../../../../core/theme/app_colors.dart';

/// Tuya-style in-app notification feed: events grouped by day, card per event
/// with an icon tile, bold title, "HH:mm:ss | message" body, home footer and
/// an unread dot. Entries come from [MessageCenter] (local, no backend).
class MessageCenterPage extends StatefulWidget {
  const MessageCenterPage({super.key});

  @override
  State<MessageCenterPage> createState() => _MessageCenterPageState();
}

class _MessageCenterPageState extends State<MessageCenterPage> {
  final MessageCenter _center = GetIt.instance<MessageCenter>();

  static const _months = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December',
  ];

  @override
  void initState() {
    super.initState();
    _center.ensureLoaded();
  }

  @override
  void dispose() {
    // Leaving the screen counts as having seen everything.
    _center.markAllRead();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F7),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF2F4F7),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios,
              size: 20, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: const Text(
          'Message Center',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Mark all as read',
            icon: const Icon(Icons.checklist_rtl,
                size: 22, color: Colors.black87),
            onPressed: _center.markAllRead,
          ),
        ],
      ),
      body: AnimatedBuilder(
        animation: _center,
        builder: (context, _) {
          final messages = _center.messages;
          if (messages.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.notifications_none_rounded,
                      size: 56, color: Colors.grey.shade400),
                  const SizedBox(height: 14),
                  Text(
                    'No notifications yet',
                    style:
                        TextStyle(fontSize: 15, color: Colors.grey.shade600),
                  ),
                ],
              ),
            );
          }

          // Group by calendar day, newest first (list is already newest-first).
          final children = <Widget>[const SizedBox(height: 4)];
          DateTime? currentDay;
          for (final m in messages) {
            final day = DateTime(m.time.year, m.time.month, m.time.day);
            if (day != currentDay) {
              currentDay = day;
              children.add(_DayHeader(
                day: m.time.day,
                month: _months[m.time.month - 1],
              ));
            }
            children.add(_MessageCard(message: m));
          }
          children.add(const SizedBox(height: 40));

          return ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: children,
          );
        },
      ),
    );
  }
}

class _DayHeader extends StatelessWidget {
  final int day;
  final String month;

  const _DayHeader({required this.day, required this.month});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 18, 4, 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: [
          Text(
            day.toString().padLeft(2, '0'),
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            month,
            style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }
}

class _MessageCard extends StatelessWidget {
  final AppMessage message;

  const _MessageCard({required this.message});

  String get _time {
    final t = message.time;
    String p(int v) => v.toString().padLeft(2, '0');
    return '${p(t.hour)}:${p(t.minute)}:${p(t.second)}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _TypeTile(type: message.type),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  message.title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$_time | ${message.body}',
                  style: TextStyle(
                    fontSize: 13.5,
                    height: 1.35,
                    color: Colors.grey.shade800,
                  ),
                ),
                if (message.homeName != null &&
                    message.homeName!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.home_outlined,
                          size: 15, color: Colors.grey.shade500),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          message.homeName!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              fontSize: 12.5, color: Colors.grey.shade500),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          if (!message.read)
            Container(
              width: 8,
              height: 8,
              margin: const EdgeInsets.only(left: 6, top: 2),
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
            ),
        ],
      ),
    );
  }
}

class _TypeTile extends StatelessWidget {
  final AppMessageType type;

  const _TypeTile({required this.type});

  @override
  Widget build(BuildContext context) {
    switch (type) {
      case AppMessageType.deviceOffline:
        return Container(
          width: 44,
          height: 44,
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Image.asset(
            'assets/icons/curtain_track.png',
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) => Icon(Icons.curtains_outlined,
                size: 22, color: AppColors.primary),
          ),
        );
      case AppMessageType.scene:
        return Container(
          width: 44,
          height: 44,
          decoration: const BoxDecoration(
            color: Color(0xFFFFB300),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.campaign_rounded,
              size: 24, color: Colors.white),
        );
      case AppMessageType.system:
        return Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: AppColors.primarySubtle,
            shape: BoxShape.circle,
          ),
          child:
              const Icon(Icons.info_outline, size: 22, color: AppColors.primary),
        );
    }
  }
}
