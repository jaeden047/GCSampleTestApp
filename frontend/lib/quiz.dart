import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // supabase flutter sdk
import 'post_quiz.dart';
import 'results.dart';
// import 'dart:convert'; // Import jsonEncode

class QuizPage extends StatefulWidget {
  final int attemptId;
  final List<dynamic> questions;
  final String topicName;
  final VoidCallback onRedoQuiz;

  const QuizPage({
    super.key,
    required this.attemptId,
    required this.questions,
    required this.topicName,
    required this.onRedoQuiz,
  });

  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  List<dynamic> _questions = [];
  final Map<String, int> _selectedAnswers = {}; // question_id -> answer_id (as String keys)
  int? _attemptId;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _attemptId = widget.attemptId;
    _questions = widget.questions;
    _loading = false;
  }

  Future<void> _submitQuiz() async {
    final supabase = Supabase.instance.client;

    try {
      final score = await supabase.rpc('calculate_score', params: {
        'selected_answers': _selectedAnswers,
        'input_attempt_id': _attemptId,
      });

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => PostQuiz(
              score: score,
              onRedoQuiz: widget.onRedoQuiz,
              onViewAnswers: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => Results(),
                ),
              ),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to submit quiz: $e')),
        );
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: Text('Quiz - ${widget.topicName}')),
      body: ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: _questions.length,
        itemBuilder: (context, index) {
          final question = _questions[index];
          final answers = question['answers'] as List;

          return Card(
            margin: EdgeInsets.only(bottom: 16),
            child: Padding(
              padding: EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${index + 1}. ${question['question_text']}',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  ...answers.map((ans) => RadioListTile(
                        title: Text(ans['answer_text']),
                        value: ans['answer_id'],
                        groupValue: _selectedAnswers[question['question_id'].toString()],
                        onChanged: (val) {
                          setState(() {
                            _selectedAnswers[question['question_id'].toString()] = val as int;
                          });
                        },
                      )),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _submitQuiz,
        label: Text('Submit'),
        icon: Icon(Icons.check),
      ),
    );
  }
}
