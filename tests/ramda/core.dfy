// Ramda v0.1.5 test/test.core.js and test/test.clone.js, transcribed. Not
// transcribed: describe('isAtom') (not portable, README); head's and last's
// "returns undefined for an empty list" and "for no arguments" (the empty list
// is outside their domain, README "Outside the modeled domain"); tail's
// "returns an empty list for no arguments" (no-argument call of a list
// function); cloneDeep's "does not copy objects in the array by reference"
// (asserts reference inequality, which Dafny values do not have).

module RamdafTests.Ramda.Core {
  import opened Ramdaf.Core
  import opened Ramdaf.Sort

  // describe('isEmpty')
  method {:test} IsEmptyTrueForEmptyList() {
    var empty: seq<string> := [];
    expect isEmpty(empty) == true;
  }

  method {:test} IsEmptyFalseForNonEmptyList() {
    expect isEmpty([""]) == false;
  }

  // describe('prepend')
  method {:test} PrependAddsToTheBeginning() {
    expect prepend("x", ["y", "z"]) == ["x", "y", "z"];
  }

  // describe('append')
  method {:test} AppendAddsToTheEnd() {
    expect append("z", ["x", "y"]) == ["x", "y", "z"];
  }

  // describe('merge')
  method {:test} MergeCombinesTheLists() {
    expect merge(["a", "b"], ["c", "d"]) == ["a", "b", "c", "d"];
    var empty: seq<string> := [];
    expect merge(empty, ["c", "d"]) == ["c", "d"];
  }

  // describe('head')
  method {:test} HeadReturnsTheFirstElement() {
    expect head(["a", "b", "c", "d"]) == "a";
  }

  // describe('last') ("returns the first element of a list" checks the last)
  method {:test} LastReturnsTheLastElement() {
    expect last(["a", "b", "c", "d"]) == "d";
  }

  // describe('tail')
  method {:test} TailReturnsAnEmptyListForAnEmptyList() {
    var empty: seq<string> := [];
    expect tail(empty) == [];
  }

  method {:test} TailReturnsTheRest() {
    expect tail(["a", "b", "c", "d"]) == ["b", "c", "d"];
  }

  // describe('size')
  method {:test} SizeCountsTheElements() {
    expect size(["a", "b", "c", "d"]) == 4;
  }

  // describe('sort')
  method {:test} SortSortsTheElements() {
    expect sort((a: int, b: int) => a - b, [3, 1, 8, 1, 2, 5]) == [1, 1, 2, 3, 5, 8];
  }

  method {:test} SortDoesNotAffectTheListSupplied() {
    var list := [3, 1, 8, 1, 2, 5];
    expect sort((a: int, b: int) => a - b, list) == [1, 1, 2, 3, 5, 8];
    expect list == [3, 1, 8, 1, 2, 5];
  }

  // "is automatically curried": `sort(cmp)` applied to the list. The expected
  // order relies on a stable sort.
  method {:test} SortIsAutomaticallyCurried() {
    var sortByLength := (l: seq<string>) => sort((a: string, b: string) => |a| - |b|, l);
    expect sortByLength(["one", "two", "three", "four", "five", "six"]) ==
      ["one", "two", "six", "four", "five", "three"];
  }

  // describe('comparator')
  method {:test} ComparatorBuildsAComparatorFromALessThanPredicate() {
    expect sort(comparator((a: int, b: int) => a < b), [3, 1, 8, 1, 2, 5]) == [1, 1, 2, 3, 5, 8];
  }

  // ---- test.clone.js ----

  // describe('clone')
  method {:test} CloneReturnsACopyOfAnArray() {
    expect clone([1, 2, 3, 4, 5]) == [1, 2, 3, 4, 5];
  }

  // "copies objects in the array by reference": `c[0]` equals `o1` (Dafny
  // compares values, so this holds without references).
  method {:test} CloneCopiesObjectsInTheArrayByReference() {
    var o1, o2, o3 := map["x" := 1], map["x" := 2], map["x" := 3];
    var c := clone([o1, o2, o3]);
    expect c[0] == o1;
  }

  // describe('cloneDeep')
  method {:test} CloneDeepReturnsACopyOfAnArray() {
    expect cloneDeep([1, 2, 3, 4, 5]) == [1, 2, 3, 4, 5];
  }
}
