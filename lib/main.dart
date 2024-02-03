import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Vishnu\'s Custom YouTube Search App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: SearchPage(),
    );
  }
}

class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _controller = TextEditingController();
  late stt.SpeechToText _speech; // Marked as late
  bool _isListening = false;
  String _text = 'Press the microphone button and start speaking';

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
  }

  String processSearchQuery(String query) {
    final RegExp poduRegex =
        RegExp(r'\bvideo podu\b|\bpodu\b', caseSensitive: false);
    return query.replaceAll(poduRegex, '').trim();
  }

  Future<void> _searchYouTube() async {
    String rawQuery = _controller.text;
    String processedQuery = processSearchQuery(rawQuery);
    processedQuery = processedQuery.replaceAll(' ', '+');
    final Uri url = Uri.parse(
        'https://www.youtube.com/results?search_query=$processedQuery');
    if (!await launchUrl(url)) {
      throw Exception('Could not launch $url');
    }
  }

  void _toggleRecording() async {
    if (_isListening) {
      await _speech.stop(); // No need to assign the result
      setState(() => _isListening = false);
    } else {
      bool available = await _speech.initialize(
        onStatus: (val) => print('onStatus: $val'),
        onError: (val) => print('onError: $val'),
      );
      if (available) {
        setState(() => _isListening = true);
        _speech.listen(
          onResult: (val) => setState(() {
            _text = val.recognizedWords;
            _controller.text = _text; // This should not cause an error
          }),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Vishnu\'s Custom YouTube Search App'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                labelText: 'Enter search term',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: _searchYouTube,
              child: Text('Search on YouTube'),
            ),
            SizedBox(height: 20),
            FloatingActionButton(
              onPressed: _toggleRecording,
              child: Icon(_isListening ? Icons.mic : Icons.mic_none),
            ),
            SizedBox(height: 20),
            Text(
              _text,
              style: TextStyle(
                  fontSize: 16,
                  color: Colors.black,
                  fontWeight: FontWeight.w400),
            ),
          ],
        ),
      ),
    );
  }
}
