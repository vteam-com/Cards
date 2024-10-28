import 'package:flutter/material.dart';

class Screen extends StatelessWidget {
  const Screen({
    super.key,
    required this.title,
    required this.child,
    required this.backButton,
  });
  final String title;
  final Widget child;
  final bool backButton;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
              child: child,
            ),
          ),
          SafeArea(
            child: Row(
              children: [
                if (backButton)
                  IconButton(
                    icon: const Icon(
                      Icons.arrow_back,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                const SizedBox(
                  width: 20,
                ),
                Expanded(
                  child: Text(
                    title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white, fontSize: 24),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
