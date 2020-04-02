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
class _idem extends LinkedListEntry<_idem> {
  String word; // The word exactly as read from the dict
}

///
///	Structure of each word read from the dictionary and stored as part
///	of a possible anagram.
///
class _cell extends LinkedListEntry<_cell> {
  String word; // At last! The word itself
  int wordlen; //length of the word

  // First element in linked list of words which contain the same letters
  // (including the original) exactly as they came out of the dictionary
  _idem idem;
}

/// The main anagram class
class Anagram {
  /// Construction
  Anagram();

  static int MaxWords = 64;
  static String DefaultDictionaryPath = 'default';
  static String DictionaryPathPart = 'words';

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
  String dictionaryPath = DefaultDictionaryPath;

  List<String> _dictionaryWordList;

  _cell _wordList;

  bool _initialised = false;

  // Number of time each character occurs in the key.
  // Must be initialised to 0s.
  final _freq = List<int>(256);

  // Number of letters in key.
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
    _parameters();
    _readWordList();
    _initialised = true;
  }

  /// Solve the anagram
  /// Returns a list of anagrams or an empty list if none were found.
  List<String> solve(String word) {
    if (!_initialised) {
      _log('Please initialise the library');
      return <String>[];
    }
    _initialiseDataStructures(word);
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

  /// Read the words from the words file
  void _readWordList() {
    if (dictionaryPath == DefaultDictionaryPath) {
      dictionaryPath = join(current, DictionaryPathPart, DictionaryPathPart);
    }
    _log('Real dictionary path is $dictionaryPath');
    var myFile = File(dictionaryPath);
    _dictionaryWordList = myFile.readAsLinesSync();
    _log('${_dictionaryWordList.length} words read');
  }

  void _initialiseDataStructures(String word) {
    for (var i = 0; i < word.length; i++) {
      _freq[word.codeUnitAt(i)]++;
    }
    _nletters = word.length;
    _log('$_nletters letters in the key');
    _maxgen = maxWords;
    _wordList = _buildwordlist();
  }

  /// Read words in from the dictionary word list and put
  /// candidates into a linked list.
  /// Return the head of the list.
  _cell _buildwordlist() {}
  _cell _sort() {}
  _cell _forgelinks() {}
}
