import 'dart:convert';
import 'dart:math';

import 'package:cc_avenue/cc_avenue.dart';
import 'package:crypto/crypto.dart';
import 'package:fast_tag/api/response/getpaymentoptionresponse.dart';
import 'package:fast_tag/pages/paymentscreen.dart';
import 'package:fast_tag/utility/colorfile.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
import 'CCAvenueWebViewPage.dart';
import 'upigetwayservices.dart';
import 'package:http/http.dart' as http;
import "package:flutter/services.dart";
import 'package:encrypt/encrypt.dart' as encrypt;
import 'dart:convert';

Future<String> encryptData(String data, String key) async {
  final keyBytes = encrypt.Key.fromBase64(key);
  final iv = encrypt.IV
      .fromLength(16); // CCAvenue might specify a specific IV length or method

  final encrypter = encrypt.Encrypter(encrypt.AES(keyBytes));
  final encrypted = encrypter.encrypt(data, iv: iv);

  return encrypted.base64;
}

Future<String> getEncryptedValue(Map<String, String> params) async {
  // Convert parameters to a string suitable for encryption
  String dataToEncrypt =
      params.entries.map((e) => '${e.key}=${e.value}').join('&');
  print('Data to Encrypt: $dataToEncrypt');

  // Encrypt the data
  String encryptedData = await encryptData(
      dataToEncrypt, 'YourEncryptionKey'); // Replace with the actual key
  return encryptedData;
}

bool allowrazorpay = false, allowupi = false, allowccavenue = false;
String message =
    "Payment gateway have some technical issues please wait for some time or you can contact from the administrator";

class PaymentOption extends StatefulWidget {
  String amount,
      keyid,
      secreteke,
      cc_merchant_id,
      cc_access_code,
      cc_working_key;

