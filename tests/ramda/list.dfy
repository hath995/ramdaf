// Ramda v0.21.0 test/join.js, slice.js, remove.js, insert.js, insertAll.js,
// times.js, repeat.js, of.js, empty.js, chain.js, init.js, indexOf.js,
// lastIndexOf.js, contains.js, allUniq.js, uniq.js, uniqWith.js, map.js,
// mapObjIndexed.js, find.js, findIndex.js, findLast.js, findLastIndex.js,
// flatten.js, unnest.js, range.js, reverse.js, unfold.js, zip.js,
// zipWith.js, zipObj.js, fromPairs.js, xprod.js, partition.js, groupBy.js,
// scan.js, mapAccum.js, mapAccumRight.js,
// mergeAll.js, aperture.js, none.js, adjust.js, update.js,
// intersperse.js, dropRepeats.js, dropRepeatsWith.js, splitEvery.js,
// uniqBy.js, pair.js, indexBy.js, sequence.js, traverse.js, splitAt.js,
// splitWhen.js, transpose.js, without.js, lensIndex.js, reduceBy.js and
// groupWith.js (v0.9.x unfoldr.js, scanl.js, mapAccumL.js and
// mapAccumR.js; until v0.8.0 test.list.js, test.indexof.js,
// test.containsuniq.js, test.map.js, test.find.js, test.flatten.js,
// test.range.js, test.reverse.js, test.unfold.js, test.zip.js,
// test.product.js, test.partition.js, test.groupBy.js,
// test.createMapEntry.js, test.scanl.js, test.commute.js and test.lens.js),
// transcribed. Arity (`.length`) checks
// have no Dafny counterpart and are omitted, and so are the "throws on zero
// arguments" cases (no-argument calls; v0.11.0 removed them) and the
// `typeof` checks of the "is
// curried" cases, which hold by construction. (v0.16.0 removed lens.js,
// lensIndex.js and mapIndexed.js; the lenses' tests are lenses.js's, in
// tests/ramda/object.dfy.) findLast's and findLastIndex's `(even, 'zing')` search the
// string's characters: here a list of Js strings (since v0.5.0 find and
// findIndex search `['zing']`). indexOf.js and lastIndexOf.js also set a
// non-index property (`arr[-2] = 4`) on their arrays, which a seq cannot
// carry and which indexOf ignores. Not transcribed: flatten's and unnest's
// "is not destructive" (reference inequality), flatten's "handles
// ridiculously large inputs" (its `new Array(1000000)` is a million empty
// slots, which a seq cannot hold) and "handles array-like objects"
// (flatten's and unnest's: an object with a `length` property is not a
// seq); zipObj's "extra keys are undefined" (until v0.19.1: more keys than
// values was outside the domain; v0.20.0's "ignores extra keys" is
// transcribed) and fromPairs's "skips empty Arrays and
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
// (`into`, transformers and method dispatch, README "Not portable"); nor were
// commute's and commuteMap's "works on Algebraic Data Types such as
// "Maybe"" (a Fantasy-land functor, README "Deviations"). v0.14.0's "has
// Object.is semantics" `it`s of contains, indexOf, lastIndexOf and isSet
// test `-0` and NaN, which an int does not have (README "Deviations",
// pinned in tests/edge/list.dfy), and v0.15.0's "has R.equals semantics"
// `it`s of contains, isSet (allUniq's since v0.18.0), uniq and dropRepeats (`-0`, NaN and objects
// with an `equals` method; v0.15.1 adds uniq's `[[1], [1]]` line, which is
// transcribed alone), chain's transducer, dispatch and arity `it`s,
// and reduced.js (transducers, README "Not portable"); adjust's and update's "accepts an
// array-like object" pass an `arguments` object; intersperse's "dispatches"
// (method dispatch) and the "can act as a transducer" `it`s of dropRepeats
// and dropRepeatsWith (`into`) are not transcribed either, and the `typeof`
// check of dropRepeatsWith's "is curried" holds by construction. v0.18.0's
// functor `it`s are not transcribed either: map's "maps over objects" and
// "interprets ((->) r) as a functor", chain's "interprets ((->) r) as a
// monad", unnest's "is equivalent to R.chain(R.identity)" (a `Maybe`) and
// empty's arguments object (the port's functions take lists, README
// "Deviations"), nor are aperture's "can act as a transducer" and
// commute's and commuteMap's "traverses left to right" (sanctuary's
// `Either`; v0.20.0 removed commute.js and commuteMap.js with the
// functions). (v0.18.0 renamed isSet.js to allUniq.js with the function, and
// rewrote containsWith.js, without its "is curried", and reverse.js;
// v0.19.0 removed containsWith.js, createMapEntry.js and mapObj.js with the
// functions.) v0.19.0's new files: indexBy's key function `prop('id')` is a
// total function on the test objects here; sequence's and traverse's
// "operates on a list of applicatives", "traverses left to right" and
// "dispatches to `sequence` method" use sanctuary's Maybe and Either and an
// `Id` object (README "Deviations"), and without's "can act as a
// transducer" (`into`) and "has R.equals semantics" (`-0`, NaN, `Just`;
// its `[[1]]` line is transcribed alone) are not transcribed; transpose's
// mixed and null/undefined rows are Js values; lensIndex.js's "returns
// undefined if the specified index does not exist" is outside the lens's
// domain (README "Outside the modeled domain"), and its "can be composed"
// nests a list inside a list of numbers, which one element type cannot
// hold; its other `it`s run over Js values, as `set` stores a number among
// objects. Not transcribed either: the "filters objects" `it`s of filter
// and reject (a list here, README "Deviations"), and the "finds function,
// compared by identity" `it`s of indexOf and lastIndexOf (Dafny functions
// have no equality). v0.20.0's partition's "works with objects" and "works
// with other filterables" (an object and a sanctuary `Just`: a list here,
// README "Deviations") and reduceBy's "correctly reports the arity of
// curried versions" are not transcribed; reduceBy's students and `{type,
// val}` records are groupBy's (v0.21.0 moves its key function third).
// groupWith.js's (v0.21.0) `R.equals` is `==`, `R.complement(R.equals)`,
// `R.T` and `R.F` are binary lambdas, and `R.unnest` of the groups is
// `chain(identity)` (since v0.18.0), here `chain(g => g, …)`.

