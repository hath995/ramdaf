// Ramdaf: Ramda v0.2.2 "Logic Functions" (ramda.js lines 1429-1485).

module Ramdaf.Logic {
  export
    reveals and, or, not, allPredicates, anyPredicates

  // v0.1.4 deleted the boolean operators `and`, `or` and `not` and renamed
  // `andFn`, `orFn` and `notFn` to those names. JS forwards any number of
  // arguments to the predicates; the port's predicates are unary (tuple the
  // arguments for more).

  // `!!(f(...) && g(...))`, short-circuited.
  function and<T>(f: T -> bool, g: T -> bool): T -> bool { x => f(x) && g(x) }

  // `!!(f(...) || g(...))`, short-circuited.
  function or<T>(f: T -> bool, g: T -> bool): T -> bool { x => f(x) || g(x) }

  // `!f(...)`
  function not<T>(f: T -> bool): T -> bool { x => !f(x) }

  // `allPredicates(preds)` is a predicate true exactly when every predicate
  // holds; the JS form that also takes the values (`allPredicates(preds, v)`)
  // is the application `allPredicates(preds)(v)`.
  function allPredicates<T>(preds: seq<T -> bool>): T -> bool
  { x => forall i :: 0 <= i < |preds| ==> preds[i](x) }

  function anyPredicates<T>(preds: seq<T -> bool>): T -> bool
  { x => exists i :: 0 <= i < |preds| && preds[i](x) }
}
