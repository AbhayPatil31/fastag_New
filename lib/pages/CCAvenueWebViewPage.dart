import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:html/parser.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../api/network/network.dart';
import '../api/response/CCAvenueResponse.dart';
import 'ThankYouPageforCCAvenuePayment.dart';

class CCAvenueWebViewPage extends StatefulWidget {
  final String initiateUrl;
  // final String merchantId;
  // final String accessCode;
  // final String workingKey;
  final String orderId;
  // final String amount;
    CCAvenueWebViewPage({
    required this.initiateUrl,
    // required this.merchantId,
    // required this.accessCode,
    // required this.workingKey,
    required this.orderId,
    // required this.amount, 
    // required String url,
  });

  @override
  _CCAvenueWebViewPageState createState() => _CCAvenueWebViewPageState();
}

class _CCAvenueWebViewPageState extends State<CCAvenueWebViewPage> {
  late WebViewController _controller;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
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

  void _handleCCResponse(String htmlContent) {
    // Parse the HTML response
    final parsedHtml = parse(htmlContent);
    final jsonData = parsedHtml.body?.text ?? '';
    var result = ccavenueapiresponseFromJson(jsonData);

    String orderStatus = result[0].message ?? "Failed";
    String trackingId = result[0].status ?? "";
    String initiateUrl = result[0].initiateUrl ?? "";

    if (orderStatus == "Success") {
      // Payment successful, call the API to update status
      _updateCCPaymentStatus(orderStatus, trackingId, initiateUrl);
    } else {
      // Payment failed
      showAlertDialog(context, "Payment Failed", "Transaction failed.");
    }
  }

  Future<void> _updateCCPaymentStatus(
      String status, String trackingId, String bankRefNo) async {
    String jsonPayload = json.encode({
      "orderId": widget.orderId,
      "trackingId": trackingId,
      "bankRefNo": bankRefNo,
      "orderStatus": status,
      "paymentStatus": "1"
    });

    List<Object?>? response = await NetworkCall().postMethod(
      1,
      'https://your-api-url.com/update-payment-status', // Use actual URL
      jsonPayload,
      context,
    );

    if (response != null && response.isNotEmpty && response[0] == "true") {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => ThankYouPage()),
      );
    } else {
      showAlertDialog(context, "Payment Failed", "Unable to process payment.");
    }
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
