import 'package:flutter_test/flutter_test.dart';
import 'package:qaddy/core/services/link_launcher.dart';

void main() {
  group('phoneUri', () {
    test('keeps only what a dialler understands', () {
      expect(phoneUri('(03) 5550 0141').toString(), 'tel:0355500141');
      expect(phoneUri(' 0412 345 678 ').toString(), 'tel:0412345678');
    });

    test('keeps a leading plus for international numbers', () {
      expect(phoneUri('+61 3 5550 0141').toString(), 'tel:+61355500141');
    });
  });

  group('websiteUri', () {
    test('adds https to a bare address', () {
      expect(
        websiteUri('www.kingstonheath.example').toString(),
        'https://www.kingstonheath.example',
      );
    });

    test('leaves an address that already has a scheme alone', () {
      expect(
        websiteUri('http://club.example/tee-times').toString(),
        'http://club.example/tee-times',
      );
      expect(websiteUri(' https://club.example ').host, 'club.example');
    });
  });

  group('maps', () {
    test('a search carries the place, safely encoded', () {
      final uri = mapSearchUri('1 Heath Road, Cheltenham VIC 3192');

      expect(uri.host, 'www.google.com');
      expect(uri.path, '/maps/search/');
      expect(uri.queryParameters, <String, String>{
        'api': '1',
        'query': '1 Heath Road, Cheltenham VIC 3192',
      });
      expect(uri.toString(), isNot(contains(' ')));
    });

    test('directions carry the destination and, when known, the origin', () {
      final withOrigin = mapDirectionsUri(destination: 'A', origin: 'B');
      final without = mapDirectionsUri(destination: 'A');

      expect(withOrigin.queryParameters['origin'], 'B');
      expect(withOrigin.queryParameters['destination'], 'A');
      expect(without.queryParameters.containsKey('origin'), isFalse);
      expect(
        mapDirectionsUri(destination: 'A', origin: '').queryParameters,
        isNot(contains('origin')),
      );
    });
  });
}
