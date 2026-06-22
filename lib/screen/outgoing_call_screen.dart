import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/call/call_bloc.dart';
import '../bloc/call/call_event.dart';
import '../services/call_page.dart';

class OutgoingCallScreen extends StatefulWidget {
  final String callId;
  final String receiverName;
  final String receiverImage;

  const OutgoingCallScreen({
    Key? key,
    required this.callId,
    required this.receiverName,
    required this.receiverImage,
  }) : super(key: key);

  @override
  State<OutgoingCallScreen> createState() => _OutgoingCallScreenState();
}

class _OutgoingCallScreenState extends State<OutgoingCallScreen> {
  StreamSubscription? _callSubscription;
  bool _navigatedToCall = false;

  @override
  void initState() {
    super.initState();
    _listenToCallStatus();
  }

  void _listenToCallStatus() {
    _callSubscription = FirebaseFirestore.instance
        .collection('calls')
        .doc(widget.callId)
        .snapshots()
        .listen((snapshot) {
      if (!mounted || _navigatedToCall) return;
      final data = snapshot.data();
      if (data == null) return;

      final status = data['status'];
      if (status == 'accepted') {
        _navigatedToCall = true;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => CallPage(callID: widget.callId),
          ),
        );
      } else if (status == 'rejected' || status == 'ended') {
        Navigator.pop(context);
      }
    });
  }

  void _endCall() {
    context.read<CallBloc>().add(EndCallEvent(widget.callId));
    Navigator.pop(context);
  }

  @override
  void dispose() {
    _callSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF1A1A2E),
              Color(0xFF16213E),
              Color(0xFF0F3460),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Spacer(flex: 2),
              
              // Profile Picture
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white24, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: CircleAvatar(
                  radius: 70,
                  backgroundColor: Colors.grey.shade800,
                  backgroundImage: widget.receiverImage.isNotEmpty
                      ? NetworkImage(widget.receiverImage)
                      : null,
                  child: widget.receiverImage.isEmpty
                      ? const Icon(Icons.person, size: 70, color: Colors.white)
                      : null,
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Receiver Name
              Text(
                widget.receiverName,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 8),
              
              // Calling text
              Text(
                'Calling...',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.6),
                  fontSize: 18,
                  fontWeight: FontWeight.w400,
                  letterSpacing: 1.2,
                ),
                textAlign: TextAlign.center,
              ),
              
              const Spacer(flex: 3),
              
              // End Call Button
              GestureDetector(
                onTap: _endCall,
                child: Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE63946),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFE63946).withOpacity(0.4),
                        blurRadius: 16,
                        spreadRadius: 2,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.call_end_rounded,
                      color: Colors.white,
                      size: 36,
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 48),
            ],
          ),
        ),
      ),
    );
  }
}
