import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import '../../models/user_model.dart';
import 'profile_event.dart';
import 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  ProfileBloc() : super(ProfileInitial()) {
    on<LoadProfile>(_onLoadProfile);
    on<UpdateProfile>(_onUpdateProfile);
  }

  Future<void> _onLoadProfile(LoadProfile event, Emitter<ProfileState> emit) async {
    emit(ProfileLoading());
    try {
      final doc = await _firestore.collection('users').doc(event.uid).get();
      if (doc.exists && doc.data() != null) {
        final userModel = UserModel.fromMap(doc.data()!);
        emit(ProfileLoaded(userModel));
      } else {
        emit(ProfileError("User not found"));
      }
    } catch (e) {
      emit(ProfileError(e.toString()));
    }
  }

  Future<void> _onUpdateProfile(UpdateProfile event, Emitter<ProfileState> emit) async {
    emit(ProfileLoading());

    try {
      String? imageUrl;
      if (event.imageFile != null) {
        imageUrl = await _uploadImage(event.imageFile!);
      }

      Map<String, dynamic> updateData = {};
      if (event.name != null) {
        updateData['name'] = event.name;
      }
      if (event.bio != null) {
        updateData['bio'] = event.bio;
      }
      if (imageUrl != null) {
        updateData['profilePic'] = imageUrl;
      }

      await _firestore.collection('users').doc(event.uid).set(updateData, SetOptions(merge: true));

      final doc = await _firestore.collection('users').doc(event.uid).get();
      if (doc.exists && doc.data() != null) {
        final userModel = UserModel.fromMap(doc.data()!);
        emit(ProfileLoaded(userModel));
      } else {
        emit(ProfileError("Failed to fetch updated profile"));
      }
    } catch (e) {
      emit(ProfileError(e.toString()));
    }
  }

  Future<String?> _uploadImage(File file) async {
    try {
      final uri = Uri.parse("https://api.cloudinary.com/v1_1/dtdmunvih/image/upload");
      final request = http.MultipartRequest('POST', uri)
        ..fields['upload_preset'] = 'chat-ikokas'
        ..files.add(await http.MultipartFile.fromPath('file', file.path));

      final response = await request.send();
      if (response.statusCode == 200) {
        final responseData = await response.stream.toBytes();
        final responseString = String.fromCharCodes(responseData);
        final jsonMap = jsonDecode(responseString);
        return jsonMap['secure_url'];
      }
    } catch (e) {
      print("Error uploading image: $e");
    }
    return null;
  }
}
