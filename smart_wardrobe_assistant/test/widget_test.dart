import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_application_1/main.dart';

void main() {
  test('app can be created without device cameras', () {
    expect(const MyApp(cameras: []), isA<MyApp>());
  });
}
