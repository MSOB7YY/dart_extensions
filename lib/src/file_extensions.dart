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
  Future<File?> writeAsJson(Object? object) async {
    try {
      await create(recursive: true);
      return (await writeAsBytes(_jsonUtf8EncoderIndented.convert(object)));
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
}
