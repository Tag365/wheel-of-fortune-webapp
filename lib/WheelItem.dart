import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class WheelItem {
  static int counter = 0;
  String name;
  bool edit;
  Color color;


  WheelItem({@required this.name, this.edit = false})
      : this.color = randomizeColor();

  WheelItem.fromMap(Map<String, dynamic> map) : name = map['name'];

  Map<String, dynamic> toMap() {
    return {'name': name};
  }

  @override
  String toString() {
    return "{Name: $name, Edit: $edit}";
  }

  toggleEdit() {
    edit = !edit;
  }

  static Color randomizeColor() {
    return Colors.primaries[counter++ % Colors.primaries.length];
  }
}
