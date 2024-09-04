// ignore_for_file: depend_on_referenced_packages

import 'dart:developer' as dev;
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';

extension DESecondsLabel on int {
  String get secondsLabel {
    if (this == 0) return "00:00";

    final val = abs();
    final suffix = isNegative ? '-' : '';

    String heyPad(int n) => n.toString().padLeft(2, "0");
    final hours = val ~/ 3600;
    final minutes = (val % 3600) ~/ 60;
    final seconds = val % 60;
    final durinHour = hours > 0 ? "${heyPad(hours)}:" : '';
    return "$suffix$durinHour${heyPad(minutes)}:${heyPad(seconds)}";
  }

  String get milliSecondsLabel => (this ~/ 1000).secondsLabel;
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

extension DEDateTimeUtils on DateTime {
  int toDaysSince1970() => difference(DateTime(1970)).inDays;
}

extension DETotalTime on int {
  /// Converts milliSecondsSinceEpoch to DaysSinceEpoch.
  ///
  /// Note: using normal way of getting day doesnt give a shit about local time, this one works just fine.
  int toDaysSince1970() => DateTime.fromMillisecondsSinceEpoch(this).difference(DateTime(1970)).inDays;

  /// Formats MSSE to a readable time, ex: `2h 32min`.
  String getSecondsFormatted({
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

  String displayKeywordShort(String singular, String plural) {
    return '${formatDecimalShort()} ${this > 1 ? plural : singular}';
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

extension DEFormatNumber on int {
  String formatDecimalShort([bool full = false]) => (full ? NumberFormat('#,###,###') : NumberFormat.compact()).format(this);
  String formatDecimal() => NumberFormat('#,###,###').format(this);
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

extension DEStuffUtils<T> on T {
  T toIf(T convertTo, T ifValueEquals) => this == ifValueEquals ? convertTo : this;
  T toIfValueIs(T convertTo, T Function(T value) ifValueEquals) => this == ifValueEquals(convertTo) ? convertTo : this;
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

extension DEIterableUtils<E> on Iterable<E> {
  E? get firstOrNull => isEmpty ? null : first;
  E? get lastOrNull => isEmpty ? null : last;

  Iterable<E> withLimit([int? limit]) => limit != null ? take(limit) : this;
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
