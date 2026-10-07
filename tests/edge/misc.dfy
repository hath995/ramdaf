// Edge cases for Object, Math, String, Logic and Functions, checked against
// ramda.js v0.4.0 under node; the methods named Deviation* pin documented
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

  // v0.2.0: a map has no prototype chain, so keysIn and valuesIn are keys and
  // values (node, on plain objects: [], [1, 1]).
  method {:test} KeysInValuesInOfPlainObjects() {
    var none: map<string, int> := map[];
    expect keysIn(none) == {};
    expect keysIn(map["a" := 1, "b" := 2]) == {"a", "b"};
    expect valuesIn(map["a" := 1, "b" := 1]) == multiset{1, 1};
  }

  // propOrDefault (v0.4.0) returns obj's own property p, or the default.
  method {:test} PropOrDefaultEdges() {
    var none: map<string, int> := map[];
    expect propOrDefault("a", 5, map["a" := 1]) == 1;
    expect propOrDefault("z", 5, map["a" := 1]) == 5;
    // a falsy own value is kept
    expect propOrDefault("a", 5, map["a" := 0]) == 0;
    // node: `{}` inherits `toString`, which is not an own property
    expect propOrDefault("toString", 5, none) == 5;
    expect propOrDefault("hasOwnProperty", 5, map["hasOwnProperty" := 1]) == 1;
    // an own property whose value is null or undefined is returned (node:
    // null, undefined)
    expect propOrDefault("a", Num(5), map["a" := Null]) == Null;
    expect propOrDefault("a", Num(5), map["a" := Undefined]) == Undefined;
    // `propOrDefault('a')(5)({})`
    var aOr5 := (o: map<string, int>) => propOrDefault("a", 5, o);
    expect aOr5(none) == 5;
  }

  // toPairs/toPairsIn (v0.4.0): one pair per key (node lists them in key
  // order: `toPairs({b: 2, a: 1})` is [['b', 2], ['a', 1]], and integer-like
  // keys come first).
  method {:test} ToPairsEdges() {
    var none: map<string, int> := map[];
    expect toPairs(none) == {};
    expect toPairs(map["b" := 2, "a" := 1]) == {("a", 1), ("b", 2)};
    expect toPairs(map["2" := "x", "1" := "y", "b" := "0"]) == {("1", "y"), ("2", "x"), ("b", "0")};
    expect toPairs(map["hasOwnProperty" := 1]) == {("hasOwnProperty", 1)};
    expect toPairs(map["a" := Undefined]) == {("a", Undefined)};
    expect toPairsIn(map["a" := 1, "b" := 2]) == {("a", 1), ("b", 2)};
    expect toPairsIn(none) == {};
  }

  // pickWith (v0.2.3) passes (value, key, object).
  method {:test} PickWithEdges() {
    var none: map<string, int> := map[];
    expect pickWith((v: int, k: string, o: map<string, int>) => k == "a", map["a" := 1, "b" := 2]) == map["a" := 1];
    expect pickWith((v: int, k: string, o: map<string, int>) => "b" in o && o["b"] == v, map["a" := 2, "b" := 2, "c" := 3]) ==
      map["a" := 2, "b" := 2];
    expect pickWith((v: int, k: string, o: map<string, int>) => v > 1, none) == map[];
  }

  method {:test} MixinEdges() {
    var none: map<string, int> := map[];
    expect mixin(map["a" := 1, "b" := 2], map["b" := 3, "c" := 4]) == map["a" := 1, "b" := 3, "c" := 4];
    expect mixin(none, map["b" := 3]) == map["b" := 3];
    expect mixin(map["a" := 1], none) == map["a" := 1];
  }

  // Since v0.2.3 a function entry fails on an absent property without being
  // called (it was called with undefined, None, before); a value entry fails
  // on an absent property.
  method {:test} WhereEdges() {
    var y1 := map["y" := 1];
    expect where(map["x" := Pred((v: Option<int>, o: map<string, int>) => v.None?)], y1) == false;
    expect where(map["x" := Pred((v: Option<int>, o: map<string, int>) => true)], y1) == false;
    expect where(map["x" := Pred((v: Option<int>, o: map<string, int>) => true)], map["x" := 1]) == true;
    expect where(map["x" := Pred((v: Option<int>, o: map<string, int>) => v == Some(1))], y1) == false;
    expect where(map["x" := Val(1)], y1) == false;
    var empty: map<string, SpecVal<int>> := map[];
    expect where(empty, map["a" := 1]) == true;
    var mixed := map["x" := Val(1), "y" := Pred((v: Option<int>, o: map<string, int>) => v.Some? && "x" in o && v.value > o["x"])];
    expect where(mixed, map["x" := 1, "y" := 2]) == true;
    expect where(mixed, map["x" := 1, "y" := 0]) == false;
    expect where(mixed, map["x" := 1]) == false;
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

  // mathMod (v0.3.0) is `((m % p) + p) % p` with JS's truncated `%`, for an
  // integer m >= 1 and a nonzero p. node prints -0 for (10, -5), (1, -1) and
  // (7, -7), which `===` equals 0.
  method {:test} MathModEdges() {
    expect mathMod(17, 5) == 2;
    expect mathMod(17, -5) == -3;
    expect mathMod(29, 6) == 5;
    expect mathMod(2, -3) == -1;
    expect mathMod(1, 5) == 1;
    expect mathMod(5, 5) == 0;
    expect mathMod(3, 7) == 3;
    expect mathMod(100, 1) == 0;
    expect mathMod(12, 5) == 2;
    expect mathMod(10, -5) == 0;
    expect mathMod(1, -1) == 0;
    expect mathMod(7, -7) == 0;
  }

  // v0.2.2's curry3 starts every call of sum and product afresh (v0.2.0 and
  // v0.2.1 kept the accumulator between calls).
  method {:test} SumAndProductKeepNoState() {
    expect sum([1, 2, 3]) == 6;
    expect sum([1, 2, 3]) == 6;
    expect product([2]) == 2;
    expect product([2]) == 2;
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

  // v0.2.0: maxWith/minWith take a key function, and the running winner is
  // replaced only by a strictly better key, so the first of equals wins.
  method {:test} MaxWithMinWithKeepTheFirstOfEquals() {
    expect maxWith((r: (int, int)) => r.0, [(3, 0), (5, 1), (5, 2), (1, 3)]) == Some((5, 1));
    expect minWith((r: (int, int)) => r.0, [(3, 0), (1, 1), (1, 2)]) == Some((1, 1));
    expect maxWith((x: int) => x % 2, [1, 3, 2]) == Some(1);
    expect minWith((x: int) => x % 2, [2, 4, 1]) == Some(2);
  }

  method {:test} MaxWithMinWithCompareKeys() {
    var empty: seq<int> := [];
    expect maxWith((x: int) => -x, [1, 2, 3]) == Some(1);
    expect minWith((x: int) => -x, [1, 2, 3]) == Some(3);
    expect maxWith((x: int) => x, [7]) == Some(7);
    expect minWith((x: int) => x, empty) == None;
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

  // and/or/not combine predicates (v0.1.4 renamed andFn/orFn/notFn).
  method {:test} PredicateCombinators() {
    expect and((x: int) => x > 0, (x: int) => x < 10)(5) == true;
    expect and((x: int) => x > 0, (x: int) => x < 10)(15) == false;
    expect or((x: int) => x < 0, (x: int) => x > 10)(15) == true;
    expect or((x: int) => x < 0, (x: int) => x > 10)(5) == false;
    expect not((x: int) => x > 0)(5) == false;
    expect not((x: int) => x > 0)(-1) == true;
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

  // v0.3.0: K is an alias of always (it was tap's), and distributeTo of fork.
  method {:test} KAndDistributeToEdges() {
    expect K(5)(()) == 5;
    expect K(5)(7) == 5;
    expect distributeTo((a: int, b: int) => a * b, (x: int) => add(1, x), (x: int) => add(3, x))(2) == 15;
  }

  // fork applies both functions to the same argument, then combines them.
  method {:test} ForkEdges() {
    expect fork((a: int, b: int) => [a, b], (x: int) => x + 1, (x: int) => x * 2)(5) == [6, 10];
    expect fork((n: int, t: string) => t + NumStr(n), (s: string) => |s|, (s: string) => s + "!")("ab") == "ab!2";
    // node: fork((x, y) => [x, y], (a, b) => a + b, (a, b) => a * b)(2, 5)
    // is [7, 10]; the port's result is unary, so the arguments are a tuple.
    expect fork((x: int, y: int) => [x, y], (t: (int, int)) => t.0 + t.1, (t: (int, int)) => t.0 * t.1)((2, 5)) == [7, 10];
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
