import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

void showForceUpdateDialog(BuildContext context, String updateUrl) {
  showDialog(
      context: context,
      barrierDismissible: false, // Запрет закрытия при тапе вне диалога
      builder: (BuildContext context) {
        return WillPopScope(
            onWillPop: () async => false, // Блокировка кнопки "Назад"
            child: AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Анимированная иконка
                  RotationTransition(
                    turns: const AlwaysStoppedAnimation(45 / 360),
                    child: Icon(
                      Icons.system_update_alt,
                      size: 60,
                      color: Colors.blueAccent,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Доступно новое обновление!',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 15),
                  const Text(
                    'Для продолжения работы приложения\nнеобходимо установить последнюю версию',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 25),
                  // Кнопка обновления
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        elevation: 3,
                      ),
                      icon: const Icon(Icons.update, color: Colors.white),
                      label: const Text(
                        'Обновить сейчас',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      onPressed: () async {
                        if (await canLaunchUrl(Uri.parse(updateUrl))) {
                          await launchUrl(Uri.parse(updateUrl));
                        }
                      },
                    ),
                  ),
                ],
              ),
            ));
      });
}
