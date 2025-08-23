import 'package:dine/core/logger.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthErrorHandler {
  static void register(
    Map<Type, String Function(dynamic, {String? trace})> registry,
  ) {
    registry[AuthException] = _handleError;
    registry[AuthApiException] = _handleError;
  }

  static String _handleError(dynamic error, {String? trace}) {
    String translation = '';

    switch (error.code!.toLowerCase()) {
      // Authentication errors
      case 'invalid_credentials':
        translation =
            'Invalid email or password. Please check your credentials and try again.';

      case 'email_not_confirmed':
        translation =
            'Please verify your email address before signing in. Check your inbox for a confirmation link.';

      case 'phone_not_confirmed':
        translation = 'Please verify your phone number before signing in.';

      case 'user_not_found':
        translation =
            'No account found with this email address. Please sign up first.';

      case 'user_already_exists':
        translation =
            'An account with this email already exists. Please sign in instead.';

      case 'phone_exists':
        translation = 'An account with this phone number already exists.';

      case 'signup_disabled':
        translation =
            'New account creation is currently disabled. Please contact support.';

      case 'weak_password':
        translation =
            'Password is too weak. Please use a stronger password with at least 8 characters.';

      // Session errors
      case 'session_not_found':
        translation = 'Session not found. Please sign in again.';

      case 'session_expired':
        translation = 'Your session has expired. Please sign in again.';

      case 'bad_jwt':
        translation = 'Authentication token is invalid. Please sign in again.';

      case 'refresh_token_not_found':
        translation = 'Refresh token not found. Please sign in again.';

      case 'refresh_token_already_used':
        translation = 'Session refresh failed. Please sign in again.';

      // Rate limiting
      case 'over_email_send_rate_limit':
        translation =
            'Too many emails sent. Please wait a few minutes before trying again.';

      case 'over_sms_send_rate_limit':
        translation =
            'Too many SMS messages sent. Please wait a few minutes before trying again.';

      case 'over_request_rate_limit':
        translation =
            'Too many requests. Please wait a few minutes before trying again.';

      // Provider errors
      case 'provider_disabled':
        translation =
            'This sign-in method is not available. Please try a different method.';
      case 'oauth_provider_not_supported':
        translation =
            'This sign-in method is not available. Please try a different method.';

      case 'email_provider_disabled':
        translation =
            'Email sign-up is currently disabled. Please contact support.';

      case 'phone_provider_disabled':
        translation =
            'Phone sign-up is currently disabled. Please contact support.';

      // MFA errors
      case 'insufficient_aal':
        translation =
            'Additional authentication required. Please complete the security challenge.';

      case 'mfa_challenge_expired':
        translation = 'Security challenge expired. Please request a new one.';

      case 'mfa_factor_not_found':
        translation =
            'Security factor not found. Please set up authentication again.';

      // Network/connectivity issues
      case 'request_timeout':
        translation =
            'Request timed out. Please check your connection and try again.';

      case 'unexpected_failure':
        translation = 'An unexpected error occurred. Please try again later.';

      // Default fallback
      default:
        translation =
            'An authentication error occurred. Please try again or contact support if the problem persists.';
    }

    logger.authLog(translation, error: error, trace: trace);

    return translation;
  }
}
