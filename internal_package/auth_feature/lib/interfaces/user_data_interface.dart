abstract interface class UserData {
  abstract int id;
  abstract String login;
  abstract String password;
  abstract String accessToken;
  abstract String refreshToken;
}

abstract interface class UserDataForRegister {
  Map<String, dynamic> toJson();
  UserDataForRegister.fromJson(Map<String, dynamic> json);
}
