/*
 * Package : Anagram
 * Author : S. Hamblett <steve.hamblett@linux.com>
 * Date   : 01/04/2020
 * Copyright :  S.Hamblett
 */

part of anagram;

///
///	Structure of a cell used to hold a word in the list which has the same
///	letters as a word we have already found. Idem is latin for "the same".
///
class _idem {
  String word; // The word exactly as read from the dict
  _idem link; // Next in the list of similar words */
}

///
///	Structure of each word read from the dictionary and stored as part
///	of a possible anagram.
///
class _cell extends LinkedListEntry<_cell> {
  _cell link; // To bind the linked list together
  String word; // At last! The word itself
  int wordlen; //length of the word

// Sub-word list reduces problem for children. These pointers are
// the heads of a stack of doubly linked lists (!)
  _cell flink; // Forward links for doubly linked list
  _cell rlink; // Reverse links for doubly linked list

// First element in linked list of words which contain the same letters
  // (including the original) exactly as they came out of the dict
  _idem idem;
}

/// The main anagram class
class Anagram {
  /// Construction
  Anagram();

  static int MaxWords = 64;

  /// Verbose.
  bool verbose = false;

  /// Maximum number of words to return in anagram.
  int maxWords = 1;

  /// Ignore case of initial letters of words from dictionary.
  bool ignoreCaseInitial = false;

  /// Ignore case of all letters of words from dictionary.
  bool ignoreCaseAll = false;

  /// Ignore punctuation in words from dictionary.
  bool ignorePunctuation = false;

  /// Dictionary path
  String dictionaryPath = 'default';

  bool _initialised = false;

  // Number of time each character occurs in the key.
  // Must be initialised to 0s.
  // Set by buildwordlist, Used by findanags.
  final _freq = List<int>(256);

  // Number of letters in key, == sum(freq[*])
  int _nletters;

  // The cells for the words
  // making up the anagram under construction
  final _anagword = List<_cell>(MaxWords);

  // Number of words in current list
  int _nwords;

  // Some munging has to be done on the dict's words
  bool _purify = false;

  // Highest number of generations of findanag possible
  int _maxgen = 0;

  /// Initialise
  void initialise() {
    _freq.fillRange(0, _freq.length - 1, 0);
    _purify = ignoreCaseAll || ignoreCaseInitial || ignorePunctuation;
    _initialised = true;
  }

  /// Solve the anagram
  /// Returns a list of anagrams or an empty list if none were found.
  List<String> solve(String word) {
    if (!_initialised) {
      _log('Please initialise the library');
      return <String>[];
    }
    _parameters();
    _log('Solving for $word');
    return <String>[];
  }

  /// Verbose logging
  void _log(String entry) {
    if (verbose) {
      print('Anagram - $entry');
    }
  }

  /// Print the parameters if verbose
  void _parameters() {
    if (verbose) {
      print('Anagram - parameters are :-');
      print('   Ignore Case Initial $ignoreCaseInitial');
      print('   Ignore Case All $ignoreCaseAll');
      print('   Maximum words $maxWords');
      print('   Ignore Punctuation $ignorePunctuation');
      print('   Purify $_purify');
      print('   Dictionary Path $dictionaryPath');
      print('');
    }
  }

  _cell _buildwordlist() {}
  _cell _sort() {}
  _cell _forgelinks() {}
}
