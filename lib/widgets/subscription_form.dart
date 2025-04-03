// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import '../services/subscription_service.dart';
import '../colors/colors.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:async';

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
  List<dynamic> _citySuggestions = [];
  bool _isSearching = false;
  Timer? _debounce;
  bool _isCitySelectedFromSuggestion = false;

  @override
  void initState() {
    super.initState();
    _cityController.addListener(_onCityChanged);
  }

  void _onCityChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (_cityController.text.isNotEmpty && _cityController.text.length > 2 && !_isCitySelectedFromSuggestion) {
        _searchCities(_cityController.text);
      } else {
        setState(() {
          _citySuggestions = [];
        });
      }
    });
  }

  Future<void> _searchCities(String query) async {
    if (query.isEmpty) return;

    setState(() {
      _isSearching = true;
    });

    try {
      final response = await http.get(
        Uri.parse('https://api.weatherapi.com/v1/search.json?key=${_getWeatherApiKey()}&q=$query'),
      );

      if (response.statusCode == 200) {
        final suggestions = json.decode(response.body);
        setState(() {
          _citySuggestions = suggestions;
          _isSearching = false;
        });
      } else {
        setState(() {
          _citySuggestions = [];
          _isSearching = false;
        });
      }
    } catch (e) {
      setState(() {
        _citySuggestions = [];
        _isSearching = false;
      });
    }
  }

  String _getWeatherApiKey() {
    return 'f3b63d0f85e842529d882310253103';
  }

  void _selectCity(dynamic city) {
    setState(() {
      _cityController.text = "${city['name']}, ${city['country']}";
      _citySuggestions = [];
      _isCitySelectedFromSuggestion = true;
    });
  }

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
        _isCitySelectedFromSuggestion = false;
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
            Column(
              children: [
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
                    hintText: 'Search for a city...',
                    hintStyle: TextStyle(color: AppColors.white.withOpacity(0.3)),
                    prefixIcon: Icon(
                      Icons.location_city, 
                      color: _isCitySelectedFromSuggestion 
                          ? AppColors.green 
                          : AppColors.white.withOpacity(0.7)
                    ),
                    filled: true,
                    fillColor: AppColors.white.withOpacity(0.1),
                    suffixIcon: _isSearching 
                      ? Container(
                          width: 20,
                          height: 20,
                          padding: const EdgeInsets.all(8),
                          child: const CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(AppColors.green),
                          ),
                        )
                      : _cityController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, color: AppColors.white),
                              onPressed: () {
                                _cityController.clear();
                                setState(() {
                                  _citySuggestions = [];
                                  _isCitySelectedFromSuggestion = false;
                                });
                              },
                            )
                          : null,
                  ),
                  style: TextStyle(
                    color: _isCitySelectedFromSuggestion ? AppColors.green : AppColors.white,
                    fontWeight: _isCitySelectedFromSuggestion ? FontWeight.bold : FontWeight.normal,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter city name';
                    }
                    if (!_isCitySelectedFromSuggestion) {
                      return 'Please select a city from the suggestions';
                    }
                    return null;
                  },
                  readOnly: _isCitySelectedFromSuggestion,
                ),
                if (_citySuggestions.isNotEmpty)
                  Container(
                    margin: const EdgeInsets.only(top: 4),
                    decoration: BoxDecoration(
                      color: AppColors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.green.withOpacity(0.3), width: 1.5),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 6,
                          offset: const Offset(0, 3),
                        )
                      ],
                    ),
                    constraints: const BoxConstraints(maxHeight: 250),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: ListView.separated(
                        shrinkWrap: true,
                        padding: EdgeInsets.zero,
                        itemCount: _citySuggestions.length,
                        separatorBuilder: (context, index) => Divider(
                          height: 1,
                          color: AppColors.white.withOpacity(0.1),
                          indent: 16,
                          endIndent: 16,
                        ),
                        itemBuilder: (context, index) {
                          final city = _citySuggestions[index];
                          return ListTile(
                            dense: true,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                            leading: CircleAvatar(
                              backgroundColor: AppColors.green.withOpacity(0.1),
                              radius: 16,
                              child: const Icon(
                                Icons.location_on,
                                color: AppColors.green,
                                size: 18,
                              ),
                            ),
                            title: Text(
                              "${city['name']}",
                              style: const TextStyle(
                                color: AppColors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(
                              "${city['region']}, ${city['country']}",
                              style: TextStyle(
                                color: AppColors.white.withOpacity(0.7),
                                fontSize: 12,
                              ),
                            ),
                            onTap: () => _selectCity(city),
                            hoverColor: AppColors.green.withOpacity(0.1),
                            tileColor: Colors.transparent,
                          );
                        },
                      ),
                    ),
                  ),
                if (_cityController.text.isNotEmpty && !_isCitySelectedFromSuggestion && _citySuggestions.isEmpty && !_isSearching)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      'No cities found. Please try a different search term.',
                      style: TextStyle(
                        color: AppColors.red.withOpacity(0.7),
                        fontSize: 12,
                      ),
                    ),
                  ),
              ],
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
    _debounce?.cancel();
    _emailController.dispose();
    _cityController.dispose();
    super.dispose();
  }
} 