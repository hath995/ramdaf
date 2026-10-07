// Ramdaf: Ramda v0.14.0 `src/<fn>.js` for the functions ported up to v0.8.0
// from ramda.js's "Object Functions" section and `propEq`; from v0.9.0 on,
// the functions with `@category Object` (`evolve`, `invert`, `invertObj`,
// `merge`, `dissoc`, `lensOn`, `lensProp`, `whereEq`). A JS object is a map<string, V>; a missing
// property is JS undefined, here None. The functions that build an object by
// assigning properties (`pick`, `pickAll`, `pickBy`, `omit`, `merge`,
// `assoc`, `evolve`, `invertObj`, `dissoc`, `lensProp`'s setter) drop an own `__proto__`
// property in JS, as the assignment sets the prototype instead; a map's keys
// are all ordinary (README "Deviations"). (v0.8.0 renamed `pickWith` to
// `pickBy`, and `props` to `propOf`, reusing the name `props` for a new
// function; v0.9.0 removed `cloneObj`, which `clone` (Core.dfy) took over;
// v0.10.0 renamed `mixin` to `merge`; v0.12.0 removed `propOf` and the `get`
// alias of `prop`, deprecated in v0.11.0.)

module Ramdaf.Object {
  import opened Prelude

  export
    reveals eq, prop, props, propOr, has, hasIn, keys, keysIn, toPairs, toPairsIn,
            values, valuesIn, pick, pickAll, omit, pickBy, merge, eqProps, where,
            assoc, propEq, evolve, invert, invertObj, dissoc, lensOn, lensProp, whereEq
    provides Prelude

  // `a === b` until v0.8.0; since v0.9.0 `Object.is`: `1 / a === 1 / b`
  // when a is 0, and `a === b || (a !== a && b !== b)` otherwise, so `-0`
  // and `0` differ and `NaN` equals itself. On ints that is `==`; JS
  // arithmetic can produce `-0`, which `int` does not have, and Dafny
  // equality is structural where JS compares objects and arrays by reference
  // (see README "Deviations").
  function eq<T(==)>(a: T, b: T): bool { a == b }

  // `obj[p]`
  function prop<V>(p: string, obj: map<string, V>): Option<V>
  { if p in obj then Some(obj[p]) else None }

  // `R.props(ps, obj)` (v0.8.0, "multiple `get`"): `out[idx] = obj[ps[idx]]`
  // for each name in ps, so the values in the order of ps, undefined (None)
  // where obj lacks the property. (Until v0.7.2 `props` was the function
  // that v0.8.0 renamed `propOf` and v0.12.0 removed.)
  function props<V>(ps: seq<string>, obj: map<string, V>): seq<Option<V>>
    ensures |props(ps, obj)| == |ps|
  { seq(|ps|, i requires 0 <= i < |ps| => prop(ps[i], obj)) }

  // `R.propOr(val, p, obj)` (`src/propOr.js`): `has(p, obj) ? obj[p] :
  // val`, obj's own property p, or val when obj lacks it. v0.9.0 moved the
  // default to the first argument ("take default value as first argument to
  // R.propOr"); until v0.8.0 it was `propOr(p, val, obj)`, with
  // `hasOwnProperty.call(obj, p)`. (v0.6.0 renamed `propOrDefault`, added in
  // v0.4.0, to `propOr`, with the same code.) Every property of a map is
  // its own.
  function propOr<V>(val: V, p: string, obj: map<string, V>): V
  { if has(p, obj) then obj[p] else val }

  // `R.has(prop, obj)` (v0.7.0): `hasOwnProperty.call(obj, prop)` (since
  // v0.11.0 `_curry2(_has)`, which also takes the placeholder, `has(__,
  // obj)`). Every property of a map is its own.
  function has<V>(p: string, obj: map<string, V>): bool { p in obj }

