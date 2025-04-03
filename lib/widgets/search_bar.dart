import 'package:flutter/material.dart';
import '../../colors/colors.dart';

class CustomSearchBar extends StatefulWidget {
  final Function(Map<String, dynamic>) onLocationSelected;
  final VoidCallback onLocationButtonPressed;
  final Function(String) onSearch;
  final TextEditingController searchController;

  const CustomSearchBar({
    Key? key,
    required this.onLocationSelected,
    required this.onLocationButtonPressed,
    required this.onSearch,
    required this.searchController,
  }) : super(key: key);

  @override
  State<CustomSearchBar> createState() => _CustomSearchBarState();
}

class _CustomSearchBarState extends State<CustomSearchBar> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> searchResults = [];
  bool isSearching = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: widget.searchController,
                style: const TextStyle(color: AppColors.white),
                cursorColor: AppColors.white,
                decoration: InputDecoration(
                  hintText: 'Search for a location...',
                  // ignore: deprecated_member_use
                  hintStyle: TextStyle(color: AppColors.white.withOpacity(0.7)),
                  prefixIcon: const Icon(Icons.search, color: AppColors.white),
                  filled: true,
                  // ignore: deprecated_member_use
                  fillColor: Colors.white.withOpacity(0.2),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                ),
                onChanged: widget.onSearch,
              ),
            ),
            const SizedBox(width: 10),
            IconButton(
              onPressed: widget.onLocationButtonPressed,
              icon: const Icon(Icons.my_location, color: AppColors.white),
              tooltip: 'Use current location',
            ),
          ],
        ),
      ],
    );
  }
} 