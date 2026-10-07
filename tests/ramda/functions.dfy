// Ramda v0.18.0 test/always.js, T.js, F.js, compose.js, pipe.js,
// converge.js, flip.js and ap.js (until v0.8.0 test.always.js,
// test.compose.js and test.functionBasics.js), transcribed. A call with no
// arguments is a call with the unit value `()`. Not transcribed: the Date
// case of `always`; compose/pipe's "passes context to functions" (`this`,
// v0.2.3, which also dropped the single-function cases); compose's "returns
// a function with arity == rightmost argument" (v0.3.0; arity), and
// compose's (v0.3.0) and pipe's (v0.4.0) "throws if given no arguments" and
// "returns argument if given exactly one argument" (compose and pipe are
// binary here, and the latter checks function identity; v0.11.0 replaces it
// with "can be applied to one argument", a one-function compose or pipe and
// its arity), and v0.16.0's "is a variadic function" (arity); flip's "produces a function that throws if given no arguments"
// (v0.4.0 to v0.10.0; no-argument call);
// ap's "dispatches to the passed object's ap method" (method dispatch on a
// non-array object), the `typeof` check of its "is curried" (since v0.5.0
// the dispatch case calls `ap(obj, 10)`, on the first argument) and
// v0.18.0's "interprets ((->) r) as an applicative" (`ap` on functions; the
// port's takes lists, README "Deviations"); v0.14.0's
// converge "returns a function with the length of the "longest" argument"
// (arity), "passes context to its functions" (`this`) and the
// `f3(R.__).length` half of its "returns a curried function". The files
// of functions that are not portable (README) are not transcribed: useWith,
// once, memoize, construct, constructN, unary, binary, nAry, apply, unapply,
// composeP, pipeP, curry, curryN, op, partial, partialRight, wrap, forEach,
// forEachIndexed (until v0.15.1), installTo (until v0.11.0), path, pathOn,
// pathEq, pathOr (v0.18.0), is, propIs (v0.16.0), isArrayLike, type,
// functions, functionsIn, bind, invoker, lift, liftN, nthArg, and v0.9.0's
// new call.js, v0.14.0's uncurryN.js and v0.15.0's addIndex.js, and
// v0.16.0's composeK.js and pipeK.js, whose monad is an `Identity` object
// with a `chain` method, not a list (README "Deviations"); test/helpers/test.examplesRunner.js (test/ until v0.14.0) runs the JSDoc examples
// through `dox` and is not a hand-written suite. (v0.1.3 moved test.lazy.js
// out of test/, v0.4.1 removed test.always.js's "should be aliased by
// `constant`" with `constant`, and v0.9.0 removed alwaysZero's describe with
// the function and renamed the alwaysTrue and alwaysFalse describes to T and
// F; v0.10.0 renamed the files of pCompose, pPipe, lPartial and rPartial to
// composeP, pipeP, partial and partialRight with the functions; v0.11.0
// removed op.js and pathOn.js with the functions and added the unportable
// dissocPath.js, invariants.js (arity under partial application) and
// internal/_curry2.js and internal/_curry3.js; v0.12.0 removed installTo.js
// with the function and added the unportable invoke.js, into.js and
// transduce.js; v0.13.0 added isNaN.js and retitled the "is automatically
// curried" `it`s "is curried"; v0.14.0 removed func.js with the function;
// v0.15.0 removed isNaN.js with the function; v0.16.0 removed composeL.js,
// pipeL.js, arity.js and forEachIndexed.js with the functions and rewrote
// compose.js and pipe.js; v0.18.0 rewrote compose's and pipe's "performs
// right-to-left (left-to-right) function composition" again, retitled ap's
// "applies a list of functions to a list of values" "interprets [a] as an
// applicative", and passes converge's functions as one list, a pair here.)

module RamdafTests.Ramda.Functions {
  import opened Ramdaf.Prelude
  import opened Ramdaf.Functions
  import opened Ramdaf.List
  import opened Ramdaf.Math
  import C = Ramdaf.Core
  import O = Ramdaf.Object
  import opened Support

  // ---- always.js, T.js, F.js ----

  // describe('always')
  // (v0.5.0 adds `always()()`, whose omitted value is undefined; since
  // v0.11.0 Ramda writes `always(undefined)()`)
  method {:test} AlwaysReturnsTheValueInitiallySupplied() {
    expect always(42)(()) == 42;
    expect always(42)(10) == 42;
    expect always(42)(false) == 42;
    expect always(Undefined)(()) == Undefined;
  }
  method {:test} AlwaysWorksWithVariousTypes() {
    expect always(false)(()) == false;
    expect always("abc")(()) == "abc";
    expect always(map["a" := 1, "b" := 2])(()) == map["a" := 1, "b" := 2];
    var obj := map["a" := 1, "b" := 2];
    expect always(obj)(()) == obj;
  }

