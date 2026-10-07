// Ramda v0.6.0 test/test.math.js, transcribed. Numbers are ints (real for
// division); the string comparisons in lt/lte/gt/gte and the decimal/string
// cases of max/min are not expressible (README "Deviations"). `subtract`,
// `divide`, `modulo`, `mathMod`, `lt`, `lte`, `gt` and `gte` are
// `op`-curried: since v0.6.0 one argument fixes the first parameter again
// (`subtract(9)` is `x => 9 - x`), and `f(__, b)` with the placeholder `__`
// (undefined) fixes the second (in v0.5.0 alone, one argument fixed the
// second and `f(a, _)` the first, and Ramda's `it` names had left and right
// the other way round). The lambdas follow what the code computes. Not
// transcribed: mathMod's "requires integer arguments" (string and fractional
// arguments, which give NaN); the last two asserts of its "behaves
// differently than JS modulo" (17.2 is fractional, and since v0.4.2
// `mathMod(17, -5)` is NaN: a modulus below 1 is outside the domain, README)
// and the four NaN asserts of v0.4.2's "computes the true modulo function"
// (`mathMod(17, -5)`, `mathMod(17, 0)` and fractional arguments); v0.4.0's 13
// "throws if given no arguments" cases (no-argument calls). (v0.5.0
// removed subtractN, divideBy and moduloBy with their describes.)

module RamdafTests.Ramda.Math {
  import opened Ramdaf.Prelude
  import opened Ramdaf.Math
  import opened Support

  // describe('add')
  method {:test} AddAddsTwoNumbers() { expect add(3, 7) == 10; }
  method {:test} AddIsAutomaticallyCurried() { var incr := (x: int) => add(1, x); expect incr(42) == 43; }

  // describe('multiply')
  method {:test} MultiplyMultipliesTwoNumbers() { expect multiply(6, 7) == 42; }
  method {:test} MultiplyIsAutomaticallyCurried() { var dbl := (x: int) => multiply(2, x); expect dbl(15) == 30; }

  // describe('subtract')
  method {:test} SubtractSubtractsTwoNumbers() { expect subtract(22, 7) == 15; }
  // "is curried": `subtract(9)`
  method {:test} SubtractIsCurried() { var ninesCompl := (x: int) => subtract(9, x); expect ninesCompl(6) == 3; }
  // v0.6.0: "behaves right curried when passed `undefined` for its first
  // argument": `subtract(void 0, 5)`
  method {:test} SubtractBehavesRightCurriedWithUndefinedFirst() { var minus5 := (x: int) => subtract(x, 5); expect minus5(17) == 12; }

  // describe('divide')
  method {:test} DivideDividesTwoNumbers() { expect divide(28.0, 7.0) == 4.0; }
  // "is curried": `divide(28)`
  method {:test} DivideIsCurried() {
    var into28 := (x: real) requires x != 0.0 => divide(28.0, x);
    expect into28(7.0) == 4.0;
  }
  // v0.6.0: "behaves right curried when passed `undefined` for its first
  // argument": `divide(void 0, 2)`
  method {:test} DivideBehavesRightCurriedWithUndefinedFirst() {
    var half := (x: real) => divide(x, 2.0);
    expect half(40.0) == 20.0;
  }

  // describe('modulo')
  method {:test} ModuloDividesAndReturnsTheRemainder() {
    expect modulo(100, 2) == 0;
    expect modulo(100, 3) == 1;
    expect modulo(100, 17) == 15;
  }
  // "is curried": `modulo(100)`
  method {:test} ModuloIsCurried() {
    var hundredMod := (x: int) requires x != 0 => modulo(100, x);
    expect hundredMod(2) == 0;
    expect hundredMod(3) == 1;
    expect hundredMod(17) == 15;
  }
  // v0.6.0: "behaves right curried when passed `undefined` for its first
  // argument": `modulo(void 0, 2)`
  method {:test} ModuloBehavesRightCurriedWithUndefinedFirst() {
    var isOdd := (x: int) => modulo(x, 2);
    expect isOdd(3) == 1;
    expect isOdd(198) == 0;
  }
  method {:test} ModuloPreservesJsModuloForNegativeNumbers() {
    expect modulo(-5, 4) == -1;
  }

