// Ramda v0.1.5 test/test.objectBasics.js, test/test.keysvals.js and
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

  // describe('where')
  function Xy(x: int, y: int): map<string, int> { map["x" := x, "y" := y] }

  method {:test} WhereTakesASpecAndATestObject() {
    var spec := map["x" := Val(1), "y" := Val(2)];
    expect where(spec, Xy(0, 200)) == false;
    expect where(spec, Xy(0, 10)) == false;
    expect where(spec, Xy(1, 101)) == false;
    expect where(spec, Xy(1, 2)) == true;
  }

  // `obj.b + obj.c` etc.: the test objects all have a, b and c.
  function F(o: map<string, int>, k: string): int { if k in o then o[k] else 0 }
  function V(v: Option<int>): int { if v.Some? then v.value else 0 }
  function Abc3(a: int, b: int, c: int): map<string, int> { map["a" := a, "b" := b, "c" := c] }

  method {:test} WhereCallsFunctionsInTheSpecOnTheProperty() {
    var spec := map[
      "a" := Pred((a: Option<int>, obj: map<string, int>) => V(a) < F(obj, "b") + F(obj, "c")),
      "b" := Pred((b: Option<int>, obj: map<string, int>) => V(b) < F(obj, "a") + F(obj, "c")),
      "c" := Pred((c: Option<int>, obj: map<string, int>) => V(c) < F(obj, "a") + F(obj, "b"))];
    expect where(spec, Abc3(3, 4, 5)) == true;
    expect where(spec, Abc3(6, 8, 9)) == true;
    expect where(spec, Abc3(2, 8, 12)) == false;
    expect where(spec, Abc3(3, 11, 5)) == false;
  }

  method {:test} WhereAllowsATestObjectWithMoreProperties() {
    var spec := map["x" := Val(100)];
    expect where(spec, map["x" := 20, "y" := 100, "z" := 100]) == false;
    expect where(spec, map["w" := 1, "x" := 100, "y" := 100, "z" := 100]) == true;
  }

  // "is false if the test object is null-ish" and "matches specs that have
  // undefined properties" (v0.1.5) are not transcribed: a test object is a
  // map, never null, and an undefined property is an absent one here.
  method {:test} WhereIsAutomaticallyCurried() {
    var pred := (o: map<string, int>) => where(map["x" := Val(1), "y" := Val(2)], o);
    expect pred(map["x" := 1, "y" := 2, "z" := 3]) == true;
    expect pred(map["x" := 3, "y" := 2, "z" := 1]) == false;
  }

  // describe('mixin')
  method {:test} MixinMergesOwnPropertiesIntoANewObject() {
    expect mixin(map["w" := 1, "x" := 2], map["y" := 3, "z" := 4]) == map["w" := 1, "x" := 2, "y" := 3, "z" := 4];
  }

  method {:test} MixinOverridesPropertiesOfTheFirstObject() {
    expect mixin(map["w" := 1, "x" := 2], map["w" := 100, "y" := 3, "z" := 4]) ==
      map["w" := 100, "x" := 2, "y" := 3, "z" := 4];
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
