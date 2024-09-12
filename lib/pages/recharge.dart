import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:fast_tag/pages/amountdialog.dart';
import 'package:fast_tag/pages/paymentoption.dart';
import 'package:fast_tag/utility/apputility.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

import '../api/network/create_json.dart';
import '../api/network/network.dart';
import '../api/network/uri.dart';
import '../api/response/getrazorpaydetailsapiresponse.dart';
import '../api/response/getvehicleclassresponse.dart';
import '../api/response/paymentresponse.dart';
import '../api/response/wallettotalamountresponse.dart';
import '../utility/colorfile.dart';
import '../utility/snackbardesign.dart';
import 'homeScreen.dart';
import 'wallet.dart';

List<WallettotalamountDatum> wallenttotalamount = [];
final _amountcontroller = TextEditingController();
bool validateamount = true;

class RechargePage extends StatefulWidget {
  String pagefrom;
  RechargePage(this.pagefrom);
  State createState() => RechargePageState();
}

class RechargePageState extends State<RechargePage> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Networkcallforwalletamount();
    Networkcallforgetvehicleclass();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    wallenttotalamount.clear();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _amountcontroller.clear();
    });
    validateamount = true;
  }

  Future<void> Networkcallforwalletamount() async {
    try {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _amountcontroller.clear();
      });
      String createjsonforstocklist =
          createjson().createjsonforstocklist(AppUtility.AgentId, context);
      List<Object?>? list = await NetworkCall().postMethod(
          URLS().wallet_total_amount_api,
          URLS().wallet_total_amount_api_url,
          createjsonforstocklist,
          context);
      if (list != null) {
        List<Wallettotalamountresponse> response = List.from(list!);
        String status = response[0].status!;
        switch (status) {
          case "true":
            wallenttotalamount = response[0].data!;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              setState(() {});
            });
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

  String keyid = "", secretekey = "";
  String cc_merchant_id = "", cc_access_code = "", cc_working_key = "";
  List<GetrazorpaydetailsapiresponseData> datalist = [];

  Future<void> Networkcallforgetvehicleclass() async {
    try {
      List<Object?>? list = await NetworkCall().getMethod(
          URLS().get_razor_pay_detailsapi,
          URLS().get_razor_pay_detailsurl,
          context);
      if (list != null) {
        List<Getrazorpaydetailsapiresponse> response = List.from(list!);
        String status = response[0].status!;
        switch (status) {
          case "true":
            GetrazorpaydetailsapiresponseData obj = response[0]!.data!;
            keyid = obj.razorPayKey!;
            secretekey = obj.razorPaySecret!;
            cc_merchant_id = obj.ccMerchantId!;
            cc_access_code = obj.ccAccessCode!;
            cc_working_key = obj.ccWorkingKey!;
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
    return WillPopScope(
        onWillPop: () async {
          // Handle the system back button press manually
          if (widget.pagefrom == "wallet") {
            // Pop and go back to the previous screen for wallet case
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => MyDashboard(),
              ),
              // (Route<dynamic> route) => false,
            );
          } else if (widget.pagefrom == "failurepage") {
            // Pop and return to the previous screen for failure page case
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => MyDashboard(),
              ),
              // (Route<dynamic> route) => false,
            );

            // You may add additional logic to navigate to another specific page, if required
          } else {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => MyDashboard(),
              ),
              // (Route<dynamic> route) => false,
            );
            // Prevent app from closing for other cases
            return false;
          }
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => MyDashboard(),
            ),
            // (Route<dynamic> route) => false,
          );
          return true;
        },
        child: Scaffold(
          extendBodyBehindAppBar: true, // Extend the body behind the app bar
          appBar: AppBar(
            title: Text(
              'Recharge/ Refill',
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w600,
                color: Color(0xFF1D2024),
                fontSize: 18,
              ),
            ),
            backgroundColor: Colors.white,
            elevation: 0,
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.black),
              onPressed: () {
                // Handle the back icon press on the AppBar
                if (widget.pagefrom == "wallet") {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => MyDashboard(),
                    ),
                    // (Route<dynamic> route) => false,
                  );
                } else if (widget.pagefrom == "failurepage") {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => MyDashboard(),
                    ),
                    // (Route<dynamic> route) => false,
                  );
                } else {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => MyDashboard(),
                    ),
                    // (Route<dynamic> route) => false,
                  );
                  // You can handle other cases if needed, or add more conditions
                }
              },
            ),
          ),
          // Set the background image as the body
          body: Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('images/rechargeBackground.png'),
                fit: BoxFit.cover,
              ),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 100,
                    backgroundColor: Color.fromRGBO(
                        255, 255, 255, 1), // Set the background color
                    backgroundImage: AssetImage('images/recharge.gif'),
                  ),
                  SizedBox(height: 30),
                  // Text(
                  //   '₹5,000',
                  //   style: TextStyle(
                  //     fontSize: 50, // Increase font size to 24
                  //     fontWeight: FontWeight.bold, // Increase font weight to bold
                  //     color: Colors.white,
                  //   ),
                  // ),
                  Text(
                    'Enter Your Amount',
                    style: GoogleFonts.inter(fontSize: 20, color: Colors.white),
                  ),
                  SizedBox(height: 20),
                  SizedBox(
                    width: 200, // Adjust the width as needed
                    child: TextField(
                      controller: _amountcontroller,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                            RegExp(r'^\d*\.?\d{0,10}')),
                      ],
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: 'RS.', // Add placeholder text
                        hintStyle: TextStyle(color: Colors.white),
                        border: InputBorder.none,
                        errorText: validateamount
                            ? null
                            : "Please enter recharge amount",
                        errorStyle: TextStyle(color: Colors.red, fontSize: 10),
                        filled: true,
                        fillColor: const Color(0xFF0056D1),
                        contentPadding: EdgeInsets.symmetric(
                          vertical: 10,
                          horizontal: 20,
                        ), // Adjust the padding
                      ),
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Existing Balance is Rs.${wallenttotalamount.isEmpty ? 0 : wallenttotalamount[0].amount}',
                    style: GoogleFonts.inter(fontSize: 16, color: Colors.white),
                  ),
                  SizedBox(height: 28),
                  ElevatedButton(
                    onPressed: () {
                      if (_amountcontroller.text.isEmpty) {
                        validateamount = false;
                        setState(() {});
                      } else {
                        // rechargenow();
                        Navigator.push(context, MaterialPageRoute(
                          builder: (context) {
                            return PaymentOption(
                                _amountcontroller.text,
                                keyid,
                                secretekey,
                                cc_merchant_id,
                                cc_access_code,
                                cc_working_key);
                          },
                        )).then(
                          (value) {
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              _amountcontroller.clear();
                            });
                            validateamount = true;

                            Networkcallforwalletamount();
                            if (widget.pagefrom == "wallet") {
                              Navigator.pop(context);
                            }
                          },
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      padding:
                          EdgeInsets.symmetric(horizontal: 60, vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                            5), // Set border radius to 5px
                      ),
                    ),
                    child: Text(
                      'Submit',
                      style: GoogleFonts.inter(
                          fontSize: 18, color: Color.fromRGBO(1, 67, 121, 1)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ));
  }
}
