import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lume/core/constants/app_colors.dart';
import 'package:lume/core/constants/app_strings.dart';
import 'package:lume/presentation/bloc/recommendation/recommendation_bloc.dart';
import 'package:lume/presentation/bloc/recommendation/recommendation_event.dart';
import 'package:lume/presentation/bloc/recommendation/recommendation_state.dart';
import 'package:lume/domain/entities/book.dart';
import 'package:lume/presentation/bloc/library/library_bloc.dart';
import 'package:lume/presentation/bloc/library/library_event.dart';
import 'package:uuid/uuid.dart';

class RecommendationScreen extends StatelessWidget {
  const RecommendationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(AppStrings.recommendations, style: theme.textTheme.titleLarge),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: BlocBuilder<RecommendationBloc, RecommendationState>(
          builder: (context, state) {
            if (state is RecommendationInitial) {
              return Center(child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 80, height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isDark ? AppColors.darkAccentMuted.withValues(alpha: 0.3) : AppColors.lightAccentMuted.withValues(alpha: 0.5),
                    ),
                    child: Icon(Icons.auto_awesome_rounded, size: 36, color: isDark ? AppColors.darkAccent : AppColors.lightAccent),
                  ),
                  const SizedBox(height: 24),
                  Text(AppStrings.recommendations, style: theme.textTheme.headlineSmall),
                  const SizedBox(height: 8),
                  Text(AppStrings.recommendationsSubtitle, style: theme.textTheme.bodyMedium, textAlign: TextAlign.center),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.auto_awesome_rounded, size: 20),
                    label: const Text(AppStrings.generateRecommendations),
                    onPressed: () => context.read<RecommendationBloc>().add(FetchRecommendations()),
                  ),
                ],
              ));
            }
            if (state is RecommendationLoading) {
              return Center(child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(width: 48, height: 48, child: CircularProgressIndicator(
                    strokeWidth: 2, color: isDark ? AppColors.darkAccent : AppColors.lightAccent,
                  )),
                  const SizedBox(height: 24),
                  Text('Analyzing your reading taste...', style: theme.textTheme.bodyMedium),
                ],
              ));
            }
            if (state is RecommendationLoaded) {
              return SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    Icon(Icons.auto_awesome_rounded, size: 20, color: isDark ? AppColors.darkAccent : AppColors.lightAccent),
                    const SizedBox(width: 8),
                    Text('AI Recommendations', style: theme.textTheme.headlineSmall),
                  ]),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: isDark ? AppColors.darkDivider : AppColors.lightDivider),
                    ),
                    child: Text(state.result.profileSummary, style: theme.textTheme.bodyMedium?.copyWith(height: 1.5, fontStyle: FontStyle.italic)),
                  ),
                  const SizedBox(height: 16),
                  ...state.result.books.map((recBook) => Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkBackground : AppColors.lightBackground,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: isDark ? AppColors.darkDivider : AppColors.lightDivider),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(recBook.title, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text(recBook.author, style: theme.textTheme.bodyMedium?.copyWith(color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary)),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.darkAccentMuted : AppColors.lightAccentMuted,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(recBook.genre, style: theme.textTheme.labelSmall),
                        ),
                        const SizedBox(height: 12),
                        Text(recBook.reason, style: theme.textTheme.bodySmall?.copyWith(height: 1.5)),
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
                                ),
                              );
                            },
                            icon: const Icon(Icons.add_rounded, size: 18),
                            label: const Text('Reading Now'),
                          ),
                        ),
                      ],
                    ),
                  )),
                  const SizedBox(height: 24),
                  Center(child: TextButton.icon(
                    icon: const Icon(Icons.refresh_rounded, size: 20),
                    label: const Text('Regenerate'),
                    onPressed: () => context.read<RecommendationBloc>().add(FetchRecommendations()),
                  )),
                ]),
              );
            }
            if (state is RecommendationError) {
              return Center(child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline_rounded, size: 48, color: isDark ? AppColors.darkError : AppColors.lightError),
                  const SizedBox(height: 16),
                  Text('Something went wrong', style: theme.textTheme.headlineSmall),
                  const SizedBox(height: 8),
                  Text(state.message, style: theme.textTheme.bodyMedium, textAlign: TextAlign.center),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => context.read<RecommendationBloc>().add(FetchRecommendations()),
                    child: const Text('Try Again'),
                  ),
                ],
              ));
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}
