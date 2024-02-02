import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:google_translate/google_translate.dart' as translate;

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

  void _navigateToVoiceSearch() {
    Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => VoiceSearchPage(translate.TranslateApi())));
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
            ElevatedButton(
              onPressed: _navigateToVoiceSearch,
              child: Text('Voice Search'),
            ),
          ],
        ),
      ),
    );
  }
}

class VoiceSearchPage extends StatefulWidget {
  final translate.Translate translateApi;

  VoiceSearchPage(this.translateApi);

  @override
  _VoiceSearchPageState createState() => _VoiceSearchPageState();
}

class _VoiceSearchPageState extends State<VoiceSearchPage> {
  final SpeechToText _speechToText = SpeechToText();
  bool _speechEnabled = false;
  String _lastWords = '';

  @override
  void initState() {
    super.initState();
    _initSpeech();
  }

  void _initSpeech() async {
    _speechEnabled = await _speechToText.initialize();
    setState(() {});
  }

  void _startListening() async {
    await _speechToText.listen(onResult: _onSpeechResult);
    setState(() {});
  }

  void _stopListening() async {
    await _speechToText.stop();
    setState(() {});
  }

  void _onSpeechResult(SpeechRecognitionResult result) {
    setState(() {
      _lastWords = result.recognizedWords;
    });
    if (result.finalResult) {
      _performSearch(_lastWords);
    }
  }

  void _performSearch(String searchQuery) async {
    // Translate recognized words to English
    final translatedQuery = await widget.translateApi.translations.list(
      [searchQuery],
      source: 'auto', // Auto-detect source language
      target: 'en', // Translate to English
    );
    final translatedText = translatedQuery.translations[0].translatedText;
    // Construct YouTube search URL
    final processedQuery = translatedText.replaceAll(' ', '+');
    final Uri url = Uri.parse(
        'https://www.youtube.com/results?search_query=$processedQuery');
    // Launch URL
    if (!await launchUrl(url)) {
      throw Exception('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Voice Search'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              padding: EdgeInsets.all(16),
              child: Text(
                'Recognized words:',
                style: TextStyle(fontSize: 20.0),
              ),
            ),
            Expanded(
              child: Container(
                padding: EdgeInsets.all(16),
                child: Text(
                  _speechToText.isListening
                      ? _lastWords
                      : _speechEnabled
                          ? 'Tap the microphone to start listening...'
                          : 'Speech not available',
                  style: TextStyle(fontSize: 20.0),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed:
            _speechToText.isNotListening ? _startListening : _stopListening,
        tooltip: 'Listen',
        child: Icon(_speechToText.isNotListening ? Icons.mic_off : Icons.mic),
      ),
    );
  }
}

Future<bool> launchUrl(Uri url) async {
  if (await canLaunch(url.toString())) {
    await launch(url.toString());
    return true;
  } else {
    return false;
  }
}
