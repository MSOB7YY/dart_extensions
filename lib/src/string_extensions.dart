// ignore_for_file: unnecessary_this

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

  String get removeSymbols => StringCleanUtils.removeSymbols(this);
  String get normalizeAccents => StringCleanUtils.normalize(this);
  String get cleanUpForComparison => normalizeAccents.removeSymbols.toLowerCase();

  /// {@template dart_extensions.string_utils.splitFirst}
  ///
  /// Similar to `split().first`, except that this can break early if [onMatch] returned non-null value,
  /// which means that this will be much faster especially for long text with many splitter occurences.
  ///
  /// example:
  /// ```dart
  /// const text = 'my name is kuru';
  /// text.splitFirst('is', onMatch: (part) => part) as String; // `my name `
  /// ```
  /// {@endtemplate}
  T? splitFirst<T>(
    String splitter, {
    required T? Function(String part) onMatch,
  }) {
    final splitterCodes = splitter.codeUnits; // [".", "."]
    var currentCodes = <int>[];
    var currentTempSplitterCodes = <int>[];
    int currentSplitterIndex = 0;
    final textCodeUnits = this.codeUnits;
    final length = textCodeUnits.length;
    for (int i = 0; i < length; i++) {
      final codeUnit = textCodeUnits[i];
      if (splitterCodes[currentSplitterIndex] == codeUnit) {
        // -- is splitter streak
        currentTempSplitterCodes.add(codeUnit);
        if (currentSplitterIndex == splitterCodes.length - 1) {
          final value = onMatch(String.fromCharCodes(currentCodes));
          if (value != null) return value;
          currentCodes = [];
          currentTempSplitterCodes = []; // its no longer temp, we already used it.
        } else {
          currentSplitterIndex++;
          continue;
        }
      } else {
        // -- is normal text
        currentCodes.add(codeUnit);
        currentSplitterIndex = 0;
        if (currentTempSplitterCodes.isNotEmpty) {
          currentCodes.addAll(currentTempSplitterCodes);
          currentTempSplitterCodes = [];
        }
      }
    }
    return null;
  }

  /// {@template dart_extensions.string_utils.splitLast}
  ///
  /// Similar to `split().last`, except that this can break early if [onMatch] returned non-null value,
  /// which means that this will be much faster especially for long text with many splitter occurences.
  ///
  /// example:
  /// ```dart
  /// const text = 'my name is kuru';
  /// text.splitLast('is', onMatch: (part) => part) as String; // ` kuru`
  /// ```
  ///
  /// {@endtemplate}
  T? splitLast<T>(
    String splitter, {
    required T? Function(String part) onMatch,
  }) {
    final splittersLengthIndex = splitter.length - 1;
    final splitterCodes = splitter.codeUnits; // [".", "."]
    var currentCodes = <int>[];
    var currentTempSplitterCodes = <int>[];
    int currentSplitterIndex = splittersLengthIndex;
    final textCodeUnits = this.codeUnits;
    final length = textCodeUnits.length - 1;
    for (int i = length; i >= 0; i--) {
      final codeUnit = textCodeUnits[i];
      if (splitterCodes[currentSplitterIndex] == codeUnit) {
        // -- is splitter streak
        currentTempSplitterCodes.add(codeUnit);
        if (currentSplitterIndex == splitterCodes.length - 1) {
          final value = onMatch(String.fromCharCodes(currentCodes.reversed));
          if (value != null) return value;
          currentCodes = [];
          currentTempSplitterCodes = []; // its no longer temp, we already used it.
        } else {
          currentSplitterIndex--;
          continue;
        }
      } else {
        // -- is normal text
        currentCodes.add(codeUnit);
        currentSplitterIndex = splittersLengthIndex;
        if (currentTempSplitterCodes.isNotEmpty) {
          currentCodes.addAll(currentTempSplitterCodes);
          currentTempSplitterCodes = [];
        }
      }
    }
    return null;
  }

  /// Calls [splitFirst] and match the first occurence. if no match was found, return [this].
  ///
  /// {@macro dart_extensions.string_utils.splitFirst}
  String splitFirstM(String splitter) {
    return splitFirst(splitter, onMatch: (part) => part) ?? this;
  }

  /// Calls [splitLast] and match the first occurence. if no match was found, return [this].
  ///
  /// {@macro dart_extensions.string_utils.splitLast}
  String splitLastM(String splitter) {
    return splitLast(splitter, onMatch: (part) => part) ?? this;
  }
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
