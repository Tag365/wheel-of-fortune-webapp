class WheelItem {
  final String name;

  WheelItem({this.name});

  WheelItem.fromMap(Map<String, dynamic> map)
      : name = map['name'];

  Map<String, dynamic> toMap(){
    return {
      'name' : name
    };
  }
}
