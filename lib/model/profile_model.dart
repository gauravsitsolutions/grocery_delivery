class ProfileResponse {
  final bool status;
  final ProfileModel? data;

  ProfileResponse({required this.status, this.data});

  factory ProfileResponse.fromJson(Map<String, dynamic> json) {
    return ProfileResponse(
      status: json['status'] ?? false,
      data: json['data'] != null ? ProfileModel.fromJson(json['data']) : null,
    );
  }
}

class ProfileModel {
  final int? id;
  final int? userId;
  final String? name;
  final String? mobile;
  final String? email;
  final String? profilePhoto;
  final int? shopId;
  final String? dob;
  final String? gender;
  final String? aadhaarCard;
  final String? drivingLicense;
  final String? vehicleType;
  final String? vehicleNumber;
  final String? address;
  final int? stateId;
  final int? cityId;
  final String? pincode;
  final int? status;
  final int? createdBy;
  final String? createdAt;
  final String? updatedAt;

  ProfileModel({
    this.id,
    this.userId,
    this.name,
    this.mobile,
    this.email,
    this.profilePhoto,
    this.shopId,
    this.dob,
    this.gender,
    this.aadhaarCard,
    this.drivingLicense,
    this.vehicleType,
    this.vehicleNumber,
    this.address,
    this.stateId,
    this.cityId,
    this.pincode,
    this.status,
    this.createdBy,
    this.createdAt,
    this.updatedAt,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    // Check if 'user' object exists for nested data
    final user = json['user'];

    return ProfileModel(
      id: json['agent_id'] ?? json['id'],
      userId: user != null ? user['id'] : json['user_id'],
      name: user != null
          ? '${user['first_name'] ?? ''} ${user['last_name'] ?? ''}'.trim()
          : json['name'],
      mobile: user != null ? user['mobile'] : json['mobile'],
      email: user != null ? user['email'] : json['email'],
      profilePhoto:
          user != null ? user['profile_photo'] : json['profile_photo'],
      shopId: json['shop_id'],
      dob: json['dob'],
      gender: json['gender'],
      aadhaarCard: json['aadhaar_card'],
      drivingLicense: json['driving_license'],
      vehicleType: json['vehicle_type'],
      vehicleNumber: json['vehicle_number'],
      address: json['address'],
      stateId: json['state_id'],
      cityId: json['city_id'],
      pincode: json['pincode'],
      status: json['status'],
      createdBy: json['created_by'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'mobile': mobile,
      'email': email,
      'profile_photo': profilePhoto,
      'shop_id': shopId,
      'dob': dob,
      'gender': gender,
      'aadhaar_card': aadhaarCard,
      'driving_license': drivingLicense,
      'vehicle_type': vehicleType,
      'vehicle_number': vehicleNumber,
      'address': address,
      'state_id': stateId,
      'city_id': cityId,
      'pincode': pincode,
      'status': status,
      'created_by': createdBy,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}
