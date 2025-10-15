import 'package:flutter_test/flutter_test.dart';
import 'package:rnm_app/app.dart'; 

void main() {
  testWidgets('app builds', (tester) async {
    await tester.pumpWidget(const MyApp());
    expect(find.text('Rick & Morty'), findsOneWidget);
  });
}