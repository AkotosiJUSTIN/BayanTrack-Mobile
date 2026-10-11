class AppVersion implements Comparable<AppVersion> {
  AppVersion(this.name, this.build) {
    if (!RegExp(r'^(0|[1-9]\d*)\.(0|[1-9]\d*)\.(0|[1-9]\d*)$').hasMatch(name) ||
        build < 1 ||
        build > 2100000000) {
      throw const FormatException('Invalid app version.');
    }
  }

  final String name;
  final int build;

  factory AppVersion.parse(String value) {
    if (!RegExp(r'^[0-9]+\.[0-9]+\.[0-9]+\+[1-9][0-9]*$').hasMatch(value)) {
      throw const FormatException('Invalid app version.');
    }
    final parts = value.split('+');
    return AppVersion(parts[0], int.parse(parts[1]));
  }

  @override
  int compareTo(AppVersion other) {
    final left = name.split('.').map(int.parse).toList();
    final right = other.name.split('.').map(int.parse).toList();
    for (var index = 0; index < 3; index++) {
      final result = left[index].compareTo(right[index]);
      if (result != 0) return result;
    }
    return build.compareTo(other.build);
  }

  @override
  String toString() => '$name+$build';
}
