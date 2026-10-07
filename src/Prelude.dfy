// Ramdaf: a Dafny port of Ramda v0.23.0 (2016-12-29).
// Support datatypes shared by the area modules. These are not Ramda exports;
// they are the encodings the README's "JS -> Dafny mapping" names.

module Ramdaf.Prelude {
  export
    reveals Option, Tree, Functor, map_, Lens

  // A Ramda result that is a documented "no value" sentinel instead of an
  // element (`find` miss -> undefined, a missing property -> undefined,
  // `maxBy([])` -> undefined until v0.16.0 made maxBy binary, `nth` out of
  // range -> undefined (until v0.4.1 removed it, and again since v0.8.0; on
  // a string '' since v0.16.0), and since v0.8.0 `cond` when no predicate
  // matches -> undefined) becomes None. (Since v0.9.0 `isNil`, in
  // Core, tests an Option for None, and since v0.10.0 `defaultTo`, in Logic,
  // replaces None with a default: README "Deviations".)
  datatype Option<T> = None | Some(value: T)

  // JS nested heterogeneous arrays (the input of `flatten` and `unnest`)
  // become a rose tree: a nested array is a Node, any other element a Leaf.
  // (Since v0.3.0 Ramda also flattens an array-like element, such as an
  // object with a numeric `length`; a Leaf is never flattened, README
  // "Deviations".)
  datatype Tree<T> = Leaf(value: T) | Node(children: seq<Tree<T>>)

  // The functors a lens is run with (v0.16.0, "composable lenses"): Ramda's
  // `view` runs a lens with `Const` (`{value: x, map: function() { return
  // this; }}`, private to view.js) and `over` with `Identity` (`{value: x,
  // map: function(f) { return Identity(f(x)); }}`, private to over.js); a
  // lens maps its setter over whichever functor its function returns, with
  // `R.map`, which dispatches to the functor's own `map`. Here one datatype
  // holds both: `Const(c)` carries the viewed value and ignores the
  // function, `Identity(v)` carries the value being rebuilt. (From v0.8.0 to
  // v0.15.1 a lens was a function with the properties `set` and `map`, the
  // record `Lens(get, set_, map_)` here, and v0.11.0's `lensOn` returned a
  // bound lens, the record `LensOn(get, set_, map_)`, which v0.16.0 removed
  // with `lensOn`. `where`'s spec values were the datatype `SpecVal` from
  // v0.1.1 until v0.14.0.)
  datatype Functor<X, T> = Const(c: X) | Identity(v: T)

  // The functor's `map`: `Const` returns itself, `Identity` applies f
  // (`map` is a Dafny keyword, so `map_`). f may be partial, as a lens's
  // setter may be, and must hold for an `Identity`'s value.
  function map_<X, A, B>(f: A --> B, fa: Functor<X, A>): Functor<X, B>
    requires fa.Identity? ==> f.requires(fa.v)
  { match fa
      case Const(c) => Const(c)
      case Identity(v) => Identity(f(v)) }

  // A lens (v0.16.0): `@typedef Lens s a = Functor f => (a -> f a) -> s -> f
  // s`, a van Laarhoven lens, which takes a function from the focus to a
  // functor and returns a function from the whole to the functor; `view`,
  // `set` and `over` (Object.dfy) run it, and lenses compose with `compose`
  // (Functions.dfy). Dafny has no type quantified over functors, so the
  // functor is `Functor`, and X is the type a `Const` carries (`view` takes
  // a lens with X the focus type V). The arrows from values are partial, as
  // a getter that is undefined or throws on part of its domain gives the
  // lens a precondition there (README "JS -> Dafny mapping").
  type Lens<!S, !V, !X> = (V --> Functor<X, V>) -> (S --> Functor<X, S>)
}
