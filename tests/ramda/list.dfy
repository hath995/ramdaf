// Ramda v0.1.1 test/test.list.js, test/test.containsuniq.js, test/test.map.js,
// test/test.find.js, test/test.flatten.js, test/test.range.js,
// test/test.reverse.js, test/test.unfold.js, test/test.zip.js,
// test/test.product.js and describe('repeat.nTimes') of test/test.lazy.js,
// transcribed. Arity (`.length`) checks have no Dafny counterpart and are
// omitted. The rest of test.lazy.js tests generators (not portable, README).
// `find(even, 'zing')` searches the string's characters: here a list of Js
// strings.

module RamdafTests.Ramda.List {
  import opened Ramdaf.Prelude
  import opened Ramdaf.Core
  import opened Ramdaf.List
  import opened Support

  // ---- test.list.js ----

  // describe('indexOf')
  method {:test} IndexOfReturnsThePosition() {
    expect indexOf(30, [0, 10, 20, 30]) == 3;
  }

  method {:test} IndexOfReturnsMinusOneWhenAbsent() {
    expect indexOf(40, [0, 10, 20, 30]) == -1;
  }

  // describe('lastIndexOf')
  method {:test} LastIndexOfReturnsTheLastPosition() {
    expect lastIndexOf(30, [0, 10, 20, 30, 0, 10, 20, 30, 0, 10]) == 7;
  }

  method {:test} LastIndexOfReturnsMinusOneWhenAbsent() {
    expect lastIndexOf(40, [0, 10, 20, 30]) == -1;
  }

  // describe('join'): the list [1, 2, 3, 4] holds numbers, which JS converts
  // to strings; join takes strings here.
  method {:test} JoinConcatenatesWithASeparator() {
    expect join("~", [NumStr(1), NumStr(2), NumStr(3), NumStr(4)]) == "1~2~3~4";
  }

  // describe('splice')
  method {:test} SpliceRemovesTheSpecifiedElements() {
    expect splice(3, 2, [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]) == [0, 1, 2, 5, 6, 7, 8, 9];
  }

  // describe('nth')
  method {:test} NthReturnsTheObjectAtPositionN() {
    var list := [Str("x"), Num(1), Obj(map["a" := Num(1), "b" := Num(2)]), Arr([Num(4), Num(5), Num(6)]), Bool(true)];
    expect nth(4, list) == Some(Bool(true));
    expect nth(0, list) == Some(Str("x"));
    expect nth(3, list) == Some(Arr([Num(4), Num(5), Num(6)]));
  }

  // "returns null if n is out of the list's range"
  method {:test} NthReturnsNoneOutOfRange() {
    expect nth(4, [1, 2, 3]) == None;
  }

  method {:test} NthIsAutomaticallyCurried() {
    var get3rd := (l: seq<int>) => nth(2, l);
    expect get3rd([3, 4, 5, 6, 7, 8]) == Some(5);
  }

  // ---- test.containsuniq.js ----

  // describe('contains')
  method {:test} ContainsTrueWhenPresent() {
    expect contains(7, [1, 2, 3, 9, 8, 7, 100, 200, 300]) == true;
  }

  method {:test} ContainsFalseWhenAbsent() {
    expect contains(99, [1, 2, 3, 9, 8, 7, 100, 200, 300]) == false;
  }

  method {:test} ContainsFalseForTheEmptyList() {
    var empty: seq<int> := [];
    expect contains(1, empty) == false;
  }

  // describe('isSet')
  method {:test} IsSetTrueIfTheListHasUniqueElements() {
    expect isSet([1, 2, 3, 1, 2, 3, 1, 2, 3]) == false;
    expect isSet([3, 1, 4, 2, 5, 7, 9]) == true;
  }

  method {:test} IsSetTrueForAnEmptyArray() {
    var empty: seq<int> := [];
    expect isSet(empty) == true;
  }

  // describe('uniq')
  method {:test} UniqPurgesDuplicates() {
    expect uniq([1, 2, 3, 1, 2, 3, 1, 2, 3]) == [1, 2, 3];
  }

  method {:test} UniqOfTheEmptyArray() {
    var empty: seq<int> := [];
    expect uniq(empty) == [];
  }

  // ---- test.map.js ----

  method {:test} MapMapsSimpleFunctions() {
    expect mapSeq((x: int) => x * 2, [1, 2, 3, 4]) == [2, 4, 6, 8];
  }

  method {:test} MapIsAutomaticallyCurried() {
    var inc := (l: seq<int>) => mapSeq((x: int) => x + 1, l);
    expect inc([1, 2, 3]) == [2, 3, 4];
  }

  // describe('map.idx')
  function addIdx(x: int, idx: nat, list: seq<int>): int { x + idx }
  function squareEnds(x: int, idx: nat, list: seq<int>): int
  { if idx == 0 || idx == |list| - 1 then x * x else x }

