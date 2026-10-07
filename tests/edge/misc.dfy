// Edge cases for Object, Math, String, Logic and Functions, checked against
// dist/ramda.js v0.9.1 under node; the methods named Deviation* pin documented
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
    expect propOf(map["a" := 1], "a") == Some(1);
    expect propOf(map["a" := 1], "b") == None;
    expect eq(1, 1) == true;
    expect keys(none) == {};
  }

  // props (v0.8.0) gives one value per name, in the names' order, undefined
  // (None) for a missing property (node: [1, 1], [undefined, 1, 2], []).
  method {:test} PropsEdges() {
    var none: map<string, int> := map[];
    var names: seq<string> := [];
    expect props(["a", "a"], map["a" := 1]) == [Some(1), Some(1)];
    expect props(["c", "a", "b"], map["b" := 2, "a" := 1]) == [None, Some(1), Some(2)];
    expect props(names, map["a" := 1]) == [];
    expect props(["a"], none) == [None];
  }

  // assoc (v0.8.0) copies obj with the property set (node: {a: 1, z: 9},
  // {a: 1}, {x: 2, hasOwnProperty: 1}, and `assoc('a', undefined, {})` has
  // the own key a).
  method {:test} AssocEdges() {
    var none: map<string, int> := map[];
    expect assoc("z", 9, map["a" := 1]) == map["a" := 1, "z" := 9];
    expect assoc("a", 1, none) == map["a" := 1];
    expect assoc("a", 2, map["a" := 1, "b" := 3]) == map["a" := 2, "b" := 3];
    expect assoc("hasOwnProperty", 1, map["x" := 2]) == map["x" := 2, "hasOwnProperty" := 1];
    var emptyJs: map<string, Js> := map[];
    expect assoc("a", Undefined, emptyJs) == map["a" := Undefined];
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

  // propOr (propOrDefault from v0.4.0 to v0.5.0) returns obj's own property
  // p, or the default, which since v0.9.0 comes first (node: 1, 5, 0, 5, 1,
  // null, undefined, and `propOr(5)('a')({})` 5).
  method {:test} PropOrEdges() {
    var none: map<string, int> := map[];
    expect propOr(5, "a", map["a" := 1]) == 1;
    expect propOr(5, "z", map["a" := 1]) == 5;
    // a falsy own value is kept
    expect propOr(5, "a", map["a" := 0]) == 0;
    // node: `{}` inherits `toString`, which is not an own property
    expect propOr(5, "toString", none) == 5;
    expect propOr(5, "hasOwnProperty", map["hasOwnProperty" := 1]) == 1;
    // an own property whose value is null or undefined is returned (node:
    // null, undefined)
    expect propOr(Num(5), "a", map["a" := Null]) == Null;
    expect propOr(Num(5), "a", map["a" := Undefined]) == Undefined;
    // `propOr(5)('a')({})`
    var aOr5 := (o: map<string, int>) => propOr(5, "a", o);
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

  // pickBy (pickWith from v0.2.3 to v0.7.2) passes (value, key, object).
  method {:test} PickByEdges() {
    var none: map<string, int> := map[];
    expect pickBy((v: int, k: string, o: map<string, int>) => k == "a", map["a" := 1, "b" := 2]) == map["a" := 1];
    expect pickBy((v: int, k: string, o: map<string, int>) => "b" in o && o["b"] == v, map["a" := 2, "b" := 2, "c" := 3]) ==
      map["a" := 2, "b" := 2];
    expect pickBy((v: int, k: string, o: map<string, int>) => v > 1, none) == map[];
  }

  method {:test} MixinEdges() {
    var none: map<string, int> := map[];
    expect mixin(map["a" := 1, "b" := 2], map["b" := 3, "c" := 4]) == map["a" := 1, "b" := 3, "c" := 4];
    expect mixin(none, map["b" := 3]) == map["b" := 3];
    expect mixin(map["a" := 1], none) == map["a" := 1];
  }

  // clone copies every own property of an object (cloneObj until v0.8.0;
  // node: `clone({a: undefined})` keeps `a`, and since v0.9.0 an object
  // value is an equal copy, not the same object, which value equality
  // cannot tell apart).
  method {:test} CloneOfObjectsEdges() {
    var none: map<string, int> := map[];
    expect clone(none) == map[];
    expect clone(map["a" := 1, "b" := 2, "c" := 3, "z" := 100]) == map["a" := 1, "b" := 2, "c" := 3, "z" := 100];
    expect clone(map["a" := Undefined]) == map["a" := Undefined];
    expect clone(map["hasOwnProperty" := 1]) == map["hasOwnProperty" := 1];
    var x1 := Obj(map["x" := Num(1)]);
    expect clone(map["a" := x1, "b" := Num(2)])["a"] == x1;
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
  }

  // mathMod is `((m % p) + p) % p` with JS's truncated `%`; since v0.4.2 it
  // needs an integer p >= 1 (until v0.4.1 an integer m >= 1, so the negative
  // dividends here were NaN and negative moduli gave values).
  method {:test} MathModEdges() {
    expect mathMod(17, 5) == 2;
    expect mathMod(29, 6) == 5;
    expect mathMod(1, 5) == 1;
    expect mathMod(5, 5) == 0;
    expect mathMod(3, 7) == 3;
    expect mathMod(100, 1) == 0;
    expect mathMod(12, 5) == 2;
    expect mathMod(-17, 5) == 3;
    expect mathMod(0, 5) == 0;
    expect mathMod(-1, 1) == 0;
    expect mathMod(-3, 3) == 0;
    expect mathMod(-5, 3) == 1;
    expect mathMod(-6, 4) == 2;
    expect mathMod(-7, 1) == 0;
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
    // ties (v0.7.0's createMaxMin keeps the first winner)
    expect max([3, 3]) == 3;
    expect min([2, 2, 5]) == 2;
    expect subtract(2, 5) == -3;
    expect divide(6.0, 3.0) == 2.0;
    expect max([3, 9, 2]) == 9;
    expect min([3, 9, 2]) == 2;
    expect max([5]) == 5;
    expect sum(empty) == 0;
    expect product(empty) == 1;
  }

  // v0.2.0: maxWith/minWith (since v0.8.0 maxBy/minBy) take a key function,
  // and the running winner is replaced only by a strictly better key, so the
  // first of equals wins (node: `maxBy(k => k % 3, [1, 3, 3, 2])` is 2).
  method {:test} MaxByMinByKeepTheFirstOfEquals() {
    expect maxBy((r: (int, int)) => r.0, [(3, 0), (5, 1), (5, 2), (1, 3)]) == Some((5, 1));
    expect minBy((r: (int, int)) => r.0, [(3, 0), (1, 1), (1, 2)]) == Some((1, 1));
    expect maxBy((x: int) => x % 2, [1, 3, 2]) == Some(1);
    expect minBy((x: int) => x % 2, [2, 4, 1]) == Some(2);
  }

  method {:test} MaxByMinByCompareKeys() {
    var empty: seq<int> := [];
    expect maxBy((x: int) => -x, [1, 2, 3]) == Some(1);
    expect minBy((x: int) => -x, [1, 2, 3]) == Some(3);
    expect maxBy((x: int) => x, [7]) == Some(7);
    expect minBy((x: int) => x, empty) == None;
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
    expect toUpper("aBc-1") == "ABC-1";
    expect toLower("AbC-1") == "abc-1";
  }

  // ifElse (cond from v0.6.0 to v0.7.2) applies onTrue or onFalse to its
  // argument; JS forwards every argument (a tuple here).
  method {:test} IfElseEdges() {
    var big := ifElse((x: int) => x > 2, (x: int) => "big", (x: int) => "small");
    expect big(3) == "big";
    expect big(1) == "small";
    // `ifElse((a, b) => a < b, (a, b) => b - a, (a, b) => a - b)(2, 5)`
    expect ifElse((p: (int, int)) => p.0 < p.1, (p: (int, int)) => p.1 - p.0, (p: (int, int)) => p.0 - p.1)((2, 5)) == 3;
  }

  // cond (v0.8.0): the first pair whose predicate holds decides, and no match
  // (or no pairs) is undefined, here None (node: 'a', 'b', undefined,
  // undefined, 5; `cond(x => x > 2, ...)`, v0.7.2's form, now throws).
  method {:test} CondEdges() {
    var ab := cond([((x: int) => x > 1, (x: int) => "a"), ((x: int) => x > 0, (x: int) => "b")]);
    expect ab(5) == Some("a");
    expect ab(1) == Some("b");
    expect ab(0) == None;
    var none: seq<(int -> bool, int -> string)> := [];
    expect cond(none)(5) == None;
    // `cond([(a, b) => a < b, (a, b) => b - a])(2, 7)`
    expect cond([((p: (int, int)) => p.0 < p.1, (p: (int, int)) => p.1 - p.0)])((2, 7)) == Some(5);
  }

  // has (v0.7.0) sees own properties only; hasIn also sees the 12 members of
  // Object.prototype (node: `hasIn('toString', {})` is true).
  method {:test} HasAndHasInEdges() {
    var none: map<string, int> := map[];
    expect has("toString", none) == false;
    expect has("hasOwnProperty", map["hasOwnProperty" := 1]) == true;
    expect has("a", map["a" := Undefined]) == true;
    expect hasIn("toString", none) == true;
    expect hasIn("__proto__", none) == true;
    expect hasIn("constructor", none) == true;
    expect hasIn("valueOf", none) == true;
    expect hasIn("hasOwnProperty", none) == true;
    expect hasIn("isPrototypeOf", none) == true;
    expect hasIn("x", none) == false;
    expect hasIn("a", map["a" := Undefined]) == true;
  }

  // replace (v0.7.0) with a string pattern: the first occurrence only, and
  // the `$$`, `$&`, `` $` `` and `$'` patterns of the replacement.
  method {:test} ReplaceEdges() {
    expect replace("a", "x", "banana") == "bxnana";
    expect replace("", "x", "abc") == "xabc";
    expect replace("", "x", "") == "x";
    expect replace(".", "!", "a.b.c") == "a!b.c";
    expect replace("aa", "b", "aaa") == "ba";
    expect replace("z", "x", "banana") == "banana";
    expect replace("b", "$&$&", "abc") == "abbc";
    expect replace("b", "$$", "abc") == "a$c";
    expect replace("b", "$`", "abc") == "aac";
    expect replace("b", "$'", "abc") == "acc";
    expect replace("b", "$1", "abc") == "a$1c";
    expect replace("b", "$0", "abc") == "a$0c";
    expect replace("b", "$<x>", "abc") == "a$<x>c";
    expect replace("b", "$", "abc") == "a$c";
    expect replace("b", "$$$", "abc") == "a$$c";
    expect replace("b", "a$&b$`c$'d$$e", "abc") == "aabbaccd$ec";
    expect replace("\U{1F600}", "x", "a\U{1F600}b") == "axb";
  }

  // trim (v0.6.0) strips the leading and trailing runs of its 26 whitespace
  // characters: node strips U+180E (Ramda's fallback) and keeps U+200B and
  // U+0085, and inner whitespace stays.
  method {:test} TrimEdges() {
    expect trim("\U{180E} x \U{180E}") == "x";
    expect trim("\U{200B} x \U{200B}") == "\U{200B} x \U{200B}";
    expect trim("\U{0085} x \U{0085}") == "\U{0085} x \U{0085}";
    expect trim("") == "";
    expect trim("   ") == "";
    expect trim("a  b") == "a  b";
    expect trim(" \U{1F600} ") == "\U{1F600}";
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
    expect allPass([(x: int) => x > 1, (x: int) => x < 5])(3) == true;
    expect anyPass([(x: int) => x < 1, (x: int) => x > 5])(7) == true;
    expect always(7)(()) == 7;
    expect T("x") == true;
    expect F("x") == false;
    expect flip((a: int, b: int) => a - b)(1, 2) == 1;
    expect compose((x: int) => x + 1, (x: int) => 2 * x)(3) == 7;
    expect pipe((x: int) => 2 * x, (x: int) => x + 1)(3) == 7;
  }

  // converge (fork until v0.4.1) applies both functions to the same
  // argument, then combines them.
  method {:test} ConvergeEdges() {
    expect converge((a: int, b: int) => [a, b], (x: int) => x + 1, (x: int) => x * 2)(5) == [6, 10];
    expect converge((n: int, t: string) => t + NumStr(n), (s: string) => |s|, (s: string) => s + "!")("ab") == "ab!2";
    // node: converge((x, y) => [x, y], (a, b) => a + b, (a, b) => a * b)(2, 5)
    // is [7, 10]; the port's result is unary, so the arguments are a tuple.
    expect converge((x: int, y: int) => [x, y], (t: (int, int)) => t.0 + t.1, (t: (int, int)) => t.0 * t.1)((2, 5)) == [7, 10];
  }

  // inc, dec and negate (v0.9.0) are add(1), add(-1) and multiply(-1)
  // (node: 0, -1, 1, -5, 5).
  method {:test} IncDecNegateEdges() {
    expect inc(-1) == 0;
    expect dec(0) == -1;
    expect dec(2) == 1;
    expect negate(5) == -5;
    expect negate(-5) == 5;
  }

  // isNil (v0.9.0) is true for null and undefined only (node: true, true,
  // false for 0, '', [] and false); here None is both.
  method {:test} IsNilEdges() {
    var none: Option<int> := None;
    expect isNil(none) == true;
    expect isNil(Some(0)) == false;
    expect isNil(Some("")) == false;
    var empty: seq<int> := [];
    expect isNil(Some(empty)) == false;
    expect isNil(Some(false)) == false;
    // `isNil(prop('a', {}))`, `isNil(nth(5, [1]))`
    expect isNil(prop("a", map["b" := 1])) == true;
    expect isNil(nth(5, [1])) == true;
  }

  // evolve (v0.9.0) sets each transformed key to fn(obj[key]), with
  // undefined (None) for a missing key (node: {a: 2, b: 2}, {a: 1, c: 'U'},
  // {a: 1}).
  method {:test} EvolveEdges() {
    var incOr := (v: Option<int>) => if v.Some? then v.value + 1 else -1;
    expect evolve(map["a" := incOr], map["a" := 1, "b" := 2]) == map["a" := 2, "b" := 2];
    expect evolve(map["c" := (v: Option<Js>) => if v.None? then Str("U") else v.value], map["a" := Num(1)]) ==
      map["a" := Num(1), "c" := Str("U")];
    var noFns: map<string, Option<int> -> int> := map[];
    expect evolve(noFns, map["a" := 1]) == map["a" := 1];
  }

  // invert and invertObj (v0.9.0) (node: {a: ['x', 'z'], b: ['y']}, {},
  // {"1": ['a', 'b']} from `invert({a: 1, b: 1})`; {a: 'x', b: 'y', c:
  // 'z'}, {}).
  method {:test} InvertEdges() {
    var none: map<string, string> := map[];
    expect invert(map["x" := "a", "y" := "b", "z" := "a"]) == map["a" := {"x", "z"}, "b" := {"y"}];
    expect invert(none) == map[];
    expect invert(map["a" := "1", "b" := "1"]) == map["1" := {"a", "b"}];
    expect invertObj(map["x" := "a", "y" := "b", "z" := "c"]) == map["a" := "x", "b" := "y", "c" := "z"];
    expect invertObj(none) == map[];
  }

  // ---- documented deviations (not node behaviour) ----


  // node: clone(JSON.parse('{"__proto__": 5, "a": 1}')) (cloneObj and
  // cloneDeep until v0.8.0) and mixin(<the same>, {}) are {a: 1}: assigning
  // `__proto__` sets the prototype instead of a property (the input's own
  // `__proto__` property can only come from JSON.parse or
  // Object.defineProperty). Likewise assoc (v0.8.0): the keys of
  // `assoc('__proto__', 1, {a: 1})` are ['a'], and those of `assoc('a', 2,
  // JSON.parse('{"__proto__": 5, "b": 1}'))` are ['b', 'a']; and since v0.9.0
  // `invertObj({a: '__proto__', b: 'c'})` is {c: 'b'}, `evolve({a: x => x},
  // <the JSON object>)` has the keys ['a'], and `evolve({toString: x =>
  // typeof x}, {})` passes the inherited member (the result is {toString:
  // 'function'}). A map's keys are all ordinary, and `{}` has no `toString`.
  method {:test} DeviationPrototypeKeysAreOrdinaryInObjectCopies() {
    var o := map["__proto__" := 5, "a" := 1];
    var none: map<string, int> := map[];
    expect clone(o) == o;
    expect mixin(o, none) == o;
    expect invertObj(map["a" := "__proto__", "b" := "c"]) == map["__proto__" := "a", "c" := "b"];
    expect evolve(map["a" := (v: Option<int>) => if v.Some? then v.value else 0], o) == o;
    var kind := (v: Option<string>) => if v.None? then "undefined" else "string";
    var noStrings: map<string, string> := map[];
    expect evolve(map["toString" := kind], noStrings) == map["toString" := "undefined"];
    expect assoc("__proto__", 1, map["a" := 1]) == map["__proto__" := 1, "a" := 1];
    expect assoc("a", 2, map["__proto__" := 5, "b" := 1]) == map["__proto__" := 5, "b" := 1, "a" := 2];
  }

  // node: eq([], []) is false (two distinct array objects).
  method {:test} DeviationEqIsStructural() {
    var a: seq<int> := [];
    var b: seq<int> := [];
    expect eq(a, b) == true;
  }

  // node: 'STRASSE' and 'Ä'; case conversion is ASCII-only here.
  method {:test} DeviationCaseConversionIsAsciiOnly() {
    expect toUpper("straße") == "STRAßE";
    expect toUpper("ä") == "ä";
  }

  // node: 55357 (a UTF-16 surrogate) and length 2; a Dafny char is a code point.
  method {:test} DeviationCharactersAreCodePoints() {
    expect charCodeAt(0, "\U{1F600}") == 0x1F600;
    expect |"\U{1F600}"| == 1;
  }

  // node: invert({a: 'toString'}), invert({a: '__proto__'}) and every other
  // value naming an `Object.prototype` member throw "TypeError:
  // out[val].push is not a function" (v0.9.0); here the value is an ordinary
  // key.
  method {:test} DeviationInvertOfPrototypeNamedValues() {
    expect invert(map["a" := "toString"]) == map["toString" := {"a"}];
    expect invert(map["a" := "__proto__", "b" := "x"]) == map["__proto__" := {"a"}, "x" := {"b"}];
  }

  // node: eq(negate(0), 0), eq(multiply(-1, 0), 0) and eq(modulo(-4, 2), 0)
  // are false since v0.9.0 (eq is `Object.is`, and each left side is -0),
  // and so is eqDeep([negate(0)], [0]); an int has no -0.
  method {:test} DeviationEqSignedZero() {
    expect eq(negate(0), 0) == true;
    expect eq(multiply(-1, 0), 0) == true;
    expect eq(modulo(-4, 2), 0) == true;
  }

  // node: allPass([]) and anyPass([]) throw "First argument to arity must be
  // a non-negative integer no greater than ten" (v0.9.0: the result's arity
  // is the longest predicate's, and `max([])` is -Infinity); the
  // two-argument forms allPass([], 5) and anyPass([], 5) are true and false.
  method {:test} DeviationAllPassOfTheEmptyList() {
    var none: seq<int -> bool> := [];
    expect allPass(none)(5) == true;
    expect anyPass(none)(5) == false;
  }
}
