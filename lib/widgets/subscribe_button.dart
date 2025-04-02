import 'package:flutter/material.dart';
import 'subscription_form.dart';

class SubscribeButton extends StatelessWidget {
  const SubscribeButton({Key? key}) : super(key: key);

  void _showSubscriptionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Đăng ký nhận thông tin thời tiết'),
          content: const SingleChildScrollView(
            child: SubscriptionForm(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Đóng'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () => _showSubscriptionDialog(context),
      icon: const Icon(Icons.notifications_active),
      label: const Text('Đăng ký nhận thông tin'),
    );
  }
} 