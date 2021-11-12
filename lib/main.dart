import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'views/chatrooms.dart';
import 'helper/authenticate.dart';
import 'package:firebase_core/firebase_core.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool userisLoggedIn = false;

  @override
  void initState() {
    super.initState();
    getLoggedinState();
  }

  getLoggedinState() async {

    var currentUser = await FirebaseAuth.instance.currentUser;
    setState(() {
      userisLoggedIn = currentUser != null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Unitext',
        theme: ThemeData(
          primaryColor: Color(0xff2c2f33),
          scaffoldBackgroundColor: Color(0xff23272a),
        ),
        debugShowCheckedModeBanner: false,
        home: userisLoggedIn ? ChatRoom() : Authenticate());
  }
}