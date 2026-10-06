// Ramda v0.2.2 test/test.sql.js, transcribed. Not transcribed:
// - the three "does not work for non-primitives" cases (union/intersection/
//   difference of distinct-but-equal objects): JS `===` compares references,
//   Dafny `==` structure (README "Deviations"; pinned in tests/edge/data.dfy);
// - describe('sortBy'), which sorts by a string title: sortBy keys are ints
//   (README "Deviations").

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

  // describe('differenceWith')
  method {:test} DifferenceWithUsesThePredicate() {
    expect differenceWith(EqA, Ro(), So()) == [A(1), A(2)];
  }

  method {:test} DifferenceWithHasNoDuplicates() {
    expect differenceWith(EqA, Ro() + Ro(), So() + So()) == [A(1), A(2)];
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
}
