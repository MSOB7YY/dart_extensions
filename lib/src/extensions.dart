import 'dart:math' as math;

String _heyPad(int n) => n.toString().padLeft(2, "0");

extension DESecondsLabel on int {
  String get milliSecondsLabel {
    if (this == 0) return "00:00";

    final val = abs();
    final suffix = isNegative ? '-' : '';

    final hours = val ~/ 3600000;
    final minutes = (val % 3600000) ~/ 60000;
    final seconds = (val % 60000) ~/ 1000;
    final durinHour = hours > 0 ? "${_heyPad(hours)}:" : '';
    return "$suffix$durinHour${_heyPad(minutes)}:${_heyPad(seconds)}";
  }

  String get milliSecondsLabelWithCentiSeconds {
    final msLabel = milliSecondsLabel;
    final val = abs();
    final centiseconds = (val % 1000) ~/ 10; // Convert ms to centiseconds
    return "$msLabel.${_heyPad(centiseconds)}";
  }

  String get secondsLabel => (this * 1000).milliSecondsLabel;
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

extension DEFileSizeFormat on int {
  String get fileSizeFormatted {
    const decimals = 2;
    if (this <= 0) return "0 B";
    const suffixes = ["B", "KB", "MB", "GB", "TB", "PB", "EB", "ZB", "YB"];
    final i = (math.log(this) / math.log(1024)).floor();
    return '${(this / math.pow(1024, i)).toStringAsFixed(decimals)} ${suffixes[i]}';
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

extension DEStuffUtils<T, R> on T {
  R toIf(R convertTo, T ifValueEquals) => this == ifValueEquals ? convertTo : this as R;
  R toIfValueIs(R convertTo, T Function(T value) ifValueEquals) => this == ifValueEquals(this) ? convertTo : this as R;
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

  Iterable<E> withLimit([int? limit]) => limit != null && limit < length ? take(limit) : this;

  List<E> toFixedList() => toList(growable: false);
}

extension DEExecuteIfBool on bool {
  void executeIfTrue<T>(T Function() execute) {
    if (this) execute();
  }

  void executeIfFalse<T>(T Function() execute) {
    if (!this) execute();
  }
}
