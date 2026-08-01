import 'package:flutter_test/flutter_test.dart';
import 'package:peer_chess/main.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  testWidgets('App initializes and renders Home Screen', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: PeerChessApp()));
    expect(find.text('PEER CHESS'), findsOneWidget);
  });
}
