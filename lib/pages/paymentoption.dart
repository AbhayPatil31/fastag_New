import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:fast_tag/api/response/getpaymentoptionresponse.dart';
import 'package:fast_tag/pages/paymentscreen.dart';
import 'package:fast_tag/utility/colorfile.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../api/network/create_json.dart';
import '../api/network/network.dart';
import '../api/network/uri.dart';
import '../api/response/paymentresponse.dart';
import '../utility/apputility.dart';
import '../utility/snackbardesign.dart';
import 'upigetwayservices.dart';

bool allowrazorpay = false, allowupi = false;
String message =
    "Payment gateway have some technical issues please wait for some time or you can contact from the administrator";

class PaymentOption extends StatefulWidget {
  String amount, keyid, secretekey;
  PaymentOption(this.amount, this.keyid, this.secretekey);
  @override
  State<PaymentOption> createState() => PaymentOptionState();
}

class PaymentOptionState extends State<PaymentOption> {
  final UpiGatewayService _upiService = UpiGatewayService();
  @override
  void initState() {
    super.initState();
    Networkcallforgetpaymentoption();
  }

  Future<void> Networkcallforgetpaymentoption() async {
    try {
      List<Object?>? list = await NetworkCall().getMethod(
          URLS().get_razorpay_status, URLS().get_razorpay_status_url, context);
      if (list != null) {
        List<Getpaymentoptionresponse> response = List.from(list!);
        String status = response[0].status!;
        switch (status) {
          case "true":
            if (response[0].razzorGatewayStatus == "1") {
              allowrazorpay = true;
            } else {
              allowrazorpay = false;
              message = response[0].razzor_gateway_message!;
            }
            if (response[0].upiGatewayStatus == "1") {
              allowupi = true;
            } else {
              allowupi = false;
              message = response[0].upi_gateway_message!;
            }

            setState(() {});
            break;
          case "false":
            SnackBarDesign(
                response[0].message!,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Secure Payment Gateway',
            style: GoogleFonts.inter(
              fontWeight: FontWeight.w600,
              color: Color(0xFF1D2024),
              fontSize: 18,
            )),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: allowrazorpay == false && allowupi == false
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Center(
                    child: Lottie.asset('images/done.json', width: 300),
                  ),
                  Text(
                    'Secure Payment Gateway',
                    style: TextStyle(
                        color: Color(0xffd4aa1e),
                        fontSize: 16,
                        fontWeight: FontWeight.w700),
                  ),
                  Text(
                    message,
                    style: TextStyle(
                        color: colorfile().buttoncolor,
                        fontSize: 10,
                        fontWeight: FontWeight.w500),
                    textAlign: TextAlign.center,
                  ).marginOnly(top: 10, bottom: 10),
                  Row(
                    children: [
                      allowrazorpay
                          ? Expanded(
                              child: ElevatedButton(
                              onPressed: () {},
                              style: ButtonStyle(
                                shape: MaterialStateProperty.all<
                                    RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                        5.0), // Button corner radius 5px
                                  ),
                                ),
                                padding: MaterialStateProperty.all<EdgeInsets>(
                                    EdgeInsets.zero),
                              ),
                              child: Ink(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Color(0xFF808080),
                                      Color(0xFF808080).withOpacity(0.7),
                                      Color(0xFF808080).withOpacity(0.5),
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(5.0),
                                ),
                                child: Container(
                                  height: 60,
                                  width: double
                                      .infinity, // Make button width match its parent
                                  alignment: Alignment.center,
                                  child: Text(
                                    'Pay via Razorpay',
                                    style: TextStyle(
                                      color: Colors
                                          .white, // Set text color to white for better contrast
                                      fontSize: 18.0,
                                    ),
                                  ),
                                ),
                              ),
                            ))
                          : Container(),
                      allowrazorpay
                          ? SizedBox(
                              width: 10,
                            )
                          : Container(),
                      allowupi
                          ? Expanded(
                              child: ElevatedButton(
                              onPressed: () async {},
                              style: ButtonStyle(
                                shape: MaterialStateProperty.all<
                                    RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                        5.0), // Button corner radius 5px
                                  ),
                                ),
                                padding: MaterialStateProperty.all<EdgeInsets>(
                                    EdgeInsets.zero),
                              ),
                              child: Ink(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Color(0xFF08469D),
                                      Color(0xFF0056D0),
                                      Color(0xFF0C92DD),
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(5.0),
                                ),
                                child: Container(
                                  height: 60,
                                  width: double
                                      .infinity, // Make button width match its parent
                                  alignment: Alignment.center,
                                  child: Text(
                                    'Pay via UPI Getway',
                                    style: TextStyle(
                                      color: Colors
                                          .white, // Set text color to white for better contrast
                                      fontSize: 18.0,
                                    ),
                                  ),
                                ),
                              ),
                            ))
                          : Container(),
                    ],
                  ),
                ],
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Center(
                    child: Lottie.asset('images/done.json', width: 300),
                  ),
                  Text(
                    'Secure Payment Gateway',
                    style: TextStyle(
                        color: Color(0xffd4aa1e),
                        fontSize: 16,
                        fontWeight: FontWeight.w700),
                  ),
                  Text(
                    'Experience unparalleled security with our Payment Gateway. ',
                    style: TextStyle(
                        color: colorfile().buttoncolor,
                        fontSize: 10,
                        fontWeight: FontWeight.w500),
                    textAlign: TextAlign.center,
                  ).marginOnly(top: 10, bottom: 10),
                  Row(
                    children: [
                      allowrazorpay
                          ? Expanded(
                              child: ElevatedButton(
                              onPressed: () {
                                rechargenow();
                              },
                              style: ButtonStyle(
                                shape: MaterialStateProperty.all<
                                    RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                        5.0), // Button corner radius 5px
                                  ),
                                ),
                                padding: MaterialStateProperty.all<EdgeInsets>(
                                    EdgeInsets.zero),
                              ),
                              child: Ink(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Color(0xFF08469D),
                                      Color(0xFF0056D0),
                                      Color(0xFF0C92DD),
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(5.0),
                                ),
                                child: Container(
                                  height: 60,
                                  width: double
                                      .infinity, // Make button width match its parent
                                  alignment: Alignment.center,
                                  child: Text(
                                    'Pay via Razorpay',
                                    style: TextStyle(
                                      color: Colors
                                          .white, // Set text color to white for better contrast
                                      fontSize: 18.0,
                                    ),
                                  ),
                                ),
                              ),
                            ))
                          : Container(),
                      allowrazorpay
                          ? SizedBox(
                              width: 10,
                            )
                          : Container(),
                      allowupi
                          ? Expanded(
                              child: ElevatedButton(
                              onPressed: () async {
                                var paymentData =
                                    await _upiService.initiatePayment(
                                        'Satish Mungase',
                                        'satish@shauryasoftrack.com',
                                        '8329265068',
                                        double.parse(widget.amount));

                                var paymentUrl = paymentData.data!.paymentUrl!;

                                Navigator.push(context, MaterialPageRoute(
                                  builder: (context) {
                                    return Paymentscreen(
                                        paymentUrl, widget.amount);
                                  },
                                )).then(
                                  (value) {
                                    Navigator.pop(context);
                                  },
                                );
                              },
                              style: ButtonStyle(
                                shape: MaterialStateProperty.all<
                                    RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                        5.0), // Button corner radius 5px
                                  ),
                                ),
                                padding: MaterialStateProperty.all<EdgeInsets>(
                                    EdgeInsets.zero),
                              ),
                              child: Ink(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Color(0xFF08469D),
                                      Color(0xFF0056D0),
                                      Color(0xFF0C92DD),
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(5.0),
                                ),
                                child: Container(
                                  height: 60,
                                  width: double
                                      .infinity, // Make button width match its parent
                                  alignment: Alignment.center,
                                  child: Text(
                                    'Pay via UPI Getway',
                                    style: TextStyle(
                                      color: Colors
                                          .white, // Set text color to white for better contrast
                                      fontSize: 18.0,
                                    ),
                                  ),
                                ),
                              ),
                            ))
                          : Container(),
                    ],
                  ),
                  //  Text("Result \n $result"),
                ],
              ),
      ),
    );
  }

  rechargenow() async {
    Razorpay razorpay = Razorpay();
    var options = {
      'key': widget.keyid,
      'amount': double.parse(widget.amount) * 100,
      'name': 'Shaurya Softrack',
      'description': '',
      'id': '${AppUtility.AgentId}_${Random().nextInt(100)})',
      'send_sms_hash': true,
      'prefill': {
        'contact': AppUtility.Mobile_Number,
      },
    };
    razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, handlePaymentErrorResponse);
    razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, handlePaymentSuccessResponse);
    razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, handleExternalWalletSelected);
    razorpay.open(options);
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

  void handlePaymentErrorResponse(PaymentFailureResponse response) {
    Networkcallforupdatepaymentstatus(response.code.toString(), widget.amount,
        "2", response.error!['reason'], "1", "0");
    showAlertDialog(context, "Payment Failed",
        "Code: ${response.code}\nDescription: ${response.message}");
  }

  void handlePaymentSuccessResponse(PaymentSuccessResponse response) {
    print(response.data);
    final key = utf8.encode(widget.secretekey);
    final bytes = utf8.encode('${response.orderId}|${response.paymentId}');
    final hmacSha256 = Hmac(sha256, key);
    final generatedSignature = hmacSha256.convert(bytes);
    // if (generatedSignature.toString() == response.signature) {
    Networkcallforupdatepaymentstatus(response.paymentId!, widget.amount, "2",
        "Payment Successful", "1", "1");
    // } else {
    //   Networkcallforupdatepaymentstatus(response.paymentId!,
    //       _amountcontroller.text, "2", "Unauthentic Payment", "1", "0");
    // }
  }

  void handleExternalWalletSelected(ExternalWalletResponse response) {
    showAlertDialog(
        context, "External Wallet Selected", "${response.walletName}");
  }

  void showAlertDialog(BuildContext context, String title, String message) {
    // set up the buttons
    Widget continueButton = ElevatedButton(
      child: const Text("Continue"),
      onPressed: () {},
    );
    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text(title),
      content: Text(message),
    );
    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }
}