  // `R.hasIn(prop, obj)` (v0.7.0): `prop in obj`, an own property or one on
  // the prototype chain. A plain object's chain is `Object.prototype`, whose
  // own property names are exactly these 12 (node:
  // `Object.getOwnPropertyNames(Object.prototype)`), so `hasIn("toString",
  // map[])` is true, as `hasIn('toString', {})` is in node.
  function hasIn<V>(p: string, obj: map<string, V>): bool
  { p in obj ||
    p in {"__defineGetter__", "__defineSetter__", "__lookupGetter__", "__lookupSetter__",
          "__proto__", "constructor", "hasOwnProperty", "isPrototypeOf",
          "propertyIsEnumerable", "toLocaleString", "toString", "valueOf"} }

  // The own enumerable property names. JS returns them in insertion order;
  // a Dafny map has no order, so the result is a set.
  function keys<V>(obj: map<string, V>): set<string> { obj.Keys }

  // v0.2.0: `for (prop in obj) ks.push(prop)`, every enumerable property name
  // including inherited ones. A map is a plain object with no prototype
  // chain, so these are its keys.
  function keysIn<V>(obj: map<string, V>): set<string> { keys(obj) }

  // `R.toPairs = pairWith(R.keys)` (v0.4.0): `map(key => [key, obj[key]],
  // keys(obj))`, a [key, value] pair per own property. JS returns them in key
  // order; a map has none, so the result is a set (the keys are distinct, so
  // no pair is lost).
  function toPairs<V(==)>(obj: map<string, V>): set<(string, V)>
  { set k | k in keys(obj) :: (k, obj[k]) }

  // `R.toPairsIn = pairWith(R.keysIn)` (v0.4.0): the pairs of every
  // enumerable property, inherited ones included; for a map, toPairs.
  function toPairsIn<V(==)>(obj: map<string, V>): set<(string, V)>
  { set k | k in keysIn(obj) :: (k, obj[k]) }

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

  // The listed properties that exist on obj. (Since v0.7.0 pick, omit and
  // pickBy, `pickWith` until v0.7.2, iterate `keysIn(obj)`, since v0.11.0
  // with their own `for (var prop in obj)` loops, so inherited enumerable
  // properties count too; a map has none.)
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

  // `R.pickBy` (v0.8.0, which renamed `pickWith`, added in v0.2.3, with the
  // same results): the properties of obj for which `test(val, key, obj)` is
  // truthy (pick and omit are written with the private `_pickBy`, with
  // unchanged results).
  function pickBy<V>(test: (V, string, map<string, V>) -> bool, obj: map<string, V>): map<string, V>
    ensures pickBy(test, obj).Keys == set k | k in obj && test(obj[k], k, obj)
    ensures forall k :: k in pickBy(test, obj) ==> pickBy(test, obj)[k] == obj[k]
  { map k | k in obj && test(obj[k], k, obj) :: obj[k] }

  // `R.merge(a, b)` (v0.10.0, "rename R.mixin", with the same body):
  // `_extend(_extend({}, a), b)` (`mixin` since v0.2.4; before, `pickAll(keys(a),
  // a)` with b's properties copied over it), the own properties of a, then
  // of b: b's value wins where both have the key (Dafny's right-biased map
  // union). It was `op`-curried in v0.10.0 and is `_curry2` since v0.11.0,
  // which only add the placeholder form `merge(__, b)`. (Not the list
  // `merge` that v0.2.4 removed from Core.)
  function merge<V>(a: map<string, V>, b: map<string, V>): map<string, V>
    ensures merge(a, b).Keys == a.Keys + b.Keys
    ensures forall k :: k in b ==> merge(a, b)[k] == b[k]
    ensures forall k :: k in a && k !in b ==> merge(a, b)[k] == a[k]
  { a + b }

  // `obj1[p] === obj2[p]` (two missing properties are both undefined: equal;
  // since v0.14.0 `_eq(obj1[p], obj2[p])`, `Object.is`: README "Deviations"
  // on `-0`).
  function eqProps<V(==)>(p: string, obj1: map<string, V>, obj2: map<string, V>): bool
  { prop(p, obj1) == prop(p, obj2) }

  // `R.where(spec, testObj)` (v0.14.0, which moved the value entries to
  // `whereEq`): `for (var prop in spec) { if (_has(prop, spec) &&
  // !spec[prop](testObj[prop])) { return false; } } return true;`, every own
  // spec property is a predicate that holds for the test object's property,
  // undefined (None) when the test object lacks it (a JS test object also
  // passes an inherited member; a map has none). Until v0.13.0 a spec entry
  // was a function, called with the property and the whole test object only
  // when the property was there (since v0.2.3; before, with undefined too),
  // or a value compared with `===`, the removed `Prelude.SpecVal`; since
  // v0.14.0 a value entry throws TypeError ("spec[prop] is not a function"),
  // and a predicate on an absent property is called (`where({a: x => x ===
  // undefined}, {})` is true, was false).
  function where<V>(spec: map<string, Option<V> -> bool>, test: map<string, V>): bool
  { forall k :: k in spec ==> spec[k](prop(k, test)) }

  // `R.whereEq(spec, testObj)` (v0.14.0, `@category Object`):
  // `where(mapObj(eq, spec), testObj)`, every spec property equal (`eq`,
  // `Object.is`) to the test object's; an absent test property is undefined,
  // which no spec value here equals. `R.mapObj` is List's, which Object does
  // not import, so the spec of predicates is written out as a map
  // comprehension. A spec property whose value is undefined cannot be
  // written (README "Outside the modeled domain"), and `mapObj`'s copy drops
  // an own `__proto__` spec property in JS (README "Deviations").
  function whereEq<V(==)>(spec: map<string, V>, test: map<string, V>): bool
  { where(map k | k in spec :: (x: Option<V>) => x.Some? && eq(spec[k], x.value), test) }

  // `R.assoc(prop, val, obj)` (v0.8.0): `_assoc`, `for (var p in obj)
  // result[p] = obj[p]; result[prop] = val;` (v0.11.0; until v0.10.0
  // `_extend(fromPairs(map(key => [key, obj[key]], keysIn(obj))),
  // createMapEntry(prop, val))`, the same keys and values), a shallow copy of
  // obj with the property set to val (added if obj lacks it). On a map that
  // is the map update. In JS the key is converted to a string, and a
  // `__proto__` key (or an own `__proto__` property of obj) is not an
  // ordinary property (README "Deviations").
  function assoc<V>(p: string, val: V, obj: map<string, V>): map<string, V>
  { obj[p := val] }

  // `obj[name] === val` (since v0.14.0 `_eq(obj[name], val)`, `Object.is`:
  // README "Deviations" on `-0`)
  function propEq<V(==)>(name: string, val: V, obj: map<string, V>): bool
  { name in obj && obj[name] == val }

  // `R.evolve(transformations, object)` (v0.9.0): `_extend(_extend({},
  // object), mapObjIndexed((fn, key) => fn(object[key]), transformations))`,
  // a copy of object in which every key of transformations is set to its
  // function applied to `object[key]`, which is undefined (None) when object
  // lacks the key (Ramda's test "invokes function with undefined if object
  // does not contain the key"). JS lets a transformation change the value's
  // type, and since v0.12.0 an `@@transducer/reduced` transformation
  // (`__transducers_reduced__` until v0.13.0) with a truthy result ends
  // `mapObjIndexed`'s fold (README "Deviations").
  function evolve<V>(transformations: map<string, Option<V> -> V>, obj: map<string, V>): map<string, V>
    ensures evolve(transformations, obj).Keys == obj.Keys + transformations.Keys
  { obj + map k | k in transformations :: transformations[k](prop(k, obj)) }

  // `R.invert(obj)` (v0.9.0): `if (!has(val, out)) { out[val] = []; }
  // out[val].push(key);` over `keys(obj)` (v0.10.0, "ignore inherited
  // properties in R.invert"; v0.9.x's `out[val] = out[val] || []` found an
  // inherited member, so a value such as 'toString' threw), each value
  // mapped to the keys holding it. JS lists the keys in property order; a map
  // has none, so they are a set, as for `keys` (README "Deviations"). The
  // values become keys, so they are strings, and a `__proto__` value is not
  // an ordinary key in JS.
  function invert(obj: map<string, string>): map<string, set<string>>
    ensures invert(obj).Keys == obj.Values
  { map v | v in obj.Values :: set k | k in obj && obj[k] == v }

  // `R.invertObj(obj)` (v0.9.0): `out[obj[key]] = key` over `keys(obj)`,
  // each value mapped to its key. For a repeated value the key last in
  // property order wins, which a map does not carry, so the values must be
  // distinct (README "Outside the modeled domain").
  function invertObj(obj: map<string, string>): map<string, string>
    requires forall k1, k2 :: k1 in obj && k2 in obj && obj[k1] == obj[k2] ==> k1 == k2
    ensures invertObj(obj).Keys == obj.Values
    ensures forall k :: k in obj ==> invertObj(obj)[obj[k]] == k
  { map k | k in obj :: obj[k] := k }

  // `R.dissoc(prop, obj)` (v0.10.0): `_dissoc`, `for (var p in obj) { if (p
  // !== prop) { result[p] = obj[p]; } }` (v0.11.0; v0.10.0's
  // `_pickBy(function(val, key) { return key !== prop; }, obj)`, the body of
  // `R.pickBy`, gave the same results), a copy of obj without the property p:
  // the map without the key. JS compares the key with `!==`, so only a
  // string `prop` can match, and the loop also copies inherited enumerable
  // properties (a map has none).
  function dissoc<V>(p: string, obj: map<string, V>): map<string, V>
    ensures dissoc(p, obj) == obj - {p}
  { obj - {p} }

  // `R.lensOn(get, set, obj)` (v0.11.0, `@category Object`): `var lns =
  // function() { return get(obj); }; lns.set = set; lns.map = function(fn) {
  // return set(fn(get(obj))); }; return lns;`, a lens bound to obj, here the
  // record `Prelude.LensOn` (README "Deviations"; `set` is a Dafny keyword).
  // JS calls get on each use, so a later mutation of obj shows; a Dafny value
  // does not change. The code and Ramda's tests take obj last, as here (and
  // since v0.14.0 the JSDoc; v0.11.0 to v0.13.0's `@sig` and example put it
  // first, `R.lensOn(xo, get, set)`, which throws in node: "get is not a
  // function").
  // As for `lens`, get and set_ are partial arrows: the bound get requires
  // get's precondition on obj, and map_ that and set_'s on the mapped value.
  function lensOn<A, V, B>(get: A --> V, set_: V --> B, obj: A): LensOn<V, B>
  { LensOn(() requires get.requires(obj) => get(obj), set_,
           (fn: V -> V) requires get.requires(obj) && set_.requires(fn(get(obj))) => set_(fn(get(obj)))) }

  // `R.lensProp(k)` (v0.14.0, `@category Object`): `lens(prop(k),
  // assoc(k))`, a lens on the property k. The getter `prop(k)` is undefined
  // when obj lacks k (and is the inherited member for a name of
  // `Object.prototype`), which the value type cannot hold, so it requires
  // the key (README "Outside the modeled domain"); the setter is `assoc`,
  // total (`lensProp('x').set(9, {})` is `{x: 9}`). `R.lens` is List's, which
  // Object does not import, so its body is written out: map_ is set_ of fn
  // applied to get, requiring both.
  function lensProp<V>(k: string): Lens<map<string, V>, V>
  { var get := (obj: map<string, V>) requires k in obj => obj[k];
    var set_ := (v: V, obj: map<string, V>) => assoc(k, v, obj);
    Lens(get, set_, (fn: V -> V, obj: map<string, V>) requires get.requires(obj) && set_.requires(fn(get(obj)), obj) =>
                      set_(fn(get(obj)), obj)) }
}
