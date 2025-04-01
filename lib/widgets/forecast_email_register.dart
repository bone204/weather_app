import 'package:flutter/material.dart';
import '../colors/colors.dart';

class ForecastEmailRegister extends StatelessWidget {

  const ForecastEmailRegister({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          
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
            Icon(Icons.email, color: AppColors.white, size: 24,),
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
      ),
    );
  }
} 