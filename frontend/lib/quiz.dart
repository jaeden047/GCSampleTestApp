import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // supabase flutter sdk
import 'dart:async'; // Importing for Timer
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
  final Map<String, int> _selectedAnswers = {}; // question_id -> answer_id (as String keys)
  int? _attemptId;
  bool _loading = true;

  int _timeLeft = 1800; // set 30 mins (1800 seconds)
  late Timer _timer; // Timer instance

  @override
  void initState() {
    super.initState();
    _attemptId = widget.attemptId;
    _questions = widget.questions;
    _loading = false;

    // Start the timer
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_timeLeft > 0) {
        setState(() {
          _timeLeft--;
        });
      } else {
        _timer.cancel(); // Stop the timer when time is up
        // Handle time out logic here, such as submitting the quiz
        _submitQuiz();
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel(); // Make sure to cancel the timer when the page is disposed
    super.dispose();
  }

  Future<void> _submitQuiz() async {
    final supabase = Supabase.instance.client;
    int timePast = 1800 - _timeLeft; // calculate how many seconds it took to finish the quiz

    try {
      final score = await supabase.rpc('calculate_score', params: {
        'input_time': timePast,
        'selected_answers': _selectedAnswers,
        'input_attempt_id': _attemptId,
      });

      if (mounted) {
        Navigator.push(
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

    // Convert time left to minutes and seconds
    String minutes = (_timeLeft ~/ 60).toString().padLeft(2, '0');
    String seconds = (_timeLeft % 60).toString().padLeft(2, '0');
    String timerText = '$minutes:$seconds';

    return Scaffold(
      appBar: AppBar(
        title: Text('Quiz - ${widget.topicName}'),
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          // Timer at the top
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Time Left: $timerText',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: ListView.builder(
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
          ),
          // Submit Button
          GestureDetector(
            onTap: _submitQuiz,
            child: SvgPicture.asset(
              'assets/images/submit_button2.svg',  // Your SVG file path
              height: 70.0,  // Adjust the size of the SVG
            ),
          ),
          SizedBox(height: 20),
        ],
      ),
    );
  }
}