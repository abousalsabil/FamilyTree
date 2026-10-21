import 'package:flutter_test/flutter_test.dart';
import 'package:family_tree_app/main.dart';

void main() {
  testWidgets('FamilyTreeApp smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const FamilyTreeApp());
    expect(find.text('شجرة العائلة (تطوير تفاعلي)'), findsOneWidget);
  });
}
