// ignore_for_file: unnecessary_this

import 'dart:math' as math;

extension DEListieExt<E, Id> on List<E> {
  void assign(E element) {
    clear();
    add(element);
  }

  void assignAll(Iterable<E> iterable) {
    clear();
    addAll(iterable);
  }

  /// Simple for loop, alternative of [forEach] but doesnt check length with each iteration.
  void loop(void Function(E item) action) {
    final int length = this.length;
    for (int i = 0; i < length; i++) {
      action(this[i]);
    }
  }

  /// Same as [loop] with additional index parameter.
  void loopAdv(void Function(E item, int index) action) {
    final int length = this.length;
    for (int i = 0; i < length; i++) {
      action(this[i], i);
    }
  }

  /// Reverse version of [loop].
  void reverseLoop(void Function(E item) action) {
    final int length = this.length;
    for (int i = length - 1; i >= 0; i--) {
      action(this[i]);
    }
  }

  /// Reverse version of [loopAdv].
  void reverseLoopAdv(void Function(E e, int index) function) {
    final int length = this.length;
    for (int i = length - 1; i >= 0; i--) {
      function(this[i], i);
    }
  }

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
    loopAdv((currentElement, index) {
      if (test(currentElement)) {
        this[index] = newElement(currentElement);
        if (onMatch != null) onMatch();
      }
    });
  }

  /// Replaces Single Item inside the list.
  void replaceSingleWhere(bool Function(E e) test, E Function(E old) newElement, {void Function()? onMatch}) {
    final int length = this.length;
    for (int i = 0; i < length; i++) {
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
    loopAdv((currentElement, index) {
      if (currentElement == oldElement) {
        this[index] = newElement;
        if (onMatch != null) onMatch();
      }
    });
  }

  /// Replaces Single Item inside the list.
  void replaceItem(E oldElement, E newElement, {void Function()? onMatch}) {
    final int length = this.length;
    for (int i = 0; i < length; i++) {
      final currentElement = this[i];
      if (currentElement == oldElement) {
        this[i] = newElement;
        if (onMatch != null) onMatch();
        break;
      }
    }
  }

  E? getEnum(String? string) => string == null ? null : firstWhereEff((element) => element.toString().split('.').last == string);
  E? getEnumLoose(String? string) => string == null ? null : firstWhereEff((element) => element.toString().split('.').last.toLowerCase() == string.toLowerCase());

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

  void sortByAlts(List<Comparable Function(E e)> alternatives) => sort((a, b) {
        for (final alternative in alternatives) {
          final compare = alternative(a).compareTo(alternative(b));
          if (compare != 0) return compare;
        }
        return 0;
      });

  void sortByReverseAlts(List<Comparable Function(E e)> alternatives) => sort((a, b) {
        for (final alternative in alternatives) {
          final compare = alternative(b).compareTo(alternative(a));
          if (compare != 0) return compare;
        }
        return 0;
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
    loop((el) => list.add(toElement(el)));
    return list;
  }

  List<T> mappedUniqued<T>(T Function(E e) toElement) {
    final list = <T>[];
    final addedMap = <T, bool?>{};
    loop((el) {
      final element = toElement(el);
      if (addedMap[element] == null) {
        addedMap[element] = true;
        list.add(element);
      }
    });
    return list;
  }

  List<T> mappedUniquedList<T>(Iterable<T> Function(E e) toElements) {
    final addedMap = <T, bool?>{};
    final list = <T>[];
    loop((el) {
      final elements = toElements(el);
      for (final element in elements) {
        if (addedMap[element] == null) {
          addedMap[element] = true;
          list.add(element);
        }
      }
    });
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
    final int lengthIndex = this.length - 1;
    for (int i = lengthIndex; i >= 0; i--) {
      final element = this[i];
      if (test(element)) {
        return element;
      }
    }
    return fallback;
  }

  /// Efficient version of firstWhere()
  E? firstWhereEff(bool Function(E e) test, {E? fallback}) {
    final int length = this.length;
    for (int i = 0; i < length; i++) {
      final element = this[i];
      if (test(element)) {
        return element;
      }
    }
    return fallback;
  }

  void retainWhereAdvanced(bool Function(E element, int index) test, {int? keepIndex}) {
    final indexesToRemove = <int>[];

    loopAdv((element, index) {
      if (!test(element, index)) {
        indexesToRemove.add(index);
      }
    });

    if (keepIndex != null) indexesToRemove.remove(keepIndex);
    indexesToRemove.reverseLoop((indexToRemove) => removeAt(indexToRemove));
  }

  /// Better alternative than [removeAt] & [insert].
  /// The closer the gap between [oldIndex] and [newIndex], the more performance will be noticed compared to [removeAt] & [insert].
  void move(int oldIndex, int newIndex) {
    if (oldIndex == newIndex) return;

    var list = this;
    var temp = list[oldIndex];

    if (oldIndex < newIndex) {
      for (int i = oldIndex; i < newIndex; i++) {
        list[i] = list[i + 1];
      }
    } else {
      for (int i = oldIndex; i > newIndex; i--) {
        list[i] = list[i - 1];
      }
    }

    list[newIndex] = temp;
  }

  E? get firstOrNull => isEmpty ? null : this[0];
  E? get lastOrNull => isEmpty ? null : this[length - 1];
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
    required int targetSize,
    double multiplier = 1.0,
    double? minimumValue,
    double? clampToMax,
    bool Function(num minValue, num maxValue)? enforceClampToMax,
  }) {
    final length = this.length;
    if (targetSize == 0) return <double>[];
    if (length == 0) {
      if (minimumValue != null) {
        return List<double>.filled(targetSize, minimumValue * multiplier, growable: true);
      } else if (clampToMax != null) {
        return List<double>.filled(targetSize, clampToMax * multiplier, growable: true);
      } else {
        return <double>[];
      }
    }

    num maxValue = this[0];
    num minValue = this[0];
    final finalList = <double>[];

    // -- Case 1
    if (length > targetSize) {
      final int chunkSmall = (length / targetSize).floor(); // 0.9 -> 0
      final int chunkBig = (length / targetSize).round(); // 0.9 -> 1 (not ciel to minimize big unnecessary jumps)

      bool usingChunkBig = true;
      num subsum = 0;
      int subIterated = 0;
      for (int i = 0; i < length; i++) {
        subsum += this[i];
        subIterated++;

        final chunkToUse = usingChunkBig ? chunkBig : chunkSmall;
        if (subIterated == chunkToUse) {
          final averaged = (subsum / subIterated) * multiplier;

          finalList.add(averaged);
          if (maxValue < averaged) maxValue = averaged;
          if (minValue > averaged) minValue = averaged;
          subsum = 0;
          subIterated = 0;
          usingChunkBig = !usingChunkBig;
        }
      }
    }
    // -- Case 2
    else if (length < targetSize) {
      final step = (length - 1) / (targetSize - 1);

      for (int i = 0; i < targetSize; i++) {
        final index = i * step;
        final lowerIndex = index.floor();
        final upperIndex = index.ceil();

        double toAdd;
        if (lowerIndex == upperIndex) {
          toAdd = this[lowerIndex] * multiplier;
        } else {
          final fraction = index - lowerIndex.toDouble();
          final interpolatedValue = this[lowerIndex] + (this[upperIndex] - this[lowerIndex]) * fraction;
          toAdd = interpolatedValue * multiplier;
        }

        finalList.add(toAdd);
        if (maxValue < toAdd) maxValue = toAdd;
        if (minValue > toAdd) minValue = toAdd;
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
      final enforce = enforceClampToMax?.call(minValue, maxValue) ?? false;
      final difference = clampToMax - maxValue;
      final maxValueInversed = math.pow(maxValue, -1);
      // map only if difference != 0
      return difference != 0
          ? enforce
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
