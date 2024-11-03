import 'package:flutter/material.dart';

class ResponsiveBreakpoints {
  static const double phone = 600;
  static const double tablet = 900;
  static const double desktop = 1200;
}

extension DeviceType on BuildContext {
  bool get isPhone =>
      MediaQuery.of(this).size.width < ResponsiveBreakpoints.phone;
  bool get isTablet =>
      MediaQuery.of(this).size.width >= ResponsiveBreakpoints.phone &&
      MediaQuery.of(this).size.width < ResponsiveBreakpoints.tablet;
  bool get isDesktop =>
      MediaQuery.of(this).size.width >= ResponsiveBreakpoints.desktop;
}

class Screen extends StatelessWidget {
  const Screen({
    super.key,
    required this.title,
    required this.backButton,
    required this.child,
    this.onRefresh,
    this.rightText = '',
  });
  final String title;
  final String rightText;
  final Widget child;
  final bool backButton;
  final Function? onRefresh;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: backButton
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              )
            : null,
        title: Text(
          title,
          style: TextStyle(color: Colors.yellow.shade100.withAlpha(200)),
        ),
        actions: [
          if (onRefresh != null)
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: onRefresh!(),
            ),
          if (rightText.isNotEmpty)
            Padding(
              // Add padding to prevent text from being cut off
              padding: EdgeInsets.only(right: 8.0), // Adjust as needed
              child: Text(rightText),
            ),
        ],
      ),
      body: Stack(
        children: [
          DecoratedBox(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/table_top.png'),
                fit: BoxFit.cover, // adjust the fit as needed
              ),
            ),
            child: SizedBox.expand(
              child: DefaultTextStyle(
                style: TextStyle(
                  color: Colors.green.shade100,
                  fontSize: 20,
                ), // Your default style
                child: child,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
