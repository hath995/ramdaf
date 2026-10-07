// Ramda v0.7.0 test/test.list.js, test/test.indexof.js,
// test/test.containsuniq.js, test/test.map.js, test/test.find.js,
// test/test.flatten.js, test/test.range.js, test/test.reverse.js,
// test/test.unfold.js, test/test.zip.js, test/test.product.js,
// test/test.partition.js and test/test.groupBy.js, transcribed. Arity
// (`.length`) checks have no Dafny counterpart and are omitted, and so are
// the "throws on zero arguments" cases (v0.5.0; no-argument calls).
// findLast's and findLastIndex's `(even, 'zing')` search the string's
// characters: here a list of Js strings (since v0.5.0 find and findIndex
// search `['zing']`). test.indexof.js also sets a non-index property (`arr[-2] = 4`) on
// its arrays, which a seq cannot carry and which indexOf ignores. Not
// transcribed: test.flatten.js's "is not destructive" (reference inequality;
// flatten's, and v0.3.0's unnest's), "handles ridiculously large inputs" (its
// `new Array(1000000)` is a million empty slots, which a seq cannot hold) and
// v0.3.0's "handles array-like objects" (flatten's and unnest's: an object
// with a `length` property is not a seq); test.zip.js's zipObj "extra keys
// are undefined" (more keys than values is outside the domain, README) and
// fromPairs "skips empty Arrays and non-Array elements" (the elements are
// typed pairs, README "Outside the modeled domain"). Also transcribed here:
// v0.7.0's new test.createMapEntry.js and test.scanl.js. test.zip.js's v0.4.0
// toPairs and toPairsIn describes test Object functions and are transcribed
// in tests/ramda/object.dfy. (v0.4.1 removed test.list.js's describe('nth')
// with the function.)

module RamdafTests.Ramda.List {
  import opened Ramdaf.Prelude
  import opened Ramdaf.Core
  import opened Ramdaf.List
  import opened Ramdaf.Data
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

  // v0.2.4
  method {:test} RemoveReturnsTheAppropriateSublistWhenStartIs0() {
    expect remove(0, 5, Letters()) == ["f", "g", "h", "i", "j"];
    expect remove(0, 1, Letters()) == ["b", "c", "d", "e", "f", "g", "h", "i", "j"];
    expect remove(0, |Letters()|, Letters()) == [];
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

  // describe('of') (v0.3.0)
  method {:test} OfReturnsItsArgumentAsAnArray() {
    expect of(100) == [100];
    expect of([100]) == [[100]];
    expect of(Null) == [Null];
    expect of(Undefined) == [Undefined];
    var none: seq<int> := [];
    expect of(none) == [[]];
  }

  // describe('empty') (v0.3.0)
  method {:test} EmptyReturnsAnEmptyList() {
    expect empty([1, 2, 3]) == [];
  }

  // describe('chain') (v0.3.0): `dbl` is `map(multiply(2))`.
  method {:test} ChainMapsAFunctionOverANestedListAndFlattensTheResult() {
    var dbl := (l: seq<int>) => mapSeq((x: int) => x * 2, l);
    expect chain(dbl, [[1, 2, 3], [1], [0, 10, -3, 5, 7]]) == [2, 4, 6, 2, 0, 20, -6, 10, 14];
    expect chain(dbl, [[1, 2, 3], []]) == [2, 4, 6];
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

  // v0.5.0
  method {:test} IndexOfReturnsMinusOneForAnEmptyArray() {
    var empty: seq<string> := [];
    expect indexOf("x", empty) == -1;
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

  // v0.5.0
  method {:test} IndexOfFromReturnsMinusOneForAnEmptyArray() {
    var empty: seq<string> := [];
    expect indexOfFrom("x", 3, empty) == -1;
    expect indexOfFrom("x", -3, empty) == -1;
  }

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

  // v0.5.0: "returns -1 for an empty array" calls `lastIndexOf('x', 2, [])`
  // and `lastIndexOf('x', -5, [])`, three arguments to the binary curried
  // function, so JS searches the number 2 (or -5) as the list and gets -1;
  // the evident intent, the empty list, gives the same -1.
  method {:test} LastIndexOfReturnsMinusOneForAnEmptyArray() {
    var empty: seq<string> := [];
    expect lastIndexOf("x", empty) == -1;
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

  // v0.5.0
  method {:test} LastIndexOfFromReturnsMinusOneForAnEmptyArray() {
    var empty: seq<string> := [];
    expect lastIndexOfFrom("x", 2, empty) == -1;
    expect lastIndexOfFrom("x", -5, empty) == -1;
  }

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

  // v0.5.0
  method {:test} ContainsIsCurried() {
    var has7 := (l: seq<int>) => contains(7, l);
    expect has7([1, 2, 3]) == false;
    expect has7([1, 2, 7, 3]) == true;
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

  // v0.2.4
  method {:test} UniqKeepsElementsFromTheLeft() {
    expect uniq([1, 2, 3, 4, 1]) == [1, 2, 3, 4];
  }

  method {:test} UniqOfTheEmptyArray() {
    var empty: seq<int> := [];
    expect uniq(empty) == [];
  }

  // describe('uniqWith') (v0.2.4). The objects' `x` holds `alwaysTrue` or
  // `alwaysFalse`, compared by reference; here the markers "T" and "F".
  function Ox(x: string, i: int): map<string, Js> { map["x" := Str(x), "i" := Num(i)] }
  function Oi(i: int): map<string, Js> { map["i" := Num(i)] }
  // `x.i === accX.i`
  function eqI(x: map<string, Js>, accX: map<string, Js>): bool
  { ("i" in x) == ("i" in accX) && ("i" in x ==> x["i"] == accX["i"]) }

  method {:test} UniqWithReturnsASetBasedOnThePredicate() {
    var objs := [Ox("T", 0), Ox("F", 1), Ox("T", 2), Ox("T", 3), Ox("F", 4), Ox("F", 5), Ox("T", 6), Ox("F", 7)];
    var objs2 := [Ox("T", 0), Ox("F", 1), Ox("T", 2), Ox("T", 3), Ox("F", 0), Ox("T", 1), Ox("F", 2), Ox("F", 3)];
    expect uniqWith(eqI, objs) == objs;
    expect uniqWith(eqI, objs2) == [Ox("T", 0), Ox("F", 1), Ox("T", 2), Ox("T", 3)];
  }

  method {:test} UniqWithKeepsElementsFromTheLeft() {
    expect uniqWith(eqI, [Oi(1), Oi(2), Oi(3), Oi(4), Oi(1)]) == [Oi(1), Oi(2), Oi(3), Oi(4)];
  }

  method {:test} UniqWithOfTheEmptyArray() {
    var empty: seq<map<string, Js>> := [];
    expect uniqWith(eqI, empty) == [];
  }

  // v0.5.0
  method {:test} UniqWithIsCurried() {
    var objs := [Ox("T", 0), Ox("F", 1), Ox("T", 2), Ox("T", 3), Ox("F", 4), Ox("F", 5), Ox("T", 6), Ox("F", 7)];
    var objs2 := [Ox("T", 0), Ox("F", 1), Ox("T", 2), Ox("T", 3), Ox("F", 0), Ox("T", 1), Ox("F", 2), Ox("F", 3)];
    var uniqByI := (l: seq<map<string, Js>>) => uniqWith(eqI, l);
    expect uniqByI(objs) == objs;
    expect uniqByI(objs2) == [Ox("T", 0), Ox("F", 1), Ox("T", 2), Ox("T", 3)];
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

  // (`['zing']` since v0.5.0; `'zing'`, its characters, before)
  method {:test} FindReturnsUndefinedWhenNoElementSatisfiesThePredicate() {
    expect find(Even, [Str("zing")]) == None;
  }

  // v0.5.0
  method {:test} FindReturnsUndefinedWhenGivenAnEmptyList() {
    var none: seq<Js> := [];
    expect find(Even, none) == None;
  }

  // v0.5.0
  method {:test} FindIsCurried() {
    var findEven := (l: seq<Js>) => find(Even, l);
    expect findEven(A()) == Some(Num(10));
  }

  // describe('findIndex')
  method {:test} FindIndexReturnsTheIndexOfTheFirstElementThatSatisfiesThePredicate() {
    expect findIndex(Even, A()) == 1;
    expect findIndex(Gt100, A()) == 8;
    expect findIndex(IsStr, A()) == 3;
    expect findIndex(XGt100, A()) == 10;
  }

  // (`['zing']` since v0.5.0, which also adds the empty list)
  method {:test} FindIndexReturnsMinusOneWhenNoElementSatisfiesThePredicate() {
    var none: seq<Js> := [];
    expect findIndex(Even, [Str("zing")]) == -1;
    expect findIndex(Even, none) == -1;
  }

  // v0.5.0
  method {:test} FindIndexIsCurried() {
    var findIndexEven := (l: seq<Js>) => findIndex(Even, l);
    expect findIndexEven(A()) == 1;
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

  // v0.4.2
  method {:test} FindLastWorksWhenTheFirstElementMatches() {
    expect findLast(Even, [Num(2), Num(3), Num(5)]) == Some(Num(2));
  }

  // v0.4.2
  method {:test} FindLastDoesNotGoIntoAnInfiniteLoopOnAnEmptyArray() {
    var none: seq<Js> := [];
    expect findLast(Even, none) == None;
  }

  // v0.5.0
  method {:test} FindLastIsCurried() {
    var findLastEven := (l: seq<Js>) => findLast(Even, l);
    expect findLastEven(A()) == Some(Num(0));
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

  // v0.4.2
  method {:test} FindLastIndexWorksWhenTheFirstElementMatches() {
    expect findLastIndex(Even, [Num(2), Num(3), Num(5)]) == 0;
  }

  // v0.4.2
  method {:test} FindLastIndexDoesNotGoIntoAnInfiniteLoopOnAnEmptyArray() {
    var none: seq<Js> := [];
    expect findLastIndex(Even, none) == -1;
  }

  // v0.5.0
  method {:test} FindLastIndexIsCurried() {
    var findLastIndexEven := (l: seq<Js>) => findLastIndex(Even, l);
    expect findLastIndexEven(A()) == 15;
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

  // v0.5.0
  method {:test} FlattenFlattensAnArrayOfEmptyArrays() {
    var none: seq<Tree<int>> := [];
    expect flatten([Node(none), Node(none), Node(none)]) == [];
    expect flatten(none) == [];
  }

  // describe('unnest') (v0.3.0)
  method {:test} UnnestOnlyFlattensOneLayerDeepOfANestedList() {
    // [1, [2], [3, [4, 5], 6, [[[7], 8]]], 9, 10]
    var nest := [Leaf(1), Node([Leaf(2)]),
                 Node([Leaf(3), Node([Leaf(4), Leaf(5)]), Leaf(6), Node([Node([Node([Leaf(7)]), Leaf(8)])])]),
                 Leaf(9), Leaf(10)];
    // [1, 2, 3, [4, 5], 6, [[[7], 8]], 9, 10]
    expect unnest(nest) == [Leaf(1), Leaf(2), Leaf(3), Node([Leaf(4), Leaf(5)]), Leaf(6),
                            Node([Node([Node([Leaf(7)]), Leaf(8)])]), Leaf(9), Leaf(10)];
    // [[[[3]], 2, 1], 0, [[-1, -2], -3]]
    var nest2 := [Node([Node([Node([Leaf(3)])]), Leaf(2), Leaf(1)]), Leaf(0),
                  Node([Node([Leaf(-1), Leaf(-2)]), Leaf(-3)])];
    // [[[3]], 2, 1, 0, [-1, -2], -3]
    expect unnest(nest2) == [Node([Node([Leaf(3)])]), Leaf(2), Leaf(1), Leaf(0),
                             Node([Leaf(-1), Leaf(-2)]), Leaf(-3)];
    expect unnest([Leaf(1), Leaf(2), Leaf(3), Leaf(4), Leaf(5)]) == [Leaf(1), Leaf(2), Leaf(3), Leaf(4), Leaf(5)];
  }

  // v0.5.0
  method {:test} UnnestFlattensAnArrayOfEmptyArrays() {
    var none: seq<Tree<int>> := [];
    expect unnest([Node(none), Node(none), Node(none)]) == [];
    expect unnest(none) == [];
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

  // describe('zipObj') (v0.3.0)
  method {:test} ZipObjCombinesAnArrayOfKeysWithAnArrayOfValues() {
    expect zipObj(["a", "b", "c"], [1, 2, 3]) == map["a" := 1, "b" := 2, "c" := 3];
  }

  method {:test} ZipObjIgnoresExtraValues() {
    expect zipObj(["a", "b", "c"], [1, 2, 3, 4, 5, 6, 7]) == map["a" := 1, "b" := 2, "c" := 3];
  }

  method {:test} ZipObjLastOneInWinsWhenThereAreDuplicateKeys() {
    expect zipObj(["a", "b", "c", "a"], [Num(1), Num(2), Num(3), Str("LAST")]) ==
      map["a" := Str("LAST"), "b" := Num(2), "c" := Num(3)];
  }

  // describe('fromPairs') (v0.3.0)
  method {:test} FromPairsCombinesTwoElementArraysIntoAnObject() {
    expect fromPairs([("a", 1), ("b", 2), ("c", 3)]) == map["a" := 1, "b" := 2, "c" := 3];
  }

  // ---- test.createMapEntry.js (v0.7.0; describe('mapEntry')) ----

  method {:test} CreateMapEntryCreatesAnObjectContainingASingleKeyValuePair() {
    expect createMapEntry("foo", 42) == map["foo" := 42];
  }

  method {:test} CreateMapEntryIsAutomaticallyCurried() {
    var foo := (v: int) => createMapEntry("foo", v);
    expect foo(42) == map["foo" := 42];
  }

  // ---- test.scanl.js (v0.7.0). Not transcribed: "correctly reports the
  // arity of curried versions" and the two no-argument cases. ----

  method {:test} ScanlScansSimpleFunctionsWithTheSuppliedAccumulator() {
    expect scanl((a: int, b: int) => a + b, 0, [1, 2, 3, 4]) == [0, 1, 3, 6, 10];
    expect scanl((a: int, b: int) => a * b, 1, [1, 2, 3, 4]) == [1, 1, 2, 6, 24];
  }

  method {:test} ScanlReturnsTheAccumulatorForAnEmptyArray() {
    var empty: seq<int> := [];
    expect scanl((a: int, b: int) => a + b, 0, empty) == [0];
    expect scanl((a: int, b: int) => a * b, 1, empty) == [1];
  }

  // `scanl(add)` with JS `+`: numbers and strings
  method {:test} ScanlIsAutomaticallyCurried() {
    var sum := (l: seq<int>) => scanl((a: int, b: int) => a + b, 0, l);
    expect sum([1, 2, 3, 4]) == [0, 1, 3, 6, 10];
    var cat := (l: seq<string>) => scanl((a: string, b: string) => a + b, "", l);
    expect cat(["1", "2", "3", "4"]) == ["", "1", "12", "123", "1234"];
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


  // ---- test.partition.js (v0.3.0: partition splits a list by a predicate;
  // its v0.1.4 to v0.2.4 grouping tests moved to test.groupBy.js, below) ----

  // `function(n) { return n % 2; }`: the remainder is truthy exactly when it
  // is nonzero.
  method {:test} PartitionSplitsAListIntoTwoListsAccordingToAPredicate() {
    var pred := (n: int) => n % 2 != 0;
    var none: seq<int> := [];
    expect partition(pred, none) == ([], []);
    expect partition(pred, [0, 2, 4, 6]) == ([], [0, 2, 4, 6]);
    expect partition(pred, [1, 3, 5, 7]) == ([1, 3, 5, 7], []);
    expect partition(pred, [0, 1, 2, 3]) == ([1, 3], [0, 2]);
  }

  // `partition(Boolean)`: JS truthiness (Support.Truthy) of mixed values.
  method {:test} PartitionIsCurried() {
    var polarize := (l: seq<Js>) => partition(Truthy, l);
    expect polarize([Bool(true), Num(0), Num(1), Null]) == ([Bool(true), Num(1)], [Num(0), Null]);
  }

  // ---- test.groupBy.js (v0.3.0; test.partition.js's tests until v0.2.4) ----

  function Student(name: string, score: int): map<string, Js> { map["name" := Str(name), "score" := Num(score)] }
  function grade(score: int): string
  { if score < 65 then "F" else if score < 70 then "D" else if score < 80 then "C" else if score < 90 then "B" else "A" }
  // `grade(student.score || 0)`
  function byGrade(s: map<string, Js>): string
  { grade(if "score" in s && s["score"].Num? then s["score"].n else 0) }

  method {:test} GroupBySplitsTheListIntoGroupsAccordingToTheGroupingFunction() {
    var students := [Student("Abby", 84), Student("Brad", 73), Student("Chris", 89), Student("Dianne", 99),
                     Student("Eddy", 58), Student("Fred", 67), Student("Gillian", 91), Student("Hannah", 78),
                     Student("Irene", 85), Student("Jack", 69)];
    expect groupBy(byGrade, students) == map[
      "A" := [Student("Dianne", 99), Student("Gillian", 91)],
      "B" := [Student("Abby", 84), Student("Chris", 89), Student("Irene", 85)],
      "C" := [Student("Brad", 73), Student("Hannah", 78)],
      "D" := [Student("Fred", 67), Student("Jack", 69)],
      "F" := [Student("Eddy", 58)]];
  }

  function Typed(t: string, v: int): map<string, Js> { map["type" := Str(t), "val" := Num(v)] }
  // `prop("type")`; every record here has a string type.
  function TypeOf(o: map<string, Js>): string { if "type" in o && o["type"].Str? then o["type"].s else "undefined" }

  method {:test} GroupByIsAutomaticallyCurried() {
    var splitByType := (l: seq<map<string, Js>>) => groupBy(TypeOf, l);
    expect splitByType([Typed("A", 10), Typed("B", 20), Typed("A", 30), Typed("A", 40), Typed("C", 50), Typed("B", 60)]) ==
      map["A" := [Typed("A", 10), Typed("A", 30), Typed("A", 40)],
          "B" := [Typed("B", 20), Typed("B", 60)],
          "C" := [Typed("C", 50)]];
  }

  // v0.5.0: `groupBy(prop('x'), [])`
  method {:test} GroupByReturnsAnEmptyObjectIfGivenAnEmptyArray() {
    var none: seq<map<string, Js>> := [];
    expect groupBy((o: map<string, Js>) => if "x" in o && o["x"].Str? then o["x"].s else "undefined", none) == map[];
  }
}
