import 'dart:async';
import 'package:fast_tag/api/response/cancelpendingissuanceresponse.dart';
import 'package:fast_tag/api/response/replacevehicleotpresponse.dart';
import 'package:fast_tag/pages/homeScreen.dart';
import 'package:fast_tag/utility/progressdialog.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

import '../api/network/create_json.dart';
import '../api/network/network.dart';
import '../api/network/uri.dart';
import '../api/response/replacevehicleresponse.dart';
import '../utility/colorfile.dart';
import '../utility/snackbardesign.dart';

class ReplaceOtpPage extends StatefulWidget {
  String sessionId,
      requestId,
      vehiclenumber,
      mobilenumber,
      barcode,
      reason,
      resondescription,
      ischasisselected,
      chasisnumber,
      enginenumber,
      stateOfRegistration;

  ReplaceOtpPage(
      this.sessionId,
      this.requestId,
      this.vehiclenumber,
      this.mobilenumber,
      this.barcode,
      this.reason,
      this.resondescription,
      this.ischasisselected,
      this.chasisnumber,
      this.enginenumber,
      this.stateOfRegistration);

  @override
  _ReplaceOtpPageState createState() => _ReplaceOtpPageState();
}

class _ReplaceOtpPageState extends State<ReplaceOtpPage> {
  List<TextEditingController> _controllers =
      List.generate(6, (index) => TextEditingController());

  int secondsRemaining = 300;
  bool enableResend = false;
  Timer? timer;
  TextEditingController otpController = TextEditingController();
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(Duration(seconds: 1), (_) {
      if (secondsRemaining != 0) {
        setState(() {
          secondsRemaining--;
        });
      } else {
        setState(() {
          enableResend = true;
        });
      }
    });
  }

  String formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    String minutesStr = minutes.toString().padLeft(2, '0');
    String secondsStr = remainingSeconds.toString().padLeft(2, '0');
    return '$minutesStr:$secondsStr';
  }

  @override
  void dispose() {
    timer!.cancel();
    super.dispose();
  }

  // succesPOpup
  void _showConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Container(
            width: double.infinity, // Cover full width
            height: 400, // Set a fixed height as needed

            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'images/succes.png', // Replace with the actual path to your image asset
                    width: 200, // Set image width as needed
                    height: 200, // Set image height as needed
                  ),
                  SizedBox(height: 20), // Space between image and text
                  Text(
                    'Activation Successful',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                  SizedBox(height: 5),

                  Text(
                    'Your account is ready to use. You will\n be redirected to the Home page in\n a few seconds.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );

    // Delay redirecting to the home screen for 5 seconds
    Future.delayed(Duration(seconds: 5), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => MyDashboard()),
      );
    });
  }

