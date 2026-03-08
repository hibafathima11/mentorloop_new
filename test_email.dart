import 'lib/utils/email_service.dart';

void main() async {
  try {
    await EmailService.sendEmail(
      templateParams: {
        'to_email': 'test@example.com',
        'subject': 'Test Subject',
        'name': 'Test Name',
        'time': '12:00',
        'message': 'Test Message',
      },
    );
    print('Email sent successfully!');
  } catch (e) {
    print('Error: $e');
  }
}
