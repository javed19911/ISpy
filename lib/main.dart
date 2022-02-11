import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:ispy/create_user.dart';
import 'package:ispy/route_generator.dart';

import 'login.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: 'AIzaSyCuOQ-4v_SMOrl8eg-vuI3rXacx7Y8YzHI',
      appId: '1:27792429408:android:b37cd32564509938490e05',
      messagingSenderId: '27792429408',
      projectId: 'i-spy-7a743',
      databaseURL: 'https://i-spy-7a743-default-rtdb.firebaseio.com',
      storageBucket: 'i-spy-7a743.appspot.com',
    ),
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/',
      onGenerateRoute: RouteGenerator.generateRoute,
      // home: const Login(),
    );
  }
}