module RamdafTests.Ramda.List {
  import opened Ramdaf.Prelude
  import opened Ramdaf.Core
  import opened Ramdaf.List
  import opened Ramdaf.Data
  import Funcs = Ramdaf.Functions
  import S = Ramdaf.String
  import O = Ramdaf.Object
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

  // v0.16.0 (in place of v0.15.0's "dispatches to `slice` method", an
  // object with a `slice` method): a JS string gives a string, the same seq
  // here; JS's `-0` index is 0
  method {:test} SliceCanOperateOnStrings() {
    expect slice(0, 0, "abc") == "";
    expect slice(0, 1, "abc") == "a";
    expect slice(0, 2, "abc") == "ab";
    expect slice(0, 3, "abc") == "abc";
    expect slice(0, 4, "abc") == "abc";
    expect slice(1, 0, "abc") == "";
    expect slice(1, 1, "abc") == "";
    expect slice(1, 2, "abc") == "b";
    expect slice(1, 3, "abc") == "bc";
    expect slice(1, 4, "abc") == "bc";
    expect slice(0, -4, "abc") == "";
    expect slice(0, -3, "abc") == "";
    expect slice(0, -2, "abc") == "a";
    expect slice(0, -1, "abc") == "ab";
    expect slice(0, 0, "abc") == "";
    expect slice(-2, -4, "abc") == "";
    expect slice(-2, -3, "abc") == "";
    expect slice(-2, -2, "abc") == "";
    expect slice(-2, -1, "abc") == "b";
    expect slice(-2, 0, "abc") == "";
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

  // describe('empty') (v0.3.0): v0.16.0's "returns empty array given array"
  // ("returns an empty list" until v0.15.1) and the first line of "returns
  // empty string given string" (a string is a seq; `new String('abc')` is
  // not)
  method {:test} EmptyReturnsEmptyArrayGivenArray() {
    expect empty([1, 2, 3]) == [];
  }

  method {:test} EmptyReturnsEmptyStringGivenString() {
    expect empty("abc") == "";
  }

  // describe('chain') (v0.3.0; v0.15.0 rewrote chain.js): `times2(x) = [x *
  // 2]`, `add1(x) = [x + 1]`, `dec(x) = [x - 1]`. (Until v0.14.0 the first
  // `it` mapped `dbl = map(multiply(2))` over a list of lists.)
  function Times2(x: int): seq<int> { [x * 2] }
  method {:test} ChainMapsAFunctionOverANestedListAndFlattensTheResult() {
    expect chain(Times2, [1, 2, 3, 1, 0, 10, -3, 5, 7]) == [2, 4, 6, 2, 0, 20, -6, 10, 14];
    expect chain(Times2, [1, 2, 3]) == [2, 4, 6];
  }

  // v0.15.0: `f(xs) = xs[0] ? [xs[0]] : []` over `[[1], [[2], 100], [], [3,
  // [4]]]`, Js values (`xs[0]` of [] is undefined, falsy)
  method {:test} ChainDoesNotFlattenRecursively() {
    var f := (xs: Js) => if xs.Arr? && |xs.items| > 0 && Truthy(xs.items[0]) then [xs.items[0]] else [];
    expect chain(f, [Arr([Num(1)]), Arr([Arr([Num(2)]), Num(100)]), Arr([]), Arr([Num(3), Arr([Num(4)])])]) ==
      [Num(1), Arr([Num(2)]), Num(3)];
  }

  // v0.15.0: `mdec(mdouble([10, 20, 30]))` with `mdouble = R.chain(times2)`,
  // `mdec = R.chain(dec)`
  method {:test} ChainComposes() {
    var mdouble := (l: seq<int>) => chain(Times2, l);
    var mdec := (l: seq<int>) => chain((x: int) => [x - 1], l);
    expect mdec(mdouble([10, 20, 30])) == [19, 39, 59];
  }

  // v0.15.0: `flatInc = R.chain(add1)`
  method {:test} ChainIsCurried() {
    var flatInc := (l: seq<int>) => chain((x: int) => [x + 1], l);
    expect flatInc([1, 2, 3, 4, 5, 6]) == [2, 3, 4, 5, 6, 7];
  }

  // describe('init') (v0.9.0): v0.16.0's "returns all but the last element
  // of an ordered collection" (until v0.15.1 "returns an empty list for an
  // empty list" and "returns a new list containing all the elements except
  // the last element of a list")
  method {:test} InitReturnsAllButTheLastElementOfAnOrderedCollection() {
    var empty: seq<int> := [];
    expect init([1, 2, 3]) == [1, 2];
    expect init([2, 3]) == [2];
    expect init([3]) == [];
    expect init(empty) == [];
    expect init("abc") == "ab";
    expect init("bc") == "b";
    expect init("c") == "";
    expect init("") == "";
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

  // v0.15.0 "dispatches to `indexOf` method" and "… `lastIndexOf` method":
  // their string lines (a JS string's own method, here the seq of
  // characters); the `List` objects with methods are not lists
  method {:test} IndexOfDispatchesToIndexOfMethod() {
    expect indexOf('a', "banana") == 1;
    expect indexOf('x', "banana") == -1;
  }

  method {:test} LastIndexOfDispatchesToLastIndexOfMethod() {
    expect lastIndexOf('a', "banana") == 5;
    expect lastIndexOf('x', "banana") == -1;
  }

  // "returns -1 for an empty array": since v0.19.0 `lastIndexOf('x', [])`
  // (from v0.5.0 to v0.18.0 `lastIndexOf('x', 2, [])` and `lastIndexOf('x',
  // -5, [])`, three arguments to the binary curried function, so JS searched
  // the number 2 (or -5) as the list and got -1; this line was transcribed
  // as their evident intent, the empty list, with the same -1).
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

  // describe('allUniq') (v0.18.0; describe('isSet') until v0.17.1)
  method {:test} AllUniqTrueIfTheListHasUniqueElements() {
    expect allUniq([1, 2, 3, 1, 2, 3, 1, 2, 3]) == false;
    expect allUniq([3, 1, 4, 2, 5, 7, 9]) == true;
  }

  method {:test} AllUniqTrueForAnEmptyArray() {
    var empty: seq<int> := [];
    expect allUniq(empty) == true;
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

  // v0.15.0: `uniq([undefined, null, undefined, null])`
  method {:test} UniqHandlesNullAndUndefinedElements() {
    expect uniq([Undefined, Null, Undefined, Null]) == [Undefined, Null];
  }

  // "has R.equals semantics" (v0.15.0): v0.15.1's line `R.uniq([[1],
  // [1]]).length === 1` (deep equality: `uniq` is `uniqWith(equals)` again;
  // in v0.15.0 its `Set` kept both arrays). The `-0`, NaN and `Just` lines
  // cannot be written (README "Deviations").
  method {:test} UniqHasREqualsSemantics() {
    expect |uniq([[1], [1]])| == 1;
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

  // (v0.18.0 rewrote "reverses arrays", which had `[1, 2, 3, 4]`, and
  // folded "returns the empty list to itself" into it)
  method {:test} ReverseReversesArrays() {
    var empty: seq<int> := [];
    expect reverse(empty) == [];
    expect reverse([1]) == [1];
    expect reverse([1, 2]) == [2, 1];
    expect reverse([1, 2, 3]) == [3, 2, 1];
  }

  // v0.18.0: a JS string gives a string, the same seq here
  method {:test} ReverseReversesStrings() {
    expect reverse("") == "";
    expect reverse("a") == "a";
    expect reverse("ab") == "ba";
    expect reverse("abc") == "cba";
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

  // v0.20.0 (until v0.19.1 "extra keys are undefined", outside the domain)
  method {:test} ZipObjIgnoresExtraKeys() {
    expect zipObj(["a", "b", "c", "d", "e", "f"], [1, 2, 3]) == map["a" := 1, "b" := 2, "c" := 3];
  }

  method {:test} ZipObjLastOneInWinsWhenThereAreDuplicateKeys() {
    expect zipObj(["a", "b", "c", "a"], [Num(1), Num(2), Num(3), Str("LAST")]) ==
      map["a" := Str("LAST"), "b" := Num(2), "c" := Num(3)];
  }

  // describe('fromPairs') (v0.3.0)
  method {:test} FromPairsCombinesTwoElementArraysIntoAnObject() {
    expect fromPairs([("a", 1), ("b", 2), ("c", 3)]) == map["a" := 1, "b" := 2, "c" := 3];
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

  // ---- adjust.js, update.js, intersperse.js, dropRepeats.js and
  // dropRepeatsWith.js (v0.14.0) ----

  // `R.add(1)` is `x => x + 1`.
  method {:test} AdjustAppliesTheGivenFunctionToTheValueAtTheGivenIndex() {
    expect adjust((x: int) => x + 1, 2, [0, 1, 2, 3]) == [0, 1, 3, 3];
  }

  method {:test} AdjustOffsetsNegativeIndexesFromTheEndOfTheArray() {
    expect adjust((x: int) => x + 1, -3, [0, 1, 2, 3]) == [0, 2, 2, 3];
  }

  method {:test} AdjustReturnsTheOriginalArrayIfTheSuppliedIndexIsOutOfBounds() {
    var list := [0, 1, 2, 3];
    expect adjust((x: int) => x + 1, 4, list) == list;
    expect adjust((x: int) => x + 1, -5, list) == list;
  }

  // The second assertion holds trivially: list is a value.
  method {:test} AdjustDoesNotMutateTheOriginalArray() {
    var list := [0, 1, 2, 3];
    expect adjust((x: int) => x + 1, 2, list) == [0, 1, 3, 3];
    expect list == [0, 1, 2, 3];
  }

  // `R.adjust(R.add(1))(2)([0, 1, 2, 3])`
  method {:test} AdjustCurriesTheArguments() {
    var f := (idx: int) => (l: seq<int>) => adjust((x: int) => x + 1, idx, l);
    expect f(2)([0, 1, 2, 3]) == [0, 1, 3, 3];
  }

  method {:test} UpdateUpdatesTheValueAtTheGivenIndexOfTheSuppliedArray() {
    expect update(2, 4, [0, 1, 2, 3]) == [0, 1, 4, 3];
  }

  method {:test} UpdateOffsetsNegativeIndexesFromTheEndOfTheArray() {
    expect update(-3, 4, [0, 1, 2, 3]) == [0, 4, 2, 3];
  }

  method {:test} UpdateReturnsTheOriginalArrayIfTheSuppliedIndexIsOutOfBounds() {
    var list := [0, 1, 2, 3];
    expect update(4, 4, list) == list;
    expect update(-5, 4, list) == list;
  }

  method {:test} UpdateDoesNotMutateTheOriginalArray() {
    var list := [0, 1, 2, 3];
    expect update(2, 4, list) == [0, 1, 4, 3];
    expect list == [0, 1, 2, 3];
  }

  // `R.update(2)(4)([0, 1, 2, 3])`
  method {:test} UpdateCurriesTheArguments() {
    var f := (idx: int) => (x: int) => (l: seq<int>) => update(idx, x, l);
    expect f(2)(4)([0, 1, 2, 3]) == [0, 1, 4, 3];
  }

  method {:test} IntersperseInterposesASeparatorBetweenListItems() {
    expect intersperse("n", ["ba", "a", "a"]) == ["ba", "n", "a", "n", "a"];
    expect intersperse("bar", ["foo"]) == ["foo"];
    var none: seq<string> := [];
    expect intersperse("bar", none) == [];
  }

  method {:test} IntersperseIsCurried() {
    var withN := (l: seq<string>) => intersperse("n", l);
    expect withN(["ba", "a", "a"]) == ["ba", "n", "a", "n", "a"];
  }

  function DrObjs(): seq<int> { [1, 2, 3, 4, 5, 3, 2] }
  function DrObjs2(): seq<int> { [1, 2, 2, 2, 3, 4, 4, 5, 5, 3, 2, 2] }

  method {:test} DropRepeatsRemovesRepeatedElements() {
    expect dropRepeats(DrObjs2()) == DrObjs();
    expect dropRepeats(DrObjs()) == DrObjs();
  }

  method {:test} DropRepeatsReturnsAnEmptyArrayForAnEmptyArray() {
    var none: seq<int> := [];
    expect dropRepeats(none) == [];
  }

  function I(i: int): map<string, int> { map["i" := i] }
  function IN(i: int, n: int): map<string, int> { map["i" := i, "n" := n] }
  function DrwObjs(): seq<map<string, int>> { [I(1), I(2), I(3), I(4), I(5), I(3)] }
  function DrwObjs2(): seq<map<string, int>> { [I(1), I(1), I(1), I(2), I(3), I(3), I(4), I(4), I(5), I(3)] }
  // `eqI = R.eqProps('i')`
  function EqI(a: map<string, int>, b: map<string, int>): bool { O.eqProps("i", a, b) }

  method {:test} DropRepeatsWithRemovesRepeatedElementsBasedOnPredicate() {
    expect dropRepeatsWith(EqI, DrwObjs2()) == DrwObjs();
    expect dropRepeatsWith(EqI, DrwObjs()) == DrwObjs();
  }

  method {:test} DropRepeatsWithKeepsElementsFromTheLeft() {
    expect dropRepeatsWith(EqI, [IN(1, 1), IN(1, 2), IN(1, 3), IN(4, 1), IN(4, 2)]) == [IN(1, 1), IN(4, 1)];
  }

  method {:test} DropRepeatsWithReturnsAnEmptyArrayForAnEmptyArray() {
    var none: seq<map<string, int>> := [];
    expect dropRepeatsWith(EqI, none) == [];
  }

  method {:test} DropRepeatsWithIsCurried() {
    var byI := (l: seq<map<string, int>>) => dropRepeatsWith(EqI, l);
    expect byI(DrwObjs()) == DrwObjs();
    expect byI(DrwObjs2()) == DrwObjs();
  }

  // ---- splitEvery.js and uniqBy.js (v0.16.0). Not transcribed:
  // splitEvery's "throws if first argument is not positive" (outside the
  // domain, README "Outside the modeled domain") and uniqBy's "has R.equals
  // semantics" (`-0`, NaN and objects with an `equals` method, README
  // "Deviations"). ----

  // its string lines split a string into strings, the same seqs here
  method {:test} SplitEverySplitsACollectionIntoSlicesOfTheSpecifiedLength() {
    var empty: seq<int> := [];
    expect splitEvery(1, [1, 2, 3, 4]) == [[1], [2], [3], [4]];
    expect splitEvery(2, [1, 2, 3, 4]) == [[1, 2], [3, 4]];
    expect splitEvery(3, [1, 2, 3, 4]) == [[1, 2, 3], [4]];
    expect splitEvery(4, [1, 2, 3, 4]) == [[1, 2, 3, 4]];
    expect splitEvery(5, [1, 2, 3, 4]) == [[1, 2, 3, 4]];
    expect splitEvery(3, empty) == [];
    expect splitEvery(1, "abcd") == ["a", "b", "c", "d"];
    expect splitEvery(2, "abcd") == ["ab", "cd"];
    expect splitEvery(3, "abcd") == ["abc", "d"];
    expect splitEvery(4, "abcd") == ["abcd"];
    expect splitEvery(5, "abcd") == ["abcd"];
    expect splitEvery(3, "") == [];
  }

  function Abs(n: int): int { if n < 0 then -n else n }

  method {:test} UniqByReturnsASetFromAnyArrayBasedOnPredicate() {
    expect uniqBy(Abs, [-2, -1, 0, 1, 2]) == [-2, -1, 0];
  }

  method {:test} UniqByKeepsElementsFromTheLeft() {
    expect uniqBy(Abs, [-1, 2, 4, 3, 1, 3]) == [-1, 2, 4, 3];
  }

  method {:test} UniqByReturnsAnEmptyArrayForAnEmptyArray() {
    var empty: seq<int> := [];
    expect uniqBy((x: int) => x, empty) == [];
  }

  // ---- pair.js (v0.18.0) ----

  // `pair('foo')('bar')` as a lambda
  method {:test} PairCreatesATwoElementArray() {
    expect pair("foo", "bar") == ("foo", "bar");
    var pairFoo := (b: string) => pair("foo", b);
    expect pairFoo("bar") == ("foo", "bar");
  }

  // ---- indexBy.js (v0.19.0) ----

  // `R.prop('id')`, total on these objects; `R.toUpper` is String's
  function Id(o: map<string, string>): string { if "id" in o then o["id"] else "undefined" }
  function IdList(): seq<map<string, string>>
  { [map["id" := "xyz", "title" := "A"], map["id" := "abc", "title" := "B"]] }

  method {:test} IndexByIndexesListByTheGivenProperty() {
    expect indexBy(Id, IdList()) ==
      map["abc" := map["id" := "abc", "title" := "B"], "xyz" := map["id" := "xyz", "title" := "A"]];
  }

  method {:test} IndexByIndexesListByTheGivenPropertyUpperCase() {
    expect indexBy((o: map<string, string>) => S.toUpper(Id(o)), IdList()) ==
      map["ABC" := map["id" := "abc", "title" := "B"], "XYZ" := map["id" := "xyz", "title" := "A"]];
  }

  method {:test} IndexByIsCurried() {
    var byId := (l: seq<map<string, string>>) => indexBy(Id, l);
    expect byId(IdList()) ==
      map["abc" := map["id" := "abc", "title" := "B"], "xyz" := map["id" := "xyz", "title" := "A"]];
  }

  // ---- sequence.js, traverse.js (v0.19.0): their list `it`s; `R.of` is
  // List.of ----

  method {:test} SequenceOperatesOnAListOfLists() {
    var none: seq<seq<int>> := [];
    var empty: seq<int> := [];
    expect sequence(of, none) == [[]];
    expect sequence(of, [empty, [1, 2, 3, 4]]) == [];
    expect sequence(of, [[1], [2, 3, 4]]) == [[1, 2], [1, 3], [1, 4]];
    expect sequence(of, [[1, 2], [3, 4]]) == [[1, 3], [1, 4], [2, 3], [2, 4]];
    expect sequence(of, [[1, 2, 3], [4]]) == [[1, 4], [2, 4], [3, 4]];
    expect sequence(of, [[1, 2, 3, 4], empty]) == [];
  }

  // `R.map(R.add(10))` (until v0.19.1 commuteMap.js's `plus10map`)
  function Plus10Map(xs: seq<int>): seq<int> { mapSeq((x: int) => x + 10, xs) }

  method {:test} TraverseOperatesOnAListOfLists() {
    var none: seq<seq<int>> := [];
    var empty: seq<int> := [];
    expect traverse(of, Plus10Map, none) == [[]];
    expect traverse(of, Plus10Map, [empty, [1, 2, 3, 4]]) == [];
    expect traverse(of, Plus10Map, [[1], [2, 3, 4]]) == [[11, 12], [11, 13], [11, 14]];
    expect traverse(of, Plus10Map, [[1, 2], [3, 4]]) == [[11, 13], [11, 14], [12, 13], [12, 14]];
    expect traverse(of, Plus10Map, [[1, 2, 3], [4]]) == [[11, 14], [12, 14], [13, 14]];
    expect traverse(of, Plus10Map, [[1, 2, 3, 4], empty]) == [];
  }

  // ---- splitAt.js, splitWhen.js (v0.19.0) ----

  method {:test} SplitAtSplitsAnArrayAtAGivenIndex() {
    expect splitAt(1, [1, 2, 3]) == ([1], [2, 3]);
  }

  method {:test} SplitAtSplitsAStringAtAGivenIndex() {
    expect splitAt(5, "hello world") == ("hello", " world");
  }

  // `splitAtThree = splitAt(3)`
  method {:test} SplitAtIsCurried() {
    var splitAtThree := (s: string) => splitAt(3, s);
    expect splitAtThree("foobar") == ("foo", "bar");
  }

  method {:test} SplitAtCanHandleIndexGreaterThanArrayLength() {
    var empty: seq<int> := [];
    expect splitAt(4, [1, 2]) == ([1, 2], empty);
  }

  method {:test} SplitAtCanSupportNegativeIndex() {
    expect splitAt(-1, "foobar") == ("fooba", "r");
  }

  // `R.equals(2)` and `R.T` as lambdas
  method {:test} SplitWhenSplitsAnArrayAtTheFirstInstanceToSatisfyThePredicate() {
    expect splitWhen((x: int) => x == 2, [1, 2, 3]) == ([1], [2, 3]);
  }

  method {:test} SplitWhenRetainsAllOriginalElements() {
    var empty: seq<int> := [];
    expect splitWhen((x: int) => Funcs.T(x), [1, 1, 1]) == (empty, [1, 1, 1]);
  }

  method {:test} SplitWhenIsCurried() {
    var splitWhenFoo := (l: seq<string>) => splitWhen((x: string) => x == "foo", l);
    var empty: seq<string> := [];
    expect splitWhenFoo(["foo", "bar", "baz"]) == (empty, ["foo", "bar", "baz"]);
  }

  method {:test} SplitWhenOnlySplitsOnce() {
    expect splitWhen((x: int) => x == 2, [1, 2, 3, 1, 2, 3]) == ([1], [2, 3, 1, 2, 3]);
  }

  // ---- transpose.js (v0.19.0) ----

  method {:test} TransposeReturnsAnArrayOfTwoArrays() {
    var input := [[Str("a"), Num(1)], [Str("b"), Num(2)], [Str("c"), Num(3)]];
    expect transpose(input) == [[Str("a"), Str("b"), Str("c")], [Num(1), Num(2), Num(3)]];
  }

  method {:test} TransposeSkipsElementsWhenRowsAreShorter() {
    var empty: seq<int> := [];
    expect transpose([[10, 11], [20], empty, [30, 31, 32]]) == [[10, 20, 30], [11, 31], [32]];
  }

  method {:test} TransposeCopesWithEmptyArrays() {
    var none: seq<seq<int>> := [];
    expect transpose(none) == [];
  }

  method {:test} TransposeCopesWithTrueFalseNullAndUndefinedElements() {
    var actual := transpose([[Bool(true), Bool(false), Undefined, Null], [Null, Undefined, Bool(false), Bool(true)]]);
    expect actual == [[Bool(true), Null], [Bool(false), Undefined], [Undefined, Bool(false)], [Null, Bool(true)]];
  }

  // ---- without.js (v0.19.0) ----

  method {:test} WithoutReturnsAnArrayNotContainingValuesInTheFirstArgument() {
    expect without([1, 2], [1, 2, 1, 4, 5]) == [4, 5];
  }

  // `withoutOnes = without([1])`
  method {:test} WithoutIsCurried() {
    var withoutOnes := (l: seq<int>) => without([1], l);
    expect withoutOnes([1, 2, 3, 5, 1]) == [2, 3, 5];
  }

  // "has R.equals semantics": its `[[1]]` line
  method {:test} WithoutHasEqualsSemantics() {
    expect |without([[1]], [[1]])| == 0;
  }

  // ---- lensIndex.js (v0.19.0, again; v0.14.0 to v0.15.1 had one): over Js
  // values, `testList = [{a: 1}, {b: 2}, {c: 3}]`, as set stores a number
  // among objects; `R.keys` gives an array of the key names ----
  function TestList(): seq<Js>
  { [Obj(map["a" := Num(1)]), Obj(map["b" := Num(2)]), Obj(map["c" := Num(3)])] }
  // `R.keys` on testList's one-key objects
  function KeysOf(v: Js): Js
  { if !v.Obj? then Arr([])
    else if v.props.Keys == {"a"} then Arr([Str("a")])
    else if v.props.Keys == {"b"} then Arr([Str("b")])
    else if v.props.Keys == {"c"} then Arr([Str("c")])
    else Arr([]) }

  method {:test} LensIndexViewFocusesListElementAtTheSpecifiedIndex() {
    expect O.view(lensIndex<Js, Js>(0), TestList()) == Obj(map["a" := Num(1)]);
  }

  method {:test} LensIndexSetSetsTheListValueAtTheSpecifiedIndex() {
    expect O.set_(lensIndex<Js, Js>(0), Num(0), TestList()) ==
      [Num(0), Obj(map["b" := Num(2)]), Obj(map["c" := Num(3)])];
  }

  method {:test} LensIndexOverAppliesFunctionToTheValueAtTheSpecifiedListIndex() {
    expect O.over(lensIndex<Js, Js>(2), (v: Js) => KeysOf(v), TestList()) ==
      [Obj(map["a" := Num(1)]), Obj(map["b" := Num(2)]), Arr([Str("c")])];
  }

  // "well behaved lens"
  method {:test} LensIndexSetOfGetIsIdentity() {
    expect O.set_(lensIndex<Js, Js>(0), O.view(lensIndex<Js, Js>(0), TestList()), TestList()) == TestList();
  }

  method {:test} LensIndexGetOfSetIsTheValue() {
    expect O.view(lensIndex<Js, Js>(0), O.set_(lensIndex<Js, Js>(0), Num(0), TestList())) == Num(0);
  }

  method {:test} LensIndexGetOfSetOfSetIsTheLastValue() {
    expect O.view(lensIndex<Js, Js>(0), O.set_(lensIndex<Js, Js>(0), Num(11), O.set_(lensIndex<Js, Js>(0), Num(10), TestList()))) == Num(11);
  }

  // ---- reduceBy.js (v0.20.0): its students and `{type, val}` records are
  // groupBy's (`Student`, `byGrade`, `Typed` and `TypeOf`, above) ----

  // `collectNames = (acc, student) => acc.concat(student.name)`
  function CollectNames(acc: seq<string>, s: map<string, Js>): seq<string>
  { if "name" in s && s["name"].Str? then acc + [s["name"].s] else acc }

  // `sumValues = (acc, obj) => acc + obj.val`
  function SumValues(acc: int, o: map<string, Js>): int
  { acc + (if "val" in o && o["val"].Num? then o["val"].n else 0) }

  method {:test} ReduceBySplitsTheListIntoGroupsAccordingToTheGroupingFunction() {
    var students := [Student("Abby", 84), Student("Brad", 73), Student("Chris", 89), Student("Dianne", 99),
                     Student("Eddy", 58), Student("Fred", 67), Student("Gillian", 91), Student("Hannah", 78),
                     Student("Irene", 85), Student("Jack", 69)];
    var none: seq<string> := [];
    expect reduceBy(CollectNames, none, byGrade, students) ==
      map["A" := ["Dianne", "Gillian"], "B" := ["Abby", "Chris", "Irene"], "C" := ["Brad", "Hannah"],
          "D" := ["Fred", "Jack"], "F" := ["Eddy"]];
  }

  method {:test} ReduceByReturnsAnEmptyObjectIfGivenAnEmptyArray() {
    var none: seq<map<string, Js>> := [];
    expect reduceBy(SumValues, 0, TypeOf, none) == map[];
  }

  // `reduceToSumsBy = R.reduceBy(sumValues, 0)`, `sumByType =
  // reduceToSumsBy(byType)` (v0.21.0; in v0.20.x `splitByType =
  // R.reduceBy(byType)`, `sumByType = splitByType(sumValues, 0)`)
  method {:test} ReduceByIsCurried() {
    var reduceToSumsBy := (keyFn: map<string, Js> -> string) => ((l: seq<map<string, Js>>) => reduceBy(SumValues, 0, keyFn, l));
    var sumByType := reduceToSumsBy(TypeOf);
    expect sumByType([Typed("A", 10), Typed("B", 20), Typed("A", 30), Typed("A", 40), Typed("C", 50), Typed("B", 60)]) ==
      map["A" := 80, "B" := 80, "C" := 50];
  }

  // ---- groupWith.js (v0.21.0) ----

  method {:test} GroupWithSplitsTheListIntoGroupsAccordingToTheGroupingFunction() {
    expect groupWith((a: int, b: int) => a == b, [1, 2, 2, 3]) == [[1], [2, 2], [3]];
    expect groupWith((a: int, b: int) => a == b, [1, 1, 1, 1]) == [[1, 1, 1, 1]];
    expect groupWith((a: int, b: int) => a == b, [1, 2, 3, 4]) == [[1], [2], [3], [4]];
  }

  method {:test} GroupWithReturnsAnEmptyArrayIfGivenAnEmptyArray() {
    var empty: seq<int> := [];
    expect groupWith((a: int, b: int) => a == b, empty) == [];
  }

  method {:test} GroupWithCanBeTurnedIntoTheOriginalListThroughConcatenation() {
    var list := [1, 1, 2, 3, 4, 4, 5, 5];
    expect chain((g: seq<int>) => g, groupWith((a: int, b: int) => a == b, list)) == list;
    expect chain((g: seq<int>) => g, groupWith((a: int, b: int) => a != b, list)) == list;
    expect chain((g: seq<int>) => g, groupWith((a: int, b: int) => true, list)) == list;
    expect chain((g: seq<int>) => g, groupWith((a: int, b: int) => false, list)) == list;
  }

  // `R.groupWith(R.equals)('Mississippi')`
  method {:test} GroupWithAlsoWorksOnStrings() {
    var byEquals := (s: string) => groupWith((a: char, b: char) => a == b, s);
    expect byEquals("Mississippi") == ["M", "i", "ss", "i", "ss", "i", "pp", "i"];
  }
}
