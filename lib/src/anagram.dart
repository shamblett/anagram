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
  int wordLen; //length of the word

  // First element in linked list of words which contain the same letters
  // (including the original) exactly as they came out of the dictionary
  LinkedList<_idem> idem = LinkedList<_idem>();
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

  LinkedList<_cell> _wordList = LinkedList<_cell>();

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

  // Highest number of generations of findanag possible
  int _maxgen = 0;

  /// Initialise
  void initialise() {
    _freq.fillRange(0, _freq.length - 1, 0);
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
    _buildWordList();
    if (_wordList.isEmpty) {
      print('Empty dictionary or no suitable words.');
      return <String>[];
    }
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
  }

  /// Read words in from the dictionary word list and put
  /// candidates into a linked list.
  /// Return the head of the list.
  void _buildWordList() {
    var candidates = <String>[];
    for (var word in _dictionaryWordList) {
      var realWord = word;
      // Ignore Initial letter case
      if (ignoreCaseInitial) {
        if (word[0] == word[0].toUpperCase()) {
          realWord = realWord.replaceFirst(word[0], word[0].toLowerCase(), 0);
        }
      }
      // Ignore all case
      if (ignoreCaseAll) {
        realWord = realWord.toLowerCase();
      }
      // Ignore punctuation
      if (ignorePunctuation) {
        realWord = realWord.replaceAll(r'/[.,\/#!$%\^&\*;:{}=\-_`~()]', '');
      }
      // Throw out all one-letter words except for a, i, o.
      if (realWord.length == 1) {
        if (!(realWord.startsWith('a') ||
            realWord.startsWith('i') ||
            realWord.startsWith('o'))) {
          continue;
        }
      }
      // Reject the word if it contains any character which
      // wasn't in the key.
      for (var codeUnit in realWord.codeUnits) {
        if (_freq[codeUnit] == 0) {
          continue;
        }
      }
      // This word merits further inspection. See if it contains
      //	no more of any letter than the original.
      var freq = List.from(_freq, growable: false);
      var rejected = false;
      for (var i = 0; i < realWord.length; i++) {
        if (freq[realWord.codeUnitAt(i)] <= 0) {
          rejected = true;
        }
        freq[realWord.codeUnitAt(i)]--;
      }
      if (rejected) {
        continue;
      }
      candidates.add(realWord);

      _log('There are ${candidates.length} candidates');

      // See if this word contains the same letters as a previous one.
      // If so, tack it on to that word's idem list.

      // Scan down the word list looking for a match.
      var len = realWord.length;
      while (_wordList.iterator.moveNext()) {
        var cell = _wordList.iterator.current;
        if (len == cell.wordLen && _sameLetters(realWord, cell.word)) {
          var idem = _idem();
          idem.word = realWord;
          cell.idem.add(idem);
        }
      }

      //	The word passed all the tests.
      //	Construct a new cell and attach it to the list.

      // Get a new cell
      var cell = _cell();
      cell.word = realWord;
      cell.wordLen = realWord.length;

      // If [realWord] differs from pure word, store it separately.
      var idem = _idem();
      if (realWord == word) {
        idem.word = cell.word;
      } else {
        idem.word = realWord;
      }
      cell.idem.add(idem);
      _wordList.add(cell);
      _log('${_wordList.length} suitable words found');
    }
  }

  _cell _sort() {}
  _cell _forgelinks() {}

  // Do the two words contain the same letters?
  // It must be guaranteed by the caller that they are the same length.
  bool _sameLetters(String word1, String word2) {
    var slFreq = List<int>(256);
    slFreq.fillRange(0, 0, 0);
    for (var i = 0; i < word1.length; i++) {
      slFreq[word1.codeUnitAt(i)]++;
    }
    for (var i = 0; i < word2.length; i++) {
      if (slFreq[word2.codeUnitAt(i)]-- < 0) {
        return false;
      }
    }
    return true;
  }
}
