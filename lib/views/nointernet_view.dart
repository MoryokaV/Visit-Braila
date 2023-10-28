import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:visit_braila/services/connection_service.dart';
import 'package:visit_braila/utils/responsive.dart';
import 'package:visit_braila/utils/style.dart';

class NoInternetView extends StatelessWidget {
  const NoInternetView({super.key});

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
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
                      SvgPicture.asset(
                        "assets/icons/wifi-off.svg",
                        height: Responsive.safeBlockVertical * 15,
                        fit: BoxFit.contain,
                        colorFilter: ColorFilter.mode(kDisabledIconColor, BlendMode.srcIn),
                      ),
                      const SizedBox(
                        height: 30,
                      ),
                      Text(
                        "Oops!",
                        style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                              fontSize: 32,
                              fontWeight: FontWeight.w700,
                            ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      Text(
                        "Conexiunea la internet se pare că este offline. Mai încearcă.",
                        style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                              color: kDimmedForegroundColor,
                            ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Consumer<ConnectionService>(
                    builder: (context, connection, _) {
                      return TextButton(
                        onPressed: connection.isOnline
                            ? () {
                                connection.popup = false;
                                Navigator.of(context).pushReplacementNamed('/');
                              }
                            : null,
                        child: const Text(
                          "Reîncearcă",
                          style: TextStyle(
                            fontSize: 18,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
