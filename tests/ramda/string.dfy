// Ramda v0.9.0 test/substring.js, substringFrom.js, substringTo.js,
// charAt.js, charCodeAt.js, strIndexOf.js, strLastIndexOf.js, toUpper.js,
// toLower.js, trim.js, split.js and replace.js (until v0.8.0
// test.stringBasics.js and test.replace.js), transcribed. Not transcribed:
// match.js (regular expressions are not portable, README), and
// trim's "falls back to a shim if String.prototype.trim is not present"
// (v0.6.0), which is only registered when that method is missing, so not
// under node (its asserts repeat the other three).

module RamdafTests.Ramda.String {
  import opened Ramdaf.String

  // describe('substring')
  method {:test} SubstringReturnsTheSubstring() {
    expect substring(2, 5, "abcdefghijklm") == "cde";
  }
  method {:test} SubstringIsAutomaticallyCurried() {
    var from2 := (e: int, s: string) => substring(2, e, s);
    expect from2(5, "abcdefghijklm") == "cde";
    var from2to5 := (s: string) => substring(2, 5, s);
    expect from2to5("abcdefghijklm") == "cde";
  }

  // describe('substringFrom')
  method {:test} SubstringFromReturnsTheTrailingSubstring() {
    expect substringFrom(8, "abcdefghijklm") == "ijklm";
  }
  method {:test} SubstringFromIsAutomaticallyCurried() {
    var after8 := (s: string) => substringFrom(8, s);
    expect after8("abcdefghijklm") == "ijklm";
  }

  // describe('substringTo')
  method {:test} SubstringToReturnsTheLeadingSubstring() {
    expect substringTo(8, "abcdefghijklm") == "abcdefgh";
  }
  method {:test} SubstringToIsAutomaticallyCurried() {
    var through8 := (s: string) => substringTo(8, s);
    expect through8("abcdefghijklm") == "abcdefgh";
  }

  // describe('charAt')
  method {:test} CharAtReturnsTheCharacterAtN() {
    expect charAt(8, "abcdefghijklm") == "i";
  }
  method {:test} CharAtIsAutomaticallyCurried() {
    var at8 := (s: string) => charAt(8, s);
    expect at8("abcdefghijklm") == "i";
  }

  // describe('charCodeAt')
  method {:test} CharCodeAtReturnsTheCodeAtN() {
    expect charCodeAt(8, "abcdefghijklm") == 105;
  }
  method {:test} CharCodeAtIsAutomaticallyCurried() {
    var at8 := (s: string) requires |s| > 8 => charCodeAt(8, s);
    expect at8("abcdefghijklm") == 105;
  }

  // describe('strIndexOf')
  method {:test} StrIndexOfFindsTheIndex() { expect strIndexOf("c", "abcdefg") == 2; }
  method {:test} StrIndexOfReturnsMinusOneWhenAbsent() { expect strIndexOf("x", "abcdefg") == -1; }
  method {:test} StrIndexOfIsAutomaticallyCurried() {
    var findD := (s: string) => strIndexOf("d", s);
    expect findD("abcdefg") == 3;
  }

  // describe('strLastIndexOf')
  method {:test} StrLastIndexOfFindsTheIndex() { expect strLastIndexOf("a", "bananas") == 5; }
  method {:test} StrLastIndexOfReturnsMinusOneWhenAbsent() { expect strLastIndexOf("x", "abcdefg") == -1; }
  method {:test} StrLastIndexOfIsAutomaticallyCurried() {
    var findA := (s: string) => strLastIndexOf("a", s);
    expect findA("banana split") == 5;
  }

  // describe('toUpper'), describe('toLower') (describe('toUpperCase') and
  // describe('toLowerCase') until v0.8.0)
  method {:test} ToUpperUppercases() { expect toUpper("abc") == "ABC"; }
  method {:test} ToLowerLowercases() { expect toLower("XYZ") == "xyz"; }

  // describe('trim') (v0.6.0): the 26 characters before and after
  // "Hello, World!" are ES5 whitespace plus U+180E, U+2028, U+2029 and U+FEFF.
  function TrimWs(): string { "\t\n\U{000B}\U{000C}\r \U{00A0}\U{1680}\U{180E}\U{2000}\U{2001}\U{2002}\U{2003}\U{2004}\U{2005}\U{2006}\U{2007}\U{2008}\U{2009}\U{200A}\U{202F}\U{205F}\U{3000}\U{2028}\U{2029}\U{FEFF}" }

  method {:test} TrimTrimsAString() {
    expect trim("   xyz  ") == "xyz";
  }
  method {:test} TrimTrimsAllEs5Whitespace() {
    var test := TrimWs() + "Hello, World!" + TrimWs();
    expect trim(test) == "Hello, World!";
    expect |trim(test)| == 13;
  }
  method {:test} TrimDoesNotTrimTheZeroWidthSpace() {
    expect trim("\U{200B}") == "\U{200B}";
    expect |trim("\U{200B}")| == 1;
  }

  // ---- test.replace.js (v0.7.0). Not transcribed: "replaces regex matches
  // of the input string" (a RegExp pattern, README "Deviations") and the
  // `instanceof Function` checks of "is curried up to 3 arguments" (with null
  // arguments). ----

  method {:test} ReplaceReplacesSubstringsOfTheInputString() {
    expect replace("1", "one", "1 two three") == "one two three";
  }
  method {:test} ReplaceIsCurriedUpTo3Arguments() {
    var removeSemicolon := (s: string) => replace(";", "", s);
    expect removeSemicolon("return 42;") == "return 42";
  }

  // describe('split')
  method {:test} SplitSplitsIntoAnArray() {
    expect split(".", "a.b.c.xyz.d") == ["a", "b", "c", "xyz", "d"];
  }
  method {:test} SplitOnAnArbitraryString() {
    expect split("at", "The Cat in the Hat sat on the mat") == ["The C", " in the H", " s", " on the m", ""];
  }
}
