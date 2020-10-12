import 'package:flutter/material.dart';

Widget getTaskSlidder(int _elementsLen) {
  return Container(
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
        Center(
            child: Container(
          width: 50,
          height: 50,
          child: Center(
            child: Text(_elementsLen.toString()),
          ),
          decoration:
              BoxDecoration(shape: BoxShape.circle, color: Color(0xFFe0f2f1)),
        )),
        Spacer(
          flex: 3,
        ),
      ],
    ),
  );
}
