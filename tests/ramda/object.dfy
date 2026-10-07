// Ramda v0.14.0 test/prop.js, props.js, propOr.js, has.js,
// hasIn.js, pluck.js, pick.js, pickAll.js, omit.js, pickBy.js, eqProps.js,
// where.js, whereEq.js, merge.js, assoc.js, keys.js, keysIn.js, values.js,
// valuesIn.js, eq.js, toPairs.js, toPairsIn.js, evolve.js, invert.js,
// invertObj.js, dissoc.js, lensOn.js and lensProp.js (v0.9.x mixin.js; until
// v0.8.0 test.objectBasics.js,
// test.keysvals.js, test.tapeq.js and test.zip.js's toPairs and toPairsIn
// describes), transcribed. Not
// transcribed: keys's and values's "should work for primitives" cases (v0.2.4;
// keys/values of null, 55, "" and the like: the argument is a map); where's
// and whereEq's cases on prototypes (where's "matches inherited properties"
// and "does not match inherited spec", whereEq's "matches inherited props"
// and "does not match inherited spec"), whereEq's "reports true when the
// object equals the spec" (`whereEq(R, R)`: an object of functions, which
// have no equality here) and "matches specs that have undefined properties"
// (a spec value that is undefined cannot be written, README "Outside the
// modeled domain"), and the `null` spec of their "is true for an empty
// spec"; eqProps's "has Object.is semantics" (v0.14.0; `-0` and NaN are
// not ints, README "Deviations", pinned in tests/edge/misc.dfy) and pluck's "behaves as a transducer…" (v0.14.0;
// transducers, README "Not portable"); the cases on an object built by a constructor whose prototype has
// properties (keys's, keysIn's, values's and valuesIn's "does not include"/
// "includes the given object's prototype properties", propOr's "does not
// return properties from the prototype chain", toPairs's "only iterates the
// object's own properties", toPairsIn's "iterates properties on the object's
// prototype chain", pick's "retrieves prototype properties", omit's
// "includes prototype properties", pickBy's "retrieves prototype
// properties", dissoc's "includes prototype properties", has's "does not
// check properties from the prototype chain" and hasIn's "checks properties
// from the prototype chain"): a map has no prototype; the no-argument cases
// ("throws if given no arguments" and the like, until v0.10.0); pickBy's "creates a copy" (reference inequality); eq's `eq([], [])`
// and "is curried", which rely on `[] !== []` (reference equality, README
// "Deviations"), and its `eq(0, -0)` and `eq(NaN, NaN)` (no `-0` or NaN in
// an int; README "Deviations", pinned in tests/edge/misc.dfy); invert's and
// invertObj's "takes a list or object…" (`typeof`, and until v0.9.1 throws
// on primitives) and their "returns an empty object when applied to a
// primitive" and "… to null/undefined" (v0.10.0; not maps);
// invertObj's "prefers the last key found…" and "is not destructive",
// whose inputs repeat a value (outside the domain, README); and assocPath.js,
// func.js and tap.js (not portable, README). invert's and invertObj's array
// inputs are the objects their keys see (index keys "0", "1", …). toPairs,
// toPairsIn and invert's key lists are sets (a map has no key order, README
// "Deviations"). assoc's "reference equality" lines compare by value (Dafny
// values have no identity). (v0.8.0 renamed describe('props') to
// describe('propOf') and describe('pickWith') to describe('pickBy') with the
// functions, and added a describe('props') for the new function; v0.9.0
// moved propOr's default to the first argument; v0.10.0 renamed
// describe('mixin') to describe('merge') with the function; v0.11.0 split
// has's two-argument `it` in two and replaced its "returns a function that
// checks the appropriate property" with "is curried, op-style"; v0.12.0
// removed propOf.js and prop's "is aliased by `get`" with the functions.) lensOn.js's
// "returns a function with `set` and `map` properties" and the `typeof`
// checks of its "is curried" hold by construction: a `LensOn` always has its
// three fields, applied as `.get()`, `.set_(v)` and `.map_(fn)` (README
// "Deviations"). v0.14.0 rewrote where.js for specs of predicates: it
// dropped "calls any functions in the spec against the test object value
// for that property", "is false if the test object is null-ish", "reports
// true when the object equals the spec" and "matches inherited functions",
// retitled "takes a spec and a test object…" "returns true if the test
// object satisfies the spec", and moved the value specs to whereEq.js.

