import 'dart:io';

abstract class ProfileEvent {}

class LoadProfile extends ProfileEvent {
  final String uid;
  LoadProfile(this.uid);
}

class UpdateProfile extends ProfileEvent {
  final String uid;
  final String? name;
  final String? bio;
  final File? imageFile;

  UpdateProfile({required this.uid, this.name, this.bio, this.imageFile});
}
