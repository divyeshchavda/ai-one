import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:io';
import 'package:printing/printing.dart';
import 'package:permission_handler/permission_handler.dart';
import 'resume_templates.dart';

class ResumeTemplateSelectorScreen extends StatefulWidget {
  final Map<String, dynamic> data;
  const ResumeTemplateSelectorScreen({super.key, required this.data});

  @override
  State<ResumeTemplateSelectorScreen> createState() => _ResumeTemplateSelectorScreenState();
}

class _ResumeTemplateSelectorScreenState extends State<ResumeTemplateSelectorScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  String? selectedTemplate;
  bool isGenerating = false;

  final List<Map<String, dynamic>> resumeTemplates = [
    {
      "title": "Modern Resume",
      "description": "A stylish, clean layout with subtle colors and bold headings.",
      "type": "modern",
      "icon": Icons.auto_awesome,
      "gradient": [Color(0xFF2E3192), Color(0xFF1BFFFF)],
    },
    {
      "title": "Classic Resume",
      "description": "Traditional layout, great for conservative industries.",
      "type": "classic",
      "icon": Icons.work_outline,
      "gradient": [Color(0xFF834d9b), Color(0xFFd04ed6)],
    },
    {
      "title": "Creative Resume",
      "description": "Perfect for designers with a colorful and unique format.",
      "type": "creative",
      "icon": Icons.palette_outlined,
      "gradient": [Color(0xFF009245), Color(0xFFFCEE21)],
    },
    {
      "title": "Minimalist Resume",
      "description": "Sleek layout with a strong focus on content clarity.",
      "type": "minimalist",
      "icon": Icons.format_align_center,
      "gradient": [Color(0xFF662D8C), Color(0xFFED1E79)],
    },
    {
      "title": "Infographic Resume",
      "description": "Visual storytelling with timelines, icons, and charts.",
      "type": "infographic",
      "icon": Icons.insert_chart_outlined,
      "gradient": [Color(0xFFD4145A), Color(0xFFFBB03B)],
    },
    {
      "title": "Professional Resume",
      "description": "Balanced and formal layout for all job sectors.",
      "type": "professional",
      "icon": Icons.business_center,
      "gradient": [Color(0xFF662D8C), Color(0xFFED1E79)],
    },
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );
    _controller.forward();
    _checkAndRequestStoragePermission();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _checkAndRequestStoragePermission() async {
    if (Platform.isAndroid) {
      final status = await Permission.manageExternalStorage.status;
      if (status.isDenied) {
        await Permission.manageExternalStorage.request();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          "Choose Resume Template",
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 20.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 16.h),
                child: Text(
                  "Select a template that best represents your professional style",
                  style: GoogleFonts.poppins(
                    color: Colors.white70,
                    fontSize: 14.sp,
                  ),
                ),
              ),
              Expanded(
                child: GridView.builder(
                  itemCount: resumeTemplates.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16.w,
                    mainAxisSpacing: 16.h,
                    childAspectRatio: 0.75,
                  ),
                  itemBuilder: (context, index) {
                    final template = resumeTemplates[index];
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ResumePreviewScreen(
                              templateType: template['type']!,
                              data: widget.data,
                            ),
                          ),
                        );
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: template['gradient'] as List<Color>,
                          ),
                          borderRadius: BorderRadius.circular(20.r),
                          boxShadow: [
                            BoxShadow(
                              color: (template['gradient'][0] as Color).withOpacity(0.3),
                              blurRadius: 8.r,
                              offset: Offset(0, 4.h),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20.r),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(20.r),
                              ),
                              padding: EdgeInsets.all(16.w),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(
                                    template['icon'] as IconData,
                                    color: Colors.white,
                                    size: 32.sp,
                                  ),
                                  const Spacer(),
                                  Text(
                                    template['title']!,
                                    style: GoogleFonts.poppins(
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  SizedBox(height: 8.h),
                                  Text(
                                    template['description']!,
                                    style: GoogleFonts.poppins(
                                      fontSize: 12.sp,
                                      color: Colors.white.withOpacity(0.8),
                                    ),
                                    maxLines: 3,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
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
      ),
    );
  }
}

