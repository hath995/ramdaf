// Edge cases Ramda v0.12.0's own suite does not cover, each checked against
// dist/ramda.js v0.12.0 under node (the expected values are node's output). The
// last methods pin the documented deviations (README "Deviations").

module RamdafTests.Edge.List {
  import opened Ramdaf.Prelude
  import opened Ramdaf.Core
  import opened Ramdaf.List
  import opened Support

  method {:test} CoreEdges() {
    var empty: seq<int> := [];
    expect tail([1]) == [];
    expect tail(empty) == [];
    expect tail([1, 2]) == [2];
    expect head([5]) == 5;
    expect head([1, 2, 3]) == 1;
    expect last([1, 2, 3]) == 3;
    expect last([5]) == 5;
    expect isEmpty([0]) == false;
    expect concat(empty, [1]) == [1];
    expect concat([1], empty) == [1];
    expect concat([1, 2], [3]) == [1, 2, 3];
    expect append(1, empty) == [1];
    expect prepend(1, empty) == [1];
    expect length(empty) == 0;
    expect clone([1, 2]) == [1, 2];
    expect identity(3) == 3;
    expect repeat(7, 0) == [];
    expect repeat("a", 2) == ["a", "a"];
    expect times((i: nat) => i * i, 4) == [0, 1, 4, 9];
    expect times((i: nat) => i, 0) == [];
  }

  // reduceRight (foldr until v0.9.1) runs from the right with the
  // accumulator first (since v0.1.1).
  method {:test} ReduceRightRunsFromTheRightAccumulatorFirst() {
    var empty: seq<int> := [];
    expect reduceRight((acc: seq<int>, x: int) => [x] + acc, empty, [1, 2]) == [1, 2];
    expect reduceRight((acc: string, a: string) => acc + a, "", ["x", "y", "z"]) == "zyx";
    expect reduceRight((acc: int, a: int) => acc - a, 0, [1, 2, 3, 4]) == -10;
  }

  // The indexed folds (the `.idx` properties until v0.8.0, foldlIndexed and
  // foldrIndexed in v0.9.x) pass (acc, element, index, list).
  method {:test} IndexedFoldsPassTheIndexAndList() {
    var empty: seq<string> := [];
    var f := (acc: string, x: string, i: nat, l: seq<string>) => acc + x + NumStr(i) + NumStr(|l|);
    expect reduceIndexed(f, "", ["a", "b"]) == "a02b12";
    expect reduceRightIndexed(f, "", ["a", "b"]) == "b12a02";
    expect reduceIndexed(f, "5", empty) == "5";
    expect reduceIndexed((acc: int, x: int, i: nat, l: seq<int>) => acc + x * i, 0, [1, 2, 3]) == 8;
    var none: seq<nat> := [];
    expect reduceRightIndexed((acc: seq<nat>, x: int, i: nat, l: seq<int>) => acc + [i], none, [9, 9, 9]) == [2, 1, 0];
  }

  method {:test} IndexedMapFilterRejectEdges() {
    var empty: seq<int> := [];
    expect mapIndexed((x: int, i: nat, l: seq<int>) => x + i, empty) == [];
    expect mapIndexed((x: int, i: nat, l: seq<int>) => |l| - i, [5, 5, 5]) == [3, 2, 1];
    expect filterIndexed((x: int, i: nat, l: seq<int>) => i == 1, [7, 7, 7]) == [7];
    expect filterIndexed((x: int, i: nat, l: seq<int>) => false, [1, 2]) == [];
    expect filterIndexed((x: int, i: nat, l: seq<int>) => i < |l|, [1, 2]) == [1, 2];
    expect rejectIndexed((x: int, i: nat, l: seq<int>) => i == 1, [7, 7, 7]) == [7, 7];
    expect rejectIndexed((x: int, i: nat, l: seq<int>) => true, empty) == [];
  }

  // Since v0.4.2 findLast/findLastIndex test index 0 and end on the empty
  // list (the `while (idx--)` loop; until v0.4.1 `while (--idx)` skipped
  // index 0); since v0.2.0 findIndex and findLastIndex return -1 on a miss.
  method {:test} FindFamilyEdges() {
    var empty: seq<int> := [];
    expect findIndex((x: int) => true, empty) == -1;
    expect findIndex((x: int) => x > 1, [1, 2, 3]) == 1;
    expect findIndex((x: int) => x > 9, [1, 2, 3]) == -1;
    expect findLastIndex((x: int) => x == 1, [1, 2, 3]) == 0;
    expect findLastIndex((x: int) => x > 1, [1, 2, 3]) == 2;
    expect findLastIndex((x: int) => true, [5]) == 0;
    expect findLastIndex((x: int) => x == 9, [9, 1, 9]) == 2;
    expect findLastIndex((x: int) => x == 9, [9, 1, 2]) == 0;
    expect findLastIndex((x: int) => false, empty) == -1;
    expect findLastIndex((x: int) => true, empty) == -1;
    expect findLast((x: int) => x == 1, [1, 2, 3]) == Some(1);
    expect findLast((x: int) => x < 3, [1, 2, 3]) == Some(2);
    expect findLast((x: int) => true, [5]) == Some(5);
    expect findLast((x: int) => x % 2 == 0, [2, 4, 1]) == Some(4);
    expect findLast((x: int) => false, empty) == None;
    expect findLast((x: int) => x > 9, [1, 2]) == None;
  }

