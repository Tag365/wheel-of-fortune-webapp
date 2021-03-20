import 'package:flutter/foundation.dart';

class WheelItem {
  String name;
  bool edit;

  WheelItem({@required this.name, this.edit = false});

  WheelItem.fromMap(Map<String, dynamic> map) : name = map['name'];

  Map<String, dynamic> toMap() {
    return {'name': name};
  }

  @override
  String toString() {
    return "{Name: $name, Edit: $edit}";
  }
}
