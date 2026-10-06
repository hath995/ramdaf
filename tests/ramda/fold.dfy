// Ramda v0.1.0 test/test.fold.js, transcribed. The "should correctly report
// the arity of curried versions" cases have no Dafny counterpart (functions
// are uncurried); "should throw an error with an empty array" is the
// `requires |list| > 0` precondition, checked statically.

module RamdafTests.Ramda.Fold {
  import opened Ramdaf.List

  function add(a: int, b: int): int { a + b }
  function mult(a: int, b: int): int { a * b }
  function avg(a: real, b: real): real { (a + b) / 2.0 }

  // describe('foldl')
  method {:test} FoldlFoldsWithTheSuppliedAccumulator() {
    expect foldl(add, 0, [1, 2, 3, 4]) == 10;
    expect foldl(mult, 1, [1, 2, 3, 4]) == 24;
  }

  method {:test} FoldlReturnsTheAccumulatorForAnEmptyArray() {
    var empty: seq<int> := [];
    expect foldl(add, 0, empty) == 0;
    expect foldl(mult, 1, empty) == 1;
  }

  method {:test} FoldlIsAutomaticallyCurried() {
    var sum := (l: seq<int>) => foldl(add, 0, l);
    expect sum([1, 2, 3, 4]) == 10;
  }

  // "should be aliased by `reduce`" (strictEqual on the function objects has
  // no counterpart; the alias computes the same result)
  method {:test} FoldlIsAliasedByReduce() {
    expect reduce(add, 0, [1, 2, 3, 4]) == 10;
  }

  // describe('foldl1')
  method {:test} Foldl1FoldsWithoutAnAccumulator() {
    expect foldl1(add, [1, 2, 3, 4]) == 10;
    expect foldl1(mult, [1, 2, 3, 4]) == 24;
  }

  method {:test} Foldl1IsAutomaticallyCurried() {
    var sum := (l: seq<int>) requires |l| > 0 => foldl1(add, l);
    expect sum([1, 2, 3, 4]) == 10;
  }

  // describe('foldr')
  method {:test} FoldrFoldsListsInTheRightOrder() {
    expect foldr((a: string, b: string) => a + b, "", ["a", "b", "c", "d"]) == "abcd";
  }

  method {:test} FoldrFoldsWithTheSuppliedAccumulator() {
    expect foldr(avg, 54.0, [12.0, 4.0, 10.0, 6.0]) == 12.0;
  }

  method {:test} FoldrReturnsTheAccumulatorForAnEmptyArray() {
    var empty: seq<real> := [];
    expect foldr(avg, 0.0, empty) == 0.0;
  }

  method {:test} FoldrIsAutomaticallyCurried() {
    var something := (l: seq<real>) => foldr(avg, 54.0, l);
    expect something([12.0, 4.0, 10.0, 6.0]) == 12.0;
  }

  method {:test} FoldrIsAliasedByReduceRight() {
    expect reduceRight(avg, 54.0, [12.0, 4.0, 10.0, 6.0]) == 12.0;
  }

  // describe('foldr1')
  method {:test} Foldr1FoldsListsInTheRightOrder() {
    expect foldr1((a: string, b: string) => a + b, ["a", "b", "c", "d"]) == "abcd";
  }

  method {:test} Foldr1FoldsWithoutAnAccumulator() {
    expect foldr1(avg, [12.0, 4.0, 10.0, 6.0, 54.0]) == 12.0;
  }

  method {:test} Foldr1IsAutomaticallyCurried() {
    var something := (l: seq<real>) requires |l| > 0 => foldr1(avg, l);
    expect something([12.0, 4.0, 10.0, 6.0, 54.0]) == 12.0;
  }
}
