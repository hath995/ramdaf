// Ramda v0.4.1 test/test.always.js, test/test.compose.js and
// test/test.functionBasics.js, transcribed. A call with no arguments is a call
// with the unit value `()`. Not transcribed: the Date case of `always`;
// compose/pipe's "passes context to functions" (`this`, v0.2.3, which also
// dropped the single-function cases); compose's "returns a function with
// arity == rightmost argument" (v0.3.0; arity), and compose's (v0.3.0) and
// pipe's (v0.4.0) "throws if given no arguments" and "returns argument if
// given exactly one argument" (compose and pipe are binary here, and the
// latter checks function identity); flip's "produces a function that throws
// if given no arguments" (v0.4.0; no-argument call); ap's "dispatches to the
// passed object's ap method" (method dispatch on a non-array object) and the
// `typeof` check of its "is curried"; useWith, once, memoize, construct,
// constructN (v0.4.0), unary, binary and nAry (v0.4.1) (not portable, README;
// v0.3.0 dropped the use-over describe with `use`). test.each.js, test.maybe.js,
// test.partial.js, test.wrap.js, test.expose.js, v0.2.2's new test.curry.js
// and test.path.js, v0.3.0's new test.is.js and v0.4.0's new
// test.functions.js and test.functionsIn.js test functions that are not
// portable. (v0.1.3 moved test.lazy.js out of test/, and v0.4.1 removed
// test.always.js's "should be aliased by `constant`" with `constant`.)

module RamdafTests.Ramda.Functions {
  import opened Ramdaf.Functions
  import opened Ramdaf.List
  import opened Ramdaf.Math
  import opened Support

  // ---- test.always.js ----

  // describe('always')
  method {:test} AlwaysReturnsTheValueInitiallySupplied() {
    expect always(42)(()) == 42;
    expect always(42)(10) == 42;
    expect always(42)(false) == 42;
  }
  method {:test} AlwaysWorksWithVariousTypes() {
    expect always(false)(()) == false;
    expect always("abc")(()) == "abc";
    expect always(map["a" := 1, "b" := 2])(()) == map["a" := 1, "b" := 2];
    var obj := map["a" := 1, "b" := 2];
    expect always(obj)(()) == obj;
  }

  // describe('alwaysZero'), describe('alwaysFalse'), describe('alwaysTrue')
  method {:test} AlwaysZeroAlwaysReturnsZero() {
    expect alwaysZero(()) == 0;
    expect alwaysZero(10) == 0;
    expect alwaysZero(false) == 0;
  }
  method {:test} AlwaysFalseAlwaysReturnsFalse() {
    expect alwaysFalse(()) == false;
    expect alwaysFalse(10) == false;
    expect alwaysFalse(true) == false;
  }
  method {:test} AlwaysTrueAlwaysReturnsTrue() {
    expect alwaysTrue(()) == true;
    expect alwaysTrue(10) == true;
    expect alwaysTrue(true) == true;
  }

  // ---- test.compose.js ----

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

  // describe('fork')
  // `fork(mult, add(1), add(3))(2)`: mult(add1(2), add3(2)) = mult(3, 5)
  method {:test} ForkPassesTheResultsOfTwoFunctionsIntoAThird() {
    expect fork((a: int, b: int) => a * b, (x: int) => add(1, x), (x: int) => add(3, x))(2) == 15;
  }

  // ---- test.functionBasics.js: describe('flip') ----
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

  // ---- test.functionBasics.js: describe('ap') (v0.3.0) ----

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
