// Ramda v0.13.0 test/join.js, slice.js, remove.js, insert.js, insertAll.js,
// times.js, repeat.js, of.js, empty.js, chain.js, init.js, indexOf.js,
// lastIndexOf.js, contains.js, containsWith.js, isSet.js, uniq.js,
// uniqWith.js, map.js, mapObj.js, mapIndexed.js, mapObjIndexed.js, find.js,
// findIndex.js, findLast.js, findLastIndex.js, flatten.js, unnest.js,
// range.js, reverse.js, unfold.js, zip.js, zipWith.js, zipObj.js,
// fromPairs.js, xprod.js, partition.js, groupBy.js, createMapEntry.js,
// scan.js, mapAccum.js, mapAccumRight.js, commute.js, commuteMap.js,
// lens.js, mergeAll.js, aperture.js and none.js (v0.9.x unfoldr.js, scanl.js, mapAccumL.js and
// mapAccumR.js; until v0.8.0 test.list.js, test.indexof.js,
// test.containsuniq.js, test.map.js, test.find.js, test.flatten.js,
// test.range.js, test.reverse.js, test.unfold.js, test.zip.js,
// test.product.js, test.partition.js, test.groupBy.js,
// test.createMapEntry.js, test.scanl.js, test.commute.js and test.lens.js),
// transcribed. Arity (`.length`) checks
// have no Dafny counterpart and are omitted, and so are the "throws on zero
// arguments" cases (no-argument calls; v0.11.0 removed them) and the
// `typeof` checks of the "is
// curried" cases, which hold by construction (as does lens's "returns a
// function with `set` and `map` properties": a `Lens` always has its three
// fields; the lens is applied with `.get`, `.set_` and `.map_`, README
// "Deviations"). findLast's and findLastIndex's `(even, 'zing')` search the
// string's characters: here a list of Js strings (since v0.5.0 find and
// findIndex search `['zing']`). indexOf.js and lastIndexOf.js also set a
// non-index property (`arr[-2] = 4`) on their arrays, which a seq cannot
// carry and which indexOf ignores. Not transcribed: flatten's and unnest's
// "is not destructive" (reference inequality), flatten's "handles
// ridiculously large inputs" (its `new Array(1000000)` is a million empty
// slots, which a seq cannot hold) and "handles array-like objects"
// (flatten's and unnest's: an object with a `length` property is not a
// seq); zipObj's "extra keys are undefined" (more keys than values is
// outside the domain, README) and fromPairs's "skips empty Arrays and
// non-Array elements" (the elements are typed pairs, README "Outside the
// modeled domain"); times's "throws if second argument is not a valid array
// length" and init's "throws if applied to null or undefined" (not a nat,
// not a list). toPairs.js and toPairsIn.js test Object functions and are
// transcribed in tests/ramda/object.dfy. (v0.4.1 removed test.list.js's
// describe('nth') with the function, and v0.8.0 test.product.js's
// describe('xprodWith'). v0.9.0 removed the slice.from, indexOf.from and
// lastIndexOf.from describes and lastIndexOf's "from index" cases with the
// functions, and renamed the repeatN, insert.all, map.idx and mapObj.idx
// describes to repeat, insertAll, mapIndexed and mapObjIndexed. v0.10.0
// renamed the unfoldr, scanl, mapAccumL and mapAccumR describes to unfold,
// scan, mapAccum and mapAccumRight.) mergeAll's "ignores inherited
// properties" builds an object with a prototype, which a map cannot have.
// v0.12.0's transducer `it`s (map's "maps simple functions into arrays" and
// "can compose transducer-style", find's, findIndex's, findLast's and
// findLastIndex's `into` cases, groupBy's "dispatches on transformer
// objects") and the dispatch `it`s of map and reduce are not transcribed
// (`into`, transformers and method dispatch, README "Not portable"); nor are
// commute's and commuteMap's "works on Algebraic Data Types such as
// "Maybe"" (a Fantasy-land functor, README "Deviations").

