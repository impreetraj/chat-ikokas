import 'package:chat_ikokas/screen/messageScreen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserProfileScreen extends StatefulWidget {
  final String userId;
  final String username;
  final String name;
  final String profile;
  final String bio;

  
  const UserProfileScreen({super.key , required this.username , required this.userId , required this.name , required this.profile , required this.bio });

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  bool isFollowing = false;
  bool isLoading = true;
  final String? currentUserId = FirebaseAuth.instance.currentUser?.uid;

  @override
  void initState() {
    super.initState();
    _checkIfFollowing();
  }

  Future<void> _checkIfFollowing() async {
    if (currentUserId == null) {
      setState(() => isLoading = false);
      return;
    }
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUserId)
          .collection('following')
          .doc(widget.userId)
          .get();
      
      if (mounted) {
        setState(() {
          isFollowing = doc.exists;
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  Future<void> _toggleFollow() async {
    if (currentUserId == null || currentUserId == widget.userId) return;
    
    
    setState(() {
      isFollowing = !isFollowing;
    });

    try {
      if (isFollowing) {
        // Follow user
        await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUserId)
            .collection('following')
            .doc(widget.userId)
            .set({'timestamp': FieldValue.serverTimestamp()});
            
        await FirebaseFirestore.instance
            .collection('users')
            .doc(widget.userId)
            .collection('followers')
            .doc(currentUserId)
            .set({'timestamp': FieldValue.serverTimestamp()});

        // Copy all posts from feed
        final userPostsSnapshot = await FirebaseFirestore.instance
            .collection('userPosts')
            .doc(widget.userId)
            .collection('posts')
            .get();
            
        final followBatch = FirebaseFirestore.instance.batch();
        for (var doc in userPostsSnapshot.docs) {
          final feedDocRef = FirebaseFirestore.instance
              .collection('feeds')
              .doc(currentUserId)
              .collection('posts')
              .doc(doc.id);
          followBatch.set(feedDocRef, doc.data());
        }
        await followBatch.commit();
      } else {
        // Unfollow user
        await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUserId)
            .collection('following')
            .doc(widget.userId)
            .delete();
            
        await FirebaseFirestore.instance
            .collection('users')
            .doc(widget.userId)
            .collection('followers')
            .doc(currentUserId)
            .delete();

        // Remove all posts from feed
        final feedPostsSnapshot = await FirebaseFirestore.instance
            .collection('feeds')
            .doc(currentUserId)
            .collection('posts')
            .where('userId', isEqualTo: widget.userId)
            .get();
            
        final unfollowBatch = FirebaseFirestore.instance.batch();
        for (var doc in feedPostsSnapshot.docs) {
          unfollowBatch.delete(doc.reference);
        }
        await unfollowBatch.commit();
      }
    } catch (e) {
      
      if (mounted) {
        setState(() {
          isFollowing = !isFollowing;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Something went wrong')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.username,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: false,
      ),
      body: _buildProfileHeader(),
     
        
        
      
    );
  }

  Widget _buildProfileHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 40,
                backgroundColor: Colors.grey.shade200,
                backgroundImage: widget.profile.isNotEmpty
                    ? NetworkImage(widget.profile)
                    : null,
                child: widget.profile.isEmpty
                    ? const Icon(Icons.person, size: 40, color: Colors.grey)
                    : null,
              ),
              const SizedBox(width: 20),
            Column(
              children: [
                Text(
                widget.name,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                
                          ),
                Text(widget.bio, maxLines: 1,overflow: TextOverflow.ellipsis,),
                
              ],
            ),
            ],
          ),
          SizedBox(height: 10,),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: isLoading || currentUserId == widget.userId ? null : _toggleFollow,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isFollowing ? Colors.grey.shade300 : Colors.blue,
                    foregroundColor: isFollowing ? Colors.black : Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: isLoading 
                      ? const SizedBox(height: 15, width: 15, child: CircularProgressIndicator(strokeWidth: 2))
                      : Text(isFollowing ? 'Unfollow' : 'Follow'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => Messagescreen(peerId: widget.userId, peerName: widget.username , peerPhotoUrl: widget.profile),));
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Message'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

 
 
}