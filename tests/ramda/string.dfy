// Ramda v0.21.0 test/toUpper.js, toLower.js, trim.js, split.js and
// replace.js (until v0.8.0 test.stringBasics.js and test.replace.js),
// transcribed. (v0.14.0 removed charAt.js and charCodeAt.js, v0.16.0
// substring.js, substringFrom.js, substringTo.js, strIndexOf.js and
// strLastIndexOf.js, and v0.18.0 nthChar.js and nthCharCode.js, with the
// functions.) Not transcribed: match.js and test.js (regular expressions are
// not portable, README), toString.js (v0.14.0; not portable, README), and
// trim's "falls back to a shim if String.prototype.trim is not present"
// (v0.6.0), which is only registered when that method is missing, so not
// under node (its asserts repeat the other three).

module RamdafTests.Ramda.String {
  import opened Ramdaf.String

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
