import 'package:flutter/material.dart';
import '../../models/movie.dart';
import '../../models/movie_sort.dart';
import '../../widgets/search_result_list.dart';


class HomePesquisa extends StatefulWidget {
  final TextEditingController searchController;
  final List<Movie>? searchResults;
  final bool isSearching;
  final MovieSortOption sortOption;
  final ValueChanged<MovieSortOption> onSortChanged;
  final ValueChanged<String> onQuerySubmitted;
  final Future<List<Movie>> Function(String query) onSearch;
  final bool Function(Movie movie) isMovieSaved;
  final Future<void> Function(Movie movie) onToggleSave;

  const HomePesquisa({
    super.key,
    required this.searchController,
    required this.searchResults,
    required this.isSearching,
    required this.sortOption,
    required this.onSortChanged,
    required this.onSearch,
    required this.isMovieSaved,
    required this.onToggleSave,
    required this.onQuerySubmitted,
  });

  @override
  State<HomePesquisa> createState() => _HomePesquisaState();
}

class _HomePesquisaState extends State<HomePesquisa> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'O que você quer buscar?',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 24),
          TextField(
            controller: widget.searchController,
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
            onSubmitted: (value) async {
              if (value.trim().isEmpty) return;
              widget.onQuerySubmitted(value.trim());
            },
          ),
          const SizedBox(height: 16),
          if (widget.isSearching)
            const Center(child: CircularProgressIndicator()),
          if (!widget.isSearching && widget.searchResults != null)
            if (widget.searchResults!.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 32),
                child: Center(
                  child: Text(
                    'Nenhum filme encontrado 😔',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              )
            else
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text(
                        'Ordenar por:',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 12),
                      DropdownButton<MovieSortOption>(
                        value: widget.sortOption,
                        dropdownColor: const Color(0xFF313F56),
                        style: const TextStyle(color: Colors.white),
                        iconEnabledColor: Colors.white,
                        items: const [
                          DropdownMenuItem(
                            value: MovieSortOption.yearDesc,
                            child: Text('Ano (desc)'),
                          ),
                          DropdownMenuItem(
                            value: MovieSortOption.yearAsc,
                            child: Text('Ano (cresc)'),
                          ),
                          DropdownMenuItem(
                            value: MovieSortOption.nameAsc,
                            child: Text('Nome (A-Z)'),
                          ),
                          DropdownMenuItem(
                            value: MovieSortOption.nameDesc,
                            child: Text('Nome (Z-A)'),
                          ),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            widget.onSortChanged(value);
                          }
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SearchResultList(
                    movies: widget.searchResults!,
                    sortOption: widget.sortOption,
                    isMovieSaved: widget.isMovieSaved,
                    onToggleSave: widget.onToggleSave,
                  ),
                ],
              ),
        ],
      ),
    );
  }
}
