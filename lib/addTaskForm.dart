import 'package:Tasks/JMAC_form_builder_slider.dart' as JM;
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:intl/intl.dart';
import 'DBFunc.dart';

/// This is the stateful widget that the main application instantiates.
class AddTaskForm extends StatefulWidget {
  final Task initWithSubtask;
  AddTaskForm({Key key, this.initWithSubtask}) : super(key: key);

  @override
  _AddTaskFormState createState() => _AddTaskFormState();
}

/// This is the private State class that goes with MyStatefulWidget.
class _AddTaskFormState extends State<AddTaskForm> {
  final GlobalKey<FormBuilderState> _fbKey = GlobalKey<FormBuilderState>();
  int categorySelected;
  int thingSelected;
  bool onlyCheckForTaskOnce = false;
  bool subTask = false;
  bool showDate = false;
  bool showWorkload = false;
  @override
  Widget build(BuildContext context) {
    // If param given, need to init with values. Adding subtask
    // Only do it once or else may overwrite user values
    if (widget.initWithSubtask != null) {
      if (!onlyCheckForTaskOnce) {
        subTask = widget.initWithSubtask != null;
        categorySelected = widget.initWithSubtask.categoryId;
        onlyCheckForTaskOnce = true;
      }
    }

    return Material(
      child: FormBuilder(
        initialValue: (widget.initWithSubtask != null
            ? {
                'category_attached': widget.initWithSubtask.categoryId,
                'thing_attached': widget.initWithSubtask.thingId,
                'task_options': ['subtask_option'],
                'parentTaskId': widget.initWithSubtask.id,
              }
            : {}),
        key: _fbKey,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: SingleChildScrollView(
            child: Column(
              children: [
                FutureBuilder(
                  future: categorys(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      List<FormBuilderFieldOption> opts = [];
                      for (var cat in snapshot.data) {
                        opts.add(FormBuilderFieldOption(
                          value: cat.id,
                          child: Text(cat.title),
                        ));
                      }
                      return FormBuilderChoiceChip(
                        attribute: 'category_attached',
                        alignment: WrapAlignment.spaceEvenly,
                        decoration:
                            InputDecoration(labelText: "Select a Category..."),
                        onChanged: (value) {
                          setState(() {
                            categorySelected = value;
                            // Clears selected thing on category change
                            // Checks if init yet, if so resets
                            if (_fbKey.currentState.fields['thing_attached'] !=
                                null) {
                              _fbKey.currentState.fields['thing_attached']
                                  .currentState
                                  .reset();
                            }
                            thingSelected = null;
                          });
                        },
                        // Grab from 'categories' table TBA
                        options: opts,
                      );
                    }
                    return Container();
                  },
                ),
                // Get from 'things' display on selected category
                (categorySelected != null
                    ? FutureBuilder(
                        future: things(),
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            List<FormBuilderFieldOption> opts = [];
                            for (var thing in snapshot.data) {
                              if (thing.categoryId == categorySelected) {
                                opts.add(FormBuilderFieldOption(
                                  value: thing.id,
                                  child: Text(thing.title),
                                ));
                              }
                            }
                            return FormBuilderChoiceChip(
                              attribute: 'thing_attached',
                              alignment: WrapAlignment.spaceEvenly,
                              decoration: InputDecoration(
                                  labelText: "Select a 'thing'!"),
                              onChanged: (value) {
                                setState(() {
                                  thingSelected = value;
                                });
                              },
                              options: opts,
                            );
                          }
                          return Container();
                        },
                      )
                    : Container()),
                FormBuilderFilterChip(
                  attribute: 'task_options',
                  alignment: WrapAlignment.spaceEvenly,
                  decoration: InputDecoration(labelText: 'Options...'),
                  onChanged: (value) {
                    setState(() {
                      subTask = value.contains('subtask_option');
                      // Set parent to null when unselecting subtask
                      if (!subTask) {
                        _fbKey.currentState
                            .setAttributeValue('parentTaskId', null);
                      }
                      showDate = value.contains('date_option');
                      showWorkload = value.contains('workload_option');
                    });
                  },
                  options: [
                    FormBuilderFieldOption(
                        child: Text("Subtask"), value: "subtask_option"),
                    FormBuilderFieldOption(
                        child: Icon(Icons.calendar_today_rounded),
                        value: "date_option"),
                    FormBuilderFieldOption(
                        child: Icon(Icons.hourglass_top_rounded),
                        value: "workload_option"),
                  ],
                ),
                (subTask
                    ? FutureBuilder(
                        future: taskWithCatAndThingNames(),
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            List<FormBuilderFieldOption> opts = [];
                            for (var thing in snapshot.data) {
                              if (thing['isSubtask'] != 1) {
                                opts.add(FormBuilderFieldOption(
                                  value: thing['id'],
                                  child: (thing['thingTitle'] != null
                                      ? Text(
                                          '${thing['thingTitle']}: ${thing['title']}')
                                      : (thing['catTitle'] != null
                                          ? Text(
                                              '${thing['catTitle']}: ${thing['title']}')
                                          : Text('${thing['title']}'))),
                                ));
                              }
                            }
                            return FormBuilderChoiceChip(
                              attribute: 'parentTaskId',
                              alignment: WrapAlignment.spaceEvenly,
                              decoration:
                                  InputDecoration(labelText: "Subtask to..."),
                              onChanged: (value) {},
                              options: opts,
                            );
                          }
                          return Container();
                        },
                      )
                    : Container()),
                FormBuilderTextField(
                  maxLines: 1,
                  attribute: 'title_text',
                  autocorrect: true,
                  decoration: InputDecoration(
                      prefixIcon: Icon(Icons.clear_all_sharp),
                      labelText: "Title"),
                ),
                FormBuilderTextField(
                  attribute: 'desc_text',
                  autocorrect: true,
                  decoration: InputDecoration(labelText: "Description"),
                ),
                (showDate
                    ? FormBuilderDateTimePicker(
                        attribute: 'due_date',
                        decoration: InputDecoration(labelText: "Date"),
                      )
                    : Container()),
                (showDate
                    ? FormBuilderDropdown(
                        items: [
                          DropdownMenuItem(
                            child: Container(),
                            value: null,
                          ),
                          DropdownMenuItem(
                            child: Text('Smart Reminder'),
                            value: 'rm_smart',
                          ),
                          DropdownMenuItem(
                            child: Text('1 Hour Before'),
                            value: 'rm_1hr_b4',
                          ),
                          DropdownMenuItem(
                            child: Text('3 Hours Before'),
                            value: 'rm_3hr_b4',
                          ),
                          DropdownMenuItem(
                            child: Text('7 Hours Before'),
                            value: 'rm_7hr_b4',
                          ),
                          DropdownMenuItem(
                            child: Text('1 Day Before'),
                            value: 'rm_1dy',
                          ),
                          DropdownMenuItem(
                            child: Text('3 Days Before'),
                            value: 'rm_3dy',
                          )
                        ],
                        attribute: 'reminder_pref',
                        decoration: InputDecoration(labelText: "Remind:"),
                      )
                    : Container()),
                (showWorkload
                    ? JM.JMFormBuilderSlider(
                        attribute: 'workload_minutues',
                        displayValueAsTime: true,
                        decoration:
                            InputDecoration(labelText: "Estimated workload"),
                        displayValues: JM.DisplayValues.current,
                        min: 1,
                        max: 300,
                        initialValue: 35,
                      )
                    : Container()),
                FormBuilderSegmentedControl(
                    attribute: 'priority',
                    decoration: InputDecoration(labelText: "Priority"),
                    options: [
                      FormBuilderFieldOption(
                        value: 0,
                        child: Text('Low'),
                      ),
                      FormBuilderFieldOption(
                        value: 1,
                        child: Text('Medium'),
                      ),
                      FormBuilderFieldOption(
                        value: 2,
                        child: Text('High'),
                      ),
                    ]),
                FormBuilderCheckbox(
                  attribute: 'completed_check',
                  label: Text('Completed'),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    RaisedButton(
                      child: Text('Save'),
                      onPressed: () {
                        if (_fbKey.currentState.saveAndValidate()) {
                          var value = _fbKey.currentState.value;
                          insertTask(Task(
                            categoryId: value['category_attached'],
                            thingId: value['thing_attached'],
                            isSubtask: (subTask ? 1 : 0),
                            parentTaskId: value['parentTaskId'],
                            title: value['title_text'],
                            description: value['desc_text'],
                            date: value['due_date'].toString(),
                            remindPref: value['reminder_pref'],
                            workloadMinutues: value['workload_minutues'],
                            priority: value['priority'],
                            completed: (value['completed_check'] != null &&
                                    value['completed_check']
                                ? 1
                                : 0),
                          ));

                          Navigator.pop(context, _fbKey.currentState.value);
                        }
                      },
                    ),
                    RaisedButton(
                      child: Text('Cancel'),
                      onPressed: () {
                        _fbKey.currentState.reset();
                        Navigator.pop(context);
                      },
                    )
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Material(
//       child: Form(
//         key: _formKey,
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: <Widget>[
//             TextFormField(
//               decoration: const InputDecoration(
//                 hintText: 'Enter your email',
//               ),
//               validator: (value) {
//                 if (value.isEmpty) {
//                   return 'Please enter some text';
//                 }
//                 return null;
//               },
//             ),
//             Padding(
//               padding: const EdgeInsets.symmetric(vertical: 16.0),
//               child: ElevatedButton(
//                 onPressed: () {
//                   // Validate will return true if the form is valid, or false if
//                   // the form is invalid.
//                   if (_formKey.currentState.validate()) {
//                     // Process data.
//                     Navigator.pop(context, 5);
//                   }
//                 },
//                 child: Text('Submit'),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
