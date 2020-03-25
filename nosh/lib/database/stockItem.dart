class StockItem {
  int _stockItemId;
  String _stockItemName;
  String _stockItemExpiryDate;

  StockItem(this._stockItemName, this._stockItemExpiryDate);

  setName(String stockItemName) {
    _stockItemName = stockItemName;
  }

  setExpiryDate(String stockItemExpiryDate) {
    _stockItemExpiryDate = stockItemExpiryDate;
  }

  setId(int stockItemId) {
    _stockItemId = stockItemId;
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

  Map<String, dynamic> toMap() {
    var map = <String, dynamic> {
      'stockItemName': _stockItemName,
      'stockItemExpiryDate': _stockItemExpiryDate
    };
    return map;
  } 

  StockItem.fromMap(Map<String, dynamic> map) {
    _stockItemId = map['stockItemId'];
    _stockItemName = map['stockItemName'];
    _stockItemExpiryDate = map['stockItemExpiryDate'];
  } 
}