import 'dart:io';
import 'package:ai_one/widgets/banner_ad_widget.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import 'package:dio/dio.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'api.dart';

class ImageGeneratorScreen extends StatefulWidget {
  const ImageGeneratorScreen({super.key});

  @override
  State<ImageGeneratorScreen> createState() => _ImageGeneratorScreenState();
}

class _ImageGeneratorScreenState extends State<ImageGeneratorScreen> {
  final TextEditingController _promptController = TextEditingController();
  final ApiService _apiService = ApiService();
  String? _imageUrl;
  bool _isLoading = false;
  bool _isDownloading = false;
  double _progress = 0;
  final List<String> _history = [];
  final List<String> _suggestions = ["Futuristic cityscape", "Anime hero", "Space cat", "Cyberpunk robot"];
  final List<String> _styles = ["3D", "Anime", "Painting", "Cartoon"];
  String _selectedStyle = "3D";
  String _selectedResolution = "512x512";
  String? _userToken;

  final Color primaryColor = const Color(0xFF00FF66);
  final Color backgroundColor = const Color(0xFF121212);
  final Color cardColor = const Color(0xFF1E1E1E);

  int _coins = 10;

  @override
  void initState() {
    super.initState();
    requestStoragePermission();
    _loadCoins();
  }

  Future<void> requestStoragePermission() async {
    if (Platform.isAndroid) {
      await [
        Permission.storage,
        Permission.photos,
        Permission.manageExternalStorage,
      ].request();
    }
  }

  Future<void> _loadCoins() async {
    final prefs = await SharedPreferences.getInstance();
    final lastReset = prefs.getString("last_reset") ?? "";
    final today = DateTime.now().toIso8601String().substring(0, 10);

    if (lastReset != today) {
      await prefs.setInt("coins", 10);
      await prefs.setString("last_reset", today);
    }

    setState(() => _coins = prefs.getInt("coins") ?? 10);
  }

  Future<void> _deductCoin() async {
    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getInt("coins") ?? 10;
    final updated = current - 1;
    await prefs.setInt("coins", updated);
    setState(() => _coins = updated);
  }

  void _generateImage() async {
    final prompt = "${_promptController.text.trim()} with that $_selectedStyle style";
    if (prompt.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please enter a prompt")));
      return;
    }

    if (_coins <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Out of coins! Try again tomorrow.")));
      return;
    }

    setState(() {
      _isLoading = true;
      _imageUrl = null;
      _progress = 0;
    });

    final result = await _apiService.generateImage(prompt, _selectedResolution);

    setState(() {
      _isLoading = false;
      _promptController.clear();
      _imageUrl = result;
    });

    if (result != null) {
      _history.add(result);
      _deductCoin();
    }

    if (result == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Failed to generate image")));
    }
  }


  void _clearPrompt() => _promptController.clear();
  void _deleteImage() => setState(() => _imageUrl = null);

