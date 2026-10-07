// Ramda v0.19.0 test/filter.js, reject.js, takeWhile.js, take.js,
// dropWhile.js, drop.js, dropLast.js, takeLast.js, dropLastWhile.js and
// takeLastWhile.js (until v0.8.0 test.filter.js), transcribed ("automatically curried" cases apply
// the partially applied function in full). The "should start at the
// right arg" cases use a predicate that would fail the test if called; here
// it is a predicate whose result does not matter (the list is empty), and
// `undefined` elements are Js values. Not transcribed: v0.5.0's filter
// "dispatches to passed-in non-Array object with a `filter` method" (method
// dispatch), v0.10.0's reject "dispatches to `filter` method" (likewise)
// and the "throws on zero arguments" cases (no-argument calls; v0.11.0
// removed them); v0.15.0's take and drop "never returns the input array"
// (reference identity), and take's "handles zero correctly (#1224)"
// (v0.16.0; `into` with a transducer, README "Not portable"). v0.16.0
// replaced take's and drop's "dispatches to `slice` method" (whose object
// halves were method dispatch) with "can operate on strings" and removed
// their "is curried", and removed filterIndexed.js and rejectIndexed.js
// with the functions.
// (v0.4.1 removed skip's "should be aliased by `drop`" with `drop`; v0.9.0
// renamed the filter.idx, reject.idx and skip describes to filterIndexed,
// rejectIndexed and drop, and replaced skipUntil's with dropWhile's, whose
// predicates are negated.)

module RamdafTests.Ramda.Filter {
  import opened Ramdaf.List
  import opened Support

  function even(x: int): bool { x % 2 == 0 }

  // describe('filter')
  method {:test} FilterReducesToMatchingElements() {
    expect filter(even, [1, 2, 3, 4, 5]) == [2, 4];
  }

  // v0.5.0
  method {:test} FilterReturnsAnEmptyArrayIfNoElementMatches() {
    expect filter((x: int) => x > 100, [1, 9, 99]) == [];
  }

  // v0.5.0
  method {:test} FilterReturnsAnEmptyArrayIfAskedToFilterAnEmptyArray() {
    var empty: seq<int> := [];
    expect filter((x: int) => x > 100, empty) == [];
  }

  method {:test} FilterIsAutomaticallyCurried() {
    var onlyEven := (l: seq<int>) => filter(even, l);
    expect onlyEven([1, 2, 3, 4, 5, 6, 7]) == [2, 4, 6];
  }

  // describe('reject')
  method {:test} RejectReducesToNonMatchingElements() {
    expect reject(even, [1, 2, 3, 4, 5]) == [1, 3, 5];
  }

  // v0.5.0 (this `it` and the next appear twice each, with the same bodies)
  method {:test} RejectReturnsAnEmptyArrayIfNoElementMatches() {
    expect reject((x: int) => x < 100, [1, 9, 99]) == [];
  }

  // v0.5.0
  method {:test} RejectReturnsAnEmptyArrayIfAskedToFilterAnEmptyArray() {
    var empty: seq<int> := [];
    expect reject((x: int) => x > 100, empty) == [];
  }

  method {:test} RejectIsAutomaticallyCurried() {
    var odd := (l: seq<int>) => reject(even, l);
    expect odd([1, 2, 3, 4, 5, 6, 7]) == [1, 3, 5, 7];
  }

  // describe('takeWhile')
  method {:test} TakeWhileTakesWhileTrue() {
    expect takeWhile((x: int) => x != 5, [1, 3, 5, 7, 9]) == [1, 3];
  }

  method {:test} TakeWhileIsAutomaticallyCurried() {
    var takeUntil7 := (l: seq<int>) => takeWhile((x: int) => x != 7, l);
    expect takeUntil7([1, 3, 5, 7, 9]) == [1, 3, 5];
    expect takeUntil7([2, 4, 6, 8, 10]) == [2, 4, 6, 8, 10];
  }

  // v0.2.0
  method {:test} TakeWhileStartsAtTheRightArgAndAcknowledgesUndefined() {
    var empty: seq<Js> := [];
    expect takeWhile((x: Js) => false, empty) == [];
    expect takeWhile((x: Js) => !x.Undefined?, [Num(1), Num(3), Undefined, Num(5), Num(7)]) == [Num(1), Num(3)];
  }

  // describe('take')
  method {:test} TakeTakesTheFirstNElements() {
    expect take(3, ["a", "b", "c", "d", "e", "f", "g"]) == ["a", "b", "c"];
  }

  // v0.5.0
  method {:test} TakeReturnsOnlyAsManyAsTheArrayCanProvide() {
    var empty: seq<int> := [];
    expect take(3, [1, 2]) == [1, 2];
    expect take(3, empty) == [];
  }

  // v0.15.0 (until v0.14.0 a negative n gave []); its `take(-Infinity, …)`
  // line is not an int
  method {:test} TakeReturnsAnEquivalentListIfNIsBelowZero() {
    expect take(-1, [1, 2, 3]) == [1, 2, 3];
  }

  // v0.16.0 (v0.15.0's "dispatches to `slice` method", whose string line
  // was `take(3, 'Ramda')`; a JS string gives a string, the same seq here)
  method {:test} TakeCanOperateOnStrings() {
    expect take(3, "Ramda") == "Ram";
    expect take(2, "Ramda") == "Ra";
    expect take(1, "Ramda") == "R";
    expect take(0, "Ramda") == "";
  }

  // describe('dropWhile') (v0.9.0, in place of describe('skipUntil'))
  method {:test} DropWhileSkipsElementsWhileTheFunctionReportsTrue() {
    expect dropWhile((x: int) => x < 5, [1, 3, 5, 7, 9]) == [5, 7, 9];
  }

  method {:test} DropWhileReturnsAnEmptyListForAnEmptyList() {
    var empty: seq<Js> := [];
    expect dropWhile((x: Js) => false, empty) == [];
    expect dropWhile((x: Js) => true, empty) == [];
  }

  method {:test} DropWhileStartsAtTheRightArgAndAcknowledgesUndefined() {
    var sublist := dropWhile((x: Js) => !x.Undefined?, [Num(1), Num(3), Undefined, Num(5), Num(7)]);
    expect |sublist| == 3;
    expect sublist[0] == Undefined;
    expect sublist[1] == Num(5);
    expect sublist[2] == Num(7);
  }

  method {:test} DropWhileIsAutomaticallyCurried() {
    var dropLt7 := (l: seq<int>) => dropWhile((x: int) => x < 7, l);
    expect dropLt7([1, 3, 5, 7, 9]) == [7, 9];
    expect dropLt7([2, 4, 6, 8, 10]) == [8, 10];
  }

  // describe('drop') (describe('skip') until v0.8.0)
  method {:test} DropSkipsTheFirstNElements() {
    expect drop(3, ["a", "b", "c", "d", "e", "f", "g"]) == ["d", "e", "f", "g"];
  }

  // v0.5.0 (until v0.4.3 skip threw RangeError here)
  method {:test} DropReturnsAnEmptyArrayIfNIsTooLarge() {
    expect drop(20, ["a", "b", "c", "d", "e", "f", "g"]) == [];
  }

  // v0.14.0 (until v0.13.0 a negative n read undefined holes); its
  // `drop(-Infinity, …)` line is not an int.
  method {:test} DropReturnsAnEquivalentListIfNIsAtMostZero() {
    expect drop(0, [1, 2, 3]) == [1, 2, 3];
    expect drop(-1, [1, 2, 3]) == [1, 2, 3];
  }

  // v0.16.0 (v0.15.0's "dispatches to `slice` method", whose string line
  // was `drop(3, 'Ramda')`)
  method {:test} DropCanOperateOnStrings() {
    expect drop(3, "Ramda") == "da";
    expect drop(4, "Ramda") == "a";
    expect drop(5, "Ramda") == "";
    expect drop(6, "Ramda") == "";
  }

  // describe('dropLast') (v0.16.0). Not transcribed: the `-Infinity` line
  // (not an int) and "never returns the input array" (reference identity).
  method {:test} DropLastSkipsTheLastNElements() {
    expect dropLast(3, ["a", "b", "c", "d", "e", "f", "g"]) == ["a", "b", "c", "d"];
  }

  method {:test} DropLastReturnsAnEmptyArrayIfNIsTooLarge() {
    expect dropLast(20, ["a", "b", "c", "d", "e", "f", "g"]) == [];
  }

