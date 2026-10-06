// Ramda v0.2.3 test/test.list.js, test/test.indexof.js,
// test/test.containsuniq.js, test/test.map.js, test/test.find.js,
// test/test.flatten.js, test/test.range.js, test/test.reverse.js,
// test/test.unfold.js, test/test.zip.js, test/test.product.js and
// test/test.partition.js, transcribed. Arity (`.length`) checks have no Dafny
// counterpart and are omitted. `find(even, 'zing')` searches the string's
// characters: here a list of Js strings. test.indexof.js also sets a
// non-index property (`arr[-2] = 4`) on its arrays, which a seq cannot
// carry and which indexOf ignores. Not transcribed: test.flatten.js's "is not
// destructive" (reference inequality) and "handles ridiculously large
// inputs" (its `new Array(1000000)` is a million empty slots, which a seq
// cannot hold).

module RamdafTests.Ramda.List {
  import opened Ramdaf.Prelude
  import opened Ramdaf.Core
  import opened Ramdaf.List
  import opened Support

  // ---- test.list.js ----

  // describe('join'): the list [1, 2, 3, 4] holds numbers, which JS converts
  // to strings; join takes strings here.
  method {:test} JoinConcatenatesWithASeparator() {
    expect join("~", [NumStr(1), NumStr(2), NumStr(3), NumStr(4)]) == "1~2~3~4";
  }

  // describe('slice') (Ramda's other case is a commented-out TODO)
  method {:test} SliceRetrievesTheProperSublist() {
    expect slice(2, 5, [8, 6, 7, 5, 3, 0, 9]) == [7, 5, 3];
  }

  // describe('slice.from')
  method {:test} SliceFromRetrievesTheSuffixFromTheIndex() {
    expect sliceFrom(2, [8, 6, 7, 5, 3, 0, 9]) == [7, 5, 3, 0, 9];
  }

  // describe('remove') (v0.2.2)
  function Letters(): seq<string> { ["a", "b", "c", "d", "e", "f", "g", "h", "i", "j"] }

  method {:test} RemoveSplicesOutASubList() {
    expect remove(2, 5, Letters()) == ["a", "b", "h", "i", "j"];
  }

  method {:test} RemoveRemovesTheEndIfTheCountIsTooLarge() {
    expect remove(2, 20, Letters()) == ["a", "b"];
  }

  method {:test} RemoveRetainsTheEntireListIfTheStartIsTooLarge() {
    expect remove(13, 3, Letters()) == Letters();
  }

  method {:test} RemoveShouldBeCurried() {
    var r := (l: seq<string>) => remove(13, 3, l);
    expect r(Letters()) == Letters();
  }

  // describe('insert') (v0.2.2)
  method {:test} InsertInsertsAnElement() {
    expect insert(2, "x", ["a", "b", "c", "d", "e"]) == ["a", "b", "x", "c", "d", "e"];
  }

  method {:test} InsertInsertsAnotherListAsAnElement() {
    var list := [Str("a"), Str("b"), Str("c"), Str("d"), Str("e")];
    var st := Arr([Str("s"), Str("t")]);
    expect insert(2, st, list) == [Str("a"), Str("b"), st, Str("c"), Str("d"), Str("e")];
  }

  method {:test} InsertAppendsIfTheIndexIsTooLarge() {
    expect insert(8, "z", ["a", "b", "c", "d", "e"]) == ["a", "b", "c", "d", "e", "z"];
  }

  method {:test} InsertShouldBeCurried() {
    var ins := (l: seq<string>) => insert(8, "z", l);
    expect ins(["a", "b", "c", "d", "e"]) == ["a", "b", "c", "d", "e", "z"];
  }

  // describe('insert.all') (v0.2.2)
  method {:test} InsertAllInsertsAListOfElements() {
    expect insertAll(2, ["x", "y", "z"], ["a", "b", "c", "d", "e"]) == ["a", "b", "x", "y", "z", "c", "d", "e"];
  }

  method {:test} InsertAllAppendsIfTheIndexIsTooLarge() {
    expect insertAll(8, ["p", "q", "r"], ["a", "b", "c", "d", "e"]) == ["a", "b", "c", "d", "e", "p", "q", "r"];
  }

  method {:test} InsertAllShouldBeCurried() {
    var ins := (elts: seq<string>, l: seq<string>) => insertAll(8, elts, l);
    expect ins(["p", "q", "r"], ["a", "b", "c", "d", "e"]) == ["a", "b", "c", "d", "e", "p", "q", "r"];
  }

  // describe('nth')
  method {:test} NthReturnsTheObjectAtPositionN() {
    var list := [Str("x"), Num(1), Obj(map["a" := Num(1), "b" := Num(2)]), Arr([Num(4), Num(5), Num(6)]), Bool(true)];
    expect nth(4, list) == Some(Bool(true));
    expect nth(0, list) == Some(Str("x"));
    expect nth(3, list) == Some(Arr([Num(4), Num(5), Num(6)]));
  }

  // "returns null if n is out of the list's range" (v0.2.3 asserts undefined)
  method {:test} NthReturnsNoneOutOfRange() {
    expect nth(4, [1, 2, 3]) == None;
  }

  method {:test} NthIsAutomaticallyCurried() {
    var get3rd := (l: seq<int>) => nth(2, l);
    expect get3rd([3, 4, 5, 6, 7, 8]) == Some(5);
  }

  // describe('times') (v0.2.3)
  method {:test} TimesTakesAMapFunc() {
    expect times((i: nat) => i, 5) == [0, 1, 2, 3, 4];
    expect times((x: nat) => x * 2, 5) == [0, 2, 4, 6, 8];
  }

  method {:test} TimesIsCurried() {
    var mapid := (n: nat) => times((i: nat) => i, n);
    expect mapid(5) == [0, 1, 2, 3, 4];
  }

  // describe('repeatN')
  method {:test} RepeatNReturnsAListOfIdenticalValues() {
    expect repeatN(0, 5) == [0, 0, 0, 0, 0];
  }

  method {:test} RepeatNCanAcceptAnyValueIncludingNull() {
    expect repeatN(Null, 3) == [Null, Null, Null];
  }

  method {:test} RepeatNIsAutomaticallyCurried() {
    var nTrues := (n: nat) => repeatN(true, n);
    expect nTrues(4) == [true, true, true, true];
  }

  // ---- test.indexof.js (v0.2.2; indexOf and lastIndexOf moved here from
  // test.list.js) ----

  // describe('indexOf')
  method {:test} IndexOfReturnsThePosition() {
    expect indexOf(30, [0, 10, 20, 30]) == 3;
  }

  method {:test} IndexOfReturnsMinusOneWhenAbsent() {
    expect indexOf(40, [0, 10, 20, 30]) == -1;
  }

  method {:test} IndexOfReturnsTheIndexOfTheFirstItem() {
    expect indexOf(1, [1, 2, 3, 4, 5]) == 0;
  }

  method {:test} IndexOfReturnsTheIndexOfTheLastItem() {
    expect indexOf(5, [1, 2, 3, 4, 5]) == 4;
  }

  function Arr123(): seq<Js> { [Num(1), Num(2), Num(3)] }

  // "finds 1" and "finds 1 and is result strictly it"
  method {:test} IndexOfFinds1() {
    expect indexOf(Num(1), Arr123()) == 0;
  }

  method {:test} IndexOfDoesNotFind4() {
    expect indexOf(Num(4), Arr123()) == -1;
  }

  method {:test} IndexOfUsesStrictEquality() {
    expect indexOf(Str("1"), Arr123()) == -1;
  }

  method {:test} IndexOfShouldBeCurried() {
    var curried := (l: seq<Js>) => indexOf(Num(3), l);
    expect curried(Arr123()) == 2;
  }

  // describe('indexOf.from')
  method {:test} IndexOfFromIndex1() { expect indexOfFrom(Num(2), 1, Arr123()) == 1; }
  method {:test} IndexOfFromIndex2() { expect indexOfFrom(Num(2), 2, Arr123()) == -1; }
  method {:test} IndexOfFromIndex3() { expect indexOfFrom(Num(2), 3, Arr123()) == -1; }
  method {:test} IndexOfFromIndex4() { expect indexOfFrom(Num(2), 4, Arr123()) == -1; }
  method {:test} IndexOfFromIndexMinus1() { expect indexOfFrom(Num(3), -1, Arr123()) == 2; }
  method {:test} IndexOfFromIndexMinus2() { expect indexOfFrom(Num(3), -2, Arr123()) == 2; }
  method {:test} IndexOfFromIndexMinus3() { expect indexOfFrom(Num(3), -3, Arr123()) == 2; }
  method {:test} IndexOfFromIndexMinus4() { expect indexOfFrom(Num(3), -4, Arr123()) == 2; }

  method {:test} IndexOfFromShouldBeCurried() {
    var curried := (from: int, l: seq<Js>) => indexOfFrom(Num(3), from, l);
    expect curried(0, Arr123()) == 2;
  }

  // describe('lastIndexOf')
  method {:test} LastIndexOfReturnsTheLastPosition() {
    expect lastIndexOf(30, [0, 10, 20, 30, 0, 10, 20, 30, 0, 10]) == 7;
  }

  method {:test} LastIndexOfReturnsMinusOneWhenAbsent() {
    expect lastIndexOf(40, [0, 10, 20, 30]) == -1;
  }

  method {:test} LastIndexOfReturnsTheLastIndexOfTheFirstItem() {
    expect lastIndexOf(1, [1, 2, 3, 4, 5, 1]) == 5;
  }

  method {:test} LastIndexOfReturnsTheIndexOfTheLastItem() {
    expect lastIndexOf(5, [1, 2, 3, 4, 5, 1]) == 4;
  }

  function Ana(): seq<Js> { [Str("a"), Num(1), Str("a")] }

  method {:test} LastIndexOfFindsA() { expect lastIndexOf(Str("a"), Ana()) == 2; }
  method {:test} LastIndexOfDoesNotFindC() { expect lastIndexOf(Str("c"), Ana()) == -1; }
  method {:test} LastIndexOfUsesStrictEquality() { expect lastIndexOf(Str("1"), Ana()) == -1; }

  // describe('lastIndexOf')'s "from index" cases (repeated under
  // describe('lastIndexOf.from') below)
  method {:test} LastIndexOfFromIndexCasesInLastIndexOf() {
    expect lastIndexOfFrom(Str("a"), 1, Ana()) == 0;
    expect lastIndexOfFrom(Str("a"), 2, Ana()) == 2;
    expect lastIndexOfFrom(Str("a"), 3, Ana()) == 2;
    expect lastIndexOfFrom(Str("a"), 4, Ana()) == 2;
    expect lastIndexOfFrom(Str("a"), 0, Ana()) == 0;
    expect lastIndexOfFrom(Str("a"), -1, Ana()) == 2;
    expect lastIndexOfFrom(Str("a"), -2, Ana()) == 0;
    expect lastIndexOfFrom(Str("a"), -3, Ana()) == 0;
    expect lastIndexOfFrom(Str("a"), -4, Ana()) == -1;
  }

  method {:test} LastIndexOfShouldBeCurried() {
    var curried := (l: seq<Js>) => lastIndexOf(Str("a"), l);
    expect curried(Ana()) == 2;
  }

  // describe('lastIndexOf.from')
  method {:test} LastIndexOfFromIndex1() { expect lastIndexOfFrom(Str("a"), 1, Ana()) == 0; }
  method {:test} LastIndexOfFromIndex2() { expect lastIndexOfFrom(Str("a"), 2, Ana()) == 2; }
  method {:test} LastIndexOfFromIndex3() { expect lastIndexOfFrom(Str("a"), 3, Ana()) == 2; }
  method {:test} LastIndexOfFromIndex4() { expect lastIndexOfFrom(Str("a"), 4, Ana()) == 2; }
  method {:test} LastIndexOfFromIndex0() { expect lastIndexOfFrom(Str("a"), 0, Ana()) == 0; }
  method {:test} LastIndexOfFromIndexMinus1() { expect lastIndexOfFrom(Str("a"), -1, Ana()) == 2; }
  method {:test} LastIndexOfFromIndexMinus2() { expect lastIndexOfFrom(Str("a"), -2, Ana()) == 0; }
  method {:test} LastIndexOfFromIndexMinus3() { expect lastIndexOfFrom(Str("a"), -3, Ana()) == 0; }
  method {:test} LastIndexOfFromIndexMinus4() { expect lastIndexOfFrom(Str("a"), -4, Ana()) == -1; }

