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

part of vector_math;

/**
 * Constructs a rotation matrix in [rotationMatrix].
 *
 * Sets [rotationMatrix] to a rotation matrix built from
 * [forwardDirection] and [upDirection]. The right direction is
 * constructed to be orthogonal to [forwardDirection] and
 * [upDirection].
 *
 * [forwardDirection] specifies the direction of the forward vector.
 * [upDirection] specifies the direction of the up vector.
 *
 * Use case is to build the per-model rotation matrix from vectors
 * [forwardDirection] and [upDirection]. See sample code below for
 * a context.
 * 
 * class Model {
 * 
 *   Vector3 _center = new Vector3.zero();        // per-model translation
 *   Vector3 _scale = new Vector3(1.0, 1.0, 1.0); // per-model scaling
 *   Matrix4 _rotation = new Matrix4.identity();  // per-model rotation
 *   Matrix4 _MV = new Matrix4.identity();        // per-model model-view
 * 
 *   void updateModelViewUniform(RenderingContext gl, UniformLocation u_MV,
 *       Vector3 camPosition, camFocusPosition, camUpDirection) {
 * 
 *     // V = View (inverse of camera)
 *     // T = Translation
 *     // R = Rotation
 *     // S = Scaling
 *     setViewMatrix(_MV, camPosition, camFocusPosition, camUpDirection); // MV = V
 *     _MV.translate(_center); // MV = V*T
 *     _MV.multiply(_rotation); // MV = V*T*R <-- _rotation is updated with setRotationMatrix(_rotation, forward, up);
 *     _MV.scale(_scale); // MV = V*T*R*S
 * 
 *     gl.uniformMatrix4fv(u_MV, false, _MV.storage);
 *   }
 * 
 * }
 */
void setRotationMatrix(Matrix4 rotationMatrix, Vector3 forwardDirection, upDirection) {
  Vector3 right = forwardDirection.cross(upDirection).normalize();
  rotationMatrix.setValues(forwardDirection[0], upDirection[0], right[0], 0.0,
    forwardDirection[1], upDirection[1], right[1], 0.0,
	forwardDirection[2], upDirection[2], right[2], 0.0,
	0.0, 0.0, 0.0, 1.0);
}

/// Constructs an OpenGL view matrix in [viewMatrix].
///
/// [cameraPosition] specifies the position of the camera.
/// [cameraFocusPosition] specifies the position the camera is focused on.
/// [upDirection] specifies the direction of the up vector (usually, +Y).
void setViewMatrix(Matrix4 viewMatrix, Vector3 cameraPosition, Vector3
    cameraFocusPosition, Vector3 upDirection) {
  final z = cameraPosition - cameraFocusPosition;
  z.normalize();
  final x = upDirection.cross(z);
  x.normalize();
  final y = z.cross(x);
  y.normalize();
  viewMatrix.setZero();
  viewMatrix.setEntry(3, 3, 1.0);
  viewMatrix.setEntry(0, 0, x.x);
  viewMatrix.setEntry(1, 0, x.y);
  viewMatrix.setEntry(2, 0, x.z);
  viewMatrix.setEntry(0, 1, y.x);
  viewMatrix.setEntry(1, 1, y.y);
  viewMatrix.setEntry(2, 1, y.z);
  viewMatrix.setEntry(0, 2, z.x);
  viewMatrix.setEntry(1, 2, z.y);
  viewMatrix.setEntry(2, 2, z.z);
  viewMatrix.transpose();
  //TODO (fox32): Why transpose? Can't we set the components right in the first place?
  final rotatedEye = cameraPosition.clone()..negate();
  viewMatrix.transform3(rotatedEye);
  viewMatrix.setEntry(0, 3, rotatedEye.x);
  viewMatrix.setEntry(1, 3, rotatedEye.y);
  viewMatrix.setEntry(2, 3, rotatedEye.z);
}

/// Constructs a new OpenGL view matrix.
///
/// [cameraPosition] specifies the position of the camera.
/// [cameraFocusPosition] specifies the position the camera is focused on.
/// [upDirection] specifies the direction of the up vector (usually, +Y).
Matrix4 makeViewMatrix(Vector3 cameraPosition, Vector3
    cameraFocusPosition, Vector3 upDirection) {
  final r = new Matrix4.zero();
  setViewMatrix(r, cameraPosition, cameraFocusPosition, upDirection);
  return r;
}

