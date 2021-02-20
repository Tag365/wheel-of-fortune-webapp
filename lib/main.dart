import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_fortune_wheel/flutter_fortune_wheel.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

void main() {
  runApp(WheelHomeWidget());
}

class WheelHomeWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Fortune Wheel",
      home: Wheel(),
      debugShowCheckedModeBanner: false,
      theme: ThemeData(brightness: Brightness.dark, primaryColor: Colors.grey, accentColor: Colors.white),
    );
  }
}

class Wheel extends StatefulWidget {
  @override
  _WheelState createState() => _WheelState();
}

class _WheelState extends State<Wheel> {
  int _selected = 0;
  List<String> items = [
    "1",
    "2",
    "3",
    "4",
    "5",
    "6",
    "7",
    "8",
    "9",
    "10",
    "11",
    "12",
    "13",
    "14"
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(children: [
        Container(
          width: (MediaQuery.of(context).size.width / 3) * 2,
          child: Column(
            children: [
              Expanded(
                child: FortuneWheel(
                  styleStrategy: UniformStyleStrategy(),
                  animateFirst: false,
                  selected: _selected,
                  onAnimationEnd: _showResult,
                  items: [
                    for (var it in items)
                      FortuneItem(
                          child: Text(
                        it,
                        style: TextStyle(fontSize: 20),
                      )),
                  ],
                ),
              ),
              Container(
                  padding: EdgeInsets.all(10),
                  child: ElevatedButton(
                      child: Text("SPIN", style: TextStyle(fontSize: 30)),
                      style: ElevatedButton.styleFrom(primary: Colors.grey),
                      onPressed: _startSpin)),
            ],
          ),
        ),
        Container(
          width: MediaQuery.of(context).size.width / 3,
          child: ListView.builder(
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                return Slidable(
                  actionPane: SlidableDrawerActionPane(),
                  actionExtentRatio: 0.25,
                  child: ListTile(title: Text(item)),
                  secondaryActions: [
                    IconSlideAction(
                      caption: "delete",
                      color: Colors.red,
                      icon: Icons.delete,
                      onTap: () => _deleteItem(index),
                    )
                  ],
                );
              }),
        ),
      ]),
    );
  }

  void _startSpin() {
    setState(() {
      _selected = Random().nextInt(items.length);
    });
  }

  void _showResult() {}

  void _deleteItem(int index) {
    setState(() {
      items.removeAt(index);
    });
  }
}
