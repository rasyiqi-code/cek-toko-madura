class StockItem {
  final String id;
  final String category;
  final String name;
  double modalPrice;
  int currentStock;

  StockItem({
    required this.id,
    required this.category,
    required this.name,
    required this.modalPrice,
    required this.currentStock,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'category': category,
        'name': name,
        'modalPrice': modalPrice,
        'currentStock': currentStock,
      };

  factory StockItem.fromJson(Map<String, dynamic> json) => StockItem(
        id: json['id'],
        category: json['category'],
        name: json['name'],
        modalPrice: json['modalPrice'].toDouble(),
        currentStock: json['currentStock'],
      );
}
