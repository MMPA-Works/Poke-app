import 'package:flutter_test/flutter_test.dart';

import 'package:haumonsters/main.dart';

void main() {
  testWidgets('dashboard loads successfully', (WidgetTester tester) async {
    await tester.pumpWidget(const HAUMonstersApp());

    expect(find.text('Monster Control Center'), findsOneWidget);
    expect(find.text('Add Monsters'), findsOneWidget);
    expect(find.text('Show Monster Map'), findsOneWidget);
  });
}