  method {:test} LastIndexOfFromShouldBeCurried() {
    var curried := (from: int, l: seq<Js>) => lastIndexOfFrom(Str("a"), from, l);
    expect curried(3, Ana()) == 2;
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

  // describe('mapObj')
  method {:test} MapObjRunsTheFunctionOverEachProperty() {
    expect mapObj((n: int) => n * n, map["a" := 1, "b" := 2, "c" := 3]) == map["a" := 1, "b" := 4, "c" := 9];
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

  // describe('mapObj.idx') (v0.2.2)
  function Vowelly(): map<string, int> { map["a" := 8, "b" := 6, "c" := 7, "d" := 5, "e" := 3, "f" := 0, "g" := 9] }
  function squareVowels(x: int, key: string, obj: map<string, int>): int
  { if key in ["a", "e", "i", "o", "u"] then x * x else x }

  method {:test} MapObjIdxWorksJustLikeANormalMapObj() {
    expect mapObjIdx((x: int, k: string, o: map<string, int>) => x * 2, map["a" := 1, "b" := 2, "c" := 3, "d" := 4]) ==
      map["a" := 2, "b" := 4, "c" := 6, "d" := 8];
  }

  // `x + key` concatenates the number and the key as strings.
  method {:test} MapObjIdxPassesTheKeyAsASecondParameter() {
    expect mapObjIdx((x: int, k: string, o: map<string, int>) => NumStr(x) + k, Vowelly()) ==
      map["a" := "8a", "b" := "6b", "c" := "7c", "d" := "5d", "e" := "3e", "f" := "0f", "g" := "9g"];
  }

  method {:test} MapObjIdxPassesTheEntireObjectAsAThirdParameter() {
    expect mapObjIdx(squareVowels, Vowelly()) ==
      map["a" := 64, "b" := 6, "c" := 7, "d" := 5, "e" := 9, "f" := 0, "g" := 9];
  }

  method {:test} MapObjIdxIsAutomaticallyCurried() {
    var makeSquareVowels := (o: map<string, int>) => mapObjIdx(squareVowels, o);
    expect makeSquareVowels(Vowelly()) == map["a" := 64, "b" := 6, "c" := 7, "d" := 5, "e" := 9, "f" := 0, "g" := 9];
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
    expect findIndex(Even, A()) == 1;
    expect findIndex(Gt100, A()) == 8;
    expect findIndex(IsStr, A()) == 3;
    expect findIndex(XGt100, A()) == 10;
  }

  method {:test} FindIndexReturnsMinusOneWhenNoElementSatisfiesThePredicate() {
    expect findIndex(Even, Zing()) == -1;
  }

  // describe('findLast') (new in the v0.2.0 suite; "returns the index of the
  // last element" checks the element)
  method {:test} FindLastReturnsTheLastElementThatSatisfiesThePredicate() {
    expect findLast(Even, A()) == Some(Num(0));
    expect findLast(Gt100, A()) == Some(Num(300));
    expect findLast(IsStr, A()) == Some(Str("cow"));
    expect findLast(XGt100, A()) == Some(Obj2());
  }

  method {:test} FindLastReturnsUndefinedWhenNoElementSatisfiesThePredicate() {
    expect findLast(Even, Zing()) == None;
  }

  // describe('findLastIndex') (the v0.1.5 suite tested it under
  // describe('findLast'))
  method {:test} FindLastIndexReturnsTheIndexOfTheLastElementThatSatisfiesThePredicate() {
    expect findLastIndex(Even, A()) == 15;
    expect findLastIndex(Gt100, A()) == 9;
    expect findLastIndex(IsStr, A()) == 3;
    expect findLastIndex(XGt100, A()) == 10;
  }

  method {:test} FindLastIndexReturnsMinusOneWhenNoElementSatisfiesThePredicate() {
    expect findLastIndex(Even, Zing()) == -1;
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
    // v0.2.2
    expect flatten([Leaf(1), Leaf(2), Leaf(3), Leaf(4), Leaf(5)]) == [1, 2, 3, 4, 5];
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

  // v0.2.3 (its second half checks that pushing onto the result does not
  // change a later result; a seq is a value)
  method {:test} RangeReturnsAnEmptyArrayIfFromIsAboveTo() {
    expect range(10, 5) == [];
    expect range(10, 5) == [];
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

  // v0.2.0
  method {:test} ZipReturnsAListAsLongAsTheShorterInput() {
    var a, b, c := [1, 2, 3], [100, 200, 300, 400], [10, 20];
    expect zip(a, b) == [(1, 100), (2, 200), (3, 300)];
    expect zip(a, c) == [(1, 10), (2, 20)];
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


  // ---- test.partition.js ----

  function Student(name: string, score: int): map<string, Js> { map["name" := Str(name), "score" := Num(score)] }
  function grade(score: int): string
  { if score < 65 then "F" else if score < 70 then "D" else if score < 80 then "C" else if score < 90 then "B" else "A" }
  // `grade(student.score || 0)`
  function byGrade(s: map<string, Js>): string
  { grade(if "score" in s && s["score"].Num? then s["score"].n else 0) }

  method {:test} PartitionSplitsTheListIntoGroups() {
    var students := [Student("Abby", 84), Student("Brad", 73), Student("Chris", 89), Student("Dianne", 99),
                     Student("Eddy", 58), Student("Fred", 67), Student("Gillian", 91), Student("Hannah", 78),
                     Student("Irene", 85), Student("Jack", 69)];
    expect partition(byGrade, students) == map[
      "A" := [Student("Dianne", 99), Student("Gillian", 91)],
      "B" := [Student("Abby", 84), Student("Chris", 89), Student("Irene", 85)],
      "C" := [Student("Brad", 73), Student("Hannah", 78)],
      "D" := [Student("Fred", 67), Student("Jack", 69)],
      "F" := [Student("Eddy", 58)]];
  }

  function Typed(t: string, v: int): map<string, Js> { map["type" := Str(t), "val" := Num(v)] }
  // `prop("type")`; every record here has a string type.
  function TypeOf(o: map<string, Js>): string { if "type" in o && o["type"].Str? then o["type"].s else "undefined" }

  method {:test} PartitionIsAutomaticallyCurried() {
    var splitByType := (l: seq<map<string, Js>>) => partition(TypeOf, l);
    expect splitByType([Typed("A", 10), Typed("B", 20), Typed("A", 30), Typed("A", 40), Typed("C", 50), Typed("B", 60)]) ==
      map["A" := [Typed("A", 10), Typed("A", 30), Typed("A", 40)],
          "B" := [Typed("B", 20), Typed("B", 60)],
          "C" := [Typed("C", 50)]];
  }
}