class ResumePreviewScreen extends StatefulWidget {
  final Map<String, dynamic> data;
  final String templateType;

  const ResumePreviewScreen({
    Key? key,
    required this.data,
    required this.templateType,
  }) : super(key: key);

  @override
  State<ResumePreviewScreen> createState() => _ResumePreviewScreenState();
}

class _ResumePreviewScreenState extends State<ResumePreviewScreen> with SingleTickerProviderStateMixin {
  bool isGenerating = false;
  late AnimationController _controller;
  late Animation<double> _animation;

  // A4 size in pixels (at 96 DPI)
  static const double a4Width = 794; // 8.27 inches * 96 DPI
  static const double a4Height = 1123; // 11.69 inches * 96 DPI

  // Colors for different template styles
  final List<Color> shadowColors = [
    const Color(0xFF2E3192), // Modern
    const Color(0xFF834d9b), // Classic
    const Color(0xFF009245), // Creative
    const Color(0xFFD4145A), // Infographic
    const Color(0xFF662D8C), // Professional
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
    _controller.forward();
    _checkAndRequestStoragePermission();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _checkAndRequestStoragePermission() async {
    if (Platform.isAndroid) {
      final status = await Permission.manageExternalStorage.status;
      if (status.isDenied) {
        if (mounted) {
          final result = await showModalBottomSheet<bool>(
            context: context,
            isDismissible: false,
            enableDrag: false,
            builder: (BuildContext context) {
              return Container(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.folder_open,
                      size: 50,
                      color: Colors.blue,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Storage Permission Required',
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'This app needs storage permission to save your resume. '
                      'Please grant permission to continue.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop(false);
                          },
                          child: Text(
                            'Deny',
                            style: GoogleFonts.poppins(
                              color: Colors.grey[600],
                            ),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pop(true);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 30,
                              vertical: 12,
                            ),
                          ),
                          child: Text(
                            'Grant Permission',
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          );

          if (result == true) {
            await Permission.manageExternalStorage.request();
          }
        }
      }
    }
  }

  Future<String> _getLocalPath() async {
    if (Platform.isAndroid) {
      final directory = await getExternalStorageDirectory();
      return directory?.path ?? (await getTemporaryDirectory()).path;
    } else {
      return (await getTemporaryDirectory()).path;
    }
  }

  Future<void> _generateAndSharePDF() async {
    setState(() {
      isGenerating = true;
    });

    try {
      // Request permissions if needed
      final hasPermission = await _requestPermissions();
      if (!hasPermission) {
        throw Exception('Storage permission is required to save the PDF. Please grant permission in app settings.');
      }

      // Create PDF document
      final pdf = pw.Document();

      // Add content to PDF based on template type
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return _buildPDFContent();
          },
        ),
      );

      // Get the appropriate directory path
      final directory = await _getLocalPath();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final file = File('$directory/resume_$timestamp.pdf');

      // Save the PDF
      await file.writeAsBytes(await pdf.save());

      // Share the PDF
      if (mounted) {
        await Share.shareXFiles(
          [XFile(file.path)],
          text: 'My Resume',
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error generating PDF: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
            action: SnackBarAction(
              label: 'OK',
              textColor: Colors.white,
              onPressed: () {},
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isGenerating = false;
        });
      }
    }
  }

  pw.Widget _buildPDFContent() {
    // Build PDF content based on template type
    switch (widget.templateType) {
      case 'modern':
        return _buildModernPDFContent();
      case 'classic':
        return _buildClassicPDFContent();
      case 'creative':
        return _buildCreativePDFContent();
      case 'minimalist':
        return _buildMinimalistPDFContent();
      case 'professional':
        return _buildProfessionalPDFContent();
      case 'infographic':
        return _buildInfographicPDFContent();
      default:
        return _buildModernPDFContent();
    }
  }

  pw.Widget _buildModernPDFContent() {
    return pw.Container(
      padding: const pw.EdgeInsets.all(40),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          // Header
          pw.Text(
            widget.data['fullName'] ?? '',
            style: pw.TextStyle(
              fontSize: 24,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 10),
          pw.Text(
            '${widget.data['email'] ?? ''} • ${widget.data['phone'] ?? ''}',
            style: const pw.TextStyle(fontSize: 12),
          ),
          pw.SizedBox(height: 20),

          // Objective
          if (widget.data['objective']?.isNotEmpty ?? false) ...[
            pw.Text(
              'Objective',
              style: pw.TextStyle(
                fontSize: 16,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.SizedBox(height: 5),
            pw.Text(
              widget.data['objective'] ?? '',
              style: const pw.TextStyle(fontSize: 12),
            ),
            pw.SizedBox(height: 20),
          ],

          // Education
          if (widget.data['education']?.isNotEmpty ?? false) ...[
            pw.Text(
              'Education',
              style: pw.TextStyle(
                fontSize: 16,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.SizedBox(height: 10),
            ...widget.data['education'].map<pw.Widget>((edu) => pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  edu['degree'] ?? '',
                  style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
                ),
                pw.Text(
                  '${edu['institution'] ?? ''} • ${edu['year'] ?? ''}',
                  style: const pw.TextStyle(fontSize: 10),
                ),
                pw.SizedBox(height: 5),
              ],
            )),
            pw.SizedBox(height: 20),
          ],

          // Experience
          if (widget.data['experience']?.isNotEmpty ?? false) ...[
            pw.Text(
              'Experience',
              style: pw.TextStyle(
                fontSize: 16,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.SizedBox(height: 10),
            ...widget.data['experience'].map<pw.Widget>((exp) => pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  exp['role'] ?? '',
                  style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
                ),
                pw.Text(
                  '${exp['company'] ?? ''} • ${exp['duration'] ?? ''}',
                  style: const pw.TextStyle(fontSize: 10),
                ),
                pw.Text(
                  exp['description'] ?? '',
                  style: const pw.TextStyle(fontSize: 10),
                ),
                pw.SizedBox(height: 5),
              ],
            )),
            pw.SizedBox(height: 20),
          ],

          // Skills
          if (widget.data['skills']?.isNotEmpty ?? false) ...[
            pw.Text(
              'Skills',
              style: pw.TextStyle(
                fontSize: 16,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.SizedBox(height: 10),
            pw.Wrap(
              spacing: 5,
              runSpacing: 5,
              children: widget.data['skills'].map<pw.Widget>((skill) => pw.Container(
                padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.blue),
                  borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
                ),
                child: pw.Text(
                  skill,
                  style: const pw.TextStyle(fontSize: 10),
                ),
              )).toList(),
            ),
          ],
        ],
      ),
    );
  }

  // Add similar methods for other template types (classic, creative, etc.)
  pw.Widget _buildClassicPDFContent() {
    // Similar implementation for classic template
    return pw.Container();
  }

  pw.Widget _buildCreativePDFContent() {
    // Similar implementation for creative template
    return pw.Container();
  }

  pw.Widget _buildMinimalistPDFContent() {
    // Similar implementation for minimalist template
    return pw.Container();
  }

  pw.Widget _buildProfessionalPDFContent() {
    // Similar implementation for professional template
    return pw.Container();
  }

  pw.Widget _buildInfographicPDFContent() {
    // Similar implementation for infographic template
    return pw.Container();
  }

  Future<void> _printResume() async {
    setState(() {
      isGenerating = true;
    });

    try {
      // Create PDF document
      final pdf = pw.Document();

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return _buildPDFContent();
          },
        ),
      );

      // Print the PDF
      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdf.save(),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error printing resume: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isGenerating = false;
        });
      }
    }
  }

  Future<bool> _requestPermissions() async {
    if (Platform.isAndroid) {
      final status = await Permission.manageExternalStorage.status;

      if (status.isDenied) {
        // Show permission request bottom sheet
        final result = await showModalBottomSheet<bool>(
          context: context,
          isDismissible: false,
          enableDrag: false,
          builder: (BuildContext context) {
            return Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.folder_open,
                    size: 50,
                    color: Colors.blue,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Storage Permission Required',
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'This app needs storage permission to save your resume. '
                    'Please grant permission to continue.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop(false);
                        },
                        child: Text(
                          'Deny',
                          style: GoogleFonts.poppins(
                            color: Colors.grey[600],
                          ),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop(true);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 30,
                            vertical: 12,
                          ),
                        ),
                        child: Text(
                          'Grant Permission',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );

        if (result == true) {
          final newStatus = await Permission.manageExternalStorage.request();
          return newStatus.isGranted;
        }
        return false;
      }

      if (status.isPermanentlyDenied) {
        // Show settings bottom sheet
        final result = await showModalBottomSheet<bool>(
          context: context,
          isDismissible: false,
          enableDrag: false,
          builder: (BuildContext context) {
            return Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.settings,
                    size: 50,
                    color: Colors.orange,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Permission Required',
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Storage permission is permanently denied. '
                    'Please enable it in app settings to continue.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop(false);
                        },
                        child: Text(
                          'Cancel',
                          style: GoogleFonts.poppins(
                            color: Colors.grey[600],
                          ),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop(true);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 30,
                            vertical: 12,
                          ),
                        ),
                        child: Text(
                          'Open Settings',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );

        if (result == true) {
          await openAppSettings();
          // Check permission again after returning from settings
          final newStatus = await Permission.manageExternalStorage.status;
          return newStatus.isGranted;
        }
        return false;
      }

      return status.isGranted;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          'Resume Preview',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 20.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.black,
        centerTitle: true,
        actions: [
          PopupMenuButton<String>(
            icon: Icon(Icons.download, color: Colors.white, size: 24.sp),
            onSelected: (value) {
              if (value == 'pdf') {
                _generateAndSharePDF();
              } else if (value == 'print') {
                _printResume();
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'pdf',
                child: Row(
                  children: [
                    Icon(Icons.picture_as_pdf, color: Colors.red, size: 20.sp),
                    SizedBox(width: 8.w),
                    Text('Download PDF', style: TextStyle(fontSize: 14.sp)),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'print',
                child: Row(
                  children: [
                    Icon(Icons.print, color: Colors.green, size: 20.sp),
                    SizedBox(width: 8.w),
                    Text('Print Resume', style: TextStyle(fontSize: 14.sp)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(20.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildResumeContent(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResumeContent() {
    switch (widget.templateType) {
      case 'modern':
        return _buildModernContent();
      case 'classic':
        return _buildClassicContent();
      case 'creative':
        return _buildCreativeContent();
      case 'minimalist':
        return _buildMinimalistContent();
      case 'professional':
        return _buildProfessionalContent();
      case 'infographic':
        return _buildInfographicContent();
      default:
        return _buildModernContent();
    }
  }

  Widget _buildModernContent() {
    return ResumeTemplates.buildModernContent(widget.data);
  }

  Widget _buildClassicContent() {
    return ResumeTemplates.buildClassicContent(widget.data);
  }

  Widget _buildCreativeContent() {
    return ResumeTemplates.buildCreativeContent(widget.data);
  }

  Widget _buildMinimalistContent() {
    return ResumeTemplates.buildMinimalistContent(widget.data);
  }

  Widget _buildProfessionalContent() {
    return ResumeTemplates.buildProfessionalContent(widget.data);
  }

  Widget _buildInfographicContent() {
    return ResumeTemplates.buildInfographicContent(widget.data);
  }
}
