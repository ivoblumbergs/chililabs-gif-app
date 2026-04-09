import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gif_app/providers/search_provider.dart';

void main() {
  test('searchQueryProvider starts as empty string', () {
    final container = ProviderContainer();

    expect(container.read(searchQueryProvider), '');

    container.dispose();
  });

  test('searchQueryProvider updates when state changes', () {
    final container = ProviderContainer();

    container.read(searchQueryProvider.notifier).state = 'cats';

    expect(container.read(searchQueryProvider), 'cats');

    container.dispose();
  });
}
