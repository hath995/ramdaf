// Ramda v0.15.1 test/filter.js, filterIndexed.js, reject.js,
// rejectIndexed.js, takeWhile.js, take.js, dropWhile.js and drop.js (until
// v0.8.0 test.filter.js), transcribed ("automatically curried" cases apply
// the partially applied function in full). The "should start at the
// right arg" cases use a predicate that would fail the test if called; here
// it is a predicate whose result does not matter (the list is empty), and
// `undefined` elements are Js values. Not transcribed: v0.5.0's filter
// "dispatches to passed-in non-Array object with a `filter` method" (method
// dispatch), v0.10.0's reject "dispatches to `filter` method" (likewise)
// and the "throws on zero arguments" cases (no-argument calls; v0.11.0
// removed them); v0.15.0's take and drop "never returns the input array"
// (reference identity) and the object halves of their "dispatches to
// `slice` method" (method dispatch).
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

  // describe('filterIndexed') (describe('filter.idx') until v0.8.0)
  function everyOther(val: int, idx: nat, list: seq<int>): bool { idx % 2 == 0 }
  function lastTwo(val: int, idx: nat, list: seq<int>): bool { |list| - idx < 3 }

  method {:test} FilterIndexedWorksJustLikeANormalFilter() {
    expect filterIndexed((x: int, idx: nat, list: seq<int>) => even(x), [1, 2, 3, 4, 5]) == [2, 4];
  }

  method {:test} FilterIndexedPassesTheIndexAsASecondParameter() {
    expect filterIndexed(everyOther, [8, 6, 7, 5, 3, 0, 9]) == [8, 7, 3, 9];
  }

  method {:test} FilterIndexedPassesTheEntireListAsAThirdParameter() {
    expect filterIndexed(lastTwo, [8, 6, 7, 5, 3, 0, 9]) == [0, 9];
  }

  // v0.5.0
  method {:test} FilterIndexedReturnsAnEmptyArrayIfNoElementMatches() {
    expect filterIndexed((x: int, idx: nat, list: seq<int>) => x > 100, [1, 9, 99]) == [];
  }

  // v0.5.0
  method {:test} FilterIndexedReturnsAnEmptyArrayIfAskedToFilterAnEmptyArray() {
    var empty: seq<int> := [];
    expect filterIndexed((x: int, idx: nat, list: seq<int>) => x > 100, empty) == [];
  }

  method {:test} FilterIndexedIsAutomaticallyCurried() {
    var everyOtherPosition := (l: seq<int>) => filterIndexed(everyOther, l);
    expect everyOtherPosition([8, 6, 7, 5, 3, 0, 9]) == [8, 7, 3, 9];
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

  // describe('rejectIndexed') (describe('reject.idx') until v0.8.0)
  method {:test} RejectIndexedWorksJustLikeANormalReject() {
    expect rejectIndexed((x: int, idx: nat, list: seq<int>) => even(x), [1, 2, 3, 4, 5]) == [1, 3, 5];
  }

  method {:test} RejectIndexedPassesTheIndexAsASecondParameter() {
    expect rejectIndexed(everyOther, [8, 6, 7, 5, 3, 0, 9]) == [6, 5, 0];
  }

  method {:test} RejectIndexedPassesTheEntireListAsAThirdParameter() {
    expect rejectIndexed(lastTwo, [8, 6, 7, 5, 3, 0, 9]) == [8, 6, 7, 5, 3];
  }

  // v0.5.0
  method {:test} RejectIndexedReturnsAnEmptyArrayIfNoElementMatches() {
    expect rejectIndexed((x: int, idx: nat, list: seq<int>) => x < 100, [1, 9, 99]) == [];
  }

  // v0.5.0
  method {:test} RejectIndexedReturnsAnEmptyArrayIfAskedToFilterAnEmptyArray() {
    var empty: seq<int> := [];
    expect rejectIndexed((x: int, idx: nat, list: seq<int>) => x > 100, empty) == [];
  }

  method {:test} RejectIndexedIsAutomaticallyCurried() {
    var everyOtherPosition := (l: seq<int>) => rejectIndexed(everyOther, l);
    expect everyOtherPosition([8, 6, 7, 5, 3, 0, 9]) == [6, 5, 0];
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

  // v0.15.0 "dispatches to `slice` method": its string line (a JS string's
  // own `slice`; the same seq here); the object with a `slice` method is
  // not a list
  method {:test} TakeDispatchesToSliceMethod() {
    expect take(3, "Ramda") == "Ram";
  }

  method {:test} TakeIsAutomaticallyCurried() {
    var take3 := (l: seq<string>) => take(3, l);
    expect take3(["a", "b", "c", "d", "e", "f", "g"]) == ["a", "b", "c"];
    expect take3(["w", "x", "y", "z"]) == ["w", "x", "y"];
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

  // v0.15.0 "dispatches to `slice` method": its string line
  method {:test} DropDispatchesToSliceMethod() {
    expect drop(3, "Ramda") == "da";
  }

  method {:test} DropIsAutomaticallyCurried() {
    var drop2 := (l: seq<string>) => drop(2, l);
    expect drop2(["a", "b", "c", "d", "e"]) == ["c", "d", "e"];
    expect drop2(["x", "y", "z"]) == ["z"];
  }
}
