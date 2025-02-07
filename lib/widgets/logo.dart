import 'package:flutter/material.dart';

class Logo extends StatelessWidget {
  const Logo({super.key});

  @override
  Widget build(BuildContext context) {
    // Check if we have an small screen
    final bool isSmallScreen = MediaQuery.of(context).size.width < 600;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset('assets/icon.png',
            width: isSmallScreen ? 100 : 200,
            height: isSmallScreen ? 100 : 200),
        Padding(
          padding: EdgeInsets.symmetric(vertical: 30.0),
          child: Text(
            "Welcome to PrioritEase!",
            textAlign: TextAlign.center,
            style: isSmallScreen
                ? Theme.of(context).textTheme.headlineSmall
                : Theme.of(context)
                    .textTheme
                    .headlineMedium
                    ?.copyWith(color: Colors.black87),
          ),
        )
      ],
    );
  }
}