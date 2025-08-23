import 'dart:async';
import 'package:dine/core/error_handling/contexts/auth_error_handler.dart';
import 'package:dine/core/error_handling/contexts/network_error_handler.dart';
import 'package:dine/core/error_handling/contexts/postgres_error_handler.dart';
import 'package:dine/core/error_handling/contexts/unknown_error_handler.dart';
import 'package:dine/core/snackbar.dart';
import 'package:flutter/widgets.dart';

Future<T?> asyncErrorWrapper<T>(
  Future<T> Function() operation, {
  T Function()? finallyOperation,
  BuildContext? context,
  String? successMessage,
  String? errorMessage,
  String? debugTrace,
}) async {
  try {
    final result = await operation();

    if (successMessage != null && context != null && context.mounted) {
      customSnackbar(successMessage, type: SnackType.success, context: context);
    }

    return result;
  } catch (e) {
    print(e);
    if (context != null && context.mounted) {
      ErrorTranslator.translate(
        e,
        errorMessage: errorMessage,
        context: context,
        trace: debugTrace,
      );
      // customSnackbar(
      //   errorMessage ?? translation,
      //   type: type ?? SnackType.error,
      //   context: context,
      // );
      if (finallyOperation != null) {
        finallyOperation();
      }
      return null;
    } else {
      rethrow;
    }
  }
}

T? syncErrorWrapper<T>(
  T Function() operation, {
  T Function()? finallyOperation,
  BuildContext? context,
  String? successMessage,
  String? errorMessage,
  String? debugTrace,
}) {
  try {
    final result = operation();

    if (successMessage != null && context != null && context.mounted) {
      customSnackbar(successMessage, type: SnackType.success, context: context);
    }

    return result;
  } catch (e) {
    if (context != null && context.mounted) {
      ErrorTranslator.translate(
        e,
        errorMessage: errorMessage,
        context: context,
        trace: debugTrace,
      );
      if (finallyOperation != null) {
        finallyOperation();
      }
      return null;
    } else {
      rethrow;
    }
  }
}

// lib/common/error_handling/error_translator.dart

class ErrorTranslator {
  // The registry maps error types to their handlers
  static final Map<Type, String Function(dynamic, {String? trace})>
  _errorHandlers = {};

  // Static initialization - each handler registers itself
  static void _initializeHandlers() {
    if (_errorHandlers.isNotEmpty) return; // Already initialized

    NetworkErrorHandler.register(_errorHandlers);

    AuthErrorHandler.register(_errorHandlers);

    PostgresErrorHandler.register(_errorHandlers);

    // More handlers can be added here as the app grows
  }

  static void translate(
    dynamic error, {
    String? errorMessage,
    BuildContext? context,
    SnackType? type,
    String? trace,
  }) {
    _initializeHandlers();

    // Look up the handler for this specific error type
    String translation = '';

    final handler =
        _errorHandlers[error
            .runtimeType]; // TODO: uncomment and change to errorObject accordingly after migrating to riverpod 3.0

    if (handler == null) {
      translation = UnknownErrorHandler.handleError(error, trace: trace);
    } else {
      translation = handler(error, trace: trace);
    }

    if (context != null) {
      customSnackbar(
        errorMessage ?? translation,
        type: type ?? SnackType.error,
        context: context,
      );
    }
  }
}
