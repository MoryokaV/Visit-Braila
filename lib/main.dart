import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:visit_braila/providers/wishlist_provider.dart';
import 'package:visit_braila/utils/style.dart';
import 'package:visit_braila/utils/responsive.dart';
import 'package:visit_braila/widgets/bottom_navbar.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  Responsive().init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: ((_) => Wishlist()),
      child: MaterialApp(
        title: 'Visit Brăila',
        theme: ThemeData(
          scaffoldBackgroundColor: kBackgroundColor,
          primaryColor: kPrimaryColor,
          colorScheme:
              ColorScheme.fromSwatch().copyWith(secondary: kSecondaryColor),
          textTheme: const TextTheme(
            headline4: TextStyle(
              color: kForegroundColor,
              fontFamily: labelFont,
            ),
            button: TextStyle(
              color: kForegroundColor,
              fontFamily: labelFont,
              fontWeight: FontWeight.w600,
              fontSize: 18,
            ),
            bodyText2: TextStyle(
              color: kForegroundColor,
              fontFamily: bodyFont,
              fontSize: 16,
            ),
            headline2: TextStyle(
              color: kForegroundColor,
              fontFamily: bodyFont,
              fontWeight: FontWeight.w700,
              fontSize: 18,
              height: 1.4,
            ),
          ),
        ),
        debugShowCheckedModeBanner: false,
        home: const BottomNavbar(),
      ),
    );
  }
}
