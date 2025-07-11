import 'package:flutter/material.dart';

class ResultPage extends StatelessWidget {
  final int score;
  final int total;
  final List<Map<String, dynamic>> answers; // Each: {question, userAnswer, correctAnswer}
  final Map<String, dynamic>? progression; // Experience and level up data
  final int modeSpecificPoints; // Points gained for this game mode

  const ResultPage({
    Key? key,
    required this.score,
    required this.total,
    required this.answers,
    this.progression,
    required this.modeSpecificPoints,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Debug logging
    debugPrint('=== RESULT PAGE DEBUG ===');
    debugPrint('Score: $score, Total: $total');
    debugPrint('Mode Specific Points: $modeSpecificPoints');
    debugPrint('Progression data: $progression');
    debugPrint('Experience gained: ${progression?['experienceGained']}');
    debugPrint('Leveled up: ${progression?['leveledUp']}');
    
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
        backgroundColor: const Color(0xFFE9E0FF),
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFE9E0FF), Color(0xFF7C5CFC)],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
            // Result Header
            Container(
                  padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: resultColor.withOpacity(0.2)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                      Icon(resultIcon, size: 48, color: resultColor),
                      const SizedBox(height: 12),
                  Text(
                    resultMessage,
                    style: TextStyle(
                          fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: resultColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'You scored $score out of $total!',
                        style: const TextStyle(fontSize: 16, color: Colors.black87),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '$percentage%',
                    style: TextStyle(
                          fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: resultColor,
                    ),
                  ),
                ],
              ),
            ),
                const SizedBox(height: 16),
                   
            // Score Breakdown
            Row(
              children: [
                Expanded(
                  child: _ScoreCard(
                    title: 'Correct',
                    value: score,
                    color: Colors.green,
                    icon: Icons.check_circle,
                    background: Colors.white,
                  ),
                ),
                    const SizedBox(width: 8),
                Expanded(
                  child: _ScoreCard(
                    title: 'Incorrect',
                    value: total - score,
                    color: Colors.red,
                    icon: Icons.cancel,
                    background: Colors.white,
                  ),
                ),
              ],
            ),
                const SizedBox(height: 16),
                
                // Points Earned Section
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 8,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.stars,
                            color: Color(0xFFFFD700),
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'Points Earned',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF7C5CFC),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Base Points',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.black54,
                                  ),
                                ),
                                Text(
                                  '$score',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF7C5CFC),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Bonuses',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.black54,
                                  ),
                                ),
                                Text(
                                  '${modeSpecificPoints - score}',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFFFFD700),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Total',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.black54,
                                  ),
                                ),
                                Text(
                                  '$modeSpecificPoints',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF7C5CFC),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                
                // Answer Details - Compact Version
                if (answers.isNotEmpty) ...[
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 8,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.list_alt,
                              color: Color(0xFF7C5CFC),
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'Answer Details',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF7C5CFC),
                              ),
                            ),
                            const Spacer(),
                            Text(
                              '${answers.where((a) => a['userAnswer'] == a['correctAnswer']).length}/${answers.length}',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF7C5CFC),
                              ),
                            ),
                        ],
                      ),
                        const SizedBox(height: 12),
                        SizedBox(
                          height: 200, // Fixed height to prevent overflow
                          child: ListView.builder(
                            itemCount: answers.length,
                            itemBuilder: (context, index) {
                              final a = answers[index];
                              final isCorrect = a['userAnswer'] == a['correctAnswer'];
                              return Container(
                                margin: const EdgeInsets.only(bottom: 8),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: isCorrect ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: isCorrect ? Colors.green.withOpacity(0.3) : Colors.red.withOpacity(0.3),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      isCorrect ? Icons.check_circle : Icons.cancel,
                                      color: isCorrect ? Colors.green : Colors.red,
                                      size: 16,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Q${index + 1}',
                                            style: const TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black54,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            'Your answer: ${a['userAnswer'] ?? 'No answer'}',
                                            style: const TextStyle(fontSize: 12),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          if (!isCorrect) ...[
                                            const SizedBox(height: 2),
                                            Text(
                                              'Correct: ${a['correctAnswer']}',
                                              style: const TextStyle(
                                                fontSize: 12,
                                                color: Colors.deepPurple,
                                                fontWeight: FontWeight.w600,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                  ],
                    ),
                  );
                },
              ),
            ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
            
            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context, true); // Replay
                    },
                        icon: const Icon(Icons.replay, size: 18),
                        label: const Text('Play Again', style: TextStyle(fontSize: 14)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF7C5CFC),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: const BorderSide(color: Color(0xFF7C5CFC)),
                      ),
                      elevation: 2,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.of(context).pushNamedAndRemoveUntil('/main', (route) => false);
                    },
                        icon: const Icon(Icons.home, size: 18),
                        label: const Text('Home', style: TextStyle(fontSize: 14)),
                    style: OutlinedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF7C5CFC),
                      side: const BorderSide(color: Color(0xFF7C5CFC)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
                const SizedBox(height: 16), // Bottom padding for safe area
          ],
            ),
          ),
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
  final Color background;

  const _ScoreCard({
    required this.title,
    required this.value,
    required this.color,
    required this.icon,
    this.background = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, size: 24, color: color),
          const SizedBox(height: 6),
          Text(
            '$value',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
} 