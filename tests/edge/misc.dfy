// Edge cases for Object, Math, String, Logic and Functions, checked against
// ramda.js v0.1.0 under node; the methods named Deviation* pin documented
// deviations (README "Deviations") and say what node returns.

module RamdafTests.Edge.Misc {
  import opened Ramdaf.Prelude
  import opened Ramdaf.Object
  import opened Ramdaf.Math
  import opened Ramdaf.String
  import opened Ramdaf.Logic
  import opened Ramdaf.Functions

  method {:test} PickFamilyEdges() {
    var o := map["a" := 1];
    expect pickAll(["a", "g"], o) == map["a" := Some(1), "g" := None];
    expect pick(["a", "a"], o) == map["a" := 1];
    expect pickAll([], o) == map[];
    expect omit([], o) == map["a" := 1];
    expect pick([], o) == map[];
  }

  method {:test} PropertyEdges() {
    var none: map<string, int> := map[];
    expect eqProps("x", none, none) == true;
    expect eqProps("x", map["x" := 1], none) == false;
    expect propEq("nope", 1, map["foo" := 1]) == false;
    expect prop("nope", map["a" := 1]) == None;
    expect props(map["a" := 1], "a") == Some(1);
    expect props(map["a" := 1], "b") == None;
    expect eq(1, 1) == true;
    expect keys(none) == {};
  }

  // values keeps one entry per key (node: [1, 1]).
  method {:test} ValuesKeepsDuplicates() {
    expect values(map["a" := 1, "b" := 1]) == multiset{1, 1};
  }

  method {:test} MathEdges() {
    var empty: seq<int> := [];
    expect subtractN(5, 2) == -3;
    expect divideBy(3.0, 6.0) == 2.0;
    expect max([3, 9, 2]) == 9;
    expect min([3, 9, 2]) == 2;
    expect max([5]) == 5;
    expect sum(empty) == 0;
    expect product(empty) == 1;
  }

  function ByV(a: (int, int), b: (int, int)): int { a.0 - b.0 }

  // The running maximum/minimum is replaced only by a strictly better
  // element, so the first of equals wins.
  method {:test} MaxWithMinWithKeepTheFirstOfEquals() {
    expect maxWith(ByV, [(3, 0), (5, 1), (5, 2), (1, 3)]) == Some((5, 1));
    expect minWith(ByV, [(3, 0), (1, 1), (1, 2)]) == Some((1, 1));
  }

  // Rock-paper-scissors is not transitive: the left-to-right fold decides.
  function Rps(a: char, b: char): int
  { if a == b then 0
    else if (a == 'R' && b == 'S') || (a == 'P' && b == 'R') || (a == 'S' && b == 'P') then 1
    else -1 }

  method {:test} MaxWithMinWithFoldLeftToRight() {
    expect maxWith(Rps, ['R', 'P', 'S']) == Some('S');
    expect minWith(Rps, ['R', 'P', 'S']) == Some('S');
    expect maxWith(Rps, ['S', 'P', 'R']) == Some('R');
    expect minWith(Rps, ['P', 'S', 'R']) == Some('R');
  }

  // String.prototype.substring clamps both indices and swaps them if needed.
  method {:test} SubstringClampsAndSwaps() {
    expect substring(5, 2, "abcdefg") == "cde";
    expect substring(2, 100, "abc") == "c";
    expect substring(-3, 2, "abcd") == "ab";
    expect substring(3, -1, "abcd") == "abc";
    expect substring(2, 2, "abcd") == "";
    expect substringFrom(10, "abc") == "";
    expect substringFrom(-2, "abcd") == "abcd";
    expect substringTo(10, "abc") == "abc";
    expect substringTo(-2, "abcd") == "";
  }

  method {:test} CharAtOutOfRangeIsEmpty() {
    expect charAt(10, "abc") == "";
    expect charAt(-1, "abc") == "";
  }

  method {:test} SplitEdges() {
    expect split("", "abc") == ["a", "b", "c"];
    expect split("", "") == [];
    expect split(",", "") == [""];
    expect split(",", ",") == ["", ""];
    expect split(",", "a,b,") == ["a", "b", ""];
    expect split("aa", "aaa") == ["", "a"];
    expect split("x", "abc") == ["abc"];
  }

  method {:test} StrIndexOfEdges() {
    expect strIndexOf("", "abc") == 0;
    expect strIndexOf("", "") == 0;
    expect strLastIndexOf("", "abc") == 3;
    expect strLastIndexOf("aa", "aaa") == 1;
    expect strIndexOf("aa", "aaa") == 0;
    expect strIndexOf("abcd", "abc") == -1;
    expect strLastIndexOf("bc", "abcbc") == 3;
  }

  method {:test} CaseConversionOfAscii() {
    expect toUpperCase("aBc-1") == "ABC-1";
    expect toLowerCase("AbC-1") == "abc-1";
  }

  method {:test} LogicAndFunctionEdges() {
    var none: seq<int -> bool> := [];
    expect allPredicates(none)(5) == true;
    expect anyPredicates(none)(5) == false;
    expect always(7)(()) == 7;
    expect alwaysZero("x") == 0;
    expect flip((a: int, b: int) => a - b)(1, 2) == 1;
    expect compose((x: int) => x + 1, (x: int) => 2 * x)(3) == 7;
    expect pipe((x: int) => 2 * x, (x: int) => x + 1)(3) == 7;
  }

  // ---- documented deviations (not node behaviour) ----

  // node: eq([], []) is false (two distinct array objects).
  method {:test} DeviationEqIsStructural() {
    var a: seq<int> := [];
    var b: seq<int> := [];
    expect eq(a, b) == true;
  }

  // node: 'STRASSE' and 'Ä'; case conversion is ASCII-only here.
  method {:test} DeviationCaseConversionIsAsciiOnly() {
    expect toUpperCase("straße") == "STRAßE";
    expect toUpperCase("ä") == "ä";
  }

  // node: 55357 (a UTF-16 surrogate) and length 2; a Dafny char is a code point.
  method {:test} DeviationCharactersAreCodePoints() {
    expect charCodeAt(0, "\U{1F600}") == 0x1F600;
    expect |"\U{1F600}"| == 1;
  }
}
