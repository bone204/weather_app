import 'package:flutter/material.dart';
import 'package:cloud_functions/cloud_functions.dart';

class ConfirmSubscriptionView extends StatefulWidget {
  final String email;
  final String token;

  const ConfirmSubscriptionView({
    Key? key,
    required this.email,
    required this.token,
  }) : super(key: key);

  @override
  State<ConfirmSubscriptionView> createState() => _ConfirmSubscriptionViewState();
}

class _ConfirmSubscriptionViewState extends State<ConfirmSubscriptionView> {
  bool _isLoading = true;
  String _message = '';
  bool _isSuccess = false;

  @override
  void initState() {
    super.initState();
    _confirmSubscription();
  }

  Future<void> _confirmSubscription() async {
    try {
      final result = await FirebaseFunctions.instance
          .httpsCallable('confirmSubscription')
          .call({
        'email': widget.email,
        'token': widget.token,
      });

      setState(() {
        _isLoading = false;
        _isSuccess = result.data['success'] ?? false;
        _message = result.data['message'] ?? 'Xác nhận đăng ký thành công!';
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _isSuccess = false;
        _message = 'Có lỗi xảy ra khi xác nhận đăng ký. Vui lòng thử lại sau.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/img/bg_4.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              borderRadius: BorderRadius.circular(10),
            ),
            constraints: const BoxConstraints(maxWidth: 400),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_isLoading) ...[
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  const Text('Đang xác nhận đăng ký...'),
                ] else ...[
                  Icon(
                    _isSuccess ? Icons.check_circle : Icons.error,
                    color: _isSuccess ? Colors.green : Colors.red,
                    size: 64,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _message,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pushReplacementNamed('/');
                    },
                    child: const Text('Quay về trang chủ'),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
} 