  method {:test} MapIdxWorksJustLikeANormalMap() {
    expect mapIdx((x: int, idx: nat, list: seq<int>) => x * 2, [1, 2, 3, 4]) == [2, 4, 6, 8];
  }

  method {:test} MapIdxPassesTheIndexAsASecondParameter() {
    expect mapIdx(addIdx, [8, 6, 7, 5, 3, 0, 9]) == [8 + 0, 6 + 1, 7 + 2, 5 + 3, 3 + 4, 0 + 5, 9 + 6];
  }

  method {:test} MapIdxPassesTheEntireListAsAThirdParameter() {
    expect mapIdx(squareEnds, [8, 6, 7, 5, 3, 0, 9]) == [64, 6, 7, 5, 3, 0, 81];
  }

  method {:test} MapIdxIsAutomaticallyCurried() {
    var makeSquareEnds := (l: seq<int>) => mapIdx(squareEnds, l);
    expect makeSquareEnds([8, 6, 7, 5, 3, 0, 9]) == [64, 6, 7, 5, 3, 0, 81];
  }

  // ---- test.find.js ----

  function Even(x: Js): bool { x.Num? && x.n % 2 == 0 }
  function Gt100(x: Js): bool { x.Num? && x.n > 100 }
  function IsStr(x: Js): bool { x.Str? }
  // `o && o.x > 100`
  function XGt100(o: Js): bool { o.Obj? && "x" in o.props && o.props["x"].Num? && o.props["x"].n > 100 }

  function Obj1(): Js { Obj(map["x" := Num(100)]) }
  function Obj2(): Js { Obj(map["x" := Num(200)]) }
  function A(): seq<Js>
  { [Num(11), Num(10), Num(9), Str("cow"), Obj1(), Num(8), Num(7), Num(100), Num(200), Num(300),
     Obj2(), Num(4), Num(3), Num(2), Num(1), Num(0)] }
  function Zing(): seq<Js> { [Str("z"), Str("i"), Str("n"), Str("g")] }

  // describe('find')
  method {:test} FindReturnsTheFirstElementThatSatisfiesThePredicate() {
    expect find(Even, A()) == Some(Num(10));
    expect find(Gt100, A()) == Some(Num(200));
    expect find(IsStr, A()) == Some(Str("cow"));
    expect find(XGt100, A()) == Some(Obj2());
  }

  method {:test} FindReturnsUndefinedWhenNoElementSatisfiesThePredicate() {
    expect find(Even, Zing()) == None;
  }

  // describe('findIndex')
  method {:test} FindIndexReturnsTheIndexOfTheFirstElementThatSatisfiesThePredicate() {
    expect findIndex(Even, A()) == Some(1);
    expect findIndex(Gt100, A()) == Some(8);
    expect findIndex(IsStr, A()) == Some(3);
    expect findIndex(XGt100, A()) == Some(10);
  }

  method {:test} FindIndexReturnsUndefinedWhenNoElementSatisfiesThePredicate() {
    expect findIndex(Even, Zing()) == None;
  }

  // describe('findLast') (Ramda's describe tests findLastIndex)
  method {:test} FindLastIndexReturnsTheIndexOfTheLastElementThatSatisfiesThePredicate() {
    expect findLastIndex(Even, A()) == Some(15);
    expect findLastIndex(Gt100, A()) == Some(9);
    expect findLastIndex(IsStr, A()) == Some(3);
    expect findLastIndex(XGt100, A()) == Some(10);
  }

  method {:test} FindLastIndexReturnsUndefinedWhenNoElementSatisfiesThePredicate() {
    expect findLastIndex(Even, Zing()) == None;
  }

  // ---- test.flatten.js ----

  method {:test} FlattenTurnsANestedListIntoOneFlatList() {
    // [1, [2], [3, [4, 5], 6, [[[7], 8]]], 9, 10]
    var nest := [Leaf(1), Node([Leaf(2)]),
                 Node([Leaf(3), Node([Leaf(4), Leaf(5)]), Leaf(6), Node([Node([Node([Leaf(7)]), Leaf(8)])])]),
                 Leaf(9), Leaf(10)];
    expect flatten(nest) == [1, 2, 3, 4, 5, 6, 7, 8, 9, 10];
    // [[[[3]], 2, 1], 0, [[-1, -2], -3]]
    var nest2 := [Node([Node([Node([Leaf(3)])]), Leaf(2), Leaf(1)]), Leaf(0),
                  Node([Node([Leaf(-1), Leaf(-2)]), Leaf(-3)])];
    expect flatten(nest2) == [3, 2, 1, 0, -1, -2, -3];
  }

  // ---- test.range.js ----

  method {:test} RangeReturnsListOfNumbers() {
    expect range(0, 5) == [0, 1, 2, 3, 4];
    expect range(4, 7) == [4, 5, 6];
  }