  Future<void> _downloadImage() async {
    if (_imageUrl == null) return;
    setState(() => _isDownloading = true);
    try {
      Directory? baseDir = await getExternalStorageDirectory();
      if (baseDir == null) throw Exception("Storage path not found");
      String newPath = baseDir.path.split("/Android")[0] + "/Pictures/AioneImages";
      baseDir = Directory(newPath);
      if (!await baseDir.exists()) await baseDir.create(recursive: true);
      final filePath = "${baseDir.path}/aione_image_${DateTime.now().millisecondsSinceEpoch}.jpg";
      await Dio().download(_imageUrl!, filePath,
          onReceiveProgress: (rec, total) => setState(() => _progress = rec / total));
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Image saved to $filePath")));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Download failed: $e")));
    }
    setState(() => _isDownloading = false);
  }

  Future<void> _shareImage() async {
    if (_imageUrl == null) return;
    try {
      final response = await Dio().get<List<int>>(_imageUrl!, options: Options(responseType: ResponseType.bytes));
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/shared_image.jpg');
      await file.writeAsBytes(response.data!);
      await Share.shareXFiles([XFile(file.path)], text: 'Check out this AI image from Aione!');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Sharing failed: $e")));
    }
  }

  InputDecoration _inputDecoration(String label) => InputDecoration(
    labelText: label,
    suffixIcon: IconButton(
      icon: Icon(Icons.clear, color: Colors.white70, size: 24.sp),
      onPressed: _clearPrompt,
    ),
    labelStyle: GoogleFonts.poppins(color: Colors.white70, fontSize: 16.sp),
    filled: true,
    fillColor: cardColor,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(20.r),
      borderSide: BorderSide.none,
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(20.r),
      borderSide: BorderSide(color: primaryColor, width: 2),
    ),
    contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          "AI Image Generator",
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w700,
            fontSize: 22.sp,
            color: primaryColor
          )
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.all(20.w),
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: const BannerAdWidget(),
            ),
              Padding(
                padding: EdgeInsets.only(bottom: 10.h),
                child: Text(
                  "Daily Coin : $_coins",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    color: primaryColor,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            Text(
              "Turn Words Into Art 🎨",
              style: GoogleFonts.poppins(
                fontSize: 26.sp,
                color: Colors.white,
                fontWeight: FontWeight.bold
              )
            ),
            SizedBox(height: 6.h),
            Text(
              "Describe your vision and let AI paint it.",
              style: GoogleFonts.roboto(
                fontSize: 16.sp,
                color: Colors.white70
              )
            ),
            SizedBox(height: 20.h),
            _buildSuggestions(),
            SizedBox(height: 10.h),
            _buildStyleAndResolutionSelector(),
            SizedBox(height: 10.h),
            _buildPromptInput(),
            SizedBox(height: 6.h),
            Text(
              "Tip: Use imaginative, detailed prompts for best results.",
              style: GoogleFonts.roboto(color: Colors.white60)
            ),
            SizedBox(height: 20.h),
            _buildGenerateButton(),
            SizedBox(height: 30.h),
            if (_isLoading) ...[
              Center(child: CircularProgressIndicator(color: primaryColor)),
              if (_progress > 0)
                Text(
                  "Loading ${(100 * _progress).toStringAsFixed(0)}%",
                  style: TextStyle(color: Colors.white)
                )
            ] else if (_imageUrl != null)
              Column(
                children: [
                  _buildImageCard(),
                  SizedBox(height: 20.h),
                  _buildActionButtons(),
                ],
              )
            else _buildEmptyState(),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: const BannerAdWidget(),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildSuggestions() => Wrap(
    spacing: 10.w,
    children: _suggestions.map((s) => ActionChip(
      backgroundColor: cardColor,
      label: Text(s, style: TextStyle(color: Colors.white, fontSize: 14.sp)),
      onPressed: () => _promptController.text = s,
    )).toList(),
  );

  Widget _buildStyleAndResolutionSelector() => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      DropdownButton<String>(
        value: _selectedStyle,
        dropdownColor: backgroundColor,
        items: _styles.map((e) => DropdownMenuItem(
          value: e,
          child: Text(e, style: TextStyle(color: Colors.white, fontSize: 14.sp))
        )).toList(),
        onChanged: (val) => setState(() => _selectedStyle = val!),
      ),
      DropdownButton<String>(
        value: _selectedResolution,
        dropdownColor: backgroundColor,
        items: ["256x256", "512x512", "1024x1024"].map((e) => DropdownMenuItem(
          value: e,
          child: Text(e, style: TextStyle(color: Colors.white, fontSize: 14.sp))
        )).toList(),
        onChanged: (val) => setState(() => _selectedResolution = val!),
      ),
    ],
  );

  Widget _buildPromptInput() => Container(
    decoration: BoxDecoration(
      color: cardColor,
      borderRadius: BorderRadius.circular(20.r),
      boxShadow: [
        BoxShadow(
          color: primaryColor.withOpacity(0.3),
          blurRadius: 16.r,
          spreadRadius: 2.r,
          offset: Offset(0, 6.h)
        )
      ],
    ),
    child: TextField(
      controller: _promptController,
      style: GoogleFonts.poppins(color: Colors.white, fontSize: 16.sp),
      decoration: _inputDecoration("Enter a creative prompt"),
    ),
  );

  Widget _buildGenerateButton() => GestureDetector(
    onTap: _generateImage,
    child: Container(
      padding: EdgeInsets.symmetric(vertical: 16.h),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [primaryColor, Colors.lightGreenAccent]),
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.6),
            blurRadius: 20.r,
            offset: Offset(0, 8.h)
          )
        ],
      ),
      child: Center(
        child: Text(
          'Generate Image',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            fontSize: 16.sp,
            color: Colors.black
          )
        ),
      ),
    ),
  );

  Widget _buildImageCard() => GestureDetector(
    onTap: () => showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("PHOTO"),
        content: Image.network(_imageUrl!),
      ),
    ),
    child: AnimatedContainer(
      duration: Duration(milliseconds: 500),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.5),
            blurRadius: 16.r,
            offset: Offset(0, 6.h)
          )
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20.r),
        child: Image.network(
          _imageUrl!,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, loadingProgress) =>
            loadingProgress == null ? child : Shimmer.fromColors(
              baseColor: Colors.grey[850]!,
              highlightColor: Colors.grey[700]!,
              child: Container(height: 300.h, color: Colors.grey[900]),
            ),
        ),
      ),
    ),
  );

  Widget _buildActionButtons() => Row(
    children: [
      _buildAction("Download", _downloadImage, _isDownloading),
      SizedBox(width: 10.w),
      _buildAction("Share", _shareImage, false),
      SizedBox(width: 10.w),
      _buildAction("Delete", _deleteImage, false),
    ],
  );

  Widget _buildAction(String label, VoidCallback onTap, bool isLoading) => Expanded(
    child: GestureDetector(
      onTap: isLoading ? null : onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 14.h),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isLoading ? [Colors.grey, Colors.grey] : [primaryColor, Colors.lightGreenAccent]
          ),
          borderRadius: BorderRadius.circular(20.r),
          boxShadow: [
            if (!isLoading)
              BoxShadow(
                color: primaryColor.withOpacity(0.5),
                blurRadius: 16.r,
                offset: Offset(0, 6.h)
              )
          ],
        ),
        child: Center(
          child: Text(
            isLoading ? "$label..." : label,
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
              fontSize: 16.sp,
              color: isLoading ? Colors.black54 : Colors.black
            ),
          ),
        ),
      ),
    ),
  );

  Widget _buildEmptyState() => Column(
    children: [
      Icon(Icons.image, color: Colors.white24, size: 100.sp),
      SizedBox(height: 8.h),
      Text(
        "No image generated yet",
        style: GoogleFonts.poppins(color: Colors.white38, fontSize: 16.sp)
      ),
    ],
  );
}