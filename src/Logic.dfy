// Ramdaf: Ramda v0.8.0 "Logic Functions" (ramda.js lines 4741-4972).
// (v0.8.0 renamed v0.6.0's `cond` to `ifElse`, with the alias `if`, and
// reused the name `cond` for a new function.)

module Ramdaf.Logic {
  import opened Prelude

  export
    reveals and, or, not, allPredicates, anyPredicates, ifElse, if_, cond
    provides Prelude

  // v0.1.4 deleted the boolean operators `and`, `or` and `not` and renamed
  // `andFn`, `orFn` and `notFn` to those names. JS forwards any number of
  // arguments to the predicates; the port's predicates are unary (tuple the
  // arguments for more).

  // `f(...) && g(...)`, short-circuited (v0.7.0; before, `!!(...)`). JS now
  // returns the deciding operand, not a boolean; with boolean predicates
  // that is the same bool (README "Deviations").
  function and<T>(f: T -> bool, g: T -> bool): T -> bool { x => f(x) && g(x) }

  // `f(...) || g(...)`, short-circuited (v0.7.0; before, `!!(...)`), as for
  // and.
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

  // `R.ifElse(condition, onTrue, onFalse)` (v0.8.0, which renamed v0.6.0's
  // `cond` to `ifElse` with the same code): a function that applies onTrue
  // to its arguments when condition holds for them (truthy), and onFalse
  // otherwise; only the chosen branch is called. JS forwards any number of
  // arguments; the port's result is unary (tuple the arguments for more).
  function ifElse<A, B>(condition: A -> bool, onTrue: A -> B, onFalse: A -> B): A -> B
  { x => if condition(x) then onTrue(x) else onFalse(x) }

  // `R['if'] = ifElse` (v0.8.0). `if` is a Dafny keyword, so the alias is
  // `if_`.
  function if_<A, B>(condition: A -> bool, onTrue: A -> B, onFalse: A -> B): A -> B
  { ifElse(condition, onTrue, onFalse) }

  // `R.cond([pred, transform], ...)` (v0.8.0; the name held today's `ifElse`
  // from v0.6.0 to v0.7.2): a function that tests its arguments against each
  // pair's predicate in turn and returns the first truthy one's transformer
  // applied to them; later predicates are not called, and when none matches
  // the result is undefined (documented), here None. JS takes the pairs as
  // separate arguments and forwards any number of arguments; here the pairs
  // are one seq and the result is unary (README "Deviations").
  function cond<A, B>(pairs: seq<(A -> bool, A -> B)>): A -> Option<B>
  { x => if |pairs| == 0 then None
         else if pairs[0].0(x) then Some(pairs[0].1(x))
         else cond(pairs[1..])(x) }
}
