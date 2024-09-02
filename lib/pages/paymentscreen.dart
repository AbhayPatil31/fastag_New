import 'package:android_intent_plus/android_intent.dart';
import 'package:android_intent_plus/flag.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get_utils/get_utils.dart';
import 'package:html/parser.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../api/network/create_json.dart';
import '../api/network/network.dart';
import '../api/network/uri.dart';
import '../api/response/paymentresponse.dart';
import '../utility/apputility.dart';
import '../utility/colorfile.dart';
import '../utility/snackbardesign.dart';

class Paymentscreen extends StatefulWidget {
  String url, amount;
  Paymentscreen(this.url, this.amount);

  @override
  PaymentscreenState createState() => PaymentscreenState();
}

WebViewController controller = WebViewController();

class PaymentscreenState extends State<Paymentscreen> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onUrlChange: (change) async {
            print(change);
          },
          onProgress: (int progress) {
            print(progress);
          },
          onPageStarted: (String url) async {
            print('URL: ' + url);

            if (url.contains("https://yourdomain.com/payment_success")) {
              List abc = url.split('&');
              List abcd = abc[1].toString().split('=');
              _handlePaymentSuccess(abcd[1]);
            } else if (url.contains("https://yourdomain.com/payment_failure")) {
              List abc = url.split('&');
              List abcd = abc[1].toString().split('=');
              _handlePaymentFailure(abcd[1]);
            } else if (url.startsWith("upi://pay")) {
              //_launchUPIIntent(url);
            }
          },
          onPageFinished: (String url) async {
            print(url);
          },
          onWebResourceError: (WebResourceError error) {
            print('WebResourceError: ${error.description}');
          },
          onNavigationRequest: (NavigationRequest request) async {
            if (request.url.startsWith("upi://pay")) {
              _launchUPIIntent(request.url);
              // if (await canLaunch(Uri.parse(request.url).toString())) {
              //   await launch(Uri.parse(request.url).toString());
              return NavigationDecision.prevent;
              // } else {
              //   print(
              //       'Could not launch UPI intent: ${Uri.parse(request.url).toString()}');
              //   return NavigationDecision.prevent;
              // }
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
  }

  void _handlePaymentSuccess(String transactionId) {
    // Navigate to success screen or show a success message
    Networkcallforupdatepaymentstatus(
        transactionId, widget.amount, '2', 'Payment Successful', '1', '1');
    // Navigator.pop(context, 'Payment Successful');
  }

  void _handlePaymentFailure(String transactionId) {
    // Navigate to failure screen or show a failure message
    // Navigator.pop(context, 'Payment Failed');
    Networkcallforupdatepaymentstatus(
        transactionId, widget.amount, "2", 'Payment Successful', "1", "0");
  }

  void _parseHtmlForTransactionStatus(String htmlContent) {
    // You can parse the HTML content to look for specific indicators of success or failure
    if (htmlContent.contains('Success')) {
      _handlePaymentSuccess('');
    } else if (htmlContent.contains('Failure')) {
      _handlePaymentFailure('');
    }
  }

  void _launchUPIIntent(String upiUrl) async {
    try {
      final AndroidIntent intent = AndroidIntent(
        action: 'action_view',
        data: upiUrl,
        flags: <int>[Flag.FLAG_ACTIVITY_NEW_TASK],
      );
      await intent.launch();
    } catch (e) {
      print('Failed to launch UPI intent: $e');
      SnackBarDesign('No UPI App Found', context,
          colorfile().errormessagebcColor, colorfile().errormessagetxColor);
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return SafeArea(
      child: Scaffold(
        // appBar: AppBar(
        //   iconTheme: IconThemeData(color: Colors.black),
        //   leading: IconButton(
        //       onPressed: () {
        //         Navigator.pop(context);
        //       },
        //       icon: Icon(CupertinoIcons.left_chevron)),
        //   elevation: 0,
        //   toolbarHeight: 70,
        //   backgroundColor: context.theme.cardColor,
        //   title: Row(
        //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
        //     children: [
        //       GestureDetector(
        //         onTap: () {},
        //         child: Row(
        //           children: [Text('')],
        //         ).marginOnly(top: 10),
        //       ),
        //     ],
        //   ),
        // ),
        body: WebViewWidget(controller: controller),
      ),
    );
  }

  Future<void> Networkcallforupdatepaymentstatus(
      String paymentId,
      String amount,
      String paymentmode,
      String remark,
      String transactiontype,
      String paymentstatus) async {
    try {
      String craetejsonString = createjson().createjsonforupdatepaymentstatus(
          AppUtility.AgentId,
          amount,
          paymentmode,
          remark,
          transactiontype,
          paymentId,
          paymentstatus,
          context);
      List<Object?>? list = await NetworkCall().postMethod(
          URLS().set_wallet_amount_api,
          URLS().set_wallet_amount_api_url,
          craetejsonString,
          context);
      if (list != null) {
        List<RechargeNowResponse> response = List.from(list!);
        String status = response[0].status!;
        switch (status) {
          case "true":
            SnackBarDesign(
                "Recharge successfully!!",
                context,
                colorfile().sucessmessagebcColor,
                colorfile().sucessmessagetxColor);
            // if (widget.pagefrom == "wallet") {
            Navigator.pop(context);
            // } else {
            //  Navigator.pop(context);
            // }
            break;
          case "false":
            SnackBarDesign(
                "If the amount has been dedcuted then please wait for 24 hour ",
                context,
                colorfile().errormessagebcColor,
                colorfile().errormessagetxColor);
            break;
        }
      } else {
        SomethingWentWrongSnackBarDesign(context);
      }
    } catch (e) {
      print(e.toString());
    }
  }
}
