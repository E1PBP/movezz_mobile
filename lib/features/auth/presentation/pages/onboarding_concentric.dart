import 'package:flutter/material.dart';
import 'package:concentric_transition/concentric_transition.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:nb_utils/nb_utils.dart';

// Import AppRoutes agar bisa navigasi
import 'package:movezz_mobile/core/routing/app_router.dart'; 

// 1. Model Data
class PageData {
  final String? title;
  final String? caption;
  final String svgAsset;
  final Color bgColor;
  final Color textColor;
  final Color iconColor; 

  final double imageHeightRatio;
  final double imageWidthRatio;

  const PageData({
    this.title,
    this.caption,
    required this.svgAsset,
    this.bgColor = Colors.white,
    this.textColor = Colors.black,
    required this.iconColor, 
    this.imageHeightRatio = 0.35,
    this.imageWidthRatio = 0.8,
  });
}

// 2. Daftar Halaman
final List<PageData> onboardingPages = [
  const PageData(
    svgAsset: "assets/onboarding/page-1.svg",
    bgColor: Color(0xFFFAFAFA),
    textColor: Colors.black,
    imageHeightRatio: 0.4,
    imageWidthRatio: 0.5,
    iconColor: Colors.white, 
  ),
  const PageData(
    svgAsset: "assets/onboarding/page-2.svg",
    title: "Connect and Inspire",
    caption:
        "Track friends’ progress, celebrate their milestones, and showcase your own championships on your social feed.",
    bgColor: Color(0xFF84CC16), 
    textColor: Color(0xFF365314),
    imageHeightRatio: 0.3,
    imageWidthRatio: 0.5,
    iconColor: Colors.white,
  ),
  const PageData(
    svgAsset: "assets/onboarding/page-3.svg",
    title: "Join the Action",
    caption:
        "Explore broadcasts for local sports events and RSVP instantly to join the community!",
    bgColor: Color(0xFF365314), 
    textColor: Colors.white,
    imageHeightRatio: 0.3,
    iconColor: Color(0xFF84CC16), 
  ),
  const PageData(
    svgAsset: "assets/onboarding/page-4.svg",
    title: "Let's Get Moving!",
    caption:
        "Find essential equipment in the marketplace, chat with friends, and start your journey today!",
    bgColor: Color(0xFFFAFAFA),
    textColor: Color(0xFF171717),
    iconColor: Colors.black,
  ),
];

class ConcentricAnimationOnboarding extends StatefulWidget {
  const ConcentricAnimationOnboarding({super.key});

  @override
  State<ConcentricAnimationOnboarding> createState() =>
      _ConcentricAnimationOnboardingState();
}

class _ConcentricAnimationOnboardingState
    extends State<ConcentricAnimationOnboarding> {
  
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: ConcentricPageView(
        colors: onboardingPages.map((p) => p.bgColor).toList(),
        radius: screenWidth * 0.1,
        
        onChange: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        
        nextButtonBuilder: (context) {
          return Padding(
            padding: const EdgeInsets.only(left: 3),
            child: Icon(
              Icons.navigate_next,
              size: screenWidth * 0.15,
              color: onboardingPages[_currentIndex % onboardingPages.length].iconColor,
            ),
          );
        },
        scaleFactor: 2,
        itemCount: onboardingPages.length,
        
        // --- BAGIAN INI YANG DIPERBAIKI ---
        onFinish: () {
          // 1. Simpan status bahwa user sudah melihat onboarding
          setValue('hasSeenOnboarding', true);
          
          print("Selesai Onboarding - Navigasi ke Login");

          // 2. Lakukan Navigasi (Uncommented)
          Navigator.of(context).pushReplacementNamed(AppRoutes.login);
        },
        // ----------------------------------

        itemBuilder: (index) {
          final page = onboardingPages[index];
          return SafeArea(child: _Page(page: page));
        },
      ),
    );
  }
}

class _Page extends StatelessWidget {
  final PageData page;

  const _Page({required this.page});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            height: screenHeight * page.imageHeightRatio,
            width: screenWidth * page.imageWidthRatio,
            child: SvgPicture.asset(
              page.svgAsset,
              fit: BoxFit.contain,
              placeholderBuilder: (BuildContext context) => Container(
                padding: const EdgeInsets.all(30.0),
                child: const CircularProgressIndicator(),
              ),
            ),
          ),
          const SizedBox(height: 40),
          if (page.title != null) ...[
            Text(
              page.title!,
              style: TextStyle(
                color: page.textColor,
                fontSize: 28,
                fontWeight: FontWeight.bold,
                fontFamily: 'Plus Jakarta Sans',
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
          ],
          if (page.caption != null) ...[
            Text(
              page.caption!,
              style: TextStyle(
                color: page.textColor.withOpacity(0.8),
                fontSize: 16,
                height: 1.2,
                fontWeight: FontWeight.w500,
                fontFamily: 'Plus Jakarta Sans',
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}