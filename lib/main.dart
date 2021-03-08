import 'dart:html' as html;
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_fortune_wheel/flutter_fortune_wheel.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:wheel_flutter/WheelItem.dart';

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
  List<WheelItem> allItems;
  List<WheelItem> currentWheelItems;
  List<WheelItem> lastWheelItems;
  final TextEditingController _textController = new TextEditingController();
  static const double EditHeight = 70;
  static const double ButtonHeight = 60;
  bool isCollapsed = false;
  double wheelWidth;
  String localStorageString;

  @override
  void initState() {
    if (html.window.localStorage['wheel_items'] == null) {
      html.window.localStorage['wheel_items'] = "placeholder1,placeholder2";
    }
    localStorageString = html.window.localStorage['wheel_items'];
    buildItemList();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(children: [
        Container(
          width: getWheelWidth(context),
          child: Column(
            children: [
              Expanded(
                child: FortuneWheel(
                  styleStrategy: UniformStyleStrategy(),
                  animateFirst: false,
                  selected: _selected,
                  physics: NoPanPhysics(),
                  onAnimationEnd: () => _showResult(context),
                  //indicators: [FortuneIndicator(child: TriangleIndicator(), alignment: Alignment.topCenter)],
                  items: [
                    for (var item in currentWheelItems)
                      FortuneItem(
                          child: Text(
                        item.name,
                        style: TextStyle(fontSize: 20),
                      )),
                  ],
                ),
              ),
              Container(
                  padding: EdgeInsets.all(10),
                  child: ButtonBar(alignment: MainAxisAlignment.center, children: [
                    ElevatedButton(
                        child: Text("SPIN", style: TextStyle(fontSize: 30)),
                        style: ElevatedButton.styleFrom(primary: Colors.grey),
                        onPressed: _startSpin),
                    ElevatedButton(
                      child: Text("Reset", style: TextStyle(fontSize: 20)),
                      style: ElevatedButton.styleFrom(primary: Colors.grey),
                      onPressed: _resetWheel,
                    )
                  ])),
            ],
          ),
        ),
        Container(
            height: MediaQuery.of(context).size.height,
            width: 20,
            child: Column(children: [
              Container(
                height: MediaQuery.of(context).size.height / 2 - 10,
                child: VerticalDivider(
                  thickness: 2,
                ),
              ),
              Container(
                  height: 20,
                  child: InkWell(
                      child:
                          Icon(isCollapsed ? Icons.keyboard_arrow_left_outlined : Icons.keyboard_arrow_right_outlined),
                      onTap: _toggleListView)),
              Container(
                height: MediaQuery.of(context).size.height / 2 - 10,
                child: VerticalDivider(
                  thickness: 2,
                ),
              ),
            ])),
        buildListView(context),
      ]),
    );
  }

  Widget buildListView(BuildContext context) {
    if (isCollapsed) {
      return Container(
        width: 10,
      );
    } else {
      return Container(
        width: MediaQuery.of(context).size.width / 4 - 20,
        child: Column(
          children: [
            Container(
                height: MediaQuery.of(context).size.height - EditHeight - ButtonHeight,
                child: Scrollbar(
                  isAlwaysShown: true,
                  thickness: 7.5,
                  child: ListView.builder(
                      itemCount: allItems.length,
                      itemBuilder: (context, index) {
                        final item = allItems[index];
                        return Slidable(
                          actionPane: SlidableDrawerActionPane(),
                          actionExtentRatio: 0.25,
                          child: ListTile(title: Text(item.name)),
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
                )),
            Container(
              height: EditHeight,
              child: TextField(
                controller: _textController,
                style: TextStyle(fontSize: 18),
                decoration: InputDecoration(labelText: "Enter new entry"),
                onSubmitted: _submitTextEntry,
              ),
            ),
            Container(
              padding: EdgeInsets.all(10),
              height: ButtonHeight,
              child: ElevatedButton(
                child: Text(
                  "Submit",
                  style: TextStyle(fontSize: 18),
                ),
                style: ElevatedButton.styleFrom(primary: Colors.grey),
                onPressed: _changeWheelItems,
              ),
            )
          ],
        ),
      );
    }
  }

  void _startSpin() {
    setState(() {
      _selected = Random().nextInt(currentWheelItems.length - 1);
    });
  }

  void _showResult(BuildContext context) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("We have a winner!"),
            content: Text("The winner is: ${currentWheelItems[_selected].name}"),
            actions: [ElevatedButton(onPressed: () => _closePopUpAndRemoveEntry(context), child: Text("close"))],
          );
        });
  }

  void _deleteItem(int index) {
    setState(() {
      allItems.removeAt(index);
    });
  }

  void _submitTextEntry(String entry) {
    WheelItem newItem = new WheelItem(name: entry);
    setState(() {
      allItems.add(newItem);
    });
    html.window.localStorage['wheel_items'] += "," + newItem.name;
    _textController.text = "";
  }

  void _resetWheel() {
    setState(() {
      currentWheelItems = []..addAll(lastWheelItems);
    });
  }

  void _toggleListView() {
    setState(() {
      isCollapsed = !isCollapsed;
    });
  }

  double getWheelWidth(BuildContext context) {
    if (isCollapsed) {
      return MediaQuery.of(context).size.width - 50;
    } else {
      return (MediaQuery.of(context).size.width / 4) * 3;
    }
  }

  void buildItemList() {
    List<String> spliced = localStorageString.split(",");
    var tmp = List.generate(spliced.length, (index) => new WheelItem(name: spliced[index]));
    setState(() {
      currentWheelItems = []..addAll(tmp);
      allItems = []..addAll(tmp);
      lastWheelItems = []..addAll(tmp);
    });
  }

  void _changeWheelItems() {
    if (_textController.text.isNotEmpty) _submitTextEntry(_textController.text);
    setState(() {
      currentWheelItems = []..addAll(allItems);
      lastWheelItems = []..addAll(allItems);
    });
  }

  void _closePopUpAndRemoveEntry(BuildContext context) {
    if (currentWheelItems.length > 2) {
      setState(() {
        currentWheelItems.removeAt(_selected);
        currentWheelItems.shuffle();
      });
    }
    Navigator.of(context).pop();
  }
}
