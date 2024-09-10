package com.example.fast_tag

import android.app.Activity
import android.content.Intent
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import com.ccavenue.sdk.CCAvenue
import com.ccavenue.sdk.CCAvenueConfig

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.example.fast_tag/payment"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "startPayment") {
                val encRequest = call.argument<String>("encRequest")
                val accessCode = call.argument<String>("accessCode")
                if (encRequest != null && accessCode != null) {
                    startPayment(encRequest, accessCode, result)
                } else {
                    result.error("INVALID_ARGUMENT", "encRequest or accessCode not provided", null)
                }
            } else {
                result.notImplemented()
            }
        }
    }

    private fun startPayment(encRequest: String, accessCode: String, result: MethodChannel.Result) {
        // Configure CCAvenue SDK
        val ccaVenueConfig = CCAvenueConfig.Builder()
            .setAccessCode(accessCode)
            .setEncRequest(encRequest)
            .build()

        val ccaVenue = CCAvenue(ccaVenueConfig)
        ccaVenue.startPayment(this, object : CCAvenue.PaymentListener {
            override fun onPaymentSuccess(response: String) {
                // Return success result to Flutter
                MethodChannel(flutterEngine?.dartExecutor?.binaryMessenger, CHANNEL)
                    .invokeMethod("paymentResult", response)
            }

            override fun onPaymentFailure(error: String) {
                // Return failure result to Flutter
                MethodChannel(flutterEngine?.dartExecutor?.binaryMessenger, CHANNEL)
                    .invokeMethod("paymentResult", error)
            }
        })
    }
}
