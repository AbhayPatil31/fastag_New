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
import '../api/response/CCAvenueResponse.dart';
import '../api/response/paymentresponse.dart';
import '../utility/apputility.dart';
import '../utility/progressdialog.dart';
import '../utility/snackbardesign.dart';
import 'CCAvenueWebViewPage.dart';
import 'upigetwayservices.dart';
import 'package:http/http.dart' as http;
import "package:flutter/services.dart";
import 'package:encrypt/encrypt.dart' as encrypt;
import 'dart:convert';
import 'package:app_links/app_links.dart';

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
String ccavenueurl = "";

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
  final String returnUrl =
      "yourapp://paymentresponse"; // Define your custom scheme URL
  late AppLinks _appLinks;
  @override
  void initState() {
    super.initState();
    // getRsaPublicKey();
    Networkcallforgetpaymentoption();
    // Networkcallforapiinitiateccavenueforwalletrecharge();
    // Initialize AppLinks to listen for deep links
    _appLinks = AppLinks();
    _appLinks.uriLinkStream.listen((Uri? uri) {
      if (uri != null) {
        _handleDeepLink(uri);
      }
    });

    AppLinks().uriLinkStream.listen((Uri? uri) {
      if (uri != null) {
        // Handle the deep link when the app is already running
        _handleDeepLink(uri);
      }
    });
  }

  void _handleDeepLink(Uri uri) {
    if (uri.host == "paymentresponse") {
      if (uri.pathSegments.contains('success')) {
        // Payment successful
        final paymentId = uri.queryParameters['payment_id'];
        if (paymentId != null) {
          handlePaymentSuccessResponseCcAvenue(paymentId);
        } else {
          handlePaymentErrorResponseCcAvenue("Invalid payment response");
        }
      } else if (uri.pathSegments.contains('cancel')) {
        // Payment canceled
        handlePaymentErrorResponseCcAvenue("Payment cancelled by user");
      }
    }
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

  Future<String> getRsaPublicKey() async {
    final response = await http
        .get(Uri.parse('https://test.ccavenue.com/transaction/getRSAKey'));

    if (response.statusCode == 200) {
      // Assuming the response contains the public key in plain text
      return response.body; // This should be the RSA public key
    } else {
      throw Exception('Failed to load RSA public key');
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
                          rechargeByCcAvenue(context);
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

  Future<void> rechargeByCcAvenue(BuildContext context) async {
    try {
      Networkcallforplaceorderwithccavenue();
      // String url = "https://shauryapay.com/testing/check_status";

      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CCAvenueWebViewPage(
            initiateUrl: ccavenueurl,
          ),
        ),
      );
    } catch (e) {
      handlePaymentErrorResponseCcAvenue(e.toString());
    }
  }

// Ensure your encryption method is correct
  // Future<String> getEncryptedValue(
  //     Map<String, String> params, String workingKey) async {
  //   // Convert params to a URL-encoded string format
  //   String dataToEncrypt =
  //       params.entries.map((e) => '${e.key}=${e.value}').join('&');
  //   print('Data to Encrypt: $dataToEncrypt');

  //   // Use the Working Key provided by CCAvenue
  //   final key = encrypt.Key.fromUtf8(workingKey); // Ensure 16 bytes key
  //   final iv =
  //       encrypt.IV.fromLength(16); // Initialization Vector (empty for CBC mode)
  //   final encrypter =
  //       encrypt.Encrypter(encrypt.AES(key, mode: encrypt.AESMode.cbc));

  //   // Encrypt the data
  //   final encrypted = encrypter.encrypt(dataToEncrypt, iv: iv);

  //   // Return the base64 encoded encrypted string
  //   return encrypted.base64;
  // }

  Future<void> launchBrowser(String url) async {
    // You can use url_launcher or another package to open a browser
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

// Handling CCAvenue payment failure
  void handlePaymentErrorResponseCcAvenue(String? message) {
    // Your error handling logic here
    print("Payment Failed: $message");
    showAlertDialog(context, "Payment Failed", message ?? "Unknown Error");
  }

// Handling CCAvenue payment success
  void handlePaymentSuccessResponseCcAvenue(String paymentId) {
    // Your success handling logic here
    print("Payment Successful with ID: $paymentId");
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

  Future<void> showAlertDialog(
      BuildContext context, String title, String content) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(content),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
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

  Future<String> getEncryptedValue(
      Map<String, String> params, String workingKey) async {
    // Convert params to a URL-encoded string format
    String dataToEncrypt =
        params.entries.map((e) => '${e.key}=${e.value}').join('&');
    print('Data to Encrypt: $dataToEncrypt');

    // Ensure your working key is exactly 16 bytes
    final key = encrypt.Key.fromUtf8(workingKey);
    final iv = encrypt.IV.fromLength(16); // AES IV (16-byte)

    // Create AES Encrypter with CBC mode
    final encrypter =
        encrypt.Encrypter(encrypt.AES(key, mode: encrypt.AESMode.cbc));

    // Encrypt the data
    final encrypted = encrypter.encrypt(dataToEncrypt, iv: iv);

    // Return the base64 encoded encrypted string
    return encrypted.base64;
  }

  Future<void> Networkcallforplaceorderwithccavenue() async {
    try {
      ProgressDialog.showProgressDialog(context, "Loading...");
      String creatjson = createjson().initapiforgeturlcallFromJson(
          AppUtility.AgentId, widget.amount, context);
      List<Object?>? list = await NetworkCall().postMethod(
          URLS().api_initiate_cc_avenue_for_wallet_rechargeapi,
          URLS().api_initiate_cc_avenue_for_wallet_rechargeurl,
          creatjson,
          context);
      if (list != null) {
        Navigator.pop(context);
        List<Ccavenueapiresponse> response = List.from(list!);
        String status = response[0].status!;
        switch (status) {
          case "true":
            ccavenueurl = response[0].initiateUrl!;

            MaterialPageRoute(
              builder: (context) => CCAvenueWebViewPage(
                initiateUrl: response[0].initiateUrl!,
              ),
            );

            break;

          case "false":
            SnackBarDesign(
                'Unable to pay emi!', context, Colors.red, Colors.white);
            break;
        }
      } else {
        Navigator.pop(context);
      }
    } catch (e) {
      // PrintMessage.printmessage(e.toString(), 'Networkcallforplaceorderwithemi',
      // 'Check Out EMI', context);
    }
    // }

    // if (result != null) {
    //   // Handle the response from the WebView
    //   final status = result['status'];
    //   final message = result['message'];
    //   final data = result['data'];

    //   print('##########Status: $status############');
    //   print('Message: $message');
    //   print('Data: $data');

    // Process the result as needed
  }
}
