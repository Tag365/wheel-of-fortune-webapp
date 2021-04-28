import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class WheelItem {
  static int counter = 0;
  String name;
  bool edit;
  TextEditingController controller;
  FocusNode focusNode;

  WheelItem({@required this.name, this.edit = false})
      : this.controller = new TextEditingController(),
        this.focusNode = new FocusNode();

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
    if (edit) {
      controller.text = name;
    } else {
      controller.clear();
    }
  }

  static Color randomizeColor() {
    return Colors.primaries[counter++ % Colors.primaries.length];
  }
}
