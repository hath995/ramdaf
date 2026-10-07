// Ramda v0.4.0 test/test.fold.js, transcribed. Not transcribed: the "should
// correctly report the arity of curried versions" cases (Dafny functions have
// no arity), and foldl.idx's "works just like normal foldl" and "passes the
// entire list as a fourth parameter" (both have empty bodies in Ramda).
// v0.1.1 dropped the foldl1 and foldr1 describes, and v0.2.0 the functions.

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

  // describe('foldr')
  method {:test} FoldrFoldsListsInTheRightOrder() {
    expect foldr((a: string, b: string) => a + b, "", ["a", "b", "c", "d"]) == "dcba";
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

  // describe('foldl.idx')
  function timesIdx(tot: int, num: int, idx: nat, ls: seq<int>): int { tot + num * idx }

  // `objectify` assigns `acc[elem] = idx` on an object.
  method {:test} FoldlIdxPassesTheIndexAsAThirdParameter() {
    expect foldlIdx(timesIdx, 0, [1, 2, 3, 4, 5]) == 40;
    var empty: map<string, nat> := map[];
    expect foldlIdx((acc: map<string, nat>, elem: string, idx: nat, ls: seq<string>) => acc[elem := idx],
                    empty, ["a", "b", "c", "d", "e"]) == map["a" := 0, "b" := 1, "c" := 2, "d" := 3, "e" := 4];
  }

  // describe('foldr.idx')
  method {:test} FoldrIdxFoldsListsInTheRightOrder() {
    expect foldrIdx((a: string, b: string, idx: nat, list: seq<string>) => a + NumStr(idx) + b, "",
                    ["a", "b", "c", "d"]) == "3d2c1b0a";
  }

  method {:test} FoldrIdxFoldsWithTheSuppliedAccumulator() {
    var empty: seq<int> := [];
    expect foldrIdx((acc: seq<int>, n: int, i: nat, ls: seq<int>) => acc + [i, n], empty, [12, 4, 10, 6]) ==
      [3, 6, 2, 10, 1, 4, 0, 12];
  }

  // The result is the accumulator itself (v0.2.3 asserts `memo`; before, it
  // asserted `== 0`, which JS's `[] == 0` satisfies).
  method {:test} FoldrIdxReturnsTheAccumulatorForAnEmptyArray() {
    var empty: seq<int> := [];
    expect foldrIdx((a: seq<int>, n: int, i: nat, ls: seq<int>) => a + [i], empty, empty) == empty;
  }

  method {:test} FoldrIdxIsAutomaticallyCurried() {
    var something := (l: seq<int>) => foldrIdx((acc: int, b: int, i: nat, ls: seq<int>) => acc + i + b, 54, l);
    expect something([12, 4, 10, 6]) == 92;
  }

  // "should be aliased by `reduceRight`" (`reduceRight.idx === foldr.idx`)
  method {:test} FoldrIdxIsAliasedByReduceRightIdx() {
    expect reduceRightIdx((acc: int, b: int, i: nat, ls: seq<int>) => acc + i + b, 54, [12, 4, 10, 6]) == 92;
  }

  // `'' + n` for the index in "folds lists in the right order"
  function NumStr(n: nat): string
  { if n < 10 then [('0' as int + n) as char] else NumStr(n / 10) + NumStr(n % 10) }
}
