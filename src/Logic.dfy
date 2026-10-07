// Ramdaf: Ramda v0.6.0 "Logic Functions" (ramda.js lines 4072-4253).

module Ramdaf.Logic {
  export
    reveals and, or, not, allPredicates, anyPredicates, cond

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

  // `R.cond(condition, onTrue, onFalse)` (v0.6.0): a function that applies
  // onTrue to its arguments when condition holds for them (truthy), and
  // onFalse otherwise; only the chosen branch is called. JS forwards any
  // number of arguments; the port's result is unary (tuple the arguments for
  // more).
  function cond<A, B>(condition: A -> bool, onTrue: A -> B, onFalse: A -> B): A -> B
  { x => if condition(x) then onTrue(x) else onFalse(x) }
}
