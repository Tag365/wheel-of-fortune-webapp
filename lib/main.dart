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
  final TextEditingController _textController = new TextEditingController();
  final FocusNode _focusNode = FocusNode();
  static const double EditHeight = 70;
  static const double ButtonHeight = 60;
  static const String versionNumber = "0.3.5";

  bool isCollapsed = false;
  bool toggleOnce = true;
  bool forcedToggle = false;
  double wheelWidth;
  int _selected = 0;
  int originalRandom;
  List<WheelItem> allItems;
  List<WheelItem> currentWheelItems;
  List<WheelItem> lastWheelItems;

  @override
  void initState() {
    if (html.window.localStorage['wheel_items'] == null || html.window.localStorage['wheel_items'] == "") {
      html.window.localStorage['wheel_items'] = "placeholder1,placeholder2";
    }
    buildItemList();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.of(context).size.width < 1000 && toggleOnce && !forcedToggle) {
      setState(() {
        isCollapsed = true;
        toggleOnce = false;
      });
    } else {
      setState(() {
        toggleOnce = true;
      });
    }
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
                  onAnimationStart: onAnimationStart,
                  onAnimationEnd: () => _showResult(context),
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
              Container(child: Text("Version $versionNumber | developed by Tag365 | hosted by Suened"))
            ],
          ),
        ),
        Container(
            height: MediaQuery
                .of(context)
                .size
                .height,
            width: 20,
            child: Column(children: [
              Container(
                height: MediaQuery
                    .of(context)
                    .size
                    .height / 2 - 15,
                child: VerticalDivider(
                  thickness: 2,
                ),
              ),
              Container(
                  height: 30,
                  child: InkWell(
                      child: Icon(
                          isCollapsed ? Icons.keyboard_arrow_left_outlined : Icons.keyboard_arrow_right_outlined,
                          size: 30),
                      onTap: _toggleListView)),
              Container(
                height: MediaQuery
                    .of(context)
                    .size
                    .height / 2 - 15,
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
        width: MediaQuery
            .of(context)
            .size
            .width / 4 - 20,
        child: Column(
          children: [
            Container(
                height: MediaQuery
                    .of(context)
                    .size
                    .height - EditHeight - ButtonHeight,
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
                          child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                            Text(item.name),
                            IconButton(
                              alignment: Alignment.centerRight,
                              icon: Icon(Icons.delete, size: 18,),
                              onPressed: () => _deleteItem(allItems[index]),
                            )
                          ]),
                          secondaryActions: [
                            IconSlideAction(
                              caption: "delete",
                              color: Colors.red,
                              icon: Icons.delete,
                              onTap: () => _deleteItem(allItems[index]),
                            )
                          ],
                        );
                      }),
                )),
            Container(
              height: EditHeight,
              child: TextField(
                controller: _textController,
                focusNode: _focusNode,
                style: TextStyle(fontSize: 18),
                decoration: InputDecoration(labelText: "Enter new entry"),
                onSubmitted: _changeWheelItems,
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
                onPressed: () => _changeWheelItems(null),
              ),
            )
          ],
        ),
      );
    }
  }

  void _startSpin() {
    int maxBound = currentWheelItems.length == 2 ? currentWheelItems.length : currentWheelItems.length - 1;
    originalRandom = Random().nextInt(maxBound);
    if (_selected == originalRandom) {
      List<int> tmp = List.generate(currentWheelItems.length, (index) => index);
      tmp.remove(originalRandom);
      setState(() {
        _selected = Fortune.randomItem(tmp, Random());
      });
    } else {
      setState(() {
        _selected = originalRandom;
      });
    }
  }

  void onAnimationStart() {
    setState(() {
      _selected = originalRandom;
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

  void _deleteItem(WheelItem item) {
    setState(() {
      allItems.remove(item);
    });
    saveAllItemsToLocalStorage();
  }

  void _submitTextEntry(String entry) {

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
    if (MediaQuery.of(context).size.width < 1000 && !isCollapsed){
      setState(() {
        forcedToggle = true;
      });
    } else {
      setState(() {
        forcedToggle = false;
      });
    }
  }

  double getWheelWidth(BuildContext context) {
    if (isCollapsed) {
      return MediaQuery
          .of(context)
          .size
          .width - 50;
    } else {
      return (MediaQuery
          .of(context)
          .size
          .width / 4) * 3;
    }
  }

  void buildItemList() {
    List<String> spliced = html.window.localStorage['wheel_items'].split(",");
    var tmp = List.generate(spliced.length, (index) => new WheelItem(name: spliced[index]));
    setState(() {
      currentWheelItems = []..addAll(tmp);
      allItems = []..addAll(tmp);
      lastWheelItems = []..addAll(tmp);
    });
  }

  void _changeWheelItems(String entry) {
    if (_textController.text.isNotEmpty) {
      WheelItem newItem = new WheelItem(name: _textController.text);
      setState(() {
        allItems.add(newItem);
      });
      saveAllItemsToLocalStorage();
      _textController.clear();
      _focusNode.requestFocus();
    }
    if (allItems.length > 1) {
      setState(() {
        currentWheelItems = []..addAll(allItems);
        lastWheelItems = []..addAll(allItems);
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(new SnackBar(
          behavior: SnackBarBehavior.floating,
          width: 400,
          backgroundColor: Colors.grey,
          content: Text(
            "You must have at least two Items in your List before submitting it to the wheel",
            style: TextStyle(color: Colors.white),
            textAlign: TextAlign.center,
          )));
    }
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

  void saveAllItemsToLocalStorage() {
    String localStorageString = "";
    if (allItems.length > 0) {
      for (WheelItem item in allItems) {
        localStorageString += item.name + ",";
      }
      html.window.localStorage['wheel_items'] = localStorageString.substring(0, localStorageString.length - 1);
    } else {
      html.window.localStorage['wheel_items'] = "";
    }
  }
}
