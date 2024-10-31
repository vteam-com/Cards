import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class TextWithLinkWidget extends StatelessWidget {
  const TextWithLinkWidget({
    super.key,
    required this.text,
    required this.linkText,
    required this.url,
  });
  final String text;
  final String linkText;
  final String url;

  // Function to open the URL
  Future<void> _launchURL(String url) async {
    Uri uri = Uri.parse(url);
    if (!await launchUrl(uri)) {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        children: <TextSpan>[
          TextSpan(
            text: text,
            style: TextStyle(color: Colors.white.withAlpha(200), fontSize: 20),
          ),
          TextSpan(
            text: ' $linkText',
            style: const TextStyle(
              fontSize: 20,
              color: Color.fromARGB(255, 128, 195, 131),
              decoration: TextDecoration.underline,
            ),
            recognizer: TapGestureRecognizer()..onTap = () => _launchURL(url),
          ),
        ],
      ),
    );
  }
}
