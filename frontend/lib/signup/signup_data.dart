// Data model to pass signup information between screens
class SignupData {
  // Screen 1 - Personal Details
  String? fullName;
  String? email;
  String? phoneNumber;
  String? countryCode;
  String? gender;
  
  // Screen 2 - Additional Details
  String? address;
  String? institutionSchool;
  String? residentialCountry;
  String? referenceCode;
  
  // Screen 3 - Password
  String? password;
  String? confirmPassword;
  
  SignupData({
    this.fullName,
    this.email,
    this.phoneNumber,
    this.countryCode,
    this.gender,
    this.address,
    this.institutionSchool,
    this.residentialCountry,
    this.referenceCode,
    this.password,
    this.confirmPassword,
  });
  
  // Create a copy with updated fields
  SignupData copyWith({
    String? fullName,
    String? email,
    String? phoneNumber,
    String? countryCode,
    String? gender,
    String? address,
    String? institutionSchool,
    String? residentialCountry,
    String? referenceCode,
    String? password,
    String? confirmPassword,
  }) {
    return SignupData(
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      countryCode: countryCode ?? this.countryCode,
      gender: gender ?? this.gender,
      address: address ?? this.address,
      institutionSchool: institutionSchool ?? this.institutionSchool,
      residentialCountry: residentialCountry ?? this.residentialCountry,
      referenceCode: referenceCode ?? this.referenceCode,
      password: password ?? this.password,
      confirmPassword: confirmPassword ?? this.confirmPassword,
    );
  }
}

