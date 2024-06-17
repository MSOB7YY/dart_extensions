// ignore_for_file: unused_local_variable

import 'package:benchmarking/benchmarking.dart';
import 'package:dart_extensions/src/string_extensions.dart';
import 'package:dart_extensions/src/list_extensions.dart';
import 'package:test/test.dart';

void main() {
  group('DEListieSizie', () {
    test('test changeListSize', () {
      final orgList = [1, 5, 7, 9];
      final newList = orgList.changeListSize(
        targetSize: 3,
        // clampToMax: 9,
        // enforceClampToMax: (minValue, maxValue) => true,
      );
      print(newList);
    });
  });

  group('DEStringUtils', () {
    test('test splitFirst() && splitLast()', () {
      const text = 'my name is  he  hehe .';
      const splitter = 'he ';

      String splittedold = '';
      String splittednew = '';
      splittedold = text.split(splitter).first;
      splittednew = text.splitFirst(splitter, onMatch: (part) => part) as String;
      expect(splittedold, splittednew);

      String splittedoldlast = '';
      String splittednewlast = '';
      splittedoldlast = text.split(splitter).last;
      splittednewlast = text.splitLast(splitter, onMatch: (part) => part) as String;
      expect(splittedoldlast, splittednewlast);
    });
    test('benchmark splitFirst() && splitLast()', () {
      const delimiter = '<div><div><div><div> </div></div></div></div>';

      String text = '';
      for (int i = 0; i < 10000; i++) {
        text += delimiter;
      }

      const splitter = '>';

      String splittedold = '';
      String splittednew = '';
      syncBenchmark('old (first)', () => splittedold = text.split(splitter).first).report();
      syncBenchmark('new (first)', () => splittednew = text.splitFirst(splitter, onMatch: (part) => part) as String).report();

      String splittedoldlast = '';
      String splittednewlast = '';
      syncBenchmark('old (last)', () => splittedoldlast = text.split(splitter).last).report();
      syncBenchmark('new (last)', () => splittednewlast = text.splitLast(splitter, onMatch: (part) => part) as String).report();
    });
  });
}
