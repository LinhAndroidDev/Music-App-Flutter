class SearchQuery {
  const SearchQuery({
    required this.query,
    required this.normalizedQuery,
    required this.lastSearchedAt,
  });

  final String query;
  final String normalizedQuery;
  final int lastSearchedAt;
}
