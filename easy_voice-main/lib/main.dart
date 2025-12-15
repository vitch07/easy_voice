import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:url_launcher/url_launcher.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Custom YouTube Search App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const PlaygroundPageWidget(),
    );
  }
}

class PlaygroundPageWidget extends StatefulWidget {
  const PlaygroundPageWidget({super.key});

  @override
  PlaygroundPageWidgetState createState() => PlaygroundPageWidgetState();
}

class PlaygroundPageWidgetState extends State<PlaygroundPageWidget> {
  final TextEditingController _controller = TextEditingController();
  late stt.SpeechToText _speech;
  bool _isListening = false;
  String _text = 'Press the microphone button and start speaking';

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
  }

  void _toggleRecording() async {
    var microphoneStatus = await Permission.microphone.status;
    if (!microphoneStatus.isGranted) {
      await Permission.microphone.request();
    }

    microphoneStatus = await Permission.microphone.status;
    if (microphoneStatus.isGranted) {
      if (_isListening) {
        await _speech.stop();
        setState(() => _isListening = false);
      } else {
        bool available = await _speech.initialize();
        if (available) {
          setState(() => _isListening = true);
          _speech.listen(
            onResult: (result) => setState(() {
              _text = result.recognizedWords;
              _controller.text = _text;
            }),
          );
        }
      }
    } else {
      // Microphone permission is denied
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Microphone permission is denied.')),
        );
      }
    }
  }

  Future<void> _searchYouTube() async {
    String rawQuery = _text; // Use recognized text as query
    String processedQuery = rawQuery.replaceAll(' ', '+');
    final Uri url = Uri.parse(
      'https://www.youtube.com/results?search_query=$processedQuery',
    );
    if (!await launchUrl(url)) {
      throw Exception('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 180, 204, 235),
      body: SafeArea(
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Stack(
            children: [
              const Align(
                alignment: AlignmentDirectional(0, -1),
                child: Text(
                  'Easy Voice Search',
                  style: TextStyle(
                    color: Color.fromARGB(255, 18, 22, 248),
                    fontWeight: FontWeight.w600,
                    fontSize: 30,
                  ),
                ),
              ),
              Align(
                alignment: const AlignmentDirectional(0, -0.75),
                child: ElevatedButton(
                  onPressed: _toggleRecording,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    minimumSize: const Size(160, 160),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Icon(
                    _isListening ? Icons.mic : Icons.mic_none,
                    size: 150,
                  ),
                ),
              ),
              Align(
                alignment: const AlignmentDirectional(0, 0.5),
                child: ElevatedButton(
                  onPressed: _searchYouTube,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF70707),
                    minimumSize: const Size(160, 160),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Icon(Icons.ondemand_video, size: 150),
                ),
              ),
              Align(
                alignment: const AlignmentDirectional(0, -0.1),
                child: Text(
                  _text,
                  style: const TextStyle(
                    color: Color(0xFF101213),
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
