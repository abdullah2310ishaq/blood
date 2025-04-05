class DonorModel {
  final String id;
  final String userId;
  final String bloodType;
  final String address;
  final bool isAvailable;
  final DateTime lastDonationDate;
  final List<String> medicalConditions;
  final double? latitude;
  final double? longitude;
  final bool shareLocation;

  DonorModel({
    required this.id,
    required this.userId,
    required this.bloodType,
    required this.address,
    required this.isAvailable,
    required this.lastDonationDate,
    required this.medicalConditions,
    this.latitude,
    this.longitude,
    this.shareLocation = false,
  });

  factory DonorModel.fromJson(Map<String, dynamic> json) {
    return DonorModel(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      bloodType: json['bloodType'] ?? '',
      address: json['address'] ?? '',
      isAvailable: json['isAvailable'] ?? false,
      lastDonationDate: json['lastDonationDate'] != null
          ? DateTime.parse(json['lastDonationDate'])
          : DateTime.now(),
      medicalConditions: List<String>.from(json['medicalConditions'] ?? []),
      latitude: json['latitude'],
      longitude: json['longitude'],
      shareLocation: json['shareLocation'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'bloodType': bloodType,
      'address': address,
      'isAvailable': isAvailable,
      'lastDonationDate': lastDonationDate.toIso8601String(),
      'medicalConditions': medicalConditions,
      'latitude': latitude,
      'longitude': longitude,
      'shareLocation': shareLocation,
    };
  }

  DonorModel copyWith({
    String? id,
    String? userId,
    String? bloodType,
    String? address,
    bool? isAvailable,
    DateTime? lastDonationDate,
    List<String>? medicalConditions,
    double? latitude,
    double? longitude,
    bool? shareLocation,
  }) {
    return DonorModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      bloodType: bloodType ?? this.bloodType,
      address: address ?? this.address,
      isAvailable: isAvailable ?? this.isAvailable,
      lastDonationDate: lastDonationDate ?? this.lastDonationDate,
      medicalConditions: medicalConditions ?? this.medicalConditions,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      shareLocation: shareLocation ?? this.shareLocation,
    );
  }
}

