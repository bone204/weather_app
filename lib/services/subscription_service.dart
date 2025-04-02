import 'package:cloud_functions/cloud_functions.dart';

class SubscriptionService {
  final FirebaseFunctions _functions = FirebaseFunctions.instance;

  Future<void> subscribe(String email, String city) async {
    try {
      await _functions.httpsCallable('subscribeToWeather').call({
        'email': email,
        'city': city,
      });
    } catch (e) {
      throw Exception('Failed to subscribe: $e');
    }
  }

  Future<void> unsubscribe(String email) async {
    try {
      await _functions.httpsCallable('unsubscribeFromWeather').call({
        'email': email,
      });
    } catch (e) {
      throw Exception('Failed to unsubscribe: $e');
    }
  }

  Future<void> confirmSubscription(String email, String token) async {
    try {
      await _functions.httpsCallable('confirmSubscription').call({
        'email': email,
        'token': token,
      });
    } catch (e) {
      throw Exception('Failed to confirm subscription: $e');
    }
  }
} 