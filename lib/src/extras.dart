import 'dart:developer' as dev;

// ignore: depend_on_referenced_packages
import 'package:flutter/foundation.dart' show kDebugMode;

import 'package:intl/intl.dart';

final _date1970utc = DateTime.utc(1970);

extension DEDateTimeUtils on DateTime {
  int toDaysSince1970() {
    final localDateAsUtc = DateTime.utc(year, month, day);
    return localDateAsUtc.difference(_date1970utc).inDays;
  }

  String getYearFormatted([String? newPattern, String? locale]) => DateFormat(newPattern, locale).format(this);
  String formatTimeFromDate(String format) => DateFormat(format).format(this);
  String getDateFormatted(String format) => formatTimeFromDate(format);
  String getClockFormatted(bool hourFormat12) => formatTimeFromDate(hourFormat12 ? 'hh:mm aa' : 'HH:mm');
}

extension DETotalTime on int {
  /// Converts milliSecondsSinceEpoch to DaysSinceEpoch.
  ///
  /// Note: using normal way of getting day doesnt give a shit about local time, this one works just fine.
  int toDaysSince1970() => DateTime.fromMillisecondsSinceEpoch(this).toDaysSince1970();

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

extension DEYearDateFormatted on int {
  /// converts [yyyyMMdd] or parsable date to [newPattern].
  /// if failed, returns [toString]
  String getYearFormatted([String? newPattern, String? locale]) {
    if (this == 0) return '';

    final parseResult = DateTime.tryParse(toString());
    if (parseResult != null) {
      return parseResult.getYearFormatted(newPattern, locale);
    }

    return toString();
  }

  String formatTimeFromMSSE(String format) => DateTime.fromMillisecondsSinceEpoch(this).formatTimeFromDate(format);
  String getDateFormatted(String format) => DateTime.fromMillisecondsSinceEpoch(this).getDateFormatted(format);
  String getClockFormatted(bool hourFormat12) => DateTime.fromMillisecondsSinceEpoch(this).getClockFormatted(hourFormat12);
}

extension DEDisplayKeywords on int {
  String displayKeyword(String singular, String plural) {
    return '${formatDecimal()} ${this > 1 ? plural : singular}';
  }

  String displayKeywordShort(String singular, String plural) {
    return '${formatDecimalShort()} ${this > 1 ? plural : singular}';
  }
}

extension DEFormatNumber on int {
  String formatDecimalShort([bool full = false]) => (full ? NumberFormat('#,###,###') : NumberFormat.compact()).format(this);
  String formatDecimal() => NumberFormat('#,###,###').format(this);
}

extension DEPrintFunction on dynamic {
  void printy(dynamic message, {bool isError = false, bool dumpshit = false}) {
    printo(message, isError: isError, classScope: this, dumpshit: dumpshit);
  }
}

/// logs the message only in Debug mode.
void printo(dynamic message, {bool printInDebugOnly = true, bool isError = false, dynamic classScope, bool dumpshit = false}) {
  if (kDebugMode && printInDebugOnly) {
    final className = classScope ?? '';
    final isClassNameLong = className.toString().split('').length > 50;
    final msgWithClass = "[$className]: ${isClassNameLong ? '\n' : ''} $message";
    final infoMsg = isError ? '' : 'Info: $msgWithClass';
    final errorMsg = isError ? 'Error: $msgWithClass' : '';
    final color = dumpshit ? '\x1B[37m' : '';
    final stackTrace = isError ? '\n${StackTrace.current}' : '';
    dev.log('$color$infoMsg$stackTrace', error: errorMsg, name: 'Namida');
  }
}
