import 'dart:convert';
import 'package:fast_tag/api/response/paymenturlresponse.dart';
import 'package:http/http.dart' as http;

class UpiGatewayService {
  final String _apiUrl = 'https://api.ekqr.in/api/create_order';
  final String _apiKey =
      'a55bafeb-73b3-4019-9850-bf3f63b83b9a'; // Replace with your actual API key

  Future<Paymenturlresponse> initiatePayment(String customerName,
      String customerEmail, String customerMobile, double amount) async {
    var clientTxnId = DateTime.now()
        .millisecondsSinceEpoch
        .toString(); // Unique transaction ID

    var requestBody = {
      'key': _apiKey,
      'client_txn_id': clientTxnId,
      'amount': amount.toString(),
      'p_info': 'Online Payment',
      'customer_name': customerName,
      'customer_email': customerEmail,
      'customer_mobile': customerMobile,
      'redirect_url':
          'https://yourdomain.com/payment_success', // Replace with your redirect URL
      'udf1': '1',
      'udf2': 'extradata',
      'udf3': 'extradata',
    };

    var response = await http.post(
      Uri.parse(_apiUrl),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode(requestBody),
    );

    if (response.statusCode == 200) {
      return paymenturlresponseFromJson(response.body);
    } else {
      throw Exception('Failed to initiate payment');
    }
  }
}
