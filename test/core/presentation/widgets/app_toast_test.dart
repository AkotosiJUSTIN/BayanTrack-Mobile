import 'package:bayantrack_mobile/core/presentation/widgets/app_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget host() {
    return MaterialApp(
      home: Scaffold(
        body: Builder(
          builder: (context) => TextButton(
            key: const ValueKey('toast-host'),
            onPressed: () => AppToast.success(context, 'Saved'),
            child: const Text('Show toast'),
          ),
        ),
      ),
    );
  }

  testWidgets(
    'toast replaces current feedback and supports top swipe dismiss',
    (tester) async {
      await tester.pumpWidget(host());
      final context = tester.element(find.byKey(const ValueKey('toast-host')));

      AppToast.success(context, 'Saved');
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('Saved'), findsOneWidget);
      expect(find.byType(LinearProgressIndicator), findsOneWidget);

      AppToast.info(context, 'Updated');
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('Saved'), findsNothing);
      expect(find.text('Updated'), findsOneWidget);
      expect(tester.getTopLeft(find.text('Updated')).dy, lessThan(150));

      await tester.drag(find.text('Updated'), const Offset(-260, 0));
      await tester.pumpAndSettle();
      expect(find.text('Updated'), findsNothing);
    },
  );

  testWidgets('transient toast pauses while a gesture is active', (
    tester,
  ) async {
    await tester.pumpWidget(host());
    final context = tester.element(find.byKey(const ValueKey('toast-host')));

    AppToast.info(context, 'Hold this update');
    await tester.pump(const Duration(milliseconds: 300));

    final gesture = await tester.startGesture(
      tester.getCenter(find.text('Hold this update')),
    );
    await tester.pump(const Duration(seconds: 4));
    expect(find.text('Hold this update'), findsOneWidget);

    await gesture.up();
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();
    expect(find.text('Hold this update'), findsNothing);
  });

  testWidgets('transient toast auto-dismisses but errors persist', (
    tester,
  ) async {
    await tester.pumpWidget(host());
    final context = tester.element(find.byKey(const ValueKey('toast-host')));

    AppToast.success(context, 'Saved');
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();
    expect(find.text('Saved'), findsNothing);

    AppToast.warning(context, 'Complete required fields');
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pump(const Duration(seconds: 4));
    expect(find.text('Complete required fields'), findsOneWidget);
    await tester.tap(find.byIcon(Icons.close));
    await tester.pumpAndSettle();

    AppToast.error(context, 'Could not save');
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pump(const Duration(seconds: 5));
    expect(find.text('Could not save'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.close));
    await tester.pumpAndSettle();
    expect(find.text('Could not save'), findsNothing);
  });
}
