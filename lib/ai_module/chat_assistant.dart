// Keep all your imports as is...

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'api.dart';

class ChatAssistantScreen extends StatefulWidget {
  @override
  _ChatAssistantScreenState createState() => _ChatAssistantScreenState();
}

class _ChatAssistantScreenState extends State<ChatAssistantScreen> {
  TextEditingController _controller = TextEditingController();
  List<String> messages = [];
  List<String> timestamps = [];
  final ApiService _apiService = ApiService();
  String userEmail = '';
  String filter = 'All';
  bool isTyping = false;
  ScrollController _scrollController = ScrollController();
  late stt.SpeechToText _speech;
  bool _isListening = false;

  @override
  void initState() {
    super.initState();
    getemail();
    loadChatHistory();
    _speech = stt.SpeechToText();
  }
  void _listen() async {
    if (!_isListening) {
      bool available = await _speech.initialize(
        onStatus: (status) {
          if (status == 'done' || status == 'notListening') {
            setState(() {
              _isListening = false;
            });
          }
        },
        onError: (error) {
          setState(() {
            _isListening = false;
          });
        },
      );
      if (available) {
        setState(() {
          _isListening = true;
        });
        _speech.listen(
          onResult: (result) {
            setState(() {
              _controller.text = result.recognizedWords;
              _controller.selection = TextSelection.fromPosition(
                TextPosition(offset: _controller.text.length),
              );
            });
          },
        );
      }
    } else {
      setState(() {
        _isListening = false;
      });
      _speech.stop();
    }
  }

  void sendMessage() async {
    String userMessage = _controller.text.trim();
    if (userMessage.isEmpty) return;

    final now = DateTime.now();
    setState(() {
      messages.add("You: $userMessage");
      timestamps.add(_formatTime(now));
      _controller.clear();
      isTyping = true;
    });

    // Smooth scroll animation when sending message
    _scrollToBottomWithAnimation();

    String generatedMessage = await _apiService.getResponseFromApi(userMessage);
    final responseTime = DateTime.now();

    setState(() {
      messages.add("Assistant: $generatedMessage");
      timestamps.add(_formatTime(responseTime));
      isTyping = false;
    });

    // Removed the scroll animation when receiving response
    // _scrollToBottomWithAnimation();

    await _apiService.saveChatHistory(userEmail, messages);
  }

  void _scrollToBottomWithAnimation() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 500),
          curve: Curves.easeOutQuart,
        );
      }
    });
  }

  // Replace the old _scrollToBottom method with the new one
  void _scrollToBottom() {
    _scrollToBottomWithAnimation();
  }

  String _formatTime(DateTime time) {
    return "${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}";
  }

  void loadChatHistory() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    userEmail = prefs.getString('email') ?? '';
    if (userEmail.isNotEmpty) {
      _apiService.getChatHistory(userEmail).then((chatHistory) {
        setState(() {
          messages = chatHistory;
          timestamps = List.generate(chatHistory.length, (_) => "");
        });
        _scrollToBottom();
      });
    }
  }

  Future<void> getemail() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    userEmail = prefs.getString('email') ?? '';
  }

  void clearHistory() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1E1E1E),
          title: Text("Clear Chat History", style: GoogleFonts.poppins(color: Colors.white)),
          content: Text("Are you sure?", style: GoogleFonts.roboto(color: Colors.white70)),
          actions: [
            TextButton(
              child: Text("Cancel", style: GoogleFonts.roboto(color: Colors.blueAccent)),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text("Clear", style: GoogleFonts.roboto(color: Colors.redAccent)),
              onPressed: () async {
                Navigator.of(context).pop();
                if (userEmail.isNotEmpty) {
                  await FirebaseFirestore.instance
                      .collection('details')
                      .doc(userEmail)
                      .update({'history': FieldValue.delete()});
                  setState(() {
                    messages = [];
                    timestamps = [];
                  });
                }
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildMessageText(String text, bool isUser) {
    if (isUser) {
      return Text(
        text,
        style: GoogleFonts.roboto(
          fontSize: 16,
          color: Colors.white,
          height: 1.4,
          letterSpacing: 0.2,
        ),
      );
    }

    // Split text by ** markers
    List<String> parts = text.split('**');
    List<TextSpan> textSpans = [];

    for (int i = 0; i < parts.length; i++) {
      if (i % 2 == 0) {
        // Regular text
        textSpans.add(TextSpan(
          text: parts[i],
          style: GoogleFonts.roboto(
            fontSize: 16,
            color: Colors.white,
            height: 1.4,
            letterSpacing: 0.2,
          ),
        ));
      } else {
        // Bold text
        textSpans.add(TextSpan(
          text: parts[i],
          style: GoogleFonts.roboto(
            fontSize: 16,
            color: Colors.white,
            height: 1.4,
            letterSpacing: 0.2,
            fontWeight: FontWeight.bold,
          ),
        ));
      }
    }

    return RichText(
      text: TextSpan(children: textSpans),
    );
  }

  @override
  Widget build(BuildContext context) {
    List<int> visibleIndexes = List.generate(messages.length, (i) {
      if (filter == "All") return i;
      if (filter == "You" && messages[i].startsWith("You:")) return i;
      if (filter == "Assistant" && messages[i].startsWith("Assistant:")) return i;
      return -1;
    }).where((i) => i != -1).toList();

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
        title: AnimatedSwitcher(
          duration: Duration(milliseconds: 500),
          child: Text(
            "Chat Assistant",
            key: ValueKey(filter),
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 22.sp,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
              shadows: [
                Shadow(
                  color: Color(0xFF00E5FF).withOpacity(0.3),
                  blurRadius: 10,
                  offset: Offset(0, 2),
                ),
              ],
            ),
          ),
        ),
        backgroundColor: Colors.transparent,
        actions: [
          Container(
            margin: EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.white.withOpacity(0.1),
                width: 1,
              ),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                dropdownColor: Color(0xFF1E1E1E),
                value: filter,
                style: GoogleFonts.roboto(color: Colors.white),
                icon: Icon(Icons.filter_list, color: Colors.white),
                padding: EdgeInsets.symmetric(horizontal: 12),
                items: ["All", "You", "Assistant"].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(
                      value == "You" ? "Only You" : value == "Assistant" ? "Only Assistant" : "All",
                      style: GoogleFonts.roboto(fontSize: 14.sp),
                    ),
                  );
                }).toList(),
                onChanged: (val) => setState(() => filter = val!),
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.delete_forever, color: Colors.white70),
            onPressed: clearHistory,
          ),
        ],
      ),
      body: SafeArea(
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Stack(
            children: [
              // Animated background
              AnimatedContainer(
                duration: Duration(milliseconds: 500),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0xFF1A1A1A).withOpacity(0.5),
                      Color(0xFF121212),
                    ],
                  ),
                ),
                child: CustomPaint(
                  painter: GridPainter(
                    color: Colors.white.withOpacity(0.03),
                    lineWidth: 1,
                    spacing: 30,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
                child: Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        controller: _scrollController,
                        itemCount: visibleIndexes.length + (isTyping ? 1 : 0),
                        itemBuilder: (context, i) {
                          if (isTyping && i == visibleIndexes.length) {
                            return _buildTypingIndicator();
                          }

                          int index = visibleIndexes[i];
                          bool isUser = messages[index].startsWith("You:");
                          String messageText = messages[index].substring(isUser ? 4 : 10); // Remove "You: " or "Assistant: "

                          return AnimatedContainer(
                            duration: Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                            alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                            child: GestureDetector(
                              onLongPress: () {
                                Clipboard.setData(ClipboardData(text: messages[index]));
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text("Copied to clipboard", style: GoogleFonts.roboto()),
                                    backgroundColor: Colors.grey[800],
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                    margin: EdgeInsets.all(8),
                                  ),
                                );
                              },
                              child: Container(
                                margin: const EdgeInsets.symmetric(vertical: 6),
                                padding: const EdgeInsets.all(16),
                                constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                                decoration: BoxDecoration(
                                  color: isUser ? Color(0xFF2E2E2E) : Color(0xFF1A1A1A),
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(24),
                                    topRight: Radius.circular(24),
                                    bottomLeft: Radius.circular(isUser ? 24 : 4),
                                    bottomRight: Radius.circular(isUser ? 4 : 24),
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: (isUser ? Color(0xFF00E5FF) : Color(0xFFF2007D)).withOpacity(0.15),
                                      blurRadius: 12,
                                      offset: Offset(0, 4),
                                    ),
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 4,
                                      offset: Offset(0, 2),
                                    ),
                                  ],
                                  border: Border.all(
                                    color: (isUser ? Color(0xFF00E5FF) : Color(0xFFF2007D)).withOpacity(0.1),
                                    width: 1,
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildMessageText(
                                      isUser ? "You: $messageText" : "Assistant: $messageText",
                                      isUser,
                                    ),
                                    SizedBox(height: 8),
                                    Align(
                                      alignment: Alignment.bottomRight,
                                      child: Text(
                                        timestamps.length > index ? timestamps[index] : "",
                                        style: GoogleFonts.roboto(
                                          fontSize: 12,
                                          color: Colors.white38,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),

              // Scroll-to-bottom button
              Positioned(
                bottom: 90,
                right: 16,
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [Color(0xFF00E5FF), Color(0xFF00C6FF)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Color(0xFF00E5FF).withOpacity(0.3),
                        blurRadius: 8,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: _scrollToBottom,
                      customBorder: CircleBorder(),
                      child: Padding(
                        padding: EdgeInsets.all(12),
                        child: Icon(
                          Icons.arrow_downward,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // Chat input area
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Color(0xFF1A1A1A),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 10,
                        offset: Offset(0, -5),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: AnimatedContainer(
                          duration: Duration(milliseconds: 300),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2E2E2E),
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: _controller.text.isNotEmpty
                                ? [
                              BoxShadow(
                                color: Color(0xFF00E5FF).withOpacity(0.3),
                                blurRadius: 12,
                                spreadRadius: 1,
                              ),
                            ]
                                : [],
                            border: Border.all(
                              color: _controller.text.isNotEmpty
                                  ? Color(0xFF00E5FF).withOpacity(0.3)
                                  : Colors.transparent,
                              width: 1,
                            ),
                          ),
                          child: TextField(
                            controller: _controller,
                            onChanged: (_) => setState(() {}),
                            onSubmitted: (_) => sendMessage(),
                            decoration: InputDecoration(
                              hintText: "Ask something...",
                              hintStyle: GoogleFonts.roboto(
                                color: Colors.white54,
                                fontSize: 15.sp,
                              ),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                            ),
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 15.sp,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 12),
                      AnimatedScale(
                        scale: _controller.text.trim().isNotEmpty ? 1.0 : 0.0,
                        duration: Duration(milliseconds: 200),
                        child: GestureDetector(
                          onTap: sendMessage,
                          child: Container(
                            padding: EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                colors: [Color(0xFF00E5FF), Color(0xFF00C6FF)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Color(0xFF00E5FF).withOpacity(0.3),
                                  blurRadius: 8,
                                  spreadRadius: 1,
                                ),
                              ],
                            ),
                            child: Icon(Icons.send, color: Colors.white, size: 20),
                          ),
                        ),
                      ),
                      if (_controller.text.trim().isEmpty) ...[
                        SizedBox(width: 12),
                        GestureDetector(
                          onTap: _listen,
                          child: Container(
                            padding: EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                colors: _isListening
                                    ? [Color(0xFFF2007D), Color(0xFFC24297)]
                                    : [Color(0xFF00E5FF), Color(0xFF00C6FF)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: (_isListening ? Color(0xFFF2007D) : Color(0xFF00E5FF)).withOpacity(0.3),
                                  blurRadius: 8,
                                  spreadRadius: 1,
                                ),
                              ],
                            ),
                            child: Icon(
                              _isListening ? Icons.mic_off : Icons.mic,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ]
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Color(0xFFF2007D).withOpacity(0.1),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: Color(0xFFF2007D).withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "Assistant is typing",
            style: GoogleFonts.roboto(
              color: Colors.white70,
              fontSize: 14.sp,
              letterSpacing: 0.5,
            ),
          ),
          SizedBox(width: 8),
          AnimatedDots(),
        ],
      ),
    );
  }
}

class GridPainter extends CustomPainter {
  final Color color;
  final double lineWidth;
  final double spacing;

  GridPainter({
    required this.color,
    required this.lineWidth,
    required this.spacing,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = lineWidth
      ..style = PaintingStyle.stroke;

    for (var i = 0.0; i < size.width; i += spacing) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), paint);
    }

    for (var i = 0.0; i < size.height; i += spacing) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class AnimatedDots extends StatefulWidget {
  @override
  _AnimatedDotsState createState() => _AnimatedDotsState();
}

class _AnimatedDotsState extends State<AnimatedDots> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  int dotCount = 3;

  @override
  void initState() {
    _controller = AnimationController(
      duration: Duration(milliseconds: 1000),
      vsync: this,
    )..repeat();
    _animation = Tween<double>(begin: 0, end: dotCount.toDouble()).animate(_controller);
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (_, __) {
        int count = (_animation.value).floor();
        return Row(
          children: List.generate(dotCount, (i) {
            return AnimatedOpacity(
              opacity: i <= count ? 1 : 0.2,
              duration: Duration(milliseconds: 200),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: Text(
                  ".",
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }
}