  // Array.prototype.slice: negative indices count from the end, both are
  // clamped, and an empty range gives [].
  method {:test} SliceClampsLikeJs() {
    var l := [1, 2, 3, 4, 5];
    expect slice(1, 3, l) == [2, 3];
    expect slice(-2, 100, l) == [4, 5];
    expect slice(3, 1, l) == [];
    expect slice(-100, 2, l) == [1, 2];
    expect slice(2, -1, l) == [3, 4];
    expect slice(0, 0, l) == [];
    expect slice(5, 5, l) == [];
    expect slice(-2, -1, l) == [4];
    expect slice(10, 20, l) == [];
  }

  // Since v0.3.0 partition splits a list into (passing, failing), each in
  // list order. (Its v0.1.4 to v0.2.4 grouping cases are groupBy's now, in
  // tests/edge/data.dfy.)
  method {:test} PartitionEdges() {
    var none: seq<int> := [];
    expect partition((x: int) => x > 2, [1, 3, 2, 4]) == ([3, 4], [1, 2]);
    expect partition((x: int) => true, [1, 2]) == ([1, 2], []);
    expect partition((x: int) => false, [1, 2]) == ([], [1, 2]);
    expect partition((x: int) => x > 0, none) == ([], []);
    // `partition(x => x % 2)([1, 2, 3])`
    var odds := (l: seq<int>) => partition((x: int) => x % 2 != 0, l);
    expect odds([1, 2, 3]) == ([1, 3], [2]);
    // `partition(s => s, ['a', '', 'b'])`: the empty string is falsy
    expect partition((s: string) => s != "", ["a", "", "b"]) == (["a", "b"], [""]);
  }

  // ap (v0.3.0) applies every function to every value, the functions
  // outermost.
  method {:test} ApEdges() {
    var nofns: seq<int -> int> := [];
    var none: seq<int> := [];
    expect ap(nofns, [1, 2]) == [];
    expect ap([(x: int) => x], none) == [];
    expect ap([(x: int) => "f" + NumStr(x), (x: int) => "g" + NumStr(x)], [1, 2]) == ["f1", "f2", "g1", "g2"];
  }

  // chain (v0.3.0) flattens the mapped results one level only.
  method {:test} ChainEdges() {
    var none: seq<int> := [];
    expect chain((x: int) => none, [1, 2]) == [];
    expect chain((x: int) => [x, x], [1, 2]) == [1, 1, 2, 2];
    expect chain((x: int) => [[x]], [1, 2]) == [[1], [2]];
    expect chain((x: int) => [Num(x), Arr([Num(x)])], [1, 2]) == [Num(1), Arr([Num(1)]), Num(2), Arr([Num(2)])];
  }

  // unnest (v0.3.0) removes one level of nesting.
  method {:test} UnnestEdges() {
    var none: seq<Tree<int>> := [];
    expect unnest(none) == [];
    expect unnest([Node(none)]) == [];
    expect unnest([Node([Node([Leaf(1)])])]) == [Node([Leaf(1)])];
    expect unnest([Leaf(1)]) == [Leaf(1)];
    expect unnest([Leaf("ab")]) == [Leaf("ab")];
    expect unnest([Leaf(1), Node([Leaf(2), Node([Leaf(3)])])]) == [Leaf(1), Leaf(2), Node([Leaf(3)])];
    expect flatten([Leaf(1), Node([Leaf(2), Node([Leaf(3)])])]) == [1, 2, 3];
  }

  // zipObj and fromPairs (v0.3.0): a later duplicate key wins.
  method {:test} ZipObjFromPairsEdges() {
    var nokeys: seq<string> := [];
    expect zipObj(["a", "a"], [1, 2]) == map["a" := 2];
    expect zipObj(["b", "a"], [1, 2]) == map["b" := 1, "a" := 2];
    expect zipObj(nokeys, [1, 2]) == map[];
    // `zipObj(['a'])(['z'])`
    var zipA := (vs: seq<string>) requires |vs| >= 1 => zipObj(["a"], vs);
    expect zipA(["z"]) == map["a" := "z"];
    var nopairs: seq<(string, int)> := [];
    expect fromPairs([("a", 1), ("a", 2)]) == map["a" := 2];
    expect fromPairs(nopairs) == map[];
    // `fromPairs([[1, 'x']])`: JS converts the key 1 to the string "1".
    expect fromPairs([("1", "x")]) == map["1" := "x"];
  }

  // of, empty and length (v0.3.0).
  method {:test} OfEmptyLengthEdges() {
    var none: seq<int> := [];
    expect of(1) == [1];
    expect of(none) == [none];
    expect empty([1, 2]) == [];
    expect empty(none) == [];
    expect length(none) == 0;
    // a string is a list of characters
    expect length("abc") == 3;
  }

  method {:test} MapObjEdges() {
    var none: map<string, int> := map[];
    expect mapObj((v: int) => v + 1, none) == map[];
    expect mapObj((v: int) => v * 2, map["a" := 1]) == map["a" := 2];
    expect mapObjIndexed((v: int, k: string, o: map<string, int>) => k + NumStr(v), map["a" := 1, "b" := 2]) ==
      map["a" := "a1", "b" := "b2"];
    expect mapObjIndexed((v: int, k: string, o: map<string, int>) => |o| + v, map["a" := 1, "b" := 2]) ==
      map["a" := 3, "b" := 4];
    expect mapObjIndexed((v: int, k: string, o: map<string, int>) => v, none) == map[];
  }

  method {:test} ContainsWithEdges() {
    var empty: seq<int> := [];
    expect containsWith((a: int, b: int) => a == b + 1, 3, [1, 2]) == true;
    expect containsWith((a: int, b: int) => a == b + 1, 5, [1, 2]) == false;
    expect containsWith((a: int, b: int) => true, 1, empty) == false;
    expect containsWith((a: int, b: int) => a % 10 == b % 10, 12, [2, 3]) == true;
  }

  // isSet(list) is `uniq(list).length === list.length`.
  method {:test} IsSetEdges() {
    var empty: seq<int> := [];
    expect isSet(empty) == true;
    expect isSet([1, 2, 1]) == false;
    expect isSet(["a", "b"]) == true;
    expect isSet([3, 3]) == false;
    var lists := [[1, 2, 1, 3, 2], [4, 5], [6, 6, 6], empty];
    for i := 0 to |lists| {
      expect isSet(lists[i]) == (|uniq(lists[i])| == |lists[i]|);
    }
  }

  // reduce folds from the left (from v0.4.0 to v0.8.0 `reduce` held the
  // definition and foldl was its alias; v0.9.0 removed `reduce`, and v0.10.0
  // renamed `foldl` back to `reduce`).
  method {:test} ReduceIsLeftAssociative() {
    expect reduce((acc: int, x: int) => acc - x, 0, [1, 2, 3]) == -6;
    expect reduce((acc: string, x: string) => acc + x, "", ["a", "b", "c"]) == "abc";
    expect reduce((acc: int, x: int) => acc - x, 10, [1, 2, 3]) == 4;
    // `reduce(cat, '')('abc')`: a string is a list of characters
    expect reduce((acc: string, c: char) => acc + [c], "", "abc") == "abc";
  }

  // Two strings concatenate by the first one's own `concat` method. Since
  // v0.8.0 that includes an empty first string (node: 'bar' and ''; from
  // v0.6.0 to v0.7.2 both threw "TypeError: can't concat string", a
  // deviation pinned until then).
  method {:test} ConcatOfStrings() {
    expect concat("foo", "") == "foo";
    expect concat("ab", "cd") == "abcd";
    expect concat("", "bar") == "bar";
    expect concat("", "") == "";
    var empty: seq<int> := [];
    expect concat(empty, [1]) == [1];
  }

  // nth (v0.8.0): a negative n counts from the end, and out of range is
  // undefined (node: 'foo', 'quux', undefined, 'quux', 'foo', undefined,
  // undefined; undefined for []; 'b', 'c', undefined on 'abc').
  method {:test} NthEdges() {
    var l := ["foo", "bar", "baz", "quux"];
    var empty: seq<int> := [];
    expect nth(0, l) == Some("foo");
    expect nth(3, l) == Some("quux");
    expect nth(4, l) == None;
    expect nth(-1, l) == Some("quux");
    expect nth(-4, l) == Some("foo");
    expect nth(-5, l) == None;
    expect nth(-99, l) == None;
    expect nth(0, empty) == None;
    expect nth(-1, empty) == None;
    expect nth(1, "abc") == Some('b');
    expect nth(-1, "abc") == Some('c');
    expect nth(5, "abc") == None;
  }

  // clone (cloneDeep in v0.8.0) keeps undefined properties (v0.1.1's JSON
  // cloneDeep dropped them) and functions, and since v0.9.0 copies any value
  // (node: `Object.keys` ['a', 'u'], `clone([{a: x => x * 2}])[0].a(10)` is
  // 20, `clone(5)` is 5, `clone('abc')` is 'abc', `clone({a: 1, b: [1, 2]})`
  // is equal to its input; until v0.8.0 the last three threw or, for the
  // string, gave ['a', 'b', 'c']).
  method {:test} CloneEdges() {
    var o := map["a" := Arr([Num(1), Obj(map["b" := Num(2)])]), "u" := Undefined];
    expect clone(o) == o;
    var fns: seq<map<string, int -> int>> := clone([map["a" := (x: int) => x * 2]]);
    var a := fns[0]["a"];
    expect a(10) == 20;
    expect clone(-4) == -4;
    expect clone(Null) == Null;
    expect clone(5) == 5;
    expect clone("abc") == "abc";
    expect clone(map["a" := Num(1), "b" := Arr([Num(1), Num(2)])]) == map["a" := Num(1), "b" := Arr([Num(1), Num(2)])];
    var none: map<string, int> := map[];
    expect clone(none) == none;
  }

  // commute and commuteMap (v0.8.0): every choice of one element per list,
  // the first list's element varying fastest; of builds the starting functor
  // (node: [[]], [], [], [[1], [2], [3]], [[1], [1]], [], the eight triples,
  // ['ac', 'bc', 'ad', 'bd'] as character pairs, [[1, 3], [1, 3], [2, 3],
  // [2, 3]], [[2, 1]], [[]] and [[2, 4], [1, 4], [2, 3], [1, 3]]).
  method {:test} CommuteEdges() {
    var none: seq<seq<int>> := [];
    var empty: seq<int> := [];
    expect commute(of, none) == [[]];
    expect commute(of, [empty]) == [];
    expect commute(of, [[1], empty]) == [];
    expect commute(of, [[1, 2, 3]]) == [[1], [2], [3]];
    expect commute((x: seq<int>) => [x, x], [[1]]) == [[1], [1]];
    expect commute((x: seq<int>) => [], [[1]]) == [];
    expect commute(of, [[1, 2], [3, 4], [5, 6]]) ==
      [[1, 3, 5], [2, 3, 5], [1, 4, 5], [2, 4, 5], [1, 3, 6], [2, 3, 6], [1, 4, 6], [2, 4, 6]];
    expect commute(of, ["ab", "cd"]) == ["ac", "bc", "ad", "bd"];
    expect commute((x: seq<int>) => [x, x], [[1, 2], [3]]) == [[1, 3], [1, 3], [2, 3], [2, 3]];
    expect commuteMap((xs: seq<int>) => [|xs|], of, [[1, 2], [3]]) == [[2, 1]];
    expect commuteMap((xs: seq<int>) => mapSeq((x: int) => x + 10, xs), of, none) == [[]];
    expect commuteMap(reverse, of, [[1, 2], [3, 4]]) == [[2, 4], [1, 4], [2, 3], [1, 3]];
  }

  // lens (v0.8.0), Ramda's headLens example (node: 10, ['mu', 20, 30, 40],
  // [11, 20, 30, 40]).
  method {:test} LensEdges() {
    var headLens := lens((a: seq<Js>) => if |a| > 0 then a[0] else Undefined,
                         (v: Js, a: seq<Js>) => [v] + (if |a| > 0 then a[1..] else []));
    var l := [Num(10), Num(20), Num(30), Num(40)];
    expect headLens.get(l) == Num(10);
    expect headLens.set_(Str("mu"), l) == [Str("mu"), Num(20), Num(30), Num(40)];
    expect headLens.map_((x: Js) => if x.Num? then Num(x.n + 1) else x, l) == [Num(11), Num(20), Num(30), Num(40)];
    // On ints the getter is partial: node's `l([])` is undefined and
    // `l.map(x => x + 1, [])` is `[NaN]`, so get and map_ require a
    // non-empty list; the setter is total (`l.set(9, [])` is `[9]`). Node:
    // 10, [9], [11, 20].
    var intHead := lens((a: seq<int>) requires |a| > 0 => a[0],
                        (v: int, a: seq<int>) => [v] + (if |a| > 0 then a[1..] else []));
    expect intHead.get([10, 20]) == 10;
    expect intHead.set_(9, []) == [9];
    expect intHead.map_((x: int) => x + 1, [10, 20]) == [11, 20];
  }

  // xprod (v0.8.0 removed xprodWith; xprod is unchanged): node gives
  // [[1, 'a'], [1, 'b'], [2, 'a'], [2, 'b']] and, on two strings, the
  // character pairs.
  method {:test} XprodEdges() {
    expect xprod([1, 2], ["a", "b"]) == [(1, "a"), (1, "b"), (2, "a"), (2, "b")];
    expect xprod("ab", "cd") == [('a', 'c'), ('a', 'd'), ('b', 'c'), ('b', 'd')];
  }

  // Since v0.7.2 an object with a positive `length` is array-like only when
  // it owns the indices 0 and `length - 1`, so these leaves stay whole in
  // node too (node: [{length: 2}] and [{0: 7, length: 2}]; v0.3.0 to v0.7.1
  // gave [undefined, undefined] and [7, undefined]).
  method {:test} SparseArrayLikeLeavesAreKept() {
    var len2 := map["length" := 2];
    expect flatten([Leaf(len2)]) == [len2];
    var zero7 := map["0" := 7, "length" := 2];
    expect unnest([Leaf(zero7)]) == [Leaf(zero7)];
  }

  // Since v0.4.0 a function element is a leaf again (v0.3.0 expanded it into
  // `f.length` undefined elements): node gives 2, 4 and 6 for r.length,
  // r[0](3) and r[1](3), for both flatten and unnest.
  method {:test} FunctionElementsAreLeaves() {
    var r := flatten([Leaf((x: int) => x + 1), Node([Leaf((x: int) => x * 2)])]);
    expect |r| == 2 && r[0](3) == 4 && r[1](3) == 6;
    var u := unnest([Leaf((x: int) => x + 1), Node([Leaf((x: int) => x * 2)])]);
    expect |u| == 2 && u[0].Leaf? && u[0].value(3) == 4 && u[1].Leaf? && u[1].value(3) == 6;
  }

  // Since v0.2.4 uniq keeps the first occurrence of each element (it kept
  // the last).
  method {:test} UniqKeepsFirstOccurrences() {
    expect uniq([1, 2, 1, 3, 2]) == [1, 2, 3];
    expect uniq([3, 3, 3]) == [3];
  }

  // Since v0.2.4 uniqWith keeps the first representative and drops item when
  // pred(item, r) holds for a kept r.
  method {:test} UniqWithKeepsFirstRepresentatives() {
    var empty: seq<int> := [];
    expect uniqWith((a: int, b: int) => a % 3 == b % 3, [1, 2, 3, 4]) == [1, 2, 3];
    expect uniqWith((a: int, b: int) => a < b, [1, 2, 3]) == [1, 2, 3];
    expect uniqWith((a: int, b: int) => a < b, [3, 2, 1]) == [3];
    expect uniqWith((a: int, b: int) => a == b, [1, 2, 1]) == [1, 2];
    expect uniqWith((a: int, b: int) => a == b, empty) == [];
  }

  // Since v0.1.5 take clamps n to the list's length, and since v0.8.0 a
  // negative n gives [] (it threw RangeError); since v0.5.0 drop (skip until
  // v0.8.0) gives [] for n >= |list| (from v0.2.0 to v0.4.3 it threw
  // RangeError for n > |list|).
  method {:test} TakeDropEdges() {
    var empty: seq<int> := [];
    expect take(-1, [1, 2, 3]) == [];
    expect take(-5, empty) == [];
    expect take(-1, "abc") == "";
    expect take(0, [1]) == [];
    expect take(0, [1, 2]) == [];
    expect take(2, [1, 2]) == [1, 2];
    expect take(5, [1, 2]) == [1, 2];
    expect take(3, empty) == [];
    expect take(2, [1, 2, 3]) == [1, 2];
    expect drop(0, [1, 2]) == [1, 2];
    expect drop(2, [1, 2]) == [];
    expect drop(1, [1, 2]) == [2];
    expect drop(5, [1, 2]) == [];
    expect drop(3, empty) == [];
    expect drop(3, [1, 2, 3]) == [];
    // `drop(5, "abc")`, `drop(1, "abc")` (['b', 'c']) and `drop(5)([1, 2, 3])`
    expect drop(5, "abc") == "";
    expect drop(1, "abc") == "bc";
    var drop5 := (l: seq<int>) => drop(5, l);
    expect drop5([1, 2, 3]) == [];
  }

  // Since v0.2.0 zip and zipWith stop at the shorter list.
  method {:test} ZipEdges() {
    var empty: seq<int> := [];
    expect zip([1], [3, 4]) == [(1, 3)];
    expect zip(empty, [1]) == [];
    expect zipWith((a: int, b: int) => a + b, [1, 2], [10, 20, 30]) == [11, 22];
    expect zip([1, 2, 3], [4]) == [(1, 4)];
    expect zipWith((a: int, b: int) => a + b, [1, 2], [10]) == [11];
  }

  // remove, insert and insert.all are built on `_slice`; since v0.2.4 a cut
  // at 0 is empty (until v0.2.3 it copied the whole list), and since v0.8.0
  // a negative start cuts at 0 (node: [1, 2, 3, 4, 5], [2, 3, 4, 5],
  // [2, 3, 4, 5], [], [], [3, 4, 5] and []; until v0.7.2 each threw
  // RangeError).
  method {:test} RemoveUsesRamdasSlice() {
    var l := [1, 2, 3, 4, 5];
    var empty: seq<int> := [];
    expect remove(1, 2, l) == [1, 4, 5];
    expect remove(0, 2, l) == [3, 4, 5];
    expect remove(0, 0, [1, 2, 3]) == [1, 2, 3];
    expect remove(0, 5, l) == [];
    expect remove(3, 10, [1, 2, 3]) == [1, 2, 3];
    expect remove(5, 1, [1, 2, 3]) == [1, 2, 3];
    expect remove(1, -1, l) == [1, 1, 2, 3, 4, 5];
    expect remove(3, -1, l) == [1, 2, 3, 3, 4, 5];
    expect remove(2, -2, l) == [1, 2, 1, 2, 3, 4, 5];
    expect remove(1, 0, l) == l;
    expect remove(0, 1, empty) == [];
    expect remove(2, 0, empty) == [];
    expect remove(4, -4, [16, 8, 12]) == [16, 8, 12, 16, 8, 12];
    expect remove(-1, 1, l) == [1, 2, 3, 4, 5];
    expect remove(-1, 2, l) == [2, 3, 4, 5];
    expect remove(-2, 3, l) == [2, 3, 4, 5];
    expect remove(-3, 8, l) == [];
    expect remove(-1, 6, l) == [];
    expect remove(-10, 12, l) == [3, 4, 5];
    expect remove(-1, 1, empty) == [];
  }

  method {:test} InsertUsesRamdasSlice() {
    var empty: seq<int> := [];
    expect insert(1, 9, [1, 2, 3]) == [1, 9, 2, 3];
    expect insert(0, 9, [1, 2, 3]) == [9, 1, 2, 3];
    expect insert(2, 9, [1, 2, 3]) == [1, 2, 9, 3];
    expect insert(3, 9, [1, 2, 3]) == [1, 2, 3, 9];
    expect insert(10, 9, [1, 2, 3]) == [1, 2, 3, 9];
    expect insert(-1, 9, [1, 2, 3]) == [1, 2, 3, 9];
    expect insert(0, 9, empty) == [9];
    expect insert(5, 9, empty) == [9];
    expect insertAll(1, [7, 8], [1, 2, 3]) == [1, 7, 8, 2, 3];
    expect insertAll(0, [7, 8], [1, 2, 3]) == [7, 8, 1, 2, 3];
    expect insertAll(-1, [7, 8], [1, 2, 3]) == [1, 2, 3, 7, 8];
    expect insertAll(5, [7, 8], [1, 2, 3]) == [1, 2, 3, 7, 8];
    expect insertAll(0, empty, [1, 2, 3]) == [1, 2, 3];
    expect insertAll(2, empty, [1, 2, 3]) == [1, 2, 3];
    expect insertAll(0, [7], empty) == [7];
  }

  method {:test} JoinEdges() {
    var empty: seq<string> := [];
    expect join(",", empty) == "";
    expect join("-", ["a"]) == "a";
    expect join("", ["a", "b"]) == "ab";
  }

  method {:test} RangeEdges() {
    expect range(-2, 2) == [-2, -1, 0, 1];
    expect range(3, 3) == [];
  }

  method {:test} FindTakeWhileDropWhileEdges() {
    var empty: seq<int> := [];
    expect find((x: int) => x > 9, [1, 2]) == None;
    expect find((x: int) => x > 1, [1, 2, 3]) == Some(2);
    expect takeWhile((x: int) => x < 3, [1, 2, 3, 1]) == [1, 2];
    expect takeWhile((x: int) => x > 0, empty) == [];
    expect takeWhile((x: int) => x < 2, [1, 2, 3]) == [1];
    expect takeWhile((x: int) => x < 9, [1, 2]) == [1, 2];
    // v0.2.4 (it was the whole list from v0.2.0 to v0.2.3)
    expect takeWhile((x: int) => x > 5, [1, 2, 3]) == [];
    // dropWhile (v0.9.0; skipUntil, with the predicate negated, until
    // v0.8.0) stops at the first element that fails the predicate
    expect dropWhile((x: int) => x <= 2, [1, 2, 3, 1]) == [3, 1];
    expect dropWhile((x: int) => x > 2, [1, 2, 3, 1]) == [1, 2, 3, 1];
    expect dropWhile((x: int) => x != 5, [1, 3, 5, 7, 9]) == [5, 7, 9];
    expect dropWhile((x: int) => true, [1, 2]) == [];
    expect dropWhile((x: int) => x <= 0, empty) == [];
    expect dropWhile((c: char) => c != 'b', "abc") == "bc";
  }

  // scan (scanl from v0.7.0 to v0.9.1): the accumulator, then each
  // successive fn(acc, x).
  method {:test} ScanEdges() {
    var none: seq<int> := [];
    expect scan((a: int, b: int) => a - b, 10, [1, 2, 3]) == [10, 9, 7, 4];
    expect scan((a: seq<int>, x: int) => [x] + a, none, [1, 2, 3]) == [[], [1], [2, 1], [3, 2, 1]];
    // `scan(add, '', 'abc')`: a string is a list of characters
    expect scan((a: string, c: char) => a + [c], "", "abc") == ["", "a", "ab", "abc"];
    expect scan((a: int, b: int) => a + b, 0, none) == [0];
  }

  // mapAccum and mapAccumRight (mapAccumL and mapAccumR in v0.9.x): the
  // JSDoc examples (node: ['01234', ['01', '012', '0123', '01234']] and
  // ['04321', ['04321', '0432', '043', '04']]) and a string, a list of
  // characters (node: ['abc', ['', 'a', 'ab']] and ['cba', ['cb', 'c',
  // '']]).
  method {:test} MapAccumEdges() {
    var f := (a: string, b: string) => (a + b, a + b);
    expect mapAccum(f, "0", ["1", "2", "3", "4"]) == ("01234", ["01", "012", "0123", "01234"]);
    expect mapAccumRight(f, "0", ["1", "2", "3", "4"]) == ("04321", ["04321", "0432", "043", "04"]);
    var g := (a: string, c: char) => (a + [c], a);
    expect mapAccum(g, "", "abc") == ("abc", ["", "a", "ab"]);
    expect mapAccumRight(g, "", "abc") == ("cba", ["cb", "c", ""]);
  }

  // mergeAll (v0.10.0) merges left to right, later keys winning (node: {},
  // {a: 1}, {a: 3, b: 2, c: 3}, {}).
  method {:test} MergeAllEdges() {
    var none: seq<map<string, int>> := [];
    var empty: map<string, int> := map[];
    expect mergeAll(none) == map[];
    expect mergeAll([map["a" := 1]]) == map["a" := 1];
    expect mergeAll([map["a" := 1, "b" := 1], map["b" := 2], map["a" := 3, "c" := 3]]) == map["a" := 3, "b" := 2, "c" := 3];
    expect mergeAll([empty, empty]) == map[];
  }

  // createMapEntry (v0.7.0)
  method {:test} CreateMapEntryEdges() {
    expect createMapEntry("", 1) == map["" := 1];
    expect createMapEntry("a", Undefined) == map["a" := Undefined];
    // `createMapEntry(1, 'x')`: JS converts the key 1 to "1"
    expect createMapEntry("1", "x") == map["1" := "x"];
  }

  method {:test} FlattenEdges() {
    var empty: seq<Tree<int>> := [];
    expect flatten(empty) == [];
    expect flatten([Node(empty)]) == [];
    expect flatten([Leaf(1), Node(empty), Node([Node([Leaf(2)])])]) == [1, 2];
  }

  // A falsy result (or an empty pair) stops the unfold.
  method {:test} UnfoldStopsAtNone() {
    expect unfold((n: int) => if n < 3 then Some((n, n + 1)) else None, 0, 100) == [0, 1, 2];
  }

  method {:test} PluckMissingIsUndefined() {
    expect pluck("nope", [map["a" := 1]]) == [None];
    expect pluck("a", [map["a" := 1], map["b" := 2]]) == [Some(1), None];
  }

  method {:test} MiscListEdges() {
    var empty: seq<int> := [];
    expect reverse([1]) == [1];
    expect indexOf(2, [1, 2, 3, 2]) == 1;
    expect lastIndexOf(2, [1, 2, 3, 2]) == 3;
    expect xprod(empty, [1]) == [];
    expect xprod([1], empty) == [];
    expect all((x: int) => x > 0, empty) == true;
    expect any((x: int) => x > 0, empty) == false;
    // `all(x => x > 0)([1, 2])`, `any(x => x > 1, [1, 2])`
    var allPos := (l: seq<int>) => all((x: int) => x > 0, l);
    expect allPos([1, 2]) == true;
    expect any((x: int) => x > 1, [1, 2]) == true;
    expect reject((x: int) => x > 1, [1, 2, 3]) == [1];
    expect contains(3, [1, 2]) == false;
    expect mapSeq((x: int) => x * x, empty) == [];
  }

  // aperture (v0.12.0): the windows of n consecutive elements, none past
  // the length, and for n <= 0 `|list| - n + 1` empty ones (node: [[1, 2],
  // [2, 3]], [], [[], [], []], four [], [[]], ['ab', 'bc'] as arrays of
  // characters).
  method {:test} ApertureEdges() {
    var empty: seq<int> := [];
    expect aperture(2, [1, 2, 3]) == [[1, 2], [2, 3]];
    expect aperture(7, [1, 2]) == [];
    expect aperture(0, [1, 2]) == [[], [], []];
    expect aperture(-1, [1, 2]) == [[], [], [], []];
    expect aperture(0, empty) == [[]];
    expect aperture(2, "abc") == ["ab", "bc"];
  }

  // none (v0.12.0) is the negation of any (node: true, false, true).
  method {:test} NoneEdges() {
    var empty: seq<int> := [];
    expect none((x: int) => x > 2, [1, 2]) == true;
    expect none((x: int) => x > 1, [1, 2]) == false;
    expect none((x: int) => true, empty) == true;
  }

  // ---- documented deviations (not node behaviour) ----

  // JS unfold (unfoldr until v0.9.1) would loop forever here; the fuel bound
  // stops it.
  method {:test} DeviationUnfoldStopsAtFuel() {
    expect unfold((n: int) => Some((n, n + 1)), 0, 3) == [0, 1, 2];
  }

  // node: flatten([{length: 0}]) is [], flatten([{length: 2, 0: 'a', 1: 'b'}])
  // is ['a', 'b'] and unnest([{length: 0}]) is [] (since v0.3.0 an array-like
  // element is flattened), and since v0.4.0 flatten([{nodeType: 1, length: -1}])
  // and unnest([{nodeType: 1, length: -1}]) are [] (a DOM-element test); a
  // Leaf is never flattened.
  method {:test} DeviationLeafIsNeverArrayLike() {
    var len0 := map["length" := 0];
    expect flatten([Leaf(len0)]) == [len0];
    var ab := map["length" := Num(2), "0" := Str("a"), "1" := Str("b")];
    expect flatten([Leaf(ab)]) == [ab];
    expect unnest([Leaf(len0)]) == [Leaf(len0)];
    var node := map["nodeType" := 1, "length" := -1];
    expect flatten([Leaf(node)]) == [node];
    expect unnest([Leaf(node)]) == [Leaf(node)];
  }

  // node: chain(x => 'ab', [1, 2]) is ['ab', 'ab'] (a string is not
  // array-like, so it stays one element); here f returns a seq, a string is a
  // seq of characters, and the results are concatenated.
  method {:test} DeviationChainConcatenatesStringResults() {
    expect chain((x: int) => "ab", [1, 2]) == "abab";
  }

  // node: zipObj(['__proto__', 'a'], [1, 2]) is {a: 2} and
  // fromPairs([['__proto__', 5], ['a', 1]]) is {a: 1}, and since v0.7.0
  // createMapEntry('__proto__', 1) has no own key: assigning
  // `__proto__` sets the prototype (a primitive is ignored) instead of a
  // property. Likewise the keys of mergeAll([JSON.parse('{"__proto__": 5,
  // "a": 1}'), {b: 2}]) (v0.10.0) are ['a', 'b']. A map's keys are all
  // ordinary.
  method {:test} DeviationPrototypeKeysAreOrdinaryInListBuilders() {
    expect zipObj(["__proto__", "a"], [1, 2]) == map["__proto__" := 1, "a" := 2];
    expect fromPairs([("__proto__", 5), ("a", 1)]) == map["__proto__" := 5, "a" := 1];
    expect createMapEntry("__proto__", 1) == map["__proto__" := 1];
    expect mergeAll([map["__proto__" := 5, "a" := 1], map["b" := 2]]) == map["__proto__" := 5, "a" := 1, "b" := 2];
  }

  // node: since v0.12.0 `_reduce` stops when the accumulator has a truthy
  // `__transducers_reduced__` property and returns its `value` (the
  // transducer protocol's "reduced" marker): `reduce((acc, x) => assoc('x', x,
  // acc), {__transducers_reduced__: 1, value: 9}, [1, 2, 3])` is 9,
  // `mergeAll([{__transducers_reduced__: 1, value: 7}, {a: 2}])` is 7, and
  // `mapObj(x => x, {__transducers_reduced__: 1, value: 5, z: 3})` and
  // `mapObjIndexed` of it are undefined. Here the key is ordinary.
  method {:test} DeviationReducedMarkerIsAnOrdinaryKey() {
    var marked := map["__transducers_reduced__" := 1, "value" := 9];
    expect reduce((acc: map<string, int>, x: int) => acc["x" := x], marked, [1, 2, 3]) == marked["x" := 3];
    var m7 := map["__transducers_reduced__" := 1, "value" := 7];
    expect mergeAll([m7, map["a" := 2]]) == m7["a" := 2];
    var o := map["__transducers_reduced__" := 1, "value" := 5, "z" := 3];
    expect mapObj((x: int) => x, o) == o;
    expect mapObjIndexed((x: int, k: string, m: map<string, int>) => x, o) == o;
  }
}
