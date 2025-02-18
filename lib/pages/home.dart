import 'package:flutter/material.dart';
import '../pages/user_page.dart';
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          constraints: BoxConstraints(
            maxHeight: 1500,
            maxWidth: 1000
          ),
          child: Padding(
            padding: const EdgeInsets.all(30.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      onPressed: () => {}, 
                      icon: Icon(Icons.timer),
                      iconSize: 40.0,
                    ),
                    IconButton(
                      onPressed: () async => {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const UserPage()),
                        )
                      }, 
                      icon: Icon(Icons.person_4),
                      iconSize: 40.0,
                    ),
                  ],
                ),
                SizedBox(height: 30.0),
                Placeholder(),
                
              ],
            ),
          ),
        ),
      ),
    );
  }
}