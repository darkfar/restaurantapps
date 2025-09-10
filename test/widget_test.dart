

import 'package:flutter_test/flutter_test.dart';
import 'package:restaurant_app/main.dart';

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {

    await tester.pumpWidget(const MyApp());


    expect(find.text('Restaurant App'), findsOneWidget);


  });
}