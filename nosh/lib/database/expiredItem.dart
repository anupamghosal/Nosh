class ExpiredItem {
  int _expiredItemId;
  String _expiredItemName;
  String _expiredItemExpiryDate;
  String _image;

  ExpiredItem(this._expiredItemName, this._expiredItemExpiryDate, this._image);

  setName(String expiredItemName) {
    _expiredItemName = expiredItemName;
  }

  setExpiryDate(String expiredItemExpiryDate) {
    _expiredItemExpiryDate = expiredItemExpiryDate;
  }

  setId(int expiredItemId) {
    _expiredItemId = expiredItemId;
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

  Map<String, dynamic> toMap() {
    var map = <String, dynamic> {
      'expiredItemName': _expiredItemName,
      'expiredItemExpiryDate': _expiredItemExpiryDate,
      'expiredItemImage': _image
    };
    return map;
  } 

  ExpiredItem.fromMap(Map<String, dynamic> map) {
    _expiredItemId = map['expiredItemId'];
    _expiredItemName = map['expiredItemName'];
    _expiredItemExpiryDate = map['expiredItemExpiryDate'];
    _image = map['expiredItemImage'];
  } 
}