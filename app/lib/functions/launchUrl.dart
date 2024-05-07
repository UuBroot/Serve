import 'package:url_launcher/url_launcher.dart';

/// Launches the url in the browser
Future<void> launchURL(String url) async {
  //TODO:find alternative to depricated feature
  // ignore: deprecated_member_use
  if (await canLaunch(url)) {
    // ignore: deprecated_member_use
    await launch(url);
  } else {
    throw 'Could not launch $url';
  }
}
