class WheelItem {
  final String key;
  final String name;

  WheelItem({this.key, this.name});

  WheelItem.fromMap(Map<String, dynamic> map)
      : key = map['key'],
        name = map['name'];

  Map<String, dynamic> toMap(){
    return {
      'key' : key,
      'name' : name
    };
  }
}
