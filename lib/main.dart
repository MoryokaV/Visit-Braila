import 'package:flutter/material.dart';
import 'package:visit_braila/constants.dart';
import 'package:visit_braila/responsive.dart';
import 'package:visit_braila/views/home.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  Responsive().init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Visit Brăila',
      theme: ThemeData(
        scaffoldBackgroundColor: kBackgroundColor,
        primaryColor: kPrimaryColor,
        colorScheme:
            ColorScheme.fromSwatch().copyWith(secondary: kSecondaryColor),
        textTheme: const TextTheme(
          bodyText2: TextStyle(
            color: kForegroundColor,
            fontFamily: "Merriweather",
            fontSize: 16,
          ),
        ),
      ),
      debugShowCheckedModeBanner: false,
      home: const Home(),
    );
  }
}
