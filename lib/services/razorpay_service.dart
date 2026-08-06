import 'dart:async';
import 'package:flutter/material.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

class RazorpayResult {
  final String paymentId;
  final String? orderId;
  final String? signature;

  RazorpayResult({
    required this.paymentId,
    this.orderId,
    this.signature,
  });
}
class RazorpayService {
  static const String _key = 'rzp_test_T300832ARbr1G9'; // Replace with your Razorpay key

  static Future<RazorpayResult?> openCheckout({
    required double amountInINR,
    required String receiptId,
    required BuildContext context,
    String? contact,
    String? email,
  }) {
    final completer = Completer<RazorpayResult?>();

    final razorpay = Razorpay();
    razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, (response) {
      razorpay.clear();
      final result = response as PaymentSuccessResponse;
      completer.complete(RazorpayResult(
        paymentId: result.paymentId ?? '',
        orderId: result.orderId,
        signature: result.signature,
      ));
    });
    razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, (response) {
      razorpay.clear();
      final result = response as PaymentFailureResponse;
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.message ?? 'Payment failed'),
            backgroundColor: Colors.red.shade700,
          ),
        );
      }
      completer.complete(null);
    });
    razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, (response) {
      razorpay.clear();
      completer.complete(null);
    });

    final options = {
      'key': _key,
      'amount': (amountInINR * 100).round(), // paise
      'name': 'thStyle',
      'description': 'Order Payment',
      'receipt': receiptId,
      'prefill': {
        'contact': contact ?? '',
        'email': email ?? '',
      },
      'theme': {'color': '#0A0A0A'},
    };

    try {
      razorpay.open(options);
    } catch (e) {
      razorpay.clear();
      completer.complete(null);
    }

    return completer.future;
  }
}
