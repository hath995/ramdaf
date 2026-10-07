// Ramda v0.3.0 test/test.filter.js, transcribed ("automatically curried" cases
// apply the partially applied function in full). The "should start at the
// right arg" cases use a predicate that would fail the test if called; here
// it is a predicate whose result does not matter (the list is empty), and
// `undefined` elements are Js values.

module RamdafTests.Ramda.Filter {
  import opened Ramdaf.List
  import opened Support

  function even(x: int): bool { x % 2 == 0 }

  // describe('filter')
  method {:test} FilterReducesToMatchingElements() {
    expect filter(even, [1, 2, 3, 4, 5]) == [2, 4];
  }

  method {:test} FilterIsAutomaticallyCurried() {
    var onlyEven := (l: seq<int>) => filter(even, l);
    expect onlyEven([1, 2, 3, 4, 5, 6, 7]) == [2, 4, 6];
  }

  // describe('filter.idx')
  function everyOther(val: int, idx: nat, list: seq<int>): bool { idx % 2 == 0 }
  function lastTwo(val: int, idx: nat, list: seq<int>): bool { |list| - idx < 3 }

  method {:test} FilterIdxWorksJustLikeANormalFilter() {
    expect filterIdx((x: int, idx: nat, list: seq<int>) => even(x), [1, 2, 3, 4, 5]) == [2, 4];
  }

  method {:test} FilterIdxPassesTheIndexAsASecondParameter() {
    expect filterIdx(everyOther, [8, 6, 7, 5, 3, 0, 9]) == [8, 7, 3, 9];
  }

  method {:test} FilterIdxPassesTheEntireListAsAThirdParameter() {
    expect filterIdx(lastTwo, [8, 6, 7, 5, 3, 0, 9]) == [0, 9];
  }

  method {:test} FilterIdxIsAutomaticallyCurried() {
    var everyOtherPosition := (l: seq<int>) => filterIdx(everyOther, l);
    expect everyOtherPosition([8, 6, 7, 5, 3, 0, 9]) == [8, 7, 3, 9];
  }

  // describe('reject')
  method {:test} RejectReducesToNonMatchingElements() {
    expect reject(even, [1, 2, 3, 4, 5]) == [1, 3, 5];
  }

  method {:test} RejectIsAutomaticallyCurried() {
    var odd := (l: seq<int>) => reject(even, l);
    expect odd([1, 2, 3, 4, 5, 6, 7]) == [1, 3, 5, 7];
  }

  // describe('reject.idx')
  method {:test} RejectIdxWorksJustLikeANormalReject() {
    expect rejectIdx((x: int, idx: nat, list: seq<int>) => even(x), [1, 2, 3, 4, 5]) == [1, 3, 5];
  }

  method {:test} RejectIdxPassesTheIndexAsASecondParameter() {
    expect rejectIdx(everyOther, [8, 6, 7, 5, 3, 0, 9]) == [6, 5, 0];
  }

  method {:test} RejectIdxPassesTheEntireListAsAThirdParameter() {
    expect rejectIdx(lastTwo, [8, 6, 7, 5, 3, 0, 9]) == [8, 6, 7, 5, 3];
  }

  method {:test} RejectIdxIsAutomaticallyCurried() {
    var everyOtherPosition := (l: seq<int>) => rejectIdx(everyOther, l);
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

  method {:test} TakeIsAutomaticallyCurried() {
    var take3 := (l: seq<string>) => take(3, l);
    expect take3(["a", "b", "c", "d", "e", "f", "g"]) == ["a", "b", "c"];
    expect take3(["w", "x", "y", "z"]) == ["w", "x", "y"];
  }

  // describe('skipUntil')
  method {:test} SkipUntilSkipsUntilTrue() {
    expect skipUntil((x: int) => x == 5, [1, 3, 5, 7, 9]) == [5, 7, 9];
  }

  method {:test} SkipUntilIsAutomaticallyCurried() {
    var skipUntil7 := (l: seq<int>) => skipUntil((x: int) => x == 7, l);
    expect skipUntil7([1, 3, 5, 7, 9]) == [7, 9];
    expect skipUntil7([2, 4, 6, 8, 10]) == [];
  }

  // v0.2.0
  method {:test} SkipUntilStartsAtTheRightArgAndAcknowledgesUndefined() {
    var empty: seq<Js> := [];
    expect skipUntil((x: Js) => false, empty) == [];
    expect skipUntil((x: Js) => x.Undefined?, [Num(1), Num(3), Undefined, Num(5), Num(7)]) == [Undefined, Num(5), Num(7)];
  }

  // describe('skip')
  method {:test} SkipSkipsTheFirstNElements() {
    expect skip(3, ["a", "b", "c", "d", "e", "f", "g"]) == ["d", "e", "f", "g"];
  }

  method {:test} SkipIsAutomaticallyCurried() {
    var skip2 := (l: seq<string>) requires 2 <= |l| => skip(2, l);
    expect skip2(["a", "b", "c", "d", "e"]) == ["c", "d", "e"];
    expect skip2(["x", "y", "z"]) == ["z"];
  }

  // "should be aliased by `drop`"
  method {:test} SkipIsAliasedByDrop() {
    expect drop(1, ["a", "b", "c"]) == ["b", "c"];
  }
}
