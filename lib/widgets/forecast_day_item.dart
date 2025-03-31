import 'package:flutter/material.dart';
import 'package:weather_app/colors/colors.dart';

class ForecastDayItem extends StatelessWidget {
  final String day;
  final String temperature;
  final String humidity;
  final String windSpeed;
  final String rainChance;
  final IconData weatherIcon;

  const ForecastDayItem({
    Key? key,
    required this.day,
    required this.temperature,
    required this.humidity,
    required this.windSpeed,
    required this.rainChance,
    required this.weatherIcon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            // ignore: deprecated_member_use
            color: AppColors.white.withOpacity(0.2),
            width: 1,
          ),
        ),
      ),
      child: ExpansionTile(
        backgroundColor: Colors.transparent,
        collapsedIconColor: AppColors.white,
        iconColor: AppColors.white,
        title: Row(
          children: [
            Expanded(
              flex: 2,
              child: Text(
                day,
                style: TextStyle(
                  color: AppColors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w500
                ),
              ),
            ),
            Icon(
              weatherIcon,
              color: AppColors.white,
              size: 28,
            ),
            const SizedBox(width: 12),
            Text(
              '$temperature°C',
              style: TextStyle(
                color: AppColors.white,
                fontSize: 18,
                fontWeight: FontWeight.w500
              ),
            ),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              children: [
                _buildDetailRow(Icons.water_drop, 'Humidity', humidity),
                const SizedBox(height: 8),
                _buildDetailRow(Icons.air, 'Wind Speed', windSpeed),
                const SizedBox(height: 8),
                _buildDetailRow(Icons.umbrella, 'Rain Chance', rainChance),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(
          icon,
          color: AppColors.white,
          size: 20,
        ),
        const SizedBox(width: 8),
        Text(
          '$label: $value',
          style: TextStyle(
            color: AppColors.white,
            fontSize: 16,
          ),
        ),
      ],
    );
  }
} 