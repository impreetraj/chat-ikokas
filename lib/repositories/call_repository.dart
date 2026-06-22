import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/call_model.dart';

class CallRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<CallModel?> listenToIncomingCalls(String currentUserId) {
    return _firestore
        .collection('calls')
        .where('receiverId', isEqualTo: currentUserId)
        .where('status', isEqualTo: 'calling')
        .snapshots()
        .map((snapshot) {
      if (snapshot.docs.isNotEmpty) {
        return CallModel.fromMap(snapshot.docs.first.data(), snapshot.docs.first.id);
      }
      return null;
    });
  }

  Stream<CallModel?> listenToCallStatus(String callId) {
    return _firestore.collection('calls').doc(callId).snapshots().map((snapshot) {
      if (snapshot.exists && snapshot.data() != null) {
        return CallModel.fromMap(snapshot.data()!, snapshot.id);
      }
      return null;
    });
  }

  Future<String> initiateCall(CallModel call) async {
    final docRef = await _firestore.collection('calls').add(call.toMap());
    return docRef.id;
  }

  Future<void> updateCallStatus(String callId, String status) async {
    await _firestore.collection('calls').doc(callId).update({'status': status});
  }
}
