import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // supabase flutter sdk
// import 'api_service.dart';
import 'post_quiz.dart';
import 'results.dart';


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
  final Map<int, int> _selectedAnswers = {}; // question_id -> answer_id
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
      // Insert each answer into the quiz_answers table
      for (final question in _questions) {
        final questionId = question['question_id'];
        final answerId = _selectedAnswers[questionId];

        if (answerId == null) continue;

        await supabase.from('quiz_answers').insert({
          'attempt_id': _attemptId,
          'question_id': questionId,
          'answer_id': answerId,
        });
      }

      // Example: calculate score in client (you could also use a Supabase RPC/Edge Function)
      int score = 0;
      for (final question in _questions) {
        final correctId = question['correct_answer_id']; // Make sure this is included
        final selectedId = _selectedAnswers[question['question_id']];
        if (correctId == selectedId) score++;
      }

      // Update the score in the quiz_attempts table
      await supabase.from('quiz_attempts').update({
        'score': score,
      }).eq('id', _attemptId!);

      // Navigate to PostQuiz
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => PostQuiz(
            score: score,
            onRedoQuiz: widget.onRedoQuiz,
            onViewAnswers: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => Results(), // pass attemptId if needed
              ),
            ),
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to submit quiz: $e')),
      );
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
                        groupValue: _selectedAnswers[question['question_id']],
                        onChanged: (val) {
                          setState(() {
                            _selectedAnswers[question['question_id']] = val as int;
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
