// Ramda v0.32.0 test/project.js, propEq.js, union.js, unionWith.js,
// intersection.js, difference.js, differenceWith.js,
// countBy.js, sortBy.js, equals.js, identical.js, eqBy.js,
// symmetricDifference.js, symmetricDifferenceWith.js, clamp.js and
// innerJoin.js (until v0.8.0
// test.sql.js, whose copy of the groupBy describe v0.9.0 dropped; eq.js and
// eqDeep.js, restored in v0.15.1, went with the functions in v0.16.0),
// transcribed. Not transcribed:
// - the "has R.equals semantics" `it`s (v0.15.0) of union, intersection,
//   difference and propEq (v0.14.0's "has Object.is semantics" for
//   propEq): `-0` and NaN are not ints, and their `Just` objects carry an
//   `equals` method (README "Deviations"; pinned in tests/edge/); v0.15.0
//   removed the three "does not work for non-primitives" cases (`===`
//   compared distinct-but-equal objects by reference, which in v0.15.0
//   alone union did, through uniq's `Set`);
// - describe('sortBy'), which sorts by a string title: sortBy keys are ints
//   (README "Deviations"); its v0.10.0 "preserves object identity" (reference
//   identity, by a string key) and "sorts array-like object" (`arguments`,
//   by a string key) likewise;
// - equals.js's (eqDeep.js's from v0.9.0 to v0.14.0) "handles regex",
//   "handles dates", "handles typed arrays" (no such values), the cyclic
//   `c`/`d` and `e`/`f` lines of "handles recursive data structures" (a
//   Dafny value cannot contain itself), "throws if given no arguments"
//   (until v0.10.0), and v0.15.0's boxed-primitive `it`s (`new Boolean`,
//   `new Number`, `new String`) and "dispatches to `equals` method"
//   (objects with methods; v0.18.0 replaces it with "dispatches to `equals`
//   method recursively" and "is commutative", both on such objects), and
//   v0.18.0's `it`s on `arguments` objects, Maps, Sets, WeakMaps, WeakSets
//   and boxed values with extra properties (no such values). Its mixed
//   values are Js;
// - identical.js's `[] !== []`, `-0`, NaN and `new Number(0)` lines and its
//   "is curried" (until v0.25.0), which compared two arrays by reference
//   (README "Deviations"), and v0.29.0's cross-origin `it` (a Proxy);
// - eqBy.js's (v0.18.0) and symmetricDifference.js's (v0.19.0) "has
//   R.equals semantics" (`-0`, NaN and `Just` objects with an `equals`
//   method), and equals.js's v0.19.0 "considers equivalent Error objects
//   equal" (no Error values) and v0.20.0 "compares Promise objects by
//   identity" (no Promises);
// - clamp.js's (v0.20.0) "works with letters as well": clamp takes ints
//   (README "Deviations").
// (v0.25.0 removed intersectionWith.js with the function.)
// innerJoin.js's (v0.24.0) records `{id, name}` are the local datatype Rec,
// and its `f = R.innerJoin((r, id) => r.id === id)` a lambda.
// (v0.26.0 removed the per-function "is curried" `it`s, with their
// transcriptions here.)

module RamdafTests.Ramda.Sql {
  import opened Ramdaf.Prelude
  import opened Ramdaf.List
  import opened Ramdaf.Object
  import opened Ramdaf.Data
  import opened Support

  function Kid(name: string, age: int, other: string, value: string): map<string, Js>
  { map["name" := Str(name), "age" := Num(age), other := Str(value)] }

  function Kids(): seq<map<string, Js>>
  { [Kid("Abby", 7, "hair", "blond"), Kid("Fred", 12, "hair", "brown"),
     Kid("Rusty", 10, "hair", "brown"), Kid("Alois", 15, "disposition", "surly")] }

  // describe('project')
  method {:test} ProjectSelectsTheChosenProperties() {
    expect project(["name", "age"], Kids()) == [
      map["name" := Some(Str("Abby")), "age" := Some(Num(7))],
      map["name" := Some(Str("Fred")), "age" := Some(Num(12))],
      map["name" := Some(Str("Rusty")), "age" := Some(Num(10))],
      map["name" := Some(Str("Alois")), "age" := Some(Num(15))]];
  }

