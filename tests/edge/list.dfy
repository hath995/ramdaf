// Edge cases Ramda v0.1.0's own suite does not cover, each checked against
// ramda.js v0.1.0 under node (the expected values are node's output). The
// last methods pin the documented deviations (README "Deviations").

module RamdafTests.Edge.List {
  import opened Ramdaf.Prelude
  import opened Ramdaf.Core
  import opened Ramdaf.List

  method {:test} CoreEdges() {
    var empty: seq<int> := [];
    expect tail([1]) == [];
    expect tail(empty) == [];
    expect tail([1, 2]) == [2];
    expect head([5]) == 5;
    expect isEmpty([0]) == false;
    expect merge(empty, [1]) == [1];
    expect merge([1], empty) == [1];
    expect append(1, empty) == [1];
    expect prepend(1, empty) == [1];
    expect size(empty) == 0;
    expect clone([1, 2]) == [1, 2];
    expect identity(3) == 3;
  }

  // foldr folds from the right with the element first.
  method {:test} FoldrIsRightAssociative() {
    var empty: seq<int> := [];
    expect foldr((x: int, acc: seq<int>) => [x] + acc, empty, [1, 2]) == [1, 2];
    expect foldr((a: string, acc: string) => a + acc, "", ["x", "y", "z"]) == "xyz";
    expect foldr((a: int, acc: int) => a - acc, 0, [1, 2, 3, 4]) == -2;
    expect foldr1((a: int, acc: int) => a - acc, [1, 2, 3]) == 2;
    expect foldr1((a: int, acc: int) => a - acc, [5]) == 5;
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
