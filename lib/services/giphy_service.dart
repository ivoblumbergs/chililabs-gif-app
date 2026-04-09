import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:gif_app/models/gif.dart';
import 'package:gif_app/secrets.dart';

Future<List<Gif>> searchGifs(String query, {int offset = 0}) async {
  final url = Uri.parse(
      'https://api.giphy.com/v1/gifs/search?api_key=$giphyApiKey&q=$query&limit=20&rating=g&offset=$offset');

  final response = await http.get(url);
  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    final List items = data['data'];
    return items.map((item) => Gif.fromJson(item)).toList();
  } else {
    throw Exception('Failed to load GIFs');
  }
}
