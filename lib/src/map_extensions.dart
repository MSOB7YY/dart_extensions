import 'package:dart_extensions/src/list_extensions.dart';

extension NPMapUtils<K, V> on Map<K, V> {
  void assign(K key, V value) {
    clear();
    this[key] = value;
  }

  void assignAll(Map<K, V> other) {
    clear();
    addAll(other);
  }

  void assignAllEntries(Iterable<MapEntry<K, V>> newEntries) {
    clear();
    addEntries(newEntries);
  }

  void sort([int Function(MapEntry<K, V> a, MapEntry<K, V> b)? compare]) {
    final sortedE = sorted(compare);
    this.assignAllEntries(sortedE);
  }

  void sortBy(Comparable<dynamic> Function(MapEntry<K, V> e) key) {
    final sorted = sortedBy(key);
    this.assignAllEntries(sorted);
  }

  void sortByReverse(Comparable<dynamic> Function(MapEntry<K, V> e) key) {
    final sorted = sortedByReverse(key);
    this.assignAllEntries(sorted);
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

  /// Adds [entries] to the map and clears old entries to keep map length at [max].
  ///
  /// [entries] are forcely added to the tail, by removing them first.
  void optimizedAdd(Iterable<MapEntry<K, V>> entries, int max) {
    final map = this;

    for (final e in entries) {
      map.remove(e.key); // removing so that items are inserted lastly, indicating that it has been used.
      map[e.key] = e.value;
    }

    final excess = map.length - max;
    if (excess > 0) {
      final excessKeys = map.keys.take(excess).toList();
      for (final k in excessKeys) {
        map.remove(k);
      }
    }
  }

  /// {@template dart_extensions.extensions.reAssign}
  ///
  /// - Re-Assigns [oldKey] with [newKey] to the map while maintaining the same order.
  ///
  /// ex:
  /// ```dart
  /// final map = {1: 'a', 2: 'b', 3: 'c'};
  /// map.reAssign(2, 6);
  /// print(map); // {1: 'a', 6: 'b', 3: 'c'}
  /// ```
  ///
  /// - [newValue] is optional, to assign both key:value in the same index.
  /// - keys must be comparable (`k == oldKey`).
  ///
  /// {@endtemplate}
  void reAssign(K oldKey, K newKey, {V? newValue}) {
    final map = this;
    if (map[oldKey] == null) return;
    final keys = map.keys.toList();
    final newMapEntries = <MapEntry<K, V>>[];
    int? keyIndex; // just to prevent further equality checks
    keys.loopAdv((k, index) {
      final value = newValue ?? map[k];
      if (value != null) {
        if (keyIndex == null && k == oldKey) {
          keyIndex = index;
          newMapEntries.add(MapEntry(newKey, value));
        } else {
          newMapEntries.add(MapEntry(k, value));
        }
      }
    });
    map.assignAllEntries(newMapEntries);
  }
}

extension NPMapUtilsNullable<K, V> on Map<K, V?> {
  /// {@macro dart_extensions.extensions.reAssign}
  void reAssignNullable(K oldKey, K newKey, {V? newValue}) {
    final map = this;
    final keys = map.keys.toList();
    final newMapEntries = <MapEntry<K, V?>>[];
    int? keyIndex; // just to prevent further equality checks
    keys.loopAdv((k, index) {
      final value = newValue ?? map[k];
      if (keyIndex == null && k == oldKey) {
        keyIndex = index;
        newMapEntries.add(MapEntry(newKey, value));
      } else {
        newMapEntries.add(MapEntry(k, value));
      }
    });
    map.assignAllEntries(newMapEntries);
  }
}

extension NPMapExtNull<K, E> on Map<K, List<E>?> {
  void addForce(K key, E item) {
    if (containsKey(key)) {
      this[key]!.add(item);
    } else {
      this[key] = <E>[item];
    }
  }

  void insertForce(int index, K key, E item) {
    if (containsKey(key)) {
      this[key]!.insert(index, item);
    } else {
      this[key] = <E>[item];
    }
  }

  /// Same as [addNoDuplicates], but initializes new list in case list was null.
  /// i.e: entry doesnt exist in map.
  void addNoDuplicatesForce(K key, E item, {bool preventDuplicates = true}) {
    if (containsKey(key)) {
      this[key]!.addNoDuplicates(item, preventDuplicates: preventDuplicates);
    } else {
      this[key] = <E>[item];
    }
  }

  void addAllNoDuplicatesForce(K key, Iterable<E> items, {bool preventDuplicates = true}) {
    if (containsKey(key)) {
      this[key]!.addAllNoDuplicates(items, preventDuplicates: preventDuplicates);
    } else {
      this[key] = items.toList();
    }
  }
}
