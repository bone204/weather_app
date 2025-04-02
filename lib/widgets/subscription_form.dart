// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import '../services/subscription_service.dart';
import '../colors/colors.dart';

class SubscriptionForm extends StatefulWidget {
  const SubscriptionForm({Key? key}) : super(key: key);

  @override
  _SubscriptionFormState createState() => _SubscriptionFormState();
}

class _SubscriptionFormState extends State<SubscriptionForm> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _cityController = TextEditingController();
  final _subscriptionService = SubscriptionService();
  bool _isLoading = false;
  bool _isUnsubscribe = false;

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        if (_isUnsubscribe) {
          await _subscriptionService.unsubscribe(_emailController.text);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Unsubscribed successfully')),
            );
            Navigator.of(context).pop();
          }
        } else {
          await _subscriptionService.subscribe(
            _emailController.text,
            _cityController.text,
          );
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Please check your email to confirm subscription'),
              ),
            );
            Navigator.of(context).pop();
          }
        }
        _emailController.clear();
        _cityController.clear();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${e.toString()}')),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton(
                onPressed: () => setState(() => _isUnsubscribe = false),
                style: TextButton.styleFrom(
                  foregroundColor: !_isUnsubscribe ? AppColors.green : AppColors.white.withOpacity(0.7),
                ),
                child: const Text('Subscribe'),
              ),
              TextButton(
                onPressed: () => setState(() => _isUnsubscribe = true),
                style: TextButton.styleFrom(
                  foregroundColor: _isUnsubscribe ? AppColors.red : AppColors.white.withOpacity(0.7),
                ),
                child: const Text('Unsubscribe'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _emailController,
            decoration: InputDecoration(
              labelText: 'Email',
              labelStyle: TextStyle(color: AppColors.white.withOpacity(0.7)),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: AppColors.white.withOpacity(0.3)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: AppColors.white.withOpacity(0.3)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: _isUnsubscribe ? AppColors.red : AppColors.green),
              ),
              hintText: 'Enter your email',
              hintStyle: TextStyle(color: AppColors.white.withOpacity(0.3)),
              prefixIcon: Icon(Icons.email, color: AppColors.white.withOpacity(0.7)),
              filled: true,
              fillColor: AppColors.white.withOpacity(0.1),
            ),
            style: const TextStyle(color: AppColors.white),
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your email';
              }
              if (!value.contains('@')) {
                return 'Please enter a valid email';
              }
              return null;
            },
          ),
          if (!_isUnsubscribe) ...[
            const SizedBox(height: 16),
            TextFormField(
              controller: _cityController,
              decoration: InputDecoration(
                labelText: 'City',
                labelStyle: TextStyle(color: AppColors.white.withOpacity(0.7)),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: AppColors.white.withOpacity(0.3)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: AppColors.white.withOpacity(0.3)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: AppColors.green),
                ),
                hintText: 'Enter city name',
                hintStyle: TextStyle(color: AppColors.white.withOpacity(0.3)),
                prefixIcon: Icon(Icons.location_city, color: AppColors.white.withOpacity(0.7)),
                filled: true,
                fillColor: AppColors.white.withOpacity(0.1),
              ),
              style: const TextStyle(color: AppColors.white),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter city name';
                }
                return null;
              },
            ),
          ],
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _submitForm,
              style: ElevatedButton.styleFrom(
                backgroundColor: _isUnsubscribe ? AppColors.red : AppColors.green,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                disabledBackgroundColor: (_isUnsubscribe ? AppColors.red : AppColors.green).withOpacity(0.5),
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(AppColors.white),
                      ),
                    )
                  : Text(
                      _isUnsubscribe ? 'Unsubscribe' : 'Register',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.white,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _cityController.dispose();
    super.dispose();
  }
} 