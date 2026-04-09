class Gif {
  final String url;
  final String width;
  final String height;
  final String size;

  Gif({
    required this.url,
    required this.width,
    required this.height,
    required this.size,
  });

  factory Gif.fromJson(Map<String, dynamic> json) {
    final fixedHeight = json['images']['fixed_height'];
    return Gif(
      url: fixedHeight['url'],
      width: fixedHeight['width'],
      height: fixedHeight['height'],
      size: fixedHeight['size'],
    );
  }
}
