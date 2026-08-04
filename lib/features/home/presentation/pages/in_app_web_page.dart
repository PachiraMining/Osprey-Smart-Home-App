import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../../../core/theme/app_surfaces.dart';

/// Generic in-app browser page: renders [url] in a WebView with a titled
/// app bar, load progress and back-through-history handling.
class InAppWebPage extends StatefulWidget {
  final String title;
  final String url;

  const InAppWebPage({super.key, required this.title, required this.url});

  @override
  State<InAppWebPage> createState() => _InAppWebPageState();
}

class _InAppWebPageState extends State<InAppWebPage> {
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
      ..loadRequest(Uri.parse(widget.url));
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
      backgroundColor: context.surfaces.pageBg,
      appBar: AppBar(
        backgroundColor: context.surfaces.sheet,
        elevation: 0,
        leading: IconButton(
          icon:  Icon(Icons.arrow_back_ios,
              size: 20, color: context.surfaces.textPrimary),
          onPressed: _goBack,
        ),
        centerTitle: true,
        title: Text(
          widget.title,
          style:  TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: context.surfaces.textPrimary,
          ),
        ),
        actions: [
          IconButton(
            icon:  Icon(Icons.refresh, size: 22, color: context.surfaces.textPrimary),
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
