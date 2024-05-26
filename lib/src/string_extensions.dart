// ignore_for_file: depend_on_referenced_packages

import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:string_clean_utils/string_clean_utils.dart';

extension DEFileNameUtils on String {
  String get getFilename => p.basename(this);
  String get getFilenameWOExt => p.basenameWithoutExtension(this);
  String get getExtension => p.extension(this).substring(1);
  String get getDirectoryName => p.dirname(this);
  String get getDirectoryPath => withoutLast(Platform.pathSeparator);
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

  String get overflow => this != '' ? replaceAll(' ', '\u{200B} ') : '';

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

  String get removeSymbols => StringCleanUtils.removeSymbols(this);
  String get normalizeAccents => StringCleanUtils.normalize(this);
  String get cleanUpForComparison => normalizeAccents.removeSymbols.toLowerCase();
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