  method {:test} DropLastReturnsAnEquivalentListIfNIsAtMostZero() {
    expect dropLast(0, [1, 2, 3]) == [1, 2, 3];
    expect dropLast(-1, [1, 2, 3]) == [1, 2, 3];
  }

  method {:test} DropLastCanOperateOnStrings() {
    expect dropLast(3, "Ramda") == "Ra";
  }

  method {:test} DropLastIsCurried() {
    var dropLast2 := (l: seq<string>) => dropLast(2, l);
    expect dropLast2(["a", "b", "c", "d", "e"]) == ["a", "b", "c"];
    expect dropLast2(["x", "y", "z"]) == ["x"];
  }

  // describe('takeLast') (v0.16.0). Not transcribed: the `-Infinity` line
  // and "never returns the input array", as for dropLast.
  method {:test} TakeLastTakesOnlyTheLastNElements() {
    expect takeLast(3, ["a", "b", "c", "d", "e", "f", "g"]) == ["e", "f", "g"];
  }

  method {:test} TakeLastReturnsOnlyAsManyAsTheArrayCanProvide() {
    var empty: seq<int> := [];
    expect takeLast(3, [1, 2]) == [1, 2];
    expect takeLast(3, empty) == [];
  }

  method {:test} TakeLastReturnsAnEquivalentListIfNIsBelowZero() {
    expect takeLast(-1, [1, 2, 3]) == [1, 2, 3];
  }

  method {:test} TakeLastCanOperateOnStrings() {
    expect takeLast(3, "Ramda") == "mda";
  }

  method {:test} TakeLastHandlesZeroCorrectly() {
    expect takeLast(0, [1, 2, 3]) == [];
  }

  method {:test} TakeLastIsCurried() {
    var takeLast3 := (l: seq<string>) => takeLast(3, l);
    expect takeLast3(["a", "b", "c", "d", "e", "f", "g"]) == ["e", "f", "g"];
    expect takeLast3(["w", "x", "y", "z"]) == ["x", "y", "z"];
  }

  // describe('dropLastWhile') (v0.16.0)
  method {:test} DropLastWhileSkipsElementsWhileTheFunctionReportsTrue() {
    expect dropLastWhile((x: int) => x >= 5, [1, 3, 5, 7, 9]) == [1, 3];
  }

  method {:test} DropLastWhileReturnsAnEmptyListForAnEmptyList() {
    var empty: seq<Js> := [];
    expect dropLastWhile((x: Js) => false, empty) == [];
    expect dropLastWhile((x: Js) => true, empty) == [];
  }

  method {:test} DropLastWhileStartsAtTheRightArgAndAcknowledgesUndefined() {
    var sublist := dropLastWhile((x: Js) => !x.Undefined?, [Num(1), Num(3), Undefined, Num(5), Num(7)]);
    expect |sublist| == 3;
    expect sublist[0] == Num(1);
    expect sublist[1] == Num(3);
    expect sublist[2] == Undefined;
  }

  method {:test} DropLastWhileIsCurried() {
    var dropGt7 := (l: seq<int>) => dropLastWhile((x: int) => x > 7, l);
    expect dropGt7([1, 3, 5, 7, 9]) == [1, 3, 5, 7];
    expect dropGt7([1, 3, 5]) == [1, 3, 5];
  }

  // describe('takeLastWhile') (v0.16.0). The predicate of the empty-list
  // line would fail the test if called; here its result does not matter.
  method {:test} TakeLastWhileContinuesTakingElementsWhileTheFunctionReportsTrue() {
    expect takeLastWhile((x: int) => x != 5, [1, 3, 5, 7, 9]) == [7, 9];
  }

  method {:test} TakeLastWhileStartsAtTheRightArgAndAcknowledgesUndefined() {
    var empty: seq<Js> := [];
    expect takeLastWhile((x: Js) => false, empty) == [];
    expect takeLastWhile((x: Js) => !x.Undefined?, [Num(1), Num(3), Undefined, Num(5), Num(7)]) == [Num(5), Num(7)];
  }

  method {:test} TakeLastWhileIsCurried() {
    var takeLastUntil7 := (l: seq<int>) => takeLastWhile((x: int) => x != 7, l);
    expect takeLastUntil7([1, 3, 5, 7, 9]) == [9];
    expect takeLastUntil7([2, 4, 6, 8, 10]) == [2, 4, 6, 8, 10];
  }
}
