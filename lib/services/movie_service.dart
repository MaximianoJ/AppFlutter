import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/movie.dart';

/// classe para construir o serviço responsável por buscar filmes na API do TMDB
class MovieService {
  static const String _apiKey = '69069fa000d3b920f593be1f87924c05';
  static const String _baseUrl = 'https://api.themoviedb.org/3';

  /// Busca filmes em destaque (tendências da semana) em português na API
  Future<List<Movie>> fetchTrendingMovies() async {
    final url = Uri.parse(
      '$_baseUrl/trending/movie/week?api_key=$_apiKey&language=pt-BR',
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List results = json.decode(response.body)['results'];
      // Converte cada resultado em um objeto Movie que foi declarado em movie.dart
      return results.map((movieJson) => Movie.fromJson(movieJson)).toList();
    } else {
      throw Exception('Falha ao carregar filmes: ${response.statusCode}');
    }
  }

  /// Busca filmes pelo termo digitado (em qualquer idioma) e retorna detalhes em português
  Future<List<Movie>> searchMovies(String query) async {
    // Busca inicial sem filtro de idioma para encontrar qualquer filme pelo nome
    final response = await http.get(
      Uri.parse('$_baseUrl/search/movie?api_key=$_apiKey&query=$query'),
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List results = data['results'];
      List<Movie> movies = [];
      // Para cada resultado, busca os detalhes em português
      for (var jsonMovie in results) {
        try {
          final movie = await fetchMovieDetails(jsonMovie['id']);
          movies.add(movie);
        } catch (e) {
          // Se falhar, adiciona o resultado original mesmo assim
          movies.add(Movie.fromJson(jsonMovie));
        }
      }
      return movies;
    } else {
      throw Exception('Erro ao buscar filmes');
    }
  }

  /// Busca detalhes completos de um filme pelo ID, sempre em português
  Future<Movie> fetchMovieDetails(int movieId) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/movie/$movieId?api_key=$_apiKey&language=pt-BR'),
    );
    if (response.statusCode == 200) {
      return Movie.fromJson(json.decode(response.body));
    } else {
      throw Exception('Erro ao buscar detalhes do filme');
    }
  }

  /// Busca filmes em cartaz no cinema, em português
  Future<List<Movie>> fetchNowPlayingMovies() async {
    final url = Uri.parse(
      '$_baseUrl/movie/now_playing?api_key=$_apiKey&language=pt-BR',
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List results = json.decode(response.body)['results'];
      // Converte cada resultado em um objeto Movie
      return results.map((movieJson) => Movie.fromJson(movieJson)).toList();
    } else {
      throw Exception('Erro ao carregar filmes em cartaz');
    }
  }
}