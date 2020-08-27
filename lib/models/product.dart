import 'package:meta/meta.dart';

class Product {
  String id;
  String name;
  String description;
  num price;
  String image_url;

  Product(
      {@required this.id,
      @required this.name,
      @required this.description,
      @required this.price,
      @required this.image_url});

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
        id: json['_id']["\$oid"],
        name: json['name'],
        description: json['description'],
        price: json['price'],
        image_url: json['image_url']);
  }
}
