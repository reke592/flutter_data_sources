import 'dart:convert';

class Profile {
  const Profile({
    required this.name,
  });

  static const empty = Profile(name: '');

  final String name;

  factory Profile.fromJson(String source) =>
      Profile.fromMap(jsonDecode(source));

  factory Profile.fromMap(Map<String, dynamic> map) => Profile(
        name: map['name'] as String,
      );

  Map<String, dynamic> asMap() => {
        'name': name,
      };

  String asJson() => jsonEncode(asMap());
}
