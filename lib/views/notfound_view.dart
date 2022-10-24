import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:visit_braila/utils/responsive.dart';
import 'package:visit_braila/utils/style.dart';

class NotFoundView extends StatelessWidget {
  const NotFoundView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 30,
            horizontal: 15,
          ),
          child: Stack(
            children: [
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Lottie.asset(
                      "assets/animations/404.json",
                      height: Responsive.safeBlockVertical * 30,
                      fit: BoxFit.contain,
                    ),
                    Text(
                      "Ooops 404!",
                      style: Theme.of(context).textTheme.headline4!.copyWith(
                            fontSize: 32,
                            fontWeight: FontWeight.w700,
                          ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    Text(
                      "Ne pare rău, dar pagina cerută tocmai ce a dispărut... Încearcă mai târziu!",
                      style: Theme.of(context).textTheme.bodyText1!.copyWith(
                            color: kDimmedForegroundColor,
                          ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ), 
              Align(
                alignment: Alignment.bottomCenter,
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    "Înapoi",
                    style: TextStyle(
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
