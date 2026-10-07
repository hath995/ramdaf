// Ramda v0.7.2 test/test.fold.js, transcribed. Not transcribed: the "should
// correctly report the arity of curried versions" cases (Dafny functions have
// no arity) and the "throws on zero arguments" cases (v0.5.0; no-argument
// calls). The alias `it`s assert `strictEqual` on the function objects, which
// has no counterpart; the aliases are compared by their results. The
// callbacks Ramda declares with fewer parameters take all four here (README
// "Deviations"), and Ramda's `add` on strings (JS `+`) is string
// concatenation. Ramda's `ls === list` checks compare the list by value.
// v0.1.1 dropped the foldl1 and foldr1 describes, and v0.2.0 the functions.

module RamdafTests.Ramda.Fold {
  import opened Ramdaf.List

  function add(a: int, b: int): int { a + b }
  function mult(a: int, b: int): int { a * b }
  function avg(a: real, b: real): real { (a + b) / 2.0 }
  function cat(a: string, b: string): string { a + b }

  // describe('foldl')
  method {:test} FoldlFoldsWithTheSuppliedAccumulator() {
    expect foldl(add, 0, [1, 2, 3, 4]) == 10;
    expect foldl(mult, 1, [1, 2, 3, 4]) == 24;
  }

  // (v0.5.0 adds `foldl(R.concat, [], [])`)
  method {:test} FoldlReturnsTheAccumulatorForAnEmptyArray() {
    var empty: seq<int> := [];
    expect foldl(add, 0, empty) == 0;
    expect foldl(mult, 1, empty) == 1;
    var noLists: seq<seq<int>> := [];
    expect foldl((a: seq<int>, b: seq<int>) => a + b, [], noLists) == [];
  }

  // (v0.5.0 adds the string half, `foldl(add)('')`)
  method {:test} FoldlIsAutomaticallyCurried() {
    var sum := (l: seq<int>) => foldl(add, 0, l);
    expect sum([1, 2, 3, 4]) == 10;
    var catAll := (l: seq<string>) => foldl(cat, "", l);
    expect catAll(["1", "2", "3", "4"]) == "1234";
  }

  // (since v0.7.0 only `strictEqual(R.reduce, R.foldl)`)
  method {:test} FoldlIsAliasedByReduce() {
    expect reduce(add, 0, [1, 2, 3, 4]) == 10;
    expect reduce(add, 0, [1, 2, 3, 4]) == foldl(add, 0, [1, 2, 3, 4]);
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

  // (v0.5.0 adds `foldr(R.add, '')` on strings)
  method {:test} FoldrIsAutomaticallyCurried() {
    var something := (l: seq<real>) => foldr(avg, 54.0, l);
    expect something([12.0, 4.0, 10.0, 6.0]) == 12.0;
    var rcat := (l: seq<string>) => foldr(cat, "", l);
    expect rcat(["1", "2", "3", "4"]) == "4321";
  }

  // (since v0.7.0 only `strictEqual(R.reduceRight, R.foldr)`)
  method {:test} FoldrIsAliasedByReduceRight() {
    expect reduceRight(avg, 54.0, [12.0, 4.0, 10.0, 6.0]) == 12.0;
    expect reduceRight(avg, 54.0, [12.0, 4.0, 10.0, 6.0]) == foldr(avg, 54.0, [12.0, 4.0, 10.0, 6.0]);
  }

  // describe('foldl.idx')
  function timesIdx(tot: int, num: int, idx: nat, ls: seq<int>): int { tot + num * idx }

  // (v0.5.0 gives it a body: `foldl.idx(R.add, 0, …)`, `foldl.idx(R.multiply, 1, …)`)
  method {:test} FoldlIdxWorksJustLikeNormalFoldl() {
    expect foldlIdx((a: int, x: int, i: nat, l: seq<int>) => add(a, x), 0, [1, 2, 3, 4]) == 10;
    expect foldlIdx((a: int, x: int, i: nat, l: seq<int>) => mult(a, x), 1, [1, 2, 3, 4]) == 24;
  }

  // v0.5.0: "should be aliased by `reduceRight`" (under foldl.idx, it asserts
  // `reduceRight === foldr`)
  method {:test} FoldlIdxDescribeAliasesReduceRightToFoldr() {
    expect reduceRight(add, 0, [1, 2, 3]) == foldr(add, 0, [1, 2, 3]);
  }

  // `objectify` assigns `acc[elem] = idx` on an object.
  method {:test} FoldlIdxPassesTheIndexAsAThirdParameter() {
    expect foldlIdx(timesIdx, 0, [1, 2, 3, 4, 5]) == 40;
    var empty: map<string, nat> := map[];
    expect foldlIdx((acc: map<string, nat>, elem: string, idx: nat, ls: seq<string>) => acc[elem := idx],
                    empty, ["a", "b", "c", "d", "e"]) == map["a" := 0, "b" := 1, "c" := 2, "d" := 3, "e" := 4];
  }

  // (v0.5.0 gives it a body)
  method {:test} FoldlIdxPassesTheEntireListAsAFourthParameter() {
    var list := [1, 2, 3];
    expect foldlIdx((acc: bool, x: int, idx: nat, ls: seq<int>) => acc && ls == list, true, list);
  }

  // v0.5.0
  method {:test} FoldlIdxIsAutomaticallyCurried() {
    var sum := (l: seq<int>) => foldlIdx((a: int, x: int, i: nat, ls: seq<int>) => add(a, x), 0, l);
    expect sum([1, 2, 3, 4]) == 10;
    var catAll := (l: seq<string>) => foldlIdx((a: string, x: string, i: nat, ls: seq<string>) => cat(a, x), "", l);
    expect catAll(["1", "2", "3", "4"]) == "1234";
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

  // "should be aliased by `reduceRight.idx`" (`reduceRight.idx === foldr.idx`;
  // until v0.4.3 it was named "… by `reduceRight`")
  method {:test} FoldrIdxIsAliasedByReduceRightIdx() {
    expect reduceRightIdx((acc: int, b: int, i: nat, ls: seq<int>) => acc + i + b, 54, [12, 4, 10, 6]) == 92;
  }

  // v0.5.0
  method {:test} FoldrIdxPassesTheIndexAsAThirdParameter() {
    expect foldrIdx(timesIdx, 0, [1, 2, 3, 4, 5]) == 40;
    var empty: map<string, nat> := map[];
    expect foldrIdx((acc: map<string, nat>, elem: string, idx: nat, ls: seq<string>) => acc[elem := idx],
                    empty, ["a", "b", "c", "d", "e"]) == map["a" := 0, "b" := 1, "c" := 2, "d" := 3, "e" := 4];
  }

  // v0.5.0
  method {:test} FoldrIdxPassesTheEntireListAsAFourthParameter() {
    var list := [1, 2, 3];
    expect foldrIdx((acc: bool, x: int, idx: nat, ls: seq<int>) => acc && ls == list, true, list);
  }

  // v0.5.0: the second "should be automatically curried" (`foldr.idx(R.add)`)
  method {:test} FoldrIdxIsAutomaticallyCurriedWithAdd() {
    var sum := (l: seq<int>) => foldrIdx((a: int, x: int, i: nat, ls: seq<int>) => add(a, x), 0, l);
    expect sum([1, 2, 3, 4]) == 10;
    var catAll := (l: seq<string>) => foldrIdx((a: string, x: string, i: nat, ls: seq<string>) => cat(a, x), "", l);
    expect catAll(["1", "2", "3", "4"]) == "4321";
  }

  // `'' + n` for the index in "folds lists in the right order"
  function NumStr(n: nat): string
  { if n < 10 then [('0' as int + n) as char] else NumStr(n / 10) + NumStr(n % 10) }
}
