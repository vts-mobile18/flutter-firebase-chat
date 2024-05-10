import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_callkit_incoming/entities/android_params.dart';
import 'package:flutter_callkit_incoming/entities/call_kit_params.dart';
import 'package:flutter_callkit_incoming/entities/ios_params.dart';
import 'package:flutter_callkit_incoming/entities/notification_params.dart';
import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';
import 'src/app.dart';


Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('ffffffffffffffffffffffffffffffffffffffff1');
  // If the app is in the background, process the message data
  if (message != null) {
    print("Handling a background message: ${message}");
    requestNotificationPermission();
    // Extract and process data from message.data
    String title = message.data['title'];
    String body = message.data['body'];

    // Optionally, show a local notification using a plugin like flutter_local_notifications
    // ... (local notification handling code)
  }
}

Future<void> requestNotificationPermission() async {
  print('djjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjj');
  try {
    CallKitParams callKitParams = CallKitParams(
      // id: _currentUuid,
      nameCaller: 'Abishek',
      appName: 'Tobi',
      avatar: 'https://i.pravatar.cc/100',
      handle: '0123456789',
      type: 0,
      textAccept: 'Accept',
      textDecline: 'Decline',
      missedCallNotification: NotificationParams(
        showNotification: true,
        isShowCallback: true,
        subtitle: 'Missed call',
        callbackText: 'Call back',
      ),
      duration: 30000,
      extra: <String, dynamic>{'userId': '1a2b3c4d'},
      headers: <String, dynamic>{'apiKey': 'Abc@123!', 'platform': 'flutter'},
      android: const AndroidParams(
          isCustomNotification: true,
          isShowLogo: false,
          ringtonePath: 'system_ringtone_default',
          backgroundColor: '#0955fa',
          backgroundUrl: 'https://i.pravatar.cc/500',
          actionColor: '#4CAF50',
          textColor: '#ffffff',
          incomingCallNotificationChannelName: "Incoming Call",
          missedCallNotificationChannelName: "Missed Call",
          isShowCallID: false
      ),
      ios: IOSParams(
        iconName: 'CallKitLogo',
        handleType: 'generic',
        supportsVideo: true,
        maximumCallGroups: 2,
        maximumCallsPerCallGroup: 1,
        audioSessionMode: 'default',
        audioSessionActive: true,
        audioSessionPreferredSampleRate: 44100.0,
        audioSessionPreferredIOBufferDuration: 0.005,
        supportsDTMF: true,
        supportsHolding: true,
        supportsGrouping: false,
        supportsUngrouping: false,
        ringtonePath: 'system_ringtone_default',
      ),
    );
    await FlutterCallkitIncoming.showCallkitIncoming(callKitParams);
  } catch(err) {
    print('errrrrrrrrrrrrrrrrrrrrrrrrrrrr: ${err}');
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true, // Required for messages to be shown when in the foreground
    badge: true,
    sound: true,
  );

  FirebaseMessaging messaging = FirebaseMessaging.instance;
  NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    announcement: true,
    badge: true,
    carPlay: false,
    criticalAlert: false,
    provisional: false,



    sound: true,
  );
  print('User granted permission: ${settings.authorizationStatus}');

  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    // Handle incoming FCM messages in the foreground
    print('onMessage message recived');
    requestNotificationPermission();
    print('onMessage message recived');

  });
  // FirebaseMessaging.onBackgroundMessage((message) async {
  //   print("Background message received:");
  //   requestNotificationPermission();
  //   // Handle the incoming message here
  //   // IMPORTANT: You need to handle the incoming message here
  //   // because the UI is not available in the background.
  // });
  // FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
  //   print('ffffffffffffffffffffffffffffffffffffffff2');
  //   requestNotificationPermission();
  //   // Handle tapping/opening a notification when the app is in the background
  //   print('onMessageOpenedApp message recived');
  // });


  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  runApp(const App());
}