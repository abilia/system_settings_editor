// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a en locale. All the
// messages from the main program should be duplicated here with the same
// function name.

// Ignore issues from commonly used lints in this file.
// ignore_for_file:unnecessary_brace_in_string_interps
// ignore_for_file:prefer_single_quotes,comment_references, directives_ordering
// ignore_for_file:annotate_overrides,prefer_generic_function_type_aliases
// ignore_for_file:unused_import, file_names

import 'package:intl/intl.dart';
import 'package:intl/message_lookup_by_library.dart';

final messages = MessageLookup();

typedef String? MessageIfAbsent(String? messageStr, List<Object>? args);

class MessageLookup extends MessageLookupByLibrary {
  @override
  String get localeName => 'en';

  @override
  final Map<String, dynamic> messages =
      _notInlinedMessages(_notInlinedMessages);

  static Map<String, dynamic> _notInlinedMessages(_) => {
        'connectToInternet': MessageLookupByLibrary.simpleMessage(
            'Connect to the internet to continue.'),
        'lincenseExpired': MessageLookupByLibrary.simpleMessage(
            'Your license expired, please connect support to extend license.'),
        'logOut': MessageLookupByLibrary.simpleMessage('Log out'),
        'noHandiLicence': MessageLookupByLibrary.simpleMessage(
            'You need to have Handi Calendar licence to be able to use app.'),
        'password': MessageLookupByLibrary.simpleMessage('Password'),
        'signIn': MessageLookupByLibrary.simpleMessage('Log in'),
        'somethingWentWrong': MessageLookupByLibrary.simpleMessage(
            'Something went wrong on our side. Please try again later.'),
        'sync': MessageLookupByLibrary.simpleMessage('Sync'),
        'tooManyAttempts': MessageLookupByLibrary.simpleMessage(
            'Please, wait a moment before you can try again.'),
        'unsupportedUserType': MessageLookupByLibrary.simpleMessage(
            'You need to have myAbilia account with type “User” to be able use Handi calendar app.'),
        'userNameOrEmail':
            MessageLookupByLibrary.simpleMessage('Username or email address'),
        'verifyCredentials': MessageLookupByLibrary.simpleMessage(
            'Username or password doesn’t match. Verify your credentials and try again.'),
        'welcomeToHandi':
            MessageLookupByLibrary.simpleMessage('Welcome to Handi!')
      };
}
