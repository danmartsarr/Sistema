import 'package:flutter_test/flutter_test.dart';
import 'package:deepmicroplastic/main.dart';

void main() {
  testWidgets('App boots without crashing', (WidgetTester tester) async {
    await tester.pumpWidget(const RaviApp());
    expect(find.text('RAVI'), findsWidgets);
  });
}
