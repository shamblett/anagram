/*
 * Package : Anagram
 * Author : S. Hamblett <steve.hamblett@linux.com>
 * Date   : 01/04/2020
 * Copyright :  S.Hamblett
 */

import 'package:args/args.dart';
import 'package:anagram/anagram.dart';

/// Anagram
///
///	Find all anagrams of a word or phrase which an be made from the words
///	of the dictionary which can be supplied if you don't want to use the default one.
/// All words containing characters not in the key are rejected out of
/// hand so punctuated and capitalised words are usually lost.
///	Eliminates all one-letter "words" except a, i, o.
///
///	originally from Martin Guy, December 1985

int main(List<String> args) {
  // Parameters
  var maxWords = 1;
  var verbose = false;
  var ignoreCaseInitial = false;
  var ignoreCaseAll = false;
  var ignorePunctuation = false;
  String inputWord;

  ArgResults results;

  // Initialize the argument parser
  final argParser = ArgParser();
  argParser.addFlag('help', abbr: 'h', negatable: false);
  argParser.addOption('maxAnagramWords',
      abbr: 'm',
      defaultsTo: '1',
      help: 'Maximum number of words in anagrams', callback: (String? param) {
    final tmp = int.tryParse(param!);
    if (tmp != null && tmp >= 1) {
      maxWords = tmp;
    } else {
      print('Error - Invalid number of words value entered, defaulting');
    }
  });
  argParser.addFlag('verbose',
      abbr: 'v', help: 'Verbose: give running commentary', negatable: false);
  argParser.addFlag('ignoreCaseInitial',
      abbr: 'i',
      help: 'Ignore case of initial letters of words from dictionary',
      negatable: false);
  argParser.addFlag('ignoreCaseAll',
      abbr: 'I',
      help: 'Ignore case of all letters of words from dictionary',
      negatable: false);
  argParser.addFlag('ignorePunctuation',
      abbr: 'p',
      help: 'Ignore punctuation in words from dictionary',
      negatable: false);

  try {
    results = argParser.parse(args);
  } on FormatException catch (e) {
    print(e.message);
    return -1;
  }

  // Help
  if (results['help']) {
    print('Usage: anagram -v -m# word');
    print('');
    print(argParser.usage);
    return 0;
  }

  // Verbose
  if (results['verbose']) {
    verbose = true;
  }

  // Ignore initial case
  if (results['ignoreCaseInitial']) {
    ignoreCaseInitial = true;
  }

  // Ignore all case
  if (results['ignoreCaseAll']) {
    ignoreCaseAll = true;
  }

  // Ignore punctuation
  if (results['ignorePunctuation']) {
    ignorePunctuation = true;
  }

  if (results.rest.isNotEmpty) {
    inputWord = results.rest.join('');
  } else {
    print('Usage: anagram -v -m# word');
    print('');
    print(argParser.usage);
    return 0;
  }

  // Initialise
  final anagram = Anagram();
  anagram.verbose = verbose;
  anagram.ignoreCaseAll = ignoreCaseAll;
  anagram.ignoreCaseInitial = ignoreCaseInitial;
  anagram.maxWords = maxWords;
  anagram.ignorePunctuation = ignorePunctuation;
  anagram.initialise();

  // Solve the anagram
  print('');
  print('Getting anagrams of the word "${results.rest.join(" ")}"');
  if (verbose) {
    print('');
  }
  var words = anagram.solve(inputWord);
  if (words.isNotEmpty) {
    print('');
    print('The anagrams of "${results.rest.join(" ")}" are :-');
    print('');
    print(words.join(','));
  } else {
    print('');
    print('No anagrams found for $inputWord');
  }

  return 0;
}
