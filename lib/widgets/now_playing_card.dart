import 'package:flutter/material.dart';
import '../models/movie.dart';
import '../pages/filme_page.dart';
//Parecido com o card de Tendências (trendindCard), mudei essa classe da inicio_screen para cá para deixar o código menos acoplado
class NowPlayingCard extends StatelessWidget {
  final Movie movie;
  final bool isSaved;
  final VoidCallback onToggleSave;

  const NowPlayingCard({
    super.key, 
    required this.movie, 
    required this.isSaved,
    required this.onToggleSave,
});

  @override
Widget build(BuildContext context) {
    return GestureDetector(
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
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
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