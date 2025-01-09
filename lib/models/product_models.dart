import 'dart:convert';

List<ProductModels> productModelsFromJson(String str) =>
    List<ProductModels>.from(
        json.decode(str).map((x) => ProductModels.fromJson(x)));

String productModelsToJson(List<ProductModels> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class ProductModels {
  int id;
  String title;
  double price;
  String description;
  Category category;
  String image;
  Rating rating;

  ProductModels({
    required this.id,
    required this.title,
    required this.price,
    required this.description,
    required this.category,
    required this.image,
    required this.rating,
  });

  factory ProductModels.fromJson(Map<String, dynamic> json) => ProductModels(
        id: json["id"],
        title: json["title"],
        price: json["price"]?.toDouble(),
        description: json["description"],
        category: categoryValues.map[json["category"]]!,
        image: json["image"],
        rating: Rating.fromJson(json["rating"]),
      );

  factory ProductModels.fromMap(Map<String, dynamic> map) => ProductModels(
        id: map["id"],
        title: map["title"],
        price: map["price"]?.toDouble(),
        description: map["description"],
        category: categoryValues.map[map["category"]]!,
        image: map["image"],
        rating: Rating.fromMap(map["rating"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "title": title,
        "price": price,
        "description": description,
        "category": categoryValues.reverse[category],
        "image": image,
        "rating": rating.toJson(),
      };

  Map<String, dynamic> toMap() => {
        "id": id,
        "title": title,
        "price": price,
        "description": description,
        "category": categoryValues.reverse[category],
        "image": image,
        "rating": rating.toMap(),
      };
}

enum Category { ELECTRONICS, JEWELERY, MEN_S_CLOTHING, WOMEN_S_CLOTHING }

final categoryValues = EnumValues({
  "electronics": Category.ELECTRONICS,
  "jewelery": Category.JEWELERY,
  "men's clothing": Category.MEN_S_CLOTHING,
  "women's clothing": Category.WOMEN_S_CLOTHING
});

class Rating {
  double rate;
  int count;

  Rating({
    required this.rate,
    required this.count,
  });

  factory Rating.fromJson(Map<String, dynamic> json) => Rating(
        rate: json["rate"]?.toDouble(),
        count: json["count"],
      );

  factory Rating.fromMap(Map<String, dynamic> map) => Rating(
        rate: map["rate"]?.toDouble(),
        count: map["count"],
      );

  Map<String, dynamic> toJson() => {
        "rate": rate,
        "count": count,
      };

  Map<String, dynamic> toMap() => {
        "rate": rate,
        "count": count,
      };
}

class EnumValues<T> {
  Map<String, T> map;
  late Map<T, String> reverseMap;

  EnumValues(this.map);

  Map<T, String> get reverse {
    reverseMap = map.map((k, v) => MapEntry(v, k));
    return reverseMap;
  }
}
