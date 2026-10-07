// Ramdaf: Ramda v0.29.1 `source/<fn>.js` for the functions ported up to v0.8.0
// from ramda.js's "Function functions" section, `flip` (an internal function
// in v0.8.0) and the `always` family (`always`, `T`, `F`); from v0.9.0 on,
// the functions with `@category Function` (`juxt`, `applySpec`, `o`,
// `applyTo`, `thunkify`, `pipeWith`, `composeWith`, `on`, `promap`). (v0.4.1
// removed the aliases `sequence`, `distributeTo`, `constant` and `K`;
// v0.4.2 renamed `fork` to `converge`; v0.9.0 renamed `alwaysTrue` and
// `alwaysFalse` to `T` and `F` and removed `alwaysZero`; v0.16.0 removed
// v0.14.0's `composeL` and `pipeL`, as lenses compose with `compose`;
// v0.28.0 removed `composeK` and `pipeK` (v0.16.0), deprecated since v0.26.0
// for `composeWith(chain)` and `pipeWith(chain)`.) compose/pipe are variadic
// in JS; the port is binary (nest for more functions). Functions imports
// List for `juxt` (`List.mapSeq`; since v0.16.0, when composeK and pipeK
// chained with `List.chain`).

module Ramdaf.Functions {
  import List

  export
    reveals compose, pipe, flip, converge, always, T, F, juxt, applySpec, o, applyTo,
            thunkify, pipeWith, composeWith, on, promap
    provides List

  // `compose(f, g)(x) == f(g(x))`
  // (v0.1.1 dropped the `fog` alias. From v0.3.0 to v0.10.0 JS `compose(f)`
  // returned f itself, and since v0.11.0 a wrapper with f's arity and
  // results; `compose()` throws; with two or more functions only the result's
  // reported arity changed. Since v0.16.0 it is `pipe` of the reversed
  // functions, and it composes van Laarhoven lenses (`Prelude.Lens`):
  // `compose(lensProp('a'), lensIndex(0))` focuses the head of the property
  // a.)
  function compose<A, B, C>(f: B -> C, g: A -> B): A -> C { x => f(g(x)) }

  // `pipe(f, g)(x) == g(f(x))` (from v0.4.0 to v0.10.0 JS `pipe(f)` was f
  // itself, as `compose(f)` was, and since v0.11.0 it is a wrapper with f's
  // results; since v0.16.0 `curryN(fns[0].length, reduce(_pipe, …))`, and
  // since v0.18.0 `_arity(…)`, whose result is not curried)
  function pipe<A, B, C>(f: A -> B, g: B -> C): A -> C { x => g(f(x)) }

  // `flip(fn)(a, b) == fn(b, a)` (since v0.25.0 the result is curried to
  // fn's arity, `curryN(fn.length, …)`, where it was binary; the arguments
  // past the second still go to fn, and the port's fn is binary)
  function flip<A, B, C>(fn: (A, B) -> C): (B, A) -> C { (b, a) => fn(a, b) }

  // `converge(after, [f1, ..., fn])(...args) == after(f1(...args), ..., fn(...args))`
  // (v0.18.0, 360d5904 "make converge a binary function": `_curry2(function
  // converge(after, fns))`, the branching functions one list, and the result
  // curried to the longest function's arity, `curryN(Math.max.apply(Math,
  // pluck('length', fns)), …)`, which passes its `this` on; since v0.20.0
  // the arity is `reduce(max, 0, …)`, so `converge(after, [])` is a function
  // of no arguments that calls after with none, where until v0.19.1 it threw
  // as the arity was -Infinity). Until v0.17.1 the functions
  // were separate arguments, `converge(after, f1, f2)`: v0.4.2 renamed
  // `fork`, added in v0.1.2, to `converge` with the same code, v0.1.4 had
  // moved `after` first and allowed any number of functions (v0.4.2's
  // documentation named three), v0.11.0 made it `curryN(3, …)`, so
  // `converge(after, f)` waited for another function, and v0.14.0 curried
  // its result to the longest function's arity. The list is a pair here
  // (README "JS -> Dafny mapping"), so the port takes exactly two
  // functions, and its result is unary (tuple the arguments for more).
  function converge<A, B, C, D>(after: (B, C) -> D, fns: (A -> B, A -> C)): A -> D
  { x => after(fns.0(x), fns.1(x)) }

