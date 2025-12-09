import 'package:flutter/material.dart';
import 'word_builder.dart';
import 'memory_match.dart'; 
import 'homepage.dart'; 

void main() {
  runApp(MaterialApp(home: PlayWithLaweh()));
}


// ignore: use_key_in_widget_constructors
class PlayWithLaweh extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFE7EAF6),
     appBar: AppBar(
  backgroundColor: Colors.transparent,
  elevation: 0,
  automaticallyImplyLeading: false, 
  actions: [
    IconButton(
      icon: const Icon(Icons.arrow_forward, color: Colors.black), 
      onPressed: () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => HomePage()),
        );
      },
    ),
    Padding(
      padding: const EdgeInsets.all(8.0),
     
    ),
  ],
),

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 10),
              const Text(
                'العب مع لوّح',
                style: TextStyle(
                  fontSize: 60,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF113F67),
                  fontFamily: 'Tajawal',
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'العب، استكشف وتعلّم',
                style: TextStyle(
                  fontSize: 22,
                  color: Colors.black54,
                  fontFamily: 'Tajawal',
                ),
              ),
              const SizedBox(height: 120), 
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start, 
                  children: [
                    _buildOptionCard(
                      context,
                      image: 'assets/memoryGame.jpg',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => MemoryMatchGameScreen(),
                          ),
                        );
                      },
                    ),
                    SizedBox(height: 40),
                    _buildOptionCard(
                      context,
                      image: 'assets/buildWord.jpg',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                         builder: (_) => WordBuilderGame(),

                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOptionCard(BuildContext context,
      {required String image, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 120,
        margin: const EdgeInsets.only(bottom: 16), 
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          image: DecorationImage(
            image: AssetImage(image),
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}