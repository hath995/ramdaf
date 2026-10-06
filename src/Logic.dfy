// Ramdaf: Ramda v0.1.1 "Logic Functions" (ramda.js lines 1146-1227).
// JS coerces operands by truthiness; the port's operands are bool (see README).

module Ramdaf.Logic {
  export
    reveals and, or, not, andFn, orFn, notFn, allPredicates, anyPredicates

  // `!!(a && b)`
  function and(a: bool, b: bool): bool { a && b }

  // `!!(a || b)`
  function or(a: bool, b: bool): bool { a || b }

  // `!a`
  function not(a: bool): bool { !a }

  // JS andFn/orFn/notFn forward any number of arguments; the port's predicates
  // are unary (tuple the arguments for more).
  function andFn<T>(f: T -> bool, g: T -> bool): T -> bool { x => f(x) && g(x) }

  function orFn<T>(f: T -> bool, g: T -> bool): T -> bool { x => f(x) || g(x) }

  function notFn<T>(f: T -> bool): T -> bool { x => !f(x) }

  // `allPredicates(preds)` is a predicate true exactly when every predicate
  // holds; the JS form that also takes the values (`allPredicates(preds, v)`)
  // is the application `allPredicates(preds)(v)`.
  function allPredicates<T>(preds: seq<T -> bool>): T -> bool
  { x => forall i :: 0 <= i < |preds| ==> preds[i](x) }

  function anyPredicates<T>(preds: seq<T -> bool>): T -> bool
  { x => exists i :: 0 <= i < |preds| && preds[i](x) }
}
