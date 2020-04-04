class ListItem {
  int _listItemId;
  String _listItemName;
  String _quantity;

  ListItem(this._listItemName, this._quantity);

  setName(String listItemName) {
    _listItemName = listItemName;
  }

  setId(int listItemId) {
    _listItemId = listItemId;
  }

  setQuantity(String quantity) {
    _quantity = quantity;
  }

  getName() {
    return _listItemName;
  }

  getId() {
    return _listItemId;
  }

  getQuantity() {
    return _quantity;
  }

  Map<String, dynamic> toMap() {
    var map = <String, dynamic> {
      'listItemName': _listItemName,
      'listItemQuantity': _quantity
    };
    return map;
  } 

  ListItem.fromMap(Map<String, dynamic> map) {
    _listItemId = map['listItemId'];
    _listItemName = map['listItemName'];
    _quantity = map['listItemQuantity'];
  } 
}