import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import '../colors/colors.dart';
import 'dart:convert';

class ForecastEmailRegister extends StatelessWidget {
  const ForecastEmailRegister({Key? key}) : super(key: key);

  void _showEmailForm(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Subscribe to Forecast Emails'),
          content: EmailSubscriptionForm(),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () => _showEmailForm(context),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.blue,
        padding: const EdgeInsets.symmetric(vertical: 20),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.email, color: AppColors.white, size: 24),
          SizedBox(width: 8),
          Text(
            'Forecast Email Register',
            style: TextStyle(
              color: AppColors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class EmailSubscriptionForm extends StatelessWidget {
  final TextEditingController _emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TextField(
          controller: _emailController,
          decoration: const InputDecoration(
            labelText: 'Enter your email',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 10),
        ElevatedButton(
          onPressed: () async {
            await _registerEmail(_emailController.text);
            Navigator.of(context).pop();
          },
          child: const Text('Subscribe'),
        ),
      ],
    );
  }

  Future<void> _registerEmail(String email) async {
    try {
      // Lưu email vào Firestore
      await FirebaseFirestore.instance.collection('subscriptions').add({
        'email': email,
        'confirmed': false,
      });

      // Gửi email xác nhận sử dụng EmailJS
      await _sendConfirmationEmail(email);
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> _sendConfirmationEmail(String recipientEmail) async {
    final url = Uri.parse('https://api.emailjs.com/api/v1.0/email/send');
    
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'service_id': 'service_wdqvvgf',
        'template_id': 'template_pqjoopy',
        'user_id': 'gcykNkQfMqZT3QDd3',
        'template_params': {
          'to_email': recipientEmail,
        }
      }),
    );

    if (response.statusCode != 200) {
      print('Error sending email: ${response.body}');
      throw Exception('Failed to send email');
    }
    
    print('Email sent successfully');
  }
} 