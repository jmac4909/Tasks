import 'package:flutter/material.dart';
import 'package:grouped_list/grouped_list.dart';

import 'DBFunc.dart';
import 'addTaskForm.dart';

class TaskDetailRoute extends StatefulWidget {
  @override
  _TaskDetailRouteState createState() => _TaskDetailRouteState();
}

class _TaskDetailRouteState extends State<TaskDetailRoute> {
  // Dict used to save values of checkboxes
  var taskDict = {};
  // Dict to sent to UPDATE of changed values
  var taskChanged = {};
  bool editMode = false;
  @override
  Widget build(BuildContext context) {
    final Task selectedTask = ModalRoute.of(context).settings.arguments;
    return Scaffold(
      appBar: AppBar(
        leadingWidth: (editMode ? 112.0 : 56.0),
        leading: Builder(
          builder: (BuildContext context) {
            if (editMode) {
              return Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.cancel_outlined),
                    onPressed: () {
                      // Uncheck boxes / reset taskDict
                      setState(() {
                        // Swap values back
                        // for (var id in taskChanged.keys) {
                        //   taskDict[id] = (taskDict[id] == 1 ? 0 : 1);
                        // }
                        // taskChanged.clear();
                      });
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.check_box),
                    onPressed: () {
                      // Save tasks as completed update state and ba boom
                      // updateTasks(taskChanged).then((value) => setState(() {
                      //       taskChanged.clear();
                      //     }));
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
            tooltip: 'Add',
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) {
                  return AddTaskForm(initWithSubtask: selectedTask);
                },
              ).then((value) => {
                    // Updates view
                    setState(() {})
                  });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Text('Subtasks:'),
          FutureBuilder<List<Task>>(
            future: taskForSubtasks(selectedTask.id),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return Container(
                  height: 200,
                  child: Card(
                    elevation: 12,
                    child: GroupedListView<dynamic, String>(
                      elements: snapshot.data,
                      groupBy: (element) => element.date,
                      groupComparator: (value1, value2) =>
                          value2.compareTo(value1),
                      itemComparator: (item1, item2) =>
                          item1.title.compareTo(item2.title),
                      order: GroupedListOrder.DESC,
                      useStickyGroupSeparators: true,
                      groupSeparatorBuilder: (String value) => Container(
                        color: Colors.amber,
                        child: Text(
                          // TODO this
                          // Either Need new future to grab categories, or reteive with SQL that gets the names as well
                          value,
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
                              dense: true,
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: 8.0, vertical: 2.0),
                              leading: Checkbox(
                                value:
                                    (taskDict[element.id] == 1 ? true : false),
                                onChanged: (value) {
                                  setState(
                                    () {
                                      taskDict[element.id] = (value ? 1 : 0);
                                      updateTasks(
                                          {element.id: (value ? 1 : 0)});
                                      if (taskChanged.containsKey(element.id)) {
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
                              onTap: () {},
                            ),
                          ),
                        );
                      },
                    ),
                  ),
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
