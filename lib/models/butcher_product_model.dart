class ButcherProduct {
  final String name;
  final String price;
  final String unit;
  final String imageAsset;
  final String description;

  const ButcherProduct({
    required this.name,
    required this.price,
    required this.unit,
    this.imageAsset = '',
    this.description = '',
  });
}
