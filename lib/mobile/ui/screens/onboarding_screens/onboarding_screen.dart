import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vpn/mobile/ui/widgets/fade_in_widget.dart';
import 'package:vpn/mobile/ui/widgets/animated_card.dart';

class OnboardingScreen extends StatefulWidget {
  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  final List<OnboardingPage> _pages = [
    OnboardingPage(
      title: "Безопасно и надежно",
      description:
          "Мы всегда стремимся защитить вашу конфиденциальность и ваши данные. Работайте с нами на любом из ваших устройств — Mac, iOS или Android.",
      image: "assets/images/coins.png",
      icon: Icons.security_rounded,
    ),
    OnboardingPage(
      title: "Лучшие серверы",
      description:
          "Используем самые современные протоколы обфускации и шифрования. Ваши данные всегда под защитой, где бы вы ни находились.",
      image: "assets/images/coins.png",
      icon: Icons.dns_rounded,
    ),
    OnboardingPage(
      title: "Серверы по всему миру",
      description:
          "Выбирайте любой из доступных серверов в более чем 30 странах мира. Наслаждайтесь высокой скоростью и стабильностью соединения.",
      image: "assets/images/coins.png",
      icon: Icons.public_rounded,
    ),
    OnboardingPage(
      title: "Премиум подписка",
      description:
          "Получите полный доступ ко всем серверам и функциям. Работайте одновременно с трех устройств на одном аккаунте.",
      image: "assets/images/coins.png",
      icon: Icons.star_rounded,
      isLast: true,
    ),
  ];

  void seen_onboarding(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('seen_onboarding', true);
    context.go('/');
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              colorScheme.primary,
              colorScheme.primary.withOpacity(0.8),
              colorScheme.background,
            ],
            stops: const [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          child: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: _pages.length,
            onPageChanged: (int page) {
              setState(() {
                _currentPage = page;
              });
            },
            itemBuilder: (context, index) {
              return _pages[index];
            },
          ),
          if (_currentPage == _pages.length - 1)
            Positioned(
                  top: 20,
                  right: 20,
                  child: FadeInWidget(
                    delay: const Duration(milliseconds: 300),
                    child: AnimatedCard(
                      padding: EdgeInsets.zero,
                      borderRadius: BorderRadius.circular(30),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () async {
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.setBool('seen_onboarding', true);
                  context.go('/');
                },
                          borderRadius: BorderRadius.circular(30),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: Icon(
                              Icons.close_rounded,
                              color: colorScheme.onPrimary,
                            ),
                          ),
                        ),
                      ),
                    ),
              ),
            ),
          Positioned(
            bottom: 50,
            left: 0,
            right: 0,
            child: Column(
              children: [
                if (_currentPage == _pages.length - 1)
                      FadeInWidget(
                        delay: const Duration(milliseconds: 200),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 40.0),
                          child: AnimatedCard(
                            padding: EdgeInsets.zero,
                            borderRadius: BorderRadius.circular(30),
                            child: Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    colorScheme.onPrimary,
                                    colorScheme.onPrimary.withOpacity(0.9),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(30),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    blurRadius: 20,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: () async {
                        context.go('/auth');
                      },
                                  borderRadius: BorderRadius.circular(30),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 18,
                                      horizontal: 30,
                                    ),
                      child: Text(
                        'Регистрация/Войти',
                                      textAlign: TextAlign.center,
                                      style: theme.textTheme.titleMedium?.copyWith(
                                        color: colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    const SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    _pages.length,
                    (index) => AnimatedContainer(
                          duration: const Duration(milliseconds: 400),
                          curve: Curves.easeInOut,
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                      height: 8,
                          width: _currentPage == index ? 32 : 8,
                      decoration: BoxDecoration(
                        color: _currentPage == index
                                ? colorScheme.onPrimary
                                : colorScheme.onPrimary.withOpacity(0.4),
                        borderRadius: BorderRadius.circular(4),
                            boxShadow: _currentPage == index
                                ? [
                                    BoxShadow(
                                      color: colorScheme.onPrimary.withOpacity(0.5),
                                      blurRadius: 8,
                                      spreadRadius: 2,
                                    ),
                                  ]
                                : null,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
          ),
        ),
      ),
    );
  }
}

class OnboardingPage extends StatelessWidget {
  final String title;
  final String description;
  final String image;
  final bool isLast;
  final IconData icon;

  OnboardingPage({
    required this.title,
    required this.description,
    required this.image,
    this.isLast = false,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
      children: [
          FadeInWidget(
            delay: const Duration(milliseconds: 100),
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    colorScheme.onPrimary.withOpacity(0.2),
                    colorScheme.onPrimary.withOpacity(0.1),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: colorScheme.onPrimary.withOpacity(0.3),
                    blurRadius: 30,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Icon(
                icon,
                size: 100,
                color: colorScheme.onPrimary,
              ),
            ),
          ),
          const SizedBox(height: 60),
          FadeInWidget(
            delay: const Duration(milliseconds: 200),
            child: Text(
              title,
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: colorScheme.onPrimary,
                letterSpacing: 0.5,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 24),
          FadeInWidget(
            delay: const Duration(milliseconds: 300),
            child: Text(
              description,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: colorScheme.onPrimary.withOpacity(0.9),
                height: 1.6,
                letterSpacing: 0.3,
              ),
            ),
              ),
            ],
          ),
    );
  }
}
