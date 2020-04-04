class ExpiredItem {
  int _expiredItemId;
  String _expiredItemName;
  String _expiredItemExpiryDate;
  String _image;
  String _quantity;

  ExpiredItem(this._expiredItemName, this._expiredItemExpiryDate, this._image, this._quantity);

  setName(String expiredItemName) {
    _expiredItemName = expiredItemName;
  }

  setExpiryDate(String expiredItemExpiryDate) {
    _expiredItemExpiryDate = expiredItemExpiryDate;
  }

  setId(int expiredItemId) {
    _expiredItemId = expiredItemId;
  }

  setQuantity(String quantity) {
    _quantity = quantity;
  }

  getName() {
    return _expiredItemName;
  }

  getExpiryDate() {
    return _expiredItemExpiryDate;
  }

  getId() {
    return _expiredItemId;
  }

  getImage() {
    return _image;
  }

  getQuantity() {
    return _quantity;
  }

  Map<String, dynamic> toMap() {
    var map = <String, dynamic> {
      'expiredItemName': _expiredItemName,
      'expiredItemExpiryDate': _expiredItemExpiryDate,
      'expiredItemImage': _image,
      'expiredItemQuantity': _quantity
    };
    return map;
  } 

  ExpiredItem.fromMap(Map<String, dynamic> map) {
    _expiredItemId = map['expiredItemId'];
    _expiredItemName = map['expiredItemName'];
    _expiredItemExpiryDate = map['expiredItemExpiryDate'];
    _image = map['expiredItemImage'];
    _quantity = map['expiredItemQuantity'];
  } 
}