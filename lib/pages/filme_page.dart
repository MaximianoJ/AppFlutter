import 'package:flutter/material.dart';
import '../models/movie.dart';
import '../services/genre_service.dart';

/// Classe que herda as propriedades da statelesswidget, serve para criar uma tela que carregue os filmes
class MoviePage extends StatelessWidget {
  final Movie movie;
  final bool isSaved;
  final VoidCallback onToggleSave;

  /// [movie]: objeto do filme a ser exibido
  /// [isSaved]: indica se o filme está salvo nos favoritos
  /// [onToggleSave]: função chamada ao clicar no botão de salvar/remover
  const MoviePage({
    super.key,
    required this.movie,
    required this.isSaved,
    required this.onToggleSave,
  });

  @override
  Widget build(BuildContext context) {
    // Fornece a data de lançamento do filme para dd/MM/aaaa
    String releaseDateFormatted = '----';
    if (movie.releaseDate.isNotEmpty && movie.releaseDate.length >= 10) {
      try {
        final date = DateTime.parse(movie.releaseDate);
        releaseDateFormatted =
            '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
      } catch (_) {}
    }

    // Obtém os nomes dos gêneros a partir dos IDs
    final genreNames = GenreService().getGenreNames(movie.genreIds);
    final genre = genreNames.isNotEmpty
        ? genreNames.join(', ')
        : 'Desconhecido';

    return Scaffold(
      backgroundColor: const Color(0xFF22293E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF22293E),
        title: Text(
          movie.title,
          style: const TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          // Botão para salvar/remover dos favoritos/salvos
          IconButton(
            icon: Icon(
              isSaved ? Icons.bookmark : Icons.bookmark_border,
              color: Colors.white,
            ),
            onPressed: onToggleSave,
            tooltip: isSaved ? 'Remover dos salvos' : 'Salvar filme',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Poster/Imagem do filme
            if (movie.posterPath.isNotEmpty)
              Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    'https://image.tmdb.org/t/p/w500${movie.posterPath}',
                    height: 400,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            const SizedBox(height: 24),
            // Título/Nome do filme a ser exibido
            Text(
              movie.title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            // Gêneros que vão ser exibidos nos detalhes
            Row(
              children: [
                const Icon(
                  Icons.confirmation_number,
                  color: Colors.white70,
                  size: 18,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    genre,
                    style: const TextStyle(color: Colors.white70, fontSize: 14),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            // Data de lançamento do filme
            Row(
              children: [
                const Icon(
                  Icons.calendar_today,
                  color: Colors.white70,
                  size: 18,
                ),
                const SizedBox(width: 6),
                Text(
                  releaseDateFormatted,
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
            const SizedBox(height: 6),
            // Nota de aprovação (vote average), que preferi deixar igual da TMBD, sem ser no formato de estrelas.
            Row(
              children: [
                const Icon(Icons.percent, color: Colors.greenAccent, size: 18),
                const SizedBox(width: 6),
                Text(
                  movie.voteAverage != 0.0
                      ? '${(movie.voteAverage * 10).toStringAsFixed(0)}% de aprovação'
                      : '-',
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
            const SizedBox(height: 24),
            // Sinopse do filme que é carregada a partir da API
            const Text(
              'Sinopse',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              movie.overview.isNotEmpty
                  ? movie.overview
                  : 'Sinopse não disponível.',
              style: const TextStyle(color: Colors.white70, fontSize: 15),
            ),
          ],
        ),
      ),
    );
  }
}