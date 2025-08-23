import 'package:dine/core/logger.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PostgresErrorHandler {
  static void register(Map<Type, String Function(dynamic, {String? trace})> registry) {
    registry[PostgrestException] = _handleError;
  }
 
  static String _handleError(dynamic error, {String? trace}) {
    String translation = '';
    // Check HTTP status code first
    switch (error.code) {
      case '401':
        translation = 'Authentication required. Please sign in and try again.';

      case '403':
        translation = 'You don\'t have permission to perform this action.';

      case '404':
        translation = 'The requested resource was not found or you don\'t have access to it.';

      case '409':
        translation = _handleConflictError(error);

      case '413':
        translation = 'The data you\'re trying to upload is too large. Please reduce the size and try again.';

      case '422':
        translation = _handleValidationError(error);

      case '429':
        translation = 'Too many requests. Please wait a moment before trying again.';

      case '500':
        translation = 'Server error occurred. Please try again later or contact support.';

      case '503':
        translation = 'Service is temporarily unavailable. Please try again in a few moments.';

      default:
        translation = _handleSpecificErrors(error);
    }

    logger.postgrestLog(translation, error: error, trace: trace);

    return translation;
  }

  static String _handleConflictError(PostgrestException error) {
    final message = error.message.toLowerCase();

    if (message.contains('unique') || message.contains('duplicate')) {
      if (message.contains('email')) {
        return 'An account with this email already exists.';
      } else if (message.contains('phone')) {
        return 'An account with this phone number already exists.';
      } else if (message.contains('class_code')) {
        return 'A class with this code already exists.';
      } else if (message.contains('unique_id')) {
        return 'This ID is already taken. Please choose a different one.';
      }

      return 'This information already exists. Please use different details.';
    }

    return 'A conflict occurred while saving your data. Please try again.';
  }

  static String _handleValidationError(PostgrestException error) {
    final message = error.message.toLowerCase();

    if (message.contains('foreign key')) {
      return 'Invalid reference. The related data may have been deleted.';
    } else if (message.contains('check constraint')) {
      return 'Invalid data format. Please check your input and try again.';
    } else if (message.contains('not null')) {
      return 'Required information is missing. Please fill in all required fields.';
    } else if (message.contains('invalid input syntax')) {
      return 'Invalid data format. Please check your input.';
    }

    return 'Invalid data provided. Please check your input and try again.';
  }

  static String _handleSpecificErrors(PostgrestException error) {
    final message = error.message.toLowerCase();

    // RLS (Row Level Security) errors
    if (message.contains('policy') || message.contains('rls')) {
      return 'You don\'t have permission to access this data.';
    }

    // Connection errors
    if (message.contains('connection') || message.contains('timeout')) {
      return 'Database connection issue. Please check your internet and try again.';
    }

    // Column/table errors
    if (message.contains('column') && message.contains('does not exist')) {
      return 'Data structure error. Please contact support.';
    }

    if (message.contains('table') && message.contains('does not exist')) {
      return 'Resource not found. Please contact support.';
    }

    // JSON errors
    if (message.contains('json') || message.contains('jsonb')) {
      return 'Invalid data format. Please try again.';
    }

    // Array errors
    if (message.contains('array')) {
      return 'Invalid list data. Please check your input.';
    }

    // Type conversion errors
    if (message.contains('invalid input syntax for type')) {
      return 'Invalid data type. Please check your input format.';
    }

    // Permission errors
    if (message.contains('permission denied')) {
      return 'Permission denied. You don\'t have access to this resource.';
    }

    // Rate limiting
    if (message.contains('rate limit') ||
        message.contains('too many requests')) {
      return 'Too many requests. Please wait before trying again.';
    }

    // Generic fallback with error code for debugging

    return 'Database error occurred. Please try again or contact support if the problem persists.';
  }
}
