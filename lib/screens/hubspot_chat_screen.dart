import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../utils/app_colors.dart';

class HubspotChatScreen extends StatefulWidget {
  const HubspotChatScreen({super.key});

  @override
  State<HubspotChatScreen> createState() => _HubspotChatScreenState();
}

class _HubspotChatScreenState extends State<HubspotChatScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(AppColors.offWhite)
      ..loadHtmlString(_chatPage, baseUrl: 'https://zippystyle.com')
      ..setNavigationDelegate(NavigationDelegate(
        onPageFinished: (_) {
          if (mounted) setState(() => _isLoading = false);
        },
        onWebResourceError: (error) {
          debugPrint('HubSpot WebView error: ${error.description} (code=${error.errorCode}, url=${error.url})');
        },
      ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.offWhite,
      appBar: AppBar(
        title: const Text("CHAT WITH US"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading)
            const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }

  static const _chatPage = '''
<!DOCTYPE html>
<html>
<head>
  <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
  <style>
    * { margin: 0; padding: 0; box-sizing: border-box; }
    html, body { height: 100%; }
    body {
      font-family: -apple-system, BlinkMacSystemFont, sans-serif;
      background: #F5F5F5;
      display: flex;
      flex-direction: column;
    }
    .header {
      padding: 40px 24px 16px;
      text-align: center;
      color: #333;
    }
    .header h1 { font-size: 20px; margin-bottom: 8px; }
    .header p { font-size: 14px; color: #666; }
    .spacer { flex: 1; }
  </style>
</head>
<body>
  <div class="header">
    <h1>Need help?</h1>
    <p>We're here to assist you. The chat widget will appear below.</p>
  </div>
  <div class="spacer"></div>

  <script>
    window.hsConversationsSettings = {
      loadImmediately: true,
      inlineEmbedSelector: undefined
    };
  </script>
  <script type="text/javascript" id="hs-script-loader" async defer src="https://js.hs-scripts.com/246521700.js"></script>
  <script>
    window.hsConversationsOnReady = function() {
      if (window.HubSpotConversations && window.HubSpotConversations.widget) {
        window.HubSpotConversations.widget.open();
        console.log('HubSpot widget opened');
      }
    };
  </script>
</body>
</html>
''';
}
