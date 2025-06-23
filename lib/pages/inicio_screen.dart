import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/movie.dart';
import '../models/movie_sort.dart';
import '../pages/home/home_inicio.dart';
import '../pages/home/home_pesquisa.dart';
import '../pages/home/home_salvos.dart';
import '../services/genre_service.dart';
import '../services/movie_service.dart';
import 'dart:convert';

class InicioScreen extends StatefulWidget {
  @override
  State<InicioScreen> createState() => _InicioScreenState();
}

class _InicioScreenState extends State<InicioScreen> {
  // Navegação entre as abas do bottomNavigationBar
  int _selectedIndex = 0;

  // Controle de filmes salvos
  List<int> _savedMovieIds = [];
  List<Movie> _savedMovieObjects = [];

  // Listas de filmes para exibição
  List<Movie> _trendingMovies = [];
  List<Movie> _nowPlayingMovies = [];
  List<Movie>? _searchResults;

  // Serviços e controllers
  final MovieService _movieService = MovieService();
  late Future<List<Movie>> _futureTrending;
  late Future<List<Movie>> _futureNowPlaying;
  final TextEditingController _searchController = TextEditingController();

  // Estado da interface
  bool _isSearching = false;
  bool _genresLoaded = false;
  MovieSortOption _sortOption = MovieSortOption.yearDesc;

  @override
  void initState() {
    super.initState();
    _loadSavedMovies();

    // Carrega gêneros (opcional, para exibir nomes de gêneros)
    GenreService().fetchGenres().then((_) {
      setState(() {
        _genresLoaded = true;
      });
    });

    // Carrega filmes em alta e em cartaz
    _futureTrending = _movieService.fetchTrendingMovies();
    _futureNowPlaying = _movieService.fetchNowPlayingMovies();

    // Preenche listas locais e objetos salvos na tela de Salvos
    _futureTrending.then((movies) {
      setState(() {
        _trendingMovies = movies;
        _addToSavedObjectsFromList(movies);
      });
    });
    _futureNowPlaying.then((movies) {
      setState(() {
        _nowPlayingMovies = movies;
        _addToSavedObjectsFromList(movies);
      });
    });
  }

  /// Adiciona à lista de objetos salvos os filmes que os IDs já estão salvos
  void _addToSavedObjectsFromList(List<Movie> movies) {
    for (final movie in movies) {
      if (_savedMovieIds.contains(movie.id) &&
          !_savedMovieObjects.any((m) => m.id == movie.id)) {
        _savedMovieObjects.add(movie);
      }
    }
  }

  /// Carrega IDs e objetos dos filmes salvos do SharedPreferences
  Future<void> _loadSavedMovies() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _savedMovieIds =
          prefs.getStringList('saved_movies')?.map(int.parse).toList() ?? [];
      final savedMovieJsons = prefs.getStringList('saved_movie_objects') ?? [];
      _savedMovieObjects = savedMovieJsons
          .map((jsonStr) => Movie.fromJson(jsonDecode(jsonStr)))
          .toList();
    });
  }

  /// Salva ou remove um filme dos favoritos, atualizando SharedPreferences
  Future<void> _toggleSaveMovie(Movie movie) async {
    final prefs = await SharedPreferences.getInstance();
    bool wasSaved = false;
    setState(() {
      if (_savedMovieIds.contains(movie.id)) {
        _savedMovieIds.remove(movie.id);
        _savedMovieObjects.removeWhere((m) => m.id == movie.id);
        wasSaved = false;
      } else {
        _savedMovieIds.add(movie.id);
        if (!_savedMovieObjects.any((m) => m.id == movie.id)) {
          _savedMovieObjects.add(movie);
        }
        wasSaved = true;
      }
      // Salva IDs e objetos no SharedPreferences
      prefs.setStringList(
        'saved_movies',
        _savedMovieIds.map((id) => id.toString()).toList(),
      );
      prefs.setStringList(
        'saved_movie_objects',
        _savedMovieObjects.map((m) => jsonEncode(m.toJson())).toList(),
      );
    });
    // Mostra a mensagem informando que o filme foi salvo ou removido de salvos
    // ignore: use_build_context_synchronously
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(wasSaved ? 'Filme salvo!' : 'Filme removido dos salvos!'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  /// Verifica se um filme está salvo
  bool _isMovieSaved(Movie movie) => _savedMovieIds.contains(movie.id);

  /// Realiza a busca de filmes e atualiza o estado de cada widget
  Future<List<Movie>> _handleSearch(String value) async {
    if (value.trim().isEmpty) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      return [];
    }
    setState(() {
      _isSearching = true;
      _searchResults = null;
    });
    try {
      final results = await _movieService.searchMovies(value.trim());
      setState(() {
        _searchResults = results;
        _isSearching = false;
        _addToSavedObjectsFromList(results);
      });
      return results;
    } catch (e) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      return [];
    }
  }

  /// Retorna a lista de filmes salvos, sem duplicar vários cards de filmes
  List<Movie> get _savedMovies {
    final allMovies = [
      ..._savedMovieObjects,
      ...?_searchResults,
      ..._trendingMovies,
      ..._nowPlayingMovies,
    ];
    final uniqueMovies = {for (var m in allMovies) m.id: m}.values.toList();
    return uniqueMovies.where((m) => _savedMovieIds.contains(m.id)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF22293E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF22293E),
        title: const Text(
          'App Flutter',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          // Tela de Inicio do app
          HomeInicio(
            searchResults: _searchResults,
            isSearching: _isSearching,
            searchController: _searchController,
            onToggleSave: _toggleSaveMovie,
            isMovieSaved: _isMovieSaved,
            sortOption: _sortOption,
            onSortOptionChanged: (value) {
              setState(() {
                _sortOption = value;
              });
            },
            futureTrending: _futureTrending,
            futureNowPlaying: _futureNowPlaying,
            genresLoaded: _genresLoaded,
            onQuerySubmitted: (String value) async {
              await _handleSearch(value);
            },
          ),
          // Tela de pesquisa
          HomePesquisa(
            searchController: _searchController,
            searchResults: _searchResults,
            isSearching: _isSearching,
            sortOption: _sortOption,
            onSearch: _handleSearch,
            onToggleSave: _toggleSaveMovie,
            isMovieSaved: _isMovieSaved,
            onSortChanged: (MovieSortOption value) {
              setState(() {
                _sortOption = value;
              });
            },
            onQuerySubmitted: (String value) async {
              await _handleSearch(value);
            },
          ),
          // Tela de filmes salvos
          HomeSalvos(
            savedMovieIds: _savedMovieIds,
            searchResults: _searchResults,
            trendingMovies: _trendingMovies,
            nowPlayingMovies: _nowPlayingMovies,
            isMovieSaved: _isMovieSaved,
            onToggleSave: _toggleSaveMovie,
            savedMovies: _savedMovies,
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            // Limpa busca ao voltar para a tela inicial
            if (_selectedIndex == index && index == 0) {
              _searchController.clear();
              _searchResults = null;
              _isSearching = false;
            }
            _selectedIndex = index;
          });
        },
        backgroundColor: const Color(0xFF22293E),
        selectedItemColor: const Color(0xFF0296E5),
        unselectedItemColor: Colors.white,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_filled),
            label: 'Início',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search_rounded),
            label: 'Pesquisar',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bookmark_added_outlined),
            label: 'Salvos',
          ),
        ],
      ),
    );
  }
}