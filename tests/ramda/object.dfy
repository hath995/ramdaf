// Ramda v0.30.0 test/prop.js, props.js, propOr.js, has.js,
// hasIn.js, pluck.js, pick.js, pickAll.js, omit.js, pickBy.js, eqProps.js,
// where.js, whereEq.js, assoc.js, keys.js, keysIn.js, values.js,
// valuesIn.js, toPairs.js, toPairsIn.js, evolve.js, invert.js,
// invertObj.js, dissoc.js, lenses.js, objOf.js, mergeWith.js,
// mergeWithKey.js, lensProp.js, mergeLeft.js, mergeRight.js, modify.js and
// whereAny.js (merge.js until v0.27.2; v0.9.x mixin.js; until
// v0.8.0 test.objectBasics.js,
// test.keysvals.js, test.tapeq.js and test.zip.js's toPairs and toPairsIn
// describes), transcribed. (v0.26.0 removed the "is curried" `it`s of the
// per-function files, with their transcriptions here, and propOr.js's
// "does not return properties from the prototype chain"; its new "uses the
// default when supplied an object with a nil value" is a Deviations pin in
// tests/edge/, as the port returns the nil value. hasPath.js is not
// portable.) Not
// transcribed: keys's and values's "should work for primitives" cases (v0.2.4;
// keys/values of null, 55, "" and the like: the argument is a map); where's
// and whereEq's cases on prototypes (where's "matches inherited properties"
// and "does not match inherited spec", whereEq's "matches inherited props"
// and "does not match inherited spec"), whereEq's "reports true when the
// object equals the spec" (`whereEq(R, R)`: an object of functions, which
// have no equality here) and "matches specs that have undefined properties"
// (a spec value that is undefined cannot be written, README "Outside the
// modeled domain"), and the `null` spec of their "is true for an empty
// spec"; eqProps's "has Object.is semantics" (v0.14.0; since v0.15.0 "has
// R.equals semantics", with an object carrying an `equals` method; `-0`
// and NaN are not ints, README "Deviations", pinned in
// tests/edge/misc.dfy), evolve's "is recursive" (v0.15.0; a nested
// transformation object cannot be written, README "Outside the modeled
// domain"), propOr's "returns the default value when the object is nil"
// (v0.15.0; null and undefined are not maps) and pluck's "behaves as a transducer…" (v0.14.0;
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
// removed propOf.js and prop's "is aliased by `get`" with the functions;
// v0.16.0 removed lensOn.js and lensProp.js, whose lenses lenses.js now
// covers with `view`, `over` and `set`; v0.19.0 brings lensProp.js back,
// and adds `pets` to lenses.js's alice and two `lensPath` `it`s, not
// transcribed, as lensPath is not portable, README.) Of v0.19.0's
// mergeWith.js and mergeWithKey.js, "reports only own properties"
// (prototypes) and the `notStrictEqual` half of "is not destructive"
// (reference identity) are not transcribed; of lensProp.js, "returns
// undefined if the specified property does not exist", "adds the property
// to the object if it doesn't exist" and "applies function to undefined and
// adds the property" are outside the lens's domain (README "Outside the
// modeled domain"), and "can be composed" runs over `{a: {b: 1}}` alone (its
// `c: 2` cannot share the map's value type, as in lenses.js). v0.15.0 deleted eq.js with `eq` (identical.js, in
// tests/ramda/sql.dfy, has its asserts), replaced evolve's "invokes function
// with undefined if object does not contain the key" with "does not invoke
// function if object does not contain the key", and where.js's `R.eq`
// with `R.equals`. v0.14.0 rewrote where.js for specs of predicates: it
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
  import D = Ramdaf.Data
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

  // v0.15.0: "handles numbers as properties", `pick([1], obj)` with `obj`'s
  // extra `1: 7`; the name is the key "1" here (keys are strings, README
  // "Deviations").
  method {:test} PickHandlesNumbersAsProperties() {
    expect pick(["1"], Abc()["1" := 7]) == map["1" := 7];
  }

  // describe('pickAll')
  method {:test} PickAllCopiesTheNamedProperties() {
    expect pickAll(["a", "c", "f"], Abc()) == map["a" := Some(1), "c" := Some(3), "f" := Some(6)];
  }

  method {:test} PickAllIncludesPropertiesNotPresent() {
    expect pickAll(["a", "c", "g"], Abc()) == map["a" := Some(1), "c" := Some(3), "g" := None];
  }

  // describe('omit')
  method {:test} OmitOmitsTheListedProperties() {
    expect omit(["a", "c", "f"], Abc()) == map["b" := 2, "d" := 4, "e" := 5];
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

  // describe('eqProps')
  method {:test} EqPropsComparesAProperty() {
    expect eqProps("name", map["name" := Str("fred"), "age" := Num(10)], map["name" := Str("fred"), "age" := Num(12)]) == true;
    expect eqProps("name", map["name" := Str("fred"), "age" := Num(10)], map["name" := Str("franny"), "age" := Num(10)]) == false;
  }

  // describe('where') (v0.14.0 rewrote where.js: every spec value is a
  // predicate on the test object's property). `R.equals(a)` (`R.eq(a)`
  // until v0.14.0) is a predicate that holds for a property equal to a and
  // fails on an absent one (undefined).
  function Xy(x: int, y: int): map<string, int> { map["x" := x, "y" := y] }
  function EqP(a: int): Option<int> -> bool { (v: Option<int>) => v.Some? && D.equals(a, v.value) }

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

  // "matches specs that have undefined properties": `R.equals(undefined)` holds
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

  // (its `whereEq(null, {a: 1})` case cannot be written)
  method {:test} WhereEqIsTrueForAnEmptySpec() {
    var empty: map<string, int> := map[];
    expect whereEq(empty, map["a" := 1]) == true;
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

  // ---- evolve.js (v0.9.0) ----

  // `R.add(k)` over the Js numbers it meets here (`add(1)(undefined)` would
  // be NaN, which these cases never reach; since v0.15.0 evolve calls a
  // transformation only on a key the object has)
  function AddJs(k: int): Option<Js> -> Js
  { (v: Option<Js>) => if v.Some? && v.value.Num? then Num(v.value.n + k) else Undefined }

  function Tomato(elapsed: int, remaining: int): map<string, Js>
  { map["name" := Str("Tomato"), "elapsed" := Num(elapsed), "remaining" := Num(remaining)] }

  method {:test} EvolveCreatesANewObjectByEvolvingTheObject() {
    var transf := map["elapsed" := AddJs(1), "remaining" := AddJs(-1)];
    expect evolve(transf, Tomato(100, 1400)) == Tomato(101, 1399);
  }

  // v0.15.0 (in place of v0.9.0's "invokes function with undefined if
  // object does not contain the key"): `{n: add(1), m: add(1)}` on `{m: 3}`
  method {:test} EvolveDoesNotInvokeFunctionIfObjectDoesNotContainTheKey() {
    var transf := map["n" := AddJs(1), "m" := AddJs(1)];
    expect evolve(transf, map["m" := Num(3)]) == map["m" := Num(4)];
  }

  // The object is a value, so the check holds trivially.
  method {:test} EvolveIsNotDestructive() {
    var transf := map["elapsed" := AddJs(1), "remaining" := AddJs(-1)];
    var obj := Tomato(100, 1400);
    var _ := evolve(transf, obj);
    expect obj == Tomato(100, 1400);
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

  // ---- lenses.js (v0.16.0, describe('view, over, and set'), which
  // replaced lens.js, lensIndex.js, lensProp.js, composeL.js, pipeL.js and
  // lensOn.js with the van Laarhoven lenses; its `eq` compares
  // `R.toString`s, structurally) ----

  // `alice = {name: 'Alice Jones', address: ['22 Walnut St', 'San
  // Francisco', 'CA'], pets: {dog: 'joker', cat: 'batman'}}` (`pets` since
  // v0.19.0), a Js object here; `nameLens = R.lens(R.prop('name'),
  // R.assoc('name'))`, whose getter is defined where the object has a name
  // (`prop` of an absent name is undefined, outside the lens's domain);
  // `headLens = R.lensIndex(0)`, applied to `alice.address`; `R.toUpper` on
  // a Js string is Uc, and on a string a lambda calling `S.toUpper` (with
  // `S.toUpper` itself as the value, the verifier does not prove `over`'s
  // precondition).
  function Uc(v: Js): Js { if v.Str? then Str(S.toUpper(v.s)) else v }
  function AliceAddress(): seq<string> { ["22 Walnut St", "San Francisco", "CA"] }
  function Address(): Js { Arr([Str("22 Walnut St"), Str("San Francisco"), Str("CA")]) }
  function Pets(): Js { Obj(map["dog" := Str("joker"), "cat" := Str("batman")]) }
  function Alice(): map<string, Js>
  { map["name" := Str("Alice Jones"), "address" := Address(), "pets" := Pets()] }
  function NameLens(): Lens<map<string, Js>, Js, Js>
  { lens((o: map<string, Js>) requires "name" in o => o["name"], (v: Js, o: map<string, Js>) => assoc("name", v, o)) }

  method {:test} ViewOverAndSetMayBeAppliedToALensCreatedByLensProp() {
    assert "name" in Alice();  // witness for the lens's domain (v0.19.0's pets)
    expect view(NameLens(), Alice()) == Str("Alice Jones");
    expect over(NameLens(), Uc, Alice()) ==
      map["name" := Str("ALICE JONES"), "address" := Address(), "pets" := Pets()];
    expect set_(NameLens(), Str("Alice Smith"), Alice()) ==
      map["name" := Str("Alice Smith"), "address" := Address(), "pets" := Pets()];
  }

  method {:test} ViewOverAndSetMayBeAppliedToALensCreatedByLensIndex() {
    var headLens := lensIndex<string, string>(0);
    expect view(headLens, AliceAddress()) == "22 Walnut St";
    expect over(headLens, (s: string) => S.toUpper(s), AliceAddress()) == ["22 WALNUT ST", "San Francisco", "CA"];
    expect set_(headLens, "52 Crane Ave", AliceAddress()) == ["52 Crane Ave", "San Francisco", "CA"];
  }

  // `streetLens = R.compose(addressLens, headLens)` with `addressLens =
  // R.lensProp('address')`: lenses compose with `compose`. The object here
  // is alice's address alone, a map of lists of strings, as lensIndex
  // focuses a list and alice's name (a string) cannot share the map's value
  // type; JS leaves the name as it is.
  method {:test} ViewOverAndSetMayBeAppliedToComposedLenses() {
    var alice := map["address" := AliceAddress()];
    var streetLens := Funcs.compose(lensProp<seq<string>, string>("address"), lensIndex<string, string>(0));
    expect view(streetLens, alice) == "22 Walnut St";
    expect over(streetLens, (s: string) => S.toUpper(s), alice) == map["address" := ["22 WALNUT ST", "San Francisco", "CA"]];
    expect set_(streetLens, "52 Crane Ave", alice) == map["address" := ["52 Crane Ave", "San Francisco", "CA"]];
  }

  // ---- objOf.js (v0.18.0) ----

  // `objOf('foo')(42)` as a lambda
  method {:test} ObjOfCreatesAnObjectContainingASingleKeyValuePair() {
    expect objOf("foo", 42) == map["foo" := 42];
    var objOfFoo := (v: int) => objOf("foo", v);
    expect objOfFoo(42) == map["foo" := 42];
  }

  // ---- mergeWith.js, mergeWithKey.js (v0.19.0): `last(x, y) = y` (and
  // `last(k, x, y) = y`) ----

  method {:test} MergeWithTakesTwoObjectsAndMergesTheirOwnProperties() {
    expect mergeWith((x: int, y: int) => y, map["w" := 1, "x" := 2], map["y" := 3, "z" := 4]) ==
      map["w" := 1, "x" := 2, "y" := 3, "z" := 4];
  }

  method {:test} MergeWithAppliesTheFunctionToTheValuesOfKeysInBothObjects() {
    expect mergeWith((a: string, b: string) => a + b, map["x" := "a", "y" := "c"], map["x" := "b", "z" := "d"]) ==
      map["x" := "ab", "y" := "c", "z" := "d"];
  }

  method {:test} MergeWithIsNotDestructive() {
    expect mergeWith((x: int, y: int) => y, map["w" := 1, "x" := 2], map["x" := 5]) == map["w" := 1, "x" := 5];
  }

  method {:test} MergeWithKeyTakesTwoObjectsAndMergesTheirOwnProperties() {
    expect mergeWithKey((k: string, x: int, y: int) => y, map["w" := 1, "x" := 2], map["y" := 3, "z" := 4]) ==
      map["w" := 1, "x" := 2, "y" := 3, "z" := 4];
  }

  method {:test} MergeWithKeyAppliesTheFunctionToTheKeyAndTheValuesOfKeysInBothObjects() {
    expect mergeWithKey((k: string, a: string, b: string) => k + a + b, map["a" := "b", "x" := "d"], map["a" := "c", "y" := "e"]) ==
      map["a" := "abc", "x" := "d", "y" := "e"];
  }

  method {:test} MergeWithKeyIsNotDestructive() {
    expect mergeWithKey((k: string, x: int, y: int) => y, map["w" := 1, "x" := 2], map["x" := 5]) == map["w" := 1, "x" := 5];
  }

  // ---- lensProp.js (v0.19.0, again): `testObj = {a: 1, b: 2, c: 3}` ----
  function TestObj(): map<string, int> { map["a" := 1, "b" := 2, "c" := 3] }

  method {:test} LensPropViewFocusesTheSpecifiedObjectProperty() {
    expect view(lensProp<int, int>("a"), TestObj()) == 1;
  }

  method {:test} LensPropSetSetsTheValueOfTheObjectPropertySpecified() {
    expect set_(lensProp<int, int>("a"), 0, TestObj()) == map["a" := 0, "b" := 2, "c" := 3];
  }

  // `R.inc`
  method {:test} LensPropOverAppliesFunctionToTheValueOfTheSpecifiedObjectProperty() {
    expect over(lensProp<int, int>("a"), (x: int) => x + 1, TestObj()) == map["a" := 2, "b" := 2, "c" := 3];
  }

  // over `{a: {b: 1}}` alone (JS's `c: 2` cannot share the map's value type)
  method {:test} LensPropCanBeComposed() {
    var nestedObj := map["a" := map["b" := 1]];
    var composedLens := Funcs.compose(lensProp<map<string, int>, int>("a"), lensProp<int, int>("b"));
    expect view(composedLens, nestedObj) == 1;
  }

  // "well behaved lens"
  method {:test} LensPropSetOfGetIsIdentity() {
    expect set_(lensProp<int, int>("a"), view(lensProp<int, int>("a"), TestObj()), TestObj()) == TestObj();
  }

  method {:test} LensPropGetOfSetIsTheValue() {
    expect view(lensProp<int, int>("a"), set_(lensProp<int, int>("a"), 0, TestObj())) == 0;
  }

  method {:test} LensPropGetOfSetOfSetIsTheLastValue() {
    expect view(lensProp<int, int>("a"), set_(lensProp<int, int>("a"), 11, set_(lensProp<int, int>("a"), 10, TestObj()))) == 11;
  }

  // ---- mergeLeft.js, mergeRight.js (v0.26.0) ----

  method {:test} MergeLeftTakesTwoObjectsMergesTheirOwnPropertiesAndReturnsANewObject() {
    expect mergeLeft(map["w" := 1, "x" := 2], map["y" := 3, "z" := 4]) == map["w" := 1, "x" := 2, "y" := 3, "z" := 4];
  }

  method {:test} MergeLeftOverridesPropertiesInTheSecondObjectWithPropertiesInTheFirstObject() {
    expect mergeLeft(map["w" := 1, "x" := 2], map["w" := 100, "y" := 3, "z" := 4]) ==
      map["w" := 1, "x" := 2, "y" := 3, "z" := 4];
  }

  // its reference-inequality half has no counterpart (the map a is a value)
  method {:test} MergeLeftIsNotDestructive() {
    var a := map["w" := 1, "x" := 2];
    expect mergeLeft(a, map["x" := 3, "y" := 4]) == map["w" := 1, "x" := 2, "y" := 4];
    expect a == map["w" := 1, "x" := 2];
  }

  // `new Cla` has no own property (its x is on the prototype), so as a map
  // it is empty.
  method {:test} MergeLeftReportsOnlyOwnProperties() {
    var a := map["w" := 1, "x" := 2];
    var cla: map<string, int> := map[];
    expect mergeLeft(cla, a) == map["w" := 1, "x" := 2];
    expect mergeLeft(a, cla) == map["w" := 1, "x" := 2];
  }

  // The values mix objects and numbers (Js); its `strictEqual(a.x, res.x)`
  // (reference identity) has no counterpart.
  method {:test} MergeLeftIsShallow() {
    var a := map["x" := Obj(map["u" := Num(1), "v" := Num(2)]), "y" := Num(0)];
    var b := map["x" := Obj(map["u" := Num(3), "w" := Num(4)]), "z" := Num(0)];
    expect mergeLeft(a, b) == map["x" := Obj(map["u" := Num(1), "v" := Num(2)]), "y" := Num(0), "z" := Num(0)];
  }

  method {:test} MergeRightTakesTwoObjectsMergesTheirOwnPropertiesAndReturnsANewObject() {
    expect mergeRight(map["w" := 1, "x" := 2], map["y" := 3, "z" := 4]) == map["w" := 1, "x" := 2, "y" := 3, "z" := 4];
  }

  method {:test} MergeRightOverridesPropertiesInTheFirstObjectWithPropertiesInTheSecondObject() {
    expect mergeRight(map["w" := 1, "x" := 2], map["w" := 100, "y" := 3, "z" := 4]) ==
      map["w" := 100, "x" := 2, "y" := 3, "z" := 4];
  }

  method {:test} MergeRightIsNotDestructive() {
    var a := map["w" := 1, "x" := 2];
    expect mergeRight(a, map["x" := 5]) == map["w" := 1, "x" := 5];
    expect a == map["w" := 1, "x" := 2];
  }

  method {:test} MergeRightReportsOnlyOwnProperties() {
    var a := map["w" := 1, "x" := 2];
    var cla: map<string, int> := map[];
    expect mergeRight(cla, a) == map["w" := 1, "x" := 2];
    expect mergeRight(a, cla) == map["w" := 1, "x" := 2];
  }

  method {:test} MergeRightIsShallow() {
    var a := map["x" := Obj(map["u" := Num(1), "v" := Num(2)]), "y" := Num(0)];
    var b := map["x" := Obj(map["u" := Num(3), "w" := Num(4)]), "z" := Num(0)];
    expect mergeRight(a, b) == map["x" := Obj(map["u" := Num(3), "w" := Num(4)]), "y" := Num(0), "z" := Num(0)];
  }

  // ---- has.js (v0.27.0): "tests currying", `R.has('a')({a: {b: 1}})`; its
  // "returns false for non-objects" (undefined, null, true, '', a RegExp)
  // has no map argument ----

  method {:test} HasTestsCurrying() {
    var hasA := (o: map<string, Js>) => has("a", o);
    expect hasA(map["a" := Obj(map["b" := Num(1)])]) == true;
  }

  // ---- modify.js (v0.28.0): the object mixes a string and numbers (Js),
  // and `R.add(1)` adds to a number. Its "ignores primitive value
  // transformations" and "ignores null transformations" (fn is not a
  // function), "adjust if `array`…" (an array object) and "ignores
  // transformations if the input value is not Array and Object" are not
  // transcribed. ----

  function AddOneJs(v: Js): Js { if v.Num? then Num(v.n + 1) else v }

  method {:test} ModifyCreatesANewObjectByApplyingTheTransformationToTheProperty() {
    expect modify_("elapsed", AddOneJs, Tomato(100, 1400)) == Tomato(101, 1400);
  }

  method {:test} ModifyReturnsTheOriginalObjectIfObjectDoesNotContainTheProperty() {
    expect modify_("nonexistent", AddOneJs, Tomato(100, 1400)) == Tomato(100, 1400);
  }

  method {:test} ModifyIsNotDestructive() {
    var obj := Tomato(100, 1400);
    var res := modify_("elapsed", AddOneJs, obj);
    expect res == Tomato(101, 1400);
    expect obj == Tomato(100, 1400);
  }

  // ---- whereAny.js (v0.28.0): `R.equals(n)` is `x == Some(n)`. Its
  // "matches inherited properties" and "does not match inherited spec"
  // (prototypes) are not transcribed, as for where. ----

  method {:test} WhereAnyReturnsTrueIfTheTestObjectSatisfiesTheSpec() {
    var spec := map["x" := (v: Option<int>) => v == Some(0), "y" := (v: Option<int>) => v == Some(2)];
    expect whereAny(spec, map["x" := 0, "y" := 200]) == true;
    expect whereAny(spec, map["x" := 0, "y" := 10]) == true;
    expect whereAny(spec, map["x" := 1, "y" := 101]) == false;
    expect whereAny(spec, map["x" := 1, "y" := 2]) == true;
  }

  method {:test} WhereAnyDoesNotNeedTheSpecAndTheTestObjectToHaveTheSameInterface() {
    var spec := map["x" := (v: Option<int>) => v == Some(100)];
    expect whereAny(spec, map["x" := 20, "y" := 100, "z" := 100]) == false;
    expect whereAny(spec, map["w" := 1, "x" := 100, "y" := 100, "z" := 100]) == true;
  }

  // `R.equals(undefined)` holds for undefined (None) only; `{x: undefined}`
  // is the object without x here (README mapping), and `{x: null}` has the
  // Js value Null (as for where).
  method {:test} WhereAnyMatchesSpecsThatHaveUndefinedProperties() {
    var spec := map["x" := (v: Option<Js>) => v.None?];
    var none: map<string, Js> := map[];
    expect whereAny(spec, none) == true;
    expect whereAny(spec, map["x" := Null]) == false;
    expect whereAny(spec, none) == true;
    expect whereAny(spec, map["x" := Num(1)]) == false;
  }

  method {:test} WhereAnyIsFalseForAnEmptySpec() {
    var empty: map<string, Option<int> -> bool> := map[];
    expect whereAny(empty, map["a" := 1]) == false;
  }
}
