// Ramda v0.14.0 test/reduce.js, reduceRight.js, reduceIndexed.js and
// reduceRightIndexed.js (v0.9.x foldl.js, foldr.js, foldlIndexed.js and
// foldrIndexed.js; until v0.8.0 test.fold.js), transcribed. Not transcribed:
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

  // describe('reduceIndexed') (describe('foldlIndexed') until v0.9.1,
  // describe('foldl.idx') until v0.8.0)
  function timesIndexed(tot: int, num: int, idx: nat, ls: seq<int>): int { tot + num * idx }

  // (v0.5.0 gives it a body: `foldl.idx(R.add, 0, …)`, `foldl.idx(R.multiply, 1, …)`)
  method {:test} ReduceIndexedWorksJustLikeNormalReduce() {
    expect reduceIndexed((a: int, x: int, i: nat, l: seq<int>) => add(a, x), 0, [1, 2, 3, 4]) == 10;
    expect reduceIndexed((a: int, x: int, i: nat, l: seq<int>) => mult(a, x), 1, [1, 2, 3, 4]) == 24;
  }

  // `objectify` assigns `acc[elem] = idx` on an object.
  method {:test} ReduceIndexedPassesTheIndexAsAThirdParameter() {
    expect reduceIndexed(timesIndexed, 0, [1, 2, 3, 4, 5]) == 40;
    var empty: map<string, nat> := map[];
    expect reduceIndexed((acc: map<string, nat>, elem: string, idx: nat, ls: seq<string>) => acc[elem := idx],
                    empty, ["a", "b", "c", "d", "e"]) == map["a" := 0, "b" := 1, "c" := 2, "d" := 3, "e" := 4];
  }

  // (v0.5.0 gives it a body)
  method {:test} ReduceIndexedPassesTheEntireListAsAFourthParameter() {
    var list := [1, 2, 3];
    expect reduceIndexed((acc: bool, x: int, idx: nat, ls: seq<int>) => acc && ls == list, true, list);
  }

  // v0.5.0
  method {:test} ReduceIndexedIsAutomaticallyCurried() {
    var sum := (l: seq<int>) => reduceIndexed((a: int, x: int, i: nat, ls: seq<int>) => add(a, x), 0, l);
    expect sum([1, 2, 3, 4]) == 10;
    var catAll := (l: seq<string>) => reduceIndexed((a: string, x: string, i: nat, ls: seq<string>) => cat(a, x), "", l);
    expect catAll(["1", "2", "3", "4"]) == "1234";
  }

  // describe('reduceRightIndexed') (describe('foldrIndexed') until v0.9.1,
  // describe('foldr.idx') until v0.8.0)
  method {:test} ReduceRightIndexedFoldsListsInTheRightOrder() {
    expect reduceRightIndexed((a: string, b: string, idx: nat, list: seq<string>) => a + NumStr(idx) + b, "",
                    ["a", "b", "c", "d"]) == "3d2c1b0a";
  }

  method {:test} ReduceRightIndexedFoldsWithTheSuppliedAccumulator() {
    var empty: seq<int> := [];
    expect reduceRightIndexed((acc: seq<int>, n: int, i: nat, ls: seq<int>) => acc + [i, n], empty, [12, 4, 10, 6]) ==
      [3, 6, 2, 10, 1, 4, 0, 12];
  }

  // The result is the accumulator itself (v0.2.3 asserts `memo`; before, it
  // asserted `== 0`, which JS's `[] == 0` satisfies).
  method {:test} ReduceRightIndexedReturnsTheAccumulatorForAnEmptyArray() {
    var empty: seq<int> := [];
    expect reduceRightIndexed((a: seq<int>, n: int, i: nat, ls: seq<int>) => a + [i], empty, empty) == empty;
  }

  method {:test} ReduceRightIndexedIsAutomaticallyCurried() {
    var something := (l: seq<int>) => reduceRightIndexed((acc: int, b: int, i: nat, ls: seq<int>) => acc + i + b, 54, l);
    expect something([12, 4, 10, 6]) == 92;
  }

  // v0.5.0
  method {:test} ReduceRightIndexedPassesTheIndexAsAThirdParameter() {
    expect reduceRightIndexed(timesIndexed, 0, [1, 2, 3, 4, 5]) == 40;
    var empty: map<string, nat> := map[];
    expect reduceRightIndexed((acc: map<string, nat>, elem: string, idx: nat, ls: seq<string>) => acc[elem := idx],
                    empty, ["a", "b", "c", "d", "e"]) == map["a" := 0, "b" := 1, "c" := 2, "d" := 3, "e" := 4];
  }

  // v0.5.0
  method {:test} ReduceRightIndexedPassesTheEntireListAsAFourthParameter() {
    var list := [1, 2, 3];
    expect reduceRightIndexed((acc: bool, x: int, idx: nat, ls: seq<int>) => acc && ls == list, true, list);
  }

  // v0.5.0: the second "should be automatically curried" (`reduceRightIndexed(R.add)`)
  method {:test} ReduceRightIndexedIsAutomaticallyCurriedWithAdd() {
    var sum := (l: seq<int>) => reduceRightIndexed((a: int, x: int, i: nat, ls: seq<int>) => add(a, x), 0, l);
    expect sum([1, 2, 3, 4]) == 10;
    var catAll := (l: seq<string>) => reduceRightIndexed((a: string, x: string, i: nat, ls: seq<string>) => cat(a, x), "", l);
    expect catAll(["1", "2", "3", "4"]) == "4321";
  }

  // `'' + n` for the index in "folds lists in the right order"
  function NumStr(n: nat): string
  { if n < 10 then [('0' as int + n) as char] else NumStr(n / 10) + NumStr(n % 10) }
}
