import 'package:flutter_test/flutter_test.dart';
import 'package:gif_app/providers/gif_provider.dart';

void main() {
  test('GifState starts with empty gifs', () {
    final state = GifState();

    expect(state.gifs, isEmpty);
    expect(state.offset, 0);
    expect(state.isLoadingMore, false);
    expect(state.errorMessage, null);
  });

  test('GifState copyWith updates only the given fields', () {
    final state = GifState();
    final updated = state.copyWith(offset: 20, isLoadingMore: true);

    expect(updated.offset, 20);
    expect(updated.isLoadingMore, true);
    expect(updated.gifs, isEmpty);
  });
}
