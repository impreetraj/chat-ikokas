import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:chat_ikokas/models/message_model.dart';

class ChatRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;


  String getChatroomId(String user1, String user2) {
    if (user1.compareTo(user2) > 0) {
      return "${user1}_$user2";
    } else {
      return "${user2}_$user1";
    }
  }


  Future<void> sendMessage(String chatroomId, MessageModel message) async {
    // Update the chatroom document with participants and last message details
    await _firestore.collection('chatrooms').doc(chatroomId).set({
      'participants': [message.senderId, message.receiverId],
      'lastMessage': message.message,
      'lastMessageTime': message.timestamp,
    }, SetOptions(merge: true));

  
    await _firestore
        .collection('chatrooms')
        .doc(chatroomId)
        .collection('messages')
        .add(message.toMap());
  }

 
  Stream<QuerySnapshot> getMessages(String chatroomId) {
    return _firestore
        .collection('chatrooms')
        .doc(chatroomId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots();
  }

  
  Stream<QuerySnapshot> getUserChatrooms(String userId) {
    return _firestore
        .collection('chatrooms')
        .where('participants', arrayContains: userId)
        .snapshots();
  }
}
