// Ramda v0.25.0 test/add.js, multiply.js, subtract.js, divide.js, modulo.js,
// mathMod.js, sum.js, product.js, lt.js, lte.js, gt.js, gte.js, max.js,
// min.js, maxBy.js, minBy.js, inc.js, dec.js, negate.js, mean.js and
// median.js (until v0.8.0 test.math.js), transcribed. Numbers are ints (real
// for division and for mean's and median's results); the string comparisons in lt/lte/gt/gte and the Date/string
// cases of max/min are not expressible (README "Deviations"). `subtract`,
// `divide`, `modulo`, `mathMod`, `lt`, `lte`, `gt` and `gte` were
// `op`-curried until v0.10.0 and are `_curry2` since v0.11.0, with the same
// sections: since v0.6.0 one argument fixes the first parameter again
// (`subtract(9)` is `x => 9 - x`), and `f(__, b)` with the placeholder `__`
// (undefined until v0.8.0; since v0.9.0 the object `R.__`) fixes the second
// (in v0.5.0 alone, one argument fixed the second and `f(a, _)` the first,
// and Ramda's `it` names had left and right the other way round). The lambdas follow what the code computes. Not
// transcribed: mathMod's "requires integer arguments" (string and fractional
// arguments, which give NaN); the last two asserts of its "behaves
// differently than JS modulo" (17.2 is fractional, and since v0.4.2
// `mathMod(17, -5)` is NaN: a modulus below 1 is outside the domain, README)
// and the four NaN asserts of v0.4.2's "computes the true modulo function"
// (`mathMod(17, -5)`, `mathMod(17, 0)` and fractional arguments); v0.4.0's 13
// "throws if given no arguments" cases (no-argument calls; v0.11.0 removed
// them); mean's and median's "returns NaN for an empty list" (outside the
// domain, README) and "handles array-like object" (an `arguments` object);
// v0.20.0's "coerces its arguments to numbers" of add and subtract
// (strings, booleans, null, undefined and Dates; README "Deviations").
// (v0.5.0
// removed subtractN, divideBy and moduloBy with their describes; v0.8.0
// renamed the maxWith and minWith describes to maxBy and minBy.)

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
  // v0.6.0: "behaves right curried when passed `R.__` for its first
  // argument" ("… `undefined` …" until v0.8.0): `subtract(R.__, 5)`
  method {:test} SubtractBehavesRightCurriedWithPlaceholderFirst() { var minus5 := (x: int) => subtract(x, 5); expect minus5(17) == 12; }

  // describe('divide')
  method {:test} DivideDividesTwoNumbers() { expect divide(28.0, 7.0) == 4.0; }
  // "is curried": `divide(28)`
  method {:test} DivideIsCurried() {
    var into28 := (x: real) requires x != 0.0 => divide(28.0, x);
    expect into28(7.0) == 4.0;
  }
  // v0.6.0: "behaves right curried when passed `R.__` for its first
  // argument" ("… `undefined` …" until v0.8.0): `divide(R.__, 2)`
  method {:test} DivideBehavesRightCurriedWithPlaceholderFirst() {
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
  // v0.6.0: "behaves right curried when passed `R.__` for its first
  // argument" ("… `undefined` …" until v0.8.0): `modulo(R.__, 2)`
  method {:test} ModuloBehavesRightCurriedWithPlaceholderFirst() {
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
  // v0.6.0: "behaves right curried when passed `R.__` for its first
  // argument" ("… `undefined` …" until v0.8.0), which calls
  // `modulo(R.__, 5)`, not mathMod
  method {:test} MathModBehavesRightCurriedWithPlaceholderFirst() {
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
  // v0.6.0: "behaves right curried when passed `R.__` for its first
  // argument" ("… `undefined` …" until v0.8.0): `lt(__, 5)`
  method {:test} LtBehavesRightCurriedWithPlaceholderFirst() {
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
  // v0.6.0: "behaves right curried when passed `R.__` for its first
  // argument" ("… `undefined` …" until v0.8.0): `lte(__, 20)`
  method {:test} LteBehavesRightCurriedWithPlaceholderFirst() {
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
  // v0.6.0: "behaves right curried when passed `R.__` for its first
  // argument" ("… `undefined` …" until v0.8.0): `gt(__, 20)`
  method {:test} GtBehavesRightCurriedWithPlaceholderFirst() {
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
  // v0.6.0: "behaves right curried when passed `R.__` for its first
  // argument" ("… `undefined` …" until v0.8.0): `gte(__, 20)`
  method {:test} GteBehavesRightCurriedWithPlaceholderFirst() {
    var gte20 := (x: int) => gte(x, 20);
    expect !gte20(10);
    expect gte20(20);
    expect gte20(25);
  }

  // describe('max'), describe('min'): rewritten in v0.16.0 for the binary
  // functions (until v0.15.1 they took a list: "calculates the largest
  // value of a list", "finds max in any position", "accepts negative
  // numbers, decimals, and even strings", "returns -Infinity for an empty
  // list" and "returns a number"). Their "works for any orderable type"
  // compares Dates and strings, not ints (README "Deviations").
  method {:test} MaxReturnsTheLargerOfItsTwoArguments() {
    expect max(-7, 7) == 7;
    expect max(7, -7) == 7;
  }
  method {:test} MinReturnsTheSmallerOfItsTwoArguments() {
    expect min(-7, 7) == -7;
    expect min(7, -7) == -7;
  }

  function Xy(x: int, y: int): map<string, int> { map["x" := x, "y" := y] }
  // `prop('x')`: every record here has an x.
  function X(o: map<string, int>): int { Field(o, "x") }

  // describe('maxBy') (describe('maxWith') until v0.7.2), describe('minBy'):
  // rewritten in v0.16.0 for the binary functions (until v0.15.1 "calculates
  // the largest (smallest) value of a list using the supplied comparator",
  // "returns undefined (null) for the empty list" and "is curried"); `n => n
  // * n` and `prop('x')`.
  method {:test} MaxByReturnsTheLargerValueAsDeterminedByTheFunction() {
    expect maxBy((n: int) => n * n, -3, 2) == -3;
    expect maxBy(X, Xy(3, 1), Xy(5, 10)) == Xy(5, 10);
  }
  method {:test} MinByReturnsTheSmallerValueAsDeterminedByTheFunction() {
    expect minBy((n: int) => n * n, -3, 2) == 2;
    expect minBy(X, Xy(3, 1), Xy(5, 10)) == Xy(3, 1);
  }

  // describe('inc') (v0.9.0): its int lines (12.34 and the infinities are
  // not ints)
  method {:test} IncIncrementsItsArgument() {
    expect inc(-1) == 0;
    expect inc(0) == 1;
    expect inc(1) == 2;
  }

  // describe('dec') (v0.9.0)
  method {:test} DecDecrementsItsArgument() {
    expect dec(-1) == -2;
    expect dec(0) == -1;
    expect dec(1) == 0;
  }

  // describe('negate') (v0.9.0): its int lines (not the Infinity ones).
  // Since v0.18.0 the test compares with `R.toString`, which tells `-0` from
  // `0`: `negate(-0)` is `0` and `negate(0)` is `-0`, both 0 here, as an
  // int has no `-0` (README "Deviations"; until v0.17.1 `negate(0) === 0`).
  method {:test} NegateNegatesItsArgument() {
    expect negate(-1) == 1;
    expect negate(-0) == 0;
    expect negate(0) == -0;
    expect negate(1) == -1;
  }

  // ---- mean.js and median.js (v0.14.0) ----

  method {:test} MeanReturnsMeanOfANonemptyList() {
    expect mean([2]) == 2.0;
    expect mean([2, 7]) == 4.5;
    expect mean([2, 7, 9]) == 6.0;
    expect mean([2, 7, 9, 10]) == 7.0;
  }

  method {:test} MedianReturnsMiddleValueOfAnOddLengthList() {
    expect median([2]) == 2.0;
    expect median([2, 9, 7]) == 7.0;
  }

  method {:test} MedianReturnsMeanOfTwoMiddleValuesOfANonemptyEvenLengthList() {
    expect median([7, 2]) == 4.5;
    expect median([7, 2, 10, 9]) == 8.0;
  }
}