  // describe('mathMod') (v0.3.0): the first assert of "behaves differently
  // than JS modulo" (`-17 % 5` is -2, `mathMod(-17, 5)` is 3 since v0.4.2;
  // until v0.4.1 it was NaN, and the port transcribed the third assert,
  // `mathMod(17, -5)`, which v0.4.2 makes NaN).
  method {:test} MathModBehavesDifferentlyThanJsModulo() {
    expect mathMod(-17, 5) != modulo(-17, 5);
  }
  // v0.4.2: the first assert of "computes the true modulo function"
  method {:test} MathModComputesTheTrueModuloFunction() {
    expect mathMod(-17, 5) == 3;
  }
  // "is curried": `mathMod(29)`
  method {:test} MathModIsCurried() {
    var f := (p: int) requires p >= 1 => mathMod(29, p);
    expect f(6) == 5;
  }
  // v0.6.0: "behaves right curried when passed `undefined` for its first
  // argument", which calls `modulo(void 0, 5)`, not mathMod
  method {:test} MathModBehavesRightCurriedWithUndefinedFirst() {
    var mod5 := (x: int) => modulo(x, 5);
    expect mod5(12) == 2;
    expect mod5(8) == 3;
  }

  // describe('sum'), describe('product')
  method {:test} SumAddsTheArray() { expect sum([1, 2, 3, 4]) == 10; }
  // v0.2.2
  method {:test} SumDoesNotSaveTheStateOfTheAccumulator() {
    expect sum([1, 2, 3, 4]) == 10;
    expect sum([1]) == 1;
    expect sum([5, 5, 5, 5, 5]) == 25;
  }
  method {:test} ProductMultipliesTheArray() { expect product([1, 2, 3, 4]) == 24; }

  // describe('lt') etc. (the string cases are not expressible)
  method {:test} LtReportsLessThan() {
    expect lt(3, 5);
    expect !lt(6, 4);
    expect !lt(7, 7);
  }
  // "is curried": `lt(5)`
  method {:test} LtIsCurried() {
    var gt5 := (x: int) => lt(5, x);
    expect gt5(10);
    expect !gt5(5);
    expect !gt5(3);
  }
  // v0.6.0: "behaves right curried when passed `undefined` for its first
  // argument": `lt(__, 5)`
  method {:test} LtBehavesRightCurriedWithUndefinedFirst() {
    var lt5 := (x: int) => lt(x, 5);
    expect !lt5(10);
    expect !lt5(5);
    expect lt5(3);
  }
  method {:test} LteReportsLessOrEqual() {
    expect lte(3, 5);
    expect !lte(6, 4);
    expect lte(7, 7);
  }
  // "is curried": `lte(20)`
  method {:test} LteIsCurried() {
    var gte20 := (x: int) => lte(20, x);
    expect !gte20(10);
    expect gte20(20);
    expect gte20(25);
  }
  // v0.6.0: "behaves right curried when passed `undefined` for its first
  // argument": `lte(__, 20)`
  method {:test} LteBehavesRightCurriedWithUndefinedFirst() {
    var upTo20 := (x: int) => lte(x, 20);
    expect upTo20(10);
    expect upTo20(20);
    expect !upTo20(25);
  }
  method {:test} GtReportsGreaterThan() {
    expect !gt(3, 5);
    expect gt(6, 4);
    expect !gt(7, 7);
  }
  // "is curried": `gt(20)`
  method {:test} GtIsCurried() {
    var lt20 := (x: int) => gt(20, x);
    expect lt20(10);
    expect !lt20(20);
    expect !lt20(25);
  }
  // v0.6.0: "behaves right curried when passed `undefined` for its first
  // argument": `gt(__, 20)`
  method {:test} GtBehavesRightCurriedWithUndefinedFirst() {
    var gt20 := (x: int) => gt(x, 20);
    expect !gt20(10);
    expect !gt20(20);
    expect gt20(25);
  }
  method {:test} GteReportsGreaterOrEqual() {
    expect !gte(3, 5);
    expect gte(6, 4);
    expect gte(7, 7);
  }
  // "is curried": `gte(20)`
  method {:test} GteIsCurried() {
    var lte20 := (x: int) => gte(20, x);
    expect lte20(10);
    expect lte20(20);
    expect !lte20(25);
  }
  // v0.6.0: "behaves right curried when passed `undefined` for its first
  // argument": `gte(__, 20)`
  method {:test} GteBehavesRightCurriedWithUndefinedFirst() {
    var gte20 := (x: int) => gte(x, 20);
    expect !gte20(10);
    expect gte20(20);
    expect gte20(25);
  }

