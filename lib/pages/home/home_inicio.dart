import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import '../../models/movie.dart';
import '../../widgets/section_title.dart';
import '../../widgets/trending_card.dart';
import '../../widgets/now_playing_card.dart';
import '../../widgets/search_result_list.dart';
import '../../models/movie_sort.dart';

class HomeInicio extends StatelessWidget {
  final TextEditingController searchController;
  final Future<List<Movie>> futureTrending;
  final Future<List<Movie>> futureNowPlaying;
  final bool isSearching;
  final List<Movie>? searchResults;
  final bool Function(Movie) isMovieSaved;
  final Future<void> Function(Movie) onToggleSave;
  final bool genresLoaded;
  final ValueChanged<String> onQuerySubmitted;

  const HomeInicio({
    super.key,
    required this.searchController,
    required this.futureTrending,
    required this.futureNowPlaying,
    required this.isSearching,
    required this.searchResults,
    required this.isMovieSaved,
    required this.onToggleSave,
    required this.onQuerySubmitted,
    required this.genresLoaded,
    required MovieSortOption sortOption,
    required Null Function(dynamic value) onSortOptionChanged,
  });

  @override
  Widget build(BuildContext context) {
    if (!genresLoaded) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'O que você quer assistir hoje?',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 24),
          TextField(
            controller: searchController,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Buscar',
              hintStyle: const TextStyle(color: Colors.white54),
              filled: true,
              fillColor: const Color(0xFF313F56),
              prefixIcon: const Icon(Icons.search, color: Colors.white70),
              contentPadding: const EdgeInsets.symmetric(vertical: 14.0),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
            onSubmitted: (value) {
              if (value.trim().isEmpty) return;
              onQuerySubmitted(value.trim());
            },
          ),
          const SizedBox(height: 16),
          if (isSearching) const Center(child: CircularProgressIndicator()),
          if (searchResults != null)
            searchResults!.isEmpty
                ? const Padding(
                    padding: EdgeInsets.symmetric(vertical: 32),
                    child: Center(
                      child: Text(
                        'Nenhum filme encontrado 😔',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  )
                : Padding(
                    padding: const EdgeInsets.symmetric(vertical: 32),
                    child: SearchResultList(
                      movies: searchResults!,
                      sortOption: MovieSortOption.yearDesc,
                      isMovieSaved: isMovieSaved,
                      onToggleSave: onToggleSave,
                    ),
                  ),
          if (searchResults == null) ...[
            const SizedBox(height: 32),
            const SectionTitle('Tendências'),
            const SizedBox(height: 16),
            FutureBuilder<List<Movie>>(
              future: futureTrending,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Text(
                    'Erro: \${snapshot.error}',
                    style: const TextStyle(color: Colors.white),
                  );
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Text(
                    'Nenhum filme encontrado 😔',
                    style: TextStyle(color: Colors.white),
                  );
                }

                final movies = snapshot.data!;
                return CarouselSlider(
                  options: CarouselOptions(
                    height: 360,
                    enlargeCenterPage: true,
                    viewportFraction: 0.45,
                    autoPlay: true,
                    autoPlayInterval: const Duration(seconds: 4),
                    autoPlayAnimationDuration: const Duration(
                      milliseconds: 800,
                    ),
                  ),
                  items: movies
                      .map(
                        (movie) => TrendingCard(
                          movie: movie,
                          isSaved: isMovieSaved(movie),
                          onToggleSave: () => onToggleSave(movie),
                        ),
                      )
                      .toList(),
                );
              },
            ),
            const SizedBox(height: 32),
            const SectionTitle('Nos cinemas'),
            const SizedBox(height: 16),
            FutureBuilder<List<Movie>>(
              future: futureNowPlaying,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Text(
                    'Erro: \${snapshot.error}',
                    style: const TextStyle(color: Colors.white),
                  );
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Text(
                    'Nenhum filme encontrado 😔',
                    style: TextStyle(color: Colors.white),
                  );
                }

                final movies = snapshot.data!;
                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: movies.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 118 / 160,
                  ),
                  itemBuilder: (context, index) {
                    final movie = movies[index];
                    return NowPlayingCard(
                      movie: movie,
                      isSaved: isMovieSaved(movie),
                      onToggleSave: () => onToggleSave(movie),
                    );
                  },
                );
              },
            ),
          ],
        ],
      ),
    );
  }
}
