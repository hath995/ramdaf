// Ramdaf: a Dafny port of Ramda v0.15.1 (2015-06-21).
// Support datatypes shared by the area modules. These are not Ramda exports;
// they are the encodings the README's "JS -> Dafny mapping" names.

module Ramdaf.Prelude {
  export
    reveals Option, Tree, Lens, LensOn

  // A Ramda result that is a documented "no value" sentinel instead of an
  // element (`find` miss -> undefined, a missing property -> undefined,
  // `maxBy([])` -> undefined, `nth` out of range -> undefined (until v0.4.1
  // removed it, and again since v0.8.0), and since v0.8.0 `cond` when no
  // predicate matches -> undefined) becomes None. (Since v0.9.0 `isNil`, in
  // Core, tests an Option for None, and since v0.10.0 `defaultTo`, in Logic,
  // replaces None with a default: README "Deviations".)
  datatype Option<T> = None | Some(value: T)

  // JS nested heterogeneous arrays (the input of `flatten` and `unnest`)
  // become a rose tree: a nested array is a Node, any other element a Leaf.
  // (Since v0.3.0 Ramda also flattens an array-like element, such as an
  // object with a numeric `length`; a Leaf is never flattened, README
  // "Deviations".)
  datatype Tree<T> = Leaf(value: T) | Node(children: seq<Tree<T>>)

  // The result of `R.lens(get, set)` (v0.8.0): JS returns the function
  // `lns(a) = get(a)` carrying two properties, `lns.set = set` and
  // `lns.map(fn, a) = set(fn(get(a)), a)`. A Dafny function value has no
  // properties, so the lens is a record of the three: `l.get(a)` for the
  // call `l(a)`, `l.set_(v, a)` and `l.map_(fn, a)` (`set` and `map` are
  // Dafny keywords). The fields are partial arrows (`-->`): a JS getter or
  // setter may throw or return undefined on part of its domain, which the
  // port states as a precondition, and only a partial arrow can carry one.
  // `lens` (List.dfy) builds map_ from get and set_, requiring both, and so
  // do `lensIndex` (List.dfy), `lensProp` (Object.dfy), `composeL` and
  // `pipeL` (Functions.dfy), v0.14.0. (`where`'s spec values were the
  // datatype `SpecVal`, `Pred(fn)` or `Val(v)`, from v0.1.1 until v0.14.0
  // made every spec value a predicate and removed it.)
  datatype Lens<!A, !V> = Lens(get: A --> V, set_: (V, A) --> A, map_: (V -> V, A) --> A)

  // The result of `R.lensOn(get, set, obj)` (v0.11.0), a lens bound to obj:
  // JS returns the function `lns() = get(obj)`, which ignores its arguments,
  // carrying two properties, `lns.set = set` (the given function itself) and
  // `lns.map(fn) = set(fn(get(obj)))`. As for Lens, it is a record of the
  // three: `l.get()` for the call `l()`, `l.set_(v)` for `l.set(v)` and
  // `l.map_(fn)` for `l.map(fn)`; set may return a value of any type B.
  // The fields are partial arrows, as Lens's are. `lensOn` (Object.dfy)
  // builds it, map_ requiring get's and then set_'s preconditions.
  datatype LensOn<!V, B> = LensOn(get: () --> V, set_: V --> B, map_: (V -> V) --> B)
}