  // "should have an undefined property on the output tuple for any input tuple
  // that does not have the property"
  method {:test} ProjectHasUndefinedForMissingProperties() {
    expect project(["name", "hair"], Kids()) == [
      map["name" := Some(Str("Abby")), "hair" := Some(Str("blond"))],
      map["name" := Some(Str("Fred")), "hair" := Some(Str("brown"))],
      map["name" := Some(Str("Rusty")), "hair" := Some(Str("brown"))],
      map["name" := Some(Str("Alois")), "hair" := None]];
  }

  // describe('propEq'): v0.29.0 moves the value first, `propEq(val, name,
  // obj)`, over the four kids (v0.17.0 restored `propEq(name, val, obj)` and
  // the v0.15.1 `it`s; v0.16.0 alone moved the value first, over `abby` and
  // `fred`); its "handles number as property" (array indices) and nil-object
  // lines are not transcribed.
  method {:test} PropEqDeterminesWhetherAParticularPropertyMatchesAGivenValue() {
    var kids := Kids();
    expect propEq(Str("Abby"), "name", kids[0]) == true;
    expect propEq(Str("brown"), "hair", kids[1]) == true;
    expect propEq(Str("blond"), "hair", kids[1]) == false;
  }

  function R(): seq<int> { [1, 2, 3, 4] }
  function R2(): seq<int> { [1, 2, 3, 4, 1, 2, 3, 4] }
  function S(): seq<int> { [3, 4, 5, 6] }
  function S2(): seq<int> { [3, 3, 4, 4, 5, 5, 6, 6] }
  function Z(): seq<int> { [3, 4, 5, 6, 10] }
  function Z2(): seq<int> { [1, 2, 3, 3, 4, 4, 5, 5, 6, 6, 7, 8] }
  function A(n: int): map<string, int> { map["a" := n] }
  function Ro(): seq<map<string, int>> { [A(1), A(2), A(3), A(4)] }
  function So(): seq<map<string, int>> { [A(3), A(4), A(5), A(6)] }
  function EqA(r: map<string, int>, s: map<string, int>): bool { Field(r, "a") == Field(s, "a") }

  // describe('union')
  method {:test} UnionCombinesIntoTheSetOfAllElements() {
    expect union(R(), S()) == [1, 2, 3, 4, 5, 6];
  }

  // describe('unionWith')
  method {:test} UnionWithUsesThePredicate() {
    expect unionWith(EqA, Ro(), So()) == [A(1), A(2), A(3), A(4), A(5), A(6)];
  }

  // describe('intersection')
  method {:test} IntersectionCombinesIntoTheCommonElements() {
    expect intersection(R(), S()) == [3, 4];
  }

  method {:test} IntersectionHasNoDuplicates() {
    expect intersection(R2(), S2()) == [3, 4];
  }

  // (v0.29.0)
  method {:test} IntersectionHasNoDuplicatesEvenIfTheFirstListIsBiggerAndHasDuplicates() {
    expect intersection(R2(), S()) == [3, 4];
  }

  method {:test} IntersectionHasNoDuplicatesEvenIfTheSecondListIsBiggerAndHasDuplicates() {
    expect intersection(R(), S2()) == [3, 4];
  }

  // describe('difference')
  method {:test} DifferenceFindsElementsNotInTheSecond() {
    expect difference(R(), S()) == [1, 2];
  }

  method {:test} DifferenceHasNoDuplicates() {
    expect difference(R2(), S2()) == [1, 2];
  }

  // v0.7.0
  method {:test} DifferenceWorksForArraysOfDifferentLengths() {
    expect difference(Z(), Z2()) == [10];
    expect difference(Z2(), Z()) == [1, 2, 7, 8];
  }

  // v0.7.0
  method {:test} DifferenceReturnsAnEmptyArrayIfThereAreNoDifferentElements() {
    var empty: seq<int> := [];
    expect difference(R2(), R()) == [];
    expect difference(R(), R2()) == [];
    expect difference(empty, R2()) == [];
  }

  // v0.14.0: `difference(M2, [3]).length` is 3
  method {:test} DifferenceWillNotCreateASparseArray() {
    expect |difference(R2(), [3])| == 3;
  }

  // describe('differenceWith')
  method {:test} DifferenceWithUsesThePredicate() {
    expect differenceWith(EqA, Ro(), So()) == [A(1), A(2)];
  }

