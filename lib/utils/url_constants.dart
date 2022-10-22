import 'package:url_launcher/url_launcher.dart';

const baseUrl = "http://193.22.95.33:8080";
const apiUrl = "http://193.22.95.33:8080/api";

void openBrowserURL(String url) async {
  if (await canLaunchUrl(Uri.parse(url))) {
    launchUrl(
      Uri.parse(url),
      mode: LaunchMode.externalApplication,
    );
  } else {
    throw "Could not launch $url";
  }
}
