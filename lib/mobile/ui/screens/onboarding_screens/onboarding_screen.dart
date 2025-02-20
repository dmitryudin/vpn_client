import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
    ),
    OnboardingPage(
      title: "Лучшие сервера",
      description:
          "Используем самые современные протоколы обфускации и шифрования. Ваши данные всегда под защитой, где бы вы ни находились.",
      image: "assets/images/coins.png",
    ),
    OnboardingPage(
      title: "Серверы по всему миру",
      description:
          "Выбирайте любой из доступных серверов в более чем 30 странах мира. Наслаждайтесь высокой скоростью и стабильностью соединения.",
      image: "assets/images/coins.png",
    ),
    OnboardingPage(
      title: "Премиум подписка",
      description:
          "Получите полный доступ ко всем серверам и функциям. Работайте одновременно с трех устройств на одном аккаунте.",
      image: "assets/images/coins.png",
      isLast: true,
    ),
  ];

  void seen_onboarding(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('seen_onboarding', true);
    context.go('/'); // Переход на главный экран
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: Stack(
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
              top: 40,
              left: 20,
              child: IconButton(
                icon: Icon(Icons.close, color: theme.colorScheme.onBackground),
                onPressed: () async {
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.setBool('seen_onboarding', true);
                  context.go('/');
                },
              ),
            ),
          Positioned(
            bottom: 50,
            left: 0,
            right: 0,
            child: Column(
              children: [
                if (_currentPage == _pages.length - 1)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 40.0, vertical: 10.0),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        foregroundColor: theme.colorScheme.onSecondary,
                        backgroundColor: theme.colorScheme.secondary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30.0),
                          side: BorderSide(color: theme.colorScheme.secondary),
                        ),
                        padding:
                            EdgeInsets.symmetric(vertical: 15, horizontal: 30),
                        elevation: 5,
                      ),
                      onPressed: () async {
                        context.go('/auth');
                      },
                      child: Text(
                        'Регистрация/Войти',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    _pages.length,
                    (index) => AnimatedContainer(
                      duration: Duration(milliseconds: 300),
                      margin: EdgeInsets.symmetric(horizontal: 5),
                      height: 8,
                      width: _currentPage == index ? 24 : 8,
                      decoration: BoxDecoration(
                        color: _currentPage == index
                            ? theme.colorScheme.primary
                            : theme.colorScheme.onSurface,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class OnboardingPage extends StatelessWidget {
  final String title;
  final String description;
  final String image;
  final bool isLast;

  OnboardingPage({
    required this.title,
    required this.description,
    required this.image,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Stack(
      children: [
        // Фоновое изображение (только для первого экрана)
        if (title == "Безопасно и надежно")
          Positioned.fill(
            child: Align(
              alignment:
                  Alignment.topCenter, // Выравниваем изображение по верху
              child: Padding(
                padding: EdgeInsets.only(top: 50), // Отступ сверху
                child: Image.asset(
                  'assets/icons/onboarding_1.png', // Путь к фоновому изображению
                  fit: BoxFit.contain, // Сохраняем пропорции изображения
                ),
              ),
            ),
          ),
        if (title == "Лучшие сервера")
          Positioned.fill(
            child: Align(
              alignment:
                  Alignment.topCenter, // Выравниваем изображение по верху
              child: Padding(
                padding: EdgeInsets.fromLTRB(50, 70, 0, 0), // Отступ сверху
                child: Image.asset(
                  'assets/icons/onboarding_2.png', // Путь к фоновому изображению
                  fit: BoxFit.contain, // Сохраняем пропорции изображения
                ),
              ),
            ),
          ),
        if (title == "Серверы по всему миру")
          Positioned.fill(
            child: Align(
              alignment:
                  Alignment.topCenter, // Выравниваем изображение по верху
              child: Padding(
                padding: EdgeInsets.only(top: 50), // Отступ сверху
                child: Image.asset(
                  'assets/icons/onboarding_3.png', // Путь к фоновому изображению
                  fit: BoxFit.contain, // Сохраняем пропорции изображения
                ),
              ),
            ),
          ),
        if (title == "Премиум подписка")
          Positioned.fill(
            child: Align(
              alignment:
                  Alignment.topCenter, // Выравниваем изображение по верху
              child: Padding(
                padding: EdgeInsets.only(top: 50), // Отступ сверху
                child: Image.asset(
                  'assets/icons/onboarding_4.gif', // Путь к фоновому изображению
                  fit: BoxFit.contain, // Сохраняем пропорции изображения
                ),
              ),
            ),
          ),
        Padding(
          padding: EdgeInsets.all(40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(image, height: 200), // Основное изображение
              SizedBox(height: 40),
              Text(
                title,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onBackground,
                ),
              ),
              SizedBox(height: 20),
              Text(
                description,
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 16, color: theme.colorScheme.onBackground),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
