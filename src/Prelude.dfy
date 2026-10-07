// Ramdaf: a Dafny port of Ramda v0.8.0 (2014-11-19).
// Support datatypes shared by the area modules. These are not Ramda exports;
// they are the encodings the README's "JS -> Dafny mapping" names.

module Ramdaf.Prelude {
  export
    reveals Option, Tree, SpecVal, Lens

  // A Ramda result that is a documented "no value" sentinel instead of an
  // element (`find` miss -> undefined, a missing property -> undefined,
  // `maxBy([])` -> undefined, `nth` out of range -> undefined (until v0.4.1
  // removed it, and again since v0.8.0), and since v0.8.0 `cond` when no
  // predicate matches -> undefined) becomes None.
  datatype Option<T> = None | Some(value: T)

  // JS nested heterogeneous arrays (the input of `flatten` and `unnest`)
  // become a rose tree: a nested array is a Node, any other element a Leaf.
  // (Since v0.3.0 Ramda also flattens an array-like element, such as an
  // object with a numeric `length`; a Leaf is never flattened, README
  // "Deviations".)
  datatype Tree<T> = Leaf(value: T) | Node(children: seq<Tree<T>>)

  // A value of `where`'s spec object: a function, called with the test
  // object's property and the whole test object, or any other value, compared
  // with `===`. (Up to v0.2.2 the function was also called for an absent
  // property, with None, i.e. JS undefined; since v0.2.3 it is not.)
  datatype SpecVal<!V> = Pred(fn: (Option<V>, map<string, V>) -> bool) | Val(v: V)

  // The result of `R.lens(get, set)` (v0.8.0): JS returns the function
  // `lns(a) = get(a)` carrying two properties, `lns.set = set` and
  // `lns.map(fn, a) = set(fn(get(a)), a)`. A Dafny function value has no
  // properties, so the lens is a record of the three: `l.get(a)` for the
  // call `l(a)`, `l.set_(v, a)` and `l.map_(fn, a)` (`set` and `map` are
  // Dafny keywords). The fields are partial arrows (`-->`): a JS getter or
  // setter may throw or return undefined on part of its domain, which the
  // port states as a precondition, and only a partial arrow can carry one.
  // `lens` (List.dfy) builds map_ from get and set_, requiring both.
  datatype Lens<!A, !V> = Lens(get: A --> V, set_: (V, A) --> A, map_: (V -> V, A) --> A)
}
