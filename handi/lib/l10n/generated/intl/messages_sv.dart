// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a sv locale. All the
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
  String get localeName => 'sv';

  @override
  final Map<String, dynamic> messages =
      _notInlinedMessages(_notInlinedMessages);

  static Map<String, dynamic> _notInlinedMessages(_) => {
        'connectToInternet': MessageLookupByLibrary.simpleMessage(
            'Anslut till internet för att fortsätta.'),
        'lincenseExpired': MessageLookupByLibrary.simpleMessage(
            'Din licens har upphört, vänligen kontakta support och förläng licensen.'),
        'logOut': MessageLookupByLibrary.simpleMessage('Logga ut'),
        'noHandiLicence': MessageLookupByLibrary.simpleMessage(
            'Du behöver en Handi licens för att kunna använda appen.'),
        'password': MessageLookupByLibrary.simpleMessage('Lösenord'),
        'signIn': MessageLookupByLibrary.simpleMessage('Logga in'),
        'somethingWentWrong': MessageLookupByLibrary.simpleMessage(
            'Något gick fel på vår sida, vänligen försök igen senare.'),
        'sync': MessageLookupByLibrary.simpleMessage('Synkronisera'),
        'tooManyAttempts': MessageLookupByLibrary.simpleMessage(
            'För många försök. Vänligen vänta en stund innan du försöker igen.'),
        'unsupportedUserType': MessageLookupByLibrary.simpleMessage(
            'Du behöver ett myAbilia konto med typen \"Användare\" för att kunna använda Handi appen.'),
        'userNameOrEmail': MessageLookupByLibrary.simpleMessage(
            'Användarnamn eller e-postadress'),
        'verifyCredentials': MessageLookupByLibrary.simpleMessage(
            'Användarnamn eller lösenord stämmer inte överens. Verifiera dina uppgifter och försök igen'),
        'welcomeToHandi':
            MessageLookupByLibrary.simpleMessage('Välkommen till Handi!')
      };
}