//rejection popup
  void _showRejectionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Container(
            width: double.infinity, // Cover full width
            height: 400, // Set a fixed height as needed

            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'images/sad.png', // Replace with the actual path to your image asset
                    width: 200, // Set image width as needed
                    height: 200, // Set image height as needed
                  ),
                  // SizedBox(height: 5), // Space between image and text
                  Text(
                    'Tag Replacement',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                  SizedBox(height: 5),

                  Text(
                    'Your tag replace successfully',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );

    // Delay redirecting to the home screen for 5 seconds
    Future.delayed(Duration(seconds: 5), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => MyDashboard()),
      );
    });
  }

  Widget _buildTextField(int index) {
    return SizedBox(
      width: 50,
      height: 45,
      child: TextField(
        controller: _controllers[index],
        keyboardType: TextInputType.number,
        maxLength: 1,
        textAlign: TextAlign.center,
        decoration: InputDecoration(
          counterText: "",
          border: OutlineInputBorder(),
        ),
        onChanged: (String value) {
          if (value.length == 1 && index < 5) {
            FocusScope.of(context).nextFocus();
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'OTP Verification',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            flex: 4,
            child: Center(
              child: Image.asset(
                'images/assignOtp.png',
                height: 400,
              ),
            ),
          ),
          Expanded(
            flex: 5,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 30.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'OTP Verification',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 25,
                    ),
                  ),
                  SizedBox(height: 5),
                  Container(
                    width: MediaQuery.of(context).size.width * 0.8,
                    child: RichText(
                      text: TextSpan(
                        text:
                            'Please enter the 6 digit security code we just sent you at  ',
                        style: TextStyle(
                          color: Color(0xffA1A8B0),
                          fontWeight: FontWeight.w400,
                          fontSize: 14,
                        ),
                        children: <TextSpan>[
                          TextSpan(
                            text: widget.mobilenumber.replaceRange(
                              0,
                              widget.mobilenumber.length - 4,
                              'X' * (widget.mobilenumber.length - 2),
                            ),
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                              color: Color(0xff101623),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 30),

                  // Row(
                  //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  //   children:
                  //       List.generate(6, (index) => _buildTextField(index)),
                  // ),
                  PinCodeTextField(
                    controller: otpController,
                    length: 6,
                    onChanged: (value) {},
                    appContext: context,
                    keyboardType: TextInputType.number,
                    onCompleted: (value) {
                      // validateOTP(value);
                    },
                    pinTheme: PinTheme(
                        shape: PinCodeFieldShape.box,
                        borderRadius: BorderRadius.circular(5),
                        fieldHeight: 50,
                        fieldWidth: 50,
                        selectedColor: Color(0xFF0056D0),
                        activeColor: Color(0xFF0056D0),
                        inactiveColor: Colors.grey),
                  ),
                  SizedBox(height: 10.0),
                  if (errorMessage.isNotEmpty)
                    Text(
                      errorMessage,
                      style: TextStyle(color: Colors.red),
                    ),

                  SizedBox(height: 10),
                  enableResend
                      ? SizedBox(
                          height: 70,
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {},
                            style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all<Color>(
                                Color(0xFF0056D0).withOpacity(0.4),
                              ),
                              shape: MaterialStateProperty.all<
                                  RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5.0),
                                ),
                              ),
                            ),
                            child: Container(
                              height: 70,
                              width: double.infinity,
                              child: Center(
                                child: Text(
                                  'Verify',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18.0,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        )
                      : SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              if (_controllers.isEmpty) {
                                SnackBarDesign(
                                    "Please enter OTP",
                                    context,
                                    colorfile().errormessagebcColor,
                                    colorfile().errormessagetxColor);
                              } else {
                                Networkcallforverifyotp();
                              }
                            },
                            style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all<Color>(
                                Color(0xFF0056D0),
                              ),
                              shape: MaterialStateProperty.all<
                                  RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5.0),
                                ),
                              ),
                            ),
                            child: Container(
                              width: double.infinity,
                              child: Center(
                                child: Text(
                                  'Verify',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18.0,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                  SizedBox(height: 10),
                  Center(
                    child: Text(
                      // 'Resend in $_resendTimer Sec',
                      'Resend in ${formatTime(secondsRemaining)} Sec',
                      style: TextStyle(
                        color: Colors.blue,
                        fontSize: 15,
                      ),
                    ),
                  ),
                  // SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
          color: Theme.of(context).scaffoldBackgroundColor,
          child: Container(
              alignment: Alignment.center,
              child: RichText(
                  text: TextSpan(
                      text: 'Didn’t receive the code? ',
                      style: TextStyle(
                          color: Color(0xff717784),
                          fontSize: 15,
                          fontWeight: FontWeight.w400),
                      children: <TextSpan>[
                    TextSpan(
                        text: "Resend ",
                        style: TextStyle(
                          color: Colors.blue,
                          fontSize: 16.0,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            Networkcallforresendotp();
                          })
                  ])))),
    );
  }

  Future<void> Networkcallforverifyotp() async {
    try {
      String abc = otpController.text;
      for (var element in _controllers) {
        abc = abc + element.text;
      }
      print(abc);
      ProgressDialog.showProgressDialog(context, "");
      String assignfaasttag = createjson().createjsonforverifyreplaceotp(
          otpController.text,
          widget.requestId,
          widget.sessionId,
          widget.vehiclenumber,
          context);
      List<Object?>? list = await NetworkCall().postMethod(
          URLS().rep_validate_otp_bajaj,
          URLS().rep_validate_otp_bajaj_url,
          assignfaasttag,
          context);
      if (list != null) {
        Navigator.pop(context);
        List<Replacevehicleotpresponse> response = List.from(list!);
        if (response[0].data!.isNotEmpty) {
          String status = response[0].data![0].response!.status!;
          switch (status) {
            case "success":
              // SnackBarDesign(
              //     "Tag replace successfully!!",
              //     context,
              //     colorfile().sucessmessagebcColor,
              //     colorfile().sucessmessagetxColor);
              _showConfirmationDialog(context);
              break;
            case "failed":
              SnackBarDesign(
                  response[0].data![0].response!.msg!,
                  context,
                  colorfile().errormessagebcColor,
                  colorfile().errormessagetxColor);
              break;
          }
        } else {
          Navigator.pop(context);
          SnackBarDesign(response[0].message!, context,
              colorfile().errormessagebcColor, colorfile().errormessagetxColor);
        }
      } else {
        Navigator.pop(context);
        SomethingWentWrongSnackBarDesign(context);
      }
    } catch (e) {
      print(e.toString());
    }
  }

  Future<void> Networkcallforresendotp() async {
    try {
      setState(() {
        secondsRemaining = 120;
        enableResend = false;
      });
      ProgressDialog.showProgressDialog(context, "");
      String assignfaasttag =
          createjson().createjsonforgenerateotpforreplacevehicle(
              widget.mobilenumber,
              widget.vehiclenumber,
              widget.barcode,
              widget.reason,
              widget.resondescription,
              widget.ischasisselected,
              widget.chasisnumber,
              // widget.enginenumber,
              // widget.stateOfRegistration,
              context);
      List<Object?>? list = await NetworkCall().postMethod(
          URLS().rep_generate_otp_by_vehicle,
          URLS().rep_generate_otp_by_vehicle_url,
          assignfaasttag,
          context);

      if (list != null) {
        Navigator.pop(context);
        List<Replacevehicleresponse> response = List.from(list!);
        String status = response[0].status!;
        switch (status) {
          case "true":
            widget.requestId = response[0].data![0].requestId!;
            widget.sessionId = response[0].data![0].sessionId!;
            setState(() {});
            SnackBarDesign(
                "OTP send successfully!!",
                context,
                colorfile().sucessmessagebcColor,
                colorfile().sucessmessagetxColor);

            break;
          case "false":
            SnackBarDesign(
                "Unable to send OTP , Please try again",
                context,
                colorfile().errormessagebcColor,
                colorfile().errormessagetxColor);
            break;
        }
      } else {
        Navigator.pop(context);
        SomethingWentWrongSnackBarDesign(context);
      }
    } catch (e) {
      print(e.toString());
    }
  }
}
