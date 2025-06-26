import 'package:flutter/material.dart';

// Results page
class Results extends StatefulWidget { // Results is a type of widget (Class) 
// StatefulWidget => Changeable Widget during Runtime. StatelessWidget => Static Widget. extends Stateful => copy fields to Results
  const Results({super.key}); // Results() is constructor for class
  // Constructor; applies super.key to a class key field. Key field
  @override
  State<Results> createState() => _ResultsState(); //
}

class _ResultsState extends State<Results> { // 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          width: double.infinity,
          height: 300,
          child: Card(
            shadowColor: Colors.black,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(20)),
            ),
            margin: EdgeInsets.all(32),
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'Attempt ...',
                style: TextStyle(fontSize: 30),
              ),
            ),
          ),
        ),
      ),
    );
  }
}