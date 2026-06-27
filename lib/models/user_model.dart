/// Represents an authenticated user.
class UserModel {
  final String uid;
  final String? email;
  final String? displayName;
  final String? photoUrl;
  final DateTime? createdAt;
  final bool isPremium;

  const UserModel({
    required this.uid,
    this.email,
    this.displayName,
    this.photoUrl,
    this.createdAt,
    this.isPremium = false,
  });

  Map<String, dynamic> toJson() => {
        'uid': uid,
        'email': email,
        'displayName': displayName,
        'photoUrl': photoUrl,
        'createdAt': createdAt?.millisecondsSinceEpoch,
        'isPremium': isPremium,
      };

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      uid: json['uid'] as String,
      email: json['email'] as String?,
      displayName: json['displayName'] as String?,
      photoUrl: json['photoUrl'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['createdAt'] as int)
          : null,
      isPremium: json['isPremium'] as bool? ?? false,
    );
  }

  UserModel copyWith({
    String? uid,
    String? email,
    String? displayName,
    String? photoUrl,
    DateTime? createdAt,
    bool? isPremium,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      createdAt: createdAt ?? this.createdAt,
      isPremium: isPremium ?? this.isPremium,
    );
  }

  @override
  String toString() => 'UserModel(uid: $uid, email: $email)';
}
