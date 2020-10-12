import 'package:Tasks/addCategoryForm.dart';
import 'package:Tasks/addThingForm.dart';
import 'package:flutter/material.dart';
import 'package:grouped_list/grouped_list.dart';

import 'routeTwo.dart';
import 'DBFunc.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
        // This makes the visual density adapt to the platform that you run
        // the app on. For desktop platforms, the controls will be smaller and
        // closer together (more dense) than on mobile platforms.
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool dragLeftStarted = false;

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    startDB();
    return Scaffold(
        appBar: AppBar(
          // Here we take the value from the MyHomePage object that was created by
          // the App.build method, and use it to set our appbar title.
          title: Text(widget.title),
        ),
        body: Center(
          // Center is a layout widget. It takes a single child and positions it
          // in the middle of the parent.
          child: Column(
            // Column is also a layout widget. It takes a list of children and
            // arranges them vertically. By default, it sizes itself to fit its
            // children horizontally, and tries to be as tall as its parent.
            //
            // Invoke "debug painting" (press "p" in the console, choose the
            // "Toggle Debug Paint" action from the Flutter Inspector in Android
            // Studio, or the "Toggle Debug Paint" command in Visual Studio Code)
            // to see the wireframe for each widget.
            //
            // Column has various properties to control how it sizes itself and
            // how it positions its children. Here we use mainAxisAlignment to
            // center the children vertically; the main axis here is the vertical
            // axis because Columns are vertical (the cross axis would be
            // horizontal).
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Spacer(
                flex: 1,
              ),
              FutureBuilder(
                future: tasks(),
                builder: (context, snapshot) {
                  // ROW ACROSS THE TOP
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      (dragLeftStarted
                          ? DragTarget(
                              onAccept: (data) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => SecondRoute(),
                                  ),
                                );
                              },
                              builder: (BuildContext context,
                                  List<dynamic> candidateData,
                                  List<dynamic> rejectedData) {
                                return Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Container(
                                    height: 120,
                                    width: 22,
                                    decoration: BoxDecoration(
                                        border: Border.all(),
                                        color: Colors.transparent,
                                        borderRadius:
                                            BorderRadius.circular(20.0)),
                                  ),
                                );
                              },
                            )
                          : Container()),
                      // RIGHT DRAGGABLE LIST VIEW
                      Draggable(
                        axis: Axis.horizontal,
                        child: Container(
                          width: 55,
                          height: 150,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(5),
                            border: Border.all(),
                          ),
                          child: Column(
                            children: [
                              Spacer(
                                flex: 1,
                              ),
                              Center(
                                  child: Container(
                                width: 50,
                                height: 50,
                                child: Center(
                                  child: Text((snapshot.hasData
                                      ? snapshot.data.length.toString()
                                      : "-")),
                                ),
                                decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Color(0xFFe0f2f1)),
                              )),
                              Spacer(
                                flex: 4,
                              ),
                            ],
                          ),
                        ),
                        childWhenDragging: Container(),
                        feedback: Container(
                          width: 500,
                          height: 550,
                          child: Row(
                            children: [
                              Column(
                                children: [
                                  Container(
                                    width: 50,
                                    height: 150,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(2),
                                      border: Border.all(),
                                    ),
                                    child: Column(
                                      children: [
                                        Spacer(
                                          flex: 1,
                                        ),
                                        Material(
                                          child: Center(
                                            child: Container(
                                              width: 50,
                                              height: 50,
                                              child: Center(
                                                child: Text((snapshot.hasData
                                                    ? snapshot.data.length
                                                        .toString()
                                                    : "-")),
                                              ),
                                              decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  color: Color(0xFFe0f2f1)),
                                            ),
                                          ),
                                        ),
                                        Spacer(
                                          flex: 4,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Container(
                                      height: 550,
                                      width: 450,
                                      child: Material(
                                          child: (snapshot.hasData
                                              ? Container(
                                                  child: GroupedListView<
                                                      dynamic, String>(
                                                    elements: snapshot.data,
                                                    groupBy: (element) =>
                                                        element.date,
                                                    groupComparator: (value1,
                                                            value2) =>
                                                        value2
                                                            .compareTo(value1),
                                                    itemComparator: (item1,
                                                            item2) =>
                                                        item1.title.compareTo(
                                                            item2.title),
                                                    order:
                                                        GroupedListOrder.DESC,
                                                    useStickyGroupSeparators:
                                                        false,
                                                    groupSeparatorBuilder:
                                                        (String value) =>
                                                            Container(
                                                      color: Colors.amber,
                                                      child: Text(
                                                        value,
                                                        textAlign:
                                                            TextAlign.center,
                                                        style: TextStyle(
                                                            fontSize: 18,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                      ),
                                                    ),
                                                    itemBuilder: (c, element) {
                                                      return Card(
                                                        elevation: 2.0,
                                                        margin: new EdgeInsets
                                                                .symmetric(
                                                            horizontal: 10.0,
                                                            vertical: 1.0),
                                                        child: Container(
                                                          child: ListTile(
                                                            contentPadding:
                                                                EdgeInsets.symmetric(
                                                                    horizontal:
                                                                        20.0,
                                                                    vertical:
                                                                        2.0),
                                                            leading: Icon(Icons
                                                                .account_circle),
                                                            title: Text(
                                                                element.title),
                                                            trailing: Icon(Icons
                                                                .arrow_forward),
                                                          ),
                                                        ),
                                                      );
                                                    },
                                                  ),
                                                )
                                              : Container())
                                          // BREAK UP INTO OTHER FILES AND WIDGETS PLZ
                                          )),
                                ],
                              )
                            ],
                          ),
                        ),
                        onDragStarted: () {
                          setState(() {
                            dragLeftStarted = true;
                          });
                        },
                        onDragEnd: (details) {
                          setState(() {
                            dragLeftStarted = false;
                          });
                        },
                        onDragCompleted: () {
                          setState(() {});
                        },
                      ),
                    ],
                  );
                },
              ),
              Spacer(
                flex: 4,
              ),
            ],
          ),
        ),
        floatingActionButton: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            FloatingActionButton(
              backgroundColor: Color.fromARGB(100, 10, 10, 10),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) {
                    return AddCategoryForm();
                  },
                ).then((value) => {
                      if (value != null)
                        {insertCategory(value['category_name'])}
                    });
              },
              tooltip: 'Increment',
              child: Icon(Icons.add),
            ),
            FloatingActionButton(
              heroTag: null,
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) {
                    return AddThingForm();
                  },
                ).then((value) => {
                      if (value != null)
                        {
                          insertThing(
                              value['thing_name'], value['category_attached'])
                        }
                    });
              },
              tooltip: 'Increment',
              child: Icon(Icons.add),
            ),
          ],
        ));
  }
}
