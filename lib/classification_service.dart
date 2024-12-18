import 'package:tflite_flutter/tflite_flutter.dart'; // TensorFlow Lite interpreter
import 'dart:io';
import 'package:image/image.dart' as img;
import 'package:logger/logger.dart';

// Logger setup with detailed configuration
final logger = Logger(
  printer: PrettyPrinter(
    methodCount: 1, // Number of stack trace methods to show
    errorMethodCount: 3, // Number of methods to show when logging errors
    lineLength: 120, // Width of each log line
    colors: true, // Colorize the logs
    printEmojis: true, // Include emojis in logs
    dateTimeFormat:
        DateTimeFormat.onlyTimeAndSinceStart, // Replaces deprecated printTime
  ),
);

class ClassificationService {
  static late Interpreter _mainInterpreter;
  static late Interpreter _objectDetector;
  static final List<String> _mainLabels = [
    'healthy',
    'black pod',
    'frosty pod',
    'pod borer'
  ];
  static final List<String> _objectLabels = ['cacao', 'random'];

  // Load the models and labels
  static Future<void> loadModels() async {
    try {
      _mainInterpreter =
          await Interpreter.fromAsset('assets/cacaoguard.tflite');
      _objectDetector = await Interpreter.fromAsset('assets/cacaaobj.tflite');
      logger.i('Models loaded successfully');
    } catch (e) {
      logger.e('Error loading models: $e');
    }
  }

  // Preprocess the image for the model (resize and normalize)
  static List<List<List<List<double>>>> _preprocessImage(File image) {
    final imageBytes = image.readAsBytesSync();
    img.Image? originalImage = img.decodeImage(imageBytes);

    img.Image resizedImage =
        img.copyResize(originalImage!, width: 224, height: 224);

    final List<List<List<List<double>>>> input = List.generate(
      1,
      (i) =>
          List.generate(224, (j) => List.generate(224, (k) => [0.0, 0.0, 0.0])),
    );

    for (int y = 0; y < resizedImage.height; y++) {
      for (int x = 0; x < resizedImage.width; x++) {
        final pixel = resizedImage.getPixel(x, y);
        input[0][y][x][0] = img.getRed(pixel) / 255.0;
        input[0][y][x][1] = img.getGreen(pixel) / 255.0;
        input[0][y][x][2] = img.getBlue(pixel) / 255.0;
      }
    }

    return input;
  }

  // Detect if the image contains cacao using the object detector
  static Future<bool> detectCacao(File image) async {
    try {
      logger.i('Running object detection for cacao...');
      final input = _preprocessImage(image);
      final List<List<double>> output =
          List.generate(1, (_) => List.filled(_objectLabels.length, 0.0));

      _objectDetector.run(input, output);

      int bestIndex = 0;
      for (int i = 0; i < output[0].length; i++) {
        if (output[0][i] > output[0][bestIndex]) {
          bestIndex = i;
        }
      }

      logger.i('Object Detection Result: ${_objectLabels[bestIndex]}');
      return _objectLabels[bestIndex] == 'cacao';
    } catch (e) {
      logger.e('Error during object detection: $e');
      return false;
    }
  }

  // Function to classify the image using the main model
  static Future<String> classifyImage(File image) async {
    try {
      logger.i('Starting classification process...');

      // Step 1: Check for cacao in the image
      bool isCacao = await detectCacao(image);
      if (!isCacao) {
        logger.w('Not a cacao image detected. Prompting user to recapture.');
        return 'Not a cacao image. Please capture again.';
      }

      // Step 2: Proceed with main classification
      logger.i('Cacao detected. Proceeding with classification...');
      final input = _preprocessImage(image);
      final List<List<double>> output =
          List.generate(1, (_) => List.filled(_mainLabels.length, 0.0));

      _mainInterpreter.run(input, output);

      int bestIndex = 0;
      for (int i = 0; i < output[0].length; i++) {
        if (output[0][i] > output[0][bestIndex]) {
          bestIndex = i;
        }
      }

      // Log the classification result and confidence
      logger.i('Classification Result: ${_mainLabels[bestIndex]}');
      logger.i('Confidence: ${output[0][bestIndex]}');

      return _mainLabels[bestIndex];
    } catch (e) {
      logger.e('Error during classification: $e');
      return 'Error';
    }
  }
}
