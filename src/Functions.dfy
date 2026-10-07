// Ramdaf: Ramda v0.18.0 `src/<fn>.js` for the functions ported up to v0.8.0
// from ramda.js's "Function functions" section, `flip` (an internal function
// in v0.8.0) and the `always` family (`always`, `T`, `F`); from v0.9.0 on,
// the functions with `@category Function` (`composeK`, `pipeK`). (v0.4.1
// removed the aliases `sequence`, `distributeTo`, `constant` and `K`;
// v0.4.2 renamed `fork` to `converge`; v0.9.0 renamed `alwaysTrue` and
// `alwaysFalse` to `T` and `F` and removed `alwaysZero`; v0.16.0 removed
// v0.14.0's `composeL` and `pipeL`, as lenses compose with `compose`.)
// compose/pipe (and composeK/pipeK) are variadic in JS; the port is binary
// (nest for more functions). composeK and pipeK chain with `List.chain`, so
// Functions imports List (v0.16.0).

module Ramdaf.Functions {
  import List

  export
    reveals compose, pipe, flip, converge, always, T, F, composeK, pipeK
    provides List

  // `compose(f, g)(x) == f(g(x))`
  // (v0.1.1 dropped the `fog` alias. From v0.3.0 to v0.10.0 JS `compose(f)`
  // returned f itself, and since v0.11.0 a wrapper with f's arity and
  // results; `compose()` throws; with two or more functions only the result's
  // reported arity changed. Since v0.16.0 it is `pipe` of the reversed
  // functions, and it composes van Laarhoven lenses (`Prelude.Lens`):
  // `compose(lensProp('a'), lensIndex(0))` focuses the head of the property
  // a.)
  function compose<A, B, C>(f: B -> C, g: A -> B): A -> C { x => f(g(x)) }

  // `pipe(f, g)(x) == g(f(x))` (from v0.4.0 to v0.10.0 JS `pipe(f)` was f
  // itself, as `compose(f)` was, and since v0.11.0 it is a wrapper with f's
  // results; since v0.16.0 `curryN(fns[0].length, reduce(_pipe, …))`, and
  // since v0.18.0 `_arity(…)`, whose result is not curried)
  function pipe<A, B, C>(f: A -> B, g: B -> C): A -> C { x => g(f(x)) }

  // `flip(fn)(a, b) == fn(b, a)`
  function flip<A, B, C>(fn: (A, B) -> C): (B, A) -> C { (b, a) => fn(a, b) }

  // `converge(after, [f1, ..., fn])(...args) == after(f1(...args), ..., fn(...args))`
  // (v0.18.0, 360d5904 "make converge a binary function": `_curry2(function
  // converge(after, fns))`, the branching functions one list, and the result
  // curried to the longest function's arity, `curryN(Math.max.apply(Math,
  // pluck('length', fns)), …)`, which passes its `this` on; `converge(after,
  // [])` throws, as the arity is -Infinity). Until v0.17.1 the functions
  // were separate arguments, `converge(after, f1, f2)`: v0.4.2 renamed
  // `fork`, added in v0.1.2, to `converge` with the same code, v0.1.4 had
  // moved `after` first and allowed any number of functions (v0.4.2's
  // documentation named three), v0.11.0 made it `curryN(3, …)`, so
  // `converge(after, f)` waited for another function, and v0.14.0 curried
  // its result to the longest function's arity. The list is a pair here
  // (README "JS -> Dafny mapping"), so the port takes exactly two
  // functions, and its result is unary (tuple the arguments for more).
  function converge<A, B, C, D>(after: (B, C) -> D, fns: (A -> B, A -> C)): A -> D
  { x => after(fns.0(x), fns.1(x)) }

  // JS `always(v)` ignores however many arguments it gets; the port's result
  // takes one argument of any type.
  function always<T, U>(val: T): U -> T { _ => val }

  // `R.T = always(true)` and `R.F = always(false)` (v0.9.0, which renamed
  // `alwaysTrue` and `alwaysFalse` with the same code; `alwaysZero`, removed
  // in v0.9.0, was `always(0)`): the functions themselves, applied to one
  // argument of any type.
  function T<U>(x: U): bool { always(true)(x) }
  function F<U>(x: U): bool { always(false)(x) }

  // `R.composeK(…fns)` (v0.16.0, `@category Function`): since v0.18.0
  // `compose.apply(this, prepend(identity, map(chain, arguments)))` (v0.16.0
  // `compose.apply(this, map(chain, arguments))`, and `identity` for no
  // functions; the same results), right-to-left Kleisli composition: each
  // function is `chain`ed over the monadic value the one to its right
  // returns (`composeK(f, g)(m)` is `chain(f, chain(g, m))`; `composeK()` is
  // `identity`). JS chains any Fantasy-land monad through its `chain`
  // method; here the monad is the list, through `List.chain` (README
  // "Deviations"). JS takes any number of functions; the port is binary, as
  // compose is.
  function composeK<A, B, C>(f: B -> seq<C>, g: A -> seq<B>): seq<A> -> seq<C>
  { compose((xs: seq<B>) => List.chain(f, xs), (xs: seq<A>) => List.chain(g, xs)) }

  // `R.pipeK(…fns)` (v0.16.0): `composeK.apply(this, reverse(arguments))`,
  // left-to-right Kleisli composition (`pipeK(f, g)` is `composeK(g, f)`).
  function pipeK<A, B, C>(f: A -> seq<B>, g: B -> seq<C>): seq<A> -> seq<C>
  { composeK(g, f) }
}