  // JS `always(v)` ignores however many arguments it gets; the port's result
  // takes one argument of any type.
  function always<T, U>(val: T): U -> T { _ => val }

  // `R.T = function() { return true; }` and `R.F = function() { return
  // false; }` (v0.26.0; from v0.9.0, which renamed `alwaysTrue` and
  // `alwaysFalse` with the same code, to v0.25.0 `always(true)` and
  // `always(false)`, the same results, and the bodies called `always`;
  // `alwaysZero`, removed in v0.9.0, was `always(0)`): the functions
  // themselves, applied to one argument of any type, which they ignore.
  function T<U>(x: U): bool { true }
  function F<U>(x: U): bool { false }

  // `R.juxt(fns)` (v0.19.0, `@category Function`): a function that applies
  // every function to its arguments and lists the results in order
  // (`juxt([add(3), multiply(2)])(2)` is `[5, 4]`). Since v0.20.0 it is
  // `converge(_arrayOf, fns)`, curried to the longest function's arity
  // (`juxt([multiply, add])(2)(3)` is `[6, 5]`), with the same results; in
  // v0.19.x `function() { return map(apply(__, arguments), fns); }`. JS
  // forwards any number of arguments; the result here is unary (tuple the
  // arguments for more, `()` for none). The port's converge takes a pair of
  // functions, so the body keeps v0.19.0's form: `R.map` is `List.mapSeq`
  // with the application written out (`R.apply` is not portable, README).
  function juxt<A, B>(fns: seq<A -> B>): A -> seq<B>
  { x => List.mapSeq((f: A -> B) => f(x), fns) }

  // `R.applySpec(spec)` (v0.20.0, `@category Function`): `spec =
  // map(function(v) { return typeof v == 'function' ? v : applySpec(v); },
  // spec)`, then `curryN(reduce(max, 0, pluck('length', values(spec))),
  // function() { var args = arguments; return map(function(f) { return
  // apply(f, args); }, spec); })`: a function that calls every function of
  // the spec with its arguments and returns an object of the same shape
  // (`applySpec({v: inc, u: dec})(1)` is `{v: 2, u: 0}`). Here the spec maps
  // each key to a function of one type, and `R.map` over an object is
  // written out as a map comprehension (as in Object.whereEq). A nested spec
  // object, which JS applies recursively, and a value that is neither a
  // function nor an object (it throws) cannot be written (README "Outside
  // the modeled domain"). JS forwards any number of arguments and curries
  // the result to the longest function's arity; the result here is unary
  // (tuple the arguments for more, `()` for none; README "Deviations"). The
  // spec is copied with R.map, so in JS an own `__proto__` spec function is
  // dropped and a reduced marker key ends the copy (README "Deviations").
  // Since v0.26.0 the spec is copied with a local `mapValues(fn, obj)`,
  // `keys(obj).reduce(function(acc, key) { acc[key] = fn(obj[key]); return
  // acc; }, {})`, in place of `R.map`, so a reduced marker key is an ordinary
  // key again and a spec key `map` (or `fantasy-land/map`) is no longer
  // dispatched to (README "Deviations"); an own `__proto__` is still dropped.
  function applySpec<A, B>(spec: map<string, A -> B>): A -> map<string, B>
  { x => map k | k in spec :: spec[k](x) }

  // `R.o(f, g, x)` (v0.24.0, `@category Function`): `_curry3(function o(f, g,
  // x) { return f(g(x)); })`, the composition of exactly two functions,
  // applied to x (`o(R.add(1), R.multiply(2), 10)` is 21), curried where
  // compose is variadic (`o(f, g)` is a function of x). Uncurried, it takes
  // its three parameters.
  function o<A, B, C>(f: B -> C, g: A -> B, x: A): C { f(g(x)) }

  // `R.applyTo(x, f)` (v0.25.0, `@category Function`): `_curry2(function
  // applyTo(x, f) { return f(x); })`, the thrush combinator, x passed to f
  // (`applyTo(21, R.multiply(2))` is 42).
  function applyTo<A, B>(x: A, f: A -> B): B { f(x) }

  // `R.thunkify(fn)` (v0.26.0, `@category Function`): `curryN(fn.length,
  // function createThunk() { var fnArgs = arguments; return function
  // invokeThunk() { return fn.apply(this, fnArgs); }; })`, a function that
  // takes fn's arguments and returns a thunk, a function of no arguments
  // that calls fn with them (`thunkify(add(2))(40)()` is 42). JS curries it
  // to fn's arity; the port's is unary (tuple the arguments for more;
  // README "Deviations"), and the thunk is a zero-argument arrow.
  function thunkify<A, B>(fn: A -> B): A -> (() -> B) { x => () => fn(x) }

  // `R.pipeWith(xf, list)` (v0.26.0, `@category Function`): `if (list.length
  // <= 0) { return identity; }`, and otherwise `_arity(head(list).length,
  // function() { return _reduce(function(result, f) { return xf.call(this, f,
  // result); }, head(list).apply(this, arguments), tail(list)); })`: the
  // first function applied to the arguments and each later one combined with
  // the result so far by xf (`pipeWith((f, res) => f(res), [f, g])` is
  // `pipe(f, g)`; with `chain` it is pipeK, with `then` pipeP). JS takes a
  // list of any number of functions; here exactly two, as a pair (README
  // "JS -> Dafny mapping"; nest for more), so xf gets the second function
  // and the first one's result: `pipeWith(xf, (f, g))(x)` is `xf(g, f(x))`.
  // The result is unary (tuple the arguments for more; README
  // "Deviations"). Until v0.28.0 `_reduce` stopped at a result carrying the
  // reduced marker and returned its `@@transducer/value`
  // (`pipeWith((f, r) => f(r), [x => x, x => ({'@@transducer/reduced': 1,
  // '@@transducer/value': 9})])(0)` was 9; an omission of the v0.26.0 to
  // v0.28.0 ports, README "Deviations"); since v0.29.0 `_reduce` is a plain
  // loop and gives the marked object, as here.
  function pipeWith<A, B, G, C>(xf: (G, B) -> C, fns: (A -> B, G)): A -> C
  { x => xf(fns.1, fns.0(x)) }

  // `R.composeWith(xf, list)` (v0.26.0, `@category Function`):
  // `pipeWith.apply(this, [xf, reverse(list)])`, pipeWith with the
  // functions right to left (`composeWith(xf, (g, f))(x)` is `xf(g, f(x))`);
  // the pair reversed is its swap.
  function composeWith<A, B, G, C>(xf: (G, B) -> C, fns: (G, A -> B)): A -> C
  { pipeWith(xf, (fns.1, fns.0)) }

  // `R.on(f, g, a, b)` (v0.28.0, `@category Function`): `curryN(4, [],
  // function on(f, g, a, b) { return f(g(a), g(b)); })`, the P combinator:
  // g applied to both values and f to the results (`on((a, b) => a + b, x
  // => x * 2, 1, 2)` is 6). Uncurried, it takes its four parameters.
  function on<A, B, C>(f: (B, B) -> C, g: A -> B, a: A, b: A): C { f(g(a), g(b)) }

  // `R.promap(f, g, profunctor)` (v0.28.0, `@category Function`):
  // `_dispatchable(['fantasy-land/promap', 'promap'], _xpromap, _promap)`,
  // and for a function the private `_promap`, `function(x) { return
  // g(profunctor(f(x))); }`: f before the function and g after it
  // (`promap(x => x + 1, x => x * 10, x => x - 3)(5)` is 30). JS dispatches
  // to a profunctor's `promap` method and is a transducer; here the
  // profunctor is a function (README "Deviations").
  function promap<A, B, C, D>(f: A -> B, g: C -> D, profunctor: B -> C): A -> D
  { x => g(profunctor(f(x))) }
}
