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
              color: kBlackColor,
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
              color: kBlackColor,
              fontFamily: bodyFont,
              fontSize: 20,
              height: 1.4,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.2,
            ),
            headline2: TextStyle(
              color: kBlackColor,
              fontFamily: bodyFont,
              fontWeight: FontWeight.w700,
              fontSize: 18,
              height: 1.3,
              letterSpacing: -0.2,
            ),
            headline3: TextStyle(
              color: kBlackColor,
              fontFamily: bodyFont,
              fontWeight: FontWeight.w600,
              fontSize: 18,
              height: 1.3,
              letterSpacing: -0.1,
            ),
            headline4: TextStyle(
              color: kBlackColor,
              fontFamily: labelFont,
              letterSpacing: -0.1,
            ),
          ),
        ),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
