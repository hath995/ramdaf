// Edge cases Ramda v0.7.2's own suite does not cover, each checked against
// ramda.js v0.7.2 under node (the expected values are node's output). The
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
    expect car([1, 2, 3]) == 1;
    expect last([1, 2, 3]) == 3;
    expect last([5]) == 5;
    expect isEmpty([0]) == false;
    expect concat(empty, [1]) == [1];
    expect concat([1], empty) == [1];
    expect concat([1, 2], [3]) == [1, 2, 3];
    expect append(1, empty) == [1];
    expect prepend(1, empty) == [1];
    expect size(empty) == 0;
    expect clone([1, 2]) == [1, 2];
    expect identity(3) == 3;
    expect repeatN(7, 0) == [];
    expect repeatN("a", 2) == ["a", "a"];
    expect times((i: nat) => i * i, 4) == [0, 1, 4, 9];
    expect times((i: nat) => i, 0) == [];
  }

  // foldr runs from the right with the accumulator first (since v0.1.1).
  method {:test} FoldrRunsFromTheRightAccumulatorFirst() {
    var empty: seq<int> := [];
    expect foldr((acc: seq<int>, x: int) => [x] + acc, empty, [1, 2]) == [1, 2];
    expect foldr((acc: string, a: string) => acc + a, "", ["x", "y", "z"]) == "zyx";
    expect foldr((acc: int, a: int) => acc - a, 0, [1, 2, 3, 4]) == -10;
  }

  // The idx folds pass (acc, element, index, list).
  method {:test} IdxFoldsPassTheIndexAndList() {
    var empty: seq<string> := [];
    var f := (acc: string, x: string, i: nat, l: seq<string>) => acc + x + NumStr(i) + NumStr(|l|);
    expect foldlIdx(f, "", ["a", "b"]) == "a02b12";
    expect foldrIdx(f, "", ["a", "b"]) == "b12a02";
    expect foldlIdx(f, "5", empty) == "5";
    expect reduceIdx((acc: int, x: int, i: nat, l: seq<int>) => acc + x * i, 0, [1, 2, 3]) == 8;
    var none: seq<nat> := [];
    expect reduceRightIdx((acc: seq<nat>, x: int, i: nat, l: seq<int>) => acc + [i], none, [9, 9, 9]) == [2, 1, 0];
  }

  method {:test} IdxMapFilterRejectEdges() {
    var empty: seq<int> := [];
    expect mapIdx((x: int, i: nat, l: seq<int>) => x + i, empty) == [];
    expect mapIdx((x: int, i: nat, l: seq<int>) => |l| - i, [5, 5, 5]) == [3, 2, 1];
    expect filterIdx((x: int, i: nat, l: seq<int>) => i == 1, [7, 7, 7]) == [7];
    expect filterIdx((x: int, i: nat, l: seq<int>) => false, [1, 2]) == [];
    expect filterIdx((x: int, i: nat, l: seq<int>) => i < |l|, [1, 2]) == [1, 2];
    expect rejectIdx((x: int, i: nat, l: seq<int>) => i == 1, [7, 7, 7]) == [7, 7];
    expect rejectIdx((x: int, i: nat, l: seq<int>) => true, empty) == [];
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
    expect sliceFrom(2, [1, 2, 3]) == [3];
    expect sliceFrom(-2, [1, 2, 3]) == [2, 3];
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
    expect mapObjIdx((v: int, k: string, o: map<string, int>) => k + NumStr(v), map["a" := 1, "b" := 2]) ==
      map["a" := "a1", "b" := "b2"];
    expect mapObjIdx((v: int, k: string, o: map<string, int>) => |o| + v, map["a" := 1, "b" := 2]) ==
      map["a" := 3, "b" := 4];
    expect mapObjIdx((v: int, k: string, o: map<string, int>) => v, none) == map[];
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

  // Since v0.4.0 reduce holds the definition and foldl is its alias.
  method {:test} FoldlIsLeftAssociative() {
    expect foldl((acc: int, x: int) => acc - x, 0, [1, 2, 3]) == -6;
    expect foldl((acc: string, x: string) => acc + x, "", ["a", "b", "c"]) == "abc";
    expect reduce((acc: int, x: int) => acc - x, 10, [1, 2, 3]) == 4;
    expect foldl((acc: int, x: int) => acc - x, 10, [1, 2, 3]) == 4;
    // `reduce(cat, '')('abc')`: a string is a list of characters
    expect reduce((acc: string, c: char) => acc + [c], "", "abc") == "abc";
  }

  // Two strings concatenate when the first is not empty (its own `concat`
  // method); the empty first string is a deviation since v0.6.0 (below).
  method {:test} ConcatOfStrings() {
    expect concat("foo", "") == "foo";
    expect concat("ab", "cd") == "abcd";
    var empty: seq<int> := [];
    expect concat(empty, [1]) == [1];
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

  // Since v0.1.5 take clamps n to the list's length; since v0.5.0 skip gives
  // [] for n >= |list| (from v0.2.0 to v0.4.3 it threw RangeError for
  // n > |list|).
  method {:test} TakeSkipEdges() {
    var empty: seq<int> := [];
    expect take(0, [1, 2]) == [];
    expect take(2, [1, 2]) == [1, 2];
    expect take(5, [1, 2]) == [1, 2];
    expect take(3, empty) == [];
    expect take(2, [1, 2, 3]) == [1, 2];
    expect skip(0, [1, 2]) == [1, 2];
    expect skip(2, [1, 2]) == [];
    expect skip(1, [1, 2]) == [2];
    expect skip(5, [1, 2]) == [];
    expect skip(3, empty) == [];
    expect skip(3, [1, 2, 3]) == [];
    // `skip(5, "abc")` and `skip(5)([1, 2, 3])`
    expect skip(5, "abc") == "";
    var skip5 := (l: seq<int>) => skip(5, l);
    expect skip5([1, 2, 3]) == [];
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
  // at 0 is empty (until v0.2.3 it copied the whole list).
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

  // indexOf.from/lastIndexOf.from (v0.2.2): a negative fromIdx counts from
  // the end; lastIndexOf.from searches at and below fromIdx.
  method {:test} IndexOfFromEdges() {
    var empty: seq<int> := [];
    expect indexOfFrom(2, 1, [2, 1, 2, 3]) == 2;
    expect indexOfFrom(2, -2, [2, 1, 2, 3]) == 2;
    expect indexOfFrom(2, -10, [2, 1, 2]) == 0;
    expect indexOfFrom(2, 10, [2]) == -1;
    expect indexOfFrom(2, 0, empty) == -1;
    expect indexOfFrom(3, 3, [1, 2, 3]) == -1;
    expect lastIndexOfFrom(2, 1, [2, 1, 2, 3]) == 0;
    expect lastIndexOfFrom(2, -1, [2, 1, 2]) == 2;
    expect lastIndexOfFrom(2, -10, [2, 1, 2]) == -1;
    expect lastIndexOfFrom(2, 10, [2, 1, 2]) == 2;
    expect lastIndexOfFrom(2, 0, empty) == -1;
    expect lastIndexOfFrom(1, -3, [1, 2, 3]) == 0;
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

  method {:test} FindTakeWhileSkipUntilEdges() {
    var empty: seq<int> := [];
    expect find((x: int) => x > 9, [1, 2]) == None;
    expect find((x: int) => x > 1, [1, 2, 3]) == Some(2);
    expect takeWhile((x: int) => x < 3, [1, 2, 3, 1]) == [1, 2];
    expect takeWhile((x: int) => x > 0, empty) == [];
    expect takeWhile((x: int) => x < 2, [1, 2, 3]) == [1];
    expect takeWhile((x: int) => x < 9, [1, 2]) == [1, 2];
    // v0.2.4 (it was the whole list from v0.2.0 to v0.2.3)
    expect takeWhile((x: int) => x > 5, [1, 2, 3]) == [];
    expect skipUntil((x: int) => x > 2, [1, 2, 3, 1]) == [3, 1];
    expect skipUntil((x: int) => x > 0, empty) == [];
  }

  // scanl (v0.7.0): the accumulator, then each successive fn(acc, x).
  method {:test} ScanlEdges() {
    var none: seq<int> := [];
    expect scanl((a: int, b: int) => a - b, 10, [1, 2, 3]) == [10, 9, 7, 4];
    expect scanl((a: seq<int>, x: int) => [x] + a, none, [1, 2, 3]) == [[], [1], [2, 1], [3, 2, 1]];
    // `scanl(add, '', 'abc')`: a string is a list of characters
    expect scanl((a: string, c: char) => a + [c], "", "abc") == ["", "a", "ab", "abc"];
    expect scanl((a: int, b: int) => a + b, 0, none) == [0];
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
  method {:test} UnfoldrStopsAtNone() {
    expect unfoldr((n: int) => if n < 3 then Some((n, n + 1)) else None, 0, 100) == [0, 1, 2];
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
    expect every((x: int) => x > 0, empty) == true;
    expect some((x: int) => x > 0, empty) == false;
    // `every(x => x > 0)([1, 2])`, `some(x => x > 1, [1, 2])`
    var allPos := (l: seq<int>) => every((x: int) => x > 0, l);
    expect allPos([1, 2]) == true;
    expect some((x: int) => x > 1, [1, 2]) == true;
    expect reject((x: int) => x > 1, [1, 2, 3]) == [1];
    expect contains(3, [1, 2]) == false;
    expect mapSeq((x: int) => x * x, empty) == [];
  }

  // ---- documented deviations (not node behaviour) ----

  // JS unfoldr would loop forever here; the fuel bound stops it.
  method {:test} DeviationUnfoldrStopsAtFuel() {
    expect unfoldr((n: int) => Some((n, n + 1)), 0, 3) == [0, 1, 2];
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

  // node: concat('', 'bar') and concat('', '') throw "TypeError: can't concat
  // string" (since v0.6.0 a non-array second argument needs a truthy first
  // argument with a `concat` method; v0.4.0 and v0.5.0 gave 'bar' and '',
  // v0.2.4 to v0.3.0 ['b', 'a', 'r'] and []). Here a string is a seq, and
  // `concat("", "bar")` is the same call as `concat([], ['b', 'a', 'r'])`,
  // which node still allows.
  method {:test} DeviationConcatOfAnEmptyFirstString() {
    expect concat("", "bar") == "bar";
    expect concat("", "") == "";
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
  // property. A map's keys are all ordinary.
  method {:test} DeviationPrototypeKeysAreOrdinaryInListBuilders() {
    expect zipObj(["__proto__", "a"], [1, 2]) == map["__proto__" := 1, "a" := 2];
    expect fromPairs([("__proto__", 5), ("a", 1)]) == map["__proto__" := 5, "a" := 1];
    expect createMapEntry("__proto__", 1) == map["__proto__" := 1];
  }
}
