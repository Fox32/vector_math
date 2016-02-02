// Copyright (c) 2015, Google Inc. Please see the AUTHORS file for details.
// All rights reserved. Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.

part of vector_math_64;

/// Defines a plane in the Hessian normal form, by a [normal] and a [constant]
/// that is the plane's distance to the origin.
class Plane {
  final Vector3 _normal;
  double _constant;

  /// Find the intersection point between the three planes [a], [b] and [c] and
  /// copy it into [result].
  static void intersection(Plane a, Plane b, Plane c, Vector3 result) {
    final cross = new Vector3.zero();

    b.normal.crossInto(c.normal, cross);

    final f = -a.normal.dot(cross);

    final v1 = cross.scaled(a.constant);

    c.normal.crossInto(a.normal, cross);

    final v2 = cross.scaled(b.constant);

    a.normal.crossInto(b.normal, cross);

    final v3 = cross.scaled(c.constant);

    result.x = (v1.x + v2.x + v3.x) / f;
    result.y = (v1.y + v2.y + v3.y) / f;
    result.z = (v1.z + v2.z + v3.z) / f;
  }

  /// The [normal] that defines the plane.
  Vector3 get normal => _normal;
  /// The [constant] that is the distance between the plane and the origin.
  double get constant => _constant;
  set constant(double value) => _constant = value;

  /// Create a new plane.
  Plane()
      : _normal = new Vector3.zero(),
        _constant = 0.0;

  /// Create a new plane as a copy of [other].
  Plane.copy(Plane other)
      : _normal = new Vector3.copy(other._normal),
        _constant = other._constant;

  /// Create a plane with its' [x], [y], [z], and [w] components.
  Plane.components(double x, double y, double z, double w)
      : _normal = new Vector3(x, y, z),
        _constant = w;

  /// DEPRECATED: Use normalConstant constructor instead.
  @deprecated
  factory Plane.normalconstant(Vector3 normal, double constant) =>
      new Plane.normalConstant(normal, constant);

  /// Create a plane with its' [normal] and [constant].
  Plane.normalConstant(Vector3 normal, double constant)
      : _normal = new Vector3.copy(normal),
        _constant = constant;

  /// Create a plane with a [normal] and a [point] lying on the plane.
  factory Plane.normalPoint(Vector3 normal, Vector3 point) =>
      new Plane()..setFromNormalPoint(normal, point);

  /// Copy the plane from [other].
  void copyFrom(Plane other) {
    _normal.setFrom(other._normal);
    _constant = other._constant;
  }

  /// Set the plane's [normal] and [constant].
  void setFromNormalConstant(Vector3 normal, double constant) {
    _normal.setFrom(normal);
    _constant = constant;
  }

  /// Set the plane from a [normal] and a [point] lying on the plane.
  void setFromNormalPoint(Vector3 normal, Vector3 point) {
    _normal.setFrom(normal);

    //TODO: !!!
  }

  /// Set the plane's [x], [y], [z], and [w] components.
  void setFromComponents(double x, double y, double z, double w) {
    _normal.setValues(x, y, z);
    _constant = w;
  }

  /// Normalize the [normal] of the plane.
  void normalize() {
    var inverseLength = 1.0 / normal.length;
    _normal.scale(inverseLength);
    _constant *= inverseLength;
  }

  /// Calculate the distance between the plane and [point].
  double distanceToVector3(Vector3 point) {
    return _normal.dot(point) + _constant;
  }
}
