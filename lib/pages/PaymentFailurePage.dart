import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'recharge.dart';

class FailedPaymentPage extends StatelessWidget {
  final String? transactionId;

  const FailedPaymentPage({Key? key, this.transactionId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async {
          // Navigate to WalletPage when system back button is pressed
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => RechargePage("failurepage"),
            ),
            // (Route<dynamic> route) => false,
          );
          return false; // Prevent default back button action
        },
        child: Scaffold(
          extendBodyBehindAppBar: true,
          backgroundColor: Colors.white,
          appBar: AppBar(
            title: Text(
              'Payment Failed',
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w600,
                color: Color(0xFF1D2024),
                fontSize: 18,
              ),
            ),
            backgroundColor: Colors.white,
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Failed Payment Icon
                Center(
                  child: Icon(
                    Icons.error_outline,
                    color: Colors.redAccent,
                    size: 100,
                  ),
                ),
                SizedBox(height: 20),
                // Animated Error Message
                AnimatedTextKit(
                  animatedTexts: [
                    TypewriterAnimatedText(
                      'Oops! Your payment failed.',
                      textStyle: TextStyle(
                        fontSize: 28.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                      speed: const Duration(milliseconds: 100),
                    ),
                  ],
                  isRepeatingAnimation: false,
                  totalRepeatCount: 1,
                ),
                SizedBox(height: 20),
                // Additional details text
                Text(
                  'We couldn\'t process your transaction at this time. Please try again later.',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.black54,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 20),
                // Display Transaction ID if provided
                if (transactionId != null)
                  Center(
                    child: Text(
                      'Transaction ID: $transactionId',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black45,
                      ),
                    ),
                  ),
                SizedBox(height: 30),
                // Retry Button
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF0056D1),
                    padding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                  ),
                  icon: Icon(Icons.refresh, color: Colors.white),
                  label: Text(
                    'Retry Payment',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  onPressed: () {
                    // Handle retry payment logic here
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                        builder: (context) => RechargePage("failurepage"),
                      ),
                      (Route<dynamic> route) => false,
                    );
                  },
                ),
                SizedBox(height: 10),
                // Contact Support Button
                // OutlinedButton.icon(
                //   style: OutlinedButton.styleFrom(
                //     side: BorderSide(color: Colors.redAccent, width: 2),
                //     padding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                //     shape: RoundedRectangleBorder(
                //       borderRadius: BorderRadius.circular(30.0),
                //     ),
                //   ),
                //   icon: Icon(Icons.contact_support, color: Colors.redAccent),
                //   label: Text(
                //     'Contact Support',
                //     style: TextStyle(
                //       fontSize: 18,
                //       fontWeight: FontWeight.bold,
                //       color: Colors.redAccent,
                //     ),
                //   ),
                //   onPressed: () {
                //     // Handle contact support logic here
                //   },
                // ),
              ],
            ),
          ),
        ));
  }
}
