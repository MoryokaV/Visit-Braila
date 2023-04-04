import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:visit_braila/firebase_options.dart';
import 'package:visit_braila/providers/wishlist_provider.dart';
import 'package:visit_braila/services/connection_service.dart';
import 'package:visit_braila/services/dynamic_links_service.dart';
import 'package:visit_braila/services/localstorage_service.dart';
import 'package:visit_braila/services/location_service.dart';
import 'package:visit_braila/services/messaging_service.dart';
import 'package:visit_braila/utils/navigation_util.dart';
import 'package:visit_braila/utils/style.dart';
import 'package:visit_braila/utils/responsive.dart';
import 'package:visit_braila/utils/router.dart';
import 'package:visit_braila/utils/url_constants.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await trustServer();

  await LocalStorage.init();

  await Responsive().init();

  await ConnectionService.init();

  await LocationService.init();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await DynamicLinksService.startUrl();

  await DynamicLinksService.init();

  await MessagingService.init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => Wishlist()),
        ChangeNotifierProvider(create: (_) => ConnectionService()),
        ChangeNotifierProvider(create: (_) => LocationService()),
      ],
      child: MaterialApp(
        title: 'Visit Brăila',
        initialRoute: '/',
        navigatorKey: NavigationUtil.navigatorKey,
        onGenerateRoute: PageRouter.generateRoute,
        onUnknownRoute: PageRouter.unknownRoute,
        theme: ThemeData(
          scaffoldBackgroundColor: kBackgroundColor,
          primaryColor: kPrimaryColor,
          colorScheme: ColorScheme.fromSwatch().copyWith(secondary: kSecondaryColor),
          textTheme: const TextTheme(
            labelLarge: TextStyle(
              color: kBlackColor,
              fontFamily: labelFont,
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
            bodyLarge: TextStyle(
              color: kForegroundColor,
              fontFamily: labelFont,
              fontSize: 16,
            ),
            bodyMedium: TextStyle(
              color: kForegroundColor,
              fontFamily: bodyFont,
              fontSize: 16,
            ),
            displayLarge: TextStyle(
              color: kBlackColor,
              fontFamily: bodyFont,
              fontSize: 24,
              height: 1.4,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.2,
            ),
            displayMedium: TextStyle(
              color: kBlackColor,
              fontFamily: bodyFont,
              fontWeight: FontWeight.w700,
              fontSize: 20,
              height: 1.3,
              letterSpacing: -0.2,
            ),
            displaySmall: TextStyle(
              color: kBlackColor,
              fontFamily: bodyFont,
              fontWeight: FontWeight.w600,
              fontSize: 18,
              height: 1.3,
              letterSpacing: -0.1,
            ),
            headlineMedium: TextStyle(
              color: kForegroundColor,
              fontFamily: labelFont,
              letterSpacing: -0.1,
              fontSize: 20,
            ),
          ),
        ),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
