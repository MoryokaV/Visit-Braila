import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:visit_braila/providers/wishlist_provider.dart';
import 'package:visit_braila/services/localstorage_service.dart';
import 'package:visit_braila/utils/style.dart';
import 'package:visit_braila/utils/responsive.dart';
import 'package:visit_braila/utils/router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await LocalStorage.init();

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
        initialRoute: '/',
        onGenerateRoute: PageRouter.generateRoute,
        theme: ThemeData(
          scaffoldBackgroundColor: kBackgroundColor,
          primaryColor: kPrimaryColor,
          colorScheme:
              ColorScheme.fromSwatch().copyWith(secondary: kSecondaryColor),
          textTheme: const TextTheme(
            button: TextStyle(
              color: kForegroundColor,
              fontFamily: labelFont,
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
            bodyText1: TextStyle(
              color: kForegroundColor,
              fontFamily: bodyFont,
              fontSize: 14,
            ),
            bodyText2: TextStyle(
              color: kForegroundColor,
              fontFamily: bodyFont,
              fontSize: 16,
            ),
            headline1: TextStyle(
              color: kForegroundColor,
              fontFamily: bodyFont,
              fontSize: 20,
              height: 1.4,
              fontWeight: FontWeight.w700,
            ),
            headline2: TextStyle(
              color: kForegroundColor,
              fontFamily: bodyFont,
              fontWeight: FontWeight.w700,
              fontSize: 18,
              height: 1.4,
            ),
            headline4: TextStyle(
              color: kForegroundColor,
              fontFamily: labelFont,
            ),
          ),
        ),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