  PaymentOption(this.amount, this.keyid, this.secreteke, this.cc_merchant_id,
      this.cc_access_code, this.cc_working_key);
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
            if (response[0].ccavenue_gateway_status == "1") {
              allowccavenue = true;
            } else {
              allowccavenue = false;
              message = response[0].ccavenue_gateway_message!;
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
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    'Experience unparalleled security with our Payment Gateway.',
                    style: TextStyle(
                      color: colorfile().buttoncolor,
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ).marginOnly(top: 10, bottom: 10),
                  if (allowrazorpay) // Razorpay button
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5.0),
                      child: ElevatedButton(
                        onPressed: () {
                          rechargenow();
                        },
                        style: ButtonStyle(
                          shape:
                              MaterialStateProperty.all<RoundedRectangleBorder>(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5.0),
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
                            alignment: Alignment.center,
                            child: Text(
                              'Pay via Razorpay',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18.0,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  if (allowccavenue)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5.0),
                      child: ElevatedButton(
                        onPressed: () {
                          // startCCAvenuePayment();
                          rechargeByCcAvenue();
                        },
                        style: ButtonStyle(
                          shape:
                              MaterialStateProperty.all<RoundedRectangleBorder>(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5.0),
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
                            alignment: Alignment.center,
                            child: Text(
                              'Pay via CC Avenue',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18.0,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  if (allowupi) // UPI button
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5.0),
                      child: ElevatedButton(
                        onPressed: () async {
                          var paymentData = await _upiService.initiatePayment(
                              'Satish Mungase',
                              'satish@shauryasoftrack.com',
                              '8329265068',
                              double.parse(widget.amount));

                          var paymentUrl = paymentData.data!.paymentUrl!;

                          Navigator.push(context, MaterialPageRoute(
                            builder: (context) {
                              return Paymentscreen(paymentUrl, widget.amount);
                            },
                          )).then((value) {
                            Navigator.pop(context);
                          });
                        },
                        style: ButtonStyle(
                          shape:
                              MaterialStateProperty.all<RoundedRectangleBorder>(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5.0),
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
                            alignment: Alignment.center,
                            child: Text(
                              'Pay via UPI Gateway',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18.0,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
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

  static const MethodChannel _channel =
      MethodChannel('com.example.fast_tag/payment');

  Future<void> rechargeByCcAvenue() async {
    try {
      var params = {
        'merchant_id': widget.cc_merchant_id,
        'order_id':
            '${widget.keyid}_${Random().nextInt(100)}', // Unique order ID
        'currency': 'INR',
        'amount': (double.parse(widget.amount) * 100)
            .toString(), // Amount in smallest currency unit
        'redirect_url':
            'http://your_redirect_url_here.com', // Actual redirect URL
        'cancel_url': 'http://your_cancel_url_here.com', // Actual cancel URL
      };
      print('Parameters: $params');

      var encRequest = await getEncryptedValue(params);
      print('Encrypted Request: $encRequest');

      String accessCode =
          widget.cc_access_code; // Access code provided by CCAvenue

      String ccAvenueUrl =
          'https://secure.ccavenue.com/transaction.do?command=initiateTransaction&encRequest=$encRequest&access_code=$accessCode';

      final String result = await _channel.invokeMethod('startPayment', {
        'encRequest': encRequest,
        'accessCode': accessCode,
      });
      print(result);
    } catch (e) {
      print('CCAvenue Payment Error: $e');
      handlePaymentErrorResponseCcAvenue(e.toString());
    }
  }

// Ensure your encryption method is correct
  Future<String> getEncryptedValue(Map<String, String> params) async {
    // Convert parameters to a string suitable for encryption
    String dataToEncrypt =
        params.entries.map((e) => '${e.key}=${e.value}').join('&');
    print('Data to Encrypt: $dataToEncrypt');

    // Encrypt the data using the working key
    String encryptedData =
        await encryptData(dataToEncrypt, widget.cc_working_key);
    return encryptedData;
  }

// Handling CCAvenue payment failure
  void handlePaymentErrorResponseCcAvenue(String? message) {
    // Implement similar to Razorpay error handling logic
    Networkcallforupdatepaymentstatus(
      '', // Payment ID would be empty in case of error
      widget.amount,
      "2",
      message ?? "Unknown Error",
      "1",
      "0",
    );
    showAlertDialog(context, "Payment Failed", message ?? "Unknown Error");
  }

// Handling CCAvenue payment success
  void handlePaymentSuccessResponseCcAvenue(String paymentId) {
    Networkcallforupdatepaymentstatus(
      paymentId,
      widget.amount,
      "2",
      "Payment Successful",
      "1",
      "1",
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

  void handlePaymentErrorResponse(PaymentFailureResponse response) {
    Networkcallforupdatepaymentstatus(response.code.toString(), widget.amount,
        "2", response.error!['reason'], "1", "0");
    showAlertDialog(context, "Payment Failed",
        "Code: ${response.code}\nDescription: ${response.message}");
  }

//have to do work here today.
  void handlePaymentSuccessResponse(PaymentSuccessResponse response) {
    print(response.data);
    final key = utf8.encode(widget.secreteke);
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

  Future<String> encryptData(String data, String hexKey) async {
    try {
      // Convert hexadecimal key to bytes
      final keyBytes = hexToBytes(hexKey);

      // Create key object from bytes
      final key = encrypt.Key(keyBytes);

      // Create an Initialization Vector (IV)
      final iv = encrypt.IV.fromLength(
          16); // Ensure this is the correct length or method for CCAvenue

      // Initialize Encrypter with AES algorithm
      final encrypter = encrypt.Encrypter(encrypt.AES(key));

      // Encrypt data
      final encrypted = encrypter.encrypt(data, iv: iv);

      // Return encrypted data as base64
      return encrypted.base64;
    } catch (e) {
      print('Encryption Error: $e');
      throw e;
    }
  }

  Uint8List hexToBytes(String hex) {
    final buffer = Uint8List(hex.length ~/ 2);
    for (var i = 0; i < buffer.length; i++) {
      buffer[i] = int.parse(hex.substring(i * 2, i * 2 + 2), radix: 16);
    }
    return buffer;
  }
  // Future<String> getEncryptedValue(Map<String, String> requestParams) async {
  //   final response = await http.post(
  //     Uri.parse('https://test.ccavenue.com/'),
  //     body: requestParams,
  //   );
  //   if (response.statusCode == 200) {
  //     return response.body; // Encrypted value
  //   } else {
  //     throw Exception('Failed to load encrypted data');
  //   }
  // }
}
