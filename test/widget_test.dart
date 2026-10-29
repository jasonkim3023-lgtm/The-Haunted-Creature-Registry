import 'package:flutter_test/flutter_test.dart';
import 'package:inclass10/main.dart';

void main() {
  testWidgets('Foyer shows the enter button', (tester) async {
    await tester.pumpWidget(const HauntedMansionApp());
    expect(find.text('Enter the Registry'), findsOneWidget);
  });
}
