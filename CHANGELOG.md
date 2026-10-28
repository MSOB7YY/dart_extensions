## 2.0.8

- `writeAsJson` and `writeAsJsonSync` write directly again. The atomic writes moved to `writeAsJsonAtomic` and `writeAsJsonAtomicSync`
- `writeAsBytesAtomic` and `writeAsStringAtomic` (and their sync twins) for atomic writes of raw bytes or text
- `Directory.listFilesWithoutAtomicTemps` (and its sync twin) lists the files of a folder without the temp files of the atomic writes

## 2.0.7

- `writeAsJson` and `writeAsJsonSync` write atomically (temp file + rename), a kill midway keeps the old file whole
- `writeAsJson` creates missing folders only when the write fails

## 1.0.5

- convert to pure dart