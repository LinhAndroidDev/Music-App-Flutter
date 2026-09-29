import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/navigation/app_route.dart';
import '../../data/models/firestore_song.dart';
import '../../data/models/song.dart';
import '../../data/playback/song_playback_repository.dart';
import '../../data/search/search_catalog.dart';
import '../../data/search/search_history_repository.dart';
import '../../data/search/search_query.dart';
import '../../data/services/firestore_music_repository.dart';

enum SearchResultsMode { typing, committed }

enum SearchChrome { idle, loading, preview, tabs }

class SearchUiState {
  const SearchUiState({
    this.query = '',
    this.songs = const [],
    this.singers = const [],
    this.relatedNames = const [],
    this.isSearching = false,
    this.mode = SearchResultsMode.typing,
    this.recentQueries = const [],
    this.suggestions = const [],
  });

  final String query;
  final List<Song> songs;
  final List<FirestoreSinger> singers;
  final List<String> relatedNames;
  final bool isSearching;
  final SearchResultsMode mode;
  final List<SearchQuery> recentQueries;
  final List<String> suggestions;

  bool get hasResults =>
      songs.isNotEmpty || singers.isNotEmpty || relatedNames.isNotEmpty;

  SearchUiState copyWith({
    String? query,
    List<Song>? songs,
    List<FirestoreSinger>? singers,
    List<String>? relatedNames,
    bool? isSearching,
    SearchResultsMode? mode,
    List<SearchQuery>? recentQueries,
    List<String>? suggestions,
  }) {
    return SearchUiState(
      query: query ?? this.query,
      songs: songs ?? this.songs,
      singers: singers ?? this.singers,
      relatedNames: relatedNames ?? this.relatedNames,
      isSearching: isSearching ?? this.isSearching,
      mode: mode ?? this.mode,
      recentQueries: recentQueries ?? this.recentQueries,
      suggestions: suggestions ?? this.suggestions,
    );
  }
}

class MusicSearchController extends GetxController {
  MusicSearchController({
    FirestoreMusicRepository? music,
    SongPlaybackRepository? playback,
    SearchHistoryRepository? history,
  })  : _music = music ?? Get.find<FirestoreMusicRepository>(),
        _playback = playback ?? Get.find<SongPlaybackRepository>(),
        _history = history ?? Get.find<SearchHistoryRepository>();

  final FirestoreMusicRepository _music;
  final SongPlaybackRepository _playback;
  final SearchHistoryRepository _history;

  final uiState = SearchUiState().obs;
  final fieldText = ''.obs;

  final searchFieldController = TextEditingController();
  final searchFocusNode = FocusNode();

  Timer? _debounce;
  List<String> _suggestionPool = [];
  List<String> _suggestionCategories = [];
  List<FirestoreSinger>? _allSingers;

  Worker? _historyWorker;

  @override
  void onInit() {
    super.onInit();
    _historyWorker = ever(_history.recentQueries, (_) => _publishSuggestions());
    _loadSuggestions();
    final committed = (Get.parameters[AppRouteParam.committedQuery] ?? '').trim();
    if (committed.isNotEmpty) {
      _setFieldText(committed, notify: false);
      commitQuery(committed);
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (searchFocusNode.canRequestFocus) {
          searchFocusNode.requestFocus();
        }
      });
    }
  }

  @override
  void onClose() {
    _debounce?.cancel();
    _historyWorker?.dispose();
    searchFieldController.dispose();
    searchFocusNode.dispose();
    super.onClose();
  }

  SearchChrome resolveChrome() {
    final state = uiState.value;
    final querying = state.query.isNotEmpty || fieldText.value.trim().isNotEmpty;
    if (!querying) return SearchChrome.idle;
    if (state.isSearching && !state.hasResults) return SearchChrome.loading;
    if (state.mode == SearchResultsMode.committed && !state.isSearching) {
      return SearchChrome.tabs;
    }
    if (state.isSearching &&
        state.mode == SearchResultsMode.committed &&
        state.hasResults) {
      return SearchChrome.tabs;
    }
    return SearchChrome.preview;
  }

  void onFieldChanged(String raw) {
    fieldText.value = raw;
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () {
      if (raw.trim().isEmpty) {
        clearResults();
      } else {
        search(raw);
      }
    });
  }

  void onSearchSubmitted(String raw) {
    final keyword = raw.trim();
    if (keyword.isEmpty) return;
    _debounce?.cancel();
    commitQuery(keyword);
  }

  void search(String query) => _runSearch(query, SearchResultsMode.typing);

  void commitQuery(String raw) {
    final keyword = raw.trim();
    if (keyword.isNotEmpty) {
      unawaited(_history.recordQuery(keyword));
    }
    _setFieldText(keyword, notify: false);
    _runSearch(raw, SearchResultsMode.committed);
  }

  void applyChipQuery(String text) {
    _debounce?.cancel();
    _setFieldText(text, notify: false);
    commitQuery(text);
  }

  void clearField() {
    _debounce?.cancel();
    searchFieldController.clear();
    fieldText.value = '';
    clearResults();
  }

  void clearResults() {
    uiState.value = uiState.value.copyWith(
      query: '',
      songs: const [],
      singers: const [],
      relatedNames: const [],
      isSearching: false,
      mode: SearchResultsMode.typing,
    );
  }

  Future<void> deleteRecentQuery(String normalizedQuery) {
    return _history.deleteQuery(normalizedQuery);
  }

  Future<void> clearRecentQueries() => _history.clearAll();

  void _setFieldText(String text, {required bool notify}) {
    if (searchFieldController.text != text) {
      searchFieldController.text = text;
      searchFieldController.selection = TextSelection.collapsed(
        offset: text.length.clamp(0, text.length),
      );
    }
    fieldText.value = text;
    if (notify) onFieldChanged(text);
  }

  void setQueryFromVoice(String text) {
    _debounce?.cancel();
    _setFieldText(text, notify: false);
    commitQuery(text);
  }

  Future<void> _runSearch(String raw, SearchResultsMode mode) async {
    final keyword = raw.trim();
    if (keyword.isEmpty) {
      clearResults();
      return;
    }
    final current = uiState.value;
    if (keyword == current.query &&
        !current.isSearching &&
        current.mode == mode) {
      return;
    }

    uiState.value = current.copyWith(
      query: keyword,
      isSearching: true,
      mode: mode,
    );

    await _ensureCatalogLoaded();
    final songsFuture = Future(() => SearchCatalog.filterSongs(_catalogSongs(), keyword));
    final singersFuture = _filterSingers(keyword);

    final songs = await songsFuture;
    final singers = await singersFuture;

    uiState.value = uiState.value.copyWith(
      query: keyword,
      songs: songs,
      singers: singers,
      relatedNames: SearchCatalog.relatedNames(songs, singers, query: keyword),
      isSearching: false,
      mode: mode,
    );
  }

  Future<List<FirestoreSinger>> _filterSingers(String keyword) async {
    try {
      _allSingers ??= await _music.getSingers();
      return SearchCatalog.filterSingers(_allSingers!, keyword);
    } catch (_) {
      return const [];
    }
  }

  Future<void> _ensureCatalogLoaded() async {
    if (_playback.getLatestPlaylist().isEmpty) {
      await _playback.refreshPlaylist(fromServer: false);
    }
    if (_playback.getTopPlaylist().isEmpty) {
      await _playback.refreshTopPlaylist(fromServer: false);
    }
  }

  List<Song> _catalogSongs() {
    return SearchCatalog.mergeSongs(
      _playback.getLatestPlaylist(),
      _playback.getTopPlaylist(),
    );
  }

  Future<void> _loadSuggestions() async {
    _publishSuggestions();
    if (_playback.getTopPlaylist().isEmpty) {
      await _playback.refreshTopPlaylist(fromServer: false);
      _publishSuggestions();
    }
    try {
      final categories = await _music.getCategories();
      _suggestionCategories = categories.map((c) => c.name).where((n) => n.isNotEmpty).toList();
      _publishSuggestions();
    } catch (_) {}
  }

  void _publishSuggestions() {
    final titles = _playback.getTopPlaylist().map((s) => s.title);
    _suggestionPool = [...titles, ..._suggestionCategories];
    uiState.value = uiState.value.copyWith(
      recentQueries: List<SearchQuery>.from(_history.recentQueries),
      suggestions: SearchCatalog.pickSuggestions(
        _suggestionPool,
        _history.recentQueries,
      ),
    );
  }
}
