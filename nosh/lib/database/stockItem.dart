class StockItem {
  int _stockItemId;
  String _stockItemName;
  String _stockItemExpiryDate;
  String _image;
  String _quantity;

  StockItem(this._stockItemName, this._stockItemExpiryDate, this._image, this._quantity);

  setName(String stockItemName) {
    _stockItemName = stockItemName;
  }

  setExpiryDate(String stockItemExpiryDate) {
    _stockItemExpiryDate = stockItemExpiryDate;
  }

  setId(int stockItemId) {
    _stockItemId = stockItemId;
  }

  setQuantity(String quantity) {
    _quantity = quantity;
  }

  setImage(String image) {
    _image = image;
  }

  getName() {
    return _stockItemName;
  }

  getExpiryDate() {
    return _stockItemExpiryDate;
  }

  getId() {
    return _stockItemId;
  }

  getImage() {
    return _image;
  }

  getQuantity() {
    return _quantity;
  }

  Map<String, dynamic> toMap() {
    var map = <String, dynamic> {
      'stockItemName': _stockItemName,
      'stockItemExpiryDate': _stockItemExpiryDate,
      'stockItemImage': _image,
      'stockItemQuantity': _quantity
    };
    return map;
  } 

  StockItem.fromMap(Map<String, dynamic> map) {
    _stockItemId = map['stockItemId'];
    _stockItemName = map['stockItemName'];
    _stockItemExpiryDate = map['stockItemExpiryDate'];
    _image = map['stockItemImage'];
    _quantity = map['stockItemQuantity'];
  } 
}