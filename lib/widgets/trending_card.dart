import 'package:flutter/material.dart';
import '../models/movie.dart';
import '../pages/filme_page.dart';

/// Card para exibir um filme em Tendências
class TrendingCard extends StatelessWidget {
  final Movie movie;
  final bool isSaved;
  final Future<void> Function() onToggleSave;

  /// [movie]: objeto do filme exibido no card
  /// [isSaved]: indica se o filme está salvo nos favoritos
  /// [onToggleSave]: função chamada para salvar/remover o filme da tela de Salvos
  const TrendingCard({
    super.key,
    required this.movie,
    required this.isSaved,
    required this.onToggleSave,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // Ao tocar no card, navega para a tela de detalhes do filme
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MoviePage(
              movie: movie,
              isSaved: isSaved,
              onToggleSave: onToggleSave,
            ),
          ),
        );
      },
      //Aqui é a container que os cards dos filmes vão ficar
      child: Container(
        width: 230,
        height: 360,
        margin: const EdgeInsets.symmetric(horizontal: 6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          image: DecorationImage(
            image: NetworkImage(
              'https://image.tmdb.org/t/p/w500${movie.posterPath}',
            ),
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}