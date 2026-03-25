//lib/services/navigation_service.dart
import 'package:flutter/material.dart';

class NavigationService {
  static Future slideTo(BuildContext context, Widget page) {
    return Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => page,

        transitionsBuilder: (_, animation, __, child) {
          return SlideTransition(
            position: Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero)
                .animate(
                  CurvedAnimation(parent: animation, curve: Curves.easeInOut),
                ),
            child: child,
          );
        },

        transitionDuration: const Duration(milliseconds: 280),
      ),
    );
  }
}
