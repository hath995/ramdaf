// Edge cases Ramda v0.1.4's own suite does not cover, each checked against
// ramda.js v0.1.4 under node (the expected values are node's output). The
// last methods pin the documented deviations (README "Deviations").

module RamdafTests.Edge.List {
  import opened Ramdaf.Prelude
  import opened Ramdaf.Core
  import opened Ramdaf.List
  import opened Support

  method {:test} CoreEdges() {
    var empty: seq<int> := [];
    expect tail([1]) == [];
    expect tail(empty) == [];
    expect tail([1, 2]) == [2];
    expect head([5]) == 5;
    expect first([1, 2, 3]) == 1;
    expect last([1, 2, 3]) == 3;
    expect last([5]) == 5;
    expect isEmpty([0]) == false;
    expect merge(empty, [1]) == [1];
    expect merge([1], empty) == [1];
    expect append(1, empty) == [1];
    expect prepend(1, empty) == [1];
    expect size(empty) == 0;
    expect clone([1, 2]) == [1, 2];
    expect identity(3) == 3;
    expect cloneDeep([[1], [2, 3]]) == [[1], [2, 3]];
    expect cloneDeep(map["a" := 1]) == map["a" := 1];
    expect repeatN(7, 0) == [];
    expect repeatN("a", 2) == ["a", "a"];
    expect repeatN(7, -2) == [];
  }

  // foldr runs from the right with the accumulator first (since v0.1.1), and
  // so does foldr1, which seeds it with the last element.
  method {:test} FoldrRunsFromTheRightAccumulatorFirst() {
    var empty: seq<int> := [];
    expect foldr((acc: seq<int>, x: int) => [x] + acc, empty, [1, 2]) == [1, 2];
    expect foldr((acc: string, a: string) => acc + a, "", ["x", "y", "z"]) == "zyx";
    expect foldr((acc: int, a: int) => acc - a, 0, [1, 2, 3, 4]) == -10;
    expect foldr1((acc: int, a: int) => acc - a, [1, 2, 3]) == 0;
    expect foldr1((acc: int, a: int) => acc - a, [5]) == 5;
    expect foldr1((a: string, b: string) => a + b, ["a", "b", "c", "d"]) == "dcba";
  }

  // The idx folds pass (acc, element, index, list).
  method {:test} IdxFoldsPassTheIndexAndList() {
    var empty: seq<string> := [];
    var f := (acc: string, x: string, i: nat, l: seq<string>) => acc + x + NumStr(i) + NumStr(|l|);
    expect foldlIdx(f, "", ["a", "b"]) == "a02b12";
    expect foldrIdx(f, "", ["a", "b"]) == "b12a02";
    expect foldlIdx(f, "5", empty) == "5";
    expect reduceIdx((acc: int, x: int, i: nat, l: seq<int>) => acc + x * i, 0, [1, 2, 3]) == 8;
    var none: seq<nat> := [];
    expect reduceRightIdx((acc: seq<nat>, x: int, i: nat, l: seq<int>) => acc + [i], none, [9, 9, 9]) == [2, 1, 0];
  }

  method {:test} IdxMapFilterRejectEdges() {
    var empty: seq<int> := [];
    expect mapIdx((x: int, i: nat, l: seq<int>) => x + i, empty) == [];
    expect mapIdx((x: int, i: nat, l: seq<int>) => |l| - i, [5, 5, 5]) == [3, 2, 1];
    expect filterIdx((x: int, i: nat, l: seq<int>) => i == 1, [7, 7, 7]) == [7];
    expect filterIdx((x: int, i: nat, l: seq<int>) => false, [1, 2]) == [];
    expect filterIdx((x: int, i: nat, l: seq<int>) => i < |l|, [1, 2]) == [1, 2];
    expect rejectIdx((x: int, i: nat, l: seq<int>) => i == 1, [7, 7, 7]) == [7, 7];
    expect rejectIdx((x: int, i: nat, l: seq<int>) => true, empty) == [];
  }

  // findLast/findLastIndex never test index 0 (the `while (--idx)` loop).
  method {:test} FindFamilyEdges() {
    var empty: seq<int> := [];
    expect findIndex((x: int) => true, empty) == None;
    expect findIndex((x: int) => x > 1, [1, 2, 3]) == Some(1);
    expect findIndex((x: int) => x > 9, [1, 2, 3]) == None;
    expect findLastIndex((x: int) => x == 1, [1, 2, 3]) == None;
    expect findLastIndex((x: int) => x > 1, [1, 2, 3]) == Some(2);
    expect findLastIndex((x: int) => true, [5]) == None;
    expect findLast((x: int) => x == 1, [1, 2, 3]) == None;
    expect findLast((x: int) => x < 3, [1, 2, 3]) == Some(2);
    expect findLast((x: int) => true, [5]) == None;
    expect findLast((x: int) => x % 2 == 0, [2, 4, 1]) == Some(4);
  }

  // Array.prototype.slice: negative indices count from the end, both are
  // clamped, and an empty range gives [].
  method {:test} SliceClampsLikeJs() {
    var l := [1, 2, 3, 4, 5];
    expect slice(1, 3, l) == [2, 3];
    expect slice(-2, 100, l) == [4, 5];
    expect slice(3, 1, l) == [];
    expect slice(-100, 2, l) == [1, 2];
    expect slice(2, -1, l) == [3, 4];
    expect slice(0, 0, l) == [];
    expect slice(5, 5, l) == [];
    expect slice(-2, -1, l) == [4];
    expect slice(10, 20, l) == [];
    expect sliceFrom(2, [1, 2, 3]) == [3];
    expect sliceFrom(-2, [1, 2, 3]) == [2, 3];
  }

  function parity(x: int): string { if x % 2 == 0 then "even" else "odd" }

  // partition groups by whatever key the function returns.
  method {:test} PartitionEdges() {
    var empty: seq<int> := [];
    expect partition(parity, [1, 2, 3, 4, 5]) == map["odd" := [1, 3, 5], "even" := [2, 4]];
    expect partition((x: int) => "k", empty) == map[];
    // `String(x > 2)`: a predicate's results as keys
    expect partition((x: int) => if x > 2 then "true" else "false", [1, 3, 2, 4]) == map["false" := [1, 2], "true" := [3, 4]];
    expect partition((s: string) => s, ["b", "a", "b"]) == map["b" := ["b", "b"], "a" := ["a"]];
  }

  method {:test} MapObjEdges() {
    var none: map<string, int> := map[];
    expect mapObj((v: int) => v + 1, none) == map[];
    expect mapObj((v: int) => v * 2, map["a" := 1]) == map["a" := 2];
  }

  // isSet(list) is `uniq(list).length === list.length`.
  method {:test} IsSetEdges() {
    var empty: seq<int> := [];
    expect isSet(empty) == true;
    expect isSet([1, 2, 1]) == false;
    expect isSet(["a", "b"]) == true;
    expect isSet([3, 3]) == false;
    var lists := [[1, 2, 1, 3, 2], [4, 5], [6, 6, 6], empty];
    for i := 0 to |lists| {
      expect isSet(lists[i]) == (|uniq(lists[i])| == |lists[i]|);
    }
  }

  method {:test} FoldlIsLeftAssociative() {
    expect foldl((acc: int, x: int) => acc - x, 0, [1, 2, 3]) == -6;
    expect foldl((acc: string, x: string) => acc + x, "", ["a", "b", "c"]) == "abc";
    expect foldl1((a: int, b: int) => a - b, [1, 2, 3]) == -4;
    expect foldl1((a: int, b: int) => a - b, [5]) == 5;
  }

  // uniq keeps the last occurrence of each element.
  method {:test} UniqKeepsLastOccurrences() {
    expect uniq([1, 2, 1, 3, 2]) == [1, 3, 2];
    expect uniq([3, 3, 3]) == [3];
  }

  method {:test} TakeSkipEdges() {
    expect take(0, [1, 2]) == [];
    expect take(2, [1, 2]) == [1, 2];
    expect skip(5, [1, 2]) == [];
    expect skip(0, [1, 2]) == [1, 2];
    expect skip(2, [1, 2]) == [];
  }

  method {:test} ZipEdges() {
    var empty: seq<int> := [];
    expect zip([1], [3, 4]) == [(1, 3)];
    expect zip(empty, [1]) == [];
    expect zipWith((a: int, b: int) => a + b, [1, 2], [10, 20, 30]) == [11, 22];
  }

  // Array.prototype.splice clamping: a negative start counts from the end.
  method {:test} SpliceClampsLikeJs() {
    expect splice(1, 2, [1, 2, 3, 4, 5]) == [1, 4, 5];
    expect splice(-2, 1, [1, 2, 3, 4]) == [1, 2, 4];
    expect splice(1, 10, [1, 2, 3]) == [1];
    expect splice(5, 1, [1, 2]) == [1, 2];
    expect splice(1, -1, [1, 2, 3]) == [1, 2, 3];
    expect splice(-10, 1, [1, 2, 3]) == [2, 3];
    expect splice(-1, 5, [1, 2, 3]) == [1, 2];
    expect splice(0, 0, [1, 2, 3]) == [1, 2, 3];
  }

  method {:test} NthEdges() {
    expect nth(-1, [1, 2]) == None;
    expect nth(9, [1, 2]) == None;
    expect nth(0, [1, 2]) == Some(1);
  }

  method {:test} JoinEdges() {
    var empty: seq<string> := [];
    expect join(",", empty) == "";
    expect join("-", ["a"]) == "a";
    expect join("", ["a", "b"]) == "ab";
  }

  method {:test} RangeEdges() {
    expect range(-2, 2) == [-2, -1, 0, 1];
    expect range(3, 3) == [];
  }

  method {:test} FindTakeWhileSkipUntilEdges() {
    var empty: seq<int> := [];
    expect find((x: int) => x > 9, [1, 2]) == None;
    expect find((x: int) => x > 1, [1, 2, 3]) == Some(2);
    expect takeWhile((x: int) => x < 3, [1, 2, 3, 1]) == [1, 2];
    expect takeWhile((x: int) => x > 0, empty) == [];
    expect skipUntil((x: int) => x > 2, [1, 2, 3, 1]) == [3, 1];
    expect skipUntil((x: int) => x > 0, empty) == [];
  }

  method {:test} FlattenEdges() {
    var empty: seq<Tree<int>> := [];
    expect flatten(empty) == [];
    expect flatten([Node(empty)]) == [];
    expect flatten([Leaf(1), Node(empty), Node([Node([Leaf(2)])])]) == [1, 2];
  }

  // A falsy result (or an empty pair) stops the unfold.
  method {:test} UnfoldrStopsAtNone() {
    expect unfoldr((n: int) => if n < 3 then Some((n, n + 1)) else None, 0, 100) == [0, 1, 2];
  }

  method {:test} PluckMissingIsUndefined() {
    expect pluck("nope", [map["a" := 1]]) == [None];
    expect pluck("a", [map["a" := 1], map["b" := 2]]) == [Some(1), None];
  }

  method {:test} MiscListEdges() {
    var empty: seq<int> := [];
    expect reverse([1]) == [1];
    expect indexOf(2, [1, 2, 3, 2]) == 1;
    expect lastIndexOf(2, [1, 2, 3, 2]) == 3;
    expect xprod(empty, [1]) == [];
    expect xprod([1], empty) == [];
    expect all((x: int) => x > 0, empty) == true;
    expect any((x: int) => x > 0, empty) == false;
    expect reject((x: int) => x > 1, [1, 2, 3]) == [1];
    expect contains(3, [1, 2]) == false;
    expect mapSeq((x: int) => x * x, empty) == [];
  }

  // ---- documented deviations (not node behaviour) ----

  // JS unfoldr would loop forever here; the fuel bound stops it.
  method {:test} DeviationUnfoldrStopsAtFuel() {
    expect unfoldr((n: int) => Some((n, n + 1)), 0, 3) == [0, 1, 2];
  }
}
