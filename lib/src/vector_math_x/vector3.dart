import 'dart:typed_data';

extension type Vector3.fromFloat32List(Float32List _storage) {
  Vector3.zero() : this.fromFloat32List(Float32List(3));

  factory Vector3(double x, double y, double z) =>
      Vector3.zero()..setValues(x, y, z);

  factory Vector3.all(double value) => Vector3.zero()..splat(value);

  factory Vector3.copy(Vector3 other) => Vector3.zero()..setFrom(other);

  void add(Vector3 arg) {
    final argStorage = arg._storage;
    _storage[2] += argStorage[2];
    _storage[1] += argStorage[1];
    _storage[0] += argStorage[0];
  }

  void setValues(double x, double y, double z) {
    _storage[2] = z;
    _storage[1] = y;
    _storage[0] = x;
  }

  void splat(double value) {
    _storage[2] = value;
    _storage[1] = value;
    _storage[0] = value;
  }

  void setFrom(Vector3 other) {
    final otherStorage = other._storage;
    _storage[2] = otherStorage[2];
    _storage[1] = otherStorage[1];
    _storage[0] = otherStorage[0];
  }

  Vector3 clone() => Vector3.copy(this);
}
