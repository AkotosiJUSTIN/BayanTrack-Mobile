import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/backend_reachability_provider.dart';

final sessionRouteObserver = RouteObserver<ModalRoute<void>>();

/// Refresh retained content when its route becomes visible or reconnects.
class SessionScreenLifecycle extends ConsumerStatefulWidget {
  const SessionScreenLifecycle({
    super.key,
    required this.child,
    required this.onVisible,
    this.onHidden,
  });
  final Widget child;
  final VoidCallback onVisible;
  final VoidCallback? onHidden;
  @override
  ConsumerState<SessionScreenLifecycle> createState() =>
      _SessionScreenLifecycleState();
}

class _SessionScreenLifecycleState extends ConsumerState<SessionScreenLifecycle>
    with WidgetsBindingObserver, RouteAware {
  ModalRoute<void>? _route;
  bool get _resumed =>
      WidgetsBinding.instance.lifecycleState == null ||
      WidgetsBinding.instance.lifecycleState == AppLifecycleState.resumed;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route != _route) {
      sessionRouteObserver.unsubscribe(this);
      _route = route;
      if (route != null) sessionRouteObserver.subscribe(this, route);
    }
  }

  @override
  void didPopNext() {
    if (_resumed) widget.onVisible();
  }

  @override
  void didPushNext() => widget.onHidden?.call();
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && _route?.isCurrent != false) {
      widget.onVisible();
    } else {
      widget.onHidden?.call();
    }
  }

  @override
  void dispose() {
    sessionRouteObserver.unsubscribe(this);
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(backendReachabilityProvider, (previous, next) {
      if (previous == BackendReachability.unreachable &&
          next == BackendReachability.reachable &&
          _route?.isCurrent != false &&
          _resumed) {
        widget.onVisible();
      }
    });
    return widget.child;
  }
}
