import 'package:flutter_test/flutter_test.dart';

import 'package:skinbuddy/main.dart';

void main() {
  testWidgets('App launches successfully', (WidgetTester tester) async {
    await tester.pumpWidget(const SkinBuddyApp());
    expect(find.text('SkinBuddy'), findsOneWidget);
  });
}
