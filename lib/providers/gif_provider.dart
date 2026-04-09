import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gif_app/models/gif.dart';
import 'package:gif_app/services/giphy_service.dart';

class GifState {
  final List<Gif> gifs;
  final int offset;
  final bool isLoadingMore;
  final String? errorMessage;

  GifState({
    this.gifs = const [],
    this.offset = 0,
    this.isLoadingMore = false,
    this.errorMessage,
  });

  GifState copyWith({
    List<Gif>? gifs,
    int? offset,
    bool? isLoadingMore,
    String? errorMessage,
  }) {
    return GifState(
      gifs: gifs ?? this.gifs,
      offset: offset ?? this.offset,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class GifNotifier extends StateNotifier<GifState> {
  GifNotifier() : super(GifState());

  Future<void> search(String query) async {
    if (query.isEmpty) {
      state = GifState();
      return;
    }
    state = GifState();
    try {
      final gifs = await searchGifs(query, offset: 0);
      state = state.copyWith(gifs: gifs, offset: 20);
    } catch (e) {
      state = state.copyWith(
          errorMessage: 'Something went wrong. Please try again.');
    }
  }

  Future<void> loadMore(String query) async {
    if (state.isLoadingMore) return;
    state = state.copyWith(isLoadingMore: true);
    try {
      final newGifs = await searchGifs(query, offset: state.offset);
      state = state.copyWith(
        gifs: [...state.gifs, ...newGifs],
        offset: state.offset + 20,
        isLoadingMore: false,
      );
    } catch (e) {
      state = state.copyWith(
          isLoadingMore: false, errorMessage: 'Failed to load GIFS');
    }
  }
}

final gifProvider = StateNotifierProvider<GifNotifier, GifState>(
  (ref) {
    return GifNotifier();
  },
);
