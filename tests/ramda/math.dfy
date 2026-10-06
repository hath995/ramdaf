// Ramda v0.1.2 test/test.math.js, transcribed. Numbers are ints (real for
// division); the string comparisons in lt/lte/gt/gte and the decimal/string
// cases of max/min are not expressible (README "Deviations").

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
  method {:test} SubtractIsAutomaticallyCurried() { var ninesCompl := (x: int) => subtract(9, x); expect ninesCompl(6) == 3; }

  // describe('subtractN')
  method {:test} SubtractNSubtractsTwoNumbers() { expect subtractN(7, 22) == 15; }
  method {:test} SubtractNIsAutomaticallyCurried() { var minus6 := (x: int) => subtractN(6, x); expect minus6(9) == 3; }

  // describe('divide')
  method {:test} DivideDividesTwoNumbers() { expect divide(28.0, 7.0) == 4.0; }
  method {:test} DivideIsAutomaticallyCurried() {
    var divideInto120 := (x: real) requires x != 0.0 => divide(120.0, x);
    expect divideInto120(40.0) == 3.0;
  }

  // describe('divideBy')
  method {:test} DivideByDividesTwoNumbers() { expect divideBy(7.0, 28.0) == 4.0; }
  method {:test} DivideByIsAutomaticallyCurried() { var half := (x: real) => divideBy(2.0, x); expect half(40.0) == 20.0; }

  // describe('modulo')
  method {:test} ModuloDividesAndReturnsTheRemainder() {
    expect modulo(100, 2) == 0;
    expect modulo(100, 3) == 1;
    expect modulo(100, 17) == 15;
  }
  method {:test} ModuloIsAutomaticallyCurried() {
    var modOf120by := (x: int) requires x != 0 => modulo(120, x);
    expect modOf120by(3) == 0;
    expect modOf120by(19) == 6;
  }
  method {:test} ModuloPreservesJsModuloForNegativeNumbers() {
    expect modulo(-5, 4) == -1;
  }

  // describe('moduloBy')
  method {:test} ModuloByDividesTheSecondByTheFirst() {
    expect moduloBy(2, 100) == 0;
    expect moduloBy(3, 100) == 1;
    expect moduloBy(17, 100) == 15;
  }
  method {:test} ModuloByIsAutomaticallyCurried() {
    var isOdd := (x: int) => moduloBy(2, x);
    expect isOdd(3) == 1;
    expect isOdd(198) == 0;
  }
  method {:test} ModuloByPreservesJsModuloForNegativeNumbers() {
    expect moduloBy(4, -5) == -1;
  }

  // describe('sum'), describe('product')
  method {:test} SumAddsTheArray() { expect sum([1, 2, 3, 4]) == 10; }
  method {:test} ProductMultipliesTheArray() { expect product([1, 2, 3, 4]) == 24; }

  // describe('lt') etc. (the string cases are not expressible)
  method {:test} LtReportsLessThan() {
    expect lt(3, 5);
    expect !lt(6, 4);
    expect !lt(7, 7);
  }
  method {:test} LtIsAutomaticallyCurried() {
    var atLeast20 := (x: int) => lt(20, x);
    expect !atLeast20(10);
    expect !atLeast20(20);
    expect atLeast20(25);
  }
  method {:test} LteReportsLessOrEqual() {
    expect lte(3, 5);
    expect !lte(6, 4);
    expect lte(7, 7);
  }
  method {:test} LteIsAutomaticallyCurried() {
    var greaterThan20 := (x: int) => lte(20, x);
    expect !greaterThan20(10);
    expect greaterThan20(20);
    expect greaterThan20(25);
  }
  method {:test} GtReportsGreaterThan() {
    expect !gt(3, 5);
    expect gt(6, 4);
    expect !gt(7, 7);
  }
  method {:test} GtIsAutomaticallyCurried() {
    var lessThan20 := (x: int) => gt(20, x);
    expect lessThan20(10);
    expect !lessThan20(20);
    expect !lessThan20(25);
  }
  method {:test} GteReportsGreaterOrEqual() {
    expect !gte(3, 5);
    expect gte(6, 4);
    expect gte(7, 7);
  }
  method {:test} GteIsAutomaticallyCurried() {
    var upTo20 := (x: int) => gte(20, x);
    expect upTo20(10);
    expect upTo20(20);
    expect !upTo20(25);
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
  function ByX(a: map<string, int>, b: map<string, int>): int { Field(a, "x") - Field(b, "x") }

  // describe('maxWith')
  method {:test} MaxWithUsesTheComparator() {
    expect maxWith(ByX, [Xy(3, 1), Xy(5, 10), Xy(-2, 0)]) == Some(Xy(5, 10));
  }
  method {:test} MaxWithReturnsNullForTheEmptyList() {
    var empty: seq<map<string, int>> := [];
    expect maxWith(ByX, empty) == None;
  }
  method {:test} MaxWithIsProperlyCurried() {
    var highestX := (l: seq<map<string, int>>) => maxWith(ByX, l);
    expect highestX([Xy(3, 1), Xy(5, 10), Xy(-2, 0)]) == Some(Xy(5, 10));
  }

  // describe('minWith')
  method {:test} MinWithUsesTheComparator() {
    expect minWith(ByX, [Xy(3, 1), Xy(5, 10), Xy(-2, 0)]) == Some(Xy(-2, 0));
  }
  method {:test} MinWithReturnsNullForTheEmptyList() {
    var empty: seq<map<string, int>> := [];
    expect minWith(ByX, empty) == None;
  }
  method {:test} MinWithIsProperlyCurried() {
    var lowestX := (l: seq<map<string, int>>) => minWith(ByX, l);
    expect lowestX([Xy(3, 1), Xy(5, 10), Xy(-2, 0)]) == Some(Xy(-2, 0));
  }
}
