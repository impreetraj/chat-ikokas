import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:googleapis_auth/auth_io.dart' as auth;
import 'package:flutter_callkit_incoming/entities/entities.dart';
import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';
import 'package:uuid/uuid.dart';
import 'fcm_credentials.dart';

class PushNotificationService {
  static final PushNotificationService _instance = PushNotificationService._internal();
  factory PushNotificationService() => _instance;
  PushNotificationService._internal();

  /// Scopes required for FCM HTTP v1 API
  final List<String> _scopes = [
    "https://www.googleapis.com/auth/firebase.messaging"
  ];

  Future<String?> _getAccessToken() async {
    try {
      if (FCMCredentials.serviceAccountJson['project_id'] == null || FCMCredentials.serviceAccountJson['project_id']!.isEmpty) {
        print('FCM Credentials not provided.');
        return null;
      }
      
      final serviceAccountCredentials = auth.ServiceAccountCredentials.fromJson(
        FCMCredentials.serviceAccountJson,
      );

      final client = await auth.clientViaServiceAccount(
        serviceAccountCredentials,
        _scopes,
      );

      final accessToken = client.credentials.accessToken.data;
      client.close();
      return accessToken;
    } catch (e) {
      print("Error generating FCM access token: $e");
      return null;
    }
  }

  Future<void> sendNotification({
    required String receiverToken,
    required String title,
    required String body,
  }) async {
    try {
      final projectId = FCMCredentials.serviceAccountJson['project_id'];
      if (projectId == null || projectId.isEmpty) {
        print("Project ID not found. Notification aborted.");
        return;
      }

      final token = await _getAccessToken();
      if (token == null) {
        print("Failed to get FCM access token. Notification aborted.");
        return;
      }

      final String endpoint = "https://fcm.googleapis.com/v1/projects/$projectId/messages:send";

      final Map<String, dynamic> message = {
        'message': {
          'token': receiverToken,
          'notification': {
            'title': title,
            'body': body,
          },
          'data': {
            'click_action': 'FLUTTER_NOTIFICATION_CLICK',
          }
        }
      };

      final response = await http.post(
        Uri.parse(endpoint),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(message),
      );

      if (response.statusCode == 200) {
        print("Notification sent successfully to $receiverToken");
      } else {
        print("Failed to send notification: ${response.body}");
      }
    } catch (e) {
      print("Exception sending notification: $e");
    }
  }

  Future<void> sendCallNotification({
    required String receiverToken,
    required String callId,
    required String callerName,
    required String callerImage,
  }) async {
    try {
      final projectId = FCMCredentials.serviceAccountJson['project_id'];
      if (projectId == null || projectId.isEmpty) {
        return;
      }
      final token = await _getAccessToken();
      if (token == null) return;

      final String endpoint = "https://fcm.googleapis.com/v1/projects/$projectId/messages:send";

      final Map<String, dynamic> message = {
        'message': {
          'token': receiverToken,
          'android': {
            'priority': 'HIGH',
            'ttl': '0s',
          },
          'data': {
            'type': 'voice_call',
            'callId': callId,
            'callerName': callerName,
            'callerImage': callerImage,
          }
        }
      };

      await http.post(
        Uri.parse(endpoint),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(message),
      );
    } catch (e) {
      print("Exception sending call notification: $e");
    }
  }

  Future<void> sendCallEndedNotification({
    required String receiverToken,
    required String callId,
  }) async {
    try {
      final projectId = FCMCredentials.serviceAccountJson['project_id'];
      if (projectId == null || projectId.isEmpty) return;
      final token = await _getAccessToken();
      if (token == null) return;

      final String endpoint = "https://fcm.googleapis.com/v1/projects/$projectId/messages:send";

      final Map<String, dynamic> message = {
        'message': {
          'token': receiverToken,
          'android': {
            'priority': 'HIGH',
            'ttl': '0s',
          },
          'data': {
            'type': 'call_ended',
            'callId': callId,
          }
        }
      };

      await http.post(
        Uri.parse(endpoint),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(message),
      );
    } catch (e) {
      print("Exception sending call ended notification: $e");
    }
  }

  static Future<void> handleIncomingCall(Map<String, dynamic> data) async {
    if (data['type'] == 'voice_call') {
      print("[CALLKIT] handleIncomingCall triggered with data: $data");
      final callUUID = const Uuid().v4();
      CallKitParams callKitParams = CallKitParams(
        id: callUUID,
        nameCaller: data['callerName'],
        appName: 'Chat Ikokas',
        avatar: data['callerImage'],
        handle: 'Incoming Voice Call',
        type: 0, // Voice call
        duration: 45000, // Ring for 45 seconds
        textAccept: 'Accept',
        textDecline: 'Reject',
        extra: <String, dynamic>{'callId': data['callId']},
        android: const AndroidParams(
          isCustomNotification: false,
          isShowLogo: false,
          ringtonePath: 'system_ringtone_default',
          backgroundColor: '#0955fa',
          actionColor: '#4CAF50',
          isShowFullLockedScreen: true,
          isShowCallID: false,
        ),
      );
      await FlutterCallkitIncoming.showCallkitIncoming(callKitParams);
      print("[CALLKIT] showCallkitIncoming called successfully");
    }
  }
}
