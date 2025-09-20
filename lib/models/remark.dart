class Remark {
  final int id;
  final String text;
  final List<String> imageUrls;

  Remark({required this.id, required this.text, required this.imageUrls});

  factory Remark.fromJson(Map<String, dynamic> json) {
    return Remark(
      id: json['remark_id'] is int
          ? json['remark_id'] as int
          : int.tryParse(json['remark_id']?.toString() ?? '0') ?? 0,
      text: json['text']?.toString() ?? '',
      imageUrls:
          (json['remark_photos'] as List?)
              ?.map((p) => p['photo_url']?.toString() ?? '')
              .where((url) => url.isNotEmpty)
              .toList() ??
          [],
    );
  }
}