  method {:test} RangeIsEmptyUnlessFromIsBelowTo() {
    expect range(7, 3) == [];
    expect range(5, 5) == [];
  }

  method {:test} RangeIsAutomaticallyCurried() {
    var from10 := (to: int) => range(10, to);
    expect from10(15) == [10, 11, 12, 13, 14];
  }

  // ---- test.reverse.js ----

  method {:test} ReverseReversesArrays() {
    expect reverse([1, 2, 3, 4]) == [4, 3, 2, 1];
  }

  method {:test} ReverseOfTheEmptyList() {
    var empty: seq<int> := [];
    expect reverse(empty) == [];
  }

  // ---- test.unfold.js (unfoldr takes a fuel bound; see README) ----

  method {:test} UnfoldrUnfoldsFromASeed() {
    expect unfoldr((n: int) => if n > 0 then Some((n, n - 1)) else None, 10, 100) ==
      [10, 9, 8, 7, 6, 5, 4, 3, 2, 1];
  }

  // "should just be cool!": the JS generator counts its calls in a closure;
  // the count is threaded through the seed instead.
  method {:test} UnfoldrFibonacci() {
    var fib := (s: (int, (int, int))) =>
      if s.0 < 10 then Some((s.1.0, (s.0 + 1, (s.1.1, s.1.0 + s.1.1)))) else None;
    expect unfoldr(fib, (0, (0, 1)), 100) == [0, 1, 1, 2, 3, 5, 8, 13, 21, 34];
  }

  // ---- test.zip.js ----

  method {:test} ZipWithAppliesTheFunctionPairwise() {
    var a, b := [1, 2, 3], [100, 200, 300];
    expect zipWith((x: int, y: int) => x + y, a, b) == [101, 202, 303];
    expect zipWith((x: int, y: int) => x * y, a, b) == [100, 400, 900];
    expect zipWith((x: int, y: int) => NumStr(x) + " cow " + NumStr(y), a, b) ==
      ["1 cow 100", "2 cow 200", "3 cow 300"];
  }

  method {:test} ZipWithLengthIsTheFirstListsLength() {
    var a, c := [1, 2, 3], [10, 20, 30, 40, 50, 60];
    expect |zipWith((x: int, y: int) => x + y, a, c)| == |a|;
  }

  method {:test} ZipReturnsAnArrayOfTuples() {
    expect zip([1, 2, 3], [100, 200, 300]) == [(1, 100), (2, 200), (3, 300)];
  }

  // ---- test.product.js ----

  method {:test} XprodReturnsAnEmptyListIfEitherInputListIsEmpty() {
    var empty: seq<int> := [];
    expect xprod(empty, [1, 2, 3]) == [];
    expect xprod([1, 2, 3], empty) == [];
  }

  method {:test} XprodCreatesAllCrossProductPairs() {
    expect xprod([1, 2], ["a", "b", "c"]) == [(1, "a"), (1, "b"), (1, "c"), (2, "a"), (2, "b"), (2, "c")];
  }

  method {:test} XprodIsAutomaticallyCurried() {
    var something := (l: seq<int>) => xprod(["a", "b", "c"], l);
    expect something([1, 2]) == [("a", 1), ("a", 2), ("b", 1), ("b", 2), ("c", 1), ("c", 2)];
  }

  method {:test} XprodWithCreatesAllCrossProducts() {
    expect xprodWith((x: int, y: string) => NumStr(x) + y, [1, 2], ["a", "b", "c"]) ==
      ["1a", "1b", "1c", "2a", "2b", "2c"];
  }

  method {:test} XprodWithReturnsAnEmptyListIfEitherInputListIsEmpty() {
    var empty: seq<int> := [];
    expect xprodWith((x: int, y: int) => x + y, empty, [1, 2, 3]) == [];
    expect xprodWith((x: int, y: int) => x + y, [1, 2, 3], empty) == [];
  }

  method {:test} XprodWithIsAutomaticallyCurried() {
    expect xprodWith((x: string, y: int) => x + NumStr(y), ["a", "b", "c"], [1, 2]) ==
      ["a1", "a2", "b1", "b2", "c1", "c2"];
    expect xprodWith((x: int, y: string) => NumStr(x) + y, [1, 2], ["a", "b", "c"]) ==
      ["1a", "1b", "1c", "2a", "2b", "2c"];
  }

  // ---- test.lazy.js: describe('repeat.nTimes') ----

  method {:test} RepeatNTimesReturnsAListOfIdenticalValues() {
    expect repeatNTimes(0, 5) == [0, 0, 0, 0, 0];
  }

  method {:test} RepeatNTimesCanAcceptAnyValueIncludingNull() {
    expect repeatNTimes(Null, 3) == [Null, Null, Null];
  }

  method {:test} RepeatNTimesIsAutomaticallyCurried() {
    var nTrues := (n: nat) => repeatNTimes(true, n);
    expect nTrues(4) == [true, true, true, true];
  }
}