  method {:test} DifferenceWithHasNoDuplicates() {
    expect differenceWith(EqA, Ro() + Ro(), So() + So()) == [A(1), A(2)];
  }

  // v0.14.0: `eq = (a, b) => a === b`; the result's length is 2 (v0.11.0 to
  // v0.13.0 left holes, outside the port's domain then).
  method {:test} DifferenceWithDoesNotReturnASparseArray() {
    expect |differenceWith((a: int, b: int) => a == b, [1, 3, 2, 1, 3, 1, 2, 3], [3])| == 2;
  }

  function Album(title: string, artist: string, genre: string): map<string, string>
  { map["title" := title, "artist" := artist, "genre" := genre] }

  function Albums(): seq<map<string, string>>
  { [Album("Art of the Fugue", "Glenn Gould", "Baroque"),
     Album("A Farewell to Kings", "Rush", "Rock"),
     Album("Timeout", "Dave Brubeck Quartet", "Jazz"),
     Album("Fly By Night", "Rush", "Rock"),
     Album("Goldberg Variations", "Daniel Barenboim", "Baroque"),
     Album("New World Symphony", "Leonard Bernstein", "Romantic"),
     Album("Romance with the Unseen", "Don Byron", "Jazz"),
     Album("Somewhere In Time", "Iron Maiden", "Metal"),
     Album("In Times of Desparation", "Danny Holt", "Modern"),
     Album("Evita", "Various", "Broadway"),
     Album("Five Leaves Left", "Nick Drake", "Folk"),
     Album("The Magic Flute", "John Eliot Gardiner", "Classical")] }

  // `prop("genre")`; every album has a genre.
  function Genre(album: map<string, string>): string
  { if "genre" in album then album["genre"] else "" }

  // `remap[genre] || genre`
  function DerivedGenre(album: map<string, string>): string
  { var g := Genre(album);
    if g == "Baroque" || g == "Modern" || g == "Romantic" then "Classical"
    else if g == "Metal" then "Rock" else g }

  // describe('countBy')
  method {:test} CountByASimpleProperty() {
    expect countBy(Genre, Albums()) == map["Baroque" := 2, "Rock" := 2, "Jazz" := 2, "Romantic" := 1,
      "Metal" := 1, "Modern" := 1, "Broadway" := 1, "Folk" := 1, "Classical" := 1];
  }

  method {:test} CountByAMoreComplexFunction() {
    expect countBy(DerivedGenre, Albums()) ==
      map["Classical" := 5, "Rock" := 3, "Jazz" := 2, "Broadway" := 1, "Folk" := 1];
  }

  // v0.9.1: "ignores inherited properties" (`countBy(R.identity, ['abc',
  // 'toString'])`; until v0.9.0 node counted on from the inherited
  // `toString`)
  method {:test} CountByIgnoresInheritedProperties() {
    var result := countBy((s: string) => s, ["abc", "toString"]);
    expect "abc" in result && "toString" in result;
    expect result["abc"] == 1;
    expect result["toString"] == 1;
  }

  // describe('groupBy')
  function GroupedByGenre(): map<string, seq<map<string, string>>>
  { var a := Albums();
    map["Baroque" := [a[0], a[4]], "Rock" := [a[1], a[3]], "Jazz" := [a[2], a[6]],
        "Romantic" := [a[5]], "Metal" := [a[7]], "Modern" := [a[8]], "Broadway" := [a[9]],
        "Folk" := [a[10]], "Classical" := [a[11]]] }

  method {:test} GroupByASimpleProperty() {
    expect groupBy(Genre, Albums()) == GroupedByGenre();
  }

  method {:test} GroupByAMoreComplexFunction() {
    var a := Albums();
    expect groupBy(DerivedGenre, a) ==
      map["Classical" := [a[0], a[4], a[5], a[8], a[11]], "Rock" := [a[1], a[3], a[7]],
          "Jazz" := [a[2], a[6]], "Broadway" := [a[9]], "Folk" := [a[10]]];
  }

  // ---- equals.js (v0.15.0; eqDeep.js, describe('eqDeep'), from v0.9.0 to
  // v0.14.0) and identical.js (v0.15.0; eq.js, describe('eq'), until
  // v0.14.0, with the same asserts) ----

  method {:test} EqualsTestsForDeepEqualityOfItsOperands() {
    var a: seq<int> := [];
    var b := a;
    expect equals(Num(100), Num(100)) == true;
    expect equals(Num(100), Str("100")) == false;
    var e1: seq<int> := [];
    var e2: seq<int> := [];
    expect equals(e1, e2) == true;
    expect equals(a, b) == true;
  }

  method {:test} EqualsConsidersEqualBooleanPrimitivesEqual() {
    expect equals(true, true) == true;
    expect equals(false, false) == true;
    expect equals(true, false) == false;
    expect equals(false, true) == false;
  }

  method {:test} EqualsConsidersEqualNumberPrimitivesEqual() {
    expect equals(0, 0) == true;
    expect equals(0, 1) == false;
    expect equals(1, 0) == false;
  }

  method {:test} EqualsConsidersEqualStringPrimitivesEqual() {
    expect equals("", "") == true;
    expect equals("", "x") == false;
    expect equals("x", "") == false;
    expect equals("foo", "foo") == true;
    expect equals("foo", "bar") == false;
    expect equals("bar", "foo") == false;
  }

  method {:test} EqualsHandlesObjects() {
    var none: map<string, int> := map[];
    expect equals(none, none) == true;
    expect equals(map["a" := 1, "b" := 2], map["a" := 1, "b" := 2]) == true;
    expect equals(map["a" := 2, "b" := 3], map["b" := 3, "a" := 2]) == true;
    expect equals(map["a" := 2, "b" := 3], map["a" := 3, "b" := 3]) == false;
    expect equals(map["a" := 2, "b" := 3, "c" := 1], map["a" := 2, "b" := 3]) == false;
  }

  method {:test} EqualsHandlesLists() {
    expect equals(Arr([]), Obj(map[])) == false;
    expect equals([1, 2, 3], [1, 3, 2]) == false;
  }

  // its `nestA`, `nestB` and `nestC` lines
  method {:test} EqualsHandlesRecursiveDataStructures() {
    var nestA := Obj(map["a" := Arr([Num(1), Num(2), Obj(map["c" := Num(1)])]), "b" := Num(1)]);
    var nestB := Obj(map["a" := Arr([Num(1), Num(2), Obj(map["c" := Num(1)])]), "b" := Num(1)]);
    var nestC := Obj(map["a" := Arr([Num(1), Num(2), Obj(map["c" := Num(2)])]), "b" := Num(1)]);
    expect equals(nestA, nestB) == true;
    expect equals(nestA, nestC) == false;
  }

  // "has Object.is semantics": its `identical([], [])` (two array objects),
  // `-0`, NaN and `new Number(0)` lines cannot be written (README
  // "Deviations"); `null` and `undefined` are the Js values Null and
  // Undefined. (Its "is curried" compares two arrays by reference.)
  method {:test} IdenticalHasObjectIsSemantics() {
    var a: seq<int> := [];
    var b := a;
    expect identical(Num(100), Num(100)) == true;
    expect identical(Num(100), Str("100")) == false;
    expect identical("string", "string") == true;
    expect identical(a, b) == true;
    expect identical(Undefined, Undefined) == true;
    expect identical(Null, Undefined) == false;
  }

  // "is auto-curried" (v0.29.0, as identical is curried by hand): `unaryFn =
  // R.identical('foo')` is a lambda (D5); its `length` checks are not
  // transcribed, nor is "does not access the placeholder property of its
  // arguments…" (a cross-origin Proxy).
  method {:test} IdenticalIsAutoCurried() {
    var unaryFn := (b: string) => identical("foo", b);
    expect unaryFn("bar") == false;
    expect unaryFn("foo") == true;
  }

  // ---- eqBy.js (v0.18.0) ----

  // `Math.abs`
  function Abs(n: int): int { if n < 0 then -n else n }

  method {:test} EqByDeterminesWhetherTwoValuesMapToTheSameValueInTheCodomain() {
    expect eqBy(Abs, 5, 5) == true;
    expect eqBy(Abs, 5, -5) == true;
    expect eqBy(Abs, -5, 5) == true;
    expect eqBy(Abs, -5, -5) == true;
    expect eqBy(Abs, 42, 99) == false;
  }

  // ---- symmetricDifference.js, symmetricDifferenceWith.js (v0.19.0) ----

