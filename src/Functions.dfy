// Ramdaf: Ramda v0.15.1 `src/<fn>.js` for the functions ported up to v0.8.0
// from ramda.js's "Function functions" section, `flip` (an internal function
// in v0.8.0) and the `always` family (`always`, `T`, `F`); from v0.9.0 on,
// the functions with `@category Function` (`composeL`, `pipeL`). (v0.4.1 removed the aliases
// `sequence`, `distributeTo`, `constant` and `K`; v0.4.2 renamed `fork` to
// `converge`; v0.9.0 renamed `alwaysTrue` and `alwaysFalse` to `T` and `F`
// and removed `alwaysZero`.)
// compose/pipe (and composeL/pipeL) are variadic in JS; the port is binary
// (nest for more functions).

module Ramdaf.Functions {
  import opened Prelude

  export
    reveals compose, pipe, flip, converge, always, T, F, composeL, pipeL
    provides Prelude

  // `compose(f, g)(x) == f(g(x))`
  // (v0.1.1 dropped the `fog` alias. From v0.3.0 to v0.10.0 JS `compose(f)`
  // returned f itself, and since v0.11.0 a wrapper with f's arity and
  // results; `compose()` throws; with two or more functions only the result's
  // reported arity changed.)
  function compose<A, B, C>(f: B -> C, g: A -> B): A -> C { x => f(g(x)) }

  // `pipe(f, g)(x) == g(f(x))` (from v0.4.0 to v0.10.0 JS `pipe(f)` was f
  // itself, as `compose(f)` was, and since v0.11.0 it is a wrapper with f's
  // results)
  function pipe<A, B, C>(f: A -> B, g: B -> C): A -> C { x => g(f(x)) }

  // `flip(fn)(a, b) == fn(b, a)`
  function flip<A, B, C>(fn: (A, B) -> C): (B, A) -> C { (b, a) => fn(a, b) }

  // `converge(after, f1, ..., fn)(...args) == after(f1(...args), ..., fn(...args))`
  // (v0.4.2 renamed `fork`, added in v0.1.2, to `converge` with the same
  // code; v0.1.4 had moved `after` first and allowed any number of
  // functions, though v0.4.2's documentation names three; since v0.11.0 it
  // is `curryN(3, …)`, so `converge(after, f)` waits for another function,
  // and since v0.14.0 its result is curried to the longest function's arity,
  // `curryN(max(pluck('length', fns)), …)`, and passes its `this` on).
  // The port takes exactly two functions, and its result is unary (tuple the
  // arguments for more).
  function converge<A, B, C, D>(after: (B, C) -> D, f1: A -> B, f2: A -> C): A -> D
  { x => after(f1(x), f2(x)) }

  // JS `always(v)` ignores however many arguments it gets; the port's result
  // takes one argument of any type.
  function always<T, U>(val: T): U -> T { _ => val }

  // `R.T = always(true)` and `R.F = always(false)` (v0.9.0, which renamed
  // `alwaysTrue` and `alwaysFalse` with the same code; `alwaysZero`, removed
  // in v0.9.0, was `always(0)`): the functions themselves, applied to one
  // argument of any type.
  function T<U>(x: U): bool { always(true)(x) }
  function F<U>(x: U): bool { always(false)(x) }

  // `R.composeL(l1, …, ln)` (v0.14.0, `@category Function`): the lenses
  // composed right to left with `_composeL(innerLens, outerLens) =
  // lens(_compose(innerLens, outerLens), function(x, source) { var
  // newInnerValue = innerLens.set(x, outerLens(source)); return
  // outerLens.set(newInnerValue, source); })`: the get is the inner get of
  // the outer get, and the set sets the inner part of the outer value and
  // puts it back. JS takes any number of lenses (`composeL(l)` is l itself,
  // `composeL()` undefined); the port is binary, `composeL(l1,
  // composeL(l2, l3))` for three (README "Deviations"). The arrows are
  // partial, and the composed ones require what their parts do: get the
  // outer get's and then the inner get's preconditions, set the outer
  // get's and both setters' (README "Outside the modeled domain"). `R.lens`
  // is List's, which Functions does not import, so its body is written out:
  // map_ is set_ of fn applied to get, requiring both.
  function composeL<A, B, C>(inner: Lens<B, C>, outer: Lens<A, B>): Lens<A, C>
  { var get := (a: A) requires outer.get.requires(a) && inner.get.requires(outer.get(a)) =>
                  inner.get(outer.get(a));
    var set_ := (x: C, source: A)
                  requires outer.get.requires(source) && inner.set_.requires(x, outer.get(source)) &&
                           outer.set_.requires(inner.set_(x, outer.get(source)), source) =>
                  outer.set_(inner.set_(x, outer.get(source)), source);
    Lens(get, set_, (fn: C -> C, a: A) requires get.requires(a) && set_.requires(fn(get(a)), a) =>
                      set_(fn(get(a)), a)) }

  // `R.pipeL = compose(apply(composeL), unapply(reverse))` (v0.14.0):
  // composeL of the lenses in reverse order, so they compose left to right
  // (`pipeL(l1, l2)` is `composeL(l2, l1)`); binary, as composeL.
  function pipeL<A, B, C>(outer: Lens<A, B>, inner: Lens<B, C>): Lens<A, C>
  { composeL(inner, outer) }
}
