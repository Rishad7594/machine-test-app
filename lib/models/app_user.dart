// lib/models/app_user.dart
class AppUser {
  final String localId; // Firebase localId (uid)
  final String email;
  final String idToken; // Firebase ID token (JWT)
  final String refreshToken;
  final int expiresIn; // seconds until idToken expires (from server)

  AppUser({
    required this.localId,
    required this.email,
    required this.idToken,
    required this.refreshToken,
    required this.expiresIn,
  });

  Map<String, dynamic> toJson() => {
        'localId': localId,
        'email': email,
        'idToken': idToken,
        'refreshToken': refreshToken,
        'expiresIn': expiresIn,
      };

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      localId: json['localId'] ?? '',
      email: json['email'] ?? '',
      idToken: json['idToken'] ?? '',
      refreshToken: json['refreshToken'] ?? '',
      expiresIn: json['expiresIn'] is String
          ? int.tryParse(json['expiresIn']) ?? 0
          : (json['expiresIn'] ?? 0),
    );
  }
}
