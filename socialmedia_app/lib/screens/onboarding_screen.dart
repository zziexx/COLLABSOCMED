import 'package:flutter/material.dart';
import 'navigation_hub.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _currentPage = 0;

  final List<Map<String, String>> _pages = [
    {
      "title": "Borrow, Don't Buy",
      "desc": "Need a ladder for an hour? Check with your neighbors before hitting the store.",
      "icon": "🛠️"
    },
    {
      "title": "Share the Harvest",
      "desc": "Have too many lemons or tomatoes? Swap them for something fresh next door.",
      "icon": "🌿"
    },
    {
      "title": "Built on Trust",
      "desc": "A verified community where neighbors help neighbors thrive.",
      "icon": "🤝"
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView.builder(
            controller: _controller,
            onPageChanged: (value) => setState(() => _currentPage = value),
            itemCount: _pages.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.all(40.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(_pages[index]["icon"]!, style: const TextStyle(fontSize: 80)),
                    const SizedBox(height: 40),
                    Text(
                      _pages[index]["title"]!,
                      style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      _pages[index]["desc"]!,
                      style: const TextStyle(fontSize: 16, color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            },
          ),

          // Bottom Controls
          Positioned(
            bottom: 50,
            left: 20,
            right: 20,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    _pages.length,
                        (index) => AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      height: 8,
                      width: _currentPage == index ? 24 : 8,
                      margin: const EdgeInsets.only(right: 5),
                      decoration: BoxDecoration(
                        color: const Color(0xFF00695C),
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: () {
                      if (_currentPage == _pages.length - 1) {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => const NavigationHub()),
                        );
                      } else {
                        _controller.nextPage(
                          duration: const Duration(milliseconds: 500),
                          curve: Curves.ease,
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00695C),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    ),
                    child: Text(_currentPage == _pages.length - 1 ? "Get Started" : "Next"),
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
