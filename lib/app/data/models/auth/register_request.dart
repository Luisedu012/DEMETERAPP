class RegisterRequest {
  final String name;
  final String email;
  final String password;
  final String confirmPassword;
  final String phone;

  RegisterRequest({
    required this.name,
    required this.email,
    required this.password,
    required this.confirmPassword,
    required this.phone,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'name': name,
      'phone': phone,
      'password': password,
      'password_confirm': confirmPassword,
    };
  }

  @override
  String toString() {
    return 'RegisterRequest(name: $name, email: $email)';
  }
}
