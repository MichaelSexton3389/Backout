import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:BackOut/screens/home_screen.dart'; // Update with your chat screen import
import '../main.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin = 
      FlutterLocalNotificationsPlugin();
      
  static Future<void> initialize() async {
    // Initialize for Android
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher'); // You can create a dedicated notification icon
    
    // Initialize for iOS
    final DarwinInitializationSettings initializationSettingsIOS = 
        DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        );
    
    // Initialize settings for both platforms
    final InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );
    
    // Initialize the plugin
    await _notificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );
  }
  
  // Request iOS permissions separately (call this in your first screen)
  static Future<void> requestIOSPermissions() async {
    if (Platform.isIOS) {
      await _notificationsPlugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
    }
  }
  
  // Create notification channel for Android
  static Future<void> createNotificationChannel() async {
    if (Platform.isAndroid) {
      const AndroidNotificationChannel channel = AndroidNotificationChannel(
        'chat_messages', // ID
        'Chat Messages', // Name
        description: 'Notifications for new chat messages', // Description
        importance: Importance.high,
      );
      
      await _notificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel);
    }
  }
  
  // Handle notification tap
  static void _onNotificationTapped(NotificationResponse notificationResponse) {
    if (notificationResponse.payload != null) {
      try {
        final data = json.decode(notificationResponse.payload!);
        
        // Handle navigation based on the notification type
        if (data['type'] == 'chat_message') {
          final chatId = data['chatId'];
          
          // Navigate to the chat screen
          navigatorKey.currentState?.push(
            MaterialPageRoute(
              builder: (context) => HomeScreen(), // Replace with your chat screen
              // For example: ChatScreen(chatId: chatId)
            ),
          );
        }
      } catch (e) {
        print('Error handling notification tap: $e');
      }
    }
  }
  
  // Show a notification
  static Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    required String payload,
  }) async {
    // Android notification details
    const AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
      'chat_messages',
      'Chat Messages',
      channelDescription: 'Notifications for new chat messages',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: true,
    );
    
    // iOS notification details
    const DarwinNotificationDetails iosNotificationDetails =
        DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );
    
    // Notification details for both platforms
    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
      iOS: iosNotificationDetails,
    );
    
    // Show the notification
    await _notificationsPlugin.show(
      id,
      title,
      body,
      notificationDetails,
      payload: payload,
    );
  }
}