class Item {
  String id;
  String name;
  DateTime expiry;
  String imageUri;
  String quantity;

  Item({this.id, this.name, this.quantity, this.expiry, this.imageUri = ''});

  Item copyWith({String id, String name, String quantity, String imageUri}) {
    return Item(
        id: id ?? this.id,
        name: name ?? this.name,
        quantity: quantity ?? this.quantity,
        expiry: expiry ?? this.expiry,
        imageUri: imageUri ?? this.imageUri);
  }

  Item.fromJson(Map json) {
    id = json['id'];
    name = json['name'];
    quantity = json['quantity'];
    expiry = json['expiry'] == null ? null : DateTime.parse(json['expiry']);
    imageUri = json['imageUri'];
  }

  //for previous db
  Item.fromPrevStockMap(Map json) {
    id = json['stockItemId'].toString();
    name = json['stockItemName'];
    quantity = json['stockItemQuantity'];
    expiry = json['stockItemExpiryDate'] == '' ? null : DateTime.parse(json['expiry']);
    imageUri = json['stockItemImage'];
  }

  Item.fromPrevExpiryMap(Map json) {
    id = json['expiryItemId'].toString();
    name = json['expiryItemName'];
    quantity = json['expiryItemQuantity'];
    expiry = json['expiryItemExpiryDate'] == '' ? null : DateTime.parse(json['expiry']);
    imageUri = json['expiredItemImage'];
  }

  Map toJson() => {
        'id': id,
        'name': name,
        'quantity': quantity,
        'expiry': expiry == null ? null : expiry.toString(),
        'imageUri': imageUri
      };
}
