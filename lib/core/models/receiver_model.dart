class ReceiverModel {
  final String id;
  final String userId;
  final String hospitalName;
  final String address;
  final String contactPerson;

  ReceiverModel({
    required this.id,
    required this.userId,
    required this.hospitalName,
    required this.address,
    required this.contactPerson,
  });

  factory ReceiverModel.fromJson(Map<String, dynamic> json) {
    return ReceiverModel(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      hospitalName: json['hospitalName'] ?? '',
      address: json['address'] ?? '',
      contactPerson: json['contactPerson'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'hospitalName': hospitalName,
      'address': address,
      'contactPerson': contactPerson,
    };
  }
}

