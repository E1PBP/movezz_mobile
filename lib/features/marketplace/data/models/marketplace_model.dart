// To parse this JSON data, do
//
//     final marketplaceModel = marketplaceModelFromJson(jsonString);

import 'dart:convert';

List<MarketplaceModel> marketplaceModelFromJson(String str) => List<MarketplaceModel>.from(json.decode(str).map((x) => MarketplaceModel.fromJson(x)));

String marketplaceModelToJson(List<MarketplaceModel> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class MarketplaceModel {
    Model model;
    String pk;
    Fields fields;
    bool isMine;

    MarketplaceModel({
        required this.model,
        required this.pk,
        required this.fields,
        required this.isMine,
    });

    factory MarketplaceModel.fromJson(Map<String, dynamic> json) => MarketplaceModel(
        model: modelValues.map[json["model"]]!,
        pk: json["pk"],
        fields: Fields.fromJson(json["fields"]),
        isMine: (json["isMine"] as bool?) ?? false,
    );

    Map<String, dynamic> toJson() => {
        "model": modelValues.reverse[model],
        "pk": pk,
        "fields": fields.toJson(),
        "isMine": isMine,
    };
}

class Fields {
    int owner;
    String title;
    int price;
    Condition condition;
    String location;
    String imageUrl;

    Fields({
        required this.owner,
        required this.title,
        required this.price,
        required this.condition,
        required this.location,
        required this.imageUrl,
    });

    factory Fields.fromJson(Map<String, dynamic> json) => Fields(
        owner: json["owner"],
        title: json["title"],
        price: json["price"],
        condition: conditionValues.map[json["condition"]]!,
        location: json["location"],
        imageUrl: json["image_url"],
    );

    Map<String, dynamic> toJson() => {
        "owner": owner,
        "title": title,
        "price": price,
        "condition": conditionValues.reverse[condition],
        "location": location,
        "image_url": imageUrl,
    };
}

enum Condition {
    BRAND_NEW,
    USED
}

final conditionValues = EnumValues({
    "BRAND_NEW": Condition.BRAND_NEW,
    "USED": Condition.USED
});

enum Model {
    MARKETPLACE_MODULE_LISTING
}

final modelValues = EnumValues({
    "marketplace_module.listing": Model.MARKETPLACE_MODULE_LISTING
});

class EnumValues<T> {
    Map<String, T> map;
    late Map<T, String> reverseMap;

    EnumValues(this.map);

    Map<T, String> get reverse {
            reverseMap = map.map((k, v) => MapEntry(v, k));
            return reverseMap;
    }
}
