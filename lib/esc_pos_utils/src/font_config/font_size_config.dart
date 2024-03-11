class FontSizeConfig {
  const FontSizeConfig({required this.maxCharsPerLineSmall, required this.maxCharsPerLineLarge});

  final int maxCharsPerLineSmall;
  final int maxCharsPerLineLarge;
}

enum Size {
  small(1),
  large(2);

  const Size(this.value);

  final int value;
}