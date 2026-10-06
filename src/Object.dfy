// Ramdaf: Ramda v0.1.2 "Object Functions" (ramda.js lines 1000-1139) and `propEq`
// (line 1454). A JS object is a map<string, V>; a missing property is JS
// undefined, here None.

module Ramdaf.Object {
  import opened Prelude

  export
    reveals eq, prop, get, props, keys, values, pick, pickAll, omit, mixin, eqProps,
            where, propEq
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

  // `pickAll(keys(a), a)`, then every own property of b is copied over it:
  // b's value wins where both have the key (Dafny's right-biased map union).
  function mixin<V>(a: map<string, V>, b: map<string, V>): map<string, V>
    ensures mixin(a, b).Keys == a.Keys + b.Keys
    ensures forall k :: k in b ==> mixin(a, b)[k] == b[k]
    ensures forall k :: k in a && k !in b ==> mixin(a, b)[k] == a[k]
  { a + b }

  // `obj1[p] === obj2[p]` (two missing properties are both undefined: equal).
  function eqProps<V(==)>(p: string, obj1: map<string, V>, obj2: map<string, V>): bool
  { prop(p, obj1) == prop(p, obj2) }

  // `all(key => typeof spec[key] === 'function' ? spec[key](test[key], test)
  //                                             : test[key] === spec[key], keys(spec))`:
  // a function entry is called with the test object's property (None when it
  // is absent, i.e. undefined) and the test object; any other entry must equal
  // the property, so an absent property fails it. (A spec property whose value
  // is undefined cannot be written: in this encoding an undefined property is
  // an absent one.)
  function where<V(==)>(spec: map<string, SpecVal<V>>, test: map<string, V>): bool
  { forall k :: k in spec ==>
      match spec[k]
        case Pred(fn) => fn(prop(k, test), test)
        case Val(v) => k in test && test[k] == v }

  // `obj[name] === val`
  function propEq<V(==)>(name: string, val: V, obj: map<string, V>): bool
  { name in obj && obj[name] == val }
}
