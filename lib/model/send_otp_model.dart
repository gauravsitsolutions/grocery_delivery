class SendOtpModel {
  String? mobileNumber;

  SendOtpModel({this.mobileNumber});

  SendOtpModel.fromJson(Map<String, dynamic> json) {
    mobileNumber = json['mobile_number'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['mobile_number'] = mobileNumber;
    return data;
  }
}
