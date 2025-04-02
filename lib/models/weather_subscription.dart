class WeatherSubscription {
  final String email;
  final String city;
  final bool isConfirmed;
  final DateTime createdAt;
  final DateTime? confirmedAt;

  WeatherSubscription({
    required this.email,
    required this.city,
    this.isConfirmed = false,
    required this.createdAt,
    this.confirmedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'city': city,
      'isConfirmed': isConfirmed,
      'createdAt': createdAt.toIso8601String(),
      'confirmedAt': confirmedAt?.toIso8601String(),
    };
  }

  factory WeatherSubscription.fromMap(Map<String, dynamic> map) {
    return WeatherSubscription(
      email: map['email'],
      city: map['city'],
      isConfirmed: map['isConfirmed'] ?? false,
      createdAt: DateTime.parse(map['createdAt']),
      confirmedAt: map['confirmedAt'] != null ? DateTime.parse(map['confirmedAt']) : null,
    );
  }
} 