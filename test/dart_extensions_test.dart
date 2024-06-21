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
  group('DEListieExt', () {
    test('test DEListieExt.move', () async {
      final varl = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10];
      final varl2 = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10];

      const removeFrom = 8;
      const insertTo = 2;

      final e = varl.removeAt(removeFrom);
      varl.insert(insertTo, e);

      varl2.move(removeFrom, insertTo);

      expect(varl.isEqualTo(varl2), true);
    });
    test('benchmark DEListieExt.move', () async {
      const count = 10000;
      final varl = List.filled(count, 1, growable: true);
      final varl2 = List.filled(count, 1, growable: true);

      const removeFrom = 2;
      const insertTo = 100;

      syncBenchmark(
        'remove & insert',
        () {
          final e = varl.removeAt(removeFrom);
          varl.insert(insertTo, e);
        },
      ).report();
      syncBenchmark(
        're-assign',
        () {
          varl2.move(removeFrom, insertTo);
        },
      ).report();
    });
  });

  group('DEStringUtils', () {
    test('test splitFirst() && splitLast()', () {
      const text = 'my name is  he  hehe .';
      const splitter = 'he ';

      String splittedold = '';
      String splittednew = '';
      splittedold = text.split(splitter).first;
      splittednew = text.splitFirst(splitter);
      expect(splittedold, splittednew);

      String splittedoldlast = '';
      String splittednewlast = '';
      splittedoldlast = text.split(splitter).last;
      splittednewlast = text.splitLast(splitter);
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
      syncBenchmark('new (first)', () => splittednew = text.splitFirst(splitter)).report();

      String splittedoldlast = '';
      String splittednewlast = '';
      syncBenchmark('old (last)', () => splittedoldlast = text.split(splitter).last).report();
      syncBenchmark('new (last)', () => splittednewlast = text.splitLast(splitter)).report();
    });
  });
}
