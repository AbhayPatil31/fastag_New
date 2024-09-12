import 'package:flutter/material.dart';

import 'wallet.dart';

class ThankYouPage extends StatelessWidget {
  final String? orderId;
  final String? trackingId;

  ThankYouPage({this.orderId, this.trackingId});

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Navigate to WalletPage when system back button is pressed
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (context) => WalletPage(),
          ),
          (Route<dynamic> route) => false,
        );
        return false; // Prevent default back button action
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('Thank You!'),
          backgroundColor: Colors.green,
          centerTitle: true,
          automaticallyImplyLeading: false,
        ),
        body: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: 30),
              _buildSuccessIcon(),
              SizedBox(height: 20),
              _buildThankYouText(),
              SizedBox(height: 15),
              _buildSuccessMessage(),
              SizedBox(height: 30),
              _buildOrderDetails(trackingId!),
              Spacer(),
              // _buildTrackOrderButton(context),
              _buildBackToHomeButton(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSuccessIcon() {
    return Icon(
      Icons.check_circle,
      color: Colors.green,
      size: 100,
    );
  }

  Widget _buildThankYouText() {
    return Text(
      'Thank You!',
      textAlign: TextAlign.center,
      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
    );
  }

  Widget _buildSuccessMessage() {
    return Text(
      'Your order has been placed successfully.',
      textAlign: TextAlign.center,
    );
  }

  Widget _buildOrderDetails(String trackingId) {
    return Column(
      children: [
        // Text('Order ID: $orderId'),
        Text('Tracking ID: $trackingId'),
      ],
    );
  }

  // Widget _buildTrackOrderButton(BuildContext context) {
  //   return ElevatedButton(
  //     onPressed: () {
  //       // Navigate to track order page
  //     },
  //     child: Text('Track Order'),
  //   );
  // }

  Widget _buildBackToHomeButton(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => WalletPage(),
          ),
        );
      },
      child: Text('Back to Wallet'),
    );
  }
}

Widget _buildSuccessIcon() {
  return Center(
    child: Icon(
      Icons.check_circle_outline,
      color: Colors.green,
      size: 100,
    ),
  );
}

Widget _buildThankYouText() {
  return Center(
    child: Text(
      "Thank You!",
      style: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: Colors.black,
      ),
    ),
  );
}

Widget _buildSuccessMessage() {
  return Center(
    child: Text(
      "Your Fastag has been successfully activated and the order is confirmed.",
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: 18,
        color: Colors.black87,
      ),
    ),
  );
}

Widget _buildOrderDetails(String orderId, String trackingId) {
  return Container(
    padding: EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.grey[200],
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: Colors.grey[300]!),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Order Details",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 10),
        _buildDetailRow("Order ID:", orderId),
        SizedBox(height: 5),
        // _buildDetailRow("Tracking ID:", trackingId),
        SizedBox(height: 5),
        _buildDetailRow("Status:", "Activated & Confirmed"),
      ],
    ),
  );
}

Widget _buildDetailRow(String label, String value) {
  return Row(
    children: [
      Text(
        label,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
      SizedBox(width: 10),
      Expanded(
        child: Text(
          value,
          style: TextStyle(
            fontSize: 16,
            color: Colors.black54,
          ),
        ),
      ),
    ],
  );
}

// Widget _buildTrackOrderButton(BuildContext context) {
//   return ElevatedButton(
//     onPressed: () {
//       // Navigate to tracking page (if available)
//       // Navigator.push(
//       //   context,
//       //   MaterialPageRoute(
//       //     builder: (context) => OrderTrackingPage(orderId: orderId), // Example page
//       //   ),
//       // );
//     },
//     style: ElevatedButton.styleFrom(
//       padding: EdgeInsets.symmetric(vertical: 15),
//       backgroundColor: Colors.green, // Button color
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(8),
//       ),
//     ),
//     child: Text(
//       "Track My Order",
//       style: TextStyle(
//         fontSize: 18,
//         color: Colors.white,
//       ),
//     ),
//   );
// }

Widget _buildBackToHomeButton(BuildContext context) {
  return TextButton(
    onPressed: () {
      // Navigate to WalletPage when back button is pressed
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => WalletPage(),
        ),
      );
    },
    child: Text(
      "Back to Home",
      style: TextStyle(
        fontSize: 18,
        color: Colors.green,
      ),
    ),
  );
}
