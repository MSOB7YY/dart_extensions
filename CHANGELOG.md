## 2.0.7

- `writeAsJson` and `writeAsJsonSync` write atomically (temp file + rename), a kill midway keeps the old file whole
- `writeAsJson` creates missing folders only when the write fails

## 1.0.5

- convert to pure dart