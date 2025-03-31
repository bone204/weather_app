import 'dart:ui';
import 'package:flutter/material.dart';
import '../../colors/colors.dart';

class CustomSearchBar extends StatelessWidget {
  final TextEditingController? controller;
  final String hintText;
  final Function(String)? onChanged;
  final EdgeInsetsGeometry? margin;
  final bool autofocus;

  const CustomSearchBar({
    Key? key,
    this.controller,
    required this.hintText,
    this.onChanged,
    this.margin,
    this.autofocus = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        // ignore: deprecated_member_use
        color: AppColors.black.withOpacity(0.4),
      ),
      child: TextField(
        controller: controller,
        style: TextStyle(
          color: AppColors.white,
          fontSize: 18,
        ),
        onChanged: onChanged,
        decoration: InputDecoration(
          contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          hintText: hintText,
          hintStyle: TextStyle(
            fontSize: 18, 
            color: AppColors.white,
            fontWeight: FontWeight.w400
          ),
          labelStyle: TextStyle(
            fontSize: 18,
            color: AppColors.white,
            fontWeight: FontWeight.w500
          ),
          prefixIcon: Padding(
            padding: EdgeInsets.only(left: 16, right: 8),
            child: Icon(Icons.search_sharp, size: 24, color: AppColors.white),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: AppColors.white),
          ),
        ),
      ),
    );
  }
} 