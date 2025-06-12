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

    String generatedMessage = await _apiService.getResponseFromApi(userMessage);
    final responseTime = DateTime.now();

    setState(() {
      messages.add("Assistant: $generatedMessage");
      timestamps.add(_formatTime(responseTime));
      isTyping = false;
    });

    await _apiService.saveChatHistory(userEmail, messages);
    _scrollToBottom();
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

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
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
        iconTheme: IconThemeData(color: Colors.white),
        title: AnimatedSwitcher(
          duration: Duration(milliseconds: 500),
          child: Text("Chat Assistant", key: ValueKey(filter), style: GoogleFonts.poppins(color: Colors.white, fontSize: 20.sp, fontWeight: FontWeight.w600)),
        ),
        backgroundColor: Colors.white12,
        actions: [
          DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              dropdownColor: Colors.black87,
              value: filter,
              style: GoogleFonts.roboto(color: Colors.white),
              icon: Icon(Icons.filter_list, color: Colors.white),
              items: ["All", "You", "Assistant"].map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value == "You" ? "Only You" : value == "Assistant" ? "Only Assistant" : "All"),
                );
              }).toList(),
              onChanged: (val) => setState(() => filter = val!),
            ),
          ),
          IconButton(
            icon: Icon(Icons.delete_forever, color: Colors.white),
            onPressed: clearHistory,
          ),
        ],
      ),
      body: SafeArea(
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Stack(
            children: [
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
                                  ),
                                );
                              },
                              child: Container(
                                margin: const EdgeInsets.symmetric(vertical: 6),
                                padding: const EdgeInsets.all(14),
                                constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                                decoration: BoxDecoration(
                                  color: isUser ? Color(0xFF2E2E2E) : Color(0xFF1A1A1A),
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(16),
                                    topRight: Radius.circular(16),
                                    bottomLeft: Radius.circular(isUser ? 16 : 0),
                                    bottomRight: Radius.circular(isUser ? 0 : 16),
                                  ),
                                  boxShadow: [BoxShadow(color: Colors.black45, blurRadius: 6)],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(messages[index], style: GoogleFonts.roboto(fontSize: 16, color: Colors.white)),
                                    SizedBox(height: 6),
                                    Align(
                                      alignment: Alignment.bottomRight,
                                      child: Text(
                                        timestamps.length > index ? timestamps[index] : "",
                                        style: GoogleFonts.roboto(fontSize: 12, color: Colors.white38),
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
                child: FloatingActionButton(
                  mini: true,
                  backgroundColor: Colors.black54,
                  onPressed: _scrollToBottom,
                  child: Icon(Icons.arrow_downward, color: Colors.white),
                ),
              ),

              // Chat input area
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  padding: EdgeInsets.all(12),
                  color: const Color(0xFF121212),
                  child: Row(
                    children: [
                      Expanded(
                        child: AnimatedContainer(
                          duration: Duration(milliseconds: 300),
                          decoration: BoxDecoration(
                            color: const Color(0xFF333333),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: _controller.text.isNotEmpty
                                ? [BoxShadow(color: Color(0xFF00E5FF).withOpacity(0.5), blurRadius: 8)]
                                : [],
                          ),
                          child: TextField(
                            controller: _controller,
                            onChanged: (_) => setState(() {}),
                            onSubmitted: (_) => sendMessage(),
                            decoration: InputDecoration(
                              hintText: "Ask something...",
                              hintStyle: GoogleFonts.roboto(color: Colors.white54),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            ),
                            style: GoogleFonts.poppins(color: Colors.white),
                          ),
                        ),
                      ),
                      SizedBox(width: 8),
                      AnimatedScale(
                        scale: _controller.text.trim().isNotEmpty ? 1.0 : 0.0,
                        duration: Duration(milliseconds: 200),
                        child: GestureDetector(
                          onTap: sendMessage,
                          child: Container(
                            padding: EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                colors: [Color(0xFF00E5FF), Color(0xFF00C6FF)],
                              ),
                            ),
                            child: Icon(Icons.send, color: Colors.white),
                          ),
                        ),
                      ),
                      if (_controller.text.trim().isEmpty) ...[
                        GestureDetector(
                          onTap: _listen,
                          child: Container(
                            padding: EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                colors: _isListening?[Color(0xFFF2007D), Color(0xFFC24297)]:[Color(0xFF00E5FF), Color(0xFF00C6FF)],
                              ),
                            ),
                            child: Icon(_isListening?Icons.mic_off:Icons.mic, color: Colors.white),
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
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Text("Assistant is typing", style: GoogleFonts.roboto(color: Colors.white54)),
          AnimatedDots(),
        ],
      ),
    );
  }
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
    _controller = AnimationController(duration: Duration(milliseconds: 1000), vsync: this)..repeat();
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
            return Opacity(
              opacity: i <= count ? 1 : 0.2,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: Text(".", style: TextStyle(color: Colors.white54, fontSize: 18)),
              ),
            );
          }),
        );
      },
    );
  }
}
