class DonationRequestModel {
  final String id;
  final String receiverId;
  final String bloodType;
  final String urgency; // 'high', 'medium', 'low'
  final String status; // 'pending', 'accepted', 'completed', 'cancelled'
  final String hospitalName;
  final String address;
  final String patientName;
  final String contactNumber;
  final String? donorId;
  final DateTime createdAt;
  final DateTime? completedAt;

  DonationRequestModel({
    required this.id,
    required this.receiverId,
    required this.bloodType,
    required this.urgency,
    required this.status,
    required this.hospitalName,
    required this.address,
    required this.patientName,
    required this.contactNumber,
    this.donorId,
    required this.createdAt,
    this.completedAt,
  });

  factory DonationRequestModel.fromJson(Map<String, dynamic> json) {
    return DonationRequestModel(
      id: json['id'] ?? '',
      receiverId: json['receiverId'] ?? '',
      bloodType: json['bloodType'] ?? '',
      urgency: json['urgency'] ?? 'medium',
      status: json['status'] ?? 'pending',
      hospitalName: json['hospitalName'] ?? '',
      address: json['address'] ?? '',
      patientName: json['patientName'] ?? '',
      contactNumber: json['contactNumber'] ?? '',
      donorId: json['donorId'],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'receiverId': receiverId,
      'bloodType': bloodType,
      'urgency': urgency,
      'status': status,
      'hospitalName': hospitalName,
      'address': address,
      'patientName': patientName,
      'contactNumber': contactNumber,
      'donorId': donorId,
      'createdAt': createdAt.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
    };
  }
}

