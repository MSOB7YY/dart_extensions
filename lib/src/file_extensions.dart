import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dart_extensions/src/extensions.dart';
import 'package:dart_extensions/src/list_extensions.dart';

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
      const encoder = JsonEncoder.withIndent("  ");
      return (await writeAsString(encoder.convert(object)));
    } catch (e) {
      printy(e, isError: true);
      return null;
    }
  }

  File? writeAsJsonSync(Object? object) {
    try {
      createSync(recursive: true);
      const encoder = JsonEncoder.withIndent("  ");
      writeAsStringSync(encoder.convert(object));
      return this;
    } catch (e) {
      printy(e, isError: true);
      return null;
    }
  }
}
