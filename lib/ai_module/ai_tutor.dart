import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';

import 'api.dart';

class AiTutorScreen extends StatefulWidget {
  @override
  _AiTutorScreenState createState() => _AiTutorScreenState();
}

class _AiTutorScreenState extends State<AiTutorScreen> {
  TextEditingController _questionController = TextEditingController();
  String _tutorResponse = '';
  String _learningMaterial = '';
  String _quiz = '';

  Future<String> askQuestion(String question) async {
    String response = await ApiService().getResponseFromApi(question);
    return response;
  }

  Future<String> getLearningMaterial(String topic) async {
    String material = await ApiService().getTutorMaterial(topic);
    return material;
  }

  Future<String> getQuiz(String topic) async {
    String quiz = await ApiService().getQuizForTopic(topic);
    return quiz;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),  // Dark background
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title Section
              Text(
                "Ask the Tutor",
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 60),
        
              // TextField for question input
              TextField(
                controller: _questionController,
                decoration: InputDecoration(
                  hintText: "Type your question here...",
                  hintStyle: TextStyle(color: Colors.white60),
                  filled: true,
                  fillColor: Colors.grey[800],
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white30),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                style: TextStyle(color: Colors.white),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
        
              // Ask the Tutor Button with custom style and colorful shadow
              _StyledButton(
                text: "Ask the Tutor",
                color: const Color(0xFF00E5FF),
                onPressed: () async {
                  String response=await askQuestion(_questionController.text);
                  setState(() {
                    _tutorResponse=response;
                  });
                  print("Hello:$_tutorResponse");
                },
              ),
              const SizedBox(height: 24),
        
        
              if (_tutorResponse.isNotEmpty) ...[
                Text(
                  "Response:",
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                _StyledCard(
                  content: _tutorResponse,
                ),
              ],
              const SizedBox(height: 24),
        
              // Get Learning Material Button with custom style and colorful shadow
              _StyledButton(
                text: "Get Learning Material (${_questionController.text})",
                color: const Color(0xFF66BB6A),
                onPressed: () async {
                  String response=await getLearningMaterial("${_questionController.text}");
                  setState(() {
                    _learningMaterial=response;
                  });
                },
              ),
              const SizedBox(height: 24),
        
              // Material Section
              if (_learningMaterial.isNotEmpty) ...[
                Text(
                  "Learning Material:",
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                _StyledCard(
                  content: _learningMaterial,
                ),
              ],
              const SizedBox(height: 24),
        
              // Get Quiz Button with custom style and colorful shadow
              _StyledButton(
                text: "Generate Quiz (${_questionController.text})",
                color: const Color(0xFFFF7043),
                onPressed: () async {
                  var response=await getQuiz("${_questionController.text}");
                  setState(() {
                    _quiz=response;
                  });
                },
              ),
              const SizedBox(height: 24),
        
              // Quiz Section
              if (_quiz.isNotEmpty) ...[
                Text(
                  "Quiz:",
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                _StyledCard(
                  content: _quiz,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// Styled button widget for consistent button design with colorful shadows
class _StyledButton extends StatelessWidget {
  final String text;
  final Color color;
  final VoidCallback onPressed;

  const _StyledButton({
    Key? key,
    required this.text,
    required this.color,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        // Simulate button press effect
      },
      onTapUp: (_) {
        // Simulate button release effect
      },
      onTapCancel: () {
        // Simulate button cancel effect
      },
      onTap: onPressed,
      child: TweenAnimationBuilder(
        duration: const Duration(milliseconds: 100),
        tween: Tween<double>(begin: 1.0, end: 0.95),
        builder: (context, scale, child) {
          return Transform.scale(scale: scale, child: child);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.4),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
              BoxShadow(
                color: color.withOpacity(0.2),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
              BoxShadow(
                color: color.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Center(
            child: Text(
              text,
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Styled card widget for content display with colorful shadow
class _StyledCard extends StatelessWidget {
  final String content;

  const _StyledCard({Key? key, required this.content}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[850],
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00E5FF).withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: const Color(0xFF66BB6A).withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: const Color(0xFFFF7043).withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Text(
        content,
        style: TextStyle(color: Colors.white70),
      ),
    );
  }
}
