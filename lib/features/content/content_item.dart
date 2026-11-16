enum ContentKind { video, book }

class ContentItem {
  const ContentItem({
    required this.id,
    required this.title,
    required this.description,
    required this.kind,
    required this.category,
    this.videoPath,
    this.imagePath,
    this.thumbnailPath,
    this.externalLink,
    this.fullText,
    this.premiumOnly = false,
    this.comingSoon = false,
  });

  final String id;
  final String title;
  final String description;
  final ContentKind kind;
  final String category;
  final String? videoPath;
  final String? imagePath;
  final String? thumbnailPath;
  final String? externalLink;
  final String? fullText;
  final bool premiumOnly;
  final bool comingSoon;

  bool get isVideo => kind == ContentKind.video;
}
