// Edge cases for Object, Math, String, Logic and Functions, checked against
// dist/ramda.js v0.27.2 under node; the methods named Deviation* pin documented
// deviations (README "Deviations") and say what node returns.

module RamdafTests.Edge.Misc {
  import opened Ramdaf.Prelude
  import opened Ramdaf.Core
  import opened Ramdaf.Object
  import opened Ramdaf.Math
  import opened Ramdaf.String
  import opened Ramdaf.Logic
  import opened Ramdaf.Functions
  import D = Ramdaf.Data
  import L = Ramdaf.List
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
    // (until v0.25.0 `{}`'s inherited `toString` was not an own property, so
    // `propOr(5, 'toString', {})` was 5, and an own null or undefined value
    // was returned; since v0.26.0 the pins DeviationInheritedMembersAreAbsent
    // and DeviationPropOrOfNilValues hold those lines)
    expect propOr(5, "hasOwnProperty", map["hasOwnProperty" := 1]) == 1;
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

  // merge (mixin until v0.9.1): b's value wins.
  method {:test} MergeEdges() {
    var none: map<string, int> := map[];
    expect merge(map["a" := 1, "b" := 2], map["b" := 3, "c" := 4]) == map["a" := 1, "b" := 3, "c" := 4];
    expect merge(none, map["b" := 3]) == map["b" := 3];
    expect merge(map["a" := 1], none) == map["a" := 1];
  }

  // dissoc (v0.10.0) copies obj without the property (node: {a: 1, c: 3},
  // {a: 1}, {}, {x: 2} and {a: 1} for `dissoc('toString', {a: 1})`).
  method {:test} DissocEdges() {
    var none: map<string, int> := map[];
    expect dissoc("b", map["a" := 1, "b" := 2, "c" := 3]) == map["a" := 1, "c" := 3];
    expect dissoc("d", map["a" := 1]) == map["a" := 1];
    expect dissoc("a", none) == map[];
    expect dissoc("hasOwnProperty", map["hasOwnProperty" := 1, "x" := 2]) == map["x" := 2];
    expect dissoc("toString", map["a" := 1]) == map["a" := 1];
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

  // where (v0.14.0): every spec value is a predicate on the test object's
  // property, called with undefined (None) when it is absent. Node: true
  // for `where({x: v => v === undefined}, {y: 1})` and `where({x: v =>
  // true}, {y: 1})` (both false until v0.13.0, which did not call a
  // function on an absent property), false for `where({x: v => v === 1},
  // {y: 1})`, true for `where({}, {a: 1})`, and true, false, false for
  // `where({x: v => v === 1, y: v => v > 1}, …)` on {x: 1, y: 2}, {x: 1, y:
  // 0} and {x: 1}.
  method {:test} WhereEdges() {
    var y1 := map["y" := 1];
    expect where(map["x" := (v: Option<int>) => v.None?], y1) == true;
    expect where(map["x" := (v: Option<int>) => true], y1) == true;
    expect where(map["x" := (v: Option<int>) => v == Some(1)], y1) == false;
    var empty: map<string, Option<int> -> bool> := map[];
    expect where(empty, map["a" := 1]) == true;
    var two := map["x" := (v: Option<int>) => v == Some(1), "y" := (v: Option<int>) => v.Some? && v.value > 1];
    expect where(two, map["x" := 1, "y" := 2]) == true;
    expect where(two, map["x" := 1, "y" := 0]) == false;
    expect where(two, map["x" := 1]) == false;
  }

  // whereEq (v0.14.0). Node: true for `whereEq({a: 1}, {a: 1, b: 2})`,
  // `whereEq({}, {})` and `whereEq({toString: 'x'}, {toString: 'x'})`, false
  // for `whereEq({a: 1}, {b: 1})` and `whereEq({a: 1, b: 2}, {a: 1})`.
  method {:test} WhereEqEdges() {
    expect whereEq(map["a" := 1], map["a" := 1, "b" := 2]) == true;
    var none: map<string, int> := map[];
    expect whereEq(none, none) == true;
    expect whereEq(map["toString" := "x"], map["toString" := "x"]) == true;
    expect whereEq(map["a" := 1], map["b" := 1]) == false;
    expect whereEq(map["a" := 1, "b" := 2], map["a" := 1]) == false;
  }

  // lensProp (v0.14.0), run with view, set and over since v0.16.0. Node:
  // `view(lensProp('a'), {a: 1})` is 1, `set(lensProp('x'), 9, {x: 1})` is
  // {x: 9}, and `over(lensProp('a'), x => x + 1, {a: 1, b: 2})` is {a: 2,
  // b: 2}. (`view(lensProp('x'), {})` is undefined, outside the getter's
  // domain, and since v0.16.0 so is `set(lensProp('x'), 9, {})`, {x: 9} in
  // node, as `set` runs the getter.)
  method {:test} LensPropEdges() {
    expect view(lensProp<int, int>("a"), map["a" := 1]) == 1;
    expect set_(lensProp<int, int>("x"), 9, map["x" := 1]) == map["x" := 9];
    expect over(lensProp<int, int>("a"), (x: int) => x + 1, map["a" := 1, "b" := 2]) == map["a" := 2, "b" := 2];
  }

  // Lenses compose with compose and pipe (v0.16.0; composeL and pipeL from
  // v0.14.0 to v0.15.1). Node: for `l = compose(lensProp('a'),
  // lensProp('b'))` and `s = {a: {b: 1}, c: {d: 2}}`, `view(l, s)` is 1,
  // `set(l, 9, s)` is {a: {b: 9}, c: {d: 2}} and `over(l, x => x + 1, s)` is
  // {a: {b: 2}, c: {d: 2}}; `pipe(lensProp('b'), lensProp('a'))`, the same
  // lens, gives 1 and {a: {b: 9}, c: {d: 2}}. (`set(l, 9, {a: {}})` is {a:
  // {b: 9}} in node, outside the domain: the inner getter needs b.)
  method {:test} ComposedLensEdges() {
    var l := compose(lensProp<map<string, int>, int>("a"), lensProp<int, int>("b"));
    var s := map["a" := map["b" := 1], "c" := map["d" := 2]];
    expect view(l, s) == 1;
    expect set_(l, 9, s) == map["a" := map["b" := 9], "c" := map["d" := 2]];
    expect over(l, (x: int) => x + 1, s) == map["a" := map["b" := 2], "c" := map["d" := 2]];
    var p := pipe(lensProp<int, int>("b"), lensProp<map<string, int>, int>("a"));
    expect view(p, s) == 1;
    expect set_(p, 9, s) == map["a" := map["b" := 9], "c" := map["d" := 2]];
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
    // max and min (binary since v0.16.0) keep the first argument on a tie
    // (node: 3, 2, 9, 3, 9; until v0.15.1 they took a list, and
    // createMaxMin kept the first winner)
    expect max(3, 3) == 3;
    expect min(2, 2) == 2;
    expect max(9, 3) == 9;
    expect min(9, 3) == 3;
    expect max(3, 9) == 9;
    expect subtract(2, 5) == -3;
    expect divide(6.0, 3.0) == 2.0;
    expect sum(empty) == 0;
    expect product(empty) == 1;
  }

  // maxBy and minBy (binary since v0.16.0, `f(b) > f(a) ? b : a`) keep the
  // first argument on a tie (node: [5, 1], [1, 1], 3, 3). (Since v0.2.0
  // maxWith/minWith, maxBy/minBy since v0.8.0, took a key function and a
  // list, the first of equals winning; in v0.15.x the first element was
  // skipped.)
  method {:test} MaxByMinByKeepTheFirstOfEquals() {
    expect maxBy((r: (int, int)) => r.0, (5, 1), (5, 2)) == (5, 1);
    expect minBy((r: (int, int)) => r.0, (1, 1), (1, 2)) == (1, 1);
    expect maxBy((x: int) => x % 2, 3, 5) == 3;
    expect minBy((x: int) => x % 2, 3, 5) == 3;
  }

  // Node (v0.16.0): `maxBy(x => -x, 1, 2)` is 1, `minBy(x => -x, 1, 2)` 2,
  // `maxBy(x => x, 9, 1)` 9 and `minBy(x => x, 9, 1)` 1.
  method {:test} MaxByMinByCompareKeys() {
    expect maxBy((x: int) => -x, 1, 2) == 1;
    expect minBy((x: int) => -x, 1, 2) == 2;
    expect maxBy((x: int) => x, 9, 1) == 9;
    expect minBy((x: int) => x, 9, 1) == 1;
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

  // trim (v0.6.0) strips the leading and trailing runs of its 25 whitespace
  // characters: node keeps U+180E (since v0.27.2, the native trim; until
  // v0.27.1 Ramda's fallback stripped it, 'x'), U+200B and U+0085, and inner
  // whitespace stays.
  method {:test} TrimEdges() {
    expect trim("\U{180E} x \U{180E}") == "\U{180E} x \U{180E}";
    expect trim("\U{200B} x \U{200B}") == "\U{200B} x \U{200B}";
    expect trim("\U{0085} x \U{0085}") == "\U{0085} x \U{0085}";
    expect trim("") == "";
    expect trim("   ") == "";
    expect trim("a  b") == "a  b";
    expect trim(" \U{1F600} ") == "\U{1F600}";
  }

  // both/either/complement combine predicates (v0.12.0 renamed and/or/not,
  // which v0.1.4 had renamed from andFn/orFn/notFn).
  method {:test} PredicateCombinators() {
    expect both((x: int) => x > 0, (x: int) => x < 10)(5) == true;
    expect both((x: int) => x > 0, (x: int) => x < 10)(15) == false;
    expect either((x: int) => x < 0, (x: int) => x > 10)(15) == true;
    expect either((x: int) => x < 0, (x: int) => x > 10)(5) == false;
    expect complement((x: int) => x > 0)(5) == false;
    expect complement((x: int) => x > 0)(-1) == true;
  }

  // and/or/not (v0.12.0) are `a && b`, `a || b` and `!a` (node: false,
  // false, true, true, false, true on booleans).
  method {:test} BooleanOperators() {
    expect and(false, true) == false;
    expect and(true, true) == true;
    expect or(true, false) == true;
    expect or(false, false) == false;
    expect not(true) == false;
    expect not(false) == true;
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
  // argument, then combines them; since v0.18.0 the functions are one list,
  // a pair here (node: [6, 10] and 'ab!2').
  method {:test} ConvergeEdges() {
    expect converge((a: int, b: int) => [a, b], ((x: int) => x + 1, (x: int) => x * 2))(5) == [6, 10];
    expect converge((n: int, t: string) => t + NumStr(n), ((s: string) => |s|, (s: string) => s + "!"))("ab") == "ab!2";
    // node: converge((x, y) => [x, y], [(a, b) => a + b, (a, b) => a * b])(2, 5)
    // is [7, 10]; the port's result is unary, so the arguments are a tuple.
    expect converge((x: int, y: int) => [x, y], ((t: (int, int)) => t.0 + t.1, (t: (int, int)) => t.0 * t.1))((2, 5)) == [7, 10];
  }

  // when and unless (v0.18.0) pass x through the function when the predicate
  // holds (fails), and return x otherwise; a falsy predicate result (`0`,
  // '') is false here (node: -5, -5, 5, 5, ['z'], [2], 1, 9).
  method {:test} WhenUnlessEdges() {
    expect when((x: int) => x > 0, negate, 5) == -5;
    expect when((x: int) => x > 0, negate, -5) == -5;
    expect unless((x: int) => x > 0, negate, 5) == 5;
    expect unless((x: int) => x > 0, negate, -5) == 5;
    var empty: seq<string> := [];
    expect when(isEmpty, (l: seq<string>) => ["z"], empty) == ["z"];
    expect unless((l: seq<int>) => isEmpty(l), tail, [1, 2]) == [2];
    expect when((x: int) => false, (x: int) => 9, 1) == 1;
    expect unless((x: int) => false, (x: int) => 9, 1) == 9;
  }

  // objOf (v0.18.0; createMapEntry's code) builds a one-property object
  // (node: {a: 1}, {'': [1]}, and the key toString is an own property).
  method {:test} ObjOfEdges() {
    expect objOf("a", 1) == map["a" := 1];
    expect objOf("", [1]) == map["" := [1]];
    expect objOf("toString", 1) == map["toString" := 1];
  }

  // inc and dec (v0.9.0) are add(1) and add(-1), and negate is -n (v0.11.0;
  // multiply(-1) in v0.9.x and v0.10.0)
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

  // defaultTo (v0.10.0) returns the value unless it is null or undefined
  // (node: 42 for null and undefined, then 'x', '', 0 and false), and it
  // composes with the "no value" results: `defaultTo(0, prop('a', {}))`,
  // `defaultTo(0, nth(5, [1]))` and `defaultTo(0, prop('a', {a: 7}))` give
  // 0, 0 and 7.
  method {:test} DefaultToEdges() {
    var none: Option<int> := None;
    expect defaultTo(42, none) == 42;
    expect defaultTo(42, Some(0)) == 0;
    expect defaultTo("d", Some("x")) == "x";
    expect defaultTo("d", Some("")) == "";
    expect defaultTo(true, Some(false)) == false;
    expect defaultTo(0, prop("a", map["b" := 1])) == 0;
    expect defaultTo(0, nth(5, [1])) == 0;
    expect defaultTo(0, prop("a", map["a" := 7])) == 7;
  }

  // evolve (v0.9.0) sets each transformed key to fn(obj[key]); since v0.15.0
  // only the object's own keys are visited (node: {a: 2, b: 2}, {a: 1}, {a:
  // 1}; until v0.14.0 the second was {a: 1, c: 'U'}, as a missing key gave
  // fn(undefined)).
  method {:test} EvolveEdges() {
    var incOr := (v: Option<int>) => if v.Some? then v.value + 1 else -1;
    expect evolve(map["a" := incOr], map["a" := 1, "b" := 2]) == map["a" := 2, "b" := 2];
    // v0.15.0: a transformation for a key the object lacks adds nothing
    // (node {a: 1}; until v0.14.0 {a: 1, c: 'U'})
    expect evolve(map["c" := (v: Option<Js>) => if v.None? then Str("U") else v.value], map["a" := Num(1)]) ==
      map["a" := Num(1)];
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

  // Since v0.10.0 invert ignores inherited properties of its result, so a
  // value naming an `Object.prototype` member is an ordinary key (node:
  // {toString: ['a'], x: ['b']}, {constructor: ['a', 'b']}; v0.9.x threw
  // "TypeError: out[val].push is not a function").
  method {:test} InvertOfPrototypeNamedValues() {
    expect invert(map["a" := "toString", "b" := "x"]) == map["toString" := {"a"}, "x" := {"b"}];
    expect invert(map["a" := "constructor", "b" := "constructor"]) == map["constructor" := {"a", "b"}];
  }

  // propSatisfies (v0.16.0) gives the predicate the property, undefined
  // (None) when it is absent (node: true, true); composeK and pipeK (v0.16.0)
  // chain over lists, since v0.23.0 starting from a value that the last
  // function (the first, for pipeK) is applied to (node: `composeK(x => [x,
  // x * 10], x => [x + 1])(1)` is [2, 20], and so is `pipeK(x => [x + 1], x
  // => [x, x * 10])(1)`; `composeK(x => [], x => [x])(1)` and `composeK(x =>
  // [x], x => [])(1)` are []; until v0.22.1 they took a list, and the first
  // two on [1, 2] were [2, 20, 3, 30]).
  method {:test} PropSatisfiesAndComposeKEdges() {
    var none: map<string, int> := map[];
    expect propSatisfies((x: Option<int>) => x.None?, "a", none) == true;
    expect propSatisfies((x: Option<int>) => x == Some(1), "a", map["a" := 1]) == true;
    expect composeK((x: int) => [x, x * 10], (x: int) => [x + 1])(1) == [2, 20];
    expect pipeK((x: int) => [x + 1], (x: int) => [x, x * 10])(1) == [2, 20];
    var nothing: seq<int> := [];
    expect composeK((x: int) => nothing, (x: int) => [x])(1) == [];
    expect composeK((x: int) => [x], (x: int) => nothing)(1) == [];
  }

  // ---- documented deviations (not node behaviour) ----


  // node: clone(JSON.parse('{"__proto__": 5, "a": 1}')) (cloneObj and
  // cloneDeep until v0.8.0), merge(<the same>, {}) (mixin until v0.9.1) and
  // dissoc('x', <the same>) (v0.10.0) are {a: 1}: assigning
  // `__proto__` sets the prototype instead of a property (the input's own
  // `__proto__` property can only come from JSON.parse or
  // Object.defineProperty). Likewise assoc (v0.8.0): the keys of
  // `assoc('__proto__', 1, {a: 1})` are ['a'], and those of `assoc('a', 2,
  // JSON.parse('{"__proto__": 5, "b": 1}'))` are ['b', 'a']; and since v0.9.0
  // `invertObj({a: '__proto__', b: 'c'})` is {c: 'b'} and `evolve({a: x =>
  // x}, <the JSON object>)` has the keys ['a']; since v0.14.0
  // `whereEq(<JSON {"__proto__": 1}>, {})` is true (`mapObj`'s copy of the
  // spec drops the property, so it is not tested) and the keys of
  // `lensProp('__proto__').set(1, {a: 1})` were ['a'] (`assoc`; since
  // v0.16.0 `set(lensProp('__proto__'), 1, <JSON {"__proto__": 0, "a":
  // 1}>)` has the keys ['a'], as set runs the getter, which here requires
  // the key); and since
  // v0.15.0 `pick(['toString'], {})` has the inherited function as its
  // `toString` (`names[idx] in obj`), and `evolve({a: f}, {toString: 4})` is
  // {toString: '[object Undefined]'}, as the object's own `toString` key
  // finds the transformations' inherited `toString` and calls it. (From
  // v0.9.0 to v0.14.0 `evolve({toString: x => typeof x}, {})` passed the
  // inherited member to the transformation, {toString: 'function'}; since
  // v0.15.0 it is {}, as here.) Since v0.18.0 `objOf('__proto__', 1)` has
  // no own key (createMapEntry's assignment, until v0.18.0), and since
  // v0.19.0 the keys of `mergeWith((a, b) => b, <the JSON object>, {})`,
  // and of `mergeWithKey` of it and `JSON.parse('{"__proto__": 6}')`, are
  // ['a']; since v0.20.0 an own `__proto__` spec function of `applySpec`
  // (made with Object.defineProperty) is dropped by the spec's copy, so
  // `applySpec(<{__proto__: x => 5, a: x => 1}>)(0)` has the keys ['a']. A
  // map's keys are all ordinary, and `{}` has no `toString`.
  method {:test} DeviationPrototypeKeysAreOrdinaryInObjectCopies() {
    var o := map["__proto__" := 5, "a" := 1];
    var none: map<string, int> := map[];
    expect clone(o) == o;
    expect merge(o, none) == o;
    expect dissoc("x", o) == o;
    expect invertObj(map["a" := "__proto__", "b" := "c"]) == map["__proto__" := "a", "c" := "b"];
    expect evolve(map["a" := (v: Option<int>) => if v.Some? then v.value else 0], o) == o;
    expect evolve(map["a" := (v: Option<int>) => 0], map["toString" := 4]) == map["toString" := 4];
    expect pick(["toString"], none) == map[];
    expect assoc("__proto__", 1, map["a" := 1]) == map["__proto__" := 1, "a" := 1];
    expect assoc("a", 2, map["__proto__" := 5, "b" := 1]) == map["__proto__" := 5, "b" := 1, "a" := 2];
    expect whereEq(map["__proto__" := 1], none) == false;
    expect set_(lensProp<int, int>("__proto__"), 1, map["__proto__" := 0, "a" := 1]) == map["__proto__" := 1, "a" := 1];
    expect objOf("__proto__", 1) == map["__proto__" := 1];
    expect mergeWith((a: int, b: int) => b, o, none) == o;
    expect mergeWithKey((k: string, a: int, b: int) => b, o, map["__proto__" := 6]) == map["__proto__" := 6, "a" := 1];
    expect applySpec(map["__proto__" := (x: int) => 5, "a" := (x: int) => 1])(0) == map["__proto__" := 5, "a" := 1];
  }

  // mergeWith and mergeWithKey (v0.19.0): fn only where both objects have
  // the key (node: {a: 1, b: 5}, {}, {toString: 'toString'},
  // {hasOwnProperty: 12}).
  method {:test} MergeWithEdges() {
    var none: map<string, int> := map[];
    expect mergeWith((a: int, b: int) => a + b, map["a" := 1, "b" := 2], map["b" := 3]) == map["a" := 1, "b" := 5];
    expect mergeWith((a: int, b: int) => a + b, none, none) == none;
    expect mergeWithKey((k: string, a: string, b: string) => k, map["toString" := "1"], map["toString" := "2"]) ==
      map["toString" := "toString"];
    expect mergeWith((a: int, b: int) => a * 10 + b, map["hasOwnProperty" := 1], map["hasOwnProperty" := 2]) ==
      map["hasOwnProperty" := 12];
  }

  // juxt (v0.19.0) applies every function to the argument (node: [6], []).
  method {:test} JuxtEdges() {
    var none: seq<int -> int> := [];
    expect juxt([(x: int) => x * 2])(3) == [6];
    expect juxt(none)(3) == [];
  }

  // node: identical([], []) is false (two distinct array objects; eq([],
  // []) until v0.14.0 and in v0.15.1, which v0.15.0 and v0.16.0 removed).
  method {:test} DeviationIdenticalIsStructural() {
    var a: seq<int> := [];
    var b: seq<int> := [];
    expect D.identical(a, b) == true;
  }

  // node: a read of a name that the object lacks finds the inherited
  // `Object.prototype` member: `prop('toString', {})` is the function (since
  // v0.1.0), and so are `props(['toString', 'a'], {a: 1})[0]` (v0.8.0; the
  // second is 1), `pluck('toString', [{}])[0]`, the `toString` of
  // `pickAll(['toString'], {})` and of `project(['toString'], [{}])[0]`
  // (since v0.1.0), and `where({toString: x => x === undefined}, {})` is
  // false, as the predicate gets it (since v0.14.0; until v0.13.0 a function
  // entry was called for an inherited property, so `where({toString: () =>
  // true}, {})` was true, except in v0.2.3), and so is
  // `propSatisfies(x => x === undefined, 'toString', {})` (v0.16.0), and
  // since v0.26.0 `propOr(0, 'toString', {})` is the function (`pathOr`; it
  // was 0). A map has no prototype: the reads give None (propOr's default).
  method {:test} DeviationInheritedMembersAreAbsent() {
    var none: map<string, int> := map[];
    expect prop("toString", none) == None;
    expect props(["toString", "a"], map["a" := 1]) == [None, Some(1)];
    expect pickAll(["toString"], none) == map["toString" := None];
    expect L.pluck("toString", [none]) == [None];
    expect D.project(["toString"], [none]) == [map["toString" := None]];
    expect where(map["toString" := (x: Option<int>) => x.None?], none) == true;
    expect propSatisfies((x: Option<int>) => x.None?, "toString", none) == true;
    expect propOr(0, "toString", none) == 0;
  }

  // node: since v0.26.0 `propOr(val, p, obj)` is `pathOr(val, [p], obj)`,
  // which gives val for a null, undefined or NaN property as well as for an
  // absent one: `propOr('d', 'x', {x: null})` and `propOr('d', 'x', {x:
  // undefined})` are 'd' (null and undefined until v0.25.0), while `{x: 0}`
  // and `{x: false}` keep their values. The port's generic V cannot be
  // tested for nil, so a Js Null or Undefined value is returned (README
  // "Deviations").
  method {:test} DeviationPropOrOfNilValues() {
    expect propOr(Str("d"), "x", map["x" := Null]) == Null;
    expect propOr(Str("d"), "x", map["x" := Undefined]) == Undefined;
    expect propOr(Str("d"), "x", map["x" := Num(0)]) == Num(0);
    expect propOr(Str("d"), "x", map["x" := Bool(false)]) == Bool(false);
  }

  // node: 'STRASSE' and 'Ä'; case conversion is ASCII-only here.
  method {:test} DeviationCaseConversionIsAsciiOnly() {
    expect toUpper("straße") == "STRAßE";
    expect toUpper("ä") == "ä";
  }

  // node: the length of '\u{1F600}' is 2, `split('', '\u{1F600}')` has two
  // pieces (the UTF-16 surrogates), and since v0.18.0 `reverse('a\u{1F600}')`
  // reverses the code units, '\ude00\ud83da' (until v0.17.1 the pin used
  // `nthCharCode(0, '\u{1F600}')`, 55357, and until v0.13.0 `charCodeAt`; both
  // are gone); a Dafny char is a code point.
  method {:test} DeviationCharactersAreCodePoints() {
    expect |"\U{1F600}"| == 1;
    expect split("", "\U{1F600}") == ["\U{1F600}"];
    expect L.reverse("a\U{1F600}") == "\U{1F600}a";
  }

  // node: invert({a: '__proto__', b: 'x'}) is {x: ['b']} since v0.10.0:
  // `out['__proto__'] = []` sets the result's prototype to the array ['a']
  // instead of a property. (In v0.9.x it and every other value naming an
  // `Object.prototype` member threw "TypeError: out[val].push is not a
  // function"; the others now agree with the port, InvertOfPrototypeNamedValues
  // above.) Here the value is an ordinary key.
  method {:test} DeviationInvertOfPrototypeNamedValues() {
    expect invert(map["a" := "__proto__", "b" := "x"]) == map["__proto__" := {"a"}, "x" := {"b"}];
  }

  // node: identical(negate(0), 0), identical(multiply(-1, 0), 0) and
  // identical(modulo(-4, 2), 0) are false (`Object.is`; with `eq` from
  // v0.9.0 to v0.14.0 and in v0.15.1), as each left side is -0;
  // and `propEq('a', negate(0), {a: 0})` (`propEq(negate(0), 'a', {a: 0})`
  // in v0.16.0), `eqProps('a', {a: negate(0)}, {a:
  // 0})` and `whereEq({a: 0}, {a: negate(0)})` are false since v0.14.0
  // (`Object.is`, since v0.15.0 `R.equals`, which compares numbers with
  // identical; true until v0.13.0, with `===`). An int has no -0.
  method {:test} DeviationIdenticalSignedZero() {
    expect D.identical(negate(0), 0) == true;
    expect D.identical(multiply(-1, 0), 0) == true;
    expect D.identical(modulo(-4, 2), 0) == true;
    expect propEq("a", negate(0), map["a" := 0]) == true;
    expect eqProps("a", map["a" := negate(0)], map["a" := 0]) == true;
    expect whereEq(map["a" := 0], map["a" := negate(0)]) == true;
  }

  // node: since v0.18.0 allPass([])(5) is true and anyPass([])(5) false, as
  // here. (This was the pin DeviationAllPassOfTheEmptyList from v0.9.0 to
  // v0.17.1, when allPass([]) and anyPass([]) threw "First argument to arity
  // must be a non-negative integer no greater than ten", the result's arity
  // being the longest predicate's and `max([])` -Infinity, while the
  // two-argument forms allPass([], 5) and anyPass([], 5) were true and false.)
  method {:test} AllPassOfTheEmptyList() {
    var none: seq<int -> bool> := [];
    expect allPass(none)(5) == true;
    expect anyPass(none)(5) == false;
  }

  // node: since v0.15.0 evolve loops over the object's own keys instead of
  // folding the transformations with mapObjIndexed, so neither marker key
  // ends anything: evolve({'@@transducer/reduced': x => 1}, {a: 1}) and
  // evolve({__transducers_reduced__: x => 1}, {a: 1}) are {a: 1}, as here
  // (and the key the object lacks is not added). (This was the pin
  // DeviationReducedMarkerIsAnOrdinaryKey in v0.12.0 to v0.14.0.)
  method {:test} EvolveIgnoresTheReducedMarker() {
    expect evolve(map["@@transducer/reduced" := (v: Option<int>) => 1], map["a" := 1]) == map["a" := 1];
    expect evolve(map["__transducers_reduced__" := (v: Option<int>) => 1], map["a" := 1]) == map["a" := 1];
    expect evolve(map["@@transducer/reduced" := (v: Option<int>) => 1], map["@@transducer/reduced" := 0]) ==
      map["@@transducer/reduced" := 1];
  }

  // applySpec (v0.20.0): since v0.26.0 it copies its spec with its own
  // `keys` loop, so a reduced marker key and a key `map` are ordinary, as
  // here (node: {'@@transducer/reduced': 1, a: 2}, {map: 3},
  // {'fantasy-land/map': 4}). From v0.20.0 to v0.25.0 the copy was `R.map`,
  // whose `_reduce` ended at the marker (the copy was undefined, so applySpec
  // threw TypeError) and which dispatched to a spec's own `map` method (and
  // since v0.24.0 `fantasy-land/map`), so those specs threw too; this was
  // the pin DeviationApplySpecReducedMarkerIsAnOrdinaryKey from v0.20.0 to
  // v0.25.0.
  method {:test} ApplySpecReducedMarkerAndMapKeysAreOrdinary() {
    expect applySpec(map["@@transducer/reduced" := (x: int) => 1, "a" := (x: int) => 2])(0) ==
      map["@@transducer/reduced" := 1, "a" := 2];
    expect applySpec(map["map" := (x: int) => 3])(0) == map["map" := 3];
    expect applySpec(map["fantasy-land/map" := (x: int) => 4])(0) == map["fantasy-land/map" := 4];
  }

  // applySpec (v0.20.0): every key's function on the one argument, a
  // function shared by keys included, and `toString` an ordinary key (node:
  // {a: 2, b: 2}, {toString: 6}).
  method {:test} ApplySpecEdges() {
    var addOne := (x: int) => x + 1;
    expect applySpec(map["a" := addOne, "b" := addOne])(1) == map["a" := 2, "b" := 2];
    expect applySpec(map["toString" := (x: int) => x * 2])(3) == map["toString" := 6];
  }

  // until (v0.20.0): fn is not called when pred already holds (node: 5, 4,
  // [0, 1, 2]).
  method {:test} UntilEdges() {
    var none: seq<int> := [];
    expect until((x: int) => x > 0, (x: int) => x - 1, 5, 100) == 5;
    expect until((x: int) => x > 3, (x: int) => x + 1, 0, 100) == 4;
    expect until((l: seq<int>) => |l| > 2, (l: seq<int>) => l + [|l|], none, 100) == [0, 1, 2];
    expect until((x: int) => x > 3, (x: int) => x + 1, 0, 4) == 4;
  }

  // JS until (v0.20.0) would loop forever here (`until(x => x < 0, x => x +
  // 1, 0)`); the fuel bound stops it after that many applications of fn and
  // returns the value reached (README "Deviations").
  method {:test} DeviationUntilStopsAtFuel() {
    expect until((x: int) => x < 0, (x: int) => x + 1, 0, 3) == 3;
  }

  // o (v0.24.0): `f(g(x))` (node: 21).
  method {:test} OEdges() {
    expect o((x: int) => x + 1, (x: int) => x * 2, 10) == 21;
  }

  // applyTo (v0.25.0): `f(x)` (node: 3).
  method {:test} ApplyToEdges() {
    expect applyTo(2, (x: int) => x + 1) == 3;
  }

  // omit (v0.25.0): a name 'hasOwnProperty' throws TypeError on the first
  // property of obj (`omit(['hasOwnProperty'], {a: 1})`, outside the
  // domain), but not on an empty object; other `Object.prototype` names are
  // ordinary (node: {}, {b: 2}, {b: 2}).
  method {:test} OmitEdges() {
    var empty: map<string, int> := map[];
    expect omit(["hasOwnProperty"], empty) == map[];
    expect omit(["toString", "constructor"], map["toString" := 1, "b" := 2]) == map["b" := 2];
    expect omit(["a", "a"], map["a" := 1, "b" := 2]) == map["b" := 2];
  }

  // mergeLeft and mergeRight (v0.26.0): the left's or the right's value wins
  // (node: {a: 1, b: 2, c: 4}, {a: 1, b: 3, c: 4}, {}, {a: 1}).
  method {:test} MergeLeftRightEdges() {
    var empty: map<string, int> := map[];
    expect mergeLeft(map["a" := 1, "b" := 2], map["b" := 3, "c" := 4]) == map["a" := 1, "b" := 2, "c" := 4];
    expect mergeRight(map["a" := 1, "b" := 2], map["b" := 3, "c" := 4]) == map["a" := 1, "b" := 3, "c" := 4];
    expect mergeLeft(empty, empty) == map[];
    expect mergeRight(empty, map["a" := 1]) == map["a" := 1];
  }

  // thunkify, pipeWith and composeWith (v0.26.0) (node: 3, 8, 7).
  method {:test} ThunkifyPipeWithComposeWithEdges() {
    expect thunkify((t: (int, int)) => t.0 + t.1)((1, 2))() == 3;
    var ap := (f: int -> int, r: int) => f(r);
    expect pipeWith(ap, ((x: int) => x + 1, (x: int) => x * 2))(3) == 8;
    expect composeWith(ap, ((x: int) => x + 1, (x: int) => x * 2))(3) == 7;
  }

  // xor (v0.27.0): true when exactly one operand is true (node: false, true,
  // true, false).
  method {:test} XorEdges() {
    expect xor(false, false) == false;
    expect xor(false, true) == true;
    expect xor(true, false) == true;
    expect xor(true, true) == false;
  }
}
