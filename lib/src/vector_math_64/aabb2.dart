/*
  Copyright (C) 2013 John McCutchan <john@johnmccutchan.com>

  This software is provided 'as-is', without any express or implied
  warranty.  In no event will the authors be held liable for any damages
  arising from the use of this software.

  Permission is granted to anyone to use this software for any purpose,
  including commercial applications, and to alter it and redistribute it
  freely, subject to the following restrictions:

  1. The origin of this software must not be misrepresented; you must not
     claim that you wrote the original software. If you use this software
     in a product, an acknowledgment in the product documentation would be
     appreciated but is not required.
  2. Altered source versions must be plainly marked as such, and must not be
     misrepresented as being the original software.
  3. This notice may not be removed or altered from any source distribution.

*/

part of vector_math_64;

/// Defines a 2-dimensional axis-aligned bounding box between a [min] and a
/// [max] position.
class Aabb2 {
  final Vector2 _min;
  final Vector2 _max;

  /// The minimum point defining the AABB.
  Vector2 get min => _min;
  /// The maximum point defining the AABB.
  Vector2 get max => _max;

  /// The center of the AABB.
  Vector2 get center => _min.clone()
      ..add(_max)
      ..scale(0.5);

  /// Create a new AABB with [min] and [max] set to the origin.
  Aabb2()
      : _min = new Vector2.zero(),
        _max = new Vector2.zero();

  /// Create a new AABB as a copy of [other].
  Aabb2.copy(Aabb2 other)
      : _min = new Vector2.copy(other._min),
        _max = new Vector2.copy(other._max);

  /// DEPREACTED: Use [minMax] instead.
  @deprecated
  Aabb2.minmax(Vector2 min, Vector2 max)
      : _min = new Vector2.copy(min),
        _max = new Vector2.copy(max);

  /// Create a new AABB with a [min] and [max].
  Aabb2.minMax(Vector2 min, Vector2 max)
      : _min = new Vector2.copy(min),
        _max = new Vector2.copy(max);

  /// Create a new AABB with a [center] and [halfExtents].
  Aabb2.centerAndHalfExtents(Vector2 center, Vector2 halfExtents)
      : _min = new Vector2.copy(center)..sub(halfExtents),
        _max = new Vector2.copy(center)..add(halfExtents);

  /// Constructs [Aabb2] with a min/max [storage] that views given [buffer]
  /// starting at [offset]. [offset] has to be multiple of
  /// [Float64List.BYTES_PER_ELEMENT].
  Aabb2.fromBuffer(ByteBuffer buffer, int offset)
      : _min = new Vector2.fromBuffer(buffer, offset),
        _max = new Vector2.fromBuffer(buffer, offset +
          Float64List.BYTES_PER_ELEMENT * 2);

  /// DEPREACTED: Removed copy min and max yourself
  @deprecated
  void copyMinMax(Vector2 min, Vector2 max) {
    max.setFrom(_max);
    min.setFrom(_min);
  }

  /// Copy the [center] and the [halfExtends] of [this].
  void copyCenterAndHalfExtents(Vector2 center, Vector2 halfExtents) {
    center
        ..setFrom(_min)
        ..add(_max)
        ..scale(0.5);
    halfExtents
        ..setFrom(_max)
        ..sub(_min)
        ..scale(0.5);
  }

  /// Copy the [min] and [max] from [other] into [this].
  void copyFrom(Aabb2 other) {
    _min.setFrom(other._min);
    _max.setFrom(other._max);
  }

  /// Copy the [min] and [max] from [this] into [other].
  void copyInto(Aabb2 other) {
    other._min.setFrom(_min);
    other._max.setFrom(_max);
  }

  /// Transform [this] by the transform [t].
  void transform(Matrix3 t) {
    final center = new Vector2.zero();
    final halfExtents = new Vector2.zero();
    copyCenterAndHalfExtents(center, halfExtents);
    t
        ..transform2(center)
        ..absoluteRotate2(halfExtents);
    _min
        ..setFrom(center)
        ..sub(halfExtents);
    _max
        ..setFrom(center)
        ..add(halfExtents);
  }

  /// Rotate [this] by the rotation matrix [t].
  void rotate(Matrix3 t) {
    final center = new Vector2.zero();
    final halfExtents = new Vector2.zero();
    copyCenterAndHalfExtents(center, halfExtents);
    t.absoluteRotate2(halfExtents);
    _min
        ..setFrom(center)
        ..sub(halfExtents);
    _max
        ..setFrom(center)
        ..add(halfExtents);
  }

  /// Create a copy of [this] that is transformed by the transform [t] and store
  /// it in [out].
  Aabb2 transformed(Matrix3 t, Aabb2 out) => out
      ..copyFrom(this)
      ..transform(t);

  /// Create a copy of [this] that is rotated by the rotation matrix [t] and
  /// store it in [out].
  Aabb2 rotated(Matrix3 t, Aabb2 out) => out
      ..copyFrom(this)
      ..rotate(t);

  /// Set the min and max of [this] so that [this] is a hull of [this] and
  /// [other].
  void hull(Aabb2 other) {
    Vector2.min(_min, other._min, _min);
    Vector2.max(_max, other._max, _max);
  }

  /// Set the min and max of [this] so that [this] contains [point].
  void hullPoint(Vector2 point) {
    Vector2.min(_min, point, _min);
    Vector2.max(_max, point, _max);
  }

  /// Return if [this] contains [other].
  bool containsAabb2(Aabb2 other) {
    final otherMax = other._max;
    final otherMin = other._min;

    return _min.x < otherMin.x && _min.y < otherMin.y && _max.y > otherMax.y &&
        _max.x > otherMax.x;
  }

  /// Return if [this] contains [other].
  bool containsVector2(Vector2 other) {
    final otherX = other[0];
    final otherY = other[1];

    return _min.x < otherX && _min.y < otherY && _max.x > otherX && _max.y >
        otherY;
  }

  /// Return if [this] intersects with [other].
  bool intersectsWithAabb2(Aabb2 other) {
    final otherMax = other._max;
    final otherMin = other._min;

    return _min.x <= otherMax.x && _min.y <= otherMax.y && _max.x >= otherMin.x
        && _max.y >= otherMin.y;
  }

  /// Return if [this] intersects with [other].
  bool intersectsWithVector2(Vector2 other) {
    final otherX = other[0];
    final otherY = other[1];

    return _min.x <= otherX && _min.y <= otherY && _max.x >= otherX && _max.y >=
        otherY;
  }
}