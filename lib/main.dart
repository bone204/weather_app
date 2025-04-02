import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:weather_app/firebase_options.dart';
import 'package:weather_app/views/home/home_view.dart';
import 'package:weather_app/providers/weather_provider.dart';
import 'views/confirm_subscription/confirm_subscription_view.dart';

Future<void> main() async {
  await dotenv.load(); 
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => WeatherProvider(),
      child: MaterialApp(
        title: 'Weather App',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        initialRoute: '/',
        onGenerateRoute: (settings) {
          if (settings.name == '/confirm') {
            final uri = Uri.parse(settings.name!);
            final email = uri.queryParameters['email'];
            final token = uri.queryParameters['token'];
            
            if (email != null && token != null) {
              return MaterialPageRoute(
                builder: (context) => ConfirmSubscriptionView(
                  email: email,
                  token: token,
                ),
              );
            }
          }
          
          // Mặc định trở về trang chủ
          return MaterialPageRoute(
            builder: (context) => const HomeView(),
          );
        },
      ),
    );
  }
}