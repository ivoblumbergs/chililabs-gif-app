import 'package:flutter_test/flutter_test.dart';
import 'package:gif_app/models/gif.dart';

void main() {
  test('Gif.fromJson extracts URL', () {
    final json = {
      'images': {
        'fixed_height': {
          'url': 'https://media.giphy.com/test.gif',
        }
      }
    };

    final gif = Gif.fromJson(json);

    expect(gif.url, 'https://media.giphy.com/test.gif');
  });
}
