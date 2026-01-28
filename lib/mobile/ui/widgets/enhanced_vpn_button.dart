import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_vpn/state.dart';
import 'package:vpn/mobile/utils/vpn_bloc/vpn_bloc.dart';
import 'package:vpn/mobile/utils/vpn_bloc/vpn_event.dart';
import 'package:vpn/mobile/utils/vpn_bloc/vpn_state.dart';
import 'package:haptic_feedback/haptic_feedback.dart';
import 'package:vibration/vibration.dart';

/// Улучшенная VPN кнопка с современным UX
class EnhancedVpnButton extends StatefulWidget {
  const EnhancedVpnButton({Key? key}) : super(key: key);

  @override
  State<EnhancedVpnButton> createState() => _EnhancedVpnButtonState();
}

class _EnhancedVpnButtonState extends State<EnhancedVpnButton>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _scaleController;
  late AnimationController _rotationController;
  
  late Animation<double> _pulseAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;
  
  FlutterVpnState? _previousState;

  @override
  void initState() {
    super.initState();
    
    // Анимация пульсации для подключенного состояния
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _pulseAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    
    // Анимация масштабирования при нажатии
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeInOut),
    );
    
    // Анимация вращения для состояния подключения
    _rotationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    
    _rotationAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _rotationController, curve: Curves.linear),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _scaleController.dispose();
    _rotationController.dispose();
    super.dispose();
  }
  
  void _handleStateChange(FlutterVpnState newState) {
    if (_previousState == newState) return;
    
    // Управление анимациями в зависимости от состояния
    switch (newState) {
      case FlutterVpnState.connected:
        // Плавно останавливаем вращение и запускаем пульсацию
        _rotationController.stop();
        Future.delayed(const Duration(milliseconds: 100), () {
          if (mounted) {
            _pulseController.repeat(reverse: true);
          }
        });
        break;
      case FlutterVpnState.connecting:
        // Запускаем пульсацию и вращение одновременно
        _pulseController.repeat(reverse: true);
        _rotationController.repeat();
        break;
      case FlutterVpnState.disconnected:
        // Плавно останавливаем все анимации
        _pulseController.stop();
        _rotationController.stop();
        // Плавно сбрасываем пульсацию
        _pulseController.animateTo(
          0.0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
        break;
      default:
        _pulseController.stop();
        _rotationController.stop();
    }
    
    _previousState = newState;
  }

  void _handleTapDown(TapDownDetails details) {
    _scaleController.forward();
    _triggerHapticFeedback(HapticsType.light);
  }

  void _handleTapUp(TapUpDetails details) {
    _scaleController.reverse();
  }

  void _handleTapCancel() {
    _scaleController.reverse();
  }

  Future<void> _triggerHapticFeedback(HapticsType type) async {
    if (await Haptics.canVibrate()) {
      if (Platform.isIOS) {
        await Haptics.vibrate(type);
      } else {
        Vibration.vibrate(duration: 50);
      }
    }
  }

  Widget _buildButtonContent(FlutterVpnState state, BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    Widget content;
    
    switch (state) {
      case FlutterVpnState.disconnected:
        content = Container(
          width: 200,
          height: 200,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                colorScheme.surfaceVariant,
                colorScheme.surface,
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: colorScheme.primary.withOpacity(0.1),
                blurRadius: 20,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Icon(
            Icons.power_settings_new_rounded,
            size: 80,
            color: colorScheme.primary,
          ),
        );
        break;
        
      case FlutterVpnState.connecting:
        content = AnimatedBuilder(
          animation: Listenable.merge([_pulseAnimation, _rotationAnimation]),
          builder: (context, child) {
            return Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    colorScheme.primary,
                    colorScheme.primary.withOpacity(0.8),
                  ],
                ),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Пульсирующие концентрические круги
                  ...List.generate(3, (index) {
                    final delay = index * 0.3;
                    final animationValue = ((_pulseAnimation.value + delay) % 1.0);
                    final scale = 0.6 + (animationValue * 0.4);
                    final opacity = 1.0 - animationValue;
                    
                    return Transform.scale(
                      scale: scale,
                      child: Container(
                        width: 200,
                        height: 200,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: colorScheme.onPrimary.withOpacity(opacity * 0.5),
                            width: 2,
                          ),
                        ),
                      ),
                    );
                  }),
                  
                  // Вращающийся градиентный круг
                  Transform.rotate(
                    angle: _rotationAnimation.value * 2 * 3.14159,
                    child: Container(
                      width: 180,
                      height: 180,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: SweepGradient(
                          colors: [
                            colorScheme.onPrimary.withOpacity(0.3),
                            colorScheme.onPrimary.withOpacity(0.0),
                            colorScheme.onPrimary.withOpacity(0.0),
                            colorScheme.onPrimary.withOpacity(0.3),
                          ],
                          stops: const [0.0, 0.25, 0.75, 1.0],
                        ),
                      ),
                    ),
                  ),
                  
                  // Центральная иконка
                  Container(
                    width: 140,
                    height: 140,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: colorScheme.primary,
                    ),
                    child: Icon(
                      Icons.vpn_key_rounded,
                      size: 60,
                      color: colorScheme.onPrimary,
                    ),
                  ),
                ],
              ),
            );
          },
        );
        break;
        
      case FlutterVpnState.connected:
        content = AnimatedBuilder(
          animation: _pulseAnimation,
          builder: (context, child) {
            return Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    colorScheme.primary,
                    colorScheme.primary.withOpacity(0.8),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: colorScheme.primary.withOpacity(
                      0.3 + (_pulseAnimation.value * 0.3),
                    ),
                    blurRadius: 30 + (_pulseAnimation.value * 20),
                    spreadRadius: 5 + (_pulseAnimation.value * 5),
                  ),
                ],
              ),
              child: Icon(
                Icons.check_circle_rounded,
                size: 80,
                color: colorScheme.onPrimary,
              ),
            );
          },
        );
        break;
        
      default:
        content = const SizedBox.shrink();
    }
    
    return content;
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<VpnBloc, VpnState>(
      listener: (context, state) {
        final newState = state.connectionState;
        
        // Управляем анимациями при изменении состояния
        if (_previousState != newState) {
          _handleStateChange(newState);
        }
        
        // Haptic feedback
        if (newState == FlutterVpnState.connected) {
          _triggerHapticFeedback(HapticsType.success);
        } else if (newState == FlutterVpnState.disconnected && 
                   _previousState == FlutterVpnState.connected) {
          _triggerHapticFeedback(HapticsType.medium);
        }
      },
      child: BlocBuilder<VpnBloc, VpnState>(
        builder: (context, state) {
          final connectionState = state.connectionState;
          
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Кнопка с анимациями
              GestureDetector(
                onTapDown: _handleTapDown,
                onTapUp: _handleTapUp,
                onTapCancel: _handleTapCancel,
                onTap: () {
                  if (connectionState == FlutterVpnState.disconnected) {
                    context.read<VpnBloc>().add(ConnectVpn());
                  } else {
                    context.read<VpnBloc>().add(DisconnectVpn());
                  }
                },
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 400),
                  transitionBuilder: (child, animation) {
                    return ScaleTransition(
                      scale: animation,
                      child: FadeTransition(
                        opacity: animation,
                        child: child,
                      ),
                    );
                  },
                  child: AnimatedBuilder(
                    key: ValueKey(connectionState),
                    animation: _scaleAnimation,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _scaleAnimation.value,
                        child: _buildButtonContent(connectionState, context),
                      );
                    },
                  ),
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Статус с плавной анимацией
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (child, animation) {
                  return FadeTransition(
                    opacity: animation,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0, 0.1),
                        end: Offset.zero,
                      ).animate(animation),
                      child: child,
                    ),
                  );
                },
                child: Text(
                  state.status,
                  key: ValueKey(state.status),
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ),
              
              const SizedBox(height: 12),
              
              // Дополнительная информация о состоянии
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: _buildStatusSubtitle(connectionState, context),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStatusSubtitle(FlutterVpnState state, BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    
    switch (state) {
      case FlutterVpnState.connected:
        return Text(
          'Ваше соединение защищено',
          key: const ValueKey('connected'),
          style: textTheme.bodyMedium?.copyWith(
            color: colorScheme.primary,
            fontWeight: FontWeight.w500,
          ),
        );
      case FlutterVpnState.connecting:
        return Text(
          'Подключение...',
          key: const ValueKey('connecting'),
          style: textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w500,
          ),
        );
      default:
        return Text(
          'Нажмите для подключения',
          key: const ValueKey('disconnected'),
          style: textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        );
    }
  }
}
