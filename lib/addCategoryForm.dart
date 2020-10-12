import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:intl/intl.dart';
import 'DBFunc.dart';

/// This is the stateful widget that the main application instantiates.
class AddCategoryForm extends StatefulWidget {
  AddCategoryForm({Key key}) : super(key: key);

  @override
  _AddCategoryFormState createState() => _AddCategoryFormState();
}

/// This is the private State class that goes with MyStatefulWidget.
class _AddCategoryFormState extends State<AddCategoryForm> {
  final GlobalKey<FormBuilderState> _fbKey = GlobalKey<FormBuilderState>();
  String categorySelected;
  String thingSelected;

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
                    attribute: 'category_name',
                    decoration: InputDecoration(labelText: 'New Category'),
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
