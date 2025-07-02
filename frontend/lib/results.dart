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
    List<String> attempts = [
    'Attempt 1',
    'Attempt 2',
    'Attempt 3',
    'Attempt 4',
  ];
    return Scaffold(
      body: ListView.builder(
          itemCount: 4,
          itemBuilder: (context, index){
            return Container( // Every itembuilder needs to return a widget - container is that widget
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
                attempts[index], // Organizes cards by list and text
                style: TextStyle(fontSize: 30),
              ),
            ),
          ),
        );}
      ),
    );
  }
}