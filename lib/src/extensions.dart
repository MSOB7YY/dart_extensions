// ignore_for_file: depend_on_referenced_packages

import 'dart:async';
import 'dart:convert';
import 'dart:developer' as dev;
import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;

extension DESecondsLabel on int {
  String get secondsLabel {
    if (this == 0) return "00:00";

    String heyPad(int n) => n.toString().padLeft(2, "0");
    final hours = this ~/ 3600;
    final minutes = (this % 3600) ~/ 60;
    final seconds = this % 60;
    final durinHour = hours > 0 ? "${heyPad(hours)}:" : '';
    return "$durinHour${heyPad(minutes)}:${heyPad(seconds)}";
  }

  String get milliSecondsLabel => (this ~/ 1000).secondsLabel;
}

extension DEStringUtilsNull on String? {
  int? getIntValue({bool tryAgainAfterCleaning = true}) {
    final value = this;
    if (value == null) return null;
    int? res;
    res = int.tryParse(value);
    if (res == null && tryAgainAfterCleaning) {
      res = int.tryParse(value.cleanUpForComparison);
    }
    return res;
  }

  double? getDoubleValue() {
    final value = this;
    if (value == null) return null;
    double? res;
    res = double.tryParse(value);
    return res;
  }
}

extension DEStringUtils on String {
  /// Trims a string and removes all extra white spaces.
  String trimAll() {
    // second time ensures removing extra ones if number of white spaces is odd, for ex:
    // 1. 'W...H' => 'W..H'
    // 2. 'W..H' => 'W.H'
    return replaceAll('  ', ' ').replaceAll('  ', ' ').trim();
  }

  String addQuotation() => "'$this'";
  String addDQuotation() => '"$this"';

  String get overflow => this != '' ? characters.replaceAll(Characters(''), Characters('\u{200B}')).toString() : '';

  String formatPath() {
    String formatted = replaceFirst('/storage/', '/').replaceFirst('/emulated/0', 'main');
    if (formatted[0] == '/') {
      formatted = formatted.substring(1);
    }
    return formatted;
  }

  String withoutLast(String splitBy) {
    final parts = split(splitBy);
    parts.removeLast();
    return parts.join(splitBy);
  }

  List<String> multiSplit(Iterable<String> delimiters, Iterable<String> blacklist) {
    if (blacklist.any((s) => contains(s))) {
      return [this];
    } else {
      return delimiters.isEmpty
          ? [this]
          : split(
              RegExp(delimiters.map(RegExp.escape).join('|'), caseSensitive: false),
            );
    }
  }

  String get cleanUpForComparison => toLowerCase()
      .replaceAll(RegExp(r'''[\!\"\#\$\%\&\'\(\)\*\+\,\-\.\/\:\;\<\>\=\?\@\[\]\{\}\\\\\^\_\`\~\s\|\@\#\$\%\^\&\*\(\)\-\+\=\[\]\{\}\:\;\"\'\<\>\.\,\?\/\`\~\!\_\s]+'''), '');
}

extension DEIterables<E> on Iterable<E> {
  Map<K, List<E>> groupBy<K>(K Function(E) keyFunction) => fold(
        <K, List<E>>{},
        (Map<K, List<E>> map, E element) => map..putIfAbsent(keyFunction(element), () => <E>[]).add(element),
      );
  Map<K, E> groupByToSingleValue<K>(K Function(E) keyFunction) => fold(
        <K, E>{},
        (Map<K, E> map, E element) => map..[keyFunction(element)] = element,
      );
}

extension DEMSSEUtils on int? {
  DateTime? get milliSecondsSinceEpoch => this == null ? null : DateTime.fromMillisecondsSinceEpoch(this!);
}

extension DETotalTime on int {
  /// Converts milliSecondsSinceEpoch to DaysSinceEpoch.
  ///
  /// Note: using normal way of getting day doesnt give a shit about local time, this one works just fine.
  int toDaysSinceEpoch() => DateTime.fromMillisecondsSinceEpoch(this).difference(DateTime(1970)).inDays;

  /// Formats MSSE to a readable time, ex: `2h 32min`.
  String getTimeFormatted({
    String hourChar = 'h',
    String minutesChar = 'min',
    String separator = ' ',
  }) {
    final totalSeconds = this;
    final durInSec = totalSeconds % 60;

    if (totalSeconds < 60) {
      return '${totalSeconds}s';
    }

    final totalMinutes = totalSeconds ~/ 60;
    final durInMin = totalMinutes % 60;
    final finalDurInMin = durInSec > 30 ? durInMin + 1 : durInMin;
    final totalHours = totalMinutes ~/ 60;

    final hoursText = totalHours == 0 ? "" : "$totalHours$hourChar$separator";
    final minsText = durInMin == 0 ? "" : "$finalDurInMin$minutesChar";
    return "$hoursText$minsText";
  }
}

extension DEDisplayKeywords on int {
  String displayKeyword(String singular, String plural) {
    return '${formatDecimal()} ${this > 1 ? plural : singular}';
  }
}

extension DEYearDateFormatted on int {
  /// converts [yyyyMMdd] or parsable date to [newPattern].
  /// if failed, returns [toString]
  String getYearFormatted([String? newPattern, String? locale]) {
    if (this == 0) return '';

    final parseResult = DateTime.tryParse(toString());
    if (parseResult != null) {
      return DateFormat(newPattern, locale).format(parseResult);
    }

    return toString();
  }

  String formatTimeFromMSSE(String format) => DateFormat(format).format(DateTime.fromMillisecondsSinceEpoch(this));

  String getDateFormatted({String format = 'dd MMM yyyy'}) => formatTimeFromMSSE(format);

  String getClockFormatted(bool hourFormat12) => formatTimeFromMSSE(hourFormat12 ? 'hh:mm aa' : 'HH:mm');
}

extension DEFileSizeFormat on int {
  String get fileSizeFormatted {
    const decimals = 2;
    if (this <= 0) return "0 B";
    const suffixes = ["B", "KB", "MB", "GB", "TB", "PB", "EB", "ZB", "YB"];
    final i = (math.log(this) / math.log(1024)).floor();
    return '${(this / math.pow(1024, i)).toStringAsFixed(decimals)} ${suffixes[i]}';
  }
}

extension DEFileNameUtils on String {
  String get getFilename => p.basename(this);
  String get getFilenameWOExt => p.basenameWithoutExtension(this);
  String get getExtension => p.extension(this).substring(1);
  String get getDirectoryName => p.dirname(this);
  String get getDirectoryPath => withoutLast(Platform.pathSeparator);
}

extension DEEnumUtils on Enum {
  String get convertToString => toString().split('.').last;
}

extension DEFORMATNUMBER on int? {
  String formatDecimalShort([bool full = false]) => (full ? NumberFormat('#,###,###') : NumberFormat.compact()).format(this);
  String formatDecimal() => NumberFormat('#,###,###').format(this);
}

extension DEFileUtils<R> on File {
  Future<T> executeAndKeepStats<T>(Future<T> Function() fn, {bool keepStats = true}) async {
    final stats = keepStats ? await stat() : null;
    final res = await fn();
    if (stats != null) {
      try {
        await setLastAccessed(stats.accessed);
        await setLastModified(stats.modified);
      } catch (e) {
        printy(e, isError: true);
      }
    }
    return res;
  }

  Future<int> sizeInBytes() async => await stat().then((value) => value.size);

  int sizeInBytesSync() => statSync().size;

  Future<bool> existsAndValid([int minValidSize = 3]) async {
    final st = await stat();
    final doesExist = await exists();
    return (doesExist && st.size >= minValidSize);
  }

  bool existsAndValidSync([int minValidSize = 3]) {
    return existsSync() && statSync().size >= minValidSize;
  }

  /// returns [true] if deleted successfully. or [false] if failed.
  Future<bool> deleteIfExists() async {
    try {
      if (await exists()) {
        await delete();
        return true;
      }
    } catch (e) {
      printy(e, isError: true);
      return false;
    }
    return false;
  }

  Future<bool> tryDeleting() async {
    try {
      await delete();
      return true;
    } catch (e) {
      printy(e, isError: true);
      return false;
    }
  }

  /// returns [true] if deleted successfully.
  bool deleteIfExistsSync() {
    if (existsSync()) {
      deleteSync();
      return true;
    }
    return false;
  }

  /// Returns decoded [response] if executed successfully.
  ///
  /// Otherwise, executes [onError] and returns [null].
  ///
  /// has a built in try-catch.
  Future<dynamic> readAsJson({void Function()? onError}) async {
    try {
      await create(recursive: true);
      final content = await readAsString();
      if (content.isEmpty) return null;
      return jsonDecode(content);
    } catch (e) {
      printy(e, isError: true);
      if (onError != null) onError();
      return null;
    }
  }

  /// Returns decoded [response] if executed successfully.
  ///
  /// Otherwise, executes [onError] and returns [null].
  ///
  /// has a built in try-catch.
  dynamic readAsJsonSync({void Function()? onError}) {
    try {
      createSync(recursive: true);
      final content = readAsStringSync();
      if (content.isEmpty) return null;
      return jsonDecode(content);
    } catch (e) {
      printy(e, isError: true);
      if (onError != null) onError();
      return null;
    }
  }

  /// returns [true] if executed successfully.
  ///
  /// Otherwise, executes [onError] and returns [false].
  ///
  /// has a built in try-catch.
  Future<bool> readAsJsonAnd(Future<void> Function(R response) execute, {void Function()? onError}) async {
    final respone = await readAsJson(onError: onError);
    if (respone == null) return false;

    try {
      await execute(respone);
      return true;
    } catch (e) {
      if (onError != null) onError();
      printy(e, isError: true);
      return false;
    }
  }

  Future<bool> readAsJsonAndLoop(
    void Function(dynamic item, int index) execute, {
    void Function(List? responseList)? onListReady,
    void Function()? onError,
  }) async {
    final success = await readAsJsonAnd(
      (response) async {
        if (response != null) {
          response as List;
          if (onListReady != null) onListReady(response);

          response.loop((e, index) {
            execute(e, index);
          });
        }
      },
      onError: onError,
    );
    return success;
  }

  /// Automatically creates the file if it doesnt exist
  ///
  /// Has a built-in try-catch that returns [File] if wrote successfully, or [null] if failed.
  Future<File?> writeAsJson(Object? object) async {
    try {
      await create(recursive: true);
      const encoder = JsonEncoder.withIndent("  ");
      return (await writeAsString(encoder.convert(object)));
    } catch (e) {
      printy(e, isError: true);
      return null;
    }
  }
}

extension DENumberUtils<E extends num> on E {
  E withMinimum(E min) {
    if (this < min) return min;
    return this;
  }

  E withMaximum(E max) {
    if (this > max) return max;
    return this;
  }
}

extension DEIntUtils on int {
  int getRandomNumberBelow([int minimum = 0]) {
    return minimum + (math.Random().nextInt(this));
  }
}

extension DEMapExtNull<K, E> on Map<K, List<E>?> {
  void addForce(K key, E item) {
    if (keyExists(key)) {
      this[key]!.add(item);
    } else {
      this[key] = <E>[item];
    }
  }

  void insertForce(int index, K key, E item) {
    if (keyExists(key)) {
      this[key]!.insert(index, item);
    } else {
      this[key] = <E>[item];
    }
  }

  /// Same as [addNoDuplicates], but initializes new list in case list was null.
  /// i.e: entry doesnt exist in map.
  void addNoDuplicatesForce(K key, E item, {bool preventDuplicates = true}) {
    if (keyExists(key)) {
      this[key]!.addNoDuplicates(item, preventDuplicates: preventDuplicates);
    } else {
      this[key] = <E>[item];
    }
  }

  void addAllNoDuplicatesForce(K key, Iterable<E> items, {bool preventDuplicates = true}) {
    if (keyExists(key)) {
      this[key]!.addAllNoDuplicates(items, preventDuplicates: preventDuplicates);
    } else {
      this[key] = items.toList();
    }
  }
}

extension DEStuffUtils<T> on T {
  T toIf(T convertTo, T ifValueEquals) => this == ifValueEquals ? convertTo : this;
}

extension DESetExt<E, Id> on Set<E> {
  /// Adds [item] to [this] if it doesn't exist,
  /// or removes [item] if it exists.
  /// returns true if [item] was removed.
  bool addOrRemove(E item) {
    final didRemove = remove(item);
    if (!didRemove) {
      add(item);
    }
    return didRemove;
  }
}

extension DEListieExt<E, Id> on List<E> {
  /// Adds [item] to [this] if it doesn't exist,
  /// or removes [item] if it exists.
  /// returns true if [item] was removed.
  bool addOrRemove(E item) {
    final didRemove = remove(item);
    if (!didRemove) {
      add(item);
    }
    return didRemove;
  }

  /// Replaces All Items that fullfils [test] with [newElement] inside the list.
  void replaceWhere(bool Function(E e) test, E Function(E old) newElement, {void Function()? onMatch}) {
    loop((currentElement, index) {
      if (test(currentElement)) {
        this[index] = newElement(currentElement);
        if (onMatch != null) onMatch();
      }
    });
  }

  /// Replaces Single Item inside the list.
  void replaceSingleWhere(bool Function(E e) test, E Function(E old) newElement, {void Function()? onMatch}) {
    for (int i = 0; i <= length - 1; i++) {
      final currentElement = this[i];
      if (test(currentElement)) {
        this[i] = newElement(currentElement);
        if (onMatch != null) onMatch();
        break;
      }
    }
  }

  /// Replaces All Items that matches [oldElement] with [newElement] inside the list.
  void replaceItems(E oldElement, E newElement, {void Function()? onMatch}) {
    loop((currentElement, index) {
      if (currentElement == oldElement) {
        this[index] = newElement;
        if (onMatch != null) onMatch();
      }
    });
  }

  /// Replaces Single Item inside the list.
  void replaceItem(E oldElement, E newElement, {void Function()? onMatch}) {
    for (int i = 0; i <= length - 1; i++) {
      final currentElement = this[i];
      if (currentElement == oldElement) {
        this[i] = newElement;
        if (onMatch != null) onMatch();
        break;
      }
    }
  }

  E? getEnum(String? string) => firstWhereEff((element) => element.toString().split('.').last == string);

  void insertSafe(int index, E object) => insert(index.clamp(0, length), object);
  void insertAllSafe(int index, Iterable<E> objects) => insertAll(index.clamp(0, length), objects);

  void sortBy(Comparable Function(E e) key) => sort((a, b) => key(a).compareTo(key(b)));
  void sortByReverse(Comparable Function(E e) key) => sort((a, b) => key(b).compareTo(key(a)));

  void sortByAlt(Comparable Function(E e) key, Comparable Function(E e) alternative) => sort((a, b) {
        final compare = key(a).compareTo(key(b));
        if (compare == 0) {
          return alternative(a).compareTo(alternative(b));
        }
        return compare;
      });
  void sortByReverseAlt(Comparable Function(E e) key, Comparable Function(E e) alternative) => sort((a, b) {
        final compare = key(b).compareTo(key(a));
        if (compare == 0) {
          return alternative(b).compareTo(alternative(a));
        }
        return compare;
      });

  /// returns number of items removed.
  int removeWhereWithDifference(bool Function(E element) test) {
    final lengthBefore = length;
    removeWhere(test);
    final lengthAfter = length;
    return lengthBefore - lengthAfter;
  }

  bool isEqualTo(List<E> q2) {
    final q1 = this;
    if (q1.isEmpty && q2.isEmpty) {
      return true;
    }
    if (q1.length != q2.length) {
      return false;
    }
    final finalLength = q1.length > q2.length ? q2.length : q1.length;

    for (int i = 0; i < finalLength; i++) {
      if (q1[i] != q2[i]) {
        return false;
      }
    }
    return true;
  }

  /// returns number of items removed.
  int removeDuplicates([Id Function(E element)? id]) {
    final uniquedSet = <dynamic>{};
    final lengthBefore = length;
    retainWhere((e) => uniquedSet.add(id != null ? id(e) : e));
    final lengthAfter = length;
    return lengthBefore - lengthAfter;
  }

  List<E> uniqued([Id Function(E element)? id]) {
    final uniquedSet = <dynamic>{};
    final list = List<E>.from(this);
    list.retainWhere((e) => uniquedSet.add(id != null ? id(e) : e));
    return list;
  }

  List<T> mapped<T>(T Function(E e) toElement) {
    final list = <T>[];
    loop((el, index) {
      list.add(toElement(el));
    });
    return list;
  }

  List<T> mappedUniqued<T>(T Function(E e) toElement) {
    final list = mapped(toElement);
    list.removeDuplicates();
    return list;
  }

  List<T> mappedUniquedList<T>(Iterable<T> Function(E e) toElement) {
    final list = <T>[];
    loop((el, index) {
      list.addAll(toElement(el));
    });
    list.removeDuplicates();
    return list;
  }

  void addNoDuplicates(E item, {bool preventDuplicates = true}) {
    if (preventDuplicates && contains(item)) return;

    add(item);
  }

  void addAllNoDuplicates(Iterable<E> item, {bool preventDuplicates = true}) {
    addAll(item);
    if (preventDuplicates) {
      removeDuplicates();
    }
  }

  /// Efficient version of lastWhere()
  E? lastWhereEff(bool Function(E e) test, {E? fallback}) {
    for (int i = length - 1; i >= 0; i--) {
      final element = this[i];
      if (test(element)) {
        return element;
      }
    }
    return fallback;
  }

  /// Efficient version of firstWhere()
  E? firstWhereEff(bool Function(E e) test, {E? fallback}) {
    for (int i = 0; i < length; i++) {
      final element = this[i];
      if (test(element)) {
        return element;
      }
    }
    return fallback;
  }

  /// Efficient looping, uses normal for loop.
  ///
  /// Doesn't support keywork statements like [break], [continue], etc...
  void loop(void Function(E e, int index) function) async {
    for (int i = 0; i < length; i++) {
      final element = this[i];
      function(element, i);
    }
  }

  void retainWhereAdvanced(bool Function(E element, int index) test, {int? keepIndex}) {
    final indexesToRemove = <int>[];

    loop((element, index) {
      if (!test(element, index)) {
        indexesToRemove.add(index);
      }
    });

    indexesToRemove.remove(keepIndex);
    indexesToRemove.reverseLoop((indexToRemove, index) {
      removeAt(indexToRemove);
    });
  }

  Future<void> loopFuture(Future<void> Function(E e, int index) function) async {
    for (int i = 0; i < length; i++) {
      final element = this[i];
      await function(element, i);
    }
  }

  /// Efficent looping, uses normal for loop.
  ///
  /// Doesn't support keywork statements like [return], [break], [continue], etc...
  void reverseLoop(void Function(E e, int index) function) {
    for (int i = length - 1; i >= 0; i--) {
      final item = this[i];
      function(item, i);
    }
  }

  E? get firstOrNull => isEmpty ? null : this[0];
  E? get lastOrNull => isEmpty ? null : this[length - 1];
}

extension DEIterableUtils<E> on Iterable<E> {
  E? get firstOrNull => isEmpty ? null : first;
  E? get lastOrNull => isEmpty ? null : last;

  Iterable<E> withLimit([int? limit]) => limit != null ? take(limit) : this;
}

extension DEWidgetsSeparator on Iterable<Widget> {
  Iterable<Widget> addSeparators({required Widget separator, int skipFirst = 0}) sync* {
    final iterator = this.iterator;
    int count = 0;

    while (iterator.moveNext()) {
      if (count < skipFirst) {
        yield iterator.current;
      } else {
        yield separator;
        yield iterator.current;
      }
      count++;
    }
  }
}

extension DEListieSizie<N extends num> on List<N> {
  /// - Having a [targetSize] == null allows for using other parameters while retaining same list size.
  ///
  /// - [multiplier] multiplies each value with it, ex:
  /// ```dart
  /// [1, 2, 4].changeListSize(multiplier: 2.0) => [2, 4, 8]
  /// ```
  ///
  /// - [clampToMax] gives all values a push to have a final list with max value == `clampToMax`, while keeping relative relation, ex:
  /// ```dart
  /// [1, 2, 4].changeListSize(clampToMax: 5.0) => [2, 3, 5] // each value increased by the difference needed to make the max value reach [clampToMax]
  /// [1, 2, 4].changeListSize(clampToMax: 3.0) => [0, 1, 3] // each value decreased by the difference needed to make the max value reach [clampToMax]
  /// ```
  ///
  /// Setting [enforceClampToMax] to false means using an inverse relation between max value and given [clampToMax],
  /// resulting in a consistent increase rate relavent to max value, for example, using [clampToMax] of 50.0:
  /// 1. maxValue == 40 => will give all values 5 => max = 45
  /// 2. maxValue == 20 => will give all values 20 => max = 40
  List<double> changeListSize({
    required int? targetSize,
    double multiplier = 1.0,
    double? minimumValue,
    double? clampToMax,
    bool enforceClampToMax = false,
  }) {
    targetSize ??= length;
    double maxValue = -double.infinity;
    double minValue = double.infinity;
    final finalList = <double>[];

    // -- Case 1
    if (length > targetSize) {
      final chunk = length / targetSize;
      final iterationsCount = targetSize;
      for (int i = 0; i < iterationsCount; i++) {
        final part = skip((chunk * i).floor()).take(chunk.floor());
        final sum = part.fold<double>(0, (previousValue, element) => previousValue + element);
        final peak = sum / part.length * multiplier;
        finalList.add(peak);
        if (maxValue < peak) maxValue = peak;
        if (minValue > peak) minValue = peak;
      }
    }
    // -- Case 2
    else if (length < targetSize) {
      final step = (length - 1) / (targetSize - 1);

      for (int i = 0; i < targetSize; i++) {
        final index = i * step;
        final lowerIndex = index.floor();
        final upperIndex = index.ceil();

        if (lowerIndex == upperIndex) {
          final toAdd = this[lowerIndex] * multiplier;
          finalList.add(toAdd);
          if (maxValue < toAdd) maxValue = toAdd;
          if (minValue > toAdd) minValue = toAdd;
        } else {
          final fraction = index - lowerIndex.toDouble();
          final interpolatedValue = this[lowerIndex] + (this[upperIndex] - this[lowerIndex]) * fraction;
          final toAdd = interpolatedValue * multiplier;
          finalList.add(toAdd);
          if (maxValue < toAdd) maxValue = toAdd;
          if (minValue > toAdd) minValue = toAdd;
        }
      }
    }
    // -- Case 3
    else {
      // -- targetSize == list.length
      for (int i = 0; i <= length - 1; i++) {
        final value = this[i];
        final toAdd = value * multiplier;
        finalList.add(toAdd);
        if (maxValue < toAdd) maxValue = toAdd;
        if (minValue > toAdd) minValue = toAdd;
      }
    }

    // == Default ==
    if (minimumValue != null) {
      final diff = minimumValue - minValue;
      final refined = List<double>.from(finalList.map((e) => e + diff));
      finalList
        ..clear()
        ..addAll(refined);
    }
    if (clampToMax != null) {
      final difference = clampToMax - maxValue;
      final maxValueInversed = math.pow(maxValue, -1);
      // map only if difference != 0
      return difference != 0
          ? enforceClampToMax
              ? finalList.map((e) => e + difference).toList()
              : finalList.map((e) {
                  final calculatedAverage = e * 0.4 * maxValueInversed;
                  return e + difference * calculatedAverage;
                }).toList()
          : finalList;
    }
    return finalList;
  }
}

