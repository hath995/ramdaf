// Ramda v0.17.0 test/reduce.js and reduceRight.js (v0.9.x foldl.js and
// foldr.js; until v0.8.0 test.fold.js), transcribed (reduceIndexed.js and
// reduceRightIndexed.js, foldlIndexed.js and foldrIndexed.js in v0.9.x, went
// with the functions in v0.16.0). Not transcribed:
// the "should correctly report the arity of curried versions" cases (Dafny
// functions have no arity) and the "throws on zero arguments" cases (v0.5.0
// to v0.10.0; no-argument calls). The alias `it`s assert `strictEqual` on the function
// objects, which has no counterpart; the aliases are compared by their
// results. The callbacks Ramda declares with fewer parameters take all four
// here (README "Deviations"), and Ramda's `add` on strings (JS `+`) is
// string concatenation. Ramda's `ls === list` checks compare the list by
// value. v0.1.1 dropped the foldl1 and foldr1 describes, and v0.2.0 the
// functions. v0.9.0 removed the four "is aliased by `reduce…`" `it`s with
// `reduce` and `reduceRight`, and renamed the foldl.idx and foldr.idx
// describes to foldlIndexed and foldrIndexed (and `timesIndexed` to
// `timesIndexed`). v0.10.0 renamed the four describes and files to reduce,
// reduceRight, reduceIndexed and reduceRightIndexed, with the same `it`s
// ("works just like normal foldl" became "… normal reduce"). v0.12.0's
// reduce "dispatches to objects that implement `reduce`" (method dispatch on
// a non-array object) is not transcribed.

module RamdafTests.Ramda.Fold {
  import opened Ramdaf.List

  function add(a: int, b: int): int { a + b }
  function mult(a: int, b: int): int { a * b }
  function avg(a: real, b: real): real { (a + b) / 2.0 }
  function cat(a: string, b: string): string { a + b }

  // describe('reduce') (describe('foldl') until v0.9.1)
  method {:test} ReduceFoldsWithTheSuppliedAccumulator() {
    expect reduce(add, 0, [1, 2, 3, 4]) == 10;
    expect reduce(mult, 1, [1, 2, 3, 4]) == 24;
  }

  // (v0.5.0 adds `foldl(R.concat, [], [])`)
  method {:test} ReduceReturnsTheAccumulatorForAnEmptyArray() {
    var empty: seq<int> := [];
    expect reduce(add, 0, empty) == 0;
    expect reduce(mult, 1, empty) == 1;
    var noLists: seq<seq<int>> := [];
    expect reduce((a: seq<int>, b: seq<int>) => a + b, [], noLists) == [];
  }

  // (v0.5.0 adds the string half, `foldl(add)('')`)
  method {:test} ReduceIsAutomaticallyCurried() {
    var sum := (l: seq<int>) => reduce(add, 0, l);
    expect sum([1, 2, 3, 4]) == 10;
    var catAll := (l: seq<string>) => reduce(cat, "", l);
    expect catAll(["1", "2", "3", "4"]) == "1234";
  }

  // describe('reduceRight') (describe('foldr') until v0.9.1)
  method {:test} ReduceRightFoldsListsInTheRightOrder() {
    expect reduceRight((a: string, b: string) => a + b, "", ["a", "b", "c", "d"]) == "dcba";
  }

  method {:test} ReduceRightFoldsWithTheSuppliedAccumulator() {
    expect reduceRight(avg, 54.0, [12.0, 4.0, 10.0, 6.0]) == 12.0;
  }

  method {:test} ReduceRightReturnsTheAccumulatorForAnEmptyArray() {
    var empty: seq<real> := [];
    expect reduceRight(avg, 0.0, empty) == 0.0;
  }

  // (v0.5.0 adds `foldr(R.add, '')` on strings)
  method {:test} ReduceRightIsAutomaticallyCurried() {
    var something := (l: seq<real>) => reduceRight(avg, 54.0, l);
    expect something([12.0, 4.0, 10.0, 6.0]) == 12.0;
    var rcat := (l: seq<string>) => reduceRight(cat, "", l);
    expect rcat(["1", "2", "3", "4"]) == "4321";
  }
}
