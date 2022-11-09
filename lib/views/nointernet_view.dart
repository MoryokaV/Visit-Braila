import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:visit_braila/services/connection_service.dart';
import 'package:visit_braila/utils/responsive.dart';
import 'package:visit_braila/utils/style.dart';

class NoInternetView extends StatelessWidget {
  final bool start;
  const NoInternetView({
    super.key,
    required this.start,
  });

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
                        color: kDisabledIconColor,
                      ),
                      const SizedBox(
                        height: 30,
                      ),
                      Text(
                        "Oops!",
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
                        "Conexiunea la internet se pare că este offline. Mai încearcă.",
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
                  child: Consumer<ConnectionService>(
                    builder: (context, connection, _) {
                      if (connection.isOnline && start) {
                        Navigator.pushNamed(context, '/');
                      }

                      if (start) {
                        return const SizedBox();
                      }
                      return TextButton(
                        onPressed: connection.isOnline ? () => Navigator.pop(context) : null,
                        child: const Text(
                          "Înapoi",
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
