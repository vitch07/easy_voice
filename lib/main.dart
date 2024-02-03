import 'package:flutter/material.dart';
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
    // Launch URL
    if (!await launchUrl(url)) {
      throw Exception('Could not launch $url');
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
          ],
        ),
      ),
    );
  }
}

Future<void> _launchUrl(Uri url) async {
  if (!await launchUrl(url)) {
    throw Exception('Could not launch $url');
  }
}