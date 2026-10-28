import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:dart_extensions/src/extensions.dart';
import 'package:dart_extensions/src/extras.dart';
import 'package:dart_extensions/src/list_extensions.dart';

final _jsonUtf8Decoder = const Utf8Decoder().fuse(const JsonDecoder());
final _jsonUtf8Encoder = JsonUtf8Encoder();
final _jsonUtf8EncoderIndented = JsonUtf8Encoder("  ");

/// parses utf8 json bytes directly, without building an intermediate string.
dynamic jsonDecodeUtf8(List<int> bytes) => _jsonUtf8Decoder.convert(bytes);

/// encodes to utf8 json bytes directly, without building an intermediate string.
Uint8List jsonEncodeUtf8(Object? object) {
  final bytes = _jsonUtf8Encoder.convert(object);
  return bytes is Uint8List ? bytes : Uint8List.fromList(bytes);
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

  Future<int?> fileSize() async {
    try {
      return await length();
    } catch (_) {
      return null;
    }
  }

  int? fileSizeSync() {
    try {
      return lengthSync();
    } catch (_) {
      return null;
    }
  }

  String? fileSizeFormatted() {
    return fileSizeSync()?.fileSizeFormatted;
  }

  Future<bool> existsAndValid([int minValidSize = 3]) async {
    final st = await stat();
    return st.type == FileSystemEntityType.file && st.size >= minValidSize;
  }

  bool existsAndValidSync([int minValidSize = 3]) {
    final st = statSync();
    return st.type == FileSystemEntityType.file && st.size >= minValidSize;
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
  Future<dynamic> readAsJson({void Function()? onError, bool ensureExists = true}) async {
    try {
      if (ensureExists) {
        if (!await exists()) return null;
      }

      final bytes = await readAsBytes();
      if (bytes.isEmpty) return null;
      return _jsonUtf8Decoder.convert(bytes);
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
  dynamic readAsJsonSync({void Function()? onError, bool ensureExists = true}) {
    try {
      if (ensureExists) {
        if (!existsSync()) return null;
      }
      final bytes = readAsBytesSync();
      if (bytes.isEmpty) return null;
      return _jsonUtf8Decoder.convert(bytes);
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
          response.loopAdv((e, index) => execute(e, index));
        }
      },
      onError: onError,
    );
    return success;
  }

  /// Automatically creates the file if it doesnt exist
  ///
  /// Has a built-in try-catch that returns [File] if wrote successfully, or [null] if failed.
  Future<File?> writeAsJson(Object? object, {bool flush = false}) async {
    try {
      await create(recursive: true);
      return (await writeAsBytes(_jsonUtf8EncoderIndented.convert(object), flush: flush));
    } catch (e) {
      printy(e, isError: true);
      return null;
    }
  }

  File? writeAsJsonSync(Object? object) {
    try {
      createSync(recursive: true);
      writeAsBytesSync(_jsonUtf8EncoderIndented.convert(object));
      return this;
    } catch (e) {
      printy(e, isError: true);
      return null;
    }
  }

  static const kAtomicTempSuffix = '.tmp';

  /// See [writeAsBytesAtomic].
  Future<File?> writeAsJsonAtomic(Object? object, {bool flush = false}) async {
    try {
      final bytes = _jsonUtf8EncoderIndented.convert(object);
      return await writeAsBytesAtomic(bytes, flush: flush);
    } catch (e) {
      printy(e, isError: true);
      return null;
    }
  }

  /// See [writeAsBytesAtomicSync].
  File? writeAsJsonAtomicSync(Object? object, {bool flush = false}) {
    try {
      final bytes = _jsonUtf8EncoderIndented.convert(object);
      return writeAsBytesAtomicSync(bytes, flush: flush);
    } catch (e) {
      printy(e, isError: true);
      return null;
    }
  }

  /// See [writeAsBytesAtomic].
  Future<File?> writeAsStringAtomic(String contents, {bool flush = false}) {
    final bytes = utf8.encode(contents);
    return writeAsBytesAtomic(bytes, flush: flush);
  }

  /// See [writeAsBytesAtomicSync].
  File? writeAsStringAtomicSync(String contents, {bool flush = false}) {
    final bytes = utf8.encode(contents);
    return writeAsBytesAtomicSync(bytes, flush: flush);
  }

  /// Written to a [kAtomicTempSuffix] file then renamed over this one, so a kill midway keeps the old content whole.
  /// Falls back to a direct write when the rename fails (ex: windows while the file is locked).
  ///
  /// Creates missing parent folders only when the write fails.
  ///
  /// Has a built-in try-catch that returns [File] if wrote successfully, or [null] if failed.
  Future<File?> writeAsBytesAtomic(List<int> bytes, {bool flush = false}) async {
    try {
      final tempFile = File('$path$kAtomicTempSuffix');
      try {
        await tempFile.writeAsBytes(bytes, flush: flush);
      } on PathNotFoundException {
        await tempFile.parent.create(recursive: true);
        await tempFile.writeAsBytes(bytes, flush: flush);
      }
      try {
        return await tempFile.rename(path);
      } catch (_) {
        try {
          return await writeAsBytes(bytes, flush: flush);
        } finally {
          await tempFile.tryDeleting();
        }
      }
    } catch (e) {
      printy(e, isError: true);
      return null;
    }
  }

  /// Sync twin of [writeAsBytesAtomic].
  File? writeAsBytesAtomicSync(List<int> bytes, {bool flush = false}) {
    try {
      final tempFile = File('$path$kAtomicTempSuffix');
      try {
        tempFile.writeAsBytesSync(bytes, flush: flush);
      } on PathNotFoundException {
        tempFile.parent.createSync(recursive: true);
        tempFile.writeAsBytesSync(bytes, flush: flush);
      }
      try {
        return tempFile.renameSync(path);
      } catch (_) {
        try {
          writeAsBytesSync(bytes, flush: flush);
          return this;
        } finally {
          try {
            tempFile.deleteSync();
          } catch (_) {}
        }
      }
    } catch (e) {
      printy(e, isError: true);
      return null;
    }
  }
}

extension DEDirectoryUtils on Directory {
  /// Files of this directory, without the leftover [DEFileUtils.kAtomicTempSuffix] files of the atomic writers (ex: [DEFileUtils.writeAsJsonAtomic]).
  ///
  /// Errors are skipped, so a failing entry doesn't stop the rest.
  Stream<File> listFilesWithoutAtomicTemps() {
    return list().where((e) => e is File && !e.path.endsWith(DEFileUtils.kAtomicTempSuffix)).cast<File>().handleError((_) {});
  }

  /// Sync twin of [listFilesWithoutAtomicTemps].
  ///
  /// Has a built-in try-catch that returns an empty list if listing failed.
  List<File> listFilesWithoutAtomicTempsSync() {
    try {
      return listSync().whereType<File>().where((f) => !f.path.endsWith(DEFileUtils.kAtomicTempSuffix)).toList();
    } catch (_) {
      return [];
    }
  }
}
