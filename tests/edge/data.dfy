// Edge cases for Sort and Data, checked against dist/ramda.js v0.9.1 under node;
// the last methods pin documented deviations (README "Deviations").

module RamdafTests.Edge.Data {
  import opened Ramdaf.Prelude
  import opened Ramdaf.Sort
  import opened Ramdaf.Data
  import M = Ramdaf.Math
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
  // (uniq); intersection takes its elements, and their order, from the
  // second list.
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
  }

  // Since v0.7.0 difference and differenceWith are loops (same results).
  method {:test} DifferenceEdges() {
    expect difference([1, 2, 1, 3], [2]) == [1, 3];
    // `difference('abcab', 'b')`: strings are lists of characters
    expect difference("abcab", "b") == "ac";
    expect differenceWith((a: int, b: int) => a < b, [3, 1, 2, 5, 4], [2]) == [3, 5];
    expect differenceWith((a: int, b: int) => a < b, [5, 4, 3, 2, 1], [0]) == [5];
    expect differenceWith((a: int, b: int) => a % 3 == b % 3, [1, 2, 3, 4, 5, 6], [3]) == [1, 2];
  }

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
    expect intersectionWith(par, [1, 2, 3], [4, 5]) == [1, 2];
    expect intersectionWith((a: int, b: int) => a == b, [2, 1, 2], [2]) == [2];
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

  // JS `===` compares the objects by reference, so none of these are shared
  // (node: 8, 0, 4); Dafny `==` compares their contents.
  method {:test} DeviationStructuralEquality() {
    var ro := [map["a" := 1], map["a" := 2], map["a" := 3], map["a" := 4]];
    var so := [map["a" := 3], map["a" := 4], map["a" := 5], map["a" := 6]];
    expect |union(ro, so)| == 6;
    expect |intersection(ro, so)| == 2;
    expect |difference(ro, so)| == 2;
  }

  // node: groupBy(x => 'hasOwnProperty', [1]) is {hasOwnProperty: [undefined, 1]}
  // (`acc[key] || []` finds the inherited function, and `append` copies its
  // length-1 "elements" first), and countBy(x => '__proto__', [1, 2]) is {}
  // (the count is assigned to the prototype, which ignores it). A map's keys
  // are all ordinary. (So at v0.2.4 as well: an omission of the earlier
  // ports. Until v0.9.0 countBy(x => 'hasOwnProperty', [1, 2]) was
  // {hasOwnProperty: 'function hasOwnProperty() { [native code] }11'} too;
  // since v0.9.1 node agrees with the port there, CountByOfPrototypeNamedKeys
  // above.)
  method {:test} DeviationPrototypeKeysAreOrdinaryInGroupByAndCountBy() {
    expect groupBy((x: int) => "hasOwnProperty", [1]) == map["hasOwnProperty" := [1]];
    expect countBy((x: int) => "__proto__", [1, 2]) == map["__proto__" := 2];
  }

  // eqDeep (v0.9.0) compares structure: node gives true, true, false, false
  // (a trailing undefined element), false (an undefined property against
  // none) and false (`[]` against `{}`).
  method {:test} EqDeepEdges() {
    expect eqDeep([[1], [2, 3]], [[1], [2, 3]]) == true;
    expect eqDeep(map["a" := 1, "b" := 2], map["b" := 2, "a" := 1]) == true;
    expect eqDeep(map["a" := [1, 2]], map["a" := [2, 1]]) == false;
    expect eqDeep([Num(1), Num(2)], [Num(1), Num(2), Undefined]) == false;
    var none: map<string, Js> := map[];
    expect eqDeep(map["a" := Undefined], none) == false;
    expect eqDeep(Arr([]), Obj(map[])) == false;
  }

  // node: sort((a, b) => a < b ? -1 : a > b ? 1 : 0, 'cab') throws
  // "TypeError: clone(...).sort is not a function" since v0.9.0 (`clone`
  // returns the string, which has no `sort` method; v0.8.0 gave ['a', 'b',
  // 'c']). Here a string is a seq of characters and sorts.
  method {:test} DeviationSortOfAString() {
    var cmp := (a: char, b: char) => if a < b then -1 else if a > b then 1 else 0;
    expect sort(cmp, "cab") == "abc";
  }

  // node: eqDeep([negate(0)], [0]) is false since v0.9.0 (`_eqDeep` compares
  // the elements with `eq`, `Object.is`, and negate(0) is -0); an int has no
  // -0.
  method {:test} DeviationEqDeepSignedZero() {
    expect eqDeep([M.negate(0)], [0]) == true;
  }

  // node: sortBy(c => c.charCodeAt(0), 'cba') throws "TypeError:
  // clone(...).sort is not a function" in v0.9.1 (it sorts `clone(list)`,
  // and `clone` returns the string; v0.9.0 gave ['a', 'b', 'c']). Here a
  // string is a seq of characters and sorts.
  method {:test} DeviationSortByOfAString() {
    expect sortBy((c: char) => c as int, "cba") == "abc";
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

  // node: Object.keys(sortBy(x => 0, [JSON.parse('{"__proto__": 5, "a":
  // 1}')])[0]) is ['a'] in v0.9.1, and so is sort(() => 0, …) since v0.9.0:
  // the deep copy of each element drops an own `__proto__` property. A
  // map's keys are all ordinary.
  method {:test} DeviationPrototypeKeysAreOrdinaryInSortedCopies() {
    var o := map["__proto__" := 5, "a" := 1];
    expect sortBy((m: map<string, int>) => 0, [o]) == [o];
    expect sort((m1: map<string, int>, m2: map<string, int>) => 0, [o]) == [o];
  }
}
