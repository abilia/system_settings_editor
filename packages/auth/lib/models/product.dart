/// Should correspond to products in
///  https://github.com/abilia/whale2/blob/main/backend/src/main/java/com/abilia/models/data/Product.kt
enum Product {
  handicalendar,
  memoplanner3,
  memoplanner,
  gewaconnect,
  carybase,
  unknown,
}

extension ParseProduct on Map<String, dynamic> {
  Product parseProduct() =>
      Product.values.asNameMap()[this['product']] ?? Product.unknown;
}
