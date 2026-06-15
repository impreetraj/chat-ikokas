import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:chat_ikokas/bloc/post/post_bloc.dart';
import 'package:chat_ikokas/bloc/post/post_event.dart';
import 'package:chat_ikokas/models/post_model.dart';

class UploadScreen extends StatefulWidget {
  const UploadScreen({super.key});

  @override
  State<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  File? selectedImage;
  final TextEditingController captionController = TextEditingController();
  bool isLoading = false;

  Future<void> pickImage() async {
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );

    if (pickedFile != null) {
      setState(() {
        selectedImage = File(pickedFile.path);
      });
    }
  }

  Future<String> uploadImage() async {
    final uri = Uri.parse(
      "https://api.cloudinary.com/v1_1/dtdmunvih/image/upload",
    );
    final request = http.MultipartRequest('POST', uri)
      ..fields['upload_preset'] = 'chat-ikokas'
      ..files.add(
        await http.MultipartFile.fromPath('file', selectedImage!.path),
      );

    final response = await request.send();
    final responseData = await response.stream.toBytes();
    final responseString = String.fromCharCodes(responseData);
    final jsonMap = jsonDecode(responseString);

    if (response.statusCode == 200) {
      final String imageUrl = jsonMap['secure_url'];

      return imageUrl;
    }
    return "";
  }

  Future<void> uploadPost() async {
    if (selectedImage == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Please select an image")));
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final imageUrl = await uploadImage();

      final userDoc = await FirebaseFirestore.instance.collection("users").doc(FirebaseAuth.instance.currentUser!.uid).get();
      final userName = userDoc.data()?["name"] ?? 'User';
      final photoUrl = userDoc.data()?["profilePic"] ?? '';

      final newPost = PostModel(
        userId: FirebaseAuth.instance.currentUser!.uid,
        imagePath: imageUrl,
        caption: captionController.text,
        userName: userName,
        photourl: photoUrl,
        timestamp: DateTime.now().toString(),
      );

      context.read<PostBloc>().add(AddPost(newPost));

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Post created successfully")));
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Create Post")),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              GestureDetector(
                onTap: pickImage,
                child: Container(
                  height: 220,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: selectedImage != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(selectedImage!, fit: BoxFit.cover),
                        )
                      : const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.image, size: 60, color: Colors.grey),
                            SizedBox(height: 10),
                            Text("Tap to select image"),
                          ],
                        ),
                ),
              ),

              const SizedBox(height: 20),

              TextField(
                controller: captionController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: "Write a caption...",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: isLoading ? null : () async {
                    await uploadPost();
                  },
                  child: isLoading 
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Text("Upload Post"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
