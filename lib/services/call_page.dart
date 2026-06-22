import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:zego_uikit/zego_uikit.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/call/call_bloc.dart';
import '../bloc/call/call_event.dart';
import '../bloc/auth/auth_bloc.dart';
import '../bloc/auth/auth_state.dart';

class CallPage extends StatefulWidget {
  const CallPage({Key? key, required this.callID}) : super(key: key);
  final String callID;

  @override
  State<CallPage> createState() => _CallPageState();
}

class _CallPageState extends State<CallPage> {
  StreamSubscription? _callStatusSubscription;
  bool _hasEnded = false;

  @override
  void initState() {
    super.initState();
    _listenToCallStatus();
  }

  void _listenToCallStatus() {
    _callStatusSubscription = FirebaseFirestore.instance
        .collection('calls')
        .doc(widget.callID)
        .snapshots()
        .listen((snapshot) {
      if (!mounted || _hasEnded) return;
      final data = snapshot.data();
      if (data == null) return;

      final status = data['status'];
      if (status == 'ended' || status == 'rejected') {
        _hasEnded = true;
        // Other side ended the call, so we leave too
        Navigator.of(context).pop();
      }
    });
  }

  @override
  void dispose() {
    _callStatusSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String currentUserId = 'unknown_user';
    String currentUserName = 'Unknown User';

    final authState = context.read<AuthBloc>().state;
    if (authState is Authenticated) {
      currentUserId = authState.user.uid;
      currentUserName = authState.user.name ?? authState.user.username;
      if (currentUserName.isEmpty) {
        currentUserName = "User";
      }
    }

    return WillPopScope(
      onWillPop: () async {
        if (!_hasEnded) {
          _hasEnded = true;
          context.read<CallBloc>().add(EndCallEvent(widget.callID));
        }
        return true;
      },
      child: SafeArea(
        child: ZegoUIKitPrebuiltCall(
          appID: 71371972,
          appSign: "2ded55ae55b9dc19a1226d858c9c1e2bfa454d237ba7a611b14f826a189f945a",
          userID: currentUserId,
          userName: currentUserName,
          callID: widget.callID,
          config: ZegoUIKitPrebuiltCallConfig.oneOnOneVoiceCall(),
          events: ZegoUIKitPrebuiltCallEvents(
            onCallEnd: (event, defaultAction) {
              if (!_hasEnded) {
                _hasEnded = true;
                context.read<CallBloc>().add(EndCallEvent(widget.callID));
              }
              defaultAction.call();
            },
          ),
        ),
      ),
    );
  }
}