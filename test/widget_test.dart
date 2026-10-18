import 'package:flutter_test/flutter_test.dart';
import 'package:autodeck_rebuild/main.dart';

void main() {
  testWidgets('shows Mosya Deck Auto dashboard', (tester) async {
    await tester.pumpWidget(const AutoDeckApp());
    expect(find.text('AUTODECK'), findsOneWidget);
    expect(find.text('Android Auto'), findsOneWidget);
    expect(find.text('Salam pembukaan'), findsOneWidget);
  });
}
