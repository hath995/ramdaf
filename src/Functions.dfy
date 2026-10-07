// Ramdaf: Ramda v0.3.0 "Function functions" (ramda.js lines 968-1367) and the
// `always` family (lines 2901-2906, 3182-3194).
// compose/pipe are variadic in JS; the port is binary (nest for more functions).

module Ramdaf.Functions {
  export
    reveals compose, pipe, sequence, flip, fork, distributeTo,
            always, constant, K, alwaysZero, alwaysFalse, alwaysTrue

  // `compose(f, g)(x) == f(g(x))`
  // (v0.1.1 dropped the `fog` alias. Since v0.3.0 JS `compose(f)` returns f
  // itself and `compose()` throws; with two or more functions only the
  // result's reported arity changed.)
  function compose<A, B, C>(f: B -> C, g: A -> B): A -> C { x => f(g(x)) }

  // `pipe(f, g)(x) == g(f(x))`
  function pipe<A, B, C>(f: A -> B, g: B -> C): A -> C { x => g(f(x)) }
  function sequence<A, B, C>(f: A -> B, g: B -> C): A -> C { pipe(f, g) }

  // `flip(fn)(a, b) == fn(b, a)`
  function flip<A, B, C>(fn: (A, B) -> C): (B, A) -> C { (b, a) => fn(a, b) }

  // `fork(after, f1, ..., fn)(...args) == after(f1(...args), ..., fn(...args))`
  // (v0.1.4 moved `after` first and allowed any number of functions). The
  // port takes exactly two functions, and its result is unary (tuple the
  // arguments for more).
  function fork<A, B, C, D>(after: (B, C) -> D, f1: A -> B, f2: A -> C): A -> D
  { x => after(f1(x), f2(x)) }
  // v0.3.0: `aliasFor('fork').is('distributeTo')`.
  function distributeTo<A, B, C, D>(after: (B, C) -> D, f1: A -> B, f2: A -> C): A -> D
  { fork(after, f1, f2) }

  // JS `always(v)` ignores however many arguments it gets; the port's result
  // takes one argument of any type.
  function always<T, U>(val: T): U -> T { _ => val }
  // v0.2.0: `aliasFor("always").is("constant")`.
  function constant<T, U>(val: T): U -> T { always(val) }
  // v0.3.0: `aliasFor("always").is("constant").and("K")`. (Until v0.2.4 `K`
  // was an alias of `tap`, which is not portable.)
  function K<T, U>(val: T): U -> T { always(val) }

  // `alwaysZero = always(0)` etc.: the functions themselves, applied to one
  // argument of any type.
  function alwaysZero<U>(x: U): int { always(0)(x) }
  function alwaysFalse<U>(x: U): bool { always(false)(x) }
  function alwaysTrue<U>(x: U): bool { always(true)(x) }
}
