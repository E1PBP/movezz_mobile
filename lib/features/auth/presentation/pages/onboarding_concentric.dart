import 'package:flutter/material.dart';
import 'package:concentric_transition/concentric_transition.dart';
import 'package:movezz_mobile/core/routing/app_router.dart';
import '../../../../core/theme/app_theme.dart';

class PageData {
  final String? title;
  final IconData? icon;
  final Color bgColor;
  final Color textColor;

  const PageData({
    this.title,
    this.icon,
    this.bgColor = Colors.white,
    this.textColor = Colors.black,
  });
}

final List<PageData> onboardingPages = [
  const PageData(
    icon: Icons.sports_soccer_outlined,
    title: "Connect with Sports Enthusiasts",
    bgColor: Color.fromARGB(255, 255, 255, 255),
    textColor: Color.fromARGB(255, 0, 0, 0),
  ),
  const PageData(
    icon: Icons.feed_outlined,
    title: "Share Your Sports Activities",
    bgColor: Color(0xFF2196F3),
    textColor: Colors.white,
  ),
  const PageData(
    icon: Icons.people_outline,
    title: "Join Sports Communities",
    bgColor: Color(0xFFFF9800),
    textColor: Colors.white,
  ),
  const PageData(
    icon: Icons.campaign_outlined,
    title: "Discover Sports Events",
    bgColor: Color(0xFF9C27B0),
    textColor: Colors.white,
  ),
  const PageData(
    icon: Icons.fitness_center_outlined,
    title: "Start Your Sports Journey!",
    bgColor: AppColors.primary,
    textColor: Colors.white,
  ),
];

class ConcentricAnimationOnboarding extends StatelessWidget {
  const ConcentricAnimationOnboarding({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: ConcentricPageView(
        colors: onboardingPages.map((p) => p.bgColor).toList(),
        radius: screenWidth * 0.1,
        nextButtonBuilder: (context) => Padding(
          padding: const EdgeInsets.only(left: 3),
          child: Icon(Icons.navigate_next, size: screenWidth * 0.08),
        ),
        scaleFactor: 2,
        itemCount: onboardingPages.length,
        onFinish: () {
          
          Navigator.of(context).pushReplacementNamed(AppRoutes.login);
        },
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

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(16.0),
          margin: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: page.textColor,
          ),
          child: Icon(page.icon, size: screenHeight * 0.1, color: page.bgColor),
        ),
        const SizedBox(height: 16),
        Text(
          page.title ?? "",
          style: TextStyle(
            color: page.textColor,
            fontSize: screenHeight * 0.035,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
