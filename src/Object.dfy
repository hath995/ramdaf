// Ramdaf: Ramda v0.29.1 `source/<fn>.js` for the functions ported up to v0.8.0
// from ramda.js's "Object Functions" section and `propEq`; from v0.9.0 on,
// the functions with `@category Object` (`evolve`, `invert`, `invertObj`,
// `dissoc`, `lensProp`, `whereEq`, `view`, `over`, `set_`, `objOf`,
// `mergeWith`, `mergeWithKey`, `mergeLeft`, `mergeRight`, `modify_`
// (`modify`), `whereAny`). A JS object is a map<string, V>; a missing property is JS
// undefined, here None. The functions that build an object by assigning
// properties (`pick`, `pickAll`, `pickBy`, `omit`, `assoc`, `evolve`,
// `invertObj`, `dissoc`, `lensProp`'s setter, `objOf`, `mergeWithKey`,
// `mergeLeft`, `mergeRight`, `modify_`; `merge` until v0.27.2) drop an own
// `__proto__` property in JS, as the assignment sets the prototype instead; a
// map's keys are all ordinary (README "Deviations"). (v0.8.0 renamed `pickWith` to
// `pickBy`, and `props` to `propOf`, reusing the name `props` for a new
// function; v0.9.0 removed `cloneObj`, which `clone` (Core.dfy) took over;
// v0.10.0 renamed `mixin` to `merge`; v0.12.0 removed `propOf` and the `get`
// alias of `prop`, deprecated in v0.11.0; v0.15.0 removed `eq`, whose
// `Object.is` is now `identical`, `@category Relation`, in Data.dfy, where
// v0.15.1 restores `eq` itself, deprecated; v0.16.0 removed `lensOn`, as
// lenses became van Laarhoven functions, and `eq` again; v0.28.0 removed
// `merge`, deprecated since v0.26.0 for `mergeRight`.)

module Ramdaf.Object {
  import opened Prelude

  export
    reveals prop, props, propOr, has, hasIn, keys, keysIn, toPairs, toPairsIn,
            values, valuesIn, pick, pickAll, omit, pickBy, eqProps, where,
            assoc, propEq, evolve, invert, invertObj, dissoc, lensProp, whereEq,
            view, over, set_, objOf, mergeWith, mergeWithKey, mergeLeft, mergeRight, modify_,
            whereAny
    provides Prelude

  // `obj[p]`, undefined (None) when obj lacks p. In JS a name of an
  // `Object.prototype` member that obj lacks finds the inherited member
  // (`prop('toString', {})` is a function); a map has no prototype, so it is
  // None (README "Deviations"). Since v0.25.0 (68e4ea9e) it is `path([p],
  // obj)`, the same on an object, and undefined for a null or undefined obj
  // (which threw TypeError), which a map cannot be.
  function prop<V>(p: string, obj: map<string, V>): Option<V>
  { if p in obj then Some(obj[p]) else None }

  // `R.props(ps, obj)` (v0.8.0, "multiple `get`"): `out[idx] = obj[ps[idx]]`
  // for each name in ps, so the values in the order of ps, undefined (None)
  // where obj lacks the property (an inherited `Object.prototype` member in
  // JS, as for prop). (Until v0.7.2 `props` was the function that v0.8.0
  // renamed `propOf` and v0.12.0 removed.) Since v0.27.0 it is
  // `ps.map(function(p) { return path([p], obj); })`, which reads an integer
  // name with `nth` and gives undefineds for a nil obj; the names here are
  // strings, so the results are the same.
  function props<V>(ps: seq<string>, obj: map<string, V>): seq<Option<V>>
    ensures |props(ps, obj)| == |ps|
  { seq(|ps|, i requires 0 <= i < |ps| => prop(ps[i], obj)) }

  // `R.propOr(val, p, obj)` (`src/propOr.js`): `has(p, obj) ? obj[p] :
  // val` (since v0.15.0 also val for a null or undefined obj), obj's own property p, or val when obj lacks it. v0.9.0 moved the
  // default to the first argument ("take default value as first argument to
  // R.propOr"); until v0.8.0 it was `propOr(p, val, obj)`, with
  // `hasOwnProperty.call(obj, p)`. (v0.6.0 renamed `propOrDefault`, added in
  // v0.4.0, to `propOr`, with the same code.) Every property of a map is
  // its own. Since v0.26.0 it is `pathOr(val, [p], obj)`, which also gives
  // val for a property whose value is null, undefined or NaN (`propOr('d',
  // 'x', {x: null})` is 'd', where it was null) and reads an inherited
  // member (`propOr('d', 'toString', {})` is the inherited function); the
  // port's V has no nil value to test and a map no prototype, and `pathOr`
  // is not portable, so the body stays (README "Deviations").
  function propOr<V>(val: V, p: string, obj: map<string, V>): V
  { if has(p, obj) then obj[p] else val }

  // `R.has(prop, obj)` (v0.7.0): `hasOwnProperty.call(obj, prop)` (since
  // v0.11.0 `_curry2(_has)`, which also takes the placeholder, `has(__,
  // obj)`; since v0.26.0 `hasPath([prop], obj)`, which is `_has` for one
  // name, and since v0.27.0 false for a null or undefined obj, where it threw
  // TypeError). Every property of a map is its own.
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
  // properties count too; a map has none. Since v0.15.0 pick loops over the
  // names instead, `if (names[idx] in obj)`, which also holds for the
  // non-enumerable members of `Object.prototype`: `pick(['toString'], {})`
  // has the inherited function as its `toString`, README "Deviations".)
  function pick<V>(names: seq<string>, obj: map<string, V>): map<string, V>
    ensures pick(names, obj).Keys == obj.Keys * set n | n in names
  { map k | k in obj && k in names :: obj[k] }

  // Every listed property, `undefined` (None) where obj lacks it (in JS
  // `obj[name]`, so a name of an `Object.prototype` member gets the
  // inherited member, as for prop: README "Deviations").
  function pickAll<V>(names: seq<string>, obj: map<string, V>): map<string, Option<V>>
    ensures pickAll(names, obj).Keys == set n | n in names
  { map k | k in names :: prop(k, obj) }

  // The properties of obj that are not listed. Since v0.25.0 (67d8b7a3,
  // "Improve performance of omit") `var index = {}; … index[names[idx]] = 1;`
  // and `for (var prop in obj) { if (!index.hasOwnProperty(prop)) {
  // result[prop] = obj[prop]; } }` (until v0.24.1 `!_contains(prop,
  // names)`): the same keys, except that a name 'hasOwnProperty' becomes an
  // own property of index that shadows the method, so the first property of
  // obj throws TypeError (`omit(['hasOwnProperty'], {a: 1})`; with no
  // property there is no call, `omit(['hasOwnProperty'], {})` is {}), hence
  // the precondition (README "Outside the modeled domain"). JS converts the
  // names to keys (`omit([1], {1: 'x'})` is {} since v0.25.0); here they are
  // strings.
  function omit<V>(names: seq<string>, obj: map<string, V>): map<string, V>
    requires "hasOwnProperty" !in names || |obj| == 0
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

  // `obj1[p] === obj2[p]` (two missing properties are both undefined: equal;
  // in v0.14.0 `_eq`, `Object.is`, and since v0.15.0 `R.equals`, deep
  // equality: README "Deviations" on `-0`).
  function eqProps<V(==)>(p: string, obj1: map<string, V>, obj2: map<string, V>): bool
  { prop(p, obj1) == prop(p, obj2) }

  // `R.where(spec, testObj)` (v0.14.0, which moved the value entries to
  // `whereEq`): `for (var prop in spec) { if (_has(prop, spec) &&
  // !spec[prop](testObj[prop])) { return false; } } return true;`, every own
  // spec property is a predicate that holds for the test object's property,
  // undefined (None) when the test object lacks it (a JS test object passes
  // an inherited `Object.prototype` member for such a name: `where({toString:
  // x => x === undefined}, {})` is false; a map has none, README
  // "Deviations"). Until v0.13.0 a spec entry
  // was a function, called with the property and the whole test object only
  // when the property was there (since v0.2.3; before, with undefined too),
  // or a value compared with `===`, the removed `Prelude.SpecVal`; since
  // v0.14.0 a value entry throws TypeError ("spec[prop] is not a function"),
  // and a predicate on an absent property is called (`where({a: x => x ===
  // undefined}, {})` is true, was false).
  function where<V>(spec: map<string, Option<V> -> bool>, test: map<string, V>): bool
  { forall k :: k in spec ==> spec[k](prop(k, test)) }

  // `R.whereEq(spec, testObj)` (v0.14.0, `@category Object`):
  // `where(map(equals, spec), testObj)` (since v0.19.0; `mapObj(equals,
  // spec)` from v0.15.0, and with `eq`, `Object.is`, in v0.14.0), every
  // spec property equal to the test object's; an absent test property is
  // undefined, which no spec value here equals. `R.map` over an object
  // (`R.mapObj` until v0.18.0) has no function here (List's mapSeq takes a
  // list, and Object does not import List), so the spec of predicates is
  // written out as a map comprehension, and `R.equals` (Data's, which
  // imports Object) as `==`. A spec property whose value is undefined cannot be
  // written (README "Outside the modeled domain"), and `mapObj`'s copy drops
  // an own `__proto__` spec property in JS (README "Deviations").
  function whereEq<V(==)>(spec: map<string, V>, test: map<string, V>): bool
  { where(map k | k in spec :: (x: Option<V>) => x.Some? && spec[k] == x.value, test) }

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

  // `R.propEq(val, name, obj)` (v0.29.0, a4998cf7 "change propEq/pathEq
  // parameters order": the value first again, as in v0.16.0 alone; from
  // v0.17.0, "revert change to R.propEq argument order", b5f7ba1e, to v0.28.0
  // and before v0.16.0 `propEq(name, val, obj)`):
  // `propSatisfies(equals(val), name, obj)` (v0.16.0 to v0.21.0; since
  // v0.22.0 `equals(val, obj[name])` itself, and since v0.28.0 `equals(val,
  // prop(name, obj))`), obj's property equal to val; an absent
  // property is undefined, which no value here equals. `R.propSatisfies`
  // (Logic) and `R.equals` (Data) are written out, as Object imports
  // neither. (Until v0.15.1 `obj[name] === val`, in v0.14.0 `_eq`,
  // `Object.is`, and in v0.15.x `R.equals`: README "Deviations" on `-0`.)
  function propEq<V(==)>(val: V, name: string, obj: map<string, V>): bool
  { name in obj && obj[name] == val }

  // `R.evolve(transformations, object)` (v0.9.0): since v0.15.0 `for (key in
  // object) { transformation = transformations[key]; result[key] = typeof
  // transformation === 'function' ? transformation(object[key]) : typeof
  // transformation === 'object' ? evolve(transformation, object[key]) :
  // object[key]; }`, a copy of object in which each key that has a
  // transformation is set to it applied to the value (Ramda's test "does not
  // invoke function if object does not contain the key": a transformation
  // for a key the object lacks adds nothing, `evolve({n: add(1)}, {})` is
  // `{}`). From v0.9.0 to v0.14.0 it was `_extend(_extend({}, object),
  // mapObjIndexed((fn, key) => fn(object[key]), transformations))`, which
  // added every key of transformations, calling its function with undefined
  // (None) when object lacked it (`{n: NaN}`). The transformations keep the
  // `Option<V> -> V` type and now always get `Some`. A nested transformation
  // object (Ramda's test "is recursive") and a value that is neither a
  // function nor an object cannot be written (README "Outside the modeled
  // domain"). JS lets a transformation change the value's type, and an own
  // key of object that names an `Object.prototype` member is transformed by
  // that member (README "Deviations").
  function evolve<V>(transformations: map<string, Option<V> -> V>, obj: map<string, V>): map<string, V>
    ensures evolve(transformations, obj).Keys == obj.Keys
  { map k | k in obj :: if k in transformations then transformations[k](prop(k, obj)) else obj[k] }

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

  // `R.lensProp(k)` (v0.14.0, `@category Object`): `lens(prop(k),
  // assoc(k))`, a lens on the property k, since v0.16.0 a van Laarhoven lens
  // (`Prelude.Lens`, List.dfy's `lens`). The getter `prop(k)` is undefined
  // when obj lacks k (and is the inherited member for a name of
  // `Object.prototype`), which the value type cannot hold, so the lens
  // requires the key (README "Outside the modeled domain"); since v0.16.0
  // `set` runs the getter too, so that includes `set_`; the setter, `assoc`,
  // is total. `R.lens` is List's, which Object does not import, so its body
  // is written out (with `Prelude.map_` as its match, as in `lens`).
  function lensProp<V, X>(k: string): Lens<map<string, V>, V, X>
  { var getter := (obj: map<string, V>) requires k in obj => obj[k];
    var setter := (v: V, obj: map<string, V>) => assoc(k, v, obj);
    (f: V --> Functor<X, V>) =>
      (s: map<string, V>) requires getter.requires(s) && f.requires(getter(s)) &&
                                   (f(getter(s)).Identity? ==> setter.requires(f(getter(s)).v, s)) =>
        match f(getter(s))
          case Const(c) => Const(c)
          case Identity(v) => Identity(setter(v, s)) }

  // `R.view(lens, x)` (v0.16.0, `@category Object`): `lens(Const)(x).value`,
  // the lens run with the `Const` functor (private to view.js), which carries
  // the focus out unchanged: the focus of x (`view(lensProp('x'), {x: 1, y:
  // 2})` is 1). It requires the lens's precondition for that function and a
  // `Const` result, as every lens that `lens`, `lensIndex`, `lensProp` and
  // `compose` of them build gives.
  function view<S, V>(l: Lens<S, V, V>, x: S): V
    requires l((v: V) => Const(v)).requires(x) && l((v: V) => Const(v))(x).Const?
  { l((v: V) => Const(v))(x).c }

  // `R.over(lens, f, x)` (v0.16.0, `@category Object`): `lens(function(y) {
  // return Identity(f(y)); })(x).value`, the lens run with the `Identity`
  // functor (private to over.js): x with its focus replaced by f of it
  // (`over(lensProp('x'), negate, {x: 1, y: 2})` is `{x: -1, y: 2}`). JS
  // lets f return a value of another type (README "Deviations").
  function over<S, V, X>(l: Lens<S, V, X>, f: V -> V, x: S): S
    requires l((y: V) => Identity(f(y))).requires(x) && l((y: V) => Identity(f(y)))(x).Identity?
  { l((y: V) => Identity(f(y)))(x).v }

  // `R.set(lens, v, x)` (v0.16.0, `@category Object`): `over(lens, always(v),
  // x)`, x with its focus replaced by v. `set` is a Dafny keyword, hence
  // `set_`, and `R.always` (Functions) is written out as `_ => v`. As over
  // runs the getter before ignoring its result, set_ requires the getter's
  // precondition (`set(lensProp('x'), 9, {})` is `{x: 9}` in node, where the
  // getter gives undefined: README "Outside the modeled domain").
  function set_<S, V, X>(l: Lens<S, V, X>, v: V, x: S): S
    requires over.requires(l, (_: V) => v, x)
  { over(l, (_: V) => v, x) }

  // `R.objOf(key, val)` (v0.18.0, `@category Object`; de2cc7e6 "rename
  // R.createMapEntry", which is now its deprecated alias in List.dfy): `var
  // obj = {}; obj[key] = val; return obj;`, the object with the one
  // property. JS converts the key to a string, and a `__proto__` key sets the
  // prototype instead of a property (README "Deviations").
  function objOf<V>(key: string, val: V): map<string, V> { map[key := val] }

  // `R.mergeWithKey(fn, l, r)` (v0.19.0, `@category Object`): `for (k in l)
  // if (_has(k, l)) result[k] = _has(k, r) ? fn(k, l[k], r[k]) : l[k];`,
  // then `for (k in r) if (_has(k, r) && !_has(k, result)) result[k] =
  // r[k];`: the own properties of both, fn of the key and both values where
  // both have the key (`mergeWithKey((k, l, r) => k + l + r, {a: 'b', x:
  // 'd'}, {a: 'c', y: 'e'})` is `{a: 'abc', x: 'd', y: 'e'}`). The result is
  // built by assignment, so in JS an own `__proto__` property of either is
  // dropped (README "Deviations").
  function mergeWithKey<V>(fn: (string, V, V) -> V, l: map<string, V>, r: map<string, V>): map<string, V>
    ensures mergeWithKey(fn, l, r).Keys == l.Keys + r.Keys
  { map k | k in l.Keys + r.Keys ::
      if k in l && k in r then fn(k, l[k], r[k]) else if k in l then l[k] else r[k] }

  // `R.mergeWith(fn, l, r)` (v0.19.0, `@category Object`):
  // `mergeWithKey(function(_, _l, _r) { return fn(_l, _r); }, l, r)`, fn of
  // both values where both have the key (`mergeWith(concat, {a: [1], b:
  // [2]}, {b: [3], c: [4]})` is `{a: [1], b: [2, 3], c: [4]}`).
  function mergeWith<V>(fn: (V, V) -> V, l: map<string, V>, r: map<string, V>): map<string, V>
    ensures mergeWith(fn, l, r).Keys == l.Keys + r.Keys
  { mergeWithKey((_: string, x: V, y: V) => fn(x, y), l, r) }

  // `R.mergeLeft(l, r)` (v0.26.0, `@category Object`): `_objectAssign({}, r,
  // l)`, the own properties of r, then of l: l's value wins where both have
  // the key (`mergeLeft({a: 1, b: 2}, {b: 3, c: 4})` is `{a: 1, b: 2, c:
  // 4}`). The body is Dafny's right-biased map union, `r + l`. In JS an own
  // `__proto__` property is dropped (README "Deviations").
  function mergeLeft<V>(l: map<string, V>, r: map<string, V>): map<string, V>
  { r + l }

  // `R.mergeRight(l, r)` (v0.26.0, `@category Object`): `_objectAssign({},
  // l, r)`, the code of merge (removed in v0.28.0), r's value winning where
  // both have the key
  // (`mergeRight({a: 1, b: 2}, {b: 3, c: 4})` is `{a: 1, b: 3, c: 4}`): `l +
  // r`.
  function mergeRight<V>(l: map<string, V>, r: map<string, V>): map<string, V>
  { l + r }

  // `R.modify(prop, fn, object)` (v0.28.0, `@category Object`):
  // `modifyPath([prop], fn, object)`, which returns the object itself unless
  // it is an object or an array that owns the property (`_has`), and
  // otherwise a copy with `fn(object[prop])` there (the private `_modify`,
  // `result[prop] = fn(result[prop])` on a `for…in` copy): fn applied to
  // the property (`modify('a', x => x + 1, {a: 1, b: 2})` is `{a: 2, b: 2}`),
  // and the object unchanged when it lacks it. `_has` is written out as `p in
  // obj`. `modify` is a Dafny keyword, hence `modify_`. JS lets fn return a
  // value of another type, and the copy drops an own `__proto__` property
  // (README "Deviations").
  function modify_<V>(p: string, fn: V -> V, obj: map<string, V>): map<string, V>
  { if p in obj then obj[p := fn(obj[p])] else obj }

  // `R.whereAny(spec, testObj)` (v0.28.0, `@category Object`): `for (var prop
  // in spec) { if (_has(prop, spec) && spec[prop](testObj[prop])) { return
  // true; } } return false;`, some own spec property is a predicate that
  // holds for the test object's property, undefined (None) when the test
  // object lacks it, as for where (a JS test object passes an inherited
  // `Object.prototype` member for such a name: README "Deviations").
  function whereAny<V>(spec: map<string, Option<V> -> bool>, test: map<string, V>): bool
  { exists k :: k in spec && spec[k](prop(k, test)) }
}
