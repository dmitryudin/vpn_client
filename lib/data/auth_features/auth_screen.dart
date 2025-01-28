import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:auth_feature/data/auth_data.dart';
import 'package:auth_feature/data/device_info.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vpn/data/auth_features/auth_module.dart';

class AuthScreen extends StatefulWidget {
  final AuthModule authModule = AuthModule();

  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isRegistered = false;
  bool _isLoginMode = false;

  @override
  void initState() {
    super.initState();
    _checkRegistrationStatus();
  }

  Future<void> _checkRegistrationStatus() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isRegistered = prefs.getBool('is_registered') ?? false;
    });
  }

  Future<void> _register() async {
    if (_formKey.currentState!.validate()) {
      Map<String, String> deviceInfo = await getDeviceInfo();

      UserData userData = UserData()
        ..email = _emailController.text
        ..password = _passwordController.text
        ..deviceType = deviceInfo['deviceType'] ?? ''
        ..deviceId = deviceInfo['deviceId'] ?? '';
      AuthStatus status = await widget.authModule.authService.register(
          userData: userData,
          registerUrl: 'http://109.196.101.63:8000/api/register/');
      if (status == AuthStatus.authorized) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('is_registered', true);
        await prefs.setString('user_email', _emailController.text);
        if (mounted) {
          context.go('/');
        }
      }
    }
  }

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      Map<String, String> deviceInfo = await getDeviceInfo();

      final status = await widget.authModule.authService.logIn(
        username: _emailController.text,
        password: _passwordController.text,
        cloudMessageToken: '',
        deviceType: deviceInfo['deviceType'] ?? '',
        authUrl: 'http://109.196.101.63:8000/api/login/',
        deviceId: deviceInfo['deviceId'] ?? '',
      );

      if (status == AuthStatus.authorized) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('is_registered', true);
        await prefs.setString('user_email', _emailController.text);
        if (mounted) {
          context.go('/');
        }
      }
    }
  }

  void _toggleMode() {
    setState(() {
      _isLoginMode = !_isLoginMode;
    });
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Введите email';
    }
    final emailRegExp = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    if (!emailRegExp.hasMatch(value)) {
      return 'Введите корректный email';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Введите пароль';
    }
    if (value.length < 6) {
      return 'Пароль должен быть не менее 6 символов';
    }
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value != _passwordController.text) {
      return 'Пароли не совпадают';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isLoginMode ? 'Вход' : 'Регистрация'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedTextKit(
                animatedTexts: [
                  TyperAnimatedText(
                    _isLoginMode
                        ? 'Добро пожаловать обратно!'
                        : 'Создайте аккаунт',
                    textStyle: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                    speed: Duration(milliseconds: 100),
                  ),
                ],
              ),
              SizedBox(height: 20),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
                validator: _validateEmail,
              ),
              SizedBox(height: 20),
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: 'Пароль',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
                validator: _validatePassword,
              ),
              if (!_isLoginMode) ...[
                SizedBox(height: 20),
                TextFormField(
                  controller: _confirmPasswordController,
                  decoration: InputDecoration(
                    labelText: 'Повторите пароль',
                    border: OutlineInputBorder(),
                  ),
                  obscureText: true,
                  validator: _validateConfirmPassword,
                ),
              ],
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _isLoginMode ? _login : _register,
                child: Text(_isLoginMode ? 'Войти' : 'Зарегистрироваться'),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 15, horizontal: 30),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                ),
              ),
              TextButton(
                onPressed: _toggleMode,
                child:
                    Text(_isLoginMode ? 'Создать аккаунт' : 'Уже есть аккаунт'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
