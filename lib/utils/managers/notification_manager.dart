import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

class NotificationManager {
  static final GlobalKey<ScaffoldMessengerState> _messengerKey = GlobalKey<ScaffoldMessengerState>();
  
  static GlobalKey<ScaffoldMessengerState> get messengerKey => _messengerKey;

  static void showToast(
    BuildContext context, {
    required String message,
    required IconData icon,
    Color backgroundColor = Colors.black87,
    Color iconColor = Colors.white,
    Duration duration = const Duration(seconds: 3),
  }) {
    try {
      final messenger = _messengerKey.currentState ?? ScaffoldMessenger.of(context);
      if (messenger == null) return;
      
      messenger.showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(icon, color: iconColor, size: 28),
              SizedBox(width: 12),
              Expanded(child: Text(message, style: TextStyle(fontWeight: FontWeight.bold))),
            ],
          ),
          backgroundColor: backgroundColor,
          behavior: SnackBarBehavior.floating,
          duration: duration,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        ),
      );
    } catch (e) {
      debugPrint('Error showing notification: $e');
    }
  }

  static void showGlobalToast({
    required String message,
    required IconData icon,
    Color backgroundColor = Colors.black87,
    Color iconColor = Colors.white,
    Duration duration = const Duration(seconds: 3),
  }) {
    try {
      final messenger = _messengerKey.currentState;
      if (messenger == null) return;
      
      messenger.showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(icon, color: iconColor, size: 28),
              SizedBox(width: 12),
              Expanded(child: Text(message, style: TextStyle(fontWeight: FontWeight.bold))),
            ],
          ),
          backgroundColor: backgroundColor,
          behavior: SnackBarBehavior.floating,
          duration: duration,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 16,
            bottom: MediaQuery.of(messenger.context).size.height - 100,
          ),
        ),
      );
    } catch (e) {
      debugPrint('Error showing global notification: $e');
    }
  }
} 