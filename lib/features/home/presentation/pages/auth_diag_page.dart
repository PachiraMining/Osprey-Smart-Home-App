import 'package:flutter/material.dart';
import '../../../../l10n/gen/app_l10n.dart';
import 'package:flutter/services.dart';

import '../../../../core/auth/auth_diag_log.dart';

/// Read-only viewer for the persistent auth event log. This is the evidence
/// trail for the "logged out for no reason" bug: open it after logging back in
/// and read the newest entries — the LOGOUT line and the REFRESH line just
/// before it say exactly what happened and when.
class AuthDiagPage extends StatefulWidget {
  const AuthDiagPage({super.key});

  @override
  State<AuthDiagPage> createState() => _AuthDiagPageState();
}

class _AuthDiagPageState extends State<AuthDiagPage> {
  late Future<List<AuthDiagEntry>> _future;

  @override
  void initState() {
    super.initState();
    _future = AuthDiagLog.instance.entries();
  }

  void _reload() =>
      setState(() => _future = AuthDiagLog.instance.entries());

  Future<void> _copy() async {
    final text = await AuthDiagLog.instance.asText();
    await Clipboard.setData(ClipboardData(text: text));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppL10n.of(context).logCopiedToClipboard)),
      );
    }
  }

  Color _tagColor(String tag) {
    switch (tag) {
      case 'LOGOUT':
        return const Color(0xFFD64545);
      case 'REFRESH':
        return const Color(0xFF0B5FA8);
      case 'LOGIN':
      case 'RESUME_OK':
        return const Color(0xFF2E8B57);
      case 'NO_SESSION':
        return const Color(0xFFE0922B);
      default:
        return Colors.grey.shade600;
    }
  }

  String _fmt(DateTime t) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${t.year}-${two(t.month)}-${two(t.day)} '
        '${two(t.hour)}:${two(t.minute)}:${two(t.second)}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F7),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios,
              size: 20, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(AppL10n.of(context).authDiagnostics,
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black87)),
        actions: [
          IconButton(
            icon: const Icon(Icons.copy, size: 20, color: Colors.black87),
            tooltip: AppL10n.of(context).copy,
            onPressed: _copy,
          ),
          IconButton(
            icon: const Icon(Icons.refresh, size: 22, color: Colors.black87),
            tooltip: AppL10n.of(context).reload,
            onPressed: _reload,
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline,
                size: 22, color: Colors.black87),
            tooltip: AppL10n.of(context).clear,
            onPressed: () async {
              await AuthDiagLog.instance.clear();
              _reload();
            },
          ),
        ],
      ),
      body: FutureBuilder<List<AuthDiagEntry>>(
        future: _future,
        builder: (context, snap) {
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final items = snap.data!;
          if (items.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Text(
                  'No auth events recorded yet.\n\nUse the app normally; the '
                  'next time the session ends, the reason will appear here — '
                  'newest first.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, i) {
              final e = items[i];
              return Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: _tagColor(e.tag).withAlpha(28),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            e.tag,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: _tagColor(e.tag),
                            ),
                          ),
                        ),
                        const Spacer(),
                        Text(
                          _fmt(e.time),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade500,
                            fontFeatures: const [FontFeature.tabularFigures()],
                          ),
                        ),
                      ],
                    ),
                    if (e.detail != null) ...[
                      const SizedBox(height: 6),
                      Text(
                        e.detail!,
                        style: const TextStyle(
                            fontSize: 13, color: Colors.black87, height: 1.35),
                      ),
                    ],
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