/// Constructs an OpenGL perspective projection matrix in [perspectiveMatrix].
///
/// [fovYRadians] specifies the field of view angle, in radians, in the y
/// direction.
/// [aspectRatio] specifies the aspect ratio that determines the field of view
/// in the x direction. The aspect ratio of x (width) to y (height).
/// [zNear] specifies the distance from the viewer to the near plane
/// (always positive).
/// [zFar] specifies the distance from the viewer to the far plane
/// (always positive).
void setPerspectiveMatrix(Matrix4 perspectiveMatrix, double fovYRadians, double
    aspectRatio, double zNear, double zFar) {
  final height = Math.tan(fovYRadians * 0.5) * zNear;
  final width = height * aspectRatio;
  setFrustumMatrix(perspectiveMatrix, -width, width, -height, height, zNear,
      zFar);
}

/// Constructs a new OpenGL perspective projection matrix.
///
/// [fovYRadians] specifies the field of view angle, in radians, in the y
/// direction.
/// [aspectRatio] specifies the aspect ratio that determines the field of view
/// in the x direction. The aspect ratio of x (width) to y (height).
/// [zNear] specifies the distance from the viewer to the near plane
/// (always positive).
/// [zFar] specifies the distance from the viewer to the far plane
/// (always positive).
Matrix4 makePerspectiveMatrix(double fovYRadians, double aspectRatio, double
    zNear, double zFar) {
  final height = Math.tan(fovYRadians * 0.5) * zNear;
  final width = height * aspectRatio;
  return makeFrustumMatrix(-width, width, -height, height, zNear, zFar);
}

/// Constructs an OpenGL perspective projection matrix in [perspectiveMatrix].
///
/// [left], [right] specify the coordinates for the left and right vertical
/// clipping planes.
/// [bottom], [top] specify the coordinates for the bottom and top horizontal
/// clipping planes.
/// [near], [far] specify the coordinates to the near and far depth clipping
/// planes.
void setFrustumMatrix(Matrix4 perspectiveMatrix, double left, double
    right, double bottom, double top, double near, double far) {
  final two_near = 2.0 * near;
  final right_minus_left = right - left;
  final top_minus_bottom = top - bottom;
  final far_minus_near = far - near;
  final view = perspectiveMatrix.setZero();
  view.setEntry(0, 0, two_near / right_minus_left);
  view.setEntry(1, 1, two_near / top_minus_bottom);
  view.setEntry(0, 2, (right + left) / right_minus_left);
  view.setEntry(1, 2, (top + bottom) / top_minus_bottom);
  view.setEntry(2, 2, -(far + near) / far_minus_near);
  view.setEntry(3, 2, -1.0);
  view.setEntry(2, 3, -(two_near * far) / far_minus_near);
}

/// Constructs a new OpenGL perspective projection matrix.
///
/// [left], [right] specify the coordinates for the left and right vertical
/// clipping planes.
/// [bottom], [top] specify the coordinates for the bottom and top horizontal
/// clipping planes.
/// [near], [far] specify the coordinates to the near and far depth clipping
/// planes.
Matrix4 makeFrustumMatrix(double left, double right, double bottom, double
    top, double near, double far) {
  final view = new Matrix4.zero();
  setFrustumMatrix(view, left, right, bottom, top, near, far);
  return view;
}

/// Constructs an OpenGL orthographic projection matrix in [orthographicMatrix].
///
/// [left], [right] specify the coordinates for the left and right vertical
/// clipping planes.
/// [bottom], [top] specify the coordinates for the bottom and top horizontal
/// clipping planes.
/// [near], [far] specify the coordinates to the near and far depth clipping
/// planes.
void setOrthographicMatrix(Matrix4 orthographicMatrix, double left, double
    right, double bottom, double top, double near, double far) {
  final rml = right - left;
  final rpl = right + left;
  final tmb = top - bottom;
  final tpb = top + bottom;
  final fmn = far - near;
  final fpn = far + near;
  final r = orthographicMatrix.setZero();
  r.setEntry(0, 0, 2.0 / rml);
  r.setEntry(1, 1, 2.0 / tmb);
  r.setEntry(2, 2, -2.0 / fmn);
  r.setEntry(0, 3, -rpl / rml);
  r.setEntry(1, 3, -tpb / tmb);
  r.setEntry(2, 3, -fpn / fmn);
  r.setEntry(3, 3, 1.0);
}

/// Constructs a new OpenGL orthographic projection matrix.
///
/// [left], [right] specify the coordinates for the left and right vertical
/// clipping planes.
/// [bottom], [top] specify the coordinates for the bottom and top horizontal
/// clipping planes.
/// [near], [far] specify the coordinates to the near and far depth clipping
/// planes.
Matrix4 makeOrthographicMatrix(double left, double right, double bottom, double
    top, double near, double far) {
  final r = new Matrix4.zero();
  setOrthographicMatrix(r, left, right, bottom, top, near, far);
  return r;
}

