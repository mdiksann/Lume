import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lume/core/constants/app_colors.dart';
import 'package:lume/core/constants/app_strings.dart';
import 'package:lume/domain/entities/book.dart';
import 'package:lume/presentation/bloc/library/library_bloc.dart';
import 'package:lume/presentation/bloc/library/library_event.dart';
import 'package:lume/presentation/bloc/library/library_state.dart';
import 'package:lume/presentation/bloc/recommendation/recommendation_bloc.dart';
import 'package:lume/presentation/bloc/recommendation/recommendation_event.dart';
import 'package:lume/presentation/bloc/recommendation/recommendation_state.dart';
import 'package:lume/presentation/widgets/book_card.dart';
import 'package:lume/presentation/widgets/book_list_view.dart';
import 'package:lume/presentation/widgets/empty_state_widget.dart';
import 'package:lume/presentation/widgets/shimmer_loading.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:uuid/uuid.dart';

/// Main Library Dashboard with three tabs:
/// Reading Now, Finished, and Wishlist.
///
/// Features:
/// - Elegant serif header with tab navigation
/// - Pull-to-refresh on each tab
/// - FAB to navigate to book search
/// - Bottom navigation for recommendations and settings
class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _currentNavIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    // Load books on initial entry
    context.read<LibraryBloc>().add(const LoadBooks());
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: _currentNavIndex == 0
            ? _buildLibraryTab(context)
            : const SizedBox.shrink(),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: isDark ? AppColors.darkDivider : AppColors.lightDivider,
              width: 0.5,
            ),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentNavIndex,
          onTap: (index) {
            if (index == 1) {
              Navigator.of(context).pushNamed('/search');
            } else if (index == 2) {
              Navigator.of(context).pushNamed('/settings');
            } else {
              setState(() => _currentNavIndex = index);
            }
          },
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.auto_stories_rounded),
              label: 'Library',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.search_rounded),
              label: 'Search',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings_rounded),
              label: 'Settings',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLibraryTab(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return NestedScrollView(
      headerSliverBuilder: (context, innerBoxIsScrolled) {
        return [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'My Library',
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 32,
                      fontWeight: FontWeight.w700,
                      color: isDark
                          ? AppColors.darkTextPrimary
                          : AppColors.lightTextPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  BlocBuilder<LibraryBloc, LibraryState>(
                    builder: (context, state) {
                      if (state is LibraryLoaded) {
                        return Text(
                          '${state.totalBooks} books in your collection',
                          style: theme.textTheme.bodyMedium,
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                ],
              ),
            ),
          ),
          SliverPersistentHeader(
            pinned: true,
            delegate: _TabBarDelegate(
              tabBar: TabBar(
                controller: _tabController,
                tabs: const [
                  Tab(text: AppStrings.readingNow),
                  Tab(text: AppStrings.finished),
                  Tab(text: AppStrings.wishlist),
                ],
              ),
              backgroundColor:
                  isDark ? AppColors.darkBackground : AppColors.lightBackground,
            ),
          ),
        ];
      },
      body: BlocBuilder<LibraryBloc, LibraryState>(
        builder: (context, state) {
          if (state is LibraryLoading) {
            return const ShimmerLoading();
          }

          if (state is LibraryError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline_rounded,
                    size: 48,
                    color: isDark
                        ? AppColors.darkTextTertiary
                        : AppColors.lightTextTertiary,
                  ),
                  const SizedBox(height: 16),
                  Text(state.message, style: theme.textTheme.bodyMedium),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () =>
                        context.read<LibraryBloc>().add(const LoadBooks()),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (state is LibraryLoaded) {
            return TabBarView(
              controller: _tabController,
              children: [
                // Reading Now
                RefreshIndicator(
                  onRefresh: () async {
                    context.read<LibraryBloc>().add(const LoadBooks());
                  },
                  color: AppColors.lightAccent,
                  child: BookListView(
                    books: state.readingNow,
                    emptyIcon: Icons.menu_book_rounded,
                    emptyTitle: AppStrings.readingNowEmpty,
                    emptySubtitle: AppStrings.readingNowEmptySubtitle,
                    onBookTap: (book) => _navigateToDetail(book),
                    onBookLongPress: (book) => _showStatusSheet(book),
                  ),
                ),
                // Finished — with AI Recommendations
                RefreshIndicator(
                  onRefresh: () async {
                    context.read<LibraryBloc>().add(const LoadBooks());
                  },
                  color: AppColors.lightAccent,
                  child: _buildFinishedTab(context, state.finished),
                ),
                // Wishlist
                RefreshIndicator(
                  onRefresh: () async {
                    context.read<LibraryBloc>().add(const LoadBooks());
                  },
                  color: AppColors.lightAccent,
                  child: BookListView(
                    books: state.wishlist,
                    emptyIcon: Icons.bookmark_border_rounded,
                    emptyTitle: AppStrings.wishlistEmpty,
                    emptySubtitle: AppStrings.wishlistEmptySubtitle,
                    onEmptyAction: () =>
                        Navigator.of(context).pushNamed('/search'),
                    emptyActionLabel: 'Find Books',
                    onBookTap: (book) => _navigateToDetail(book),
                    onBookLongPress: (book) => _showStatusSheet(book),
                  ),
                ),
              ],
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  /// Builds the Finished tab with an AI recommendation banner
  /// above the book list when books are present.
  Widget _buildFinishedTab(BuildContext context, List<Book> books) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (books.isEmpty) {
      return const EmptyStateWidget(
        icon: Icons.done_all_rounded,
        title: AppStrings.finishedEmpty,
        subtitle: AppStrings.finishedEmptySubtitle,
      );
    }

    return ListView(
      padding: const EdgeInsets.only(top: 8, bottom: 100),
      physics: const BouncingScrollPhysics(
        parent: AlwaysScrollableScrollPhysics(),
      ),
      children: [
        // ── AI Recommendation Banner ──
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
          child: BlocBuilder<RecommendationBloc, RecommendationState>(
            builder: (context, state) {
              return Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isDark
                        ? [AppColors.darkAccentMuted, AppColors.darkSurface]
                        : [
                            AppColors.lightAccentMuted.withValues(alpha: 0.5),
                            AppColors.lightSurface
                          ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDark
                        ? AppColors.darkDivider
                        : AppColors.lightDivider,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Banner header
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                      child: Row(
                        children: [
                          Icon(
                            Icons.auto_awesome_rounded,
                            size: 20,
                            color: isDark
                                ? AppColors.darkAccent
                                : AppColors.lightAccent,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'AI Recommendations',
                              style: theme.textTheme.titleSmall,
                            ),
                          ),
                          if (state is RecommendationLoading)
                            SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: isDark
                                    ? AppColors.darkAccent
                                    : AppColors.lightAccent,
                              ),
                            )
                          else
                            TextButton(
                              onPressed: () => context
                                  .read<RecommendationBloc>()
                                  .add(FetchRecommendations()),
                              child: Text(
                                state is RecommendationLoaded
                                    ? 'Refresh'
                                    : 'Generate',
                              ),
                            ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
                      child: Text(
                        'Based on your ${books.length} finished book${books.length == 1 ? '' : 's'}',
                        style: theme.textTheme.bodySmall,
                      ),
                    ),
                    // Recommendation content
                    if (state is RecommendationLoaded) ...[
                      Divider(
                        height: 1,
                        color: isDark
                            ? AppColors.darkDivider
                            : AppColors.lightDivider,
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          state.result.profileSummary,
                          style: theme.textTheme.bodyMedium
                              ?.copyWith(height: 1.5, fontStyle: FontStyle.italic),
                        ),
                      ),
                      ...state.result.books.map((recBook) => Container(
                            margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: isDark ? AppColors.darkBackground : AppColors.lightBackground,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isDark ? AppColors.darkDivider : AppColors.lightDivider,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  recBook.title,
                                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  recBook.author,
                                  style: theme.textTheme.bodyMedium?.copyWith(color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
                                ),
                                const SizedBox(height: 12),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: isDark ? AppColors.darkAccentMuted : AppColors.lightAccentMuted,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    recBook.genre,
                                    style: theme.textTheme.labelSmall,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  recBook.reason,
                                  style: theme.textTheme.bodySmall?.copyWith(height: 1.5),
                                ),
                                const SizedBox(height: 16),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: FilledButton.tonalIcon(
                                    onPressed: () {
                                      final newBook = Book(
                                        id: const Uuid().v4(),
                                        title: recBook.title,
                                        authors: [recBook.author],
                                        genres: [recBook.genre],
                                        status: BookStatus.readingNow,
                                        dateAdded: DateTime.now(),
                                        description: 'AI Recommendation: ${recBook.reason}',
                                      );
                                      context.read<LibraryBloc>().add(AddBookToLibrary(newBook));
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text('Added "${recBook.title}" to Reading Now'),
                                          behavior: SnackBarBehavior.floating,
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                        ),
                                      );
                                    },
                                    icon: const Icon(Icons.add_rounded, size: 18),
                                    label: const Text('Reading Now'),
                                    style: FilledButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )),
                      const SizedBox(height: 8),
                    ],
                    if (state is RecommendationError) ...[
                      Divider(
                        height: 1,
                        color: isDark
                            ? AppColors.darkDivider
                            : AppColors.lightDivider,
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          state.message,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: isDark
                                ? AppColors.darkError
                                : AppColors.lightError,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              );
            },
          ),
        ),

        // ── Finished Books List ──
        ...books.map((book) => BookCard(
              book: book,
              onTap: () => _navigateToDetail(book),
              onLongPress: () => _showStatusSheet(book),
            )),
      ],
    );
  }

  void _navigateToDetail(Book book) {
    Navigator.of(context).pushNamed('/detail', arguments: book);
  }

  void _showStatusSheet(Book book) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor:
          isDark ? AppColors.darkSurface : AppColors.lightSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.darkDivider
                        : AppColors.lightDivider,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  book.title,
                  style: Theme.of(context).textTheme.titleMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                _buildStatusOption(
                  context,
                  book,
                  BookStatus.readingNow,
                  Icons.menu_book_rounded,
                  'Reading Now',
                ),
                _buildStatusOption(
                  context,
                  book,
                  BookStatus.finished,
                  Icons.done_all_rounded,
                  'Finished',
                ),
                _buildStatusOption(
                  context,
                  book,
                  BookStatus.wishlist,
                  Icons.bookmark_border_rounded,
                  'Wishlist',
                ),
                const Divider(height: 24),
                ListTile(
                  leading: Icon(
                    Icons.delete_outline_rounded,
                    color: isDark
                        ? AppColors.darkError
                        : AppColors.lightError,
                  ),
                  title: Text(
                    'Remove from Library',
                    style: TextStyle(
                      color: isDark
                          ? AppColors.darkError
                          : AppColors.lightError,
                    ),
                  ),
                  onTap: () {
                    context
                        .read<LibraryBloc>()
                        .add(RemoveBookFromLibrary(book.id));
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatusOption(
    BuildContext context,
    Book book,
    BookStatus status,
    IconData icon,
    String label,
  ) {
    final isSelected = book.status == status;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = isDark ? AppColors.darkAccent : AppColors.lightAccent;

    return ListTile(
      leading: Icon(
        icon,
        color: isSelected ? accent : null,
      ),
      title: Text(
        label,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
          color: isSelected ? accent : null,
        ),
      ),
      trailing: isSelected
          ? Icon(Icons.check_rounded, color: accent)
          : null,
      onTap: () {
        if (!isSelected) {
          context.read<LibraryBloc>().add(
                UpdateStatus(bookId: book.id, newStatus: status),
              );
        }
        Navigator.pop(context);
      },
    );
  }
}

/// Delegate for pinning the TabBar header during scroll.
class _TabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;
  final Color backgroundColor;

  _TabBarDelegate({required this.tabBar, required this.backgroundColor});

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: backgroundColor,
      child: tabBar,
    );
  }

  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  double get minExtent => tabBar.preferredSize.height;

  @override
  bool shouldRebuild(covariant _TabBarDelegate oldDelegate) {
    return tabBar != oldDelegate.tabBar ||
        backgroundColor != oldDelegate.backgroundColor;
  }
}
