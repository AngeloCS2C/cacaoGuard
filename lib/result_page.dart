import 'package:flutter/material.dart';
import 'dart:io';
import 'cacaodata.dart'; // Make sure to adjust the import path

class ResultPage extends StatelessWidget {
  final String diseaseKey;
  final File imageFile;

  const ResultPage({
    super.key,
    required this.diseaseKey,
    required this.imageFile,
  });

  @override
  Widget build(BuildContext context) {
    // Fetch the disease data from cacaodata
    Map<String, dynamic>? diseaseData = DiseaseInfo.cacaodata[diseaseKey];

    // If the data is found, extract the description and recommendations
    String descriptionData =
        diseaseData?['description'] ?? 'No description available.';
    List recommendations = diseaseData?['recommendations'] ?? [];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Result Page'),
        backgroundColor: Colors.green[300],
      ),
      body: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF00C853), Color(0xFFF4FF81)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            // Top section for displaying the image capture or uploaded image
            Expanded(
              flex: 3,
              child: Container(
                height: 250,
                width: 250,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: Image.file(
                    imageFile,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),

            // Middle section for displaying the result (disease name)
            Expanded(
              flex: 1,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      spreadRadius: 2,
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(10.0),
                child: Center(
                  child: Text(
                    diseaseKey,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Bottom section for description
            Expanded(
              flex: 3,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      spreadRadius: 2,
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Sticky header for description title
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 8.0),
                      decoration: const BoxDecoration(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(16),
                          topRight: Radius.circular(16),
                        ),
                        color: Color.fromARGB(255, 226, 242, 11),
                      ),
                      child: const Text(
                        "Description",
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    // Scrollable description content
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(28.0),
                        child: SingleChildScrollView(
                          child: Text(
                            descriptionData,
                            style: const TextStyle(
                              fontSize: 16,
                              height: 1.5,
                              fontWeight: FontWeight.w400,
                            ),
                            textAlign: TextAlign.justify,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Button to check recommendations
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Colors.green[700],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                minimumSize:
                    const Size(double.infinity, 50), // Full-width button
              ),
              onPressed: () {
                // Display the recommendations on press
                showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: const Text('Prevention and Control Measures'),
                      content: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: recommendations.map<Widget>((rec) {
                            return Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 4.0),
                              child: Text(rec['text']),
                            );
                          }).toList(),
                        ),
                      ),
                      actions: [
                        ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: const Text('Close'),
                        ),
                      ],
                    );
                  },
                );
              },
              child: const Text(
                'Check Recommendations',
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
