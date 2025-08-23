import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

class LoggerService {
  static final LoggerService _instance = LoggerService._internal();
  factory LoggerService() => _instance;
  LoggerService._internal();

  Logger? _logger;
  bool _isInitialized = false;

  void initialize() {
    try {
      _logger = Logger(
        level: kDebugMode ? Level.debug : Level.info,
        filter: kDebugMode ? DevelopmentFilter() : ProductionFilter(),
        printer: PrettyPrinter(
          methodCount: 0,
          errorMethodCount: 0,
          lineLength: 120,
          colors: true,
          printEmojis: true,
          dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
        ),
        output: ConsoleOutput(),
      );
      _isInitialized = true;
    } catch (e) {
      // Fallback to print if logger initialization fails
      if (kDebugMode) {
        print('Failed to initialize logger: $e');
      }
    }
  }

  bool get isInitialized => _isInitialized;

  // General Logging
  void debug(
    String message, {
    String? trace,
    Object? error,
    StackTrace? stackTrace,
  }) {
    if (_logger != null) {
      _logger!.d(
        '$message ${trace != null ? '($trace)' : ''}',
        error: error,
        stackTrace: stackTrace,
      );
    } else if (kDebugMode) {
      print('DEBUG: $message ${trace != null ? '($trace)' : ''}');
    }
  }

  void info(
    String message, {
    String? trace,
    Object? error,
    StackTrace? stackTrace,
  }) {
    if (_logger != null) {
      _logger!.i(
        '$message ${trace != null ? '($trace)' : ''}',
        error: error,
        stackTrace: stackTrace,
      );
    } else if (kDebugMode) {
      print('INFO: $message ${trace != null ? '($trace)' : ''}');
    }
  }

  void warning(
    String message, {
    String? trace,
    Object? error,
    StackTrace? stackTrace,
  }) {
    if (_logger != null) {
      _logger!.w(
        '$message ${trace != null ? '($trace)' : ''}',
        error: error,
        stackTrace: stackTrace,
      );
    } else if (kDebugMode) {
      print('WARNING: $message ${trace != null ? '($trace)' : ''}');
    }
  }

  void error(
    String message, {
    String? trace,
    Object? error,
    StackTrace? stackTrace,
  }) {
    if (_logger != null) {
      _logger!.e(
        '$message ${trace != null ? '($trace)' : ''}',
        error: error,
        stackTrace: stackTrace,
      );
    } else if (kDebugMode) {
      print('ERROR: $message ${trace != null ? '($trace)' : ''}');
    }
  }

  void fatal(
    String message, {
    String? trace,
    Object? error,
    StackTrace? stackTrace,
  }) {
    if (_logger != null) {
      _logger!.f(
        '$message ${trace != null ? '($trace)' : ''}',
        error: error,
        stackTrace: stackTrace,
      );
    } else if (kDebugMode) {
      print('FATAL: $message ${trace != null ? '($trace)' : ''}');
    }
  }

  // Simple domain logging
  void _domainLog(
    String domain,
    String action, {
    Map<String, dynamic>? data,
    Object? error,
    StackTrace? stackTrace,
  }) {
    final message = '$domain: $action';
    final logData = data != null ? {data} : null;

    if (_logger != null) {
      if (error != null) {
        _logger!.e(message, error: logData, stackTrace: stackTrace);
      } else {
        _logger!.i(message, error: logData, stackTrace: stackTrace);
      }
    } else if (kDebugMode) {
      final prefix = error != null ? 'ERROR' : 'INFO';
      print('$prefix: $message ${data ?? ''}');
    }
  }

  // Domain-specific methods (simplified)
  void authLog(
    String action, {
    String? userId,
    String? email,
    Object? error,
    String? trace,
  }) {
    _domainLog(
      'AUTH ${trace != null ? '($trace)' : ''}',
      action,
      data: {
        if (userId != null) 'userId': userId,
        if (email != null) 'email': email,
      },
      error: error,
    );
  }

  void postgrestLog(
    String action, {
    Object? error,
    StackTrace? stackTrace,
    String? trace,
  }) {
    _domainLog(
      'POSTGREST ${trace != null ? '($trace)' : ''}',
      action,
      error: error,
      stackTrace: stackTrace,
    );
  }

  void sessionLog(
    String action, {
    String? sessionId,
    String? classId,
    Object? error,
    String? trace,
  }) {
    _domainLog(
      'SESSION ${trace != null ? '($trace)' : ''}',
      action,
      data: {
        if (sessionId != null) 'sessionId': sessionId,
        if (classId != null) 'classId': classId,
        if (error != null) 'error': error,
      },
      error: error,
    );
  }

  void classLog(
    String action, {
    String? classId,
    Object? error,
    String? trace,
  }) {
    _domainLog(
      'CLASS ${trace != null ? '($trace)' : ''}',
      action,
      data: {
        if (classId != null) 'classId': classId,
        if (error != null) 'error': error,
      },
      error: error,
    );
  }

  void userLog(
    String action, {
    String? userId,
    String? email,
    Object? error,
    String? trace,
  }) {
    _domainLog(
      'USER ${trace != null ? '($trace)' : ''}',
      action,
      data: {
        if (userId != null) 'userId': userId,
        if (email != null) 'email': email,
      },
      error: error,
    );
  }

  void qrLog(
    String action, {
    String? sessionId,
    String? classId,
    Object? error,
    String? trace,
  }) {
    _domainLog(
      'QR ${trace != null ? '($trace)' : ''}',
      action,
      data: {
        if (sessionId != null) 'sessionId': sessionId,
        if (classId != null) 'classId': classId,
        if (error != null) 'error': error,
      },
      error: error,
    );
  }

  void locationLog(
    String action, {
    String? classId,
    String? sessionId,
    Object? error,
    String? trace,
  }) {
    _domainLog(
      'LOCATION ${trace != null ? '($trace)' : ''}',
      action,
      data: {
        if (classId != null) 'classId': classId,
        if (sessionId != null) 'sessionId': sessionId,
        if (error != null) 'error': error,
      },
      error: error,
    );
  }

  void excelLog(
    String action, {
    String? classId,
    String? sessionId,
    Object? error,
    String? trace,
  }) {
    _domainLog(
      'EXCEL ${trace != null ? '($trace)' : ''}',
      action,
      data: {
        if (classId != null) 'classId': classId,
        if (sessionId != null) 'sessionId': sessionId,
        if (error != null) 'error': error.toString(),
      },
      error: error,
    );
  }
}

final logger = LoggerService();
