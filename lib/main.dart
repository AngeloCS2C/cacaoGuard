import 'package:flutter/material.dart';
import 'camera_page.dart'; // Import the camera page
import 'classification_service.dart';
import 'loading_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ClassificationService
      .loadModels(); // Load the models when the app starts
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cacao Guard',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/loading', // Set loading screen as the initial route
      routes: {
        '/loading': (context) => const LoadingScreen(),
        '/home': (context) => const MyHomePage(),
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0; // To track which tab is selected

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;

      if (index == 1) {
        // Navigate to camera page when "Scan" is tapped
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const CameraPage()),
        );
      } else if (index == 2) {
        // Show guide modal when "Guide" is tapped
        _showGuideModal(context);
      }
    });
  }

  void _showGuideModal(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'How to Use Cacao Guard',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          content: const SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '1. Press the "Scan" button in the navigation bar.',
                  style: TextStyle(fontSize: 16, height: 1.5),
                ),
                SizedBox(height: 10),
                Text(
                  '2. Choose "Camera" to capture a cacao image or "Upload" to select an existing picture.',
                  style: TextStyle(fontSize: 16, height: 1.5),
                ),
                SizedBox(height: 10),
                Text(
                  '3. Wait a few seconds for the app to analyze the image and display the results.',
                  style: TextStyle(fontSize: 16, height: 1.5),
                ),
                SizedBox(height: 10),
                Text(
                  '4. Press "Check Recommendations" to view prevention and control measures.',
                  style: TextStyle(fontSize: 16, height: 1.5),
                ),
                SizedBox(height: 10),
                Text(
                  'Important Note: This app only identifies Frosty Pod, Pod Borer, Black Pod, and Healthy Cacao. Non-cacao images are not supported.',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[600],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cacao Guard',
            style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.green[300],
      ),
      body: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFA8E063), Color(0xFF61B236)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    spreadRadius: 3,
                    blurRadius: 5,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFFA8E063),
                        width: 4,
                      ),
                    ),
                    child: const CircleAvatar(
                      radius: 40,
                      backgroundImage: AssetImage('assets/healthycacao.jpg'),
                    ),
                  ),
                  const SizedBox(width: 32),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Variety: UF18', style: TextStyle(fontSize: 16)),
                        SizedBox(height: 8),
                        Text('Status: Healthy', style: TextStyle(fontSize: 16)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[400],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  onPressed: () {
                    // Handle Common Problem button press
                  },
                  child: const Text(
                    'Common Problem',
                    style: TextStyle(color: Color.fromARGB(255, 3, 3, 3)),
                  ),
                ),
                const Spacer(),
                const Text('scroll for more  →',
                    style: TextStyle(fontSize: 14)),
              ],
            ),
            const SizedBox(height: 10),
            Flexible(
              child: SizedBox(
                height: screenHeight * 0.35,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    _buildDiseaseCard('assets/disease1.png', screenWidth),
                    _buildDiseaseCard('assets/disease2.png', screenWidth),
                    _buildDiseaseCard('assets/disease3.png', screenWidth),
                    _buildDiseaseCard('assets/disease4.png', screenWidth),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16.0),
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Scan with Cacao Guard!',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
                    ),
                    const SizedBox(height: 5),
                    const Text(
                        '''Learn how to help your sick cacao.\n\nDiscover how to restore your cacao's health by identifying diseases early, understanding their root causes, and implementing the right treatments to keep your cacao plants thriving and productive.'''),
                    const Spacer(),
                    Center(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 8),
                          backgroundColor: Colors.green,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        onPressed: () {
                          // Navigate to the camera page
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const CameraPage()),
                          );
                        },
                        child: const Text('Get Recommendations',
                            style:
                                TextStyle(fontSize: 18, color: Colors.white)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.camera),
            label: 'Scan',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.eco),
            label: 'Guide',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.green[700],
        onTap: _onItemTapped,
      ),
    );
  }

  Widget _buildDiseaseCard(String imagePath, double screenWidth) {
    return Container(
      margin: const EdgeInsets.only(right: 16.0),
      width: screenWidth * 0.35,
      height: 180,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(16),
        image: DecorationImage(
          image: AssetImage(imagePath),
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