module RamdafTests.Ramda.List {
  import opened Ramdaf.Prelude
  import opened Ramdaf.Core
  import opened Ramdaf.List
  import opened Ramdaf.Data
  import Funcs = Ramdaf.Functions
  import S = Ramdaf.String
  import opened Support

  // ---- join.js, slice.js, remove.js, insert.js, insertAll.js, times.js,
  // repeat.js, of.js, empty.js, chain.js, init.js (test.list.js until
  // v0.8.0) ----

  // describe('join'): the list [1, 2, 3, 4] holds numbers, which JS converts
  // to strings; join takes strings here.
  method {:test} JoinConcatenatesWithASeparator() {
    expect join("~", [NumStr(1), NumStr(2), NumStr(3), NumStr(4)]) == "1~2~3~4";
  }

  // describe('slice') (Ramda's other case is a commented-out TODO)
  method {:test} SliceRetrievesTheProperSublist() {
    expect slice(2, 5, [8, 6, 7, 5, 3, 0, 9]) == [7, 5, 3];
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

  // describe('insertAll') (describe('insert.all') from v0.2.2 to v0.8.0)
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

  // describe('repeat') (describe('repeatN') until v0.8.0)
  method {:test} RepeatReturnsAListOfIdenticalValues() {
    expect repeat(0, 5) == [0, 0, 0, 0, 0];
  }

  method {:test} RepeatCanAcceptAnyValueIncludingNull() {
    expect repeat(Null, 3) == [Null, Null, Null];
  }

  // v0.9.0's `makeFoos = R.repeat('foo')` (until v0.8.0 `nTrues =
  // R.repeatN(true)`)
  method {:test} RepeatIsAutomaticallyCurried() {
    var makeFoos := (n: nat) => repeat("foo", n);
    expect makeFoos(0) == [];
    expect makeFoos(3) == ["foo", "foo", "foo"];
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

  // describe('init') (v0.9.0)
  method {:test} InitReturnsAnEmptyListForAnEmptyList() {
    var empty: seq<string> := [];
    expect init(empty) == [];
  }

  method {:test} InitReturnsAllTheElementsExceptTheLast() {
    expect init(["a", "b", "c", "d"]) == ["a", "b", "c"];
  }

  // ---- indexOf.js, lastIndexOf.js (test.indexof.js from v0.2.2 to v0.8.0)
  // ----

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

  // ---- contains.js, containsWith.js, isSet.js, uniq.js, uniqWith.js
  // (test.containsuniq.js until v0.8.0) ----

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

  // v0.9.0: "is curried like a binary operator, that accepts an inital
  // placeholder": since v0.11.0 `isDigit = contains(__, ['0', …, '9'])`
  // (v0.9.x: `contains(__)(fbb)('bar')`, `contains(__, fbb)('bar')` and
  // `contains(__)(fbb, 'bar')`, with `fbb = ['foo', 'bar', 'baz']`).
  method {:test} ContainsIsCurriedLikeABinaryOperator() {
    var digits := ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"];
    var isDigit := (x: string) => contains(x, digits);
    expect isDigit("0") == true;
    expect isDigit("1") == true;
    expect isDigit("x") == false;
  }

  // describe('containsWith') (v0.9.0's its; the function is older): `eqA`
  // compares the `a` properties
  function Oa(a: int): map<string, int> { map["a" := a] }
  function EqA(r: map<string, int>, t: map<string, int>): bool
  { "a" in r && "a" in t && r["a"] == t["a"] }

  method {:test} ContainsWithDeterminesIfAnElementIsInTheListByThePredicate() {
    var so := [Oa(3), Oa(4), Oa(5), Oa(6)];
    expect containsWith(EqA, Oa(3), so) == true;
    expect containsWith(EqA, Oa(3000), so) == false;
  }

  method {:test} ContainsWithIsCurried() {
    var ro := [Oa(1), Oa(2), Oa(3), Oa(4)];
    var withEqA := (x: map<string, int>) => ((l: seq<map<string, int>>) => containsWith(EqA, x, l));
    expect withEqA(Oa(3))(ro) == true;
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

  // ---- map.js, mapObj.js, mapIndexed.js, mapObjIndexed.js (test.map.js
  // until v0.8.0) ----

  method {:test} MapMapsSimpleFunctions() {
    expect mapSeq((x: int) => x * 2, [1, 2, 3, 4]) == [2, 4, 6, 8];
  }

  method {:test} MapIsAutomaticallyCurried() {
    var inc := (l: seq<int>) => mapSeq((x: int) => x + 1, l);
    expect inc([1, 2, 3]) == [2, 3, 4];
  }

  // v0.12.0: `mdec(mdouble([10, 20, 30]))` with `mdouble = map(times2)`,
  // `mdec = map(dec)`
  method {:test} MapComposes() {
    var mdouble := (l: seq<int>) => mapSeq((x: int) => x * 2, l);
    var mdec := (l: seq<int>) => mapSeq((x: int) => x - 1, l);
    expect mdec(mdouble([10, 20, 30])) == [19, 39, 59];
  }

  // describe('mapObj')
  method {:test} MapObjRunsTheFunctionOverEachProperty() {
    expect mapObj((n: int) => n * n, map["a" := 1, "b" := 2, "c" := 3]) == map["a" := 1, "b" := 4, "c" := 9];
  }

  // describe('mapIndexed') (describe('map.idx') until v0.8.0; v0.9.0 renames
  // `addIdx` to `addIndexed`)
  function addIndexed(x: int, idx: nat, list: seq<int>): int { x + idx }
  function squareEnds(x: int, idx: nat, list: seq<int>): int
  { if idx == 0 || idx == |list| - 1 then x * x else x }

  method {:test} MapIndexedWorksJustLikeANormalMap() {
    expect mapIndexed((x: int, idx: nat, list: seq<int>) => x * 2, [1, 2, 3, 4]) == [2, 4, 6, 8];
  }

  method {:test} MapIndexedPassesTheIndexAsASecondParameter() {
    expect mapIndexed(addIndexed, [8, 6, 7, 5, 3, 0, 9]) == [8 + 0, 6 + 1, 7 + 2, 5 + 3, 3 + 4, 0 + 5, 9 + 6];
  }

  method {:test} MapIndexedPassesTheEntireListAsAThirdParameter() {
    expect mapIndexed(squareEnds, [8, 6, 7, 5, 3, 0, 9]) == [64, 6, 7, 5, 3, 0, 81];
  }

  method {:test} MapIndexedIsAutomaticallyCurried() {
    var makeSquareEnds := (l: seq<int>) => mapIndexed(squareEnds, l);
    expect makeSquareEnds([8, 6, 7, 5, 3, 0, 9]) == [64, 6, 7, 5, 3, 0, 81];
  }

  // describe('mapObjIndexed') (describe('mapObj.idx') from v0.2.2 to v0.8.0)
  function Vowelly(): map<string, int> { map["a" := 8, "b" := 6, "c" := 7, "d" := 5, "e" := 3, "f" := 0, "g" := 9] }
  function squareVowels(x: int, key: string, obj: map<string, int>): int
  { if key in ["a", "e", "i", "o", "u"] then x * x else x }

  method {:test} MapObjIndexedWorksJustLikeANormalMapObj() {
    expect mapObjIndexed((x: int, k: string, o: map<string, int>) => x * 2, map["a" := 1, "b" := 2, "c" := 3, "d" := 4]) ==
      map["a" := 2, "b" := 4, "c" := 6, "d" := 8];
  }

  // `x + key` concatenates the number and the key as strings.
  method {:test} MapObjIndexedPassesTheKeyAsASecondParameter() {
    expect mapObjIndexed((x: int, k: string, o: map<string, int>) => NumStr(x) + k, Vowelly()) ==
      map["a" := "8a", "b" := "6b", "c" := "7c", "d" := "5d", "e" := "3e", "f" := "0f", "g" := "9g"];
  }

  method {:test} MapObjIndexedPassesTheEntireObjectAsAThirdParameter() {
    expect mapObjIndexed(squareVowels, Vowelly()) ==
      map["a" := 64, "b" := 6, "c" := 7, "d" := 5, "e" := 9, "f" := 0, "g" := 9];
  }

  method {:test} MapObjIndexedIsAutomaticallyCurried() {
    var makeSquareVowels := (o: map<string, int>) => mapObjIndexed(squareVowels, o);
    expect makeSquareVowels(Vowelly()) == map["a" := 64, "b" := 6, "c" := 7, "d" := 5, "e" := 9, "f" := 0, "g" := 9];
  }

  // ---- find.js, findIndex.js, findLast.js, findLastIndex.js (test.find.js)
  // ----

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

  // ---- flatten.js, unnest.js (test.flatten.js) ----

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

  // ---- range.js ----

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

  // ---- reverse.js ----

  method {:test} ReverseReversesArrays() {
    expect reverse([1, 2, 3, 4]) == [4, 3, 2, 1];
  }

  method {:test} ReverseOfTheEmptyList() {
    var empty: seq<int> := [];
    expect reverse(empty) == [];
  }

  // ---- unfold.js (v0.10.0; unfoldr.js in v0.9.x, test.unfold.js until
  // v0.8.0; unfold takes a fuel bound, see README) ----

  // describe('unfold') (describe('unfoldr') until v0.9.1)
  method {:test} UnfoldUnfoldsFromASeed() {
    expect unfold((n: int) => if n > 0 then Some((n, n - 1)) else None, 10, 100) ==
      [10, 9, 8, 7, 6, 5, 4, 3, 2, 1];
  }

  // "should just be cool!": the JS generator counts its calls in a closure;
  // the count is threaded through the seed instead.
  method {:test} UnfoldFibonacci() {
    var fib := (s: (int, (int, int))) =>
      if s.0 < 10 then Some((s.1.0, (s.0 + 1, (s.1.1, s.1.0 + s.1.1)))) else None;
    expect unfold(fib, (0, (0, 1)), 100) == [0, 1, 1, 2, 3, 5, 8, 13, 21, 34];
  }

  // ---- zip.js, zipWith.js, zipObj.js, fromPairs.js (test.zip.js) ----

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

  // ---- createMapEntry.js (v0.7.0; until v0.8.0 test.createMapEntry.js, whose
  // describe was 'mapEntry') ----

  method {:test} CreateMapEntryCreatesAnObjectContainingASingleKeyValuePair() {
    expect createMapEntry("foo", 42) == map["foo" := 42];
  }

  method {:test} CreateMapEntryIsAutomaticallyCurried() {
    var foo := (v: int) => createMapEntry("foo", v);
    expect foo(42) == map["foo" := 42];
  }

  // ---- scan.js (v0.10.0; scanl.js from v0.7.0 to v0.9.1). Not
  // transcribed: "correctly reports the arity of curried versions" and the
  // two no-argument cases. ----

  // describe('scan') (describe('scanl') until v0.9.1)

  method {:test} ScanScansSimpleFunctionsWithTheSuppliedAccumulator() {
    expect scan((a: int, b: int) => a + b, 0, [1, 2, 3, 4]) == [0, 1, 3, 6, 10];
    expect scan((a: int, b: int) => a * b, 1, [1, 2, 3, 4]) == [1, 1, 2, 6, 24];
  }

  method {:test} ScanReturnsTheAccumulatorForAnEmptyArray() {
    var empty: seq<int> := [];
    expect scan((a: int, b: int) => a + b, 0, empty) == [0];
    expect scan((a: int, b: int) => a * b, 1, empty) == [1];
  }

  // `scan(add)` with JS `+`: numbers and strings
  method {:test} ScanIsAutomaticallyCurried() {
    var sum := (l: seq<int>) => scan((a: int, b: int) => a + b, 0, l);
    expect sum([1, 2, 3, 4]) == [0, 1, 3, 6, 10];
    var cat := (l: seq<string>) => scan((a: string, b: string) => a + b, "", l);
    expect cat(["1", "2", "3", "4"]) == ["", "1", "12", "123", "1234"];
  }

  // ---- mapAccum.js, mapAccumRight.js (v0.10.0; mapAccumL.js and
  // mapAccumR.js in v0.9.x). Not transcribed: "correctly reports the arity
  // of curried versions" and the no-argument cases. ----

  // `add(a, b) = [a + b, a + b]`, `mult(a, b) = [a * b, a * b]`, `concat(a,
  // b) = [a.concat(b), a.concat(b)]`: the two-element arrays are pairs.
  function AccAdd(a: int, b: int): (int, int) { (a + b, a + b) }
  function AccMult(a: int, b: int): (int, int) { (a * b, a * b) }
  function AccCat(a: string, b: string): (string, string) { (a + b, a + b) }

  // describe('mapAccum') (describe('mapAccumL') until v0.9.1)
  method {:test} MapAccumMapsAndAccumulatesSimpleFunctions() {
    expect mapAccum(AccAdd, 0, [1, 2, 3, 4]) == (10, [1, 3, 6, 10]);
    expect mapAccum(AccMult, 1, [1, 2, 3, 4]) == (24, [1, 2, 6, 24]);
  }

  method {:test} MapAccumReturnsTheListAndAccumulatorForAnEmptyArray() {
    var empty: seq<int> := [];
    expect mapAccum(AccAdd, 0, empty) == (0, []);
    expect mapAccum(AccMult, 1, empty) == (1, []);
    var noLists: seq<seq<int>> := [];
    var none: seq<int> := [];
    expect mapAccum((a: seq<int>, b: seq<int>) => (a + b, a + b), none, noLists) == ([], []);
  }

  // `addOrConcat = mapAccum(add)` applied to 0 and to '' (JS `+` on strings)
  method {:test} MapAccumIsAutomaticallyCurried() {
    var sum := (l: seq<int>) => mapAccum(AccAdd, 0, l);
    var cat := (l: seq<string>) => mapAccum(AccCat, "", l);
    expect sum([1, 2, 3, 4]) == (10, [1, 3, 6, 10]);
    expect cat(["1", "2", "3", "4"]) == ("1234", ["1", "12", "123", "1234"]);
  }

  // describe('mapAccumRight') (describe('mapAccumR') until v0.9.1)
  method {:test} MapAccumRightMapsAndAccumulatesSimpleFunctions() {
    expect mapAccumRight(AccAdd, 0, [1, 2, 3, 4]) == (10, [10, 9, 7, 4]);
    expect mapAccumRight(AccMult, 1, [1, 2, 3, 4]) == (24, [24, 24, 12, 4]);
  }

  // The third case folds with `R.concat`, which returns one list, not a pair;
  // on an empty list fn is never called, so the result is `[[], []]`, here
  // with a pair-returning concatenation.
  method {:test} MapAccumRightReturnsTheListAndAccumulatorForAnEmptyArray() {
    var empty: seq<int> := [];
    expect mapAccumRight(AccAdd, 0, empty) == (0, []);
    expect mapAccumRight(AccMult, 1, empty) == (1, []);
    var noLists: seq<seq<int>> := [];
    var none: seq<int> := [];
    expect mapAccumRight((a: seq<int>, b: seq<int>) => (a + b, a + b), none, noLists) == ([], []);
  }

  method {:test} MapAccumRightIsAutomaticallyCurried() {
    var sum := (l: seq<int>) => mapAccumRight(AccAdd, 0, l);
    var cat := (l: seq<string>) => mapAccumRight(AccCat, "", l);
    expect sum([1, 2, 3, 4]) == (10, [10, 9, 7, 4]);
    expect cat(["1", "2", "3", "4"]) == ("4321", ["4321", "432", "43", "4"]);
  }

  // ---- mergeAll.js (v0.10.0) ----

  method {:test} MergeAllMergesAListOfObjectsTogetherIntoOneObject() {
    expect mergeAll([map["foo" := 1], map["bar" := 2], map["baz" := 3]]) == map["foo" := 1, "bar" := 2, "baz" := 3];
  }

  method {:test} MergeAllGivesPrecedenceToLaterObjectsInTheList() {
    expect mergeAll([map["foo" := 1], map["foo" := 2], map["bar" := 2]]) == map["foo" := 2, "bar" := 2];
  }

  // ---- aperture.js (v0.12.0) ----

  function SevenLs(): seq<int> { [1, 2, 3, 4, 5, 6, 7] }

  method {:test} ApertureCreatesAListOfNTuplesFromAList() {
    expect aperture(1, SevenLs()) == [[1], [2], [3], [4], [5], [6], [7]];
    expect aperture(2, SevenLs()) == [[1, 2], [2, 3], [3, 4], [4, 5], [5, 6], [6, 7]];
    expect aperture(3, SevenLs()) == [[1, 2, 3], [2, 3, 4], [3, 4, 5], [4, 5, 6], [5, 6, 7]];
    expect aperture(4, [1, 2, 3, 4]) == [[1, 2, 3, 4]];
  }

  method {:test} ApertureReturnsAnEmptyListWhenNExceedsTheLength() {
    var empty: seq<int> := [];
    expect aperture(6, [1, 2, 3]) == [];
    expect aperture(1, empty) == [];
  }

  method {:test} ApertureIsAutomaticallyCurried() {
    var pairwise := (l: seq<int>) => aperture(2, l);
    expect pairwise(SevenLs()) == [[1, 2], [2, 3], [3, 4], [4, 5], [5, 6], [6, 7]];
  }

  // ---- none.js (v0.12.0) ----

  function even(n: int): bool { n % 2 == 0 }

  method {:test} NoneReturnsTrueIfNoElementsSatisfyThePredicate() {
    expect none(even, [1, 3, 5, 7, 9, 11]) == true;
  }

  method {:test} NoneReturnsFalseIfAnyElementSatisfiesThePredicate() {
    expect none(even, [1, 3, 5, 7, 8, 11]) == false;
  }

  method {:test} NoneReturnsTrueForAnEmptyList() {
    var empty: seq<int> := [];
    expect none((x: int) => true, empty) == true;
  }

  // `{x: 'abcd'}` and the like; `o.x.indexOf('a') >= 0` is `'a' in o.x`
  method {:test} NoneWorksWithMoreComplexObjects() {
    var xs := [map["x" := "abcd"], map["x" := "adef"], map["x" := "fghiajk"]];
    var len3 := (o: map<string, string>) => "x" in o && |o["x"]| == 3;
    var hasA := (o: map<string, string>) => "x" in o && 'a' in o["x"];
    expect none(len3, xs) == true;
    expect none(hasA, xs) == false;
  }

  method {:test} NoneIsAutomaticallyCurried() {
    var noneEven := (l: seq<int>) => none(even, l);
    expect noneEven([1, 3, 5, 6, 7, 9]) == false;
  }

  // ---- xprod.js (test.product.js) ----

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

  // ---- commute.js, commuteMap.js (v0.8.0; test.commute.js until v0.8.0) ----

  function As(): seq<seq<int>> { [[1], [3, 4]] }
  function Bs(): seq<seq<int>> { [[1, 2], [3]] }
  function Cs(): seq<seq<int>> { [[1, 2], [3, 4]] }

  // describe('commute'): `R.of` is List.of
  method {:test} CommutePivotsAList() {
    expect commute(of, As()) == [[1, 3], [1, 4]];
    expect commute(of, Bs()) == [[1, 3], [2, 3]];
    expect commute(of, Cs()) == [[1, 3], [2, 3], [1, 4], [2, 4]];
  }

  method {:test} CommuteIsCurried() {
    var cmtArr := (l: seq<seq<int>>) => commute(of, l);
    expect cmtArr(As()) == [[1, 3], [1, 4]];
    expect cmtArr(Bs()) == [[1, 3], [2, 3]];
    expect cmtArr(Cs()) == [[1, 3], [2, 3], [1, 4], [2, 4]];
  }

  // describe('commuteMap'): `plus10map = R.map(x => x + 10)`
  function Plus10Map(xs: seq<int>): seq<int> { mapSeq((x: int) => x + 10, xs) }

  method {:test} CommuteMapPivotsAListAndAppliesATransformation() {
    expect commuteMap(Plus10Map, of, As()) == [[11, 13], [11, 14]];
    expect commuteMap(Plus10Map, of, Bs()) == [[11, 13], [12, 13]];
    expect commuteMap(Plus10Map, of, Cs()) == [[11, 13], [12, 13], [11, 14], [12, 14]];
  }

  // `cmtPlus10 = commuteMap(plus10map)`, `cmtmArr = cmtPlus10(R.of)`
  method {:test} CommuteMapIsCurried() {
    var cmtPlus10 := (o: seq<int> -> seq<seq<int>>) => ((l: seq<seq<int>>) => commuteMap(Plus10Map, o, l));
    var cmtmArr := cmtPlus10(of);
    expect cmtmArr(As()) == [[11, 13], [11, 14]];
    expect cmtmArr(Bs()) == [[11, 13], [12, 13]];
    expect cmtmArr(Cs()) == [[11, 13], [12, 13], [11, 14], [12, 14]];
  }

  // ---- lens.js (v0.8.0) ----

  // `getHead(obj) = obj[0]` (undefined for []), `setHead(val, obj) =
  // [val].concat(obj.slice(1))`; the lists mix numbers and strings, so they
  // hold Js values.
  function GetHead(o: seq<Js>): Js { if |o| > 0 then o[0] else Undefined }
  function SetHead(v: Js, o: seq<Js>): seq<Js> { [v] + (if |o| > 0 then o[1..] else []) }
  function HeadOf(): Lens<seq<Js>, Js> { lens(GetHead, SetHead) }

  // `getPhrase(obj) = obj.catchphrase`, `setPhrase(val, obj)` sets it on
  // `R.clone(obj)` (`R.cloneObj(obj)` until v0.8.0)
  function GetPhrase(o: map<string, Js>): Js { if "catchphrase" in o then o["catchphrase"] else Undefined }
  function SetPhrase(v: Js, o: map<string, Js>): map<string, Js> { clone(o)["catchphrase" := v] }
  function PhraseLens(): Lens<map<string, Js>, Js> { lens(GetPhrase, SetPhrase) }

  function Nums(ns: seq<int>): seq<Js> { mapSeq((n: int) => Num(n), ns) }
  function PhraseObj(): map<string, Js> { map["x" := Num(100), "y" := Num(200), "catchphrase" := Str("zing!")] }

  method {:test} LensRetrievesValuesAsDefinedByTheGetter() {
    expect HeadOf().get(Nums([10, 20, 30, 40])) == Num(10);
    expect HeadOf().get([Str("a"), Str("b"), Str("c"), Str("d")]) == Str("a");
  }

  method {:test} LensSetsPropertiesAndReturnsTheNewObject() {
    expect HeadOf().set_(Str("cow"), Nums([1, 2, 3, 4])) == [Str("cow"), Num(2), Num(3), Num(4)];
  }

  // The second assertion holds trivially: obj is a value.
  method {:test} LensTheSetterNeedNotMutateTheObject() {
    var obj := PhraseObj();
    expect PhraseLens().set_(Str("kapow!"), obj) == map["x" := Num(100), "y" := Num(200), "catchphrase" := Str("kapow!")];
    expect obj == map["x" := Num(100), "y" := Num(200), "catchphrase" := Str("zing!")];
  }

  method {:test} LensMapsAPropertyFromGetterToSetter() {
    var plus10 := (x: Js) => if x.Num? then Num(x.n + 10) else x;
    expect HeadOf().map_(plus10, Nums([-9, 2, 3])) == Nums([1, 2, 3]);
  }

  // `uc(s) = s.toUpperCase()`
  method {:test} LensTheModifierNeedNotMutateTheObject() {
    var obj := PhraseObj();
    var uc := (s: Js) => if s.Str? then Str(S.toUpper(s.s)) else s;
    expect PhraseLens().map_(uc, obj) == map["x" := Num(100), "y" := Num(200), "catchphrase" := Str("ZING!")];
    expect obj == map["x" := Num(100), "y" := Num(200), "catchphrase" := Str("zing!")];
  }

  // `get1(x) = x[1]`; `set1(val, obj)` replaces element 1 by
  // `obj.concat().splice(1, 1, val)` (appended to a shorter list); `partial =
  // R.lens(get1)`
  function Get1(o: seq<Js>): Js { if |o| > 1 then o[1] else Undefined }
  function Set1(v: Js, o: seq<Js>): seq<Js> { if |o| > 1 then o[1 := v] else o + [v] }

  method {:test} LensIsCurried() {
    var partial := (s: (Js, seq<Js>) -> seq<Js>) => lens(Get1, s);
    expect partial(Set1).get([Str("zeroth"), Str("first"), Str("second")]) == Str("first");
    expect partial(Set1).get(Nums([10, 20, 30])) == Num(20);
    expect partial(Set1).set_(Str("zoom"), Nums([10, 20, 30])) == [Num(10), Str("zoom"), Num(30)];
    var x2 := (x: Js) => if x.Num? then Num(x.n * 2) else x;
    expect partial(Set1).map_(x2, Nums([10, 20, 30])) == Nums([10, 40, 30]);
    // v0.9.0: `set` and `map` are curried, `.set('zoom')(…)` and `.map(x2)(…)`
    var setZoom := (o: seq<Js>) => partial(Set1).set_(Str("zoom"), o);
    expect setZoom(Nums([10, 20, 30])) == [Num(10), Str("zoom"), Num(30)];
    var mapX2 := (o: seq<Js>) => partial(Set1).map_(x2, o);
    expect mapX2(Nums([10, 20, 30])) == Nums([10, 40, 30]);
  }

  // v0.9.0: "curries map and set and modifies with composed lens":
  // `compose(headOf.map(add(1)), headOf.map(add(2)))`,
  // `compose(headOf.map(add(1)), headOf.set(0))` and `map` of the first
  function AddJs(k: int): Js -> Js { (x: Js) => if x.Num? then Num(x.n + k) else x }

  method {:test} LensCurriesMapAndSetAndModifiesWithComposedLens() {
    var headPlus3 := Funcs.compose((o: seq<Js>) => HeadOf().map_(AddJs(1), o), (o: seq<Js>) => HeadOf().map_(AddJs(2), o));
    expect headPlus3(Nums([-2, 2, 3])) == Nums([1, 2, 3]);
    var set0Plus1 := Funcs.compose((o: seq<Js>) => HeadOf().map_(AddJs(1), o), (o: seq<Js>) => HeadOf().set_(Num(0), o));
    expect set0Plus1(Nums([-2, 2, 3])) == Nums([1, 2, 3]);
    var mapHeadPlus3 := (l: seq<seq<Js>>) => mapSeq(headPlus3, l);
    expect mapHeadPlus3([Nums([-2, 2, 3]), Nums([-1, 2, 3])]) == [Nums([1, 2, 3]), Nums([2, 2, 3])];
  }


  // ---- partition.js (v0.3.0: partition splits a list by a predicate; its
  // v0.1.4 to v0.2.4 grouping tests moved to groupBy's file, below) ----

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

  // ---- groupBy.js (v0.3.0; test.partition.js's tests until v0.2.4) ----

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
