class UserModel {
  final String uid;
  final String? displayName;
  final String? email;
  final String? photoUrl;
  final bool isGuest;

  UserModel({
    required this.uid,
    this.displayName,
    this.email,
    this.photoUrl,
    required this.isGuest,
  });

  // Untuk simpan ke SQLite
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'displayName': displayName,
      'email': email,
      'photoUrl': photoUrl,
      'isGuest': isGuest ? 1 : 0,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'],
      displayName: map['displayName'],
      email: map['email'],
      photoUrl: map['photoUrl'],
      isGuest: map['isGuest'] == 1,
    );
  }
}
