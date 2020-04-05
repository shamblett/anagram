/*
 * Package : Anagram
 * Author : S. Hamblett <steve.hamblett@linux.com>
 * Date   : 01/04/2020
 * Copyright :  S.Hamblett
 */

import 'package:anagram/anagram.dart';

//
// The anagram package is split into the main command line anagram program and a
// supporting Anagram library.
//
// The command line program prints out its usage if you simply type 'anagram'
// or 'anagram --help'. The rest of this example shows how to use the main Anagram
// library with its options.
//

int main() {
  // Create and initialise the anagram library, note if you do not call initialise
  // the library will simply exit when the solve method is called.
  //
  final anagram = Anagram();
  anagram.initialise();

  // In the command line program the word to solve can be a single word or a space
  // separated sequence in which case the separate words are concatenated together
  // so for instance there is no difference between the word 'prelate' and 'pre late',
  // the solve method however expects one word with the components concatenated.
  //
  // Anagram will solve for the length of the input word and sub lengths specified by the
  // -m option. The default is 1 so a 7 letter word will return results only of 7 letters,
  // a value of 2 will return 6 and 7 letters etc. Note that no attempt is made to use the
  // left over letters, the are simply discarded, example, solve for the word 'prelate'
  var words = anagram.solve('prelate');
  print(words);
  words.clear();
  anagram.maxWords = 2;
  words = anagram.solve('prelate');
  print(words);

  // The other options, ignore all case, ignore punctuation and ignore first letter case
  // usage should be self explanatory.

  return 0;
}
