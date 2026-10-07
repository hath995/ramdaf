// Ramda v0.9.1 test/always.js, T.js, F.js, compose.js, pipe.js,
// converge.js, flip.js and ap.js (until v0.8.0 test.always.js,
// test.compose.js and test.functionBasics.js), transcribed. A call with no
// arguments is a call with the unit value `()`. Not transcribed: the Date
// case of `always`; compose/pipe's "passes context to functions" (`this`,
// v0.2.3, which also dropped the single-function cases); compose's "returns
// a function with arity == rightmost argument" (v0.3.0; arity), and
// compose's (v0.3.0) and pipe's (v0.4.0) "throws if given no arguments" and
// "returns argument if given exactly one argument" (compose and pipe are
// binary here, and the latter checks function identity); flip's "produces a
// function that throws if given no arguments" (v0.4.0; no-argument call);
// ap's "dispatches to the passed object's ap method" (method dispatch on a
// non-array object) and the `typeof` check of its "is curried" (since v0.5.0
// the dispatch case calls `ap(obj, 10)`, on the first argument). The files
// of functions that are not portable (README) are not transcribed: useWith,
// once, memoize, construct, constructN, unary, binary, nAry, apply, unapply,
// pCompose, pPipe, curry, curryN, op, lPartial, rPartial, wrap, forEach,
// forEachIndexed, installTo, path, pathOn, pathEq, is, isArrayLike, type,
// functions, functionsIn, bind, invoker, lift, liftN, nthArg, and v0.9.0's
// new arity.js and call.js; test.examplesRunner.js runs the JSDoc examples
// through `dox` and is not a hand-written suite. (v0.1.3 moved test.lazy.js
// out of test/, v0.4.1 removed test.always.js's "should be aliased by
// `constant`" with `constant`, and v0.9.0 removed alwaysZero's describe with
// the function and renamed the alwaysTrue and alwaysFalse describes to T and
// F.)

module RamdafTests.Ramda.Functions {
  import opened Ramdaf.Functions
  import opened Ramdaf.List
  import opened Ramdaf.Math
  import opened Support

  // ---- always.js, T.js, F.js ----

  // describe('always')
  // (v0.5.0 adds `always()()`, whose omitted value is undefined)
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

  function a(x: string): string { x + "A" }
  function b(x: string): string { x + "B" }
  function c(x: string): string { x + "C" }
  function d(x: string): string { x + "D" }

  // `compose(a, b, c, d)`, nested
  method {:test} ComposeRunsRightToLeft() {
    expect compose(a, compose(b, compose(c, d)))("") == "DCBA";
  }

  // v0.2.3: "first function is passed multiple args" (`e(a, b, c)` takes the
  // three arguments as a tuple here).
  function e(t: (int, int, int)): string { NumStr(t.2) + "E" }

  method {:test} ComposeFirstFunctionIsPassedMultipleArgs() {
    expect compose(a, compose(b, compose(c, e)))((1, 2, 3)) == "3ECBA";
  }

  // `pipe(a, b, c, d)`, nested
  method {:test} PipeRunsLeftToRight() {
    expect pipe(a, pipe(b, pipe(c, d)))("") == "ABCD";
  }

  method {:test} PipeFirstFunctionIsPassedMultipleArgs() {
    expect pipe(e, pipe(a, pipe(b, c)))((1, 2, 3)) == "3EABC";
  }

  // describe('converge') (describe('fork') until v0.4.1)
  // `converge(mult, add(1), add(3))(2)`: mult(add1(2), add3(2)) = mult(3, 5)
  method {:test} ConvergePassesTheResultsOfTwoFunctionsIntoAThird() {
    expect converge((a: int, b: int) => a * b, (x: int) => add(1, x), (x: int) => add(3, x))(2) == 15;
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
