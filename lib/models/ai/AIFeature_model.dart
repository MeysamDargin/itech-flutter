class AIFeature {
  final String title;
  final String emoji;
  final String description;
  final Function() onTap;
  final bool hasHalo;

  AIFeature({
    required this.title,
    required this.emoji,
    required this.description,
    required this.onTap,
    this.hasHalo = false,
  });
}
