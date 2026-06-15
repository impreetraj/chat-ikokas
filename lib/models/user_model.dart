import 'package:equatable/equatable.dart';

class UserModel extends Equatable {
  final String uid;
  final String email;
  final String username;
  final String? name;
  final String? bio;
  final String? profilePic;

  const UserModel({
    required this.uid,
    required this.email,
    required this.username,
    this.name,
    this.bio,
    this.profilePic,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'username': username,
      if (name != null) 'name': name,
      if (bio != null) 'bio': bio,
      if (profilePic != null) 'profilePic': profilePic,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      email: map['email'] ?? '',
      username: map['username'] ?? '',
      name: map['name'],
      bio: map['bio'],
      profilePic: map['profilePic'],
    );
  }

  UserModel copyWith({
    String? uid,
    String? email,
    String? username,
    String? name,
    String? bio,
    String? profilePic,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      username: username ?? this.username,
      name: name ?? this.name,
      bio: bio ?? this.bio,
      profilePic: profilePic ?? this.profilePic,
    );
  }

  @override
  List<Object?> get props => [uid, email, username, name, bio, profilePic];
}
