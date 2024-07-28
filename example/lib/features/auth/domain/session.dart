import 'dart:convert';

class Session {
  const Session({
    required this.token,
    required this.refreshToken,
  });

  static const empty = Session(token: '', refreshToken: null);

  final String token;
  final String? refreshToken;

  factory Session.fromJson(String source) {
    return Session.fromMap(jsonDecode(source));
  }

  factory Session.fromMap(Map<String, dynamic> map) {
    return Session(
      token: map['token'] as String,
      refreshToken: map['refreshToken'] as String?,
    );
  }

  bool get isExpired => token.isEmpty && refreshToken == null;
  bool get isValid => !isExpired;

  @override
  String toString() =>
      'Session(isValid: $isValid, token: $token, rtoken: $refreshToken)';

  Map<String, dynamic> asMap() => {
        'token': token,
        'refreshToken': refreshToken,
      };

  String asJson() => jsonEncode(asMap());
}
