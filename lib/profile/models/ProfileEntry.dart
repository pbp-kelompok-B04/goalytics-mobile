class ProfileEntry {
  final String username;
  final String name;
  final String email;

  String bio;
  String profilePicture;
  String favoriteLeague;
  String favoriteTeam;
  int? favoriteTeamId;
  String preferredPosition;
  String instagramUrl;
  String xUrl;
  String websiteUrl;
  String role;
  String memberSince;

  ProfileEntry({
    required this.username,
    required this.name,
    required this.email,
    required this.bio,
    required this.profilePicture,
    required this.favoriteLeague,
    required this.favoriteTeam,
    required this.favoriteTeamId,
    required this.preferredPosition,
    required this.instagramUrl,
    required this.xUrl,
    required this.websiteUrl,
    required this.role,
    required this.memberSince,
  });

  factory ProfileEntry.fromJson(Map<String, dynamic> json) {
    return ProfileEntry(
      username: json['username'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      bio: json['bio'] ?? '',
      profilePicture: json['avatar'] ?? '',
      favoriteLeague: json['favorite_league'] ?? '',
      favoriteTeam: json['favorite_team'] ?? '',
      favoriteTeamId: json['favorite_team_id'],
      preferredPosition: json['preferred_position'] ?? '',
      instagramUrl: json['instagram_url'] ?? '',
      xUrl: json['x_url'] ?? '',
      websiteUrl: json['website_url'] ?? '',
      role: (json["role"] ?? "").toString(),
      memberSince: (json["member_since"]),

    );
  }

  Map<String, dynamic> toUpdateJson() {
    return {
      "bio": bio,
      "profile_picture": profilePicture,
      "favorite_league": favoriteLeague,
      "preferred_position": preferredPosition,
      "instagram_url": instagramUrl,
      "x_url": xUrl,
      "website_url": websiteUrl,
      "favorite_team_id": favoriteTeamId,
    };
  }
}
