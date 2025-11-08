import 'dart:convert';
import 'package:http/http.dart' as http;

class EmailService {
  EmailService._();

  // TODO: Configure your EmailJS details
  static const String emailJsServiceId = 'YOUR_EMAILJS_SERVICE_ID';
  static const String emailJsTemplateId = 'YOUR_EMAILJS_TEMPLATE_ID';
  static const String emailJsPublicKey = 'YOUR_EMAILJS_PUBLIC_KEY';

  // templateParams must match your EmailJS template variables
  static Future<void> sendEmail({
    required Map<String, dynamic> templateParams,
  }) async {
    final uri = Uri.parse('https://api.emailjs.com/api/v1.0/email/send');
    final payload = {
      'service_id': emailJsServiceId,
      'template_id': emailJsTemplateId,
      'user_id': emailJsPublicKey,
      'template_params': templateParams,
    };

    final res = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(payload),
    );

    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception('Email send failed: ${res.statusCode} ${res.body}');
    }
  }
}
