import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class CCAvenueWebViewPage extends StatefulWidget {
  final String initiateUrl;

  CCAvenueWebViewPage({
    required this.initiateUrl,
  });

  @override
  _CCAvenueWebViewPageState createState() => _CCAvenueWebViewPageState();
}

class _CCAvenueWebViewPageState extends State<CCAvenueWebViewPage> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();

    // Initialize WebViewController
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (String url) async {
            // Inject JavaScript to handle a simple message response
            await _controller.runJavaScript("""
              window.addEventListener('message', function(event) {
                if (event.origin === 'https://shauryapay.com') {
                  // Send the response data to Flutter via JavaScriptChannel
                  window.flutterMessage.postMessage(event.data);
                }
              });

              // For demonstration, post a simple message when the page loads
              window.postMessage('success', '*');
            """);
          },
          onPageStarted: (String url) {
            print('Page started loading: $url');
          },
          onWebResourceError: (WebResourceError error) {
            print('Web resource error: ${error.description}');
            showAlertDialog(
                context, "Error", "Failed to load page: ${error.description}");
          },
        ),
      )
      ..addJavaScriptChannel(
        'flutterMessage',
        onMessageReceived: (JavaScriptMessage message) {
          // Directly handle the simple message
          final String messageContent = message.message;
          print('Message received: $messageContent');

          // Use the received message as needed
          handleWebViewResponse(messageContent);
        },
      )
      ..loadRequest(Uri.parse(widget.initiateUrl));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("CC Avenue Payment"),
      ),
      body: WebViewWidget(controller: _controller),
    );
  }

  void showAlertDialog(BuildContext context, String title, String message) {
    AlertDialog alert = AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        ElevatedButton(
          child: const Text("OK"),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ],
    );
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  String? handleWebViewResponse(String message) {
    // Handle the WebView response
    print("Handling WebView Response: $message");

    // Example action based on message
    if (message == 'success') {
      log("****Payment Successful***");
      return message;
    } else {
      log("Unexpected message received: $message");
      return message;
    }
    return message;
  }
}