extension DEMapUtils<K, V> on Map<K, V> {
  /// [keyExists] : Less accurate but instant, O(1).
  /// Shouldn't be used if the value could be null.
  ///
  /// [containsKey] : Certain but not instant, O(keys.length).
  bool keyExists(K key) => this[key] != null;

  void sort([int Function(MapEntry<K, V> a, MapEntry<K, V> b)? compare]) {
    final sortedE = sorted(compare);
    this
      ..clear()
      ..addEntries(sortedE);
  }

  void sortBy(Comparable<dynamic> Function(MapEntry<K, V> e) key) {
    final sorted = sortedBy(key);
    this
      ..clear()
      ..addEntries(sorted);
  }

  void sortByReverse(Comparable<dynamic> Function(MapEntry<K, V> e) key) {
    final sorted = sortedByReverse(key);
    this
      ..clear()
      ..addEntries(sorted);
  }

  List<MapEntry<K, V>> sorted([int Function(MapEntry<K, V> a, MapEntry<K, V> b)? compare]) {
    return entries.toList()..sort(compare);
  }

  List<MapEntry<K, V>> sortedBy(Comparable<dynamic> Function(MapEntry<K, V> e) key) {
    return entries.toList()..sortBy(key);
  }

  List<MapEntry<K, V>> sortedByReverse(Comparable<dynamic> Function(MapEntry<K, V> e) key) {
    return entries.toList()..sortByReverse(key);
  }
}

extension DEExecuteIfBool on bool {
  void executeIfTrue<T>(T Function() execute) {
    if (this) execute();
  }

  void executeIfFalse<T>(T Function() execute) {
    if (!this) execute();
  }
}

extension DEPrintFunction on dynamic {
  void printy(dynamic message, {bool isError = false, bool dumpshit = false}) {
    printo(message, isError: isError, classScope: this, dumpshit: dumpshit);
  }
}

/// logs the message only in Debug mode.
void printo(dynamic message, {bool printInDebugOnly = true, bool isError = false, dynamic classScope, bool dumpshit = false}) {
  if (printInDebugOnly && kDebugMode) {
    final className = classScope ?? '';
    final isClassNameLong = className.toString().split('').length > 50;
    final msgWithClass = "[$className]: ${isClassNameLong ? '\n' : ''} $message";
    final infoMsg = isError ? '' : 'Info: $msgWithClass';
    final errorMsg = isError ? 'Error: $msgWithClass' : '';
    final color = dumpshit ? '\x1B[37m' : '';
    dev.log('$color$infoMsg', error: errorMsg, name: 'Namida');
  }
}
