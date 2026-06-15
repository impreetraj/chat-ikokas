import 'package:chat_ikokas/bloc/auth/auth_bloc.dart';
import 'package:chat_ikokas/bloc/auth/auth_state.dart';
import 'package:chat_ikokas/screen/messageScreen.dart';
import 'package:chat_ikokas/screen/user_profile_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController searchController = TextEditingController();
  String searchQuery = "";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(13.0),
                child: TextField(
                  controller: searchController,
                  onChanged: (value) {
                    setState(() {
                      searchQuery = value.trim();
                    });
                  },
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.search),
                    hintText: "Search Friend",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(7)
                    )
                  ),
                ),
              ),
              if (searchQuery.isEmpty)
                const SizedBox.shrink()
              else
                Padding(
                  padding: const EdgeInsets.only(right: 20, left: 20, top: 10),
                  child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('users')
                        .where('username', isGreaterThanOrEqualTo: searchQuery)
                        .where('username', isLessThan: searchQuery + '\uf8ff')
                        .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: Padding(
                        padding: EdgeInsets.all(20.0),
                        child: CircularProgressIndicator(),
                      ));
                    }
                    if (snapshot.hasError) {
                      return const Center(child: Text("An error occurred"));
                    }
                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return const Center(child: Padding(
                        padding: EdgeInsets.all(20.0),
                        child: Text("No users found"),
                      ));
                    }

                    String currentUsername = '';
                    final authState = context.read<AuthBloc>().state;
                    if (authState is Authenticated) {
                      currentUsername = authState.user.username;
                    }

                    final users = snapshot.data!.docs.where((doc) {
                      final userData = doc.data() as Map<String, dynamic>;
                      return userData['username'] != currentUsername;
                    }).toList();

                    return ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: users.length,
                      itemBuilder: (context, i) {
                        final userData = users[i].data() as Map<String, dynamic>;
                        final username = userData['username'] ?? 'Unknown User';
                        final email = userData['email'] ?? '';
                        final name = userData['name'] ?? '';
                        final profilePic = userData['profilePic'] ?? '';
                        final bio = userData['bio'] ?? '';

                        return Card(
                          elevation: 4,
                          child: ListTile(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => UserProfileScreen(username: username, userId: userData['uid'], name: name, profile: profilePic, bio: bio,
                                  ),
                                ),
                              );
                            },
                            title: Text(name),
                            subtitle: Text("@$username"), 
                            leading: profilePic.isNotEmpty
                            ? CircleAvatar(backgroundImage: NetworkImage(profilePic))
                            : const CircleAvatar(child: Icon(Icons.person))
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}