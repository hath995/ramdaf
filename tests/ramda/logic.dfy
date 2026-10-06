// Ramda v0.1.1 test/test.booleans.js and test/test.allany.js, transcribed.
// Not transcribed: the "should perform type coersion" cases (operands are
// bool, README "Deviations"), the short-circuit cases that count calls with a
// side effect, and the "reports its arity" cases. The multi-parameter
// predicates take their arguments as a tuple.

module RamdafTests.Ramda.Logic {
  import opened Ramdaf.List
  import opened Ramdaf.Logic
  import opened Support

  // ---- test.booleans.js ----

  // describe('or')
  method {:test} OrMatchesJsOr() {
    expect or(false, true) == true;
    expect or(false, false) == false;
    expect or(true, false) == true;
    expect or(true, true) == true;
  }

  // describe('and')
  method {:test} AndMatchesJsAnd() {
    expect and(false, true) == false;
    expect and(false, false) == false;
    expect and(true, false) == false;
    expect and(true, true) == true;
  }

  // describe('not')
  method {:test} NotMatchesJsNot() {
    expect not(false) == true;
    expect not(true) == false;
  }

  function even(x: int): bool { x % 2 == 0 }
  function gt10(x: int): bool { x > 10 }
  function between(t: (int, int, int)): bool { t.0 < t.1 && t.1 < t.2 }
  function total20(t: (int, int, int)): bool { t.0 + t.1 + t.2 == 20 }

  // describe('orFn')
  method {:test} OrFnCombinesTwoPredicates() {
    var f := orFn(even, gt10);
    expect f(8) == true;
    expect f(13) == true;
    expect f(7) == false;
  }
  method {:test} OrFnAcceptsMultiParameterFunctions() {
    var f := orFn(between, total20);
    expect f((4, 5, 8)) == true;
    expect f((12, 2, 6)) == true;
    expect f((7, 5, 1)) == false;
  }

  // describe('andFn')
  method {:test} AndFnCombinesTwoPredicates() {
    var f := andFn(even, gt10);
    expect f(8) == false;
    expect f(13) == false;
    expect f(14) == true;
  }
  method {:test} AndFnAcceptsMultiParameterFunctions() {
    var f := andFn(between, total20);
    expect f((4, 5, 11)) == true;
    expect f((12, 2, 6)) == false;
    expect f((5, 6, 15)) == false;
  }

  // describe('notFn')
  method {:test} NotFnReversesAPredicate() {
    var f := notFn(even);
    expect f(8) == false;
    expect f(13) == true;
  }
  method {:test} NotFnAcceptsAMultiParameterFunction() {
    var f := notFn(between);
    expect f((4, 5, 11)) == false;
    expect f((12, 2, 6)) == true;
  }

  // `!!(n % 2)`
  function odd(n: int): bool { n % 2 != 0 }

  // describe('allPredicates')
  method {:test} AllPredicatesReportsWhetherAllAreSatisfied() {
    var ok := allPredicates([odd, (n: int) => n < 20, (n: int) => n > 5]);
    expect ok(7) == true;
    expect ok(9) == true;
    expect ok(10) == false;
    expect ok(3) == false;
    expect ok(21) == false;
  }
  method {:test} AllPredicatesDoesNotHaveToBeCurried() {
    expect allPredicates([odd, (n: int) => n > 5])(3) == false;
    expect allPredicates([odd, (n: int) => n > 5])(7) == true;
  }

  // describe('anyPredicates')
  method {:test} AnyPredicatesReportsWhetherAnyIsSatisfied() {
    var ok := anyPredicates([odd, (n: int) => n > 20, (n: int) => n < 5]);
    expect ok(7) == true;
    expect ok(9) == true;
    expect ok(10) == false;
    expect ok(18) == false;
    expect ok(3) == true;
    expect ok(22) == true;
  }
  method {:test} AnyPredicatesDoesNotHaveToBeCurried() {
    expect anyPredicates([odd, (n: int) => n < 5])(3) == true;
    expect anyPredicates([odd, (n: int) => n < 5])(22) == false;
  }

  // ---- test.allany.js ----

  // describe('all')
  method {:test} AllTrueWhenAllSatisfy() { expect all(even, [2, 4, 6, 8, 10, 12]) == true; }
  method {:test} AllFalseWhenAnyFails() { expect all(even, [2, 4, 6, 8, 9, 10]) == false; }
  method {:test} AllTrueForTheEmptyList() {
    var empty: seq<int> := [];
    expect all((x: int) => true, empty) == true;
  }
  method {:test} AllIsAliasedByEvery() { expect every(even, [2, 4, 6, 8, 10]) == true; }

  // describe('any') (`n % 2 === 1`)
  function oddJs(n: int): bool { n % 2 == 1 }

  method {:test} AnyTrueWhenOneSatisfies() { expect any(oddJs, [2, 4, 6, 8, 10, 11, 12]) == true; }
  method {:test} AnyFalseWhenNoneSatisfies() { expect any(oddJs, [2, 4, 6, 8, 10, 12]) == false; }

  function Person(first: string, last: string): map<string, string> { map["first" := first, "last" := last] }
  // `person.first.charAt(0) === person.last.charAt(0)`
  function alliterative(p: map<string, string>): bool
  { "first" in p && "last" in p && |p["first"]| > 0 && |p["last"]| > 0 && p["first"][0] == p["last"][0] }

  method {:test} AnyWorksWithMoreComplexObjects() {
    var people := [Person("Paul", "Grenier"), Person("Mike", "Hurley"), Person("Will", "Klein")];
    expect any(alliterative, people) == false;
    people := people + [Person("Scott", "Sauyet")];
    expect any(alliterative, people) == true;
  }

  function Teen(name: string, age: int): map<string, Js> { map["name" := Str(name), "age" := Num(age)] }
  function atLeast(age: int): map<string, Js> -> bool
  { (p: map<string, Js>) => "age" in p && p["age"].Num? && p["age"].n >= age }

  method {:test} AnyCanUseAConfigurableFunction() {
    var teens := [Teen("Alice", 14), Teen("Betty", 18), Teen("Cindy", 17)];
    expect any(atLeast(16), teens) == true;
    expect any(atLeast(21), teens) == false;
  }
  method {:test} AnyFalseForTheEmptyList() {
    var empty: seq<int> := [];
    expect any((x: int) => true, empty) == false;
  }
  method {:test} AnyIsAliasedBySome() { expect some(oddJs, [2, 4, 6, 8, 10, 11, 12]) == true; }
}
