// Ramda v0.1.0 test/test.objectBasics.js, test/test.keysvals.js and
// test/test.tapeq.js, transcribed. Not transcribed: describe('func') and
// describe('tap') (not portable, README), `eq([], [])` (reference equality,
// README "Deviations"; pinned in tests/edge/object.dfy).

module RamdafTests.Ramda.Object {
  import opened Ramdaf.Prelude
  import opened Ramdaf.List
  import opened Ramdaf.Object
  import opened Support

  function Fred(): map<string, Js> { map["name" := Str("Fred"), "age" := Num(23)] }

  // ---- test.objectBasics.js ----

  // describe('prop')
  method {:test} PropFetchesTheProperty() {
    var nm := (o: map<string, Js>) => prop("name", o);
    expect nm(Fred()) == Some(Str("Fred"));
  }

  method {:test} PropIsAliasedByGet() {
    expect get("age", Fred()) == Some(Num(23));
  }

  // describe('pluck')
  method {:test} PluckMapsThePropertyOverAnArray() {
    var people := [map["name" := Str("Fred"), "age" := Num(23)], map["name" := Str("Wilma"), "age" := Num(21)],
                   map["name" := Str("Pebbles"), "age" := Num(2)]];
    var nm := (l: seq<map<string, Js>>) => pluck("name", l);
    expect nm(people) == [Some(Str("Fred")), Some(Str("Wilma")), Some(Str("Pebbles"))];
  }

  // describe('props')
  method {:test} PropsFetchesFromTheInitiallySuppliedObject() {
    var fred := map["name" := Str("Fred"), "age" := Num(23), "feet" := Str("large")];
    var p := (k: string) => props(fred, k);
    expect p("name") == Some(Str("Fred"));
    expect p("age") == Some(Num(23));
    expect p("feet") == Some(Str("large"));
  }

  function Abc(): map<string, int> { map["a" := 1, "b" := 2, "c" := 3, "d" := 4, "e" := 5, "f" := 6] }

  // describe('pick')
  method {:test} PickCopiesTheNamedProperties() {
    expect pick(["a", "c", "f"], Abc()) == map["a" := 1, "c" := 3, "f" := 6];
  }

  method {:test} PickIgnoresPropertiesNotIncluded() {
    expect pick(["a", "c", "g"], Abc()) == map["a" := 1, "c" := 3];
  }

  method {:test} PickIsAutomaticallyCurried() {
    var copyAB := (o: map<string, int>) => pick(["a", "b"], o);
    expect copyAB(Abc()) == map["a" := 1, "b" := 2];
  }

  // describe('pickAll')
  method {:test} PickAllCopiesTheNamedProperties() {
    expect pickAll(["a", "c", "f"], Abc()) == map["a" := Some(1), "c" := Some(3), "f" := Some(6)];
  }

  method {:test} PickAllIncludesPropertiesNotPresent() {
    expect pickAll(["a", "c", "g"], Abc()) == map["a" := Some(1), "c" := Some(3), "g" := None];
  }

  method {:test} PickAllIsAutomaticallyCurried() {
    var copyAB := (o: map<string, int>) => pickAll(["a", "b"], o);
    expect copyAB(Abc()) == map["a" := Some(1), "b" := Some(2)];
  }

  // describe('omit')
  method {:test} OmitOmitsTheListedProperties() {
    expect omit(["a", "c", "f"], Abc()) == map["b" := 2, "d" := 4, "e" := 5];
  }

  method {:test} OmitIsAutomaticallyCurried() {
    var skipAB := (o: map<string, int>) => omit(["a", "b"], o);
    expect skipAB(Abc()) == map["c" := 3, "d" := 4, "e" := 5, "f" := 6];
  }

  // describe('eqProps')
  method {:test} EqPropsComparesAProperty() {
    expect eqProps("name", map["name" := Str("fred"), "age" := Num(10)], map["name" := Str("fred"), "age" := Num(12)]) == true;
    expect eqProps("name", map["name" := Str("fred"), "age" := Num(10)], map["name" := Str("franny"), "age" := Num(10)]) == false;
  }

  method {:test} EqPropsIsAutomaticallyCurried() {
    var sameName := (o1: map<string, Js>, o2: map<string, Js>) => eqProps("name", o1, o2);
    expect sameName(map["name" := Str("fred"), "age" := Num(10)], map["name" := Str("fred"), "age" := Num(12)]) == true;
  }

  // ---- test.keysvals.js ----

  function KeysValsObj(): map<string, Js>
  { map["a" := Num(100), "b" := Arr([Num(1), Num(2), Num(3)]),
        "c" := Obj(map["x" := Num(200), "y" := Num(300)]), "d" := Str("D"), "e" := Null, "f" := Undefined] }

  // JS returns the keys in insertion order; keys is a set here (README).
  method {:test} KeysReturnsTheObjectsKeys() {
    expect keys(KeysValsObj()) == {"a", "b", "c", "d", "e", "f"};
  }

  // JS returns the values in key order; values is a multiset here (README).
  method {:test} ValuesReturnsTheObjectsValues() {
    expect values(KeysValsObj()) == multiset{Num(100), Arr([Num(1), Num(2), Num(3)]),
      Obj(map["x" := Num(200), "y" := Num(300)]), Str("D"), Null, Undefined};
  }

  // ---- test.tapeq.js: describe('eq') ----

  method {:test} EqTestsStrictEquality() {
    var a: seq<int> := [];
    var b := a;
    expect eq(Num(100), Num(100)) == true;
    expect eq(Num(100), Str("100")) == false;
    expect eq(a, b) == true;
  }
}
