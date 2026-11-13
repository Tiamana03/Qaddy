import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qaddy/core/theme/qaddy_theme.dart';
import 'package:qaddy/core/user/sample_clubhouse.dart';
import 'package:qaddy/features/courses/state/course_providers.dart';
import 'package:qaddy/features/courses/ui/course_picker_sheet.dart';

import '../../support/app_test_harness.dart';
import '../../support/fake_course_data.dart';
import '../../support/sample_off.dart';

Future<ProviderContainer> _open(
  WidgetTester tester, {
  List<Override> overrides = const <Override>[],
}) async {
  useScreen(tester, const Size(400, 900));
  final container = friendsContainer(overrides: overrides);
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        theme: QaddyTheme.dark,
        home: Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () => showCoursePicker(context),
              child: const Text('Pick'),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.text('Pick'));
  await tester.pumpAndSettle();
  return container;
}

void main() {
  tearDown(resetSampleClubhouseForTests);

  testWidgets('says so when no course database is connected', (tester) async {
    await _open(tester, overrides: sampleOff());

    expect(find.text('Course search is not connected yet'), findsOneWidget);
    // Nothing to search, so no search box.
    expect(find.byType(TextField), findsNothing);
    expect(find.textContaining('standard layout'), findsWidgets);
  });

  testWidgets('lists what the catalogue returns, with a logo slot', (
    tester,
  ) async {
    await _open(tester, overrides: fakeCourseData());

    expect(find.text('Test Links'), findsOneWidget);
    expect(find.text('Testville, TS · 2 holes · 4.2 km'), findsOneWidget);
    expect(find.byType(CourseRow), findsOneWidget);
  });

  testWidgets('searches as you type', (tester) async {
    final catalogue = FakeCatalogue();
    await _open(tester, overrides: fakeCourseData(catalogue: catalogue));

    await tester.enterText(find.byType(TextField), 'zzz');
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pumpAndSettle();

    expect(catalogue.queries, contains('zzz'));
    expect(find.text('No courses match'), findsOneWidget);
    expect(find.text('Test Links'), findsNothing);
  });

  testWidgets('choosing a course picks it for the next round', (tester) async {
    final container = await _open(tester, overrides: fakeCourseData());

    await tester.tap(find.text('Test Links'));
    await tester.pumpAndSettle();

    expect(container.read(selectedCourseProvider)?.id, 'fake-1');
    expect(container.read(nextRoundCourseProvider).name, 'Test Links');
    expect(find.text('Choose your course'), findsNothing);
  });

  testWidgets('the standard layout clears the choice', (tester) async {
    final container = await _open(tester, overrides: fakeCourseData());
    container.read(selectedCourseProvider.notifier).choose(fakeCourse);

    await tester.tap(find.textContaining('Use the standard layout'));
    await tester.pumpAndSettle();

    expect(container.read(selectedCourseProvider), isNull);
  });

  testWidgets('an unreachable provider is explained, and can be retried', (
    tester,
  ) async {
    final catalogue = FakeCatalogue(fails: true);
    await _open(tester, overrides: fakeCourseData(catalogue: catalogue));

    expect(find.text("Couldn't reach the course database"), findsOneWidget);

    catalogue.fails = false;
    await tester.tap(find.text('Try again'));
    await tester.pumpAndSettle();

    expect(find.text('Test Links'), findsOneWidget);
  });
}
