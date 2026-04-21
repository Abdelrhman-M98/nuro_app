import 'package:flutter_test/flutter_test.dart';
import 'package:nervix_app/Core/legal/app_legal_content.dart';

void main() {
  test('legal copy is present for in-app screens', () {
    expect(AppLegalContent.privacySections, isNotEmpty);
    expect(AppLegalContent.termsSections, isNotEmpty);
    expect(AppLegalContent.privacySections.first.length, greaterThan(32));
  });
}
