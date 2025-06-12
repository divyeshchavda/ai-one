import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;

class ApiService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String apiUrl =
      "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent";
  final String apiKey = "AIzaSyDQ7swVYSKLArMfh2wdwOkfvI1pIwSqCPg";

  // Method to send the message and get the API response
  Future<String> getResponseFromApi(String userMessage) async {
    try {
      // Make the API request with updated request body
      final response = await http.post(
        Uri.parse('$apiUrl?key=$apiKey'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "contents": [
            {
              "parts": [
                {"text": userMessage},
              ],
            },
          ],
        }),
      );

      if (response.statusCode == 200) {
        // Print the response body for debugging
        print('Response Body: ${response.body}');

        // Parse the response
        final responseData = json.decode(response.body);

        // Check if candidates exist and parse the text correctly
        if (responseData.containsKey('candidates') &&
            responseData['candidates'] != null &&
            responseData['candidates'].isNotEmpty) {
          // Access the first candidate and get the text from the parts array
          String generatedMessage =
              responseData['candidates'][0]['content']['parts'][0]['text'] ??
              'Sorry, I didn\'t understand that.';
          return generatedMessage;
        } else {
          return 'Error: No candidates in the response.';
        }
      } else {
        return 'Failed to get a response. Status Code: ${response.statusCode}';
      }
    } catch (error) {
      return 'Error occurred while fetching the response: $error';
    }
  }

  Future<String> getTutorMaterial(String topic) async {
    try {
      final response = await http.post(
        Uri.parse('$apiUrl?key=$apiKey'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "contents": [
            {
              "parts": [
                {"text": "Explain $topic in detail"},
              ],
            },
          ],
        }),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        String generatedMaterial =
            responseData['candidates'][0]['content']['parts'][0]['text'];
        return generatedMaterial;
      } else {
        return 'Error: Failed to fetch material. Status Code: ${response.statusCode}';
      }
    } catch (error) {
      return 'Error occurred while fetching the material: $error';
    }
  }

  Future<String> getQuizForTopic(String topic) async {
    try {
      final response = await http.post(
        Uri.parse('$apiUrl?key=$apiKey'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "contents": [
            {
              "parts": [
                {"text": "Generate a quiz for $topic"},
              ],
            },
          ],
        }),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        String quiz =
            responseData['candidates'][0]['content']['parts'][0]['text'];
        return quiz;
      } else {
        return 'Error: Failed to fetch quiz. Status Code: ${response.statusCode}';
      }
    } catch (error) {
      return 'Error occurred while fetching the quiz: $error';
    }
  }

  Future<void> saveChatHistory(String userEmail, List<String> messages) async {
    try {
      if (userEmail.isEmpty) {
        print('Error: User email is empty');
        return;
      }

      // Get the document reference
      DocumentReference userDocRef = _firestore
          .collection('details')
          .doc(userEmail);

      // Add the new messages to the existing history
      await userDocRef.update({
        'history': FieldValue.arrayUnion(
          messages,
        ), // Add new messages to the existing history
      });

      print('Chat history saved successfully.');
    } catch (e) {
      print('Error saving chat history: $e');
    }
  }

  Future<List<String>> getChatHistory(String userEmail) async {
    try {
      DocumentSnapshot doc =
          await _firestore.collection('details').doc(userEmail).get();

      if (doc.exists) {
        var data = doc.data() as Map<String, dynamic>;
        return List<String>.from(data['history'] ?? []);
      } else {
        await _firestore.collection('details').doc(userEmail).set({
          'history': [],
        });
        return []; // Return an empty list
      }
    } catch (e) {
      print('Error retrieving chat history: $e');
      return [];
    }
  }

  Future<String> getTravelPlan(
    String destination,
    String hisplace,
    String budget,
    String days,
    String date,
    String persons,
  ) async {
    try {
      final prompt = '''
Create a detailed $days-day travel plan for $persons person(s) starting on $date from $hisplace to $destination within a budget of ₹$budget.

Include:
- Transportation options (to and within the destination)
- Accommodation recommendations
- Food and dining options
- Daily itinerary with activities and sightseeing
- Tips to stay within budget
- Estimated daily expenses

Separate the plan by days (Day 1, Day 2, etc.). Use a clean and easy-to-read format.
''';

      final response = await http.post(
        Uri.parse('$apiUrl?key=$apiKey'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "contents": [
            {
              "parts": [
                {"text": prompt},
              ],
            },
          ],
        }),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        String plan =
            responseData['candidates'][0]['content']['parts'][0]['text'];
        return plan;
      } else {
        return 'Error: Failed to fetch travel plan. Status Code: ${response.statusCode}';
      }
    } catch (error) {
      return 'Error occurred while fetching travel plan: $error';
    }
  }

  Future<String?> generateImage(String prompt,String resolution) async {
    const String imageApiUrl = "https://api.a4f.co/v1/images/generations";
    const String bearerToken = "ddc-a4f-2d7d30810bcb470d806273756fad9c8d";
    print(prompt);
    try {
      final response = await http.post(
        Uri.parse(imageApiUrl),
        headers: {
          'Authorization': 'Bearer ddc-a4f-2d7d30810bcb470d806273756fad9c8d',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "model": "provider-2/FLUX.1-kontext-max",
          "prompt": prompt,
          "n": 1,
          "size": resolution,
        }),
      );
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData["data"] != null && responseData["data"].isNotEmpty) {
          return responseData["data"][0]["url"];
        } else {
          return 'No image URL found in response.';
        }
      } else {
        return 'Error: ${response.statusCode} - ${response.body}';
      }
    } catch (e) {
      return 'Exception occurred: $e';
    }
  }
  static Future<String> getSimplifiedDocument(
    String userQuery, {
    required String language,
  }) async {
    final String simplifyApiUrl = "https://api.a4f.co/v1/chat/completions";
    final String bearerToken = "ddc-a4f-2d7d30810bcb470d806273756fad9c8d";
    try {
      final response = await http.post(
        Uri.parse(simplifyApiUrl),
        headers: {
          'Authorization': 'Bearer $bearerToken',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "model": "provider-1/deepseek-r1",
          "messages": [
            {
              "role": "user",
              "content":
                  "Simplify the following document:\n\n$userQuery in $language",
            },
          ],
        }),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData["choices"] != null &&
            responseData["choices"].isNotEmpty &&
            responseData["choices"][0]["message"] != null) {
          final assistantMessage =
              responseData["choices"][0]["message"]["content"];
          return assistantMessage ?? "Sorry, no content returned.";
        } else {
          return "Error: Unexpected response format.";
        }
      } else {
        return "Failed to get a response. Status Code: ${response.statusCode}";
      }
    } catch (e) {
      return "Error occurred while fetching the simplified document: $e";
    }
  }

  static Future<String> getMedicalAdvice(String symptoms) async {
    final String apiUrl = "https://api.a4f.co/v1/chat/completions";
    final String bearerToken = "ddc-a4f-2d7d30810bcb470d806273756fad9c8d";

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Authorization': 'Bearer $bearerToken',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "model": "provider-3/deepseek-v3",
          "messages": [
            {
              "role": "user",
              "content": '''
I am experiencing the following symptoms: $symptoms.

Please list:
- Add a disclaimer that this is not professional medical advice
- Possible causes
- Severity levels (if applicable)
- Whether I should consult a doctor or manage with home remedies
- Any precautions or health advice
''',
            },
          ],
        }),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final reply = responseData["choices"][0]["message"]["content"];
        return reply ?? "Sorry, I couldn't analyze the symptoms.";
      } else {
        return "Error: ${response.statusCode} - ${response.body}";
      }
    } catch (e) {
      return "Error occurred while analyzing symptoms: $e";
    }
  }
}
