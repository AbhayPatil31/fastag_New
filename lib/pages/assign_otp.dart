import 'dart:async';
import 'package:fast_tag/api/response/validateotpresponse.dart';
import 'package:fast_tag/pages/assign_customer_details.dart';
import 'package:fast_tag/pages/setvehicledetails.dart';
import 'package:fast_tag/utility/progressdialog.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

import '../api/network/create_json.dart';
import '../api/network/network.dart';
import '../api/network/uri.dart';
import '../api/response/assignfasttagresponse.dart';
import '../utility/colorfile.dart';
import '../utility/snackbardesign.dart';
import 'wallet.dart';

class AssignOtpPage extends StatefulWidget {
  String requestId,
      sessionId,
      mobilenumber,
      vehicalenumber,
      ischasis,
      chassisnumber,
      enginenumber;
  AssignOtpPage(
      this.requestId,
      this.sessionId,
      this.mobilenumber,
      this.vehicalenumber,
      this.ischasis,
      this.chassisnumber,
      this.enginenumber);

  @override
  _AssignOtpPageState createState() => _AssignOtpPageState();
}

class _AssignOtpPageState extends State<AssignOtpPage> {
  List<TextEditingController> _controllers =
      List.generate(6, (index) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (index) => FocusNode());

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
    _focusNodes.forEach((focusNode) => focusNode.dispose());

