// Ramdaf: Ramda v0.22.0 `src/<fn>.js` for the functions ported up to v0.8.0
// from ramda.js's "Logic Functions" section; from v0.9.0 on, the functions
// with `@category Logic` (`defaultTo`, `both`, `either`, `complement`,
// `propSatisfies`, `when`, `unless`, `until`).
// (v0.8.0 renamed v0.6.0's `cond` to `ifElse`, with the alias `if`, and
// reused the name `cond` for a new function; v0.9.0 renamed `allPredicates`
// and `anyPredicates` to `allPass` and `anyPass` and removed `if`; v0.12.0
// moved the predicate combinators `and`, `or` and `not` to `both`, `either`
// and `complement` and reused the old names for value operators.)

module Ramdaf.Logic {
  import opened Prelude

  export
    reveals and, or, not, both, either, complement, allPass, anyPass, ifElse, cond, defaultTo,
            propSatisfies, when, unless, until
    provides Prelude

  // `R.and(a, b)` (v0.12.0): `a && b`. From v0.1.4 to v0.11.0 `and` was the
  // predicate combinator that v0.12.0 renamed `both` (v0.1.0 to v0.1.3 had
  // the operator `!!(a && b)`). JS takes any values and returns the deciding
  // one (`and(1, 0)` is 0); the operands here are bool (README
  // "Deviations"). From v0.14.0 to v0.17.1 a first argument with an `and`
  // method was dispatched to (`a.and(b)`, Fantasy-land; a bool has none);
  // v0.18.0 removed the dispatch.
  function and(a: bool, b: bool): bool { a && b }

  // `R.or(a, b)` (v0.12.0): `a || b`, as for and (`either` until v0.11.0;
  // from v0.14.0 to v0.17.1 an `or` method of the first argument was
  // dispatched to).
  function or(a: bool, b: bool): bool { a || b }

  // `R.not(a)` (v0.12.0): `!a`, as for and (`complement` until v0.11.0).
  function not(a: bool): bool { !a }

  // v0.1.4 renamed `andFn`, `orFn` and `notFn` to `and`, `or` and `not`, and
  // v0.12.0 renamed those to `both`, `either` and `complement`, with the same
  // code. JS forwards any number of arguments to the predicates; the port's
  // predicates are unary (tuple the arguments for more). In v0.18.0
  // (c6ee5614, "Simplify logical functions") they were `lift(and)`,
  // `lift(or)` and `lift(not)`: on functions the same results, though the
  // second predicate was called even when the first decided (which a pure
  // predicate cannot observe) and the result was curried to the longer
  // predicate's arity; they also lifted the operators over any other
  // applicative, such as lists (`both([true, false], [true])` was `[true,
  // false]`), which these predicate types exclude (README "Deviations").
  // v0.19.0 makes both and either the short-circuiting function combinators
  // again (`_curry2`, `function _both() { return f.apply(this, arguments) &&
  // g.apply(this, arguments); }`); complement is still `lift(not)`. Since
  // v0.20.0 both and either are those combinators when f is a function
  // (`_isFunction(f)`) and `lift(and)(f, g)` and `lift(or)(f, g)` otherwise,
  // so they again combine other applicatives (`both([true, false], [true])`
  // is `[true, false]`), which these predicate types exclude.

  // `R.both(f, g)` (v0.12.0, `and` until v0.11.0): `f(...) && g(...)`,
  // short-circuited since v0.7.0 except in v0.18.0 (before, `!!(...)`). JS returns the deciding
  // operand, not a boolean; with boolean predicates that is the same bool
  // (README "Deviations").
  function both<T>(f: T -> bool, g: T -> bool): T -> bool { x => f(x) && g(x) }

  // `R.either(f, g)` (v0.12.0, `or` until v0.11.0): `f(...) || g(...)`,
  // short-circuited, as for both.
  function either<T>(f: T -> bool, g: T -> bool): T -> bool { x => f(x) || g(x) }

  // `R.complement(f)` (v0.12.0, `not` until v0.11.0): `!f(...)`.
  function complement<T>(f: T -> bool): T -> bool { x => !f(x) }

  // `R.allPass(preds)` (v0.9.0, which renamed `allPredicates`): since v0.18.0
  // (a599a531, "make R.anyPass and R.allPass return curried functions")
  // `_curry1`, a loop over the predicates curried to the longest one's arity,
  // `curryN(reduce(max, 0, pluck('length', preds)), …)`: a predicate true
  // exactly when every predicate holds, so `allPass([])(v)` is true, as here.
  // From v0.9.0 to v0.17.1 it was `_predicateWrap(_all)`: a second argument
  // applied it at once (`allPass(preds, v)`, which now returns the predicate
  // and ignores v), and `allPass([])` threw, as the arity was `max([])`.
  function allPass<T>(preds: seq<T -> bool>): T -> bool
  { x => forall i :: 0 <= i < |preds| ==> preds[i](x) }

