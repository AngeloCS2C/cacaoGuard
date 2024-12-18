// ignore_for_file: unused_import

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'classification_service.dart';
import 'result_page.dart';
import 'package:logger/logger.dart';
import 'cacaodata.dart';

// Initialize logger
final logger = Logger(
  printer: PrettyPrinter(
    methodCount: 1,
    errorMethodCount: 3,
    lineLength: 120,
    colors: true,
    printEmojis: true,
    dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
  ),
);

late CameraController cameraController;
late Future<void> initializeControllerFuture;

class CameraPage extends StatefulWidget {
  const CameraPage({super.key});

  @override
  CameraPageState createState() => CameraPageState();
}

class CameraPageState extends State<CameraPage> {
  final ImagePicker _picker = ImagePicker();
  File? _imageFile;
  bool _isScanning = false; // Indicates whether scanning is in progress

  @override
  void initState() {
    super.initState();
    initializeCamera();
  }

  void initializeCamera() async {
    final cameras = await availableCameras();
    final firstCamera = cameras.first;

    cameraController = CameraController(
      firstCamera,
      ResolutionPreset.high,
    );

    initializeControllerFuture = cameraController.initialize();
    setState(() {});
  }

  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }

  Future<void> _captureAndClassifyImage() async {
    setState(() {
      _isScanning = true; // Show scanning overlay
    });

    try {
      final image = await cameraController.takePicture();
      logger.i('Picture taken: ${image.path}');

      setState(() {
        _imageFile = File(image.path);
      });

      logger.i('Classifying image...');
      String result = await ClassificationService.classifyImage(_imageFile!);
      logger.i('Classification result: $result');

      if (!mounted) return;

      String diseaseKey = result;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ResultPage(
            diseaseKey: diseaseKey,
            imageFile: _imageFile!,
          ),
        ),
      );
    } catch (e) {
      logger.e('Error capturing or classifying image: $e');
    } finally {
      setState(() {
        _isScanning = false; // Hide scanning overlay
      });
    }
  }

  Future<void> _pickImage() async {
    setState(() {
      _isScanning = true; // Show scanning overlay
    });

    try {
      final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          _imageFile = File(pickedFile.path);
        });

        logger.i('Image selected: ${pickedFile.path}');
        logger.i('Classifying uploaded image...');
        String result = await ClassificationService.classifyImage(_imageFile!);
        logger.i('Classification result from uploaded image: $result');

        if (!mounted) return;

        String diseaseKey = result;

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ResultPage(
              diseaseKey: diseaseKey,
              imageFile: _imageFile!,
            ),
          ),
        );
      } else {
        logger.i('No image selected.');
      }
    } catch (e) {
      logger.e('Error picking image: $e');
    } finally {
      setState(() {
        _isScanning = false; // Hide scanning overlay
      });
    }
  }

  void _deleteImage() {
    setState(() {
      _imageFile = null;
    });
  }

  Widget buildCameraUI() {
    return Stack(
      children: [
        Container(
          padding: const EdgeInsets.all(16.0),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF00C853), Color(0xFFF4FF81)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: _imageFile == null
                      ? CameraPreview(cameraController)
                      : Image.file(
                          _imageFile!,
                          fit: BoxFit.cover,
                        ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Column(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.camera_alt, size: 60),
                        onPressed: _captureAndClassifyImage,
                      ),
                      const Text('Identify', style: TextStyle(fontSize: 18)),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
        Positioned(
          bottom: 16,
          right: 16,
          child: IconButton(
            icon: const Icon(Icons.photo_library, size: 40),
            onPressed: _pickImage,
          ),
        ),
        if (_imageFile != null)
          Positioned(
            top: 16,
            right: 16,
            child: IconButton(
              icon: const Icon(Icons.delete, size: 30, color: Colors.red),
              onPressed: _deleteImage,
            ),
          ),
        if (_isScanning)
          Container(
            color: Colors.black.withOpacity(0.6), // Blurred overlay effect
            child: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    color: Colors.white,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Scanning, please wait...',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cacao Guard - Camera'),
        backgroundColor: Colors.green[300],
      ),
      body: FutureBuilder<void>(
        future: initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return buildCameraUI();
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}
