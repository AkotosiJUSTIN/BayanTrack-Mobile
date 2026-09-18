import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';

enum ToastType { success, error, warning, info }

/// Central feedback surface for lightweight updates and recoverable errors.
///
/// One top-positioned overlay replaces the current message so feedback stays
/// visible without competing with bottom navigation, the FAB, or the keyboard.
/// Warnings and actionable errors persist until the citizen dismisses them;
/// other errors are transient.
class AppToast {
  AppToast._();

  static OverlayEntry? _currentEntry;

  static void success(BuildContext context, String message) {
    _show(context, message, ToastType.success);
  }

  static void error(
    BuildContext context,
    String message, {
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    _show(
      context,
      message,
      ToastType.error,
      persist: actionLabel != null,
      actionLabel: actionLabel,
      onAction: onAction,
    );
  }

  static void warning(BuildContext context, String message) {
    _show(context, message, ToastType.warning, persist: true);
  }

  static void info(BuildContext context, String message) {
    _show(context, message, ToastType.info);
  }

  static void _show(
    BuildContext context,
    String message,
    ToastType type, {
    Duration duration = const Duration(seconds: 3),
    bool persist = false,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    if (!context.mounted || message.trim().isEmpty) return;

    final overlay = Overlay.maybeOf(context, rootOverlay: true);
    if (overlay == null) return;

    final previous = _currentEntry;
    if (previous != null) _remove(previous);

    late final OverlayEntry entry;
    entry = OverlayEntry(
      builder: (_) => _ToastOverlay(
        message: message,
        type: type,
        duration: persist ? null : duration,
        actionLabel: actionLabel,
        onAction: onAction,
        onDismissed: () => _remove(entry),
      ),
    );
    _currentEntry = entry;
    overlay.insert(entry);
  }

  static void _remove(OverlayEntry entry) {
    if (identical(_currentEntry, entry)) _currentEntry = null;
    if (entry.mounted) {
      entry.remove();
      entry.dispose();
    }
  }

  static _ToastColors _colors(ColorScheme scheme, ToastType type) {
    final isDark = scheme.brightness == Brightness.dark;
    return switch (type) {
      ToastType.success => _ToastColors(
        background: isDark ? AppColors.resolvedBgDark : AppColors.resolvedBg,
        foreground: isDark
            ? AppColors.resolvedTextDark
            : AppColors.resolvedText,
        border: (isDark ? AppColors.resolvedTextDark : AppColors.resolvedText)
            .withValues(alpha: 0.28),
        icon: Icons.check_circle_outline,
      ),
      ToastType.error => _ToastColors(
        background: scheme.errorContainer,
        foreground: scheme.onErrorContainer,
        border: scheme.error.withValues(alpha: 0.28),
        icon: Icons.error_outline,
      ),
      ToastType.warning => _ToastColors(
        background: isDark ? AppColors.pendingBgDark : AppColors.pendingBg,
        foreground: isDark ? AppColors.pendingTextDark : AppColors.pendingText,
        border: (isDark ? AppColors.pendingTextDark : AppColors.pendingText)
            .withValues(alpha: 0.28),
        icon: Icons.warning_amber_outlined,
      ),
      ToastType.info => _ToastColors(
        background: scheme.primaryContainer,
        foreground: scheme.onPrimaryContainer,
        border: scheme.primary.withValues(alpha: 0.28),
        icon: Icons.info_outline,
      ),
    };
  }
}

class _ToastColors {
  const _ToastColors({
    required this.background,
    required this.foreground,
    required this.border,
    required this.icon,
  });

  final Color background;
  final Color foreground;
  final Color border;
  final IconData icon;
}

class _ToastOverlay extends StatefulWidget {
  const _ToastOverlay({
    required this.message,
    required this.type,
    required this.duration,
    required this.onDismissed,
    this.actionLabel,
    this.onAction,
  });

  final String message;
  final ToastType type;
  final Duration? duration;
  final String? actionLabel;
  final VoidCallback? onAction;
  final VoidCallback onDismissed;

  @override
  State<_ToastOverlay> createState() => _ToastOverlayState();
}

class _ToastOverlayState extends State<_ToastOverlay>
    with TickerProviderStateMixin {
  late final AnimationController _entryAnimation;
  AnimationController? _timer;
  double _dragOffset = 0;
  bool _isDismissing = false;

  @override
  void initState() {
    super.initState();
    _entryAnimation = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 180),
    )..forward();

    if (widget.duration != null) {
      _timer = AnimationController(vsync: this, duration: widget.duration)
        ..addStatusListener(_onTimerStatus)
        ..forward();
    }
  }

  @override
  void dispose() {
    _timer?.dispose();
    _entryAnimation.dispose();
    super.dispose();
  }

  void _onTimerStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed) _dismiss();
  }

  void _pause() => _timer?.stop();

  void _resume() {
    final timer = _timer;
    if (timer != null && !timer.isCompleted && !_isDismissing) {
      timer.forward();
    }
  }

  Future<void> _dismiss() async {
    if (_isDismissing) return;
    _isDismissing = true;
    _timer?.stop();
    try {
      await _entryAnimation.reverse();
    } on TickerCanceled {
      return;
    }
    if (mounted) widget.onDismissed();
  }

  void _runAction() {
    widget.onAction?.call();
    if (mounted) _dismiss();
  }

  void _onDragUpdate(DragUpdateDetails details) {
    setState(() {
      _dragOffset = (_dragOffset + details.delta.dx)
          .clamp(-240.0, 240.0)
          .toDouble();
    });
  }

  void _onDragEnd(DragEndDetails details) {
    final velocity = details.primaryVelocity ?? 0;
    if (_dragOffset.abs() >= 96 || velocity.abs() >= 700) {
      _dismiss();
      return;
    }
    setState(() => _dragOffset = 0);
    _resume();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = AppToast._colors(theme.colorScheme, widget.type);
    final animation = CurvedAnimation(
      parent: _entryAnimation,
      curve: Curves.easeOutCubic,
    );

    return Positioned(
      top: MediaQuery.paddingOf(context).top + 8,
      left: 0,
      right: 0,
      child: Align(
        alignment: Alignment.topCenter,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: SizedBox(
              width: double.infinity,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, -0.12),
                  end: Offset.zero,
                ).animate(animation),
                child: FadeTransition(
                  opacity: animation,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 160),
                    curve: Curves.easeOut,
                    transform: Matrix4.translationValues(_dragOffset, 0, 0),
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onHorizontalDragStart: (_) => _pause(),
                      onHorizontalDragUpdate: _onDragUpdate,
                      onHorizontalDragEnd: _onDragEnd,
                      onHorizontalDragCancel: () {
                        setState(() => _dragOffset = 0);
                        _resume();
                      },
                      child: Focus(
                        onFocusChange: (hasFocus) =>
                            hasFocus ? _pause() : _resume(),
                        child: Listener(
                          onPointerDown: (_) => _pause(),
                          onPointerUp: (_) => _resume(),
                          onPointerCancel: (_) => _resume(),
                          child: _buildCard(context, theme, colors),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCard(
    BuildContext context,
    ThemeData theme,
    _ToastColors colors,
  ) {
    final isDark = theme.brightness == Brightness.dark;
    final radius = BorderRadius.circular(16);

    return Material(
      color: colors.background,
      elevation: isDark ? 0 : 3,
      shadowColor: theme.colorScheme.shadow.withValues(
        alpha: isDark ? 0 : 0.14,
      ),
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: radius,
        side: BorderSide(color: colors.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: Semantics(
        container: true,
        liveRegion: true,
        label: widget.message,
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            14,
            12,
            widget.duration == null ? 4 : 14,
            widget.actionLabel == null ? 12 : 4,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: ExcludeSemantics(
                      child: Icon(
                        colors.icon,
                        color: colors.foreground,
                        size: 22,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ExcludeSemantics(
                      child: Text(
                        widget.message,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colors.foreground,
                          fontWeight: FontWeight.w600,
                          height: 1.3,
                        ),
                      ),
                    ),
                  ),
                  if (widget.duration == null)
                    IconButton(
                      onPressed: _dismiss,
                      tooltip: MaterialLocalizations.of(
                        context,
                      ).closeButtonTooltip,
                      icon: Icon(
                        Icons.close,
                        color: colors.foreground,
                        size: 20,
                      ),
                      visualDensity: VisualDensity.compact,
                      constraints: const BoxConstraints(
                        minWidth: 48,
                        minHeight: 48,
                      ),
                    ),
                ],
              ),
              if (widget.actionLabel != null)
                Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: TextButton(
                    onPressed: _runAction,
                    style: TextButton.styleFrom(
                      foregroundColor: colors.foreground,
                      minimumSize: const Size(0, 48),
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                    ),
                    child: Text(widget.actionLabel!),
                  ),
                ),
              if (_timer != null) ...[
                const SizedBox(height: 8),
                ExcludeSemantics(
                  child: AnimatedBuilder(
                    animation: _timer!,
                    builder: (context, _) => ClipRRect(
                      borderRadius: BorderRadius.circular(2),
                      child: LinearProgressIndicator(
                        value: 1 - _timer!.value,
                        minHeight: 3,
                        backgroundColor: colors.foreground.withValues(
                          alpha: 0.18,
                        ),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          colors.foreground.withValues(alpha: 0.72),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