  // `R.anyPass(preds)` (v0.9.0, which renamed `anyPredicates`): as allPass
  // (since v0.18.0 a curried loop; `_predicateWrap(_any)` until v0.17.1),
  // true exactly when some predicate holds (`anyPass([])(v)` is false, and
  // threw until v0.17.1).
  function anyPass<T>(preds: seq<T -> bool>): T -> bool
  { x => exists i :: 0 <= i < |preds| && preds[i](x) }

  // `R.ifElse(condition, onTrue, onFalse)` (v0.8.0, which renamed v0.6.0's
  // `cond` to `ifElse` with the same code): a function that applies onTrue
  // to its arguments when condition holds for them (truthy), and onFalse
  // otherwise; only the chosen branch is called. JS forwards any number of
  // arguments; the port's result is unary (tuple the arguments for more).
  function ifElse<A, B>(condition: A -> bool, onTrue: A -> B, onFalse: A -> B): A -> B
  { x => if condition(x) then onTrue(x) else onFalse(x) }

  // `R.cond([[pred, transform], ...])` (v0.8.0; the name held today's
  // `ifElse` from v0.6.0 to v0.7.2): a function that tests its arguments
  // against each pair's predicate in turn and returns the first truthy one's
  // transformer applied to them; later predicates are not called, and when
  // none matches the result is undefined (documented), here None. Since
  // v0.16.0 (f5558cba, "make R.cond a fixed-arity function") JS takes the
  // pairs as one list, as the port always did (until v0.15.1 they were
  // separate arguments, `cond([p1, t1], [p2, t2])`); JS forwards any number
  // of arguments, and the result here is unary (README "Deviations"); since
  // v0.20.0 it reports the longest predicate's arity (`_arity`).
  function cond<A, B>(pairs: seq<(A -> bool, A -> B)>): A -> Option<B>
  { x => if |pairs| == 0 then None
         else if pairs[0].0(x) then Some(pairs[0].1(x))
         else cond(pairs[1..])(x) }

  // `R.defaultTo(d, v)` (v0.10.0, `@category Logic`): `v == null || v !== v ?
  // d : v` (since v0.18.0; `v == null ? d : v` before), the value unless it
  // is null, undefined or (since v0.18.0) NaN, then the default (a T here has
  // no NaN). The port's
  // None stands for both (an absent property, a "no value" result), so the
  // value is an Option; JS lets the default and the value differ in type
  // (README "Deviations", with `isNil`).
  function defaultTo<T>(d: T, v: Option<T>): T
  { match v
      case Some(x) => x
      case None => d }

  // `R.propSatisfies(pred, name, obj)` (v0.16.0, `@category Logic`):
  // `pred(obj[name])`, pred applied to the property, undefined (None) when
  // obj lacks it (a JS object passes an inherited `Object.prototype` member
  // for such a name; a map has none, README "Deviations"). `R.prop`
  // (Object) is written out, as Logic imports only Prelude.
  function propSatisfies<V>(pred: Option<V> -> bool, name: string, obj: map<string, V>): bool
  { pred(if name in obj then Some(obj[name]) else None) }

  // `R.when(pred, whenTrueFn, x)` (v0.18.0, `@category Logic`): `pred(x) ?
  // whenTrueFn(x) : x`, x passed through whenTrueFn when pred holds for it
  // (truthy), and x itself otherwise. JS lets whenTrueFn return a value of
  // another type (`when(x => x > 0, String, 3)` is '3'; README "Deviations").
  function when<T>(pred: T -> bool, whenTrueFn: T -> T, x: T): T
  { if pred(x) then whenTrueFn(x) else x }

  // `R.unless(pred, whenFalseFn, x)` (v0.18.0, `@category Logic`): `pred(x) ?
  // x : whenFalseFn(x)`, x itself when pred holds for it, and otherwise x
  // passed through whenFalseFn (`unless(isArrayLike, of)(10)` is `[10]` in
  // JS, of another type: README "Deviations").
  function unless<T>(pred: T -> bool, whenFalseFn: T -> T, x: T): T
  { if pred(x) then x else whenFalseFn(x) }

  // `R.until(pred, fn, init)` (v0.20.0, `@category Logic`): `var val = init;
  // while (!pred(val)) { val = fn(val); } return val;`, fn applied to init
  // until pred holds (`until(x => x > 100, multiply(2), 1)` is 128), possibly
  // forever. Dafny functions must terminate, so, as for `List.unfold`, an
  // extra `fuel` bounds the applications of fn: after `fuel` of them the
  // value is returned whether or not pred holds (README "Deviations"). JS
  // lets fn return a value of another type (README "Deviations").
  function until<T>(pred: T -> bool, fn: T -> T, init: T, fuel: nat): T
    decreases fuel
  { if pred(init) || fuel == 0 then init else until(pred, fn, fn(init), fuel - 1) }
}
