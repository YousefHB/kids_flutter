import 'package:flutter_test/flutter_test.dart';
import 'package:letterquest_kids/main.dart';

void main() {
  testWidgets('App launches without error', (WidgetTester tester) async {
    await tester.pumpWidget(const LetterQuestApp());
    expect(find.byType(LetterQuestApp), findsOneWidget);
  });
}
