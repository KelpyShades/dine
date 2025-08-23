import 'package:dine/core/logger.dart';

class UnknownErrorHandler {
  static String handleError(dynamic error, {String? trace}) {
    logger.error("An unknown error occurred: $error", error: error, trace: trace);
    return "An unknown error occurred! Please try again later.";
  }
}