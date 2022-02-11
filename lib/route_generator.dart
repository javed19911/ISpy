import 'package:flutter/material.dart';
import 'package:ispy/active_users.dart';
import 'package:ispy/chat.dart';
import 'package:ispy/create_user.dart';
import 'login.dart';

class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    final args = settings.arguments;

    switch (settings.name) {
      case '/':
        return MaterialPageRoute(
          builder: (_) => const Login(),
        );
      case '/create':
        return MaterialPageRoute(
          builder: (_) => const CreateUser(),
        );

      case '/active_user':
        if (args is String) {
          return MaterialPageRoute(
            builder: (_) => ActiveUsers(user: args),
          );
        }
        return _errorRoute();
      case '/user_chat':
        if (args is String) {
          return MaterialPageRoute(
            builder: (_) => UserChat(chatId: args),
          );
        }
        return _errorRoute();
      default:
        // If there is no such named route in the switch statement, e.g. /third
        return _errorRoute();
    }
  }

  static Route<dynamic> _errorRoute() {
    return MaterialPageRoute(builder: (_) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Error'),
        ),
        body: const Center(
          child: Text('ERROR'),
        ),
      );
    });
  }
}

enum Activity { LOGIN, MOVIE }
