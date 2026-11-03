import 'package:flutter_test/flutter_test.dart';
import 'package:qaddy/core/services/document_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('no storage reads nothing and accepts anything', () async {
    const storage = NoDocumentStorage();

    await storage.write('{"a":1}');

    expect(storage.read(), isNull);
  });

  test('preferences storage keeps a document under its key', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final preferences = await SharedPreferences.getInstance();
    final storage = SharedPreferencesDocumentStorage(preferences, 'qaddy.t');

    expect(storage.read(), isNull);
    await storage.write('hello');

    expect(storage.read(), 'hello');
    expect(preferences.getString('qaddy.t'), 'hello');
  });

  test('a second document under another key is independent', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final preferences = await SharedPreferences.getInstance();
    final one = SharedPreferencesDocumentStorage(preferences, 'one');
    final two = SharedPreferencesDocumentStorage(preferences, 'two');

    await one.write('1');

    expect(two.read(), isNull);
  });
}
