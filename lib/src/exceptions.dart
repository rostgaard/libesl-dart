// Copyright (c) 2016, Kim Rostgaard Christensen. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be found
// in the LICENSE file.

/// Library-specific exceptions.
library esl.exceptions;

/// General ESL exception. Useful for catching exceptions thrown by this
/// library.
class EslException implements Exception {}

/// Thrown when an authentication failure occurs within an authentication
/// handler. May be used be outside of the library.
class AuthenticationFailure implements EslException {
  /// The message carried in the exception.
  final String message;

  /// Default constructor. Takes in the optional [message] argument, which
  /// is empty, if omitted.
  const AuthenticationFailure([this.message = ""]);

  /// Returns a string representation of the object.
  @override
  String toString() => "AuthenticationFailure: $message";
}
