// Ramdaf: Ramda v0.1.0 "Function functions" (ramda.js lines 384-488) and the
// `always` family (lines 902-905, 985-992).
// compose/pipe are variadic in JS; the port is binary (nest for more functions).

module Ramdaf.Functions {
  export
    reveals compose, fog, pipe, sequence, flip,
            always, alwaysZero, alwaysFalse, alwaysTrue

  // `compose(f, g)(x) == f(g(x))`
  function compose<A, B, C>(f: B -> C, g: A -> B): A -> C { x => f(g(x)) }
  function fog<A, B, C>(f: B -> C, g: A -> B): A -> C { compose(f, g) }

  // `pipe(f, g)(x) == g(f(x))`
  function pipe<A, B, C>(f: A -> B, g: B -> C): A -> C { x => g(f(x)) }
  function sequence<A, B, C>(f: A -> B, g: B -> C): A -> C { pipe(f, g) }

  // `flip(fn)(a, b) == fn(b, a)`
  function flip<A, B, C>(fn: (A, B) -> C): (B, A) -> C { (b, a) => fn(a, b) }

  // JS `always(v)` ignores however many arguments it gets; the port's result
  // takes one argument of any type.
  function always<T, U>(val: T): U -> T { _ => val }

  // `alwaysZero = always(0)` etc.: the functions themselves, applied to one
  // argument of any type.
  function alwaysZero<U>(x: U): int { always(0)(x) }
  function alwaysFalse<U>(x: U): bool { always(false)(x) }
  function alwaysTrue<U>(x: U): bool { always(true)(x) }
}
