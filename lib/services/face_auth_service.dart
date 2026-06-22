import 'dart:io';
import 'dart:math';
import 'package:camera/camera.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;

class FaceAuthService {
  Interpreter? _interpreter;
  final FaceDetector _faceDetector = FaceDetector(
    options: FaceDetectorOptions(
      enableContours: false,
      enableLandmarks: false,
      enableTracking: false,
    ),
  );

  bool _isModelLoaded = false;

  Future<void> initialize() async {
    try {
      _interpreter = await Interpreter.fromAsset('assets/mobilefacenet.tflite');
      _isModelLoaded = true;
      print('Model loaded successfully (Real Mode)');
    } catch (e) {
      print('Failed to load model: $e');
    }
  }

  double cosineSimilarity(List<double> e1, List<double> e2) {
    if (e1.length != e2.length) return 0.0;
    double dotProduct = 0.0;
    double normE1 = 0.0;
    double normE2 = 0.0;
    for (int i = 0; i < e1.length; i++) {
      dotProduct += e1[i] * e2[i];
      normE1 += pow(e1[i], 2);
      normE2 += pow(e2[i], 2);
    }
    if (normE1 == 0 || normE2 == 0) return 0.0;
    return dotProduct / (sqrt(normE1) * sqrt(normE2));
  }

  Future<List<double>?> getFaceEmbedding(String imagePath) async {
    if (!_isModelLoaded || _interpreter == null) {
      print("Model not loaded yet.");
      return null;
    }

    final inputImage = InputImage.fromFilePath(imagePath);
    final faces = await _faceDetector.processImage(inputImage);

    if (faces.isEmpty) {
      print("No face detected");
      return null;
    } else if (faces.length > 1) {
      print("Multiple faces detected");
      return null;
    }

    final face = faces.first;
    
    // Load image with image package
    img.Image? originalImage = img.decodeImage(File(imagePath).readAsBytesSync());
    if (originalImage == null) return null;

    // Crop face from original image with a slight margin for better stability
    int margin = 20; // Add margin to avoid tight unpredictable bounding boxes
    int x = max(0, face.boundingBox.left.toInt() - margin);
    int y = max(0, face.boundingBox.top.toInt() - margin);
    int w = min(originalImage.width - x, face.boundingBox.width.toInt() + (margin * 2));
    int h = min(originalImage.height - y, face.boundingBox.height.toInt() + (margin * 2));

    img.Image croppedFace = img.copyCrop(originalImage, x: x, y: y, width: w, height: h);

    // Resize to 112x112 for MobileFaceNet
    img.Image resizedFace = img.copyResize(croppedFace, width: 112, height: 112);

    // Prepare input tensor: [1, 112, 112, 3] Float32
    var inputList = List.generate(
      1,
      (i) => List.generate(
        112,
        (y) => List.generate(
          112,
          (x) {
            var pixel = resizedFace.getPixel(x, y);
            return [
              (pixel.r - 127.5) / 128.0, // Red
              (pixel.g - 127.5) / 128.0, // Green
              (pixel.b - 127.5) / 128.0  // Blue
            ];
          },
        ),
      ),
    );

    // Output tensor: [1, 192] for MobileFaceNet
    var output = List.generate(1, (i) => List.filled(192, 0.0));

    // Run inference
    _interpreter!.run(inputList, output);
    
    return output[0]; // The 192-dimensional embedding
  }

  void dispose() {
    _faceDetector.close();
    _interpreter?.close();
  }
}
