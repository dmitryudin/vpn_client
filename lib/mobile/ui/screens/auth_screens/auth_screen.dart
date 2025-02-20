import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:auth_feature/data/auth_data.dart';
import 'package:auth_feature/data/device_info.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vpn/mobile/data/auth_features/auth_module.dart';
import 'package:vpn/mobile/utils/bloc/screen_state_bloc.dart';

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
  final _inviteCodeController = TextEditingController();

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
        ..inviteCode = _inviteCodeController.text
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
          BlocProvider.of<ScreenStateBloc>(context).add(LoadServerList());
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
          BlocProvider.of<ScreenStateBloc>(context).add(LoadServerList());
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

  String? _validateInviteCode(String? value) {
    if ((value ?? '').length > 0) {
      final inviteCodeRegExp = RegExp(r'^[0-9]{6}$');
      if (!inviteCodeRegExp.hasMatch(value ?? '')) {
        return 'Код должен состоять из 6 цифр';
      }
    }
    return null;
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
        title: Text(
          _isLoginMode ? 'Вход' : 'Регистрация',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blueAccent,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blueAccent, Colors.lightBlueAccent],
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                Column(
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
                            color: Colors.white,
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
                        labelStyle: TextStyle(color: Colors.white70),
                        border: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                        ),
                        prefixIcon: Icon(Icons.email, color: Colors.white),
                      ),
                      style: TextStyle(color: Colors.white),
                      validator: _validateEmail,
                    ),
                    SizedBox(height: 20),
                    TextFormField(
                      controller: _passwordController,
                      decoration: InputDecoration(
                        labelText: 'Пароль',
                        labelStyle: TextStyle(color: Colors.white70),
                        border: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                        ),
                        prefixIcon: Icon(Icons.lock, color: Colors.white),
                      ),
                      style: TextStyle(color: Colors.white),
                      obscureText: true,
                      validator: _validatePassword,
                    ),
                    if (!_isLoginMode) ...[
                      SizedBox(height: 20),
                      TextFormField(
                        controller: _confirmPasswordController,
                        decoration: InputDecoration(
                          labelText: 'Повторите пароль',
                          labelStyle: TextStyle(color: Colors.white70),
                          border: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.white),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.white),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.white),
                          ),
                          prefixIcon: Icon(Icons.lock, color: Colors.white),
                        ),
                        style: TextStyle(color: Colors.white),
                        obscureText: true,
                        validator: _validateConfirmPassword,
                      ),
                      SizedBox(height: 20),
                      TextFormField(
                        controller: _inviteCodeController,
                        decoration: InputDecoration(
                          labelText: 'Инвайт код',
                          labelStyle: TextStyle(color: Colors.white70),
                          border: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.white),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.white),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.white),
                          ),
                          prefixIcon: Icon(Icons.confirmation_number,
                              color: Colors.white),
                        ),
                        style: TextStyle(color: Colors.white),
                        keyboardType: TextInputType.number,
                        validator: _validateInviteCode,
                      ),
                    ],
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () async {
                        final prefs = await SharedPreferences.getInstance();
                        await prefs.setBool('seen_onboarding', true);

                        _isLoginMode ? _login() : _register();
                      },
                      child: Text(
                        _isLoginMode ? 'Войти' : 'Зарегистрироваться',
                        style: TextStyle(color: Colors.blueAccent),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        padding:
                            EdgeInsets.symmetric(vertical: 15, horizontal: 30),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30.0),
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: _toggleMode,
                      child: Text(
                        _isLoginMode ? 'Создать аккаунт' : 'Уже есть аккаунт',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
