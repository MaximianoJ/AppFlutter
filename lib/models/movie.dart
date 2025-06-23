/// Classe que vai retornar os filmes pela API do TMDB
class Movie {
  final int id;                // ID único do filme
  final String title;          // Título do filme (no idioma da resposta)
  final String overview;       // Sinopse do filme
  final String posterPath;     // Caminho do poster (imagem)
  final String releaseDate;    // Data de lançamento (formato yyyy-MM-dd)
  final List<int> genreIds;    // Lista de IDs dos gêneros
  final double voteAverage;    // Nota média de avaliação

  Movie({
    required this.id,
    required this.title,
    required this.overview,
    required this.posterPath,
    required this.releaseDate,
    required this.genreIds,
    required this.voteAverage,
  });

  /// Cria um objeto Movie a partir de um JSON retornado pela API
  factory Movie.fromJson(Map<String, dynamic> json) {
    List<int> genreIds = [];
    // A API pode retornar gêneros como lista de IDs ou lista de objetos
    if (json['genre_ids'] != null && json['genre_ids'] is List) {
      genreIds = List<int>.from(json['genre_ids']);
    } else if (json['genres'] != null && json['genres'] is List) {
      genreIds = (json['genres'] as List)
          .map((g) => g is Map && g['id'] != null ? g['id'] as int : null)
          .whereType<int>()
          .toList();
    }

    return Movie(
      id: json['id'],
      title: json['title'] ?? 'Sem título',
      overview: json['overview'] ?? '',
      posterPath: json['poster_path'] ?? '',
      releaseDate: json['release_date'] ?? '',
      genreIds: genreIds,
      voteAverage: (json['vote_average'] != null)
          ? (json['vote_average'] as num).toDouble()
          : 0.0,
    );
  }

  /// Converte o objeto Movie para um Map (útil para salvar em SharedPreferences)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'overview': overview,
      'poster_path': posterPath,
      'release_date': releaseDate,
      'genre_ids': genreIds,
      'vote_average': voteAverage,
    };
  }

  String get originalTitle => title;
}