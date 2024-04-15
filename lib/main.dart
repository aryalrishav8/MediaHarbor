import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mediaharbor/ui/login_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  FirebaseOptions firebaseOptions = const FirebaseOptions(
    appId: '1:446453708339:android:63f777cd5680f2c25e9546',
    apiKey: 'AIzaSyAxqkyH3wPjk5aZqikp3_T_evPXhHxCtAo',
    messagingSenderId: '446453708339',
    projectId: 'mediaharbor-f6e33',
    storageBucket: 'mediaharbor-f6e33.appspot.com',
  );

  await Firebase.initializeApp(options: firebaseOptions);
    runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Home Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: LoginPage(),
    );
  }
}
