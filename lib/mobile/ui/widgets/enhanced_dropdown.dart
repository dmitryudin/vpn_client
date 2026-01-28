import 'package:flutter/material.dart';

/// Улучшенный dropdown с современным дизайном
class EnhancedDropdown<T> extends StatefulWidget {
  final T? value;
  final List<T> items;
  final String Function(T)? itemBuilder;
  final void Function(T?)? onChanged;
  final String? label;
  final String? hint;
  final IconData? icon;

  const EnhancedDropdown({
    Key? key,
    required this.value,
    required this.items,
    this.itemBuilder,
    this.onChanged,
    this.label,
    this.hint,
    this.icon,
  }) : super(key: key);

  @override
  State<EnhancedDropdown<T>> createState() => _EnhancedDropdownState<T>();
}

class _EnhancedDropdownState<T> extends State<EnhancedDropdown<T>>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.98).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) => _controller.reverse(),
      onTapCancel: () => _controller.reverse(),
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: child,
          );
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: colorScheme.outline.withOpacity(0.2),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: colorScheme.primary.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              if (widget.icon != null) ...[
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    widget.icon,
                    color: colorScheme.primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (widget.label != null) ...[
                      Text(
                        widget.label!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 4),
                    ],
                    DropdownButtonHideUnderline(
                      child: DropdownButton<T>(
                        value: widget.value,
                        isExpanded: true,
                        items: widget.items.map((T item) {
                          return DropdownMenuItem<T>(
                            value: item,
                            child: Text(
                              widget.itemBuilder != null
                                  ? widget.itemBuilder!(item)
                                  : item.toString(),
                              style: theme.textTheme.bodyLarge?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: colorScheme.onSurface,
                              ),
                            ),
                          );
                        }).toList(),
                        onChanged: widget.onChanged,
                        hint: widget.hint != null
                            ? Text(
                                widget.hint!,
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              )
                            : null,
                        icon: Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: colorScheme.primary,
                        ),
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: colorScheme.onSurface,
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
