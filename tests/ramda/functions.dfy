// Ramda v0.1.1 test/test.always.js, test/test.compose.js and
// test/test.functionBasics.js, transcribed. A call with no arguments is a call
// with the unit value `()`. Not transcribed: the Date case of `always`;
// single-function compose/pipe (the port is binary); use/useWith, once,
// memoize and construct (not portable, README); test.lazy.js (except
// describe('repeat.nTimes'), in list.dfy), test.each.js, test.maybe.js,
// test.partial.js, test.wrap.js and test.expose.js test functions that are
// not portable.

module RamdafTests.Ramda.Functions {
  import opened Ramdaf.Functions

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

  // `pipe(a, b, c, d)`, nested
  method {:test} PipeRunsLeftToRight() {
    expect pipe(a, pipe(b, pipe(c, d)))("") == "ABCD";
    expect sequence(a, sequence(b, sequence(c, d)))("") == "ABCD";
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
}
