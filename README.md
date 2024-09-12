## A Collection of useful dart extensions to speed up & enhance coding experience.


### Some of the custom algorithms

- [`List<num>.changeListSize()`](./lib/src/list_extensions.dart#L316)
   - manipulates list size while keeping it relative
```dart
  final originalList = [1, 3, 5, 7];
  final smallerList = originalList.changeListSize(targetSize: 3);
  print(smallerList); // [1.0, 3.0, 6.0]
  final biggerList = originalList.changeListSize(targetSize: 6);
  print(biggerList); // [1.0, 2.2, 3.4, 4.6, 5.8, 7.0]

  // - Having a [targetSize] == null allows for using other parameters while retaining same list size.
  //
  // - [multiplier] multiplies each value with it, ex:
  [1, 2, 4].changeListSize(multiplier: 2.0) => [2, 4, 8]

  //
  // - [clampToMax] gives all values a push to have a final list with max value == `clampToMax`, while keeping relative relation, ex:

  [1, 2, 4].changeListSize(clampToMax: 5.0) => [2, 3, 5] // each value increased by the difference needed to make the max value reach [clampToMax]
  [1, 2, 4].changeListSize(clampToMax: 3.0) => [0, 1, 3] // each value decreased by the difference needed to make the max value reach [clampToMax]

  // Setting [enforceClampToMax] to false means using an inverse relation between max value and given [clampToMax],
  // resulting in a consistent increase rate relavent to max value, for example, using [clampToMax] of 50.0:
  // 1. maxValue == 40 => will give all values 5 => max = 45
  // 2. maxValue == 20 => will give all values 20 => max = 40
```

- [`List.move()`](./lib/src/list_extensions.dart#L270)
  - Better alternative for [removeAt] & [insert].
  - The closer the gap between [oldIndex] and [newIndex], the more performance will be noticed compared to [removeAt] & [insert].
```dart
final list = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10];
list.move(8, 2);
print(list); // [1, 2, 9, 3, 4, 5, 6, 7, 8, 10]
```

- [`String.splitFirst()`](./lib/src/string_extensions.dart#L181)
  - a more efficient way of `String.split().first`. the string has to be 1 character length.
```dart
const text = "This is a text.";
final part = text.splitFirst(' ');
print(part); // 'This'
```

- [`String.splitLast()`](./lib/src/string_extensions.dart#L188)
  - a more efficient way of `String.split().last`. the string has to be 1 character length.
```dart
const text = "This is a text.";
final part = text.splitLast(' ');
print(part); // 'text.'
```

- [`Map.reAssign()`](./lib/src/map_extensions.dart#L81)
  - re-assigns [oldKey] with [newKey] to the map while maintaining the same order.
```dart
final map = {1: 'a', 2: 'b', 3: 'c'};
map.reAssign(2, 6);
print(map); // {1: 'a', 6: 'b', 3: 'c'}
```
