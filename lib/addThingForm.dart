import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:intl/intl.dart';
import 'DBFunc.dart';

/// This is the stateful widget that the main application instantiates.
class AddThingForm extends StatefulWidget {
  AddThingForm({Key key}) : super(key: key);

  @override
  _AddThingFormState createState() => _AddThingFormState();
}

/// This is the private State class that goes with MyStatefulWidget.
class _AddThingFormState extends State<AddThingForm> {
  final GlobalKey<FormBuilderState> _fbKey = GlobalKey<FormBuilderState>();
  int categorySelected;

  @override
  Widget build(BuildContext context) {
    return Material(
        child: FormBuilder(
            key: _fbKey,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  FormBuilderTextField(
                      attribute: 'thing_name',
                      decoration: InputDecoration(labelText: 'New Thing')),
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
                          onChanged: (value) {
                            setState(() {
                              categorySelected = value;
                            });
                          },
                          // Grab from 'categories' table TBA
                          options: opts,
                        );
                      }
                      return Container(
                        child: Material(
                          child: Text('No Categories...'),
                        ),
                      );
                    },
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      RaisedButton(
                        child: Text('Save'),
                        onPressed: () {
                          if (_fbKey.currentState.saveAndValidate()) {
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
            )));
  }
}
