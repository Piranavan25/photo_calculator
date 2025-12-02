import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:math_expressions/math_expressions.dart';
import 'package:cloud_functions/cloud_functions.dart';

class ScanPage extends StatefulWidget {
  const ScanPage({super.key});

  @override
  State<ScanPage> createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> {
  File? _image;
  final ImagePicker _picker = ImagePicker();
  final TextEditingController _expressionController = TextEditingController();

  String _result = '';
  String _explanation = '';
  bool _loadingExplanation = false;

  /// Take photo from camera
  Future<void> pickImage() async {
    final XFile? pickedFile =
        await _picker.pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
        _result = '';
        _explanation = '';
        _expressionController.text = '';
      });
      await recognizeText(_image!);
    }
  }

  /// Recognize text using ML Kit
  Future<void> recognizeText(File imageFile) async {
    final inputImage = InputImage.fromFile(imageFile);
    final textRecognizer = TextRecognizer();
    final recognizedText = await textRecognizer.processImage(inputImage);

    String detectedExpression = '';
    for (TextBlock block in recognizedText.blocks) {
      for (TextLine line in block.lines) {
        detectedExpression += line.text;
      }
    }

    setState(() {
      _expressionController.text = detectedExpression;
    });
  }

  /// Evaluate math expression locally
  void evaluateExpression() {
    try {
      String expression = _expressionController.text
          .replaceAll('×', '*')
          .replaceAll('÷', '/')
          .replaceAll(' ', '');

      Parser p = Parser();
      Expression exp = p.parse(expression);
      ContextModel cm = ContextModel();
      double eval = exp.evaluate(EvaluationType.REAL, cm);

      setState(() {
        _result = eval.toString();
        _explanation = '';
      });

      // Get explanation from Cloud Function
      getExplanation(expression, _result);
    } catch (e) {
      setState(() {
        _result = 'Error: Invalid expression';
        _explanation = '';
      });
    }
  }

  /// Call Firebase Cloud Function for explanation
  Future<void> getExplanation(String expression, String result) async {
    setState(() {
      _loadingExplanation = true;
    });

    try {
      final HttpsCallable callable =
          FirebaseFunctions.instance.httpsCallable('getMathExplanation');
      final response = await callable.call({
        'expression': expression,
        'result': result,
      });

      setState(() {
        _explanation = response.data['explanation'] ?? '';
        _loadingExplanation = false;
      });
    } catch (e) {
      setState(() {
        _explanation = 'Failed to get explanation';
        _loadingExplanation = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Photo Calculator')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            ElevatedButton.icon(
              onPressed: pickImage,
              icon: const Icon(Icons.camera_alt),
              label: const Text('Take a Photo'),
            ),
            const SizedBox(height: 20),
            if (_image != null)
              Image.file(_image!, height: 200),
            const SizedBox(height: 20),
            TextField(
              controller: _expressionController,
              decoration: const InputDecoration(
                labelText: 'Detected Expression (edit if wrong)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: evaluateExpression,
              child: const Text('Calculate'),
            ),
            const SizedBox(height: 20),
            if (_result.isNotEmpty)
              Text(
                'Result: $_result',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            const SizedBox(height: 20),
            if (_loadingExplanation)
              const CircularProgressIndicator(),
            if (_explanation.isNotEmpty)
              Text(
                'Explanation:\n$_explanation',
                style: const TextStyle(fontSize: 16),
              ),
          ],
        ),
      ),
    );
  }
}
