import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:iraq_edu_app/main.dart';

void main() {
  testWidgets('App boots and renders the home screen with Arabic title', (
    tester,
  ) async {
    await tester.pumpWidget(const ProviderScope(child: IraqEduApp()));
    // Allow the router to settle.
    await tester.pump();

    expect(find.text('منصة العراق التعليمية'), findsWidgets);
  });

  testWidgets('App enforces RTL directionality', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: IraqEduApp()));
    await tester.pump();

    final directionality = tester.widget<Directionality>(
      find.byType(Directionality).first,
    );
    expect(directionality.textDirection, TextDirection.rtl);
  });
}
