import 'package:flutter/material.dart';
import '../../colors/colors.dart';
import 'dart:ui';

import 'package:weather_app/widgets/search_bar.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/img/bg_2.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(40.0),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    width: 400,
                    decoration: BoxDecoration(
                      // ignore: deprecated_member_use
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        children: [
                          CustomSearchBar(
                            hintText: 'Search',
                            onChanged: (value) {
                              
                            },
                          ),
                          SizedBox(height: 20),
                          Icon(Icons.wb_cloudy_rounded, size: 200, color: AppColors.white),
                          SizedBox(height: 20),
                          Text('New York', style: TextStyle(color: AppColors.white, fontSize: 24, fontWeight: FontWeight.w500),),
                          Text('17°C', style: TextStyle(color: AppColors.white, fontSize: 48, fontWeight: FontWeight.w500),),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 32),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Today's highlights", style: TextStyle(color: AppColors.white, fontSize: 36, fontWeight: FontWeight.bold)),
                    SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                            child: Container(
                              width: 500,
                              height: 200,
                              decoration: BoxDecoration(
                                // ignore: deprecated_member_use
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(20.0),
                                child: Column(
                                  children: [
                                    Text('Container 1', 
                                      style: TextStyle(
                                        color: AppColors.white, 
                                        fontSize: 24,
                                        fontWeight: FontWeight.w500
                                      )
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                            child: Container(
                              width: 500,
                              height: 200,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(20.0),
                                child: Column(
                                  children: [
                                    Text('Container 2', 
                                      style: TextStyle(
                                        color: AppColors.white, 
                                        fontSize: 24,
                                        fontWeight: FontWeight.w500
                                      )
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          )
        ),
      ),
    );
  }
}
