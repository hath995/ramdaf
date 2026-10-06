// Ramda v0.1.0 test/test.core.js, transcribed.

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
  }

  // describe('head')
  method {:test} HeadReturnsTheFirstElement() {
    expect head(["a", "b", "c", "d"]) == "a";
  }

  // describe('tail')
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
}
