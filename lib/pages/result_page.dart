import 'package:flutter/material.dart';

class ResultPage extends StatelessWidget {
  final int score;
  final int total;
  final List<Map<String, dynamic>> answers; // Each: {question, userAnswer, correctAnswer}

  const ResultPage({
    Key? key,
    required this.score,
    required this.total,
    required this.answers,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final percentage = total > 0 ? (score / total * 100).round() : 0;
    final isPerfect = score == total;
    final isGood = percentage >= 70;
    final isAverage = percentage >= 50;
    
    Color resultColor;
    String resultMessage;
    IconData resultIcon;
    
    if (isPerfect) {
      resultColor = Colors.green;
      resultMessage = 'Perfect!';
      resultIcon = Icons.emoji_events;
    } else if (isGood) {
      resultColor = Colors.blue;
      resultMessage = 'Great Job!';
      resultIcon = Icons.thumb_up;
    } else if (isAverage) {
      resultColor = Colors.orange;
      resultMessage = 'Good Effort!';
      resultIcon = Icons.sentiment_satisfied;
    } else {
      resultColor = Colors.red;
      resultMessage = 'Keep Practicing!';
      resultIcon = Icons.sentiment_dissatisfied;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quiz Results'),
        backgroundColor: const Color(0xFF7C5CFC),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Result Header
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: resultColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: resultColor.withOpacity(0.3)),
              ),
              child: Column(
                children: [
                  Icon(resultIcon, size: 64, color: resultColor),
                  const SizedBox(height: 16),
                  Text(
                    resultMessage,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: resultColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'You scored $score out of $total!',
                    style: const TextStyle(fontSize: 18, color: Colors.black87),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '$percentage%',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: resultColor,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            // Score Breakdown
            Row(
              children: [
                Expanded(
                  child: _ScoreCard(
                    title: 'Correct',
                    value: score,
                    color: Colors.green,
                    icon: Icons.check_circle,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _ScoreCard(
                    title: 'Incorrect',
                    value: total - score,
                    color: Colors.red,
                    icon: Icons.cancel,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            // Answer Details
            const Text(
              'Answer Details',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.builder(
                itemCount: answers.length,
                itemBuilder: (context, index) {
                  final a = answers[index];
                  final isCorrect = a['userAnswer'] == a['correctAnswer'];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    color: isCorrect ? Colors.green[50] : Colors.red[50],
                    child: ListTile(
                      leading: Icon(
                        isCorrect ? Icons.check_circle : Icons.cancel,
                        color: isCorrect ? Colors.green : Colors.red,
                      ),
                      title: Text(
                        a['question'] ?? 'Unknown Question',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Your answer: ${a['userAnswer'] ?? 'No answer'}'),
                          if (!isCorrect)
                            Text(
                              'Correct: ${a['correctAnswer']}',
                              style: const TextStyle(
                                color: Colors.deepPurple,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                        ],
                      ),
                      isThreeLine: !isCorrect,
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),
            
            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context, true); // Replay
                    },
                    icon: const Icon(Icons.replay),
                    label: const Text('Play Again'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF7C5CFC),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.popUntil(context, ModalRoute.withName('/home'));
                    },
                    icon: const Icon(Icons.home),
                    label: const Text('Home'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF7C5CFC),
                      side: const BorderSide(color: Color(0xFF7C5CFC)),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ScoreCard extends StatelessWidget {
  final String title;
  final int value;
  final Color color;
  final IconData icon;

  const _ScoreCard({
    required this.title,
    required this.value,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, size: 32, color: color),
          const SizedBox(height: 8),
          Text(
            '$value',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
} 