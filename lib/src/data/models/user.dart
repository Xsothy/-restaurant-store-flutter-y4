class User {
  final int id;
  final String name;
  final String email;
  final String? phone;
  final Address? address;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.address,
    this.createdAt,
    this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    final name = json['name']?.toString() ?? '';
    return User(
      id: json['id'] is int ? json['id'] as int : int.tryParse('${json['id']}') ?? 0,
      name: name,
      email: json['email']?.toString() ?? '',
      phone: json['phone']?.toString(),
      address: Address.fromJson(json['address']),
      createdAt: _parseDate(json['createdAt']),
      updatedAt: _parseDate(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'address': address?.toJson(),
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    }..removeWhere((key, value) => value == null);
  }

  String get fullName => name.isEmpty ? 'Guest' : name;

  String get firstName {
    if (name.isEmpty) return '';
    final segments = name.trim().split(RegExp(r"\s+"));
    return segments.isNotEmpty ? segments.first : '';
  }

  String get lastName {
    if (name.isEmpty) return '';
    final segments = name.trim().split(RegExp(r"\s+"));
    if (segments.length <= 1) return '';
    return segments.sublist(1).join(' ');
  }

  User copyWith({
    int? id,
    String? name,
    String? email,
    String? phone,
    Address? address,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    return DateTime.tryParse(value.toString());
  }
}

class Address {
  final String street;
  final String? city;
  final String? state;
  final String? zipCode;
  final String? country;
  final double? latitude;
  final double? longitude;

  const Address({
    this.street = '',
    this.city,
    this.state,
    this.zipCode,
    this.country,
    this.latitude,
    this.longitude,
  });

  factory Address.fromJson(dynamic json) {
    if (json == null) {
      return const Address();
    }
    if (json is String) {
      return Address(street: json);
    }
    if (json is Map<String, dynamic>) {
      return Address(
        street: json['street']?.toString() ?? '',
        city: json['city']?.toString(),
        state: json['state']?.toString(),
        zipCode: json['zipCode']?.toString(),
        country: json['country']?.toString(),
        latitude: json['latitude'] is num ? (json['latitude'] as num).toDouble() : null,
        longitude: json['longitude'] is num ? (json['longitude'] as num).toDouble() : null,
      );
    }
    return const Address();
  }

  Map<String, dynamic> toJson() {
    return {
      'street': street,
      'city': city,
      'state': state,
      'zipCode': zipCode,
      'country': country,
      'latitude': latitude,
      'longitude': longitude,
    }..removeWhere((key, value) => value == null || (value is String && value.isEmpty));
  }

  String get fullAddress {
    final parts = <String>[];
    if (street.isNotEmpty) parts.add(street);
    if (city?.isNotEmpty ?? false) parts.add(city!);
    if (state?.isNotEmpty ?? false) parts.add(state!);
    if (zipCode?.isNotEmpty ?? false) parts.add(zipCode!);
    if (country?.isNotEmpty ?? false) parts.add(country!);
    return parts.join(', ');
  }

  Address copyWith({
    String? street,
    String? city,
    String? state,
    String? zipCode,
    String? country,
    double? latitude,
    double? longitude,
  }) {
    return Address(
      street: street ?? this.street,
      city: city ?? this.city,
      state: state ?? this.state,
      zipCode: zipCode ?? this.zipCode,
      country: country ?? this.country,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
    );
  }
}

class LoginRequest {
  final String email;
  final String password;

  LoginRequest({
    required this.email,
    required this.password,
  });

  Map<String, dynamic> toJson() => {
        'email': email,
        'password': password,
      };
}

class RegisterRequest {
  final String name;
  final String email;
  final String? phone;
  final String password;
  final Address? address;

  RegisterRequest({
    required this.name,
    required this.email,
    required this.password,
    this.phone,
    this.address,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'password': password,
      'address': () {
        final formatted = address?.fullAddress.trim();
        return (formatted != null && formatted.isNotEmpty) ? formatted : null;
      }(),
    }..removeWhere((key, value) => value == null);
  }
}

class AuthResponse {
  final String token;
  final String tokenType;
  final int? expiresIn;
  final User customer;
  final DateTime? issuedAt;

  AuthResponse({
    required this.token,
    required this.tokenType,
    required this.customer,
    this.expiresIn,
    this.issuedAt,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      token: json['token']?.toString() ?? '',
      tokenType: json['tokenType']?.toString() ?? 'Bearer',
      expiresIn: json['expiresIn'] is int
          ? json['expiresIn'] as int
          : int.tryParse('${json['expiresIn']}'),
      customer: json['customer'] is Map<String, dynamic>
          ? User.fromJson(json['customer'] as Map<String, dynamic>)
          : User.fromJson({}),
      issuedAt: User._parseDate(json['issuedAt']),
    );
  }
}
