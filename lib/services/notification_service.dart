import 'dart:async';
import 'dart:isolate';
import 'dart:ui';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  static ReceivedAction? initialAction;
  static ReceivePort? receivePort;
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  // Initialize notifications
  Future<void> initialize() async {
    try {
      debugPrint('Initializing notifications...');
      
      // Check if notifications are already initialized
      bool isInitialized = await AwesomeNotifications().isNotificationAllowed();
      debugPrint('Notifications already initialized: $isInitialized');

      await AwesomeNotifications().initialize(
        null, // null for default app icon
        [
          NotificationChannel(
            channelKey: 'basic_channel',
            channelName: 'Basic Notifications',
            channelDescription: 'Basic notification channel for AIONE',
            defaultColor: const Color(0xFF0A0E21),
            ledColor: const Color(0xFF0A0E21),
            importance: NotificationImportance.High,
            channelShowBadge: true,
            enableVibration: true,
            enableLights: true,
            playSound: true,
            criticalAlerts: true,
          ),
          NotificationChannel(
            channelKey: 'image_channel',
            channelName: 'Image Notifications',
            channelDescription: 'Notifications with images for AIONE',
            defaultColor: const Color(0xFF0A0E21),
            ledColor: const Color(0xFF0A0E21),
            importance: NotificationImportance.High,
            channelShowBadge: true,
            enableVibration: true,
            enableLights: true,
            playSound: true,
            criticalAlerts: true,
          ),
        ],
        debug: true,
      );

      debugPrint('Notification channels initialized successfully');

      // Get initial notification action
      initialAction = await AwesomeNotifications()
          .getInitialNotificationAction(removeFromActionEvents: false);
      debugPrint('Initial notification action: ${initialAction?.title}');

      // Initialize isolate receive port
      await initializeIsolateReceivePort();
      
      // Start listening to notifications
      await startListening();
      
      // Start recurring notifications
      await startRecurringNotifications();
      
    } catch (e) {
      debugPrint('Error initializing notifications: $e');
    }
  }

  // Initialize isolate receive port for background notifications
  Future<void> initializeIsolateReceivePort() async {
    receivePort = ReceivePort('Notification action port in main isolate')
      ..listen((silentData) => onActionReceivedImplementationMethod(silentData));

    IsolateNameServer.registerPortWithName(
        receivePort!.sendPort, 'notification_action_port');
  }

  // Start listening to notification events
  Future<void> startListening() async {
    AwesomeNotifications().setListeners(
      onActionReceivedMethod: onActionReceivedMethod,
      onNotificationCreatedMethod: onNotificationCreatedMethod,
      onNotificationDisplayedMethod: onNotificationDisplayedMethod,
      onDismissActionReceivedMethod: onDismissActionReceivedMethod,
    );
  }

  // Handle notification actions
  @pragma('vm:entry-point')
  static Future<void> onActionReceivedMethod(ReceivedAction receivedAction) async {
    if (receivedAction.actionType == ActionType.SilentAction ||
        receivedAction.actionType == ActionType.SilentBackgroundAction) {
      await executeLongTaskInBackground();
    } else {
      if (receivePort == null) {
        SendPort? sendPort =
            IsolateNameServer.lookupPortByName('notification_action_port');
        if (sendPort != null) {
          sendPort.send(receivedAction);
          return;
        }
      }
      return onActionReceivedImplementationMethod(receivedAction);
    }
  }

  // Handle notification creation
  @pragma('vm:entry-point')
  static Future<void> onNotificationCreatedMethod(
      ReceivedNotification receivedNotification) async {
    debugPrint('Notification created: ${receivedNotification.title}');
  }

  // Handle notification display
  @pragma('vm:entry-point')
  static Future<void> onNotificationDisplayedMethod(
      ReceivedNotification receivedNotification) async {
    debugPrint('Notification displayed: ${receivedNotification.title}');
  }

  // Handle notification dismissal
  @pragma('vm:entry-point')
  static Future<void> onDismissActionReceivedMethod(
      ReceivedAction receivedAction) async {
    debugPrint('Notification dismissed: ${receivedAction.title}');
  }

  // Test notifications in different states
  Future<void> testNotificationsInAllStates() async {
    try {
      debugPrint('Testing notifications in all states...');
      
      // Test foreground notification
      await showNotification(
        title: 'Foreground Test',
        body: 'This notification appears when app is open',
        actionButtons: [
          NotificationActionButton(
            key: 'FOREGROUND_ACTION',
            label: 'Action',
          ),
        ],
      );
      debugPrint('Foreground notification sent');

      // Test background notification
      await scheduleNotification(
        title: 'Background Test',
        body: 'This notification appears when app is in background',
        scheduledDate: DateTime.now().add(const Duration(seconds: 5)),
        actionButtons: [
          NotificationActionButton(
            key: 'BACKGROUND_ACTION',
            label: 'Action',
          ),
        ],
      );
      debugPrint('Background notification scheduled');

      // Test terminated state notification
      await scheduleNotification(
        title: 'Terminated Test',
        body: 'This notification appears when app is closed',
        scheduledDate: DateTime.now().add(const Duration(seconds: 10)),
        actionButtons: [
          NotificationActionButton(
            key: 'TERMINATED_ACTION',
            label: 'Action',
          ),
        ],
      );
      debugPrint('Terminated state notification scheduled');
      
    } catch (e) {
      debugPrint('Error testing notifications: $e');
    }
  }

  // Handle notification actions based on state
  static Future<void> onActionReceivedImplementationMethod(
      ReceivedAction receivedAction) async {
    debugPrint('Action received: ${receivedAction.title}');
    
    // Handle different notification actions
    switch (receivedAction.buttonKeyPressed) {
      case 'FOREGROUND_ACTION':
        debugPrint('Foreground notification action pressed');
        break;
      case 'BACKGROUND_ACTION':
        debugPrint('Background notification action pressed');
        break;
      case 'TERMINATED_ACTION':
        debugPrint('Terminated state notification action pressed');
        break;
      default:
        debugPrint('Unknown action pressed: ${receivedAction.buttonKeyPressed}');
    }

    // You can navigate to specific screens based on the notification
    if (navigatorKey.currentContext != null) {
      // Example navigation
      // Navigator.of(navigatorKey.currentContext!).pushNamed('/notification-details');
    }
  }

  // Execute long task in background
  static Future<void> executeLongTaskInBackground() async {
    debugPrint('Executing long task in background');
    await Future.delayed(const Duration(seconds: 4));
    debugPrint('Long task completed');
  }

  // Request notification permissions
  Future<bool> requestPermission() async {
    bool userAuthorized = false;
    BuildContext? context = navigatorKey.currentContext;
    
    if (context == null) return false;

    await showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          title: Text('Enable Notifications',
              style: Theme.of(context).textTheme.titleLarge),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Image.asset(
                      'assets/logo.png',
                      height: MediaQuery.of(context).size.height * 0.2,
                      fit: BoxFit.contain,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Text(
                  'Stay updated with AIONE! Enable notifications to receive important updates and alerts.'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(ctx).pop();
              },
              child: Text(
                'Not Now',
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(color: Colors.red),
              ),
            ),
            TextButton(
              onPressed: () async {
                userAuthorized = true;
                Navigator.of(ctx).pop();
              },
              child: Text(
                'Enable',
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(color: const Color(0xFF0A0E21)),
              ),
            ),
          ],
        );
      },
    );

    return userAuthorized &&
        await AwesomeNotifications().requestPermissionToSendNotifications();
  }

  // Show notification with improved error handling
  Future<void> showNotification({
    required String title,
    required String body,
    String? bigPicture,
    String? largeIcon,
    Map<String, String>? payload,
    List<NotificationActionButton>? actionButtons,
  }) async {
    try {
      debugPrint('Attempting to show notification: $title');
      
      bool isAllowed = await AwesomeNotifications().isNotificationAllowed();
      debugPrint('Notification permission status: $isAllowed');
      
      if (!isAllowed) {
        isAllowed = await requestPermission();
        debugPrint('Permission requested, status: $isAllowed');
      }
      
      if (!isAllowed) {
        debugPrint('Cannot show notification: Permission denied');
        return;
      }

      await AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: DateTime.now().millisecondsSinceEpoch.remainder(100000),
          channelKey: bigPicture != null ? 'image_channel' : 'basic_channel',
          title: title,
          body: body,
          bigPicture: bigPicture,
          largeIcon: largeIcon,
          notificationLayout: bigPicture != null
              ? NotificationLayout.BigPicture
              : NotificationLayout.Default,
          payload: payload,
          category: NotificationCategory.Message,
          wakeUpScreen: true,
          fullScreenIntent: true,
          criticalAlert: true,
          autoDismissible: false,
        ),
        actionButtons: actionButtons,
      );
      
      debugPrint('Notification created successfully');
    } catch (e) {
      debugPrint('Error showing notification: $e');
    }
  }

  // Schedule notification
  Future<void> scheduleNotification({
    required String title,
    required String body,
    required DateTime scheduledDate,
    String? bigPicture,
    String? largeIcon,
    Map<String, String>? payload,
    List<NotificationActionButton>? actionButtons,
    bool repeat = false,
  }) async {
    bool isAllowed = await AwesomeNotifications().isNotificationAllowed();
    if (!isAllowed) isAllowed = await requestPermission();
    if (!isAllowed) return;

    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: -1,
        channelKey: bigPicture != null ? 'image_channel' : 'basic_channel',
        title: title,
        body: body,
        bigPicture: bigPicture,
        largeIcon: largeIcon,
        notificationLayout: bigPicture != null
            ? NotificationLayout.BigPicture
            : NotificationLayout.Default,
        payload: payload,
      ),
      schedule: NotificationCalendar(
        year: scheduledDate.year,
        month: scheduledDate.month,
        day: scheduledDate.day,
        hour: scheduledDate.hour,
        minute: scheduledDate.minute,
        second: scheduledDate.second,
        repeats: repeat,
      ),
      actionButtons: actionButtons,
    );
  }

  // Cancel all notifications
  Future<void> cancelAllNotifications() async {
    await AwesomeNotifications().cancelAll();
  }

  // Reset badge counter
  Future<void> resetBadgeCounter() async {
    await AwesomeNotifications().resetGlobalBadge();
  }

  // Test notification
  Future<void> testNotification() async {
    try {
      debugPrint('Testing notification...');
      bool isAllowed = await AwesomeNotifications().isNotificationAllowed();
      debugPrint('Notification permission status: $isAllowed');

      if (!isAllowed) {
        isAllowed = await requestPermission();
        debugPrint('Permission requested, status: $isAllowed');
      }

      if (isAllowed) {
        await showNotification(
          title: 'Test Notification',
          body: 'This is a test notification at ${DateTime.now()}',
          actionButtons: [
            NotificationActionButton(
              key: 'TEST_ACTION',
              label: 'Test Action',
            ),
          ],
        );
        debugPrint('Test notification sent successfully');
      } else {
        debugPrint('Cannot send notification: Permission denied');
      }
    } catch (e) {
      debugPrint('Error sending test notification: $e');
    }
  }

  // Schedule recurring notifications every 3 hours
  Future<void> scheduleRecurringNotifications() async {
    try {
      debugPrint('Scheduling recurring notifications...');
      
      // List of different notification messages
      final List<Map<String, String>> notificationMessages = [
        {
          'title': 'Time to Check AIONE!',
          'body': 'Discover new AI features and updates waiting for you.',
        },
        {
          'title': 'Your AI Assistant is Ready',
          'body': 'Need help with something? Your AI assistant is here to help!',
        },
        {
          'title': 'New AI Insights Available',
          'body': 'Check out the latest AI-powered insights and recommendations.',
        },
        {
          'title': 'Stay Connected with AIONE',
          'body': 'Keep exploring the power of AI with AIONE.',
        },
        {
          'title': 'AI Task Reminder',
          'body': 'Your AI tasks are waiting for your attention.',
        },
        {
          'title': 'AIONE Update',
          'body': 'New features and improvements are available for you to explore.',
        },
        {
          'title': 'AI Learning Opportunity',
          'body': 'Learn something new with AIONE\'s AI capabilities.',
        },
        {
          'title': 'Your AI Journey Continues',
          'body': 'Keep progressing with your AI-powered tasks and goals.',
        },
      ];

      // Schedule notifications for the next 24 hours (8 notifications)
      for (int i = 0; i < 8; i++) {
        final message = notificationMessages[i % notificationMessages.length];
        final scheduledTime = DateTime.now().add(Duration(hours: i * 3));
        
        await scheduleNotification(
          title: message['title']!,
          body: message['body']!,
          scheduledDate: scheduledTime,
          actionButtons: [
            NotificationActionButton(
              key: 'RECURRING_ACTION_$i',
              label: 'Open App',
            ),
          ],
        );
        
        debugPrint('Scheduled notification for ${scheduledTime.toString()}');
      }
      
      debugPrint('Successfully scheduled all recurring notifications');
    } catch (e) {
      debugPrint('Error scheduling recurring notifications: $e');
    }
  }

  // Start recurring notifications
  Future<void> startRecurringNotifications() async {
    try {
      // Cancel any existing notifications first
      await cancelAllNotifications();
      
      // Schedule new recurring notifications
      await scheduleRecurringNotifications();
      
      // Schedule a task to reschedule notifications every 24 hours
      Timer.periodic(const Duration(hours: 24), (timer) async {
        await scheduleRecurringNotifications();
      });
      
      debugPrint('Started recurring notification schedule');
    } catch (e) {
      debugPrint('Error starting recurring notifications: $e');
    }
  }
} 