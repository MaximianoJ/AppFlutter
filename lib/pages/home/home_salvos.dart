import 'package:app_flutter/models/movie.dart';
import 'package:app_flutter/pages/filme_page.dart';
import 'package:flutter/material.dart';

class HomeSalvos extends StatelessWidget {
  final List<Movie> savedMovies;
  final bool Function(Movie) isMovieSaved;
  final Future<void> Function(Movie) onToggleSave;

  const HomeSalvos({
    super.key,
    required this.savedMovies,
    required this.isMovieSaved,
    required this.onToggleSave, required List<int> savedMovieIds, List<Movie>? searchResults, required List<Movie> trendingMovies, required List<Movie> nowPlayingMovies,
  });

  @override
  Widget build(BuildContext context) {
    if (savedMovies.isEmpty) {
      return const Center(
        child: Text(
          'Nenhum filme salvo.',
          style: TextStyle(color: Colors.white),
        ),
      );
    }

    return ListView.builder(
      itemCount: savedMovies.length,
      itemBuilder: (context, index) {
        final movie = savedMovies[index];
        return Card(
          color: const Color(0xFF313F56),
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.all(12),
            leading: movie.posterPath.isNotEmpty
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      'https://image.tmdb.org/t/p/w92${movie.posterPath}',
                      width: 50,
                      fit: BoxFit.cover,
                    ),
                  )
                : const Icon(Icons.movie, color: Colors.white54, size: 40),
            title: Text(
              movie.title,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Row(
              children: [
                const Icon(
                  Icons.calendar_today,
                  color: Colors.white70,
                  size: 16,
                ),
                const SizedBox(width: 4),
                Text(
                  (movie.releaseDate.isNotEmpty && movie.releaseDate.length >= 4)
                      ? movie.releaseDate.substring(0, 4)
                      : 'Sem ano',
                  style: const TextStyle(color: Colors.white70),
                ),
              ],
            ),
            trailing: IconButton(
              icon: const Icon(Icons.delete, color: Colors.redAccent),
              tooltip: 'Remover dos salvos',
              onPressed: () => onToggleSave(movie),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MoviePage(
                    movie: movie,
                    isSaved: isMovieSaved(movie),
                    onToggleSave: () async {
                      await onToggleSave(movie);
                    },
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