    super.dispose();
  }

  Widget _buildTextField(int index) {
    return SizedBox(
      width: 50,
      height: 45,
      child: TextField(
        controller: _controllers[index],
        focusNode: _focusNodes[index],
        keyboardType: TextInputType.number,
        maxLength: 1,
        textAlign: TextAlign.center,
        decoration: InputDecoration(
          contentPadding: EdgeInsets.symmetric(vertical: 10.0),
          counterText: "",
          border: OutlineInputBorder(),
        ),
        onChanged: (String value) {
          if (value.length == 1) {
            if (index < 5) {
              _focusNodes[index].unfocus();
              FocusScope.of(context).requestFocus(_focusNodes[index + 1]);
            }
          } else if (value.isEmpty && index > 0) {
            _focusNodes[index].unfocus();
            FocusScope.of(context).requestFocus(_focusNodes[index - 1]);
          }
        },
      ),
    );
  }

  Widget _buildTextField1(int index) {
    return SizedBox(
      width: 50,
      height: 45,
      child: TextField(
        controller: _controllers[index],
        focusNode: _focusNodes[index],
        keyboardType: TextInputType.number,
        maxLength: 1,
        textAlign: TextAlign.center,
        decoration: InputDecoration(
          alignLabelWithHint: true,
          contentPadding:
              EdgeInsets.symmetric(vertical: 10.0, horizontal: 12.0),
          counterText: "",
          border: OutlineInputBorder(),
        ),
        onChanged: (String value) {
          if (value.length == 1) {
            if (index < 5) {
              _focusNodes[index].unfocus();
              FocusScope.of(context).requestFocus(_focusNodes[index + 1]);
            }
          } else if (value.isEmpty) {
            if (index > 0) {
              _focusNodes[index].unfocus();
              FocusScope.of(context).requestFocus(_focusNodes[index - 1]);
            }
          }
        },
        onSubmitted: (String value) {
          if (value.length == 1 && index < 5) {
            FocusScope.of(context).requestFocus(_focusNodes[index + 1]);
          } else if (value.isEmpty && index > 0) {
            FocusScope.of(context).requestFocus(_focusNodes[index - 1]);
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        // forceMaterialTransparency: true,
        title: Text('OTP Verification',
            style: GoogleFonts.inter(
              fontWeight: FontWeight.w600,
              color: Color(0xFF1D2024),
              fontSize: 18,
            )),
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
                  Text('OTP Verification',
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF1D2024),
                        fontSize: 20,
                      )),
                  SizedBox(height: 5),
                  Container(
                    width: MediaQuery.of(context).size.width * 0.8,
                    child: RichText(
                      text: TextSpan(
                        text:
                            'Please enter the 6 digit security code we just sent you at ',
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
                  SizedBox(height: 20.0),
                  if (errorMessage.isNotEmpty)
                    Text(
                      errorMessage,
                      style: TextStyle(color: Colors.red),
                    ),
                  SizedBox(height: 20),
                  enableResend
                      ? SizedBox(
                          height: 60,
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
                          height: 60,
                          width: double.infinity,
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Color(0xFF08469D),
                                  Color(0xFF0056D0),
                                  Color(0xFF0C92DD),
                                ],
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                              ),
                              borderRadius: BorderRadius.circular(5.0),
                            ),
                            child: ElevatedButton(
                              onPressed: () {
                                // if (_controllers.isEmpty) {
                                //   SnackBarDesign(
                                //       "Please enter OTP",
                                //       context,
                                //       colorfile().errormessagebcColor,
                                //       colorfile().errormessagetxColor);
                                // } else {
                                //   Networkcallforverifyotp();
                                // }
                                validateOTP(otpController.text);
                              },
                              style: ButtonStyle(
                                backgroundColor:
                                    MaterialStateProperty.all<Color>(
                                  Colors.transparent,
                                ),
                                shadowColor: MaterialStateProperty.all<Color>(
                                    Colors.transparent),
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
                  SizedBox(height: 20),
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

  void validateOTP(String otp) {
    setState(() {
      if (otp.isEmpty) {
        errorMessage = 'Please enter OTP';
      } else if (otp.length != 6) {
        errorMessage = 'OTP must be exactly 6 digits';
      } else {
        errorMessage = '';
        Networkcallforverifyotp();
      }
    });
  }

  Future<void> Networkcallforverifyotp() async {
    try {
      ProgressDialog.showProgressDialog(context, " title");
      String abc = otpController.text;
      for (var element in _controllers) {
        abc = abc + element.text;
      }
      print(abc);
      String assignfaasttag = createjson().createjsonforverifyotp(abc,
          widget.requestId, widget.sessionId, widget.vehicalenumber, context);
      List<Object?>? list = await NetworkCall().postMethod(
          URLS().validate_otp_bajaj,
          URLS().validate_otp_bajaj_url,
          assignfaasttag,
          context);
      if (list != null) {
        Navigator.pop(context);
        List<Verifyotpresponse> response = List.from(list!);
        String status = response[0].status!;

        switch (status) {
          case "true":
            SnackBarDesign(
                "OTP verify successfully!!",
                context,
                colorfile().sucessmessagebcColor,
                colorfile().sucessmessagetxColor);
            List<VerifyotpDatum> otpverifydata = response[0].data!;
            if (otpverifydata[0].engineNo == null ||
                otpverifydata[0].engineNo == "" ||
                otpverifydata[0].isNationalPermit == null ||
                otpverifydata[0].isNationalPermit == "" ||
                otpverifydata[0].stateOfRegistration == null ||
                otpverifydata[0].stateOfRegistration == "" ||
                otpverifydata[0].vehicleDescriptor == null ||
                otpverifydata[0].vehicleDescriptor == "" ||
                (otpverifydata[0].isNationalPermit == "1" &&
                    otpverifydata[0].permitExpiryDate == "")) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SetVehicleDetails(
                      widget.sessionId,
                      widget.vehicalenumber,
                      otpverifydata[0].stateOfRegistration! ?? '',
                      otpverifydata[0].vehicleDescriptor! ?? '',
                      otpverifydata[0].isNationalPermit! ?? '',
                      otpverifydata[0].permitExpiryDate! ?? ''),
                ),
              );
            } else {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CustomerDetailsPage(
                      widget.vehicalenumber, widget.sessionId),
                ),
              );
            }
            break;
          case "false":
            if (response[0].message ==
                "Insufficient wallet balance. Please recharge to continue.") {
              SnackBarDesign(
                  response[0].message!,
                  context,
                  colorfile().errormessagebcColor,
                  colorfile().errormessagetxColor);
              Navigator.push(context, MaterialPageRoute(
                builder: (context) {
                  return WalletPage();
                },
              ));
            } else if (response[0].message ==
                "Low wallet amount, please recharge to proceed") {
              SnackBarDesign(
                  response[0].message!,
                  context,
                  colorfile().errormessagebcColor,
                  colorfile().errormessagetxColor);
              Navigator.push(context, MaterialPageRoute(
                builder: (context) {
                  return WalletPage();
                },
              ));
            } else {
              SnackBarDesign(
                  response[0].message!,
                  context,
                  colorfile().errormessagebcColor,
                  colorfile().errormessagetxColor);
            }
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

  Future<void> Networkcallforresendotp() async {
    try {
      otpController.clear();
      ProgressDialog.showProgressDialog(context, "title");
      setState(() {
        secondsRemaining = 120;
        enableResend = false;
      });
      String assignfaasttag = createjson().createjsonforassignfasttag(
        widget.vehicalenumber,
        widget.mobilenumber,
        "0",
        widget.chassisnumber,
        // widget.enginenumber
      );
      List<Object?>? list = await NetworkCall().postMethod(
          URLS().generate_otp_by_vehicle,
          URLS().generate_otp_by_vehicle_url,
          assignfaasttag,
          context);
      if (list != null) {
        Navigator.pop(context);
        List<Assignvehicleresponse> response = List.from(list!);
        String status = response[0].status!;
        switch (status) {
          case "true":
            widget.requestId = response[0].data![0].requestId!;
            widget.sessionId = response[0].data![0].sessionId!;
            setState(() {});
            SnackBarDesign(
                "OTP send on your mobile number",
                context,
                colorfile().sucessmessagebcColor,
                colorfile().sucessmessagetxColor);

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
        Navigator.pop(context);
        SomethingWentWrongSnackBarDesign(context);
      }
    } catch (e) {
      print(e.toString());
    }
  }
}
