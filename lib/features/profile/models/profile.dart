class Profile {
  final String id;
  final String? fullName;
  final String? avatarUrl;
  final String? bio;
  final Map<String, dynamic>? preferences;
  final bool onboardingCompleted;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Profile({
    required this.id,
    this.fullName,
    this.avatarUrl,
    this.bio,
    this.preferences,
    this.onboardingCompleted = false,
    this.createdAt,
    this.updatedAt,
  });

  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      id: json['id'],
      fullName: json['full_name'],
      avatarUrl: json['avatar_url'],
      bio: json['bio'],
      preferences: json['preferences'],
      onboardingCompleted: json['onboarding_completed'] ?? false,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'full_name': fullName,
      'avatar_url': avatarUrl,
      'bio': bio,
      'preferences': preferences,
      'onboarding_completed': onboardingCompleted,
      'updated_at': DateTime.now().toIso8601String(),
    };
  }

  Profile copyWith({
    String? fullName,
    String? avatarUrl,
    String? bio,
    Map<String, dynamic>? preferences,
    bool? onboardingCompleted,
  }) {
    return Profile(
      id: id,
      fullName: fullName ?? this.fullName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      bio: bio ?? this.bio,
      preferences: preferences ?? this.preferences,
      onboardingCompleted: onboardingCompleted ?? this.onboardingCompleted,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }
}