  function SdM(): seq<int> { [1, 2, 3, 4] }
  function SdM2(): seq<int> { [1, 2, 3, 4, 1, 2, 3, 4] }
  function SdN(): seq<int> { [3, 4, 5, 6] }
  function SdN2(): seq<int> { [3, 3, 4, 4, 5, 5, 6, 6] }
  function SdZ(): seq<int> { [3, 4, 5, 6, 10] }
  function SdZ2(): seq<int> { [1, 2, 3, 3, 4, 4, 5, 5, 6, 6, 7, 8] }

  method {:test} SymmetricDifferenceFindsTheElementsInEitherListButNotBoth() {
    expect symmetricDifference(SdM(), SdN()) == [1, 2, 5, 6];
  }

  method {:test} SymmetricDifferenceDoesNotAllowDuplicatesInTheOutput() {
    expect symmetricDifference(SdM2(), SdN2()) == [1, 2, 5, 6];
  }

  method {:test} SymmetricDifferenceWorksForArraysOfDifferentLengths() {
    expect symmetricDifference(SdZ(), SdZ2()) == [10, 1, 2, 7, 8];
    expect symmetricDifference(SdZ2(), SdZ()) == [1, 2, 7, 8, 10];
  }

  method {:test} SymmetricDifferenceWillNotCreateASparseArray() {
    expect |symmetricDifference(SdM2(), [3])| == 3;
  }

  method {:test} SymmetricDifferenceReturnsAnEmptyArrayIfThereAreNoDifferentElements() {
    expect symmetricDifference(SdM2(), SdM()) == [];
    expect symmetricDifference(SdM(), SdM2()) == [];
  }

  // `Ro2`/`So2` are Ro/So twice; `eqA` compares the `a` properties
  method {:test} SymmetricDifferenceWithCombinesTwoListsIntoTheElementsUniqueToEither() {
    expect symmetricDifferenceWith(EqA, Ro(), So()) == [A(1), A(2), A(5), A(6)];
  }

  method {:test} SymmetricDifferenceWithDoesNotAllowDuplicatesInTheOutput() {
    expect symmetricDifferenceWith(EqA, Ro() + Ro(), So() + So()) == [A(1), A(2), A(5), A(6)];
  }

  // `identical = (a, b) => a === b`
  method {:test} SymmetricDifferenceWithDoesNotReturnASparseArray() {
    expect |symmetricDifferenceWith((a: int, b: int) => a == b, [1, 3, 2, 1, 3, 1, 2, 3], [3])| == 2;
  }

  // describe('clamp') (v0.20.0)
  method {:test} ClampClampsToTheLowerBound() {
    expect clamp(1, 10, 0) == 1;
    expect clamp(3, 12, 1) == 3;
    expect clamp(-15, 3, -100) == -15;
  }

  method {:test} ClampClampsToTheUpperBound() {
    expect clamp(1, 10, 20) == 10;
    expect clamp(3, 12, 23) == 12;
    expect clamp(-15, 3, 16) == 3;
  }

  method {:test} ClampLeavesItAloneWhenWithinTheBound() {
    expect clamp(1, 10, 4) == 4;
    expect clamp(3, 12, 6) == 6;
    expect clamp(-15, 3, 0) == 0;
  }

  // ---- innerJoin.js (v0.24.0) ----

  datatype Rec = Rec(id: int, name: string)

  function JoinById(xs: seq<Rec>, ids: seq<int>): seq<Rec>
  { innerJoin((r: Rec, id: int) => r.id == id, xs, ids) }

  method {:test} InnerJoinOnlyReturnsElementsFromTheFirstList() {
    var a, b, c := Rec(1, "a"), Rec(2, "b"), Rec(3, "c");
    var none: seq<int> := [];
    expect JoinById([a, b, c], none) == [];
    expect JoinById([a, b, c], [1]) == [a];
    expect JoinById([a, b, c], [1, 2]) == [a, b];
    expect JoinById([a, b, c], [1, 2, 3]) == [a, b, c];
    expect JoinById([a, b, c], [1, 2, 3, 4]) == [a, b, c];
  }

  method {:test} InnerJoinDoesNotRemoveDuplicates() {
    var a, b, c := Rec(1, "a"), Rec(2, "b"), Rec(3, "c");
    expect JoinById([a, a, a], [1, 2, 3]) == [a, a, a];
    expect JoinById([a, b, c], [1, 1, 1]) == [a];
  }
}