  // describe('F') and describe('T') (describe('alwaysFalse') and
  // describe('alwaysTrue') until v0.8.0)
  method {:test} FAlwaysReturnsFalse() {
    expect F(()) == false;
    expect F(10) == false;
    expect F(true) == false;
  }
  method {:test} TAlwaysReturnsTrue() {
    expect T(()) == true;
    expect T(10) == true;
    expect T(true) == true;
  }

  // ---- compose.js, pipe.js, converge.js ----

  // describe('compose'), describe('pipe'): v0.18.0's "performs
  // right-to-left (left-to-right) function composition", `f =
  // compose(R.map, R.multiply, parseInt)` (`pipe(parseInt, R.multiply,
  // R.map)`), nested here, with the curried `R.multiply(n)` and `R.map(fn)`
  // as lambdas and `parseInt(s, radix)` taking a tuple, its omitted radix
  // undefined (None, base 10); the `.length` line (arity) is not transcribed.
  // (v0.16.0 and v0.17.x composed `f(a) = [a]`, `g(a, b) = [a, b]` and `h(a,
  // b, c) = [a, b, c]`; until v0.15.1 "executes its passed in functions in
  // order from right to left (left to right)" over string functions and
  // "first function is passed multiple args".)
  function ParseInt(t: (string, Option<int>)): int
    decreases |t.0|
  { var radix := if t.1.Some? then t.1.value else 10;
    if |t.0| == 0 then 0
    else ParseInt((t.0[..|t.0| - 1], t.1)) * radix + (t.0[|t.0| - 1] as int - '0' as int) }
  function MultiplyBy(n: int): int -> int { (x: int) => multiply(n, x) }
  function MapWith(fn: int -> int): seq<int> -> seq<int> { (l: seq<int>) => mapSeq(fn, l) }

  method {:test} ComposePerformsRightToLeftFunctionComposition() {
    var f := compose(MapWith, compose(MultiplyBy, ParseInt));
    expect f(("10", None))([1, 2, 3]) == [10, 20, 30];
    expect f(("10", Some(2)))([1, 2, 3]) == [2, 4, 6];
  }

  method {:test} PipePerformsLeftToRightFunctionComposition() {
    var f := pipe(ParseInt, pipe(MultiplyBy, MapWith));
    expect f(("10", None))([1, 2, 3]) == [10, 20, 30];
    expect f(("10", Some(2)))([1, 2, 3]) == [2, 4, 6];
  }

  // describe('converge') (describe('fork') until v0.4.1): since v0.18.0 the
  // branching functions are one list, a pair here
  // `converge(mult, [add(1), add(3)])(2)`: mult(add1(2), add3(2)) = mult(3, 5)
  method {:test} ConvergePassesTheResultsOfTwoFunctionsIntoAThird() {
    expect converge((a: int, b: int) => a * b, ((x: int) => add(1, x), (x: int) => add(3, x)))(2) == 15;
  }

  // v0.14.0 "returns a curried function": `f2 = converge(mult, [a => a, (a,
  // b) => b])` takes two arguments (a tuple here), and `f2(6)(7)` is
  // `mult(6, 7)`; its `f3(R.__).length` checks an arity.
  method {:test} ConvergeReturnsACurriedFunction() {
    var f2 := converge((a: int, b: int) => a * b, ((p: (int, int)) => p.0, (p: (int, int)) => p.1));
    var f2Of6 := (y: int) => f2((6, y));
    expect f2Of6(7) == 42;
  }

  // ---- flip.js ----
  // The JS function takes a third argument that flip passes through; the
  // binary port keeps the two that flip swaps.

  method {:test} FlipInvertsTheFirstTwoArguments() {
    var f := (x: string, y: string) => x + " " + y;
    var g := flip(f);
    expect f("a", "b") == "a b";
    expect g("a", "b") == "b a";
  }

  method {:test} FlipReturnsACurriedFunction() {
    var f := (x: string, y: string) => x + " " + y;
    var g := (y: string) => flip(f)("a", y);
    expect g("b") == "b a";
  }

  // ---- ap.js (v0.3.0) ----

  function mult2(x: int): int { x * 2 }
  function plus3(x: int): int { x + 3 }

  method {:test} ApAppliesAListOfFunctionsToAListOfValues() {
    expect ap([mult2, plus3], [1, 2, 3]) == [2, 4, 6, 4, 5, 6];
  }

  method {:test} ApIsCurried() {
    var val := (vs: seq<int>) => ap([mult2, plus3], vs);
    expect val([1, 2, 3]) == [2, 4, 6, 4, 5, 6];
  }
}
