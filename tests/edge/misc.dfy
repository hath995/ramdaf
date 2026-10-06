// Edge cases for Object, Math, String, Logic and Functions, checked against
// ramda.js v0.1.3 under node; the methods named Deviation* pin documented
// deviations (README "Deviations") and say what node returns.

module RamdafTests.Edge.Misc {
  import opened Ramdaf.Prelude
  import opened Ramdaf.Core
  import opened Ramdaf.Object
  import opened Ramdaf.Math
  import opened Ramdaf.String
  import opened Ramdaf.Logic
  import opened Ramdaf.Functions
  import opened Support

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

  method {:test} MixinEdges() {
    var none: map<string, int> := map[];
    expect mixin(map["a" := 1, "b" := 2], map["b" := 3, "c" := 4]) == map["a" := 1, "b" := 3, "c" := 4];
    expect mixin(none, map["b" := 3]) == map["b" := 3];
    expect mixin(map["a" := 1], none) == map["a" := 1];
  }

  // A function entry sees an absent property as undefined (None); a value
  // entry fails on an absent property.
  method {:test} WhereEdges() {
    var y1 := map["y" := 1];
    expect where(map["x" := Pred((v: Option<int>, o: map<string, int>) => v.None?)], y1) == true;
    expect where(map["x" := Pred((v: Option<int>, o: map<string, int>) => v == Some(1))], y1) == false;
    expect where(map["x" := Val(1)], y1) == false;
    var empty: map<string, SpecVal<int>> := map[];
    expect where(empty, map["a" := 1]) == true;
    var mixed := map["x" := Val(1), "y" := Pred((v: Option<int>, o: map<string, int>) => v.Some? && "x" in o && v.value > o["x"])];
    expect where(mixed, map["x" := 1, "y" := 2]) == true;
    expect where(mixed, map["x" := 1, "y" := 0]) == false;
  }

  // JS `%` truncates toward zero: the remainder takes the dividend's sign.
  method {:test} ModuloTruncatesTowardZero() {
    expect modulo(7, 3) == 1;
    expect modulo(-7, 3) == -1;
    expect modulo(7, -3) == 1;
    expect modulo(-7, -3) == -1;
    expect modulo(0, -3) == 0;
    expect modulo(6, -3) == 0;
    expect modulo(-6, 3) == 0;
    expect modulo(5, -4) == 1;
    expect modulo(1, 1) == 0;
    expect modulo(-1, -5) == -1;
    expect moduloBy(-3, 7) == 1;
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

  // fork applies both functions to the same argument, then combines them.
  method {:test} ForkEdges() {
    expect fork((x: int) => x + 1, (x: int) => x * 2, (a: int, b: int) => [a, b])(5) == [6, 10];
    expect fork((s: string) => |s|, (s: string) => s + "!", (n: int, t: string) => t + NumStr(n))("ab") == "ab!2";
    // node: fork((a, b) => a + b, (a, b) => a * b, (x, y) => [x, y])(2, 5)
    // is [7, 10]; the port's result is unary, so the arguments are a tuple.
    expect fork((t: (int, int)) => t.0 + t.1, (t: (int, int)) => t.0 * t.1, (x: int, y: int) => [x, y])((2, 5)) == [7, 10];
  }

  // ---- documented deviations (not node behaviour) ----

  // node: cloneDeep({g: undefined, a: 1}) is {a: 1} (JSON drops undefined);
  // the copy here is the value itself.
  method {:test} DeviationCloneDeepKeepsUndefinedProperties() {
    var o := map["g" := None, "a" := Some(1)];
    expect cloneDeep(o) == o;
  }

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
