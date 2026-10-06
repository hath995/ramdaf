// Ramdaf: Ramda v0.1.2 "Function functions" (ramda.js lines 416-524) and the
// `always` family (lines 1038-1041, 1155-1162).
// compose/pipe are variadic in JS; the port is binary (nest for more functions).

module Ramdaf.Functions {
  export
    reveals compose, pipe, sequence, flip, fork,
            always, alwaysZero, alwaysFalse, alwaysTrue

  // `compose(f, g)(x) == f(g(x))`
  // (v0.1.1 dropped the `fog` alias.)
  function compose<A, B, C>(f: B -> C, g: A -> B): A -> C { x => f(g(x)) }

  // `pipe(f, g)(x) == g(f(x))`
  function pipe<A, B, C>(f: A -> B, g: B -> C): A -> C { x => g(f(x)) }
  function sequence<A, B, C>(f: A -> B, g: B -> C): A -> C { pipe(f, g) }

  // `flip(fn)(a, b) == fn(b, a)`
  function flip<A, B, C>(fn: (A, B) -> C): (B, A) -> C { (b, a) => fn(a, b) }

  // `fork(f1, f2, after)(...args) == after(f1(...args), f2(...args))`. JS
  // passes along however many arguments the result gets; the port's result
  // is unary (tuple the arguments for more).
  function fork<A, B, C, D>(f1: A -> B, f2: A -> C, after: (B, C) -> D): A -> D
  { x => after(f1(x), f2(x)) }

  // JS `always(v)` ignores however many arguments it gets; the port's result
  // takes one argument of any type.
  function always<T, U>(val: T): U -> T { _ => val }

  // `alwaysZero = always(0)` etc.: the functions themselves, applied to one
  // argument of any type.
  function alwaysZero<U>(x: U): int { always(0)(x) }
  function alwaysFalse<U>(x: U): bool { always(false)(x) }
  function alwaysTrue<U>(x: U): bool { always(true)(x) }
}
