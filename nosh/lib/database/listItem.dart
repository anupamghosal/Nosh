class ListItem {
  int _listItemId;
  String _listItemName;

  ListItem(this._listItemName);

  setName(String listItemName) {
    _listItemName = listItemName;
  }

  setId(int listItemId) {
    _listItemId = listItemId;
  }

  getName() {
    return _listItemName;
  }

  getId() {
    return _listItemId;
  }

  Map<String, dynamic> toMap() {
    var map = <String, dynamic> {
      'listItemName': _listItemName,
    };
    return map;
  } 

  ListItem.fromMap(Map<String, dynamic> map) {
    _listItemId = map['listItemId'];
    _listItemName = map['listItemName'];
  } 
}