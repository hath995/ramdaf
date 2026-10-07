// Edge cases for Sort and Data, checked against dist/ramda.js v0.30.0 under node;
// the last methods pin documented deviations (README "Deviations").

module RamdafTests.Edge.Data {
  import opened Ramdaf.Prelude
  import opened Ramdaf.Sort
  import opened Ramdaf.Data
  import M = Ramdaf.Math
  import L = Ramdaf.List
  import opened Support

  method {:test} ComparatorSigns() {
    var c := comparator((a: int, b: int) => a < b);
    expect c(1, 2) == -1;
    expect c(2, 1) == 1;
    expect c(1, 1) == 0;
    expect sort(c, [5, 5, 1]) == [1, 5, 5];
  }

  // sort and sortBy are stable (equal keys keep their input order).
  method {:test} SortIsStable() {
    var empty: seq<int> := [];
    expect sort((a: int, b: int) => a - b, empty) == [];
    expect sort((a: string, b: string) => |a| - |b|,
                ["bb", "a", "cc", "d", "eee", "f", "gg", "h", "ii", "j", "kkk", "l"]) ==
      ["a", "d", "f", "h", "j", "l", "bb", "cc", "gg", "ii", "eee", "kkk"];
  }

  method {:test} SortByIsStable() {
    expect sortBy((x: int) => x % 2, [3, 2, 1, 4]) == [2, 4, 3, 1];
    expect sortBy((x: int) => x % 2, [11, 10, 9, 8, 7, 6, 5, 4, 3, 2, 1, 0]) ==
      [10, 8, 6, 4, 2, 0, 11, 9, 7, 5, 3, 1];
    expect sortBy((x: int) => -x, [1, 2, 3]) == [3, 2, 1];
    expect sortBy((s: string) => |s|, ["ccc", "a", "bb"]) == ["a", "bb", "ccc"];
    // {k, i} records, sorted by k: the i's come out 1, 3, 0, 2
    expect sortBy((r: (int, int)) => r.0, [(2, 0), (1, 1), (2, 2), (1, 3)]) == [(1, 1), (1, 3), (2, 0), (2, 2)];
  }

  // union is `compose(uniq, _concat)` since v0.8.0, so an empty first string
  // concatenates (node: ['b'] and []; from v0.6.0 to v0.7.2, through
  // `R.concat`, both threw "TypeError: can't concat string", an unrecorded
  // deviation of those ports). A string is a seq here.
  method {:test} UnionOfAnEmptyFirstString() {
    expect union("", "b") == "b";
    expect union("", "") == "";
    expect union("ab", "bc") == "abc";
  }

  // Since v0.2.4 union/difference/intersection keep the first occurrence
  // (uniq); since v0.29.0 intersection takes its elements, and their order,
  // from the second list again, as until v0.19.1 (node: [1, 2], [2, 1], [4,
  // 3, 2], [3, 1], [1, 2], [2, 3], [2, 1]); from v0.20.0 to v0.28.0 it took
  // them from the shorter list, the first when they were equally long
  // (`intersection([3, 2], [1, 2, 3])` and `intersection([1, 2], [2, 1])`
  // were [3, 2] and [1, 2]).
  method {:test} SetOperationsKeepFirstOccurrences() {
    var empty: seq<int> := [];
    expect union([1, 2, 3], [1]) == [1, 2, 3];
    expect union(empty, empty) == [];
    expect difference([1, 2, 1, 3], [3]) == [1, 2];
    expect difference([1, 1, 2], empty) == [1, 2];
    expect intersection([1, 2, 1, 3], [1, 2]) == [1, 2];
    expect intersection([2, 1, 2], [2, 1]) == [2, 1];
    expect intersection([1, 2, 3, 4], [4, 3, 2]) == [4, 3, 2];
    expect intersection([1, 2, 1, 3], [3, 1, 1]) == [3, 1];
    expect intersection([1, 2], [3, 1, 2, 1]) == [1, 2];
    expect intersection([3, 2], [1, 2, 3]) == [2, 3];
    expect intersection([1, 2], [2, 1]) == [2, 1];
  }

  // Since v0.7.0 difference and differenceWith are loops (same results).
  // Since v0.14.0 differenceWith pushes its kept elements again: node gives
  // `differenceWith((a, b) => a < b, [3, 1, 2, 5, 4], [2])` → [3, 5] (v0.11.0
  // to v0.13.0 left a hole at every dropped index before a kept one, `[3,
  // <2 empty items>, 5]`, outside the port's domain then), and [5], [1, 2].
  method {:test} DifferenceEdges() {
    expect difference([1, 2, 1, 3], [2]) == [1, 3];
    // `difference('abcab', 'b')`: strings are lists of characters
    expect difference("abcab", "b") == "ac";
    expect differenceWith((a: int, b: int) => a < b, [3, 1, 2, 5, 4], [2]) == [3, 5];
    expect differenceWith(lt, [5, 4, 3, 2, 1], [0]) == [5];
    expect differenceWith(mod3, [1, 2, 3, 4, 5, 6], [3]) == [1, 2];
  }

  // differenceWith (node: [1, 2, 3], [1], [1, 2], [], [1, 2, 3], and [1, 3]
  // for `differenceWith(eq, [1, 2, 3, 4], [2])`, `[1, <hole>, 3, 4]` from
  // v0.11.0 to v0.13.0).
  method {:test} DifferenceWithEdges() {
    var none: seq<int> := [];
    expect differenceWith(eqInt, [1, 2, 3, 4], [4]) == [1, 2, 3];
    expect differenceWith(eqInt, [1, 2], [2]) == [1];
    expect differenceWith(eqInt, [1, 2, 1, 1], none) == [1, 2];
    expect differenceWith(eqInt, none, [1]) == [];
    expect differenceWith(eqInt, [1, 2, 3], [9]) == [1, 2, 3];
    expect differenceWith(eqInt, [1, 2, 3, 4], [2]) == [1, 3, 4];
  }

  function lt(a: int, b: int): bool { a < b }
  function eqInt(a: int, b: int): bool { a == b }
  function mod3(a: int, b: int): bool { a % 3 == b % 3 }
  function par(a: int, b: int): bool { a % 2 == b % 2 }

  // Since v0.2.4 the *With functions keep the first representative too
  // (uniqWith), and call pred(later, earlier kept).
  method {:test} WithFunctionsKeepFirstRepresentatives() {
    var empty: seq<int> := [];
    expect unionWith(mod3, [1, 2], [4]) == [1, 2];
    expect unionWith(mod3, [1, 2], [4, 5, 6]) == [1, 2, 6];
    expect unionWith(mod3, [1, 2, 3, 4], empty) == [1, 2, 3];
    expect unionWith((a: int, b: int) => a < b, [3, 1, 2], empty) == [3];
    expect differenceWith(par, [1, 2, 3], [4]) == [1];
    expect differenceWith((a: int, b: int) => a == b, [1, 2, 1], [3]) == [1, 2];
    // (intersectionWith's lines went with the function in v0.25.0.)
  }

  function parity(x: int): string { if x % 2 == 0 then "even" else "odd" }

  method {:test} GroupByAndCountByEdges() {
    var empty: seq<int> := [];
    expect groupBy(parity, [1, 2, 3, 4, 5]) == map["odd" := [1, 3, 5], "even" := [2, 4]];
    expect groupBy(parity, empty) == map[];
    expect countBy(parity, [1, 2, 3, 4]) == map["odd" := 2, "even" := 2];
    expect countBy(parity, empty) == map[];
  }

  // Since v0.9.1 countBy counts a key that names an inherited
  // `Object.prototype` member from 0 (node: {toString: 2}, {constructor: 3},
  // {hasOwnProperty: 2}, {valueOf: 1}; until v0.9.0 each was the member's
  // source followed by the 1s, such as 'function toString() { [native code]
  // }11').
  method {:test} CountByOfPrototypeNamedKeys() {
    expect countBy((x: int) => "toString", [1, 2]) == map["toString" := 2];
    expect countBy((x: int) => "constructor", [1, 2, 3]) == map["constructor" := 3];
    expect countBy((x: int) => "hasOwnProperty", [1, 2]) == map["hasOwnProperty" := 2];
    expect countBy((x: int) => "valueOf", [1]) == map["valueOf" := 1];
  }

  // sortBy (v0.9.1 sorts the elements, comparing keys computed on the fly)
  // keeps its results on ordinary lists (node: [1, 2, 3], [3, 2, 1], and the
  // stable order [[0, 'b'], [0, 'd'], [1, 'a'], [1, 'c']]).
  method {:test} SortByEdges() {
    expect sortBy((x: int) => x, [3, 1, 2]) == [1, 2, 3];
    expect sortBy((x: int) => -x, [3, 1, 2]) == [3, 2, 1];
    expect sortBy((p: (int, string)) => p.0, [(1, "a"), (0, "b"), (1, "c"), (0, "d")]) ==
      [(0, "b"), (0, "d"), (1, "a"), (1, "c")];
  }

  // Since v0.10.0 sortBy sorts a shallow copy, `_slice(list)`, so a JS
  // string sorts again (node: ['a', 'b', 'c'] for `sortBy(c =>
  // c.charCodeAt(0), 'cba')`; v0.9.1 threw "TypeError: clone(...).sort is not
  // a function") and an element object keeps an own `__proto__` key (node:
  // `Object.keys(sortBy(x => 0, [JSON.parse('{"__proto__": 5, "a":
  // 1}')])[0])` is ['__proto__', 'a']; v0.9.1 gave ['a']).
  method {:test} SortByOfAStringAndPrototypeKeys() {
    expect sortBy((c: char) => c as int, "cba") == "abc";
    var o := map["__proto__" := 5, "a" := 1];
    expect sortBy((m: map<string, int>) => 0, [o]) == [o];
  }

  // groupBy's cases from v0.1.4 to v0.2.4, when partition grouped by key
  // (v0.3.0 gave groupBy partition's body; the results are unchanged).
  method {:test} GroupByEdges() {
    var empty: seq<int> := [];
    expect groupBy((x: int) => "k", empty) == map[];
    // `String(x > 2)`: a predicate's results as keys
    expect groupBy((x: int) => if x > 2 then "true" else "false", [1, 3, 2, 4]) == map["false" := [1, 2], "true" := [3, 4]];
    expect groupBy((s: string) => s, ["b", "a", "b"]) == map["b" := ["b", "b"], "a" := ["a"]];
    // `String(x % 3)`
    expect groupBy((x: int) => if x % 3 == 0 then "0" else if x % 3 == 1 then "1" else "2", [1, 2, 3, 4, 5, 6]) ==
      map["0" := [3, 6], "1" := [1, 4], "2" := [2, 5]];
  }

  method {:test} ProjectMissingIsUndefined() {
    expect project(["a", "z"], [map["a" := 1, "b" := 2]]) == [map["a" := Some(1), "z" := None]];
  }

  // ---- documented deviations (not node behaviour) ----

  // node: [3, 2, 1] (V8's order for a comparator that always says "less");
  // the postconditions leave inconsistent comparators open, and the stable
  // insertion sort keeps the input order.
  method {:test} DeviationSortWithAnInconsistentComparator() {
    expect sort((a: int, b: int) => -1, [1, 2, 3]) == [1, 2, 3];
  }

  // node (v0.15.1): `uniq` is `uniqWith(equals)` again, so
  // `uniq([{a: 1}, {a: 1}])` is [{a: 1}], `uniq([[1], [1]])` [[1]], and
  // `union`, `uniq` of the concatenation, gives `union(Ro, So).length` 6, as
  // here. (In v0.15.0 uniq kept a JS `Set`, which compares objects by
  // reference: both elements, and 8; with `===`, 8 until v0.14.0 too. This
  // was the pin DeviationStructuralEquality.)
  method {:test} UniqAndUnionCompareDeeply() {
    var ro := [map["a" := 1], map["a" := 2], map["a" := 3], map["a" := 4]];
    var so := [map["a" := 3], map["a" := 4], map["a" := 5], map["a" := 6]];
    expect |union(ro, so)| == 6;
    expect L.uniq([map["a" := 1], map["a" := 1]]) == [map["a" := 1]];
    expect L.uniq([[1], [1]]) == [[1]];
  }

  // node (v0.15.0): `intersection(Ro, So).length` and `difference(Ro,
  // So).length` are 2 and 2, `R.equals` finding the equal objects (0 and 4
  // until v0.14.0, with `===`), as here.
  method {:test} SetOperationsCompareDeeply() {
    var ro := [map["a" := 1], map["a" := 2], map["a" := 3], map["a" := 4]];
    var so := [map["a" := 3], map["a" := 4], map["a" := 5], map["a" := 6]];
    expect |intersection(ro, so)| == 2;
    expect |difference(ro, so)| == 2;
  }

  // node: countBy(x => '__proto__', [1, 2]) is {} (the count is assigned to
  // the prototype, which ignores it), and groupBy(x => '__proto__', [1, 2])
  // has no own key (since v0.11.0; its prototype is the group, [1, 2], and
  // since v0.21.0 [2], as each element starts a new group; until v0.10.0 it
  // threw RangeError). A map's keys are all ordinary. (So at v0.2.4 as well:
  // an omission of the earlier ports. Until v0.20.1 groupBy(x =>
  // 'hasOwnProperty', [1]) was {hasOwnProperty: [undefined, 1]}, as `acc[key]
  // || []` found the inherited function, and `append` copied its length-1
  // "elements" first: GroupByOfPrototypeNamedKeys below. Until v0.9.0
  // countBy(x => 'hasOwnProperty', [1, 2]) was {hasOwnProperty: 'function
  // hasOwnProperty() { [native code] }11'} too; since v0.9.1 node agrees
  // with the port there, CountByOfPrototypeNamedKeys above.)
  method {:test} DeviationPrototypeKeysAreOrdinaryInGroupByAndCountBy() {
    expect countBy((x: int) => "__proto__", [1, 2]) == map["__proto__" := 2];
    expect groupBy((x: int) => "__proto__", [1, 2]) == map["__proto__" := [1, 2]];
  }

  // Since v0.21.0 groupBy is reduceBy over own groups, so a key that names
  // an inherited member starts its own group (node: {hasOwnProperty: [1]},
  // {toString: [1, 2]}), as here.
  method {:test} GroupByOfPrototypeNamedKeys() {
    expect groupBy((x: int) => "hasOwnProperty", [1]) == map["hasOwnProperty" := [1]];
    expect groupBy((x: int) => "toString", [1, 2]) == map["toString" := [1, 2]];
  }

  // equals (v0.15.0; eqDeep, v0.9.0 to v0.14.0 and, deprecated, its alias
  // in v0.15.1, gave the same) compares structure: node gives true, true,
  // false, false (a trailing undefined element), false (an undefined
  // property against none) and false (`[]` against `{}`); identical
  // (v0.15.0) of equal ints and strings is true. (In v0.15.1 the restored
  // eqDeep and eq gave the same; v0.16.0 removed them.)
  method {:test} EqualsEdges() {
    expect equals([[1], [2, 3]], [[1], [2, 3]]) == true;
    expect equals(map["a" := 1, "b" := 2], map["b" := 2, "a" := 1]) == true;
    expect equals(map["a" := [1, 2]], map["a" := [2, 1]]) == false;
    expect equals([Num(1), Num(2)], [Num(1), Num(2), Undefined]) == false;
    var none: map<string, Js> := map[];
    expect equals(map["a" := Undefined], none) == false;
    expect equals(Arr([]), Obj(map[])) == false;
    expect identical(1, 1) == true;
    expect identical("a", "a") == true;
  }

  // node: sort((a, b) => a < b ? -1 : a > b ? 1 : 0, 'cab') is ['a', 'b',
  // 'c'] again since v0.14.0, which sorts `_slice(list)` (from v0.9.0 to
  // v0.13.0 it threw "TypeError: clone(...).sort is not a function", as
  // `clone` returned the string, and this was the pin
  // DeviationSortOfAString). A string is a seq of characters and sorts.
  method {:test} SortOfAString() {
    var cmp := (a: char, b: char) => if a < b then -1 else if a > b then 1 else 0;
    expect sort(cmp, "cab") == "abc";
  }

  // node: equals(negate(0), 0) and equals([negate(0)], [0]) are false
  // (v0.15.0; eqDeep([negate(0)], [0]) from v0.9.0 to v0.14.0 and in
  // v0.15.1): numbers are compared with identical, `Object.is`, and
  // negate(0) is -0; and so are eqBy(identity, 0, negate(0)) and eqBy(x =>
  // x * 0, -1, 1) (v0.18.0, `equals(f(x), f(y))`; -1 * 0 is -0). An int has
  // no -0.
  method {:test} DeviationEqualsSignedZero() {
    expect equals(M.negate(0), 0) == true;
    expect equals([M.negate(0)], [0]) == true;
    expect eqBy((x: int) => x, 0, M.negate(0)) == true;
    expect eqBy((x: int) => x * 0, -1, 1) == true;
  }

  // eqBy (v0.18.0) compares f's results with equals (node: true, false,
  // true, true).
  method {:test} EqByEdges() {
    expect eqBy((x: int) => x % 3, 1, 4) == true;
    expect eqBy((x: int) => x % 3, 1, 5) == false;
    expect eqBy((l: seq<int>) => |l|, [1, 2], [3, 4]) == true;
    expect eqBy((x: int) => [x], 1, 1) == true;
  }

  // node: `Array.prototype.sort` puts undefined elements last without
  // calling the comparator, so sortBy(x => x === undefined ? -1 : x, [1,
  // undefined, 0]) is [0, 1, undefined] since v0.9.1 (v0.9.0 sorted key/value
  // pairs and gave [undefined, 0, 1]), and sort with the same key comparison
  // has always given [0, 1, undefined]. Here Undefined is an ordinary value
  // with the key -1.
  method {:test} DeviationSortAndSortByUndefinedLast() {
    var key := (x: Js) => if x.Num? then x.n else -1;
    expect sortBy(key, [Num(1), Undefined, Num(0)]) == [Undefined, Num(0), Num(1)];
    expect sort((a: Js, b: Js) => key(a) - key(b), [Num(1), Undefined, Num(0)]) == [Undefined, Num(0), Num(1)];
  }

  // node: Object.keys(sort(() => 0, [JSON.parse('{"__proto__": 5, "a":
  // 1}')])[0]) is ['__proto__', 'a'] since v0.14.0, which sorts a shallow
  // copy and keeps the element objects; from v0.9.0 to v0.13.0 the deep
  // copy of each element dropped the own `__proto__` property, ['a'] (this
  // was the pin DeviationPrototypeKeysAreOrdinaryInSortedCopies; sortBy did
  // so in v0.9.1 alone, SortByOfAStringAndPrototypeKeys above).
  method {:test} SortKeepsPrototypeNamedKeys() {
    var o := map["__proto__" := 5, "a" := 1];
    expect sort((m1: map<string, int>, m2: map<string, int>) => 0, [o]) == [o];
  }

  // node: groupBy(x => '@@transducer/reduced', [1, 2]) is undefined since
  // v0.14.0 (with `__transducers_reduced__` from v0.12.0 to v0.13.0): the
  // group array is truthy, so `_reduce` takes the accumulator for the
  // transducer protocol's "reduced" marker and returns its
  // `@@transducer/value`; since v0.21.0 countBy is reduceBy, and
  // countBy(x => '@@transducer/reduced', [1, 2]) is undefined likewise (its
  // count 1 is truthy; `{'@@transducer/reduced': 2}` until v0.20.1, as
  // here). Here the key is ordinary.
  method {:test} DeviationReducedMarkerIsAnOrdinaryKey() {
    expect groupBy((x: int) => "@@transducer/reduced", [1, 2]) == map["@@transducer/reduced" := [1, 2]];
    expect countBy((x: int) => "@@transducer/reduced", [1, 2]) == map["@@transducer/reduced" := 2];
  }

  // node: groupBy(x => '__transducers_reduced__', [1, 2]) is
  // {__transducers_reduced__: [1, 2]} since v0.14.0, as here (undefined in
  // v0.12.0 and v0.13.0).
  method {:test} OldReducedMarkerIsAnOrdinaryKey() {
    expect groupBy((x: int) => "__transducers_reduced__", [1, 2]) == map["__transducers_reduced__" := [1, 2]];
  }

  // node: since v0.14.0 `uniq` (`uniqWith(eq)`), and `difference` and
  // `intersection` (through `_indexOf`), compare with `Object.is`:
  // `union([0], [negate(0)])` is [0, -0], `intersection([0], [negate(0)])`
  // [] and `difference([0], [negate(0)])` [0] (with `===` until v0.13.0: [0],
  // [-0] and []); since v0.19.0 `uniq` is `uniqBy(identity)`, and
  // `union([negate(0)], [negate(0)])` is [-0] (from v0.19.0 to v0.21.0 its
  // `Set` kept a repeated -0, [-0, -0]), and `symmetricDifference([0],
  // [negate(0)])` (v0.19.0) is [0, -0]. An int has no -0.
  method {:test} DeviationSetOperationsSignedZero() {
    expect union([0], [M.negate(0)]) == [0];
    expect intersection([0], [M.negate(0)]) == [0];
    expect difference([0], [M.negate(0)]) == [];
    expect union([M.negate(0)], [M.negate(0)]) == [0];
    expect symmetricDifference([0], [M.negate(0)]) == [];
  }

  // symmetricDifference and symmetricDifferenceWith (v0.19.0): each list's
  // elements missing from the other, each once (node: [1], [1, 2, 3], []).
  method {:test} SymmetricDifferenceEdges() {
    var empty: seq<int> := [];
    expect symmetricDifference(empty, [1, 1]) == [1];
    expect symmetricDifference([1, 1, 2], [3, 3]) == [1, 2, 3];
    expect symmetricDifferenceWith((a: int, b: int) => a % 3 == b % 3, [1, 4, 2], [7, 5]) == [];
  }

  // clamp (v0.20.0): the bounds themselves are kept, and equal bounds pin
  // the value (node: 2, 1, 3, -1).
  method {:test} ClampEdges() {
    expect clamp(2, 2, 5) == 2;
    expect clamp(1, 3, 1) == 1;
    expect clamp(1, 3, 3) == 3;
    expect clamp(-3, -1, 0) == -1;
  }

  // ascend, descend and sortWith (v0.23.0): comparators by key, and a stable
  // sort by the first comparator that tells two elements apart (node: [3, 6,
  // 4, 1, 5], [5, 4, 1, 3, 6], [3, 1, 2] (no comparators: every pair ties),
  // [2, 4, 3, 1], [4, 2, 3, 1]).
  method {:test} AscendDescendSortWithEdges() {
    var none: seq<(int, int) -> int> := [];
    expect sort((a: int, b: int) => ascend((x: int) => x % 3, a, b), [5, 3, 4, 1, 6]) == [3, 6, 4, 1, 5];
    expect sort((a: int, b: int) => descend((x: int) => x % 3, a, b), [5, 3, 4, 1, 6]) == [5, 4, 1, 3, 6];
    expect sortWith(none, [3, 1, 2]) == [3, 1, 2];
    expect sortWith([(a: int, b: int) => ascend((x: int) => x % 2, a, b)], [3, 2, 1, 4]) == [2, 4, 3, 1];
    expect sortWith([(a: int, b: int) => ascend((x: int) => x % 2, a, b), (a: int, b: int) => descend((x: int) => x, a, b)],
                    [3, 2, 1, 4]) == [4, 2, 3, 1];
  }

  // innerJoin (v0.24.0): the elements of the first list related to some
  // element of the second, in order, duplicates kept (node: [2, 2], [],
  // ['ab', 'de']).
  method {:test} InnerJoinEdges() {
    var none: seq<int> := [];
    expect innerJoin((x: int, y: int) => x == y + 1, [1, 2, 3, 2], [1, 1]) == [2, 2];
    expect innerJoin((x: int, y: int) => true, [1, 2], none) == [];
    expect innerJoin((x: string, y: int) => |x| == y, ["ab", "c", "de"], [2]) == ["ab", "de"];
  }
}
