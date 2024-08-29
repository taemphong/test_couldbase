import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

//
// *** Edit #1 *** => import plug-in
//

//import 'package:test_cloudbase/database/database_helper.dart';
import 'pages/login.dart';

void main() async {
  //
  // *** Edit #2 *** => Modify main to init firebase plug-in
  //

  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
      ),
      
      //
      // *** Edit #3 *** => modify calling ProductScreen (add new parameter)
      //
    
     home: const LoginScreen(),
    );
  }
}
