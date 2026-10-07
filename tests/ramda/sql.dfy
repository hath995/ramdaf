// Ramda v0.11.0 test/project.js, propEq.js, union.js, unionWith.js,
// intersection.js, intersectionWith.js, difference.js, differenceWith.js,
// countBy.js and sortBy.js (until v0.8.0 test.sql.js, whose copy of the
// groupBy describe v0.9.0 dropped), transcribed. Not transcribed:
// - the three "does not work for non-primitives" cases (union/intersection/
//   difference of distinct-but-equal objects): JS `===` compares references,
//   Dafny `==` structure (README "Deviations"; pinned in tests/edge/data.dfy);
// - describe('sortBy'), which sorts by a string title: sortBy keys are ints
//   (README "Deviations"); its v0.10.0 "preserves object identity" (reference
//   identity, by a string key) and "sorts array-like object" (`arguments`,
//   by a string key) likewise;
// - eqDeep.js's (v0.9.0) "handles regex", "handles dates", "handles typed
//   arrays" (no such values), the cyclic `c`/`d` and `e`/`f` lines of
//   "handles recursive data structures" (a Dafny value cannot contain
//   itself) and "throws if given no arguments" (until v0.10.0). Its mixed
//   values are Js.

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

  method {:test} ProjectIsAutomaticallyCurried() {
    var myFields := (l: seq<map<string, Js>>) => project(["name", "age"], l);
    expect myFields(Kids()) == [
      map["name" := Some(Str("Abby")), "age" := Some(Num(7))],
      map["name" := Some(Str("Fred")), "age" := Some(Num(12))],
      map["name" := Some(Str("Rusty")), "age" := Some(Num(10))],
      map["name" := Some(Str("Alois")), "age" := Some(Num(15))]];
  }

  // describe('propEq')
  method {:test} PropEqMatchesAPropertyValue() {
    var kids := Kids();
    expect propEq("name", Str("Abby"), kids[0]) == true;
    expect propEq("hair", Str("brown"), kids[1]) == true;
    expect propEq("hair", Str("blond"), kids[1]) == false;
  }

  method {:test} PropEqIsAutomaticallyCurried() {
    var kids := Kids();
    var brunette := (o: map<string, Js>) => propEq("hair", Str("brown"), o);
    expect filter(brunette, kids) == [kids[1], kids[2]];
    expect filter((o: map<string, Js>) => propEq("hair", Str("brown"), o), kids) == [kids[1], kids[2]];
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

  // v0.9.0 (its `typeof` check holds by construction)
  method {:test} UnionIsCurried() {
    var withR := (l: seq<int>) => union(R(), l);
    expect withR(S()) == [1, 2, 3, 4, 5, 6];
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

  // describe('intersectionWith')
  method {:test} IntersectionWithUsesThePredicate() {
    expect intersectionWith(EqA, Ro(), So()) == [A(3), A(4)];
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

  // v0.7.0 (its `typeof` check holds by construction)
  method {:test} DifferenceIsCurried() {
    var diff123 := (l: seq<int>) => difference([1, 2, 3], l);
    expect diff123([1, 3]) == [2];
  }

  // describe('differenceWith'). Since v0.11.0 differenceWith requires the
  // kept elements to be a prefix of the first list (README "Outside the
  // modeled domain"); both inputs keep a prefix, and the asserts name the
  // element of the second list that drops each later one.
  method {:test} DifferenceWithUsesThePredicate() {
    assert EqA(Ro()[2], So()[0]) && EqA(Ro()[3], So()[1]);
    expect differenceWith(EqA, Ro(), So()) == [A(1), A(2)];
  }

  method {:test} DifferenceWithHasNoDuplicates() {
    var first, second := Ro() + Ro(), So() + So();
    assert EqA(first[2], second[0]) && EqA(first[3], second[1]) && EqA(first[6], second[0]) && EqA(first[7], second[1]);
    assert EqA(first[4], first[..2][0]) && EqA(first[5], first[..2][1]);
    expect differenceWith(EqA, first, second) == [A(1), A(2)];
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

  method {:test} CountByIsAutomaticallyCurried() {
    var counter := (l: seq<map<string, string>>) => countBy(Genre, l);
    expect counter(Albums()) == map["Baroque" := 2, "Rock" := 2, "Jazz" := 2, "Romantic" := 1,
      "Metal" := 1, "Modern" := 1, "Broadway" := 1, "Folk" := 1, "Classical" := 1];
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

  method {:test} GroupByIsAutomaticallyCurried() {
    var grouper := (l: seq<map<string, string>>) => groupBy(Genre, l);
    expect grouper(Albums()) == GroupedByGenre();
  }

  // ---- eqDeep.js (v0.9.0) ----

  method {:test} EqDeepTestsForDeepEqualityOfItsOperands() {
    var a: seq<int> := [];
    var b := a;
    expect eqDeep(Num(100), Num(100)) == true;
    expect eqDeep(Num(100), Str("100")) == false;
    var e1: seq<int> := [];
    var e2: seq<int> := [];
    expect eqDeep(e1, e2) == true;
    expect eqDeep(a, b) == true;
  }

  method {:test} EqDeepHandlesObjects() {
    var none: map<string, int> := map[];
    expect eqDeep(none, none) == true;
    expect eqDeep(map["a" := 1, "b" := 2], map["a" := 1, "b" := 2]) == true;
    expect eqDeep(map["a" := 2, "b" := 3], map["b" := 3, "a" := 2]) == true;
    expect eqDeep(map["a" := 2, "b" := 3], map["a" := 3, "b" := 3]) == false;
    expect eqDeep(map["a" := 2, "b" := 3, "c" := 1], map["a" := 2, "b" := 3]) == false;
  }

  method {:test} EqDeepHandlesLists() {
    expect eqDeep(Arr([]), Obj(map[])) == false;
    expect eqDeep([1, 2, 3], [1, 3, 2]) == false;
  }

  // its `nestA`, `nestB` and `nestC` lines
  method {:test} EqDeepHandlesRecursiveDataStructures() {
    var nestA := Obj(map["a" := Arr([Num(1), Num(2), Obj(map["c" := Num(1)])]), "b" := Num(1)]);
    var nestB := Obj(map["a" := Arr([Num(1), Num(2), Obj(map["c" := Num(1)])]), "b" := Num(1)]);
    var nestC := Obj(map["a" := Arr([Num(1), Num(2), Obj(map["c" := Num(2)])]), "b" := Num(1)]);
    expect eqDeep(nestA, nestB) == true;
    expect eqDeep(nestA, nestC) == false;
  }

  method {:test} EqDeepIsCurried() {
    var a: seq<int> := [];
    var isA := (x: seq<int>) => eqDeep(a, x);
    expect isA([]) == true;
  }
}
