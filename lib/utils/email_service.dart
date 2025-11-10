import 'dart:convert';
import 'package:http/http.dart' as http;

class EmailService {
  EmailService._();

  // TODO: Configure your EmailJS details
  static const String emailJsServiceId = 'service_gwxddnn';
  static const String emailJsTemplateId = 'template_sc4t9ef';
  static const String emailJsPublicKey = '7hMyWbrQuAyzrge0n';

  // templateParams must match your EmailJS template variables
  static Future<void> sendEmail({
    required Map<String, dynamic> templateParams,
  }) async {
    // Validate EmailJS configuration - check if still using placeholder values
    if (emailJsServiceId == 'YOUR_EMAILJS_SERVICE_ID' ||
        emailJsTemplateId == 'YOUR_EMAILJS_TEMPLATE_ID' ||
        emailJsPublicKey == 'YOUR_EMAILJS_PUBLIC_KEY' ||
        emailJsServiceId.isEmpty ||
        emailJsTemplateId.isEmpty ||
        emailJsPublicKey.isEmpty) {
      throw Exception(
        'EmailJS not configured. Please set up EmailJS credentials in email_service.dart',
      );
    }

    final uri = Uri.parse('https://api.emailjs.com/api/v1.0/email/send');
    final payload = {
      'service_id': emailJsServiceId,
      'template_id': emailJsTemplateId,
      'user_id': emailJsPublicKey,
      'template_params': templateParams,
    };

    try {
      final res = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(payload),
      );

      // Log response for debugging
      print('EmailJS Response Status: ${res.statusCode}');
      print('EmailJS Response Body: ${res.body}');
      print('EmailJS Request Payload: ${jsonEncode(payload)}');

      if (res.statusCode < 200 || res.statusCode >= 300) {
        // Parse error response for better error message
        String errorMessage = 'Email send failed: ${res.statusCode}';
        try {
          final errorBody = jsonDecode(res.body);
          if (errorBody is Map) {
            if (errorBody.containsKey('text')) {
              errorMessage += ' - ${errorBody['text']}';
            } else if (errorBody.containsKey('message')) {
              errorMessage += ' - ${errorBody['message']}';
            } else if (errorBody.containsKey('error')) {
              errorMessage += ' - ${errorBody['error']}';
            } else {
              errorMessage += ' - ${res.body}';
            }
          } else {
            errorMessage += ' - ${res.body}';
          }
        } catch (_) {
          errorMessage += ' - ${res.body}';
        }

        // Special handling for 422 errors
        if (res.statusCode == 422) {
          errorMessage += '\n\n422 Error usually means:\n';
          errorMessage += '- Template variables don\'t match\n';
          errorMessage += '- Missing required template variables\n';
          errorMessage += '- Invalid template parameter format\n';
          errorMessage +=
              'Check your EmailJS template variables match what we\'re sending.';
        }

        throw Exception(errorMessage);
      }

      // Check if response indicates success
      try {
        final responseBody = jsonDecode(res.body);
        if (responseBody is Map) {
          // EmailJS returns status 200 even if there are issues
          // Check for any warnings or errors in the response
          if (responseBody.containsKey('error')) {
            throw Exception('EmailJS error: ${responseBody['error']}');
          }
        }
      } catch (e) {
        // If parsing fails, but status is 200, assume success
        // EmailJS might return plain text success message
      }
    } catch (e) {
      // Re-throw with more context if it's not already an Exception
      if (e is Exception) {
        rethrow;
      }
      throw Exception('Email service error: $e');
    }
  }
}
