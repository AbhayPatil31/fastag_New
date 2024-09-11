import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:html/parser.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../api/network/network.dart';
import '../api/response/CCAvenueResponse.dart';
import 'ThankYouPageforCCAvenuePayment.dart';

class CCAvenueWebViewPage extends StatefulWidget {
  final String initiateUrl;
  final String orderId;

  CCAvenueWebViewPage({
    required this.initiateUrl,
    required this.orderId,
  });

  @override
  _CCAvenueWebViewPageState createState() => _CCAvenueWebViewPageState();
}

class _CCAvenueWebViewPageState extends State<CCAvenueWebViewPage> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();

    // Initialize WebViewController with necessary configurations
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            print('Page started loading: $url');
          },
          onPageFinished: (String url) {
            print('Page finished loading: $url');
          },
          onWebResourceError: (WebResourceError error) {
            print('Web resource error: ${error.description}');
            showAlertDialog(
                context, "Error", "Failed to load page: ${error.description}");
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.initiateUrl));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("CC Avenue Payment"),
      ),
      body: WebViewWidget(
          controller: _controller), // Use WebViewWidget with controller
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
}
