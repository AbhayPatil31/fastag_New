package com.example.fast_tag

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.example.fast_tag/payment"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "startPayment") {
                val encRequest = call.argument<String>("encRequest")
                val accessCode = call.argument<String>("accessCode")
                if (encRequest != null && accessCode != null) {
                    startPayment(encRequest, accessCode)
                    result.success("Payment started")
                } else {
                    result.error("INVALID_ARGUMENT", "encRequest or accessCode not provided", null)
                }
            } else {
                result.notImplemented()
            }
        }
    }

    private fun startPayment(encRequest: String, accessCode: String) {
        // Initialize and configure CCAvenue payment
        // Replace this with actual SDK code
        // Example:
        // val ccaVenue = CCAvenue(this)
        // ccaVenue.setEncryptedRequest(encRequest)
        // ccaVenue.setAccessCode(accessCode)
        // ccaVenue.setCallback(object : CCAvenueCallback {
        //     override fun onSuccess(response: String) {
        //         // Handle success
        //     }
        //
        //     override fun onFailure(error: String) {
        //         // Handle failure
        //     }
        // })
        // ccaVenue.startPayment()
    }
}
