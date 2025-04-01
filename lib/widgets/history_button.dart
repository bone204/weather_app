import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../colors/colors.dart';
import '../services/weather_service.dart';

class HistoryButton extends StatelessWidget {
  final WeatherService weatherService;
  final Function(Map<String, dynamic>) onLocationSelected;

  const HistoryButton({
    Key? key,
    required this.weatherService,
    required this.onLocationSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => Dialog(
              backgroundColor: Colors.transparent,
              child: Container(
                width: 400,
                height: 480,
                decoration: BoxDecoration(
                  color: AppColors.black,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 20, right: 5, top: 10, bottom: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Lịch sử tìm kiếm',
                            style: TextStyle(
                              color: AppColors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, color: AppColors.white),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ],
                      ),
                    ),
                    // ignore: deprecated_member_use
                    Divider(color: AppColors.white.withOpacity(0.2)),
                    Flexible(
                      child: FutureBuilder<List<Map<String, dynamic>>>(
                        future: weatherService.getHistory(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData || snapshot.data!.isEmpty) {
                            return const Padding(
                              padding: EdgeInsets.all(16.0),
                              child: Text(
                                'Chưa có lịch sử tìm kiếm',
                                style: TextStyle(color: AppColors.white),
                              ),
                            );
                          }

                          return SingleChildScrollView(
                            child: Column(
                              children: snapshot.data!.map((item) {
                                final time = DateTime.parse(item['timestamp']);
                                return ListTile(
                                  leading: Image.network(
                                    item['icon'],
                                    width: 40,
                                    height: 40,
                                    errorBuilder: (context, error, stackTrace) =>
                                      const Icon(Icons.cloud, color: AppColors.white),
                                  ),
                                  title: Text(
                                    '${item['location']}, ${item['country']}',
                                    style: const TextStyle(
                                      color: AppColors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  subtitle: Text(
                                    '${item['temperature']}°C - ${item['condition']}\n${DateFormat('HH:mm').format(time)}',
                                    // ignore: deprecated_member_use
                                    style: TextStyle(color: AppColors.white.withOpacity(0.7)),
                                  ),
                                  onTap: () async {
                                    final data = await weatherService.fetchWeather(item['location']);
                                    if (data != null) {
                                      onLocationSelected(data);
                                    }
                                    // ignore: use_build_context_synchronously
                                    Navigator.pop(context);
                                  },
                                );
                              }).toList(),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          // ignore: deprecated_member_use
          backgroundColor: AppColors.blue,
          padding: const EdgeInsets.symmetric(vertical: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history, color: AppColors.white, size: 24,),
            SizedBox(width: 8),
            Text(
              'Lịch sử tìm kiếm',
              style: TextStyle(
                color: AppColors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
} 