/*
 * Package : Anagram
 * Author : S. Hamblett <steve.hamblett@linux.com>
 * Date   : 01/04/2020
 * Copyright :  S.Hamblett
 */

part of '../anagram.dart';

/// Maximum nuber of generations possible
const int maxGen = 10;

///
///	Structure of a cell used to hold a word in the list which has the same
///	letters as a word we have already found. Idem is latin for "the same".
///
base class _Idem extends LinkedListEntry<_Idem> {
  String? word; // The word exactly as read from the dict

  @override
  String toString() => 'Idem - word = $word';
}

///
///	Structure of each word read from the dictionary and stored as part
///	of a possible anagram.
///
base class _Cell extends LinkedListEntry<_Cell> {
  String? word; // At last! The word itself
  int? wordLen; //length of the word

  // First element in linked list of words which contain the same letters
  // (including the original) exactly as they came out of the dictionary
  LinkedList<_Idem> idem = LinkedList<_Idem>();

  // Sub-word list reduces problem for children. These are
  // the heads of a stack of doubly linked lists.
  List<_Cell?> fLink = List<_Cell?>.filled(maxGen, null); // Forward
  List<_Cell?> rLink = List<_Cell?>.filled(maxGen, null); // Reverse

  @override
  String toString() =>
      'Cell - word is $word, length is $wordLen, ${idem.length} idems';
}

/// The main anagram class
class Anagram {
  /// Construction
  Anagram();

  static const int maxNumWords = 64;

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

  late List<String> _dictionaryWordList;

  LinkedList<_Cell> _wordList = LinkedList<_Cell>();

  bool _initialised = false;

  final _anagramsFound = <String?>[];

  // Number of time each character occurs in the key.
  // Must be initialised to 0s.
  final _freq = List<int>.filled(256, 0);

  // Number of letters in key.
  int? _nLetters;

  // The cells for the words
  // making up the anagram under construction.
  final _anagramWord = List<_Cell?>.filled(maxNumWords, _Cell());

  // Highest number of generations possible.
  int _maxGen = 0;

  /// Initialise
  void initialise() {
    _parameters();
    _readWordList();
    if (_dictionaryWordList.isEmpty) {
      print('Dictionary is empty');
      return;
    }
    _initialised = true;
  }

  /// Solve the anagram
  /// Returns a list of anagrams or an empty list if none were found.
  List<String?> solve(String word) {
    if (!_initialised) {
      _log('Please initialise the library');
      return <String>[];
    }
    _initialiseDataStructures(word);
    _log('Solving for $word, building word list');
    // Build the candidate word list
    _wordList = _buildWordList();
    if (_wordList.isEmpty) {
      print('No suitable words.');
      return <String>[];
    }
    // Sort it
    _log('Sorting');
    _wordList = _sort();
    // Search for anagrams
    _log('Searching for anagrams...');
    _findAnagrams(0, _wordList.last, _nLetters);
    return _anagramsFound.toSet().toList();
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
      print('');
    }
  }

  /// Read the words from the words file
  void _readWordList() {
    final ls = LineSplitter();
    _dictionaryWordList = ls.convert(AnagramWords.words);
    _log('${_dictionaryWordList.length} words read');
  }

  void _initialiseDataStructures(String word) {
    for (var i = 0; i < word.length; i++) {
      _freq[word.codeUnitAt(i)]++;
    }
    _nLetters = word.length;
    _log('$_nLetters letters in the key');
    _maxGen = maxWords;
    _wordList.clear();
    _anagramWord.fillRange(0, _anagramWord.length - 1, _Cell());
    _anagramsFound.clear();
  }

  /// Read words in from the dictionary word list and put
  /// candidates into a linked list.
  /// Return the head of the list.
  LinkedList<_Cell> _buildWordList() {
    var candidates = <String>[];
    var head = LinkedList<_Cell>();
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
      var reject = false;
      for (var codeUnit in realWord.codeUnits) {
        if (_freq[codeUnit] == 0) {
          reject = true;
          break;
        }
      }
      if (reject) {
        continue;
      }

      // This word merits further inspection. See if it contains
      //	no more of any letter than the original.
      var freq = List.from(_freq, growable: false);
      reject = false;
      for (var i = 0; i < realWord.length; i++) {
        if (freq[realWord.codeUnitAt(i)] <= 0) {
          reject = true;
          break;
        }
        freq[realWord.codeUnitAt(i)]--;
      }
      if (reject) {
        continue;
      }
      candidates.add(realWord);

      // See if this word contains the same letters as a previous one.
      // If so, tack it on to that word's idem list.

      // Scan down the word list looking for a match.
      var len = realWord.length;
      var it = head.iterator;
      var seen = false;
      while (it.moveNext()) {
        var cell = it.current;
        if (len == cell.wordLen && _sameLetters(realWord, cell.word!)) {
          var idem = _Idem();
          idem.word = realWord;
          cell.idem.add(idem);
          seen = true;
          break;
        }
      }
      if (seen) {
        continue;
      }

      //	The word passed all the tests.
      //	Construct a new cell and attach it to the list.

      // Get a new cell
      var cell = _Cell();
      cell.word = realWord;
      cell.wordLen = realWord.length;

      // If [realWord] differs from pure word, store it separately.
      var idem = _Idem();
      if (realWord == word) {
        idem.word = cell.word;
      } else {
        idem.word = realWord;
      }
      cell.idem.add(idem);
      head.add(cell);
    }
    _log('There are ${candidates.length} candidates');
    return head;
  }

  ///
  /// Sort the _[wordList] by word length so that the longest is at the head.
  /// Return the new head of the list.
  LinkedList<_Cell> _sort() {
    var head = LinkedList<_Cell>();
    var cells = List<_Cell>.from(_wordList.toList());
    _wordList.clear();
    cells.sort((a, b) => b.wordLen! > a.wordLen! ? -1 : 1);
    cells.forEach(head.addFirst);
    return head;
  }

  ///
  /// Find all anagrams which can be made from the word list word
  ///	out of the letters left in freq[].
  /// (cell)->[fr]link[generation] is the word list we are to scan.
  /// Scan from the tail back to the head; (head->rlink[gen]==NULL)
  void _findAnagrams(int generation, _Cell wordLt, int? nLeft) {
    _Cell? myHead;
    _Cell myTail;
    for (_Cell? cell = wordLt; cell != null; cell = cell.previous) {
      //	This looks remarkably like bits of buildwordlist.
      //
      //	First a quick rudimentary check whether we have already
      //	run out of any of the letters required.
      var nextWord = false;
      for (var i = 0; i < cell.word!.length; i++) {
        if (_freq[cell.word!.codeUnitAt(i)] == 0) {
          nextWord = true;
          break;
        }
      }
      if (nextWord) {
        continue;
      }
      var freq = List<int>.from(_freq);
      //	Now do a more careful counting check.
      //
      var nl = nLeft;
      nextWord = false;
      for (var i = 0; i < cell.word!.length; i++) {
        if (freq[cell.word!.codeUnitAt(i)] == 0) {
          nextWord = true;
          break;
        } else {
          freq[cell.word!.codeUnitAt(i)]--;
          nl != null ? nl-- : null;
        }
      }
      if (nextWord) {
        continue;
      }
      //	Yep, there were the letters left to make the word.
      //	Are we done yet?
      switch (nl) {
        case 0: // Bingo
          // Insert the final word.
          _anagramWord[generation] = cell;
          // Select the phrase.
          _select(0, generation);
          break;
        default:
          if (generation < _maxGen - 1) {
            // Record the word and find something to follow it
            //
            // Add it to the list of words that were ok for
            // us; those words which we rejected are
            // certainly not worth our children's attention.
            // Constructed like a lifo stack.

            cell.fLink[generation + 1] = myHead;
            if (myHead != null) {
              myHead.rLink[generation + 1] = cell;
            } else // this is the first item on the list
            {
              myTail = cell;
              myHead = cell;
              myHead.rLink[generation + 1] = null;

              // Record where we are for printing.
              _anagramWord[generation] = cell;
              // try all combinations of words on this stem.
              _findAnagrams(generation + 1, myTail, nl);
            }
          }
      }
    }
  }

  // Do the two words contain the same letters?
  // It must be guaranteed by the caller that they are the same length.
  bool _sameLetters(String word1, String word2) {
    var slFreq = List<int>.filled(256, 0);
    slFreq.fillRange(0, slFreq.length - 1, 0);
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

  ///
  ///	Used to select successful anagrams.
  ///	Because of Optimisation #n, we have to churn out every combination
  ///	of the words in anagword[0..gen]. Best done recursively.
  ///
  ///	Select anagram phrases indicated by anagword[0..gen].
  ///	There are 'gen' invocations of this procedure active above us.
  ///	The words they are contemplating are available through
  ///	idlist[0..gen-1]. Select the parents' words from there followed by
  ///	every combination of the words dangling from anagword[gen..maxgen].
  void _select(int gen, int hiGen) {
    if (gen == hiGen) {
      // No further recursion; just select.
      // For each word in idemlist[gen], select the stem and it.
      var it = _anagramWord[hiGen]!.idem.iterator;
      while (it.moveNext()) {
        var idem = it.current;
        _anagramsFound.add(idem.word);
      }
    } else {
      var it = _anagramWord[hiGen]!.idem.iterator;
      while (it.moveNext()) {
        var idem = it.current;
        _anagramsFound.add(idem.word);
        _select(gen + 1, hiGen);
      }
    }
  }
}
