import 'package:Tasks/taskDetailView.dart';
import 'package:flutter/material.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:intl/intl.dart';
import 'addTaskForm.dart';
import 'DBFunc.dart';

class SecondRoute extends StatefulWidget {
  @override
  _SecondRouteState createState() => _SecondRouteState();
}

class _SecondRouteState extends State<SecondRoute> {
  // Dict used to save values of checkboxes
  var taskDict = {};
  // Dict to sent to UPDATE of changed values
  var taskChanged = {};
  bool hideCompleted = true;
  bool hideSubTask = true;
  var groupBy = 'date';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          leadingWidth: (taskChanged.length > 0 ? 112.0 : 56.0),
          leading: Builder(
            builder: (BuildContext context) {
              if (taskChanged.length > 0) {
                return Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.cancel_outlined),
                      onPressed: () {
                        // Uncheck boxes / reset taskDict
                        setState(() {
                          // Swap values back
                          for (var id in taskChanged.keys) {
                            taskDict[id] = (taskDict[id] == 1 ? 0 : 1);
                          }
                          taskChanged.clear();
                        });
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.check_box),
                      onPressed: () {
                        // Save tasks as completed update state and ba boom
                        updateTasks(taskChanged).then((value) => setState(() {
                              taskChanged.clear();
                            }));
                      },
                    ),
                  ],
                );
              } else {
                return BackButton();
              }
            },
          ),
          actions: <Widget>[
            IconButton(
              icon: const Icon(Icons.add),
              tooltip: 'Add Task',
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) {
                    return AddTaskForm();
                  },
                ).then((value) => {
                      // Updates view
                      setState(() {})
                    });
              },
            ),
          ],
        ),
        body: FutureBuilder<List<Task>>(
          future: taskWithCatAndThingNames(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              // Pull out completed and Subtaks
              List<Task> data = snapshot.data;
              if (hideCompleted && hideSubTask) {
                List<Task> newData = [];
                for (Task task in data) {
                  if (task.completed == 0 && task.isSubtask != 1) {
                    newData.add(task);
                  }
                }
                data = newData;
              }
              return Column(
                children: [
                  Container(
                    height: 25,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        FlatButton(
                          height: 25,
                          onPressed: () {
                            setState(() {
                              groupBy = 'date';
                            });
                          },
                          child: Text('Date'),
                        ),
                        FlatButton(
                          height: 25,
                          onPressed: () {
                            setState(() {
                              groupBy = 'thing';
                            });
                          },
                          child: Text('Thing'),
                        ),
                        FlatButton(
                          height: 25,
                          onPressed: () {
                            setState(() {
                              groupBy = 'category';
                            });
                          },
                          child: Text('Category'),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Container(
                      child: GroupedListView<dynamic, String>(
                        shrinkWrap: true,
                        elements: data,
                        groupBy: (element) => (groupBy == 'thing'
                            ? element.thingId.toString()
                            : (groupBy == 'category'
                                ? element.categoryId.toString()
                                : (element.date != 'null'
                                    ? element.date.toString().substring(0, 10)
                                    : null))),
                        groupComparator: (value1, value2) {
                          // Handle null
                          if (value1 == null && value2 == null) {
                            return 0;
                          }
                          if (value1 == null) {
                            return -1;
                          }
                          if (value2 == null) {
                            return 1;
                          }
                          if (groupBy == 'date') {
                            if (value1 == 'null' && value2 == 'null') {
                              return 0;
                            }
                            if (value1 == 'null') {
                              return -1;
                            }
                            if (value2 == 'null') {
                              return 1;
                            }
                            var dvalue1 = DateTime.parse(value1);
                            var dvalue2 = DateTime.parse(value2);
                            if (dvalue1.day == dvalue2.day &&
                                dvalue1.month == dvalue2.month &&
                                dvalue1.year == dvalue2.year) {
                              return 0;
                            }
                            return dvalue2.compareTo(dvalue1);
                          }
                          return value2.compareTo(value1);
                        },
                        itemComparator: (item1, item2) =>
                            item1.title.compareTo(item2.title),
                        order: GroupedListOrder.DESC,
                        useStickyGroupSeparators: true,
                        groupHeaderBuilder: (element) => Container(
                          color: Colors.lightBlue,
                          child: Text(
                            (groupBy == 'thing'
                                ? (element.data['thingTitle'] != null
                                    ? element.data['thingTitle']
                                    : "None")
                                : (groupBy == 'category'
                                    ? (element.data['catTitle'] != null
                                        ? element.data['catTitle']
                                        : "None")
                                    : (element.date != 'null'
                                        ?
                                        // 2020-10-15 12:00:00.000
                                        "(" +
                                            _printDuration(DateTime.parse(
                                                    element.date)
                                                .difference(DateTime.now())) +
                                            ") " +
                                            DateFormat('EEE, M/d').format(
                                                DateTime.parse(element.date))
                                        : "None"))),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ),
                        itemBuilder: (c, element) {
                          // Saves element and value to dict if not there
                          if (taskDict[element.id] == null) {
                            taskDict[element.id] = element.completed;
                          }

                          return Card(
                            elevation: 2.0,
                            margin: new EdgeInsets.symmetric(
                                horizontal: 10.0, vertical: 1.0),
                            child: Container(
                              child: ListTile(
                                contentPadding: EdgeInsets.symmetric(
                                    horizontal: 8.0, vertical: 2.0),
                                leading: Checkbox(
                                  value: (taskDict[element.id] == 1
                                      ? true
                                      : false),
                                  onChanged: (value) {
                                    setState(
                                      () {
                                        taskDict[element.id] = (value ? 1 : 0);
                                        if (taskChanged
                                            .containsKey(element.id)) {
                                          taskChanged.remove(element.id);
                                        } else {
                                          taskChanged[element.id] =
                                              (value ? 1 : 0);
                                        }
                                      },
                                    );
                                  },
                                ),
                                title: Text(element.title),
                                subtitle: Text(element.description),
                                trailing: Icon(Icons.arrow_forward),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => TaskDetailRoute(),
                                      settings:
                                          RouteSettings(arguments: element),
                                    ),
                                  );
                                },
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              );
            } else if (snapshot.hasError) {
              return new Text("${snapshot.error}");
            }
            // snapshot.data can be null or []
            return Container();
          },
        ));
  }
}

String _printDuration(Duration duration) {
  String twoDigits(int n) => n.toString().padLeft(1, "0");
  if (duration.inDays.abs() >= 1) {
    String ret = "${twoDigits(duration.inDays.abs())} days";
    if (duration.inDays < 0) {
      ret += " ago";
    }
    return ret;
  }
  String ret = "${twoDigits(duration.inHours)} hours";
  if (duration.inHours < 0) {
    ret += " ago";
  }
  return ret;
}
