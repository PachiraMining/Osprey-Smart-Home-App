import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../../../l10n/gen/app_l10n.dart';

/// In-app storefront: renders the Osprey shop website in a WebView.
class AppMallPage extends StatefulWidget {
  const AppMallPage({super.key});

  static const String _storeUrl = 'https://osprey.life/';

  @override
  State<AppMallPage> createState() => _AppMallPageState();
}

class _AppMallPageState extends State<AppMallPage> {
  late final WebViewController _controller;
  int _progress = 0;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.white)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (p) {
            if (mounted) setState(() => _progress = p);
          },
        ),
      )
      ..loadRequest(Uri.parse(AppMallPage._storeUrl));
  }

  Future<void> _goBack() async {
    if (await _controller.canGoBack()) {
      await _controller.goBack();
    } else if (mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios,
              size: 20, color: Colors.black87),
          onPressed: _goBack,
        ),
        centerTitle: true,
        title:  Text(
          AppL10n.of(context).appMall,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, size: 22, color: Colors.black87),
            onPressed: _controller.reload,
          ),
        ],
        bottom: _progress < 100
            ? PreferredSize(
                preferredSize: const Size.fromHeight(2),
                child: LinearProgressIndicator(
                  value: _progress / 100,
                  minHeight: 2,
                  backgroundColor: Colors.transparent,
                ),
              )
            : null,
      ),
      body: WebViewWidget(controller: _controller),
    );
  }
}
