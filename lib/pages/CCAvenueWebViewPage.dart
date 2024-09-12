import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'PaymentFailurePage.dart';
import 'ThankYouPageforCCAvenuePayment.dart';

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
            // Inject JavaScript to capture message on the page after it loads
            await _controller.runJavaScript("""
            // Assuming the message is in the body or a specific element
            var message = document.body.innerText || '';  // Modify this to target the right element
            // Send the message back to Flutter
            window.flutterMessage.postMessage(message);
            """);
          },
          onPageStarted: (String url) {
            log('#####Page started loading####: $url');
          },
          onWebResourceError: (WebResourceError error) {
            log('###Web resource error###: ${error.description}');
            showAlertDialog(
                context, "Error", "Failed to load page: ${error.description}");
          },
        ),
      )
      ..addJavaScriptChannel(
        'flutterMessage',
        onMessageReceived: (JavaScriptMessage message) {
          // Handle the message received from the webview
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

  Future<void> handleWebViewResponse(String message) async {
    try {
      // Check for string format like "Failure@@@113458220733" or "Success@@@113458220733"
      final parts = message.split('@@@');
      if (parts.length == 2) {
        final status = parts[0].toLowerCase().trim();
        final transactionId = parts[1].trim();

        if (status == 'success') {
          log("****Payment Successful*** Transaction ID: $transactionId");
          await Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => ThankYouPage(
                orderId: transactionId,
                trackingId: transactionId,
              ), //FailedPaymentPage
            ),
          );
        } else if (status == 'failure') {
          log("****Payment Failed*** Transaction ID: $transactionId");
          await Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => FailedPaymentPage(
                transactionId: transactionId,
              ), //FailedPaymentPage
            ),
          );
        } else {
          log("Unknown status received: $status");
        }
      } else {
        log("Invalid message format received: $message");
      }
    } catch (e) {
      // If message parsing fails, log the error
      log("Failed to parse message: $e");
    }
  }
}
