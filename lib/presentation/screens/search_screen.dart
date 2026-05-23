import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:lume/core/constants/app_colors.dart';
import 'package:lume/core/constants/app_strings.dart';
import 'package:lume/domain/entities/book.dart';
import 'package:lume/presentation/bloc/library/library_bloc.dart';
import 'package:lume/presentation/bloc/library/library_event.dart';
import 'package:lume/presentation/bloc/search/search_bloc.dart';
import 'package:lume/presentation/bloc/search/search_event.dart';
import 'package:lume/presentation/bloc/search/search_state.dart';
import 'package:lume/presentation/widgets/book_card.dart';
import 'package:lume/presentation/widgets/empty_state_widget.dart';
import 'package:lume/presentation/widgets/shimmer_loading.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});
  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _searchController = TextEditingController();
  final _focusNode = FocusNode();

  List<Book>? _trendingBooks;
  List<Book>? _recommendedBooks;
  bool _isLoadingDiscovery = false;

  static final List<Book> _fallbackTrending = [
    Book(
      id: 'trending-1',
      title: 'Atomic Habits',
      authors: const ['James Clear'],
      genres: const ['Self-Help', 'Personal Growth'],
      coverUrl: 'https://images-na.ssl-images-amazon.com/images/S/compressed.photo.goodreads.com/books/1655988390i/40121378.jpg',
      status: BookStatus.toBeRead,
      dateAdded: DateTime.now(),
    ),
    Book(
      id: 'trending-2',
      title: 'The Midnight Library',
      authors: const ['Matt Haig'],
      genres: const ['Fiction', 'Fantasy'],
      coverUrl: 'https://images-na.ssl-images-amazon.com/images/S/compressed.photo.goodreads.com/books/1602190974i/52578297.jpg',
      status: BookStatus.toBeRead,
      dateAdded: DateTime.now(),
    ),
    Book(
      id: 'trending-3',
      title: 'Lessons in Chemistry',
      authors: const ['Bonnie Garmus'],
      genres: const ['Fiction', 'Historical'],
      coverUrl: 'https://images-na.ssl-images-amazon.com/images/S/compressed.photo.goodreads.com/books/1647493721i/58065033.jpg',
      status: BookStatus.toBeRead,
      dateAdded: DateTime.now(),
    ),
    Book(
      id: 'trending-4',
      title: 'Can\'t Hurt Me',
      authors: const ['David Goggins'],
      genres: const ['Biography', 'Self-Help'],
      coverUrl: 'https://images-na.ssl-images-amazon.com/images/S/compressed.photo.goodreads.com/books/1631527092i/41721428.jpg',
      status: BookStatus.toBeRead,
      dateAdded: DateTime.now(),
    ),
  ];

  static final List<Book> _fallbackRecommended = [
    Book(
      id: 'rec-1',
      title: 'Sapiens',
      authors: const ['Yuval Noah Harari'],
      genres: const ['History', 'Science'],
      coverUrl: 'https://images-na.ssl-images-amazon.com/images/S/compressed.photo.goodreads.com/books/1590358926i/23692271.jpg',
      status: BookStatus.toBeRead,
      dateAdded: DateTime.now(),
    ),
    Book(
      id: 'rec-2',
      title: 'Thinking, Fast and Slow',
      authors: const ['Daniel Kahneman'],
      genres: const ['Psychology', 'Science'],
      coverUrl: 'https://images-na.ssl-images-amazon.com/images/S/compressed.photo.goodreads.com/books/1317793930i/11468377.jpg',
      status: BookStatus.toBeRead,
      dateAdded: DateTime.now(),
    ),
    Book(
      id: 'rec-3',
      title: 'The Psychology of Money',
      authors: const ['Morgan Housel'],
      genres: const ['Finance', 'Psychology'],
      coverUrl: 'https://images-na.ssl-images-amazon.com/images/S/compressed.photo.goodreads.com/books/1593498879i/51861313.jpg',
      status: BookStatus.toBeRead,
      dateAdded: DateTime.now(),
    ),
    Book(
      id: 'rec-4',
      title: 'Educated',
      authors: const ['Tara Westover'],
      genres: const ['Biography', 'Memoir'],
      coverUrl: 'https://images-na.ssl-images-amazon.com/images/S/compressed.photo.goodreads.com/books/1506026635i/35133922.jpg',
      status: BookStatus.toBeRead,
      dateAdded: DateTime.now(),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      setState(() {});
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _focusNode.requestFocus();
        _loadDiscoveryData();
      }
    });
  }

  Future<void> _loadDiscoveryData() async {
    if (!mounted) return;
    setState(() {
      _isLoadingDiscovery = true;
    });

    try {
      final repository = context.read<SearchBloc>().bookRepository;
      final results = await Future.wait([
        repository.searchBooks('trending'),
        repository.searchBooks('bestsellers'),
      ]);

      if (mounted) {
        setState(() {
          _trendingBooks = results[0].isNotEmpty ? results[0].take(8).toList() : _fallbackTrending;
          _recommendedBooks = results[1].isNotEmpty ? results[1].take(8).toList() : _fallbackRecommended;
          _isLoadingDiscovery = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _trendingBooks = _fallbackTrending;
          _recommendedBooks = _fallbackRecommended;
          _isLoadingDiscovery = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text('Search', style: theme.textTheme.titleLarge),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
            child: Container(
              decoration: BoxDecoration(
                boxShadow: _focusNode.hasFocus
                    ? [
                        BoxShadow(
                          color: AppColors.lightAccent.withValues(alpha: 0.2),
                          blurRadius: 15,
                          offset: const Offset(0, 4),
                        )
                      ]
                    : [],
                borderRadius: BorderRadius.circular(100),
              ),
              child: TextField(
                controller: _searchController,
                focusNode: _focusNode,
                decoration: InputDecoration(
                  hintText: AppStrings.searchHint,
                  prefixIcon: const Icon(Icons.search_rounded, size: 22),
                  suffixIcon: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (_searchController.text.isNotEmpty)
                        IconButton(
                          icon: const Icon(Icons.clear_rounded, size: 20),
                          onPressed: () {
                            _searchController.clear();
                            context.read<SearchBloc>().add(ClearSearch());
                            setState(() {});
                          },
                        ),
                      IconButton(
                        icon: const Icon(Icons.tune_rounded, size: 20),
                        onPressed: () {},
                      ),
                    ],
                  ),
                  filled: true,
                  fillColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(100),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(100),
                    borderSide: BorderSide(color: isDark ? AppColors.darkDivider : AppColors.lightDivider),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(100),
                    borderSide: const BorderSide(color: AppColors.lightAccent, width: 1.5),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                ),
                onChanged: (q) {
                  context.read<SearchBloc>().add(SearchBooks(q));
                  setState(() {});
                },
                textInputAction: TextInputAction.search,
              ),
            ),
          ),
          Expanded(child: BlocBuilder<SearchBloc, SearchState>(
            builder: (context, state) {
              if (state is SearchInitial || _searchController.text.isEmpty) {
                return _buildDiscoveryContent(context);
              }
              if (state is SearchLoading) return const ShimmerLoading(itemCount: 4);
              if (state is SearchError) {
                return EmptyStateWidget(
                  icon: Icons.error_outline_rounded,
                  title: 'Oops!',
                  subtitle: AppStrings.searchError,
                  actionLabel: 'Try Again',
                  onAction: () {
                    if (_searchController.text.isNotEmpty) {
                      context.read<SearchBloc>().add(SearchBooks(_searchController.text));
                    }
                  },
                );
              }
              if (state is SearchLoaded) {
                if (state.results.isEmpty) {
                  return const EmptyStateWidget(
                    icon: Icons.search_off_rounded,
                    title: AppStrings.searchEmpty,
                    subtitle: 'Try a different search term',
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.only(bottom: 40),
                  physics: const BouncingScrollPhysics(),
                  itemCount: state.results.length,
                  itemBuilder: (_, i) {
                    final book = state.results[i];
                    return BookCard(book: book, onTap: () => _showAddSheet(book));
                  },
                );
              }
              return const SizedBox.shrink();
            },
          )),
        ],
      ),
    );
  }

  Widget _buildDiscoveryContent(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      physics: const BouncingScrollPhysics(),
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: ['#Mystery', '#Sci-Fi', '#Biography', '#Philosophy', '#Romance'].map((tag) {
            return InkWell(
              onTap: () {
                _searchController.text = tag;
                context.read<SearchBloc>().add(SearchBooks(tag));
                setState(() {});
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.lightAccent.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Text(
                  tag,
                  style: const TextStyle(color: AppColors.lightAccent, fontWeight: FontWeight.bold, fontSize: 13),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 36),
        Text('Trending Right Now', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        _buildDiscoveryList(_trendingBooks, isDark, Icons.auto_stories_rounded),
        const SizedBox(height: 36),
        Text('Recommended For You', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        _buildDiscoveryList(_recommendedBooks, isDark, Icons.auto_awesome_rounded),
      ],
    );
  }

  Widget _buildDiscoveryList(List<Book>? books, bool isDark, IconData placeholderIcon) {
    final showShimmer = books == null || _isLoadingDiscovery;

    return SizedBox(
      height: 180,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: showShimmer ? 5 : books.length,
        separatorBuilder: (_, __) => const SizedBox(width: 16),
        itemBuilder: (context, index) {
          if (showShimmer) {
            return Container(
              width: 120,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: isDark ? AppColors.darkAccentMuted : AppColors.lightAccentMuted.withValues(alpha: 0.3),
                border: Border.all(color: const Color(0x144A5260)),
              ),
              child: Center(
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: isDark ? AppColors.darkAccent : AppColors.lightAccent,
                  ),
                ),
              ),
            );
          }

          final book = books[index];
          return GestureDetector(
            onTap: () => _showAddSheet(book),
            child: Hero(
              tag: 'discovery-${book.id}',
              child: Container(
                width: 120,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: isDark ? AppColors.darkAccentMuted : AppColors.lightAccentMuted.withValues(alpha: 0.3),
                  border: Border.all(color: const Color(0x144A5260)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 10,
                      offset: const Offset(2, 4),
                    ),
                  ],
                ),
                clipBehavior: Clip.antiAlias,
                child: book.coverUrl != null
                    ? CachedNetworkImage(
                        imageUrl: book.coverUrl!,
                        fit: BoxFit.cover,
                        placeholder: (_, __) => Center(
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: isDark ? AppColors.darkAccent : AppColors.lightAccent,
                          ),
                        ),
                        errorWidget: (_, __, ___) => _buildPlaceholderIcon(isDark, placeholderIcon),
                      )
                    : _buildPlaceholderIcon(isDark, placeholderIcon),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPlaceholderIcon(bool isDark, IconData icon) {
    return Center(
      child: Icon(
        icon,
        size: 32,
        color: AppColors.lightAccent.withValues(alpha: 0.6),
      ),
    );
  }

  void _showAddSheet(Book book) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
            Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: isDark ? AppColors.darkDivider : AppColors.lightDivider, borderRadius: BorderRadius.circular(2)))),
            const SizedBox(height: 20),
            Text(book.title, style: Theme.of(context).textTheme.titleMedium, maxLines: 2, overflow: TextOverflow.ellipsis),
            Text(book.authorsFormatted, style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 20),
            Text('Add to...', style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 8),
            _addOpt(book, BookStatus.readingNow, Icons.menu_book_rounded, 'Reading Now'),
            _addOpt(book, BookStatus.wishlist, Icons.bookmark_border_rounded, 'Wishlist'),
            _addOpt(book, BookStatus.finished, Icons.done_all_rounded, 'Already Read'),
            const SizedBox(height: 8),
            Center(child: TextButton(
              onPressed: () { Navigator.pop(context); Navigator.of(context).pushNamed('/detail', arguments: book); },
              child: const Text('View Full Details'),
            )),
          ]),
        ),
      ),
    );
  }

  Widget _addOpt(Book book, BookStatus status, IconData icon, String label) {
    return ListTile(
      contentPadding: EdgeInsets.zero, leading: Icon(icon), title: Text(label),
      onTap: () {
        final b = book.copyWith(status: status, dateAdded: DateTime.now());
        context.read<LibraryBloc>().add(AddBookToLibrary(b));
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Added "${book.title}" to $label'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ));
      },
    );
  }
}
