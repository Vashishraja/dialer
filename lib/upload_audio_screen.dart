import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  stt.SpeechToText _speechToText = stt.SpeechToText();
  bool _isSpeechAvailable = false;
  String _convertedText = "";
  String? _audioFilePath;

  @override
  void initState() {
    super.initState();
    _initSpeechToText();
  }

  Future<void> _initSpeechToText() async {
    bool available = await _speechToText.initialize();
    setState(() {
      _isSpeechAvailable = available;
    });
  }

  Future<void> _pickAudioFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.audio);

    if (result != null) {
      setState(() {
        _audioFilePath = result.files.single.path;
      });

      if (_audioFilePath != null && _isSpeechAvailable) {
        _convertAudioToText();
      } else {
        _showError("Speech-to-text is not available or audio file is missing.");
      }
    }
  }

  Future<void> _convertAudioToText() async {
    if (_audioFilePath == null) return;

    try {
      await _speechToText.listen(onResult: (result) {
        setState(() {
          _convertedText = result.recognizedWords;
        });
      });

      // Simulating audio processing completion.
      await Future.delayed(Duration(seconds: 3));
      await _speechToText.stop();
    } catch (e) {
      _showError("Error during audio processing: $e");
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Audio to Text Converter"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton(
              onPressed: _pickAudioFile,
              child: Text("Pick Audio File"),
            ),
            SizedBox(height: 20),
            Text(
              "Converted Text:",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Expanded(
              child: SingleChildScrollView(
                child: Text(
                  _convertedText.isNotEmpty
                      ? _convertedText
                      : "No text available",
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
