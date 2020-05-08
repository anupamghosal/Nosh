class ShoppingItem {
  String id;
  String name;
  String quantity;
  bool isChecked;

  ShoppingItem({this.id, this.name, this.quantity, this.isChecked = false});

  ShoppingItem copyWith(
      {String id, String name, String quantity, bool isChecked}) {
    return ShoppingItem(
        id: id ?? this.id,
        name: name ?? this.name,
        quantity: quantity ?? this.quantity,
        isChecked: isChecked ?? this.isChecked);
  }

  ShoppingItem.fromJson(Map json)
      : id = json['id'],
        name = json['name'],
        quantity = json['quantity'],
        isChecked = json['isChecked'];

  //for previous db
  ShoppingItem.fromPrevMap(Map json) {
    id = json['listItemId'].toString();
    name = json['listItemName'];
    quantity = json['listItemQuantity'];
  }

  Map toJson() =>
      {'id': id, 'name': name, 'quantity': quantity, 'isChecked': isChecked};
}
