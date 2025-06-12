import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ResumeTemplates {
  // A4 size in pixels (at 96 DPI)
  static const double a4Width = 794; // 8.27 inches * 96 DPI
  static const double a4Height = 1123; // 11.69 inches * 96 DPI

  // Canva-inspired color schemes with gradients
  static const List<Color> canvaColors = [
    Color(0xFF2D5DA1), // Professional Blue
    Color(0xFF4A90E2), // Modern Blue
    Color(0xFF50E3C2), // Fresh Mint
    Color(0xFFF5A623), // Warm Orange
    Color(0xFFD0021B), // Bold Red
    Color(0xFF7ED321), // Success Green
  ];

  static const List<LinearGradient> canvaGradients = [
    LinearGradient(
      colors: [Color(0xFF2D5DA1), Color(0xFF5B86E5)],
    ), // Blue Gradient
    LinearGradient(
      colors: [Color(0xFF4A90E2), Color(0xFF8DCBFF)],
    ), // Light Blue Gradient
    LinearGradient(
      colors: [Color(0xFF50E3C2), Color(0xFF88F4D4)],
    ), // Mint Gradient
    LinearGradient(
      colors: [Color(0xFFF5A623), Color(0xFFFFC107)],
    ), // Orange Gradient
    LinearGradient(
      colors: [Color(0xFFD0021B), Color(0xFFFF4D4F)],
    ), // Red Gradient
    LinearGradient(
      colors: [Color(0xFF7ED321), Color(0xFF52C41A)],
    ), // Green Gradient
  ];

  // Animation controller for shared use
  static Widget _withAnimation(Widget child, Animation<double> animation) {
    return FadeTransition(
      opacity: Tween<double>(begin: 0.0, end: 1.0).animate(animation),
      child: ScaleTransition(
        scale: Tween<double>(begin: 0.95, end: 1.0).animate(animation),
        child: child,
      ),
    );
  }

  static Widget buildModernContent(
    Map<String, dynamic> data,
  ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
              width: a4Width,
              padding: EdgeInsets.symmetric(horizontal: 40.w, vertical: 30.h),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12.r),
                boxShadow: [
                  BoxShadow(
                    color: canvaColors[1].withOpacity(0.3),
                    blurRadius: 15.r,
                    offset: Offset(0, 5.h),
                  ),
                ],
              ),
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: EdgeInsets.only(bottom: 20.h),
                      decoration: BoxDecoration(
                        gradient: canvaGradients[1],
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(8.r),
                          bottomRight: Radius.circular(8.r),
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Padding(
                              padding: EdgeInsets.all(20.w),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    data['fullName'] ?? 'Unknown Name',
                                    style: GoogleFonts.montserrat(
                                      fontSize: 36.sp,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.white,
                                    ),
                                  ),
                                  SizedBox(height: 8.h),
                                  Text(
                                    data['title'] ?? 'Professional',
                                    style: GoogleFonts.poppins(
                                      fontSize: 18.sp,
                                      color: Colors.white70,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Container(
                            width: 100.w,
                            height: 100.h,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: canvaColors[1].withOpacity(0.4),
                                  blurRadius: 10.r,
                                ),
                              ],
                            ),
                            child: Center(
                              child: Text(
                                (data['fullName'] ?? 'A')[0].toUpperCase(),
                                style: GoogleFonts.montserrat(
                                  fontSize: 40.sp,
                                  fontWeight: FontWeight.bold,
                                  color: canvaColors[1],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 30.h),
                    // Contact Information
                    Wrap(
                      spacing: 15,
                      runSpacing: 10,
                      children: [
                        if (data['email']?.isNotEmpty ?? false)
                          _buildContactItem(
                            Icons.email_outlined,
                            data['email'],
                            canvaColors[1],
                          ),
                        if (data['phone']?.isNotEmpty ?? false)
                          _buildContactItem(
                            Icons.phone_outlined,
                            data['phone'],
                            canvaColors[1],
                          ),
                        if (data['address']?.isNotEmpty ?? false)
                          _buildContactItem(
                            Icons.location_on_outlined,
                            data['address'],
                            canvaColors[1],
                          ),
                      ],
                    ),
                    const SizedBox(height: 30),
                    // Two Column Layout
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 2,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (data['objective']?.isNotEmpty ?? false) ...[
                                _buildCanvaSection(
                                  'Professional Summary',
                                  data['objective'],
                                  canvaColors[1],
                                ),
                                const SizedBox(height: 25),
                              ],
                              if (data['experience']?.isNotEmpty ?? false) ...[
                                _buildCanvaSection(
                                  'Work Experience',
                                  null,
                                  canvaColors[1],
                                  data['experience'],
                                ),
                                const SizedBox(height: 25),
                              ],
                              if (data['education']?.isNotEmpty ?? false)
                                _buildCanvaSection(
                                  'Education',
                                  null,
                                  canvaColors[1],
                                  data['education'],
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 30),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (data['skills']?.isNotEmpty ?? false) ...[
                                _buildCanvaSkillsSection(
                                  'Skills',
                                  data['skills'],
                                  canvaColors[1],
                                ),
                                const SizedBox(height: 25),
                              ],
                              if (data['certifications']?.isNotEmpty ??
                                  false) ...[
                                _buildCanvaSkillsSection(
                                  'Certifications',
                                  data['certifications'],
                                  canvaColors[1],
                                ),
                                const SizedBox(height: 25),
                              ],
                              if (data['languages']?.isNotEmpty ?? false)
                                _buildCanvaSkillsSection(
                                  'Languages',
                                  data['languages'],
                                  canvaColors[1],
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
        );
      },
    );
  }

  static Widget buildClassicContent(
    Map<String, dynamic> data,
  ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return  Container(
          width: a4Width,
          padding: const EdgeInsets.all(40),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: canvaColors[0].withOpacity(0.3),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Header
                Text(
                  data['fullName'] ?? 'Unknown Name',
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  data['title'] ?? 'Professional',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    color: canvaColors[0],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  height: 3,
                  width: 150,
                  decoration: BoxDecoration(
                    gradient: canvaGradients[0],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 30),
                // Contact Information
                Wrap(
                  spacing: 20,
                  runSpacing: 10,
                  alignment: WrapAlignment.center,
                  children: [
                    if (data['email']?.isNotEmpty ?? false)
                      _buildContactItem(
                        Icons.email_outlined,
                        data['email'],
                        canvaColors[0],
                      ),
                    if (data['phone']?.isNotEmpty ?? false)
                      _buildContactItem(
                        Icons.phone_outlined,
                        data['phone'],
                        canvaColors[0],
                      ),
                    if (data['address']?.isNotEmpty ?? false)
                      _buildContactItem(
                        Icons.location_on_outlined,
                        data['address'],
                        canvaColors[0],
                      ),
                  ],
                ),
                const SizedBox(height: 30),
                // Content
                if (data['objective']?.isNotEmpty ?? false) ...[
                  _buildCanvaSection(
                    'Professional Summary',
                    data['objective'],
                    canvaColors[0],
                  ),
                  const SizedBox(height: 25),
                ],
                if (data['experience']?.isNotEmpty ?? false) ...[
                  _buildCanvaSection(
                    'Work Experience',
                    null,
                    canvaColors[0],
                    data['experience'],
                  ),
                  const SizedBox(height: 25),
                ],
                if (data['education']?.isNotEmpty ?? false) ...[
                  _buildCanvaSection(
                    'Education',
                    null,
                    canvaColors[0],
                    data['education'],
                  ),
                  const SizedBox(height: 25),
                ],
                if (data['skills']?.isNotEmpty ?? false) ...[
                  _buildCanvaSkillsSection(
                    'Skills',
                    data['skills'],
                    canvaColors[0],
                  ),
                  const SizedBox(height: 25),
                ],
                if (data['certifications']?.isNotEmpty ?? false) ...[
                  _buildCanvaSkillsSection(
                    'Certifications',
                    data['certifications'],
                    canvaColors[0],
                  ),
                  const SizedBox(height: 25),
                ],
                if (data['languages']?.isNotEmpty ?? false)
                  _buildCanvaSkillsSection(
                    'Languages',
                    data['languages'],
                    canvaColors[0],
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  static Widget buildCreativeContent(Map<String, dynamic> data) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          width: a4Width,
          padding: const EdgeInsets.all(50),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: canvaColors[2].withOpacity(0.4),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Stack(
            children: [

              SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header with tilted gradient and overlapping avatar
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.fromLTRB(24, 60, 24, 24),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [canvaColors[2], Color(0xFFFF6F61)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Color(0xFFFF6F61).withOpacity(0.5),
                                blurRadius: 15,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          transform: Matrix4.rotationZ(-0.05),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 60),
                              Text(
                                data['fullName'] ?? 'Unknown Name',
                                style: GoogleFonts.dancingScript(
                                  fontSize: 32,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                data['title'] ?? 'Professional',
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  color: Colors.white70,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 20),
                              _buildContactInfo(data, Colors.white),
                            ],
                          ),
                        ),
                        Positioned(
                          top: -50,
                          left: 20,
                          child: Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              border: Border.all(color: Color(0xFFFFD700), width: 3),
                              boxShadow: [
                                BoxShadow(
                                  color: Color(0xFFFF6F61).withOpacity(0.6),
                                  blurRadius: 12,
                                ),
                              ],
                            ),
                            child: Center(
                              child: Text(
                                (data['fullName'] ?? 'A')[0].toUpperCase(),
                                style: GoogleFonts.lobster(
                                  fontSize: 48,
                                  color: canvaColors[2],
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          top: 10,
                          right: 20,
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Color(0xFFFFD700),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                    // Content Sections
                    if (data['objective']?.isNotEmpty ?? false) ...[
                      _buildCanvaSection('Professional Summary', data['objective'], canvaColors[2]),
                      const SizedBox(height: 25),
                    ],
                    if (data['experience']?.isNotEmpty ?? false) ...[
                      _buildCanvaSection(
                        'Work Experience',
                        null, // Pass null for content
                        canvaColors[2],
                        data['experience'], // Pass the list as items
                      ),
                      const SizedBox(height: 25),
                    ],
                    if (data['education']?.isNotEmpty ?? false) ...[
                      _buildCanvaSection(
                        'Education',
                        null, // Pass null for content
                        canvaColors[2],
                        data['education'], // Pass the list as items
                      ),
                      const SizedBox(height: 25),
                    ],
                    if (data['skills']?.isNotEmpty ?? false) ...[
                      _buildCanvaSkillsSection('Skills', data['skills'], canvaColors[2], ),
                      const SizedBox(height: 25),
                    ],
                    if (data['certifications']?.isNotEmpty ?? false) ...[
                      _buildCanvaSkillsSection('Certifications', data['certifications'], canvaColors[2], ),
                      const SizedBox(height: 25),
                    ],
                    if (data['languages']?.isNotEmpty ?? false)
                      _buildCanvaSkillsSection('Languages', data['languages'], canvaColors[2],),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  static Widget buildMinimalistContent(
    Map<String, dynamic> data,

  ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return
          Container(
            width: a4Width,
            padding: const EdgeInsets.all(50),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Text(
                    data['fullName'] ?? 'Unknown Name',
                    style: GoogleFonts.poppins(
                      fontSize: 36,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    data['title'] ?? 'Professional',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      color: Colors.black54,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(height: 1, color: Colors.black12),
                  const SizedBox(height: 20),
                  // Contact Information
                  Wrap(
                    spacing: 15,
                    runSpacing: 10,
                    children: [
                      if (data['email']?.isNotEmpty ?? false)
                        _buildContactItem(
                          Icons.email_outlined,
                          data['email'],
                          Colors.black54,
                        ),
                      if (data['phone']?.isNotEmpty ?? false)
                        _buildContactItem(
                          Icons.phone_outlined,
                          data['phone'],
                          Colors.black54,
                        ),
                      if (data['address']?.isNotEmpty ?? false)
                        _buildContactItem(
                          Icons.location_on_outlined,
                          data['address'],
                          Colors.black54,
                        ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  // Content
                  if (data['objective']?.isNotEmpty ?? false) ...[
                    _buildCanvaSection(
                      'Summary',
                      data['objective'],
                      Colors.black54,
                    ),
                    const SizedBox(height: 25),
                  ],
                  if (data['experience']?.isNotEmpty ?? false) ...[
                    _buildCanvaSection(
                      'Experience',
                      null,
                      Colors.black54,
                      data['experience'],
                    ),
                    const SizedBox(height: 25),
                  ],
                  if (data['education']?.isNotEmpty ?? false) ...[
                    _buildCanvaSection(
                      'Education',
                      null,
                      Colors.black54,
                      data['education'],
                    ),
                    const SizedBox(height: 25),
                  ],
                  if (data['skills']?.isNotEmpty ?? false) ...[
                    _buildCanvaSkillsSection(
                      'Skills',
                      data['skills'],
                      Colors.black54,
                    ),
                    const SizedBox(height: 25),
                  ],
                  if (data['certifications']?.isNotEmpty ?? false) ...[
                    _buildCanvaSkillsSection(
                      'Certifications',
                      data['certifications'],
                      Colors.black54,
                    ),
                    const SizedBox(height: 25),
                  ],
                  if (data['languages']?.isNotEmpty ?? false)
                    _buildCanvaSkillsSection(
                      'Languages',
                      data['languages'],
                      Colors.black54,
                    ),
                ],
              ),
            ),
          );
      },
    );
  }

  static Widget buildProfessionalContent(
    Map<String, dynamic> data,
  ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return
          Container(
            width: a4Width,
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 30),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: canvaColors[4].withOpacity(0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header with gradient bar
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: canvaGradients[4],
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(8),
                        bottomRight: Radius.circular(8),
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                data['fullName'] ?? 'Unknown Name',
                                style: GoogleFonts.montserrat(
                                  fontSize: 36,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                data['title'] ?? 'Professional',
                                style: GoogleFonts.poppins(
                                  fontSize: 18,
                                  color: Colors.white70,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: canvaColors[4].withOpacity(0.4),
                                blurRadius: 10,
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              (data['fullName'] ?? 'A')[0].toUpperCase(),
                              style: GoogleFonts.montserrat(
                                fontSize: 40,
                                fontWeight: FontWeight.bold,
                                color: canvaColors[4],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                  // Contact Information
                  Wrap(
                    spacing: 15,
                    runSpacing: 10,
                    children: [
                      if (data['email']?.isNotEmpty ?? false)
                        _buildContactItem(
                          Icons.email_outlined,
                          data['email'],
                          canvaColors[4],
                        ),
                      if (data['phone']?.isNotEmpty ?? false)
                        _buildContactItem(
                          Icons.phone_outlined,
                          data['phone'],
                          canvaColors[4],
                        ),
                      if (data['address']?.isNotEmpty ?? false)
                        _buildContactItem(
                          Icons.location_on_outlined,
                          data['address'],
                          canvaColors[4],
                        ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  // Two Column Layout
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 2,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (data['objective']?.isNotEmpty ?? false) ...[
                              _buildCanvaSection(
                                'Professional Summary',
                                data['objective'],
                                canvaColors[4],
                              ),
                              const SizedBox(height: 25),
                            ],
                            if (data['experience']?.isNotEmpty ?? false) ...[
                              _buildCanvaSection(
                                'Work Experience',
                                null,
                                canvaColors[4],
                                data['experience'],
                              ),
                              const SizedBox(height: 25),
                            ],
                            if (data['education']?.isNotEmpty ?? false)
                              _buildCanvaSection(
                                'Education',
                                null,
                                canvaColors[4],
                                data['education'],
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 30),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (data['skills']?.isNotEmpty ?? false) ...[
                              _buildCanvaSkillsSection(
                                'Skills',
                                data['skills'],
                                canvaColors[4],
                              ),
                              const SizedBox(height: 25),
                            ],
                            if (data['certifications']?.isNotEmpty ??
                                false) ...[
                              _buildCanvaSkillsSection(
                                'Certifications',
                                data['certifications'],
                                canvaColors[4],
                              ),
                              const SizedBox(height: 25),
                            ],
                            if (data['languages']?.isNotEmpty ?? false)
                              _buildCanvaSkillsSection(
                                'Languages',
                                data['languages'],
                                canvaColors[4],
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
      },
    );
  }

  static Widget buildInfographicContent(
    Map<String, dynamic> data,
  ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return
          Container(
            width: a4Width,
            padding: const EdgeInsets.all(40),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: canvaColors[5].withOpacity(0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Timeline Sidebar
                  Container(
                    width: 60,
                    child: Column(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: canvaColors[5],
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              (data['fullName'] ?? 'A')[0].toUpperCase(),
                              style: GoogleFonts.montserrat(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        Container(
                          width: 4,
                          height: a4Height - 120,
                          color: canvaColors[5].withOpacity(0.3),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 20),
                  // Main Content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          data['fullName'] ?? 'Unknown Name',
                          style: GoogleFonts.montserrat(
                            fontSize: 36,
                            fontWeight: FontWeight.w800,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          data['title'] ?? 'Professional',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            color: canvaColors[5],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 20),
                        _buildContactInfo(data, canvaColors[5]),
                        const SizedBox(height: 30),
                        if (data['objective']?.isNotEmpty ?? false) ...[
                          _buildTimelineSection(
                            'Professional Summary',
                            data['objective'],
                            canvaColors[5],
                          ),
                          const SizedBox(height: 25),
                        ],
                        if (data['education']?.isNotEmpty ?? false) ...[
                          _buildTimelineSection(
                            'Education',
                            null,
                            canvaColors[5],
                            data['education'],
                          ),
                          const SizedBox(height: 25),
                        ],
                        if (data['experience']?.isNotEmpty ?? false) ...[
                          _buildTimelineSection(
                            'Work Experience',
                            null,
                            canvaColors[5],
                            data['experience'],
                          ),
                          const SizedBox(height: 25),
                        ],
                        if (data['skills']?.isNotEmpty ?? false) ...[
                          _buildCanvaSkillsSection(
                            'Skills',
                            data['skills'],
                            canvaColors[5],
                          ),
                          const SizedBox(height: 25),
                        ],
                        if (data['certifications']?.isNotEmpty ?? false) ...[
                          _buildCanvaSkillsSection(
                            'Certifications',
                            data['certifications'],
                            canvaColors[5],
                          ),
                          const SizedBox(height: 25),
                        ],
                        if (data['languages']?.isNotEmpty ?? false)
                          _buildCanvaSkillsSection(
                            'Languages',
                            data['languages'],
                            canvaColors[5],
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
      },
    );
  }

  static Widget _buildContactItem(
    IconData icon,
    String text,
    Color accentColor,
  ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16.sp, color: accentColor),
            SizedBox(width: 8.w),
            Flexible(
              child: Text(
                text,
                style: GoogleFonts.poppins(fontSize: 14.sp, color: Colors.black87),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        );
      },
    );
  }

  static Widget _buildContactInfo(
    Map<String, dynamic> data,
    Color accentColor,
  ) {
    return Wrap(
      spacing: 15,
      runSpacing: 10,
      children: [
        if (data['email']?.isNotEmpty ?? false)
          _buildContactItem(Icons.email_outlined, data['email'], accentColor),
        if (data['phone']?.isNotEmpty ?? false)
          _buildContactItem(Icons.phone_outlined, data['phone'], accentColor),
        if (data['address']?.isNotEmpty ?? false)
          _buildContactItem(
            Icons.location_on_outlined,
            data['address'],
            accentColor,
          ),
      ],
    );
  }

  static Widget _buildCanvaSection(
    String title,
    String? content,
    Color accentColor, [
    List<dynamic>? items,
  ]) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.only(bottom: 8.h),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: accentColor.withOpacity(0.3),
                    width: 2,
                  ),
                ),
              ),
              child: Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                  color: accentColor,
                ),
              ),
            ),
            SizedBox(height: 15.h),
            if (content != null)
              Container(
                padding: EdgeInsets.all(15.w),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8.r),
                  boxShadow: [
                    BoxShadow(
                      color: accentColor.withOpacity(0.15),
                      blurRadius: 5.r,
                      offset: Offset(0, 2.h),
                    ),
                  ],
                ),
                child: Text(
                  content,
                  style: GoogleFonts.poppins(
                    fontSize: 14.sp,
                    color: Colors.black87,
                    height: 1.5,
                  ),
                ),
              ),
            if (items != null)
              ...items.asMap().entries.map<Widget>((entry) {
                final item = entry.value;
                return Container(
                  margin: EdgeInsets.only(bottom: 15.h),
                  padding: EdgeInsets.all(15.w),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8.r),
                    boxShadow: [
                      BoxShadow(
                        color: accentColor.withOpacity(0.15),
                        blurRadius: 5.r,
                        offset: Offset(0, 2.h),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (item is Map) ...[
                        Text(
                          item['role'] ?? item['degree'] ?? item.toString(),
                          style: GoogleFonts.poppins(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w500,
                            color: Colors.black87,
                          ),
                        ),
                        SizedBox(height: 5.h),
                        Text(
                          '${item['company'] ?? item['institution'] ?? ''} • ${item['duration'] ?? item['year'] ?? ''}',
                          style: GoogleFonts.poppins(
                            fontSize: 14.sp,
                            color: accentColor,
                          ),
                        ),
                        if (item['description'] != null) ...[
                          SizedBox(height: 8.h),
                          Text(
                            item['description'],
                            style: GoogleFonts.poppins(
                              fontSize: 14.sp,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ] else
                        Text(
                          item.toString(),
                          style: GoogleFonts.poppins(
                            fontSize: 14.sp,
                            color: Colors.black87,
                          ),
                        ),
                    ],
                  ),
                );
              }),
          ],
        );
      },
    );
  }

  static Widget _buildCanvaSkillsSection(
    String title,
    List<dynamic>? items,
    Color accentColor,
  ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.only(bottom: 8.h),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: accentColor.withOpacity(0.3),
                    width: 2,
                  ),
                ),
              ),
              child: Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                  color: accentColor,
                ),
              ),
            ),
            SizedBox(height: 15.h),
            Wrap(
              spacing: 10.w,
              runSpacing: 10.h,
              children:
                  items?.asMap().entries.map<Widget>((entry) {
                    final item = entry.value;
                    return Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12.w,
                        vertical: 8.h,
                      ),
                      decoration: BoxDecoration(
                        color: accentColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20.r),
                        boxShadow: [
                          BoxShadow(
                            color: accentColor.withOpacity(0.1),
                            blurRadius: 5.r,
                          ),
                        ],
                      ),
                      child: Text(
                        item.toString(),
                        style: GoogleFonts.poppins(
                          fontSize: 14.sp,
                          color: accentColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    );
                  }).toList() ??
                  [],
            ),
          ],
        );
      },
    );
  }

  static Widget _buildTimelineSection(
    String title,
    String? content,
    Color accentColor, [
    List<dynamic>? items,
  ]) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.only(bottom: 8.h),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: accentColor.withOpacity(0.3),
                    width: 2,
                  ),
                ),
              ),
              child: Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                  color: accentColor,
                ),
              ),
            ),
            SizedBox(height: 15.h),
            if (content != null)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 12.w,
                    height: 12.h,
                    decoration: BoxDecoration(
                      color: accentColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  SizedBox(width: 15.w),
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.all(15.w),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8.r),
                        boxShadow: [
                          BoxShadow(
                            color: accentColor.withOpacity(0.15),
                            blurRadius: 5.r,
                            offset: Offset(0, 2.h),
                          ),
                        ],
                      ),
                      child: Text(
                        content,
                        style: GoogleFonts.poppins(
                          fontSize: 14.sp,
                          color: Colors.black87,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            if (items != null)
              ...items.asMap().entries.map<Widget>((entry) {
                final item = entry.value;
                return Padding(
                  padding: EdgeInsets.only(bottom: 15.h),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        children: [
                          Container(
                            width: 12.w,
                            height: 12.h,
                            decoration: BoxDecoration(
                              color: accentColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                          if (entry.key < items.length - 1)
                            Container(
                              width: 2.w,
                              height: 60.h,
                              color: accentColor.withOpacity(0.3),
                            ),
                        ],
                      ),
                      SizedBox(width: 15.w),
                      Expanded(
                        child: Container(
                          padding: EdgeInsets.all(15.w),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8.r),
                            boxShadow: [
                              BoxShadow(
                                color: accentColor.withOpacity(0.15),
                                blurRadius: 5.r,
                                offset: Offset(0, 2.h),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (item is Map) ...[
                                Text(
                                  item['role'] ??
                                      item['degree'] ??
                                      item.toString(),
                                  style: GoogleFonts.poppins(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black87,
                                  ),
                                ),
                                SizedBox(height: 5.h),
                                Text(
                                  '${item['company'] ?? item['institution'] ?? ''} • ${item['duration'] ?? item['year'] ?? ''}',
                                  style: GoogleFonts.poppins(
                                    fontSize: 14.sp,
                                    color: accentColor,
                                  ),
                                ),
                                if (item['description'] != null) ...[
                                  SizedBox(height: 8.h),
                                  Text(
                                    item['description'],
                                    style: GoogleFonts.poppins(
                                      fontSize: 14.sp,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ],
                              ] else
                                Text(
                                  item.toString(),
                                  style: GoogleFonts.poppins(
                                    fontSize: 14.sp,
                                    color: Colors.black87,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
          ],
        );
      },
    );
  }
}
