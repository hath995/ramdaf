// Ramdaf: Ramda v0.3.0 "Object Functions" (ramda.js lines 2837-3157) and `propEq`
// (line 3826). A JS object is a map<string, V>; a missing property is JS
// undefined, here None.

module Ramdaf.Object {
  import opened Prelude

  export
    reveals eq, prop, get, props, keys, keysIn, values, valuesIn, pick, pickAll, omit,
            pickWith, mixin, eqProps, where, propEq
    provides Prelude

  // `a === b`. Dafny equality is structural where JS compares objects and
  // arrays by reference (see README "Deviations").
  function eq<T(==)>(a: T, b: T): bool { a == b }

  // `obj[p]`
  function prop<V>(p: string, obj: map<string, V>): Option<V>
  { if p in obj then Some(obj[p]) else None }
  function get<V>(p: string, obj: map<string, V>): Option<V> { prop(p, obj) }

  // `obj && obj[prop]`: prop with the arguments the other way round.
  function props<V>(obj: map<string, V>, p: string): Option<V> { prop(p, obj) }

  // The own enumerable property names. JS returns them in insertion order;
  // a Dafny map has no order, so the result is a set.
  function keys<V>(obj: map<string, V>): set<string> { obj.Keys }

  // v0.2.0: `for (prop in obj) ks.push(prop)`, every enumerable property name
  // including inherited ones. A map is a plain object with no prototype
  // chain, so these are its keys.
  function keysIn<V>(obj: map<string, V>): set<string> { keys(obj) }

  // The own enumerable property values, one per key (so duplicates are kept).
  // JS returns them in key order; the result is a multiset.
  function values<V(==)>(obj: map<string, V>): multiset<V>
    decreases |obj|
    ensures |values(obj)| == |obj|
    ensures forall k :: k in obj ==> obj[k] in values(obj)
  { if |obj| == 0 then multiset{}
    else var k :| k in obj;
         var rest := obj - {k};
         assert |rest| == |obj| - 1;
         assert forall j :: j in obj && j != k ==> j in rest && rest[j] == obj[j];
         multiset{obj[k]} + values(rest) }
  by method {
    var rest := obj;
    var acc: multiset<V> := multiset{};
    while |rest| > 0
      invariant acc + values(rest) == values(obj)
      decreases |rest|
    {
      var k :| k in rest;
      ValuesRemove(rest, k);
      acc := acc + multiset{rest[k]};
      rest := rest - {k};
    }
    assert rest == map[];
    return acc;
  }

  // v0.2.0: `for (prop in obj) vs.push(obj[prop])`, every enumerable
  // property value including inherited ones; for a map, its values.
  function valuesIn<V(==)>(obj: map<string, V>): multiset<V> { values(obj) }

  // values does not depend on which key it removes first.
  lemma ValuesRemove<V>(obj: map<string, V>, k: string)
    requires k in obj
    ensures values(obj) == multiset{obj[k]} + values(obj - {k})
    decreases |obj|
  {
    var k0 :| k0 in obj && values(obj) == multiset{obj[k0]} + values(obj - {k0});
    if k0 != k {
      var without0, withoutK := obj - {k0}, obj - {k};
      assert k in without0 && without0[k] == obj[k];
      assert k0 in withoutK && withoutK[k0] == obj[k0];
      ValuesRemove(without0, k);
      ValuesRemove(withoutK, k0);
      assert without0 - {k} == withoutK - {k0};
    }
  }

  // The listed properties that exist on obj.
  function pick<V>(names: seq<string>, obj: map<string, V>): map<string, V>
    ensures pick(names, obj).Keys == obj.Keys * set n | n in names
  { map k | k in obj && k in names :: obj[k] }

  // Every listed property, `undefined` (None) where obj lacks it.
  function pickAll<V>(names: seq<string>, obj: map<string, V>): map<string, Option<V>>
    ensures pickAll(names, obj).Keys == set n | n in names
  { map k | k in names :: prop(k, obj) }

  // The properties of obj that are not listed.
  function omit<V>(names: seq<string>, obj: map<string, V>): map<string, V>
    ensures omit(names, obj).Keys == obj.Keys - set n | n in names
  { map k | k in obj && k !in names :: obj[k] }

  // v0.2.3: the own properties of obj for which `test(val, key, obj)` is
  // truthy (pick and omit are now written with it, with unchanged results).
  function pickWith<V>(test: (V, string, map<string, V>) -> bool, obj: map<string, V>): map<string, V>
    ensures pickWith(test, obj).Keys == set k | k in obj && test(obj[k], k, obj)
    ensures forall k :: k in pickWith(test, obj) ==> pickWith(test, obj)[k] == obj[k]
  { map k | k in obj && test(obj[k], k, obj) :: obj[k] }

  // `extend(extend({}, a), b)` (v0.2.4; before, `pickAll(keys(a), a)` with
  // b's properties copied over it): b's value wins where both have the key
  // (Dafny's right-biased map union).
  function mixin<V>(a: map<string, V>, b: map<string, V>): map<string, V>
    ensures mixin(a, b).Keys == a.Keys + b.Keys
    ensures forall k :: k in b ==> mixin(a, b)[k] == b[k]
    ensures forall k :: k in a && k !in b ==> mixin(a, b)[k] == a[k]
  { a + b }

  // `obj1[p] === obj2[p]` (two missing properties are both undefined: equal).
  function eqProps<V(==)>(p: string, obj1: map<string, V>, obj2: map<string, V>): bool
  { prop(p, obj1) == prop(p, obj2) }

  // Every function entry is a property of test and holds,
  // `(key in testObj) && spec[key](testObj[key], testObj)`, and every other
  // entry equals the property, `spec[key] === testObj[key]` (v0.2.4, which
  // also accepts inherited properties where v0.2.3 checked
  // `hasOwnProperty`; a map has none; a null-ish test gives false). Since v0.2.3 a function entry whose
  // property is absent fails without being called; before, it was called with
  // undefined (None). So a function now only ever sees Some. Neither a spec
  // property whose value is undefined nor a null test can be written here (an
  // undefined property is an absent one, and the test is a map).
  function where<V(==)>(spec: map<string, SpecVal<V>>, test: map<string, V>): bool
  { forall k :: k in spec ==>
      match spec[k]
        case Pred(fn) => k in test && fn(Some(test[k]), test)
        case Val(v) => k in test && test[k] == v }

  // `obj[name] === val`
  function propEq<V(==)>(name: string, val: V, obj: map<string, V>): bool
  { name in obj && obj[name] == val }
}
