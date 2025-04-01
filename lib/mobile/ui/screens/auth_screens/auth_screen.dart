import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:auth_feature/data/auth_data.dart';
import 'package:auth_feature/data/device_info.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
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
  String? _errorMessage; // Для хранения сообщения об ошибке

  bool _obscurePassword = true;

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
      setState(() {
        _errorMessage = null; // Сброс ошибки перед запросом
      });

      Map<String, String> deviceInfo = await getDeviceInfo();

      UserData userData = UserData()
        ..email = _emailController.text
        ..password = _passwordController.text
        ..inviteCode = _inviteCodeController.text
        ..deviceType = deviceInfo['deviceType'] ?? ''
        ..deviceId = deviceInfo['deviceId'] ?? '';

      try {
        AuthStatus status = await widget.authModule.authService.register(
            userData: userData,
            registerUrl: 'http://109.196.101.63:8000/api/register/');

        if (status == AuthStatus.authorized) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setBool('is_registered', true);
          await prefs.setString('user_email', _emailController.text);
          if (mounted) {
            // Вызываем событие для обновления состояния
            BlocProvider.of<ScreenStateBloc>(context).add(LoadServerList());
            context.go('/');
          }
        }
      } catch (e) {
        setState(() {
          _errorMessage = e.toString(); // Установка сообщения об ошибке
        });
      }
    }
  }

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _errorMessage = null; // Сброс ошибки перед запросом
      });

      Map<String, String> deviceInfo = await getDeviceInfo();

      try {
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
            // Вызываем событие для обновления состояния
            BlocProvider.of<ScreenStateBloc>(context).add(LoadServerList());
            context.go('/');
          }
        } else if (status == AuthStatus.unauthorized) {
          setState(() {
            _errorMessage = 'Неверный пароль'; // Установка сообщения об ошибке
          });
        }
      } catch (e) {
        setState(() {
          _errorMessage = e.toString(); // Установка сообщения об ошибке
        });
      }
    }
  }
  // Future<void> _register() async {
  //   if (_formKey.currentState!.validate()) {

  //     setState(() {
  //       _errorMessage = null; // Сброс ошибки перед запросом

  //     });

  //     Map<String, String> deviceInfo = await getDeviceInfo();

  //     UserData userData = UserData()
  //       ..email = _emailController.text
  //       ..password = _passwordController.text
  //       ..inviteCode = _inviteCodeController.text
  //       ..deviceType = deviceInfo['deviceType'] ?? ''
  //       ..deviceId = deviceInfo['deviceId'] ?? '';

  //     try {
  //       AuthStatus status = await widget.authModule.authService.register(
  //           userData: userData,
  //           registerUrl: 'http://109.196.101.63:8000/api/register/');

  //       if (status == AuthStatus.authorized) {
  //         final prefs = await SharedPreferences.getInstance();
  //         await prefs.setBool('is_registered', true);
  //         await prefs.setString('user_email', _emailController.text);
  //         if (mounted) {
  //           await BlocProvider.of<ScreenStateBloc>(context)
  //               .stream
  //               .firstWhere((state) => state is ScreenStateLoaded);

  //           if (mounted) {
  //             context.go('/');
  //           }
  //         }
  //       }
  //     } catch (e) {
  //       setState(() {
  //         _errorMessage = e.toString(); // Установка сообщения об ошибке
  //       });
  //     }
  //   }
  // }

  // Future<void> _login() async {
  //   if (_formKey.currentState!.validate()) {
  //     setState(() {
  //       _errorMessage = null; // Сброс ошибки перед запросом
  //     });

  //     Map<String, String> deviceInfo = await getDeviceInfo();

  //     try {
  //       final status = await widget.authModule.authService.logIn(
  //         username: _emailController.text,
  //         password: _passwordController.text,
  //         cloudMessageToken: '',
  //         deviceType: deviceInfo['deviceType'] ?? '',
  //         authUrl: 'http://109.196.101.63:8000/api/login/',
  //         deviceId: deviceInfo['deviceId'] ?? '',
  //       );

  //       if (status == AuthStatus.authorized) {
  //         final prefs = await SharedPreferences.getInstance();
  //         await prefs.setBool('is_registered', true);
  //         await prefs.setString('user_email', _emailController.text);
  //         if (mounted) {
  //           BlocProvider.of<ScreenStateBloc>(context).add(LoadServerList());
  //           context.go('/');
  //         }
  //       } else if (status == AuthStatus.unauthorized) {
  //         setState(() {
  //           _errorMessage = 'Неверный пароль'; // Установка сообщения об ошибке
  //         });
  //       }
  //     } catch (e) {
  //       setState(() {
  //         _errorMessage = e.toString(); // Установка сообщения об ошибке
  //       });
  //     }
  //   }
  // }

  void _toggleMode() {
    setState(() {
      _isLoginMode = !_isLoginMode;
      _errorMessage = null; // Сброс ошибки при переключении режима
    });
  }

  void _togglePasswordVisibility() {
    setState(() {
      _obscurePassword = !_obscurePassword;
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

  OutlineInputBorder _buildBorder(Color color) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(
        color: color,
        width: 1.5,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Scaffold(
      appBar: AppBar(
        title: AnimatedTextKit(
          animatedTexts: [
            TyperAnimatedText(
              _isLoginMode ? 'Добро пожаловать обратно!' : 'Создайте аккаунт',
              textStyle: textTheme.bodyLarge?.copyWith(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: colorScheme.onPrimary,
              ),
              speed: Duration(milliseconds: 50),
            ),
          ],
          isRepeatingAnimation: true,
        ),
        centerTitle: true,
        backgroundColor: colorScheme.primary,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              theme.primaryColor,
              theme.cardColor,
            ],
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
                    if (_errorMessage != null) // Отображение ошибки
                      Padding(
                        padding: EdgeInsets.only(bottom: 20),
                        child: Text(
                          _errorMessage!,
                          style: textTheme.bodyMedium?.copyWith(
                            color: Colors.red,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    SizedBox(height: 20),
                    TextFormField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        prefixIcon:
                            Icon(Iconsax.sms, color: colorScheme.onSurface),
                        border: _buildBorder(colorScheme.outline),
                        enabledBorder: _buildBorder(colorScheme.outline),
                        focusedBorder: _buildBorder(colorScheme.onPrimary),
                        errorBorder: _buildBorder(colorScheme.error),
                        focusedErrorBorder: _buildBorder(colorScheme.error),
                        filled: true,
                        fillColor: colorScheme.surface,
                        floatingLabelStyle:
                            TextStyle(color: colorScheme.onPrimary),
                        labelStyle: TextStyle(
                            color: colorScheme.onSurface.withOpacity(0.7)),
                        contentPadding:
                            EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                      ),
                      style: textTheme.bodyLarge
                          ?.copyWith(color: colorScheme.onSurface),
                      cursorColor: colorScheme.primary,
                      validator: _validateEmail,
                    ),
                    SizedBox(height: 20),
                    TextFormField(
                      controller: _passwordController,
                      decoration: InputDecoration(
                        labelText: 'Пароль',
                        prefixIcon:
                            Icon(Iconsax.lock, color: colorScheme.onSurface),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword ? Iconsax.eye : Iconsax.eye_slash,
                            color: _obscurePassword
                                ? colorScheme.onSurface.withOpacity(0.5)
                                : colorScheme.primary,
                          ),
                          onPressed: _togglePasswordVisibility,
                        ),
                        border: _buildBorder(colorScheme.outline),
                        enabledBorder: _buildBorder(colorScheme.outline),
                        focusedBorder: _buildBorder(colorScheme.onPrimary),
                        errorBorder: _buildBorder(colorScheme.error),
                        focusedErrorBorder: _buildBorder(colorScheme.error),
                        filled: true,
                        fillColor: colorScheme.surface,
                        floatingLabelStyle:
                            TextStyle(color: colorScheme.onPrimary),
                        labelStyle: TextStyle(
                            color: colorScheme.onSurface.withOpacity(0.7)),
                        contentPadding:
                            EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                      ),
                      obscureText:
                          _obscurePassword, // Используем состояние здесь
                      style: textTheme.bodyLarge
                          ?.copyWith(color: colorScheme.onSurface),
                      cursorColor: colorScheme.primary,
                      validator: _validatePassword,
                    ),
                    if (!_isLoginMode) ...[
                      SizedBox(height: 20),
                      TextFormField(
                        controller: _confirmPasswordController,
                        decoration: InputDecoration(
                          labelText: 'Повторите пароль',
                          prefixIcon: Icon(Iconsax.lock_1,
                              color: colorScheme.onSurface),
                          border: _buildBorder(colorScheme.outline),
                          enabledBorder: _buildBorder(colorScheme.outline),
                          focusedBorder: _buildBorder(colorScheme.onPrimary),
                          errorBorder: _buildBorder(colorScheme.error),
                          focusedErrorBorder: _buildBorder(colorScheme.error),
                          filled: true,
                          fillColor: colorScheme.surface,
                          floatingLabelStyle:
                              TextStyle(color: colorScheme.onPrimary),
                          labelStyle: TextStyle(
                              color: colorScheme.onSurface.withOpacity(0.7)),
                          contentPadding: EdgeInsets.symmetric(
                              vertical: 16, horizontal: 20),
                        ),
                        obscureText: true,
                        style: textTheme.bodyLarge
                            ?.copyWith(color: colorScheme.onSurface),
                        cursorColor: colorScheme.primary,
                        validator: _validateConfirmPassword,
                      ),
                      SizedBox(height: 20),
                      TextFormField(
                        controller: _inviteCodeController,
                        decoration: InputDecoration(
                          labelText: 'Инвайт код',
                          prefixIcon:
                              Icon(Iconsax.gift, color: colorScheme.onSurface),
                          border: _buildBorder(colorScheme.outline),
                          enabledBorder: _buildBorder(colorScheme.outline),
                          focusedBorder: _buildBorder(colorScheme.onPrimary),
                          errorBorder: _buildBorder(colorScheme.error),
                          focusedErrorBorder: _buildBorder(colorScheme.error),
                          filled: true,
                          fillColor: colorScheme.surface,
                          floatingLabelStyle:
                              TextStyle(color: colorScheme.onPrimary),
                          labelStyle: TextStyle(
                              color: colorScheme.onSurface.withOpacity(0.7)),
                          contentPadding: EdgeInsets.symmetric(
                              vertical: 16, horizontal: 20),
                        ),
                        keyboardType: TextInputType.number,
                        style: textTheme.bodyLarge
                            ?.copyWith(color: colorScheme.onSurface),
                        cursorColor: colorScheme.primary,
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
                        style: textTheme.bodyLarge?.copyWith(
                          color: colorScheme.onPrimary,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        padding:
                            EdgeInsets.symmetric(vertical: 15, horizontal: 30),
                        backgroundColor: colorScheme.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30.0),
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: _toggleMode,
                      child: Text(
                        _isLoginMode ? 'Создать аккаунт' : 'Уже есть аккаунт',
                        style: textTheme.bodyMedium?.copyWith(),
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
