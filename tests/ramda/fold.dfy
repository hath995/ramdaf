// Ramda v0.29.0 test/reduce.js and reduceRight.js (v0.9.x foldl.js and
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
// a non-array object) is not transcribed. v0.23.0 passes reduceRight's
// callback the element first, so its string folds now concatenate in list
// order and `avg`, symmetric, is unchanged.
// (v0.26.0 removed the per-function "is curried" and "correctly reports the
// arity of curried versions" `it`s, with their transcriptions here.)

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

  // describe('reduceRight') (describe('foldr') until v0.9.1)
  // (`'dcba'` until v0.22.1, when the accumulator came first)
  method {:test} ReduceRightFoldsListsInTheRightOrder() {
    expect reduceRight((a: string, b: string) => a + b, "", ["a", "b", "c", "d"]) == "abcd";
  }

  // v0.23.0
  method {:test} ReduceRightFoldsSubtractOverArraysInTheRightOrder() {
    expect reduceRight((a: int, b: int) => a - b, 0, [1, 2, 3, 4]) == -2;
  }

  method {:test} ReduceRightFoldsWithTheSuppliedAccumulator() {
    expect reduceRight(avg, 54.0, [12.0, 4.0, 10.0, 6.0]) == 12.0;
  }

  method {:test} ReduceRightReturnsTheAccumulatorForAnEmptyArray() {
    var empty: seq<real> := [];
    expect reduceRight(avg, 0.0, empty) == 0.0;
  }

}
