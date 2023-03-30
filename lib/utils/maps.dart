import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:map_launcher/map_launcher.dart';
import 'package:visit_braila/utils/style.dart';

void openMap(double latitude, double longitude, String name, BuildContext context) async {
  final availableMaps = await MapLauncher.installedMaps;

  if (context.mounted) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: SingleChildScrollView(
            child: SizedBox(
              child: Wrap(
                children: [
                  for (var map in availableMaps)
                    ListTile(
                      onTap: () => map.showMarker(
                        coords: Coords(latitude, longitude),
                        title: name,
                      ),
                      title: Text(
                        map.mapName,
                        style: const TextStyle(
                          fontFamily: labelFont,
                        ),
                      ),
                      leading: SvgPicture.asset(
                        map.icon,
                        height: 30,
                        width: 30,
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}