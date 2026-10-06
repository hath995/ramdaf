// Ramda v0.1.4 test/test.stringBasics.js, transcribed. Not transcribed:
// describe('match') (regular expressions are not portable, README).

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

  // describe('toUpperCase'), describe('toLowerCase')
  method {:test} ToUpperCaseUppercases() { expect toUpperCase("abc") == "ABC"; }
  method {:test} ToLowerCaseLowercases() { expect toLowerCase("XYZ") == "xyz"; }

  // describe('split')
  method {:test} SplitSplitsIntoAnArray() {
    expect split(".", "a.b.c.xyz.d") == ["a", "b", "c", "xyz", "d"];
  }
  method {:test} SplitOnAnArbitraryString() {
    expect split("at", "The Cat in the Hat sat on the mat") == ["The C", " in the H", " s", " on the m", ""];
  }
}
