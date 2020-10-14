import 'package:Tasks/taskDetailView.dart';
import 'package:flutter/material.dart';
import 'package:grouped_list/grouped_list.dart';
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
      body: Stack(
        children: [
          FutureBuilder<List<Task>>(
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
                    Container(
                      child: GroupedListView<dynamic, String>(
                        shrinkWrap: true,
                        elements: data,
                        groupBy: (element) => (groupBy == 'thing'
                            ? element.thingId.toString()
                            : (groupBy == 'category'
                                ? element.categoryId.toString()
                                : element.date)),
                        groupComparator: (value1, value2) =>
                            value2.compareTo(value1),
                        itemComparator: (item1, item2) =>
                            item1.title.compareTo(item2.title),
                        order: GroupedListOrder.DESC,
                        useStickyGroupSeparators: true,
                        groupHeaderBuilder: (element) => Container(
                          color: Colors.amber,
                          child: Text(
                            (groupBy == 'thing'
                                ? (element.data['thingTitle'] != null
                                    ? element.data['thingTitle']
                                    : "None")
                                : (groupBy == 'category'
                                    ? (element.data['catTitle'] != null
                                        ? element.data['catTitle']
                                        : "None")
                                    : element.date)),
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
                    )
                  ],
                );
              } else if (snapshot.hasError) {
                return new Text("${snapshot.error}");
              }
              // snapshot.data can be null or []
              return Container();
            },
          )
        ],
      ),
    );
  }
}