  // describe('max'), describe('min') (the decimal/string cases are not expressible)
  method {:test} MaxCalculatesTheLargestValue() {
    expect max([2, 1, 2, 8, 6, 7, 5, 3, 0, 9]) == 9;
    expect max([7, 22, 11, 34, 17, 52, 26, 13, 40, 20, 10, 5, 16, 8, 4, 2, 1]) == 52;
  }
  // "accepts negative numbers, decimals, and even strings": the negative
  // numbers only, with the decimals -4.3 and -1.1 truncated to ints.
  method {:test} MaxAcceptsNegativeNumbers() {
    expect max([-6, -2, -4, -1, -5]) == -1;
  }
  method {:test} MinCalculatesTheSmallestValue() {
    expect min([2, 1, 2, 8, 6, 7, 5, 3, 0, 9]) == 0;
    expect min([7, 22, 11, 34, 17, 52, 26, 13, 40, 20, 10, 5, 16, 8, 4, 2, 1]) == 1;
  }
  // As above for min.
  method {:test} MinAcceptsNegativeNumbers() {
    expect min([-6, -2, -4, -1, -5]) == -6;
  }

  function Xy(x: int, y: int): map<string, int> { map["x" := x, "y" := y] }
  // `prop('x')`: every record here has an x.
  function X(o: map<string, int>): int { Field(o, "x") }

  // describe('maxWith') (v0.2.0: a key function instead of a comparator)
  method {:test} MaxWithCalculatesTheLargestValueUsingTheKey() {
    expect maxWith(X, [Xy(3, 1), Xy(5, 10), Xy(-2, 0)]) == Some(Xy(5, 10));
  }
  method {:test} MaxWithReturnsUndefinedForTheEmptyList() {
    var empty: seq<map<string, int>> := [];
    expect maxWith(X, empty) == None;
  }
  method {:test} MaxWithIsProperlyCurried() {
    var highestX := (l: seq<map<string, int>>) => maxWith(X, l);
    expect highestX([Xy(3, 1), Xy(5, 10), Xy(-2, 0)]) == Some(Xy(5, 10));
  }

  // describe('minWith')
  method {:test} MinWithCalculatesTheSmallestValueUsingTheKey() {
    expect minWith(X, [Xy(3, 1), Xy(5, 10), Xy(-2, 0)]) == Some(Xy(-2, 0));
  }
  // "returns null for the empty list" checks for undefined
  method {:test} MinWithReturnsUndefinedForTheEmptyList() {
    var empty: seq<map<string, int>> := [];
    expect minWith(X, empty) == None;
  }
  method {:test} MinWithIsProperlyCurried() {
    var lowestX := (l: seq<map<string, int>>) => minWith(X, l);
    expect lowestX([Xy(3, 1), Xy(5, 10), Xy(-2, 0)]) == Some(Xy(-2, 0));
  }
}
