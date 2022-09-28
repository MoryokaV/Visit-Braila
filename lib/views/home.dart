import 'package:flutter/material.dart';
import 'package:visit_braila/constants.dart';
import 'package:visit_braila/responsive.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                height: Responsive.safePaddingTop,
                color: Colors.black,
              ),
              Stack(
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Image.asset("assets/images/braila_night.jpg"),
                      Positioned(
                        bottom: 0,
                        child: FractionalTranslation(
                          translation: const Offset(0, 0.5),
                          child: Container(
                            width: Responsive.screenWidth / 1.25,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(100),
                              color: Colors.white,
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.black38,
                                  offset: Offset(0, -1),
                                  blurRadius: 4,
                                ),
                              ],
                            ),
                            child: Center(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 10,
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.search,
                                      color: Theme.of(context).primaryColor,
                                    ),
                                    const SizedBox(
                                      width: 8,
                                    ),
                                    const Text(
                                      "Where are you going?",
                                      style: TextStyle(
                                        color: kDimmedForegroundColor,
                                        fontFamily: "Merriweather",
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 12, top: 24),
                    child: RichText(
                      text: const TextSpan(
                        children: [
                          TextSpan(
                            text: "Brăila",
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          TextSpan(
                            text: " - un oraș istoric de pe malul Dunării",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                        style: TextStyle(
                          color: Colors.white,
                          fontFamily: "Merriweather",
                          height: 1.4,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