module RamdafTests.Ramda.Object {
  import opened Ramdaf.Prelude
  import opened Ramdaf.List
  import opened Ramdaf.Object
  import Funcs = Ramdaf.Functions
  import S = Ramdaf.String
  import opened Support

  function Fred(): map<string, Js> { map["name" := Str("Fred"), "age" := Num(23)] }

  // ---- prop.js … merge.js (mixin.js in v0.9.x; test.objectBasics.js until
  // v0.8.0) ----

  // describe('prop')
  method {:test} PropFetchesTheProperty() {
    var nm := (o: map<string, Js>) => prop("name", o);
    expect nm(Fred()) == Some(Str("Fred"));
  }

  // describe('pluck')
  method {:test} PluckMapsThePropertyOverAnArray() {
    var people := [map["name" := Str("Fred"), "age" := Num(23)], map["name" := Str("Wilma"), "age" := Num(21)],
                   map["name" := Str("Pebbles"), "age" := Num(2)]];
    var nm := (l: seq<map<string, Js>>) => pluck("name", l);
    expect nm(people) == [Some(Str("Fred")), Some(Str("Wilma")), Some(Str("Pebbles"))];
  }

  // describe('props') (v0.8.0): undefined is None
  method {:test} PropsReturnsEmptyArrayIfNoPropertiesRequested() {
    var none: seq<string> := [];
    expect props(none, Abc()) == [];
  }

  method {:test} PropsReturnsValuesForRequestedProperties() {
    expect props(["a", "e"], Abc()) == [Some(1), Some(5)];
  }

  method {:test} PropsPreservesOrder() {
    expect props(["f", "c", "e"], Abc()) == [Some(6), Some(3), Some(5)];
  }

  method {:test} PropsReturnsUndefinedForNonexistentProperties() {
    var ps := props(["a", "nonexistent"], Abc());
    expect |ps| == 2;
    expect ps[0] == Some(1);
    expect ps[1] == None;
  }

  method {:test} PropsIsAutomaticallyCurried() {
    var ab := (o: map<string, int>) => props(["a", "b"], o);
    expect ab(Abc()) == [Some(1), Some(2)];
  }

  // describe('propOr') (describe('propOrDefault') from v0.4.0 to v0.5.0):
  // `nm = propOr('Unknown', 'name')` (`propOr('name', 'Unknown')` until
  // v0.8.0; its `typeof nm == 'function'` holds by
  // construction)
  method {:test} PropOrReturnsAFunctionThatFetchesTheAppropriateProperty() {
    var nm := (o: map<string, Js>) => propOr(Str("Unknown"), "name", o);
    expect nm(Fred()) == Str("Fred");
  }

  method {:test} PropOrReturnsTheDefaultValueWhenThePropertyDoesNotExist() {
    var nm := (o: map<string, Js>) => propOr(Str("Unknown"), "name", o);
    expect nm(map["age" := Num(99)]) == Str("Unknown");
  }

  // describe('has') (v0.7.0); `anon` is `{age: 99}`. v0.11.0 splits "works
  // properly when called with two arguments" into these two.
  method {:test} HasReturnsTrueIfTheSpecifiedPropertyIsPresent() {
    expect has("name", Fred()) == true;
  }

  method {:test} HasReturnsFalseIfTheSpecifiedPropertyIsAbsent() {
    expect has("name", map["age" := Num(99)]) == false;
  }

  // v0.11.0, in place of "returns a function that checks the appropriate
  // property": `has('name')` and `has(R.__, point)`, the placeholder fixing
  // the object
  method {:test} HasIsCurriedOpStyle() {
    var hasName := (o: map<string, Js>) => has("name", o);
    expect hasName(Fred()) == true;
    expect hasName(map["age" := Num(99)]) == false;
    var point := map["x" := 0, "y" := 0];
    var pointHas := (k: string) => has(k, point);
    expect pointHas("x") == true;
    expect pointHas("y") == true;
    expect pointHas("z") == false;
  }

  // describe('hasIn') (v0.7.0)
  method {:test} HasInReturnsAFunctionThatChecksTheAppropriateProperty() {
    var nm := (o: map<string, Js>) => hasIn("name", o);
    expect nm(Fred()) == true;
    expect nm(map["age" := Num(99)]) == false;
  }

  method {:test} HasInWorksProperlyWhenCalledWithTwoArguments() {
    expect hasIn("name", Fred()) == true;
    expect hasIn("name", map["age" := Num(99)]) == false;
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

  // describe('pickBy') (describe('pickWith') from v0.2.3 to v0.7.2). "creates
  // a copy of the object" asserts reference inequality, which Dafny values do
  // not have; the truthy/falsy cases use boolean predicates (`always({})`,
  // `always(1)`, `always(0)` and `always(null)` are true, true, false,
  // false).
  method {:test} PickByReturningTruthyKeepsTheKey() {
    expect pickBy((v: int, k: string, o: map<string, int>) => true, Abc()) == Abc();
  }

  // "returning falsy keeps the key" (the title says keeps; the cases drop it)
  method {:test} PickByReturningFalsyDropsTheKey() {
    expect pickBy((v: int, k: string, o: map<string, int>) => false, Abc()) == map[];
  }

  method {:test} PickByShouldBeCalledWithValKeyObj() {
    expect pickBy((v: int, k: string, o: map<string, int>) => o == Abc() && k == "d" && v == 4, Abc()) == map["d" := 4];
  }

  method {:test} PickByShouldBeAutomaticallyCurried() {
    var copier := (o: map<string, int>) => pickBy((v: int, k: string, o': map<string, int>) => true, o);
    expect copier(Abc()) == Abc();
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

  // describe('where') (v0.14.0 rewrote where.js: every spec value is a
  // predicate on the test object's property). `R.eq(a)` is a predicate that
  // holds for a property equal to a and fails on an absent one (undefined).
  function Xy(x: int, y: int): map<string, int> { map["x" := x, "y" := y] }
  function EqP(a: int): Option<int> -> bool { (v: Option<int>) => v.Some? && eq(a, v.value) }

  method {:test} WhereReturnsTrueIfTheTestObjectSatisfiesTheSpec() {
    var spec := map["x" := EqP(1), "y" := EqP(2)];
    expect where(spec, Xy(0, 200)) == false;
    expect where(spec, Xy(0, 10)) == false;
    expect where(spec, Xy(1, 101)) == false;
    expect where(spec, Xy(1, 2)) == true;
  }

  method {:test} WhereAllowsATestObjectWithMoreProperties() {
    var spec := map["x" := EqP(100)];
    expect where(spec, map["x" := 20, "y" := 100, "z" := 100]) == false;
    expect where(spec, map["w" := 1, "x" := 100, "y" := 100, "z" := 100]) == true;
  }

  // "matches specs that have undefined properties": `R.eq(undefined)` holds
  // for undefined (None) only; `{x: undefined}` is the object without x here
  // (README mapping), and `{x: null}` has the Js value Null.
  method {:test} WhereMatchesSpecsThatHaveUndefinedProperties() {
    var spec := map["x" := (v: Option<Js>) => v.None?];
    var none: map<string, Js> := map[];
    expect where(spec, none) == true;
    expect where(spec, map["x" := Null]) == false;
    expect where(spec, none) == true;
    expect where(spec, map["x" := Num(1)]) == false;
  }

  method {:test} WhereIsAutomaticallyCurried() {
    var pred := (o: map<string, int>) => where(map["x" := EqP(1), "y" := EqP(2)], o);
    expect pred(map["x" := 1, "y" := 2, "z" := 3]) == true;
    expect pred(map["x" := 3, "y" := 2, "z" := 1]) == false;
  }

  // "is true for an empty spec" (its `where(null, {a: 1})` case cannot be
  // written: the spec is a map)
  method {:test} WhereEmptySpecIsTrue() {
    var empty: map<string, Option<int> -> bool> := map[];
    expect where(empty, map["a" := 1]) == true;
  }

  // describe('whereEq') (v0.14.0)
  method {:test} WhereEqReturnsTrueIfTheTestObjectSatisfiesTheSpec() {
    var spec := map["x" := 1, "y" := 2];
    expect whereEq(spec, Xy(0, 200)) == false;
    expect whereEq(spec, Xy(0, 10)) == false;
    expect whereEq(spec, Xy(1, 101)) == false;
    expect whereEq(spec, Xy(1, 2)) == true;
  }

  method {:test} WhereEqAllowsATestObjectWithMoreProperties() {
    var spec := map["x" := 100];
    expect whereEq(spec, map["x" := 20, "y" := 100, "z" := 100]) == false;
    expect whereEq(spec, map["w" := 1, "x" := 100, "y" := 100, "z" := 100]) == true;
  }

  method {:test} WhereEqIsCurried() {
    var pred := (o: map<string, int>) => whereEq(map["x" := 1, "y" := 2], o);
    expect pred(map["x" := 1, "y" := 2, "z" := 3]) == true;
    expect pred(map["x" := 3, "y" := 2, "z" := 1]) == false;
  }

  // (its `whereEq(null, {a: 1})` case cannot be written)
  method {:test} WhereEqIsTrueForAnEmptySpec() {
    var empty: map<string, int> := map[];
    expect whereEq(empty, map["a" := 1]) == true;
  }

  // describe('merge') (describe('mixin') until v0.9.1)
  method {:test} MergeMergesOwnPropertiesIntoANewObject() {
    expect merge(map["w" := 1, "x" := 2], map["y" := 3, "z" := 4]) == map["w" := 1, "x" := 2, "y" := 3, "z" := 4];
  }

  method {:test} MergeOverridesPropertiesOfTheFirstObject() {
    expect merge(map["w" := 1, "x" := 2], map["w" := 100, "y" := 3, "z" := 4]) ==
      map["w" := 100, "x" := 2, "y" := 3, "z" := 4];
  }

  // v0.2.4: "should not be destructive" (its reference-inequality half has no
  // counterpart; the map a is a value)
  method {:test} MergeShouldNotBeDestructive() {
    var a := map["w" := 1, "x" := 2];
    var res := merge(a, map["x" := 5]);
    expect res == map["w" := 1, "x" := 5];
    expect a == map["w" := 1, "x" := 2];
  }

  // v0.2.4: "only own properties". `new Cla` has no own property (its x is
  // on the prototype), so as a map it is empty.
  method {:test} MergeOnlyOwnProperties() {
    var a := map["w" := 1, "x" := 2];
    var cla: map<string, int> := map[];
    expect merge(cla, a) == map["w" := 1, "x" := 2];
    expect merge(a, cla) == map["w" := 1, "x" := 2];
  }

  // v0.2.4: "outta be curried"
  method {:test} MergeOughtToBeCurried() {
    var curried := (b: map<string, int>) => merge(map["w" := 1, "x" := 2], b);
    expect curried(map["y" := 3, "z" := 4]) == map["w" := 1, "x" := 2, "y" := 3, "z" := 4];
  }

  // v0.10.0: the second "is curried", `merge(R.__, {w: 1, x: 2})`, which
  // fixes the second argument (`op` currying)
  method {:test} MergeIsCurriedWithThePlaceholder() {
    var curried := (a: map<string, int>) => merge(a, map["w" := 1, "x" := 2]);
    expect curried(map["x" := 3, "y" := 4]) == map["w" := 1, "x" := 2, "y" := 4];
  }

  // ---- keys.js, values.js, keysIn.js, valuesIn.js (test.keysvals.js) ----

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

  // v0.2.3: "should work with hasOwnProperty override" (keys and values threw
  // a TypeError on such an object up to v0.2.2)
  method {:test} KeysWorksWithHasOwnPropertyOverride() {
    expect keys(map["hasOwnProperty" := false]) == {"hasOwnProperty"};
  }

  method {:test} ValuesWorksWithHasOwnPropertyOverride() {
    expect values(map["hasOwnProperty" := false]) == multiset{false};
  }

  // v0.2.0: describe('keysIn'), "returns an array of the given object's keys"
  // (a set here, as for keys).
  method {:test} KeysInReturnsTheObjectsKeys() {
    expect keysIn(KeysValsObj()) == {"a", "b", "c", "d", "e", "f"};
  }

  // v0.2.0: describe('valuesIn'), "returns an array of the given object's
  // values" (a multiset here, as for values).
  method {:test} ValuesInReturnsTheObjectsValues() {
    expect valuesIn(KeysValsObj()) == multiset{Num(100), Arr([Num(1), Num(2), Num(3)]),
      Obj(map["x" := Num(200), "y" := Num(300)]), Str("D"), Null, Undefined};
  }

  // ---- eq.js (test.tapeq.js's describe('eq') until v0.8.0) ----

  method {:test} EqTestsStrictEquality() {
    var a: seq<int> := [];
    var b := a;
    expect eq(Num(100), Num(100)) == true;
    expect eq(Num(100), Str("100")) == false;
    expect eq("string", "string") == true;
    expect eq(a, b) == true;
    // v0.9.0
    expect eq(Undefined, Undefined) == true;
    expect eq(Null, Undefined) == false;
  }

  // ---- toPairs.js, toPairsIn.js (v0.4.0; in test.zip.js until v0.8.0) ----

  method {:test} ToPairsConvertsAnObjectIntoKeyValuePairs() {
    expect toPairs(map["a" := 1, "b" := 2, "c" := 3]) == {("a", 1), ("b", 2), ("c", 3)};
  }

  method {:test} ToPairsInConvertsAnObjectIntoKeyValuePairs() {
    expect toPairsIn(map["a" := 1, "b" := 2, "c" := 3]) == {("a", 1), ("b", 2), ("c", 3)};
  }

  // ---- assoc.js (v0.8.0) ----

  function AssocObj1(): map<string, Js>
  { map["a" := Num(1), "b" := Obj(map["c" := Num(2), "d" := Num(3)]), "e" := Num(4), "f" := Num(5)] }

  method {:test} AssocMakesAShallowCloneOverridingOnlyTheSpecifiedProperty() {
    var obj1 := AssocObj1();
    var obj2 := assoc("e", Obj(map["x" := Num(42)]), obj1);
    expect obj2 == map["a" := Num(1), "b" := Obj(map["c" := Num(2), "d" := Num(3)]),
                       "e" := Obj(map["x" := Num(42)]), "f" := Num(5)];
    expect obj2["a"] == obj1["a"];
    expect obj2["b"] == obj1["b"];
    expect obj2["f"] == obj1["f"];
  }

  method {:test} AssocIsCloneAndSetIfThePropertyIsNotOnTheOriginal() {
    var obj1 := AssocObj1();
    var obj2 := assoc("z", Obj(map["x" := Num(42)]), obj1);
    expect obj2 == map["a" := Num(1), "b" := Obj(map["c" := Num(2), "d" := Num(3)]),
                       "e" := Num(4), "f" := Num(5), "z" := Obj(map["x" := Num(42)])];
    expect obj2["a"] == obj1["a"];
    expect obj2["b"] == obj1["b"];
    expect obj2["f"] == obj1["f"];
  }

  // `f = assoc('e')`, `g = f({x: 42})`
  method {:test} AssocIsProperlyCurried() {
    var obj1 := AssocObj1();
    var expected := map["a" := Num(1), "b" := Obj(map["c" := Num(2), "d" := Num(3)]),
                        "e" := Obj(map["x" := Num(42)]), "f" := Num(5)];
    var f := (v: Js, o: map<string, Js>) => assoc("e", v, o);
    var g := (o: map<string, Js>) => f(Obj(map["x" := Num(42)]), o);
    expect f(Obj(map["x" := Num(42)]), obj1) == expected;
    expect g(obj1) == expected;
  }

  // ---- evolve.js (v0.9.0) ----

  // `R.add(k)` over the Js numbers it meets here (`add(1)(undefined)` would
  // be NaN, which these cases never reach)
  function AddJs(k: int): Option<Js> -> Js
  { (v: Option<Js>) => if v.Some? && v.value.Num? then Num(v.value.n + k) else Undefined }

  function Tomato(elapsed: int, remaining: int): map<string, Js>
  { map["name" := Str("Tomato"), "elapsed" := Num(elapsed), "remaining" := Num(remaining)] }

  method {:test} EvolveCreatesANewObjectByEvolvingTheObject() {
    var transf := map["elapsed" := AddJs(1), "remaining" := AddJs(-1)];
    expect evolve(transf, Tomato(100, 1400)) == Tomato(101, 1399);
  }

  // `{wow: String}`: `String(undefined)` is 'undefined' (the only value the
  // transformation meets here)
  method {:test} EvolveInvokesFunctionWithUndefinedIfObjectDoesNotContainTheKey() {
    var transf := map["wow" := (v: Option<Js>) => if v.None? then Str("undefined") else v.value];
    var none: map<string, Js> := map[];
    expect evolve(transf, none) == map["wow" := Str("undefined")];
  }

  // The object is a value, so the check holds trivially.
  method {:test} EvolveIsNotDestructive() {
    var transf := map["elapsed" := AddJs(1), "remaining" := AddJs(-1)];
    var obj := Tomato(100, 1400);
    var _ := evolve(transf, obj);
    expect obj == Tomato(100, 1400);
  }

  method {:test} EvolveIsCurried() {
    var tick := (o: map<string, Js>) => evolve(map["elapsed" := AddJs(1), "remaining" := AddJs(-1)], o);
    expect tick(Tomato(100, 1400)) == Tomato(101, 1399);
  }

  // ---- invert.js (v0.9.0) ----

  method {:test} InvertReturnsTheInputsValuesAsKeysAndKeysAsValues() {
    // `invert(['a', 'b', 'c'])`
    expect invert(map["0" := "a", "1" := "b", "2" := "c"]) == map["a" := {"0"}, "b" := {"1"}, "c" := {"2"}];
    expect invert(map["x" := "a", "y" := "b", "z" := "c"]) == map["a" := {"x"}, "b" := {"y"}, "c" := {"z"}];
  }

  method {:test} InvertPutsKeysThatHaveTheSameValueIntoTheAppropriateArray() {
    // `invert(['a', 'b', 'a'])`
    expect invert(map["0" := "a", "1" := "b", "2" := "a"]) == map["a" := {"0", "2"}, "b" := {"1"}];
    var inverted := invert(map["x" := "a", "y" := "b", "z" := "a", "_id" := "a"]);
    expect "a" in inverted && "b" in inverted;
    expect "x" in inverted["a"];
    expect "z" in inverted["a"];
    expect "_id" in inverted["a"];
    expect inverted["b"] == {"y"};
  }

  // The input is a value, so the check holds trivially.
  method {:test} InvertIsNotDestructive() {
    var input := map["x" := "a", "y" := "b", "z" := "a", "_id" := "a"];
    var _ := invert(input);
    expect input == map["x" := "a", "y" := "b", "z" := "a", "_id" := "a"];
  }

  // v0.10.0
  method {:test} InvertIgnoresInheritedProperties() {
    expect invert(map["x" := "hasOwnProperty"]) == map["hasOwnProperty" := {"x"}];
  }

  // ---- invertObj.js (v0.9.0) ----

  method {:test} InvertObjReturnsTheInputsValuesAsKeysAndKeysAsValues() {
    // `invertObj(['a', 'b', 'c'])`
    expect invertObj(map["0" := "a", "1" := "b", "2" := "c"]) == map["a" := "0", "b" := "1", "c" := "2"];
    expect invertObj(map["x" := "a", "y" := "b", "z" := "c"]) == map["a" := "x", "b" := "y", "c" := "z"];
  }

  // ---- dissoc.js (v0.10.0) ----

  method {:test} DissocCopiesAnObjectOmittingTheSpecifiedProperty() {
    expect dissoc("b", map["a" := 1, "b" := 2, "c" := 3]) == map["a" := 1, "c" := 3];
    expect dissoc("d", map["a" := 1, "b" := 2, "c" := 3]) == map["a" := 1, "b" := 2, "c" := 3];
  }

  method {:test} DissocIsCurried() {
    var dissocB := (o: map<string, int>) => dissoc("b", o);
    expect dissocB(map["a" := 1, "b" := 2, "c" := 3]) == map["a" := 1, "c" := 3];
  }

  // ---- lensOn.js (v0.11.0) ----

  // `xoLens = lensOn(o => o.x, v => ({x: v}), {x: 1})`
  function GetX(o: map<string, Js>): Js { if "x" in o then o["x"] else Undefined }
  function SetX(v: Js): map<string, Js> { map["x" := v] }
  function XoLens(): LensOn<Js, map<string, Js>> { lensOn(GetX, SetX, map["x" := Num(1)]) }

  method {:test} LensOnCanGetAValue() {
    expect XoLens().get() == Num(1);
  }

  method {:test} LensOnCanSetAValue() {
    expect XoLens().set_(Str("moocow")) == map["x" := Str("moocow")];
  }

  method {:test} LensOnMapsToANewObject() {
    var plus10 := (x: Js) => if x.Num? then Num(x.n + 10) else x;
    expect XoLens().map_(plus10) == map["x" := Num(11)];
  }

  // `partial2 = lensOn(getX)(setX)`
  method {:test} LensOnIsCurried() {
    var partial2 := (o: map<string, Js>) => lensOn(GetX, SetX, o);
    expect partial2(map["x" := Str("cow")]).set_(Str("moo")) == map["x" := Str("moo")];
    var x2 := (x: Js) => if x.Num? then Num(x.n * 2) else x;
    expect partial2(map["x" := Num(100)]).map_(x2) == map["x" := Num(200)];
  }

  // ---- lensProp.js (v0.14.0) ----

  // `phraseLens = R.lensProp('catchphrase')`, `xLens = R.lensProp('x')`; the
  // object mixes numbers and strings, so it holds Js values.
  function LpObj(): map<string, Js> { map["x" := Num(100), "y" := Num(200), "catchphrase" := Str("zing!")] }
  // `uc(s) = s.toUpperCase()`
  function Uc(v: Js): Js { if v.Str? then Str(S.toUpper(v.s)) else v }

  method {:test} LensPropRetrievesValuesFromInsideAnObject() {
    expect lensProp<Js>("catchphrase").get(LpObj()) == Str("zing!");
  }

  method {:test} LensPropSetsPropertiesOnAnObjectAndReturnsTheNewObject() {
    expect lensProp<Js>("catchphrase").set_(Str("cow"), LpObj()) ==
      map["x" := Num(100), "y" := Num(200), "catchphrase" := Str("cow")];
  }

  // The second assertion holds trivially: the object is a value.
  method {:test} LensPropTheSetterShouldNotMutateTheObject() {
    var obj := LpObj();
    expect lensProp<Js>("catchphrase").set_(Str("kapow!"), obj) ==
      map["x" := Num(100), "y" := Num(200), "catchphrase" := Str("kapow!")];
    expect obj == map["x" := Num(100), "y" := Num(200), "catchphrase" := Str("zing!")];
  }

  method {:test} LensPropMapsAPropertyFromGetterToSetter() {
    expect lensProp<Js>("catchphrase").map_(Uc, LpObj()) ==
      map["x" := Num(100), "y" := Num(200), "catchphrase" := Str("ZING!")];
  }

  method {:test} LensPropTheModifierShouldNotMutateTheObject() {
    var obj := LpObj();
    expect lensProp<Js>("catchphrase").map_(Uc, obj) ==
      map["x" := Num(100), "y" := Num(200), "catchphrase" := Str("ZING!")];
    expect obj == map["x" := Num(100), "y" := Num(200), "catchphrase" := Str("zing!")];
  }

  // `xPlus3 = R.compose(xLens.map(R.add(1)), xLens.map(R.add(2)))` and
  // `set0Plus1 = R.compose(xLens.map(R.add(1)), xLens.set(0))`. The getter,
  // and so map_, requires the key, while compose takes total functions, so
  // each curried map_ is guarded by `"x" in o`, which these objects always
  // pass; the setter is total.
  function PlusJs(k: int): Js -> Js { (v: Js) => if v.Num? then Num(v.n + k) else v }
  function XMap(k: int): map<string, Js> -> map<string, Js>
  { (o: map<string, Js>) => if "x" in o then lensProp<Js>("x").map_(PlusJs(k), o) else o }

  method {:test} LensPropCurriesMapAndSetAndModifiesWithComposedLens() {
    var xPlus3 := Funcs.compose(XMap(1), XMap(2));
    expect xPlus3(LpObj()) == map["x" := Num(103), "y" := Num(200), "catchphrase" := Str("zing!")];
    var set0 := (o: map<string, Js>) => lensProp<Js>("x").set_(Num(0), o);
    var set0Plus1 := Funcs.compose(XMap(1), set0);
    expect set0Plus1(LpObj()) == map["x" := Num(1), "y" := Num(200), "catchphrase" := Str("zing!")];
  }
}
