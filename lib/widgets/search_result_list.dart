import 'package:flutter/material.dart';
import '../models/movie.dart';
import '../services/genre_service.dart';
import '../models/movie_sort.dart';
import '../pages/filme_page.dart';

/// Classe criada para mostrar os resultados dos filmes ao escrever um título no campo de busca
class SearchResultList extends StatelessWidget {
  final List<Movie> movies;
  final MovieSortOption sortOption;
  final bool Function(Movie) isMovieSaved;
  final Future<void> Function(Movie) onToggleSave;

  /// [movies]: lista de filmes a exibir
  /// [sortOption]: critério de ordenação
  /// [isMovieSaved]: função para verificar se o filme está salvo
  /// [onToggleSave]: função para salvar/remover filme de 'Salvos'
  const SearchResultList({
    super.key,
    required this.movies,
    required this.sortOption,
    required this.onToggleSave,
    required this.isMovieSaved,
  });

  @override
  Widget build(BuildContext context) {
    // Esse widget é para filtrar/ordenar a busca que o usuário quiser fazer, tem toda a lógica usando switch case para dar os valores de forma crescente ou decrescente, ou em ordem alfabética crescente ou descrescente
    final sortedMovies = List<Movie>.from(movies)
      ..sort((a, b) {
        switch (sortOption) {
          case MovieSortOption.yearAsc:
            final yearA = a.releaseDate.isNotEmpty
                ? int.tryParse(a.releaseDate.substring(0, 4)) ?? 0
                : 0;
            final yearB = b.releaseDate.isNotEmpty
                ? int.tryParse(b.releaseDate.substring(0, 4)) ?? 0
                : 0;
            return yearA.compareTo(yearB);
          case MovieSortOption.yearDesc:
            final yearA = a.releaseDate.isNotEmpty
                ? int.tryParse(a.releaseDate.substring(0, 4)) ?? 0
                : 0;
            final yearB = b.releaseDate.isNotEmpty
                ? int.tryParse(b.releaseDate.substring(0, 4)) ?? 0
                : 0;
            return yearB.compareTo(yearA);
          case MovieSortOption.nameAsc:
            return a.title.toLowerCase().compareTo(b.title.toLowerCase());
          case MovieSortOption.nameDesc:
            return b.title.toLowerCase().compareTo(a.title.toLowerCase());
        }
      });

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: sortedMovies.length,
      itemBuilder: (context, index) {
        final movie = sortedMovies[index];

        // Ano de lançamento do filme, retorna linhas se não for conhecido
        final year = movie.releaseDate.isNotEmpty
            ? movie.releaseDate.substring(0, 4)
            : '----';

        // Nome do gênero principal do filme, e se não tiver, retorna como 'Desconhecido'
        final genreNames = GenreService().getGenreNames(movie.genreIds);
        final genre = genreNames.isNotEmpty ? genreNames.first : 'Desconhecido';

        return GestureDetector(
          // Ao tocar, navega para a página de detalhes do filme
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => MoviePage(
                  movie: movie,
                  isSaved: isMovieSaved(movie),
                  onToggleSave: () async {
                    await onToggleSave(movie);
                    // ignore: use_build_context_synchronously
                    Navigator.pop(context); // Fecha a página ao salvar/remover
                  },
                ),
              ),
            );
          },
          child: Card(
            color: const Color(0xFF313F56),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Poster do filme
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: movie.posterPath.isNotEmpty
                        ? Image.network(
                            'https://image.tmdb.org/t/p/w185${movie.posterPath}',
                            width: 90,
                            height: 120,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                Container(
                                  width: 90,
                                  height: 120,
                                  color: Colors.grey[800],
                                  child: const Icon(
                                    Icons.image_not_supported,
                                    color: Colors.white54,
                                  ),
                                ),
                          )
                        : Container(
                            width: 90,
                            height: 120,
                            color: Colors.grey[800],
                            child: const Icon(
                              Icons.image_not_supported,
                              color: Colors.white54,
                            ),
                          ),
                  ),
                  const SizedBox(width: 16),
                  // Informações do filme
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Título
                        Text(
                          movie.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Gênero principal
                        Row(
                          children: [
                            const Icon(
                              Icons.confirmation_number,
                              color: Colors.white70,
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                genre,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        // Ano de lançamento
                        Row(
                          children: [
                            const Icon(
                              Icons.calendar_today,
                              color: Colors.white70,
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              year,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}