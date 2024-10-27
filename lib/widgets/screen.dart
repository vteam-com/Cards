import 'package:flutter/material.dart';

class Screen extends StatelessWidget {
  const Screen({
    super.key,
    required this.title,
    required this.child,
  });
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: DecoratedBox(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/table_top.png'),
            fit: BoxFit.cover, // adjust the fit as needed
          ),
        ),
        child: child,
      ),
    );
  }
}
