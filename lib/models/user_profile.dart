/// Profil utilisateur (mock) chargé de façon asynchrone.
class UserProfile {
  final String name;
  final String email;
  final String city;
  final String memberSince;
  final String avatarEmoji;

  const UserProfile({
    required this.name,
    required this.email,
    required this.city,
    required this.memberSince,
    required this.avatarEmoji,
  });
}
