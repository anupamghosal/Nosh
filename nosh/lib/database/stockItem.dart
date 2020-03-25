class StockItem {
  int ID;
  String NAME;
  String DATE;

  StockItem(this.NAME, this.DATE);

  setName(String NAME) {
    this.NAME = NAME;
  }

  setDate(String DATE) {
    this.DATE = DATE;
  }

  Map<String, dynamic> toMap() {
    var map = <String, dynamic> {
      'itemName': NAME,
      'date': DATE
    };
    return map;
  } 

  StockItem.fromMap(Map<String, dynamic> map) {
    ID = map['id'];
    NAME = map['itemName'];
    DATE = map['date'];
  } 
}