import 'package:bayantrack_mobile/core/presentation/widgets/session_screen_lifecycle.dart';
import 'package:bayantrack_mobile/core/providers/backend_reachability_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class Reachability extends BackendReachabilityNotifier {
  @override
  BackendReachability build() => BackendReachability.unreachable;
  void reachable() => state = BackendReachability.reachable;
}

void main() {
  testWidgets(
    'reconnect while backgrounded cannot restart screen work; resume refreshes',
    (tester) async {
      var visible = 0;
      var hidden = 0;
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            backendReachabilityProvider.overrideWith(Reachability.new),
          ],
          child: MaterialApp(
            home: SessionScreenLifecycle(
              onVisible: () => visible++,
              onHidden: () => hidden++,
              child: const Text('screen'),
            ),
          ),
        ),
      );
      final c = ProviderScope.containerOf(
        tester.element(find.byType(SessionScreenLifecycle)),
      );
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
      (c.read(backendReachabilityProvider.notifier) as Reachability)
          .reachable();
      await tester.pump();
      expect(visible, 0);
      expect(hidden, greaterThan(0));
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pump();
      expect(visible, 1);
    },
  );
  testWidgets('covering route pauses work and popping it refreshes', (
    tester,
  ) async {
    var visible = 0;
    var hidden = 0;
    await tester.pumpWidget(
      ProviderScope(
        overrides: [backendReachabilityProvider.overrideWith(Reachability.new)],
        child: MaterialApp(
          navigatorObservers: [sessionRouteObserver],
          home: SessionScreenLifecycle(
            onVisible: () => visible++,
            onHidden: () => hidden++,
            child: const Text('screen'),
          ),
        ),
      ),
    );
    final nav = Navigator.of(tester.element(find.text('screen')));
    nav.push(MaterialPageRoute<void>(builder: (_) => const Text('covered')));
    await tester.pumpAndSettle();
    expect(hidden, 1);
    nav.pop();
    await tester.pumpAndSettle();
    expect(visible, 1);
  });
}