/// Returns a transformation matrix that transforms points onto
/// the plane specified with [planeNormal] and [planePoint].
Matrix4 makePlaneProjection(Vector3 planeNormal, Vector3 planePoint) {
  final v = new Vector4(planeNormal.storage[0], planeNormal.storage[1],
      planeNormal.storage[2], 0.0);
  final outer = new Matrix4.outer(v, v);
  final r = new Matrix4.zero()..sub(outer);
  final scaledNormal = planeNormal.scaled(dot3(planePoint, planeNormal));
  final t = new Vector4(scaledNormal.storage[0], scaledNormal.storage[1],
      scaledNormal.storage[2], 1.0);
  r.setColumn(3, t);
  return r;
}

/// Returns a transformation matrix that transforms points by reflecting
/// them through the plane specified with [planeNormal] and [planePoint]
Matrix4 makePlaneReflection(Vector3 planeNormal, Vector3 planePoint) {
  final v = new Vector4(planeNormal.storage[0], planeNormal.storage[1],
      planeNormal.storage[2], 0.0);
  final outer = new Matrix4.outer(v, v)..scale(2.0);
  final r = new Matrix4.zero()..sub(outer);
  final scale = 2.0 * dot3(planePoint, planeNormal);
  final scaledNormal = planeNormal.scaled(scale);
  final t = new Vector4(scaledNormal.storage[0], scaledNormal.storage[1],
      scaledNormal.storage[2], 1.0);
  r.setColumn(3, t);
  return r;
}

/// On success, Sets [pickWorld] to be the world space position of
/// the screen space [pickX], [pickY], and [pickZ].
///
/// The viewport is specified by ([viewportX], [viewportWidth]) and
/// ([viewportY], [viewportHeight]).
///
/// [cameraMatrix] includes both the projection and view transforms.
///
/// [pickZ] is typically either 0.0 (near plane) or 1.0 (far plane).
///
/// Returns [false] on error, for example, the mouse is not in the viewport.
bool unproject(Matrix4 cameraMatrix, double viewportX, double
    viewportWidth, double viewportY, double viewportHeight, double pickX, double
    pickY, double pickZ, Vector3 pickWorld) {
  pickX = pickX - viewportX;
  pickY = pickY - viewportY;
  pickX = (2.0 * pickX / viewportWidth) - 1.0;
  pickY = (2.0 * pickY / viewportHeight) - 1.0;
  pickZ = (2.0 * pickZ) - 1.0;

  // Check if pick point is inside unit cube
  if (pickX < -1.0 || pickY < -1.0 || pickX > 1.0 || pickY > 1.0 || pickZ < -1.0
      || pickZ > 1.0) {
    return false;
  }

  // Copy camera matrix.
  final invertedCameraMatrix = new Matrix4.copy(cameraMatrix);
  // Invert the camera matrix.
  invertedCameraMatrix.invert();
  // Determine intersection point.
  final v = new Vector4(pickX, pickY, pickZ, 1.0);
  invertedCameraMatrix.transform(v);
  if (v.w == 0.0) {
    return false;
  }
  final invW = 1.0 / v.w;
  pickWorld.x = v.x * invW;
  pickWorld.y = v.y * invW;
  pickWorld.z = v.z * invW;

  return true;
}

/// On success, [rayNear] and [rayFar] are the points where
/// the screen space [pickX], [pickY] intersect with the near and far
/// planes respectively.
///
/// The viewport is specified by ([viewportX], [viewportWidth]) and
/// ([viewportY], [viewportHeight]).
///
/// [cameraMatrix] includes both the projection and view transforms.
///
/// Returns [false] on error, for example, the mouse is not in the viewport.
bool pickRay(Matrix4 cameraMatrix, double viewportX, double
    viewportWidth, double viewportY, double viewportHeight, double pickX, double
    pickY, Vector3 rayNear, Vector3 rayFar) {
  var r = unproject(cameraMatrix, viewportX, viewportWidth, viewportY,
      viewportHeight, pickX, viewportHeight - pickY, 0.0, rayNear);

  if (!r) {
    return false;
  }

  r = unproject(cameraMatrix, viewportX, viewportWidth, viewportY,
      viewportHeight, pickX, viewportHeight - pickY, 1.0, rayFar);

  return r;
}
