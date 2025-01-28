import 'package:flutter/material.dart';

class ServerList extends StatefulWidget {
  @override
  _ServerListState createState() => _ServerListState();
}

class _ServerListState extends State<ServerList> {
  String? selectedServer; // Переменная для хранения выбранного сервера
  final List<String> servers = List.generate(
      10, (index) => 'Server $index'); // Генерация списка серверов

  @override
  Widget build(BuildContext context) {
    return Center(
      child: DropdownButton<String>(
        value: selectedServer, // Устанавливаем выбранный элемент
        hint: Text('Выберите сервер'), // Подсказка
        items: servers.map((server) {
          return DropdownMenuItem<String>(
            value: server,
            child: Text(server),
          );
        }).toList(),
        onChanged: (value) {
          setState(() {
            selectedServer = value; // Обновляем выбранный элемент
          });
        },
      ),
    );
  }
}
