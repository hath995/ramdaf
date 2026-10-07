// Ramdaf: Ramda v0.9.1 `src/<fn>.js` for the functions ported up to v0.8.0
// from ramda.js's "Function functions" section, `flip` (an internal function
// in v0.8.0) and the `always` family (`always`, `T`, `F`); from v0.9.0 on,
// the functions with `@category Function`. (v0.4.1 removed the aliases
// `sequence`, `distributeTo`, `constant` and `K`; v0.4.2 renamed `fork` to
// `converge`; v0.9.0 renamed `alwaysTrue` and `alwaysFalse` to `T` and `F`
// and removed `alwaysZero`.)
// compose/pipe are variadic in JS; the port is binary (nest for more functions).

module Ramdaf.Functions {
  export
    reveals compose, pipe, flip, converge, always, T, F

  // `compose(f, g)(x) == f(g(x))`
  // (v0.1.1 dropped the `fog` alias. Since v0.3.0 JS `compose(f)` returns f
  // itself and `compose()` throws; with two or more functions only the
  // result's reported arity changed.)
  function compose<A, B, C>(f: B -> C, g: A -> B): A -> C { x => f(g(x)) }

  // `pipe(f, g)(x) == g(f(x))` (since v0.4.0 JS `pipe(f)` is f itself, as
  // `compose(f)` is)
  function pipe<A, B, C>(f: A -> B, g: B -> C): A -> C { x => g(f(x)) }

  // `flip(fn)(a, b) == fn(b, a)`
  function flip<A, B, C>(fn: (A, B) -> C): (B, A) -> C { (b, a) => fn(a, b) }

  // `converge(after, f1, ..., fn)(...args) == after(f1(...args), ..., fn(...args))`
  // (v0.4.2 renamed `fork`, added in v0.1.2, to `converge` with the same
  // code; v0.1.4 had moved `after` first and allowed any number of
  // functions, though v0.4.2's documentation names three). The port takes
  // exactly two functions, and its result is unary (tuple the arguments for
  // more).
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
}
