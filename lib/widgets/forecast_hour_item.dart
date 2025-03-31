import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:weather_app/colors/colors.dart';

class ForecastHourItem extends StatelessWidget {
  final String time;
  final String temperature;
  final String weatherIcon;
  
  const ForecastHourItem({
    Key? key,
    required this.time,
    required this.temperature, 
    required this.weatherIcon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          width: 160,
          decoration: BoxDecoration(
            // ignore: deprecated_member_use
            color: AppColors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  time,
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.w500
                  ),
                ),
                SizedBox(height: 10),
                Image.network(weatherIcon),
                SizedBox(height: 20),
                Text(
                  '$temperature°C',
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
