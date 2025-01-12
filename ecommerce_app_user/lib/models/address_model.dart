class Address {
  final String? id;
  final String provinceCode;
  final String provinceName;
  final String districtCode;
  final String districtName;
  final String wardCode;
  final String wardName;
  final String streetAddress;
  final String phoneNumber;

  Address({
    this.id,
    required this.provinceCode,
    required this.provinceName,
    required this.districtCode,
    required this.districtName,
    required this.wardCode,
    required this.wardName,
    required this.streetAddress,
    required this.phoneNumber,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'provinceCode': provinceCode,
      'provinceName': provinceName,
      'districtCode': districtCode,
      'districtName': districtName,
      'wardCode': wardCode,
      'wardName': wardName,
      'streetAddress': streetAddress,
      'phoneNumber': phoneNumber,
    };
  }

  factory Address.fromMap(Map<String, dynamic> map) {
    return Address(
      id: map['id'],
      provinceCode: map['provinceCode'],
      provinceName: map['provinceName'],
      districtCode: map['districtCode'],
      districtName: map['districtName'],
      wardCode: map['wardCode'],
      wardName: map['wardName'],
      streetAddress: map['streetAddress'],
      phoneNumber: map['phoneNumber'],
    );
  }
}
