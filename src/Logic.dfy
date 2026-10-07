// Ramdaf: Ramda v0.14.0 `src/<fn>.js` for the functions ported up to v0.8.0
// from ramda.js's "Logic Functions" section; from v0.9.0 on, the functions
// with `@category Logic` (`defaultTo`, `both`, `either`, `complement`).
// (v0.8.0 renamed v0.6.0's `cond` to `ifElse`, with the alias `if`, and
// reused the name `cond` for a new function; v0.9.0 renamed `allPredicates`
// and `anyPredicates` to `allPass` and `anyPass` and removed `if`; v0.12.0
// moved the predicate combinators `and`, `or` and `not` to `both`, `either`
// and `complement` and reused the old names for value operators.)

module Ramdaf.Logic {
  import opened Prelude

  export
    reveals and, or, not, both, either, complement, allPass, anyPass, ifElse, cond, defaultTo
    provides Prelude

  // `R.and(a, b)` (v0.12.0): `a && b`. From v0.1.4 to v0.11.0 `and` was the
  // predicate combinator that v0.12.0 renamed `both` (v0.1.0 to v0.1.3 had
  // the operator `!!(a && b)`). JS takes any values and returns the deciding
  // one (`and(1, 0)` is 0); the operands here are bool (README
  // "Deviations"). Since v0.14.0 a first argument with an `and` method is
  // dispatched to (`a.and(b)`, Fantasy-land); a bool has none.
  function and(a: bool, b: bool): bool { a && b }

  // `R.or(a, b)` (v0.12.0): `a || b`, as for and (`either` until v0.11.0;
  // since v0.14.0 an `or` method of the first argument is dispatched to).
  function or(a: bool, b: bool): bool { a || b }

  // `R.not(a)` (v0.12.0): `!a`, as for and (`complement` until v0.11.0).
  function not(a: bool): bool { !a }

  // v0.1.4 renamed `andFn`, `orFn` and `notFn` to `and`, `or` and `not`, and
  // v0.12.0 renamed those to `both`, `either` and `complement`, with the same
  // code. JS forwards any number of arguments to the predicates; the port's
  // predicates are unary (tuple the arguments for more).

  // `R.both(f, g)` (v0.12.0, `and` until v0.11.0): `f(...) && g(...)`,
  // short-circuited (v0.7.0; before, `!!(...)`). JS returns the deciding
  // operand, not a boolean; with boolean predicates that is the same bool
  // (README "Deviations").
  function both<T>(f: T -> bool, g: T -> bool): T -> bool { x => f(x) && g(x) }

  // `R.either(f, g)` (v0.12.0, `or` until v0.11.0): `f(...) || g(...)`,
  // short-circuited, as for both.
  function either<T>(f: T -> bool, g: T -> bool): T -> bool { x => f(x) || g(x) }

  // `R.complement(f)` (v0.12.0, `not` until v0.11.0): `!f(...)`.
  function complement<T>(f: T -> bool): T -> bool { x => !f(x) }

  // `R.allPass = _predicateWrap(_all)` (v0.9.0, which renamed
  // `allPredicates`): `allPass(preds)` is a predicate true exactly when every
  // predicate holds; the JS form that also takes the values
  // (`allPass(preds, v)`) is the application `allPass(preds)(v)`. Since
  // v0.9.0 JS `allPass([])` throws, as the result's arity is the longest
  // predicate's, while `allPass([], v)` is true, as here (README
  // "Deviations").
  function allPass<T>(preds: seq<T -> bool>): T -> bool
  { x => forall i :: 0 <= i < |preds| ==> preds[i](x) }

  // `R.anyPass = _predicateWrap(_any)` (v0.9.0, which renamed
  // `anyPredicates`): true exactly when some predicate holds (`anyPass([])`
  // throws in JS, `anyPass([], v)` is false).
  function anyPass<T>(preds: seq<T -> bool>): T -> bool
  { x => exists i :: 0 <= i < |preds| && preds[i](x) }

  // `R.ifElse(condition, onTrue, onFalse)` (v0.8.0, which renamed v0.6.0's
  // `cond` to `ifElse` with the same code): a function that applies onTrue
  // to its arguments when condition holds for them (truthy), and onFalse
  // otherwise; only the chosen branch is called. JS forwards any number of
  // arguments; the port's result is unary (tuple the arguments for more).
  function ifElse<A, B>(condition: A -> bool, onTrue: A -> B, onFalse: A -> B): A -> B
  { x => if condition(x) then onTrue(x) else onFalse(x) }

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

  // `R.defaultTo(d, v)` (v0.10.0, `@category Logic`): `v == null ? d : v`,
  // the value unless it is null or undefined, then the default. The port's
  // None stands for both (an absent property, a "no value" result), so the
  // value is an Option; JS lets the default and the value differ in type
  // (README "Deviations", with `isNil`).
  function defaultTo<T>(d: T, v: Option<T>): T
  { match v
      case Some(x) => x
      case None => d }
}
