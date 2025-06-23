import 'dart:convert';
import 'package:http/http.dart' as http;

//Criei essa classe pois queria renderizar nos cards dos filmes, os seus respectivos gêneros
class GenreService {
  static const String _apiKey = '69069fa000d3b920f593be1f87924c05';
  static const String _baseUrl = 'https://api.themoviedb.org/3';

  static final GenreService _instance = GenreService._internal();
  factory GenreService() => _instance;
  GenreService._internal();

  Map<int, String> _genreMap = {};

  Future<void> fetchGenres() async {
    final response = await http.get(
      Uri.parse('$_baseUrl/genre/movie/list?api_key=$_apiKey&language=pt-BR'),
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List genres = data['genres'];
      _genreMap = {
        for (var genre in genres) genre['id'] as int: genre['name'] as String
      };
    }
  }

  String getGenreName(int id) {
    return _genreMap[id] ?? 'Desconhecido';
  }

  List<String> getGenreNames(List<int> ids) {
    return ids.map((id) => getGenreName(id)).toList();
  }
}