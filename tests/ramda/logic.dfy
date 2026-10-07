// Ramda v0.7.0 test/test.booleans.js, test/test.allany.js and
// test/test.cond.js, transcribed.
// Not transcribed: the short-circuit cases ("does not evaluate the second
// expression"), which detect a call by its side effect, the "reports its
// arity" cases, and v0.5.0's "throws on zero arguments" cases (no-argument
// calls; the `typeof` checks of "is curried" hold by construction). The multi-parameter predicates take their arguments as a
// tuple.

module RamdafTests.Ramda.Logic {
  import opened Ramdaf.List
  import opened Ramdaf.Logic
  import opened Support

  // ---- test.booleans.js ----

  function even(x: int): bool { x % 2 == 0 }
  function gt10(x: int): bool { x > 10 }
  function between(t: (int, int, int)): bool { t.0 < t.1 && t.1 < t.2 }
  function total20(t: (int, int, int)): bool { t.0 + t.1 + t.2 == 20 }

  // describe('or')
  method {:test} OrCombinesTwoPredicates() {
    var f := or(even, gt10);
    expect f(8) == true;
    expect f(13) == true;
    expect f(7) == false;
  }
  method {:test} OrAcceptsMultiParameterFunctions() {
    var f := or(between, total20);
    expect f((4, 5, 8)) == true;
    expect f((12, 2, 6)) == true;
    expect f((7, 5, 1)) == false;
  }

  // v0.5.0: `or(even)(gt10)`
  method {:test} OrIsCurried() {
    var evenOr := (g: int -> bool) => or(even, g);
    expect evenOr(gt10)(11) == true;
    expect evenOr(gt10)(9) == false;
  }

  // describe('and')
  method {:test} AndCombinesTwoPredicates() {
    var f := and(even, gt10);
    expect f(8) == false;
    expect f(13) == false;
    expect f(14) == true;
  }
  method {:test} AndAcceptsMultiParameterFunctions() {
    var f := and(between, total20);
    expect f((4, 5, 11)) == true;
    expect f((12, 2, 6)) == false;
    expect f((5, 6, 15)) == false;
  }

  // v0.5.0: `and(even)(gt10)`
  method {:test} AndIsCurried() {
    var evenAnd := (g: int -> bool) => and(even, g);
    expect evenAnd(gt10)(11) == false;
    expect evenAnd(gt10)(12) == true;
  }

  // describe('not')
  method {:test} NotReversesAPredicate() {
    var f := not(even);
    expect f(8) == false;
    expect f(13) == true;
  }
  method {:test} NotAcceptsAMultiParameterFunction() {
    var f := not(between);
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

  // describe('every') (until v0.4.0 describe('all'); v0.4.1 renamed `all` to
  // `every` and dropped "should be aliased by `every`")
  method {:test} EveryTrueWhenAllSatisfy() { expect every(even, [2, 4, 6, 8, 10, 12]) == true; }
  method {:test} EveryFalseWhenAnyFails() { expect every(even, [2, 4, 6, 8, 9, 10]) == false; }
  method {:test} EveryTrueForTheEmptyList() {
    var empty: seq<int> := [];
    expect every((x: int) => true, empty) == true;
  }
  // v0.5.0: `o.x.length === 3`, `o.x.indexOf('a') > -1`
  method {:test} EveryWorksWithMoreComplexObjects() {
    var xs := [map["x" := "abc"], map["x" := "ade"], map["x" := "fghiajk"]];
    expect every((o: map<string, string>) => "x" in o && |o["x"]| == 3, xs) == false;
    expect every((o: map<string, string>) => "x" in o && 'a' in o["x"], xs) == true;
  }

  // v0.2.2 (the call count is not asserted)
  method {:test} EveryIsAutomaticallyCurried() {
    var allEven := (l: seq<int>) => every(even, l);
    expect allEven([2, 4, 6, 7, 8, 10]) == false;
  }

  // describe('some') (until v0.4.0 describe('any'); v0.4.1 renamed `any` to
  // `some` and dropped "should be aliased by `some`") (`n % 2 === 1`)
  function oddJs(n: int): bool { n % 2 == 1 }

  method {:test} SomeTrueWhenOneSatisfies() { expect some(oddJs, [2, 4, 6, 8, 10, 11, 12]) == true; }
  method {:test} SomeFalseWhenNoneSatisfies() { expect some(oddJs, [2, 4, 6, 8, 10, 12]) == false; }
  // v0.2.2 (the call count is not asserted)
  method {:test} SomeIsAutomaticallyCurried() {
    var anyOdd := (l: seq<int>) => some(oddJs, l);
    expect anyOdd([2, 4, 6, 7, 8, 10]) == true;
  }

  function Person(first: string, last: string): map<string, string> { map["first" := first, "last" := last] }
  // `person.first.charAt(0) === person.last.charAt(0)`
  function alliterative(p: map<string, string>): bool
  { "first" in p && "last" in p && |p["first"]| > 0 && |p["last"]| > 0 && p["first"][0] == p["last"][0] }

  method {:test} SomeWorksWithMoreComplexObjects() {
    var people := [Person("Paul", "Grenier"), Person("Mike", "Hurley"), Person("Will", "Klein")];
    expect some(alliterative, people) == false;
    people := people + [Person("Scott", "Sauyet")];
    expect some(alliterative, people) == true;
  }

  function Teen(name: string, age: int): map<string, Js> { map["name" := Str(name), "age" := Num(age)] }
  function atLeast(age: int): map<string, Js> -> bool
  { (p: map<string, Js>) => "age" in p && p["age"].Num? && p["age"].n >= age }

  method {:test} SomeCanUseAConfigurableFunction() {
    var teens := [Teen("Alice", 14), Teen("Betty", 18), Teen("Cindy", 17)];
    expect some(atLeast(16), teens) == true;
    expect some(atLeast(21), teens) == false;
  }
  method {:test} SomeFalseForTheEmptyList() {
    var empty: seq<int> := [];
    expect some((x: int) => true, empty) == false;
  }

  // ---- test.cond.js (v0.6.0) ----

  // `t = a + 1` (it only meets numbers), `identity`, and the validator
  // `typeof a === 'number'`
  function CondT(a: Js): Js { match a case Num(n) => Num(n + 1) case _ => a }
  function CondId(a: Js): Js { a }
  function IsNumber(a: Js): bool { a.Num? }

  method {:test} CondCallsTheTruthCaseWhenTheValidatorReturnsTruthy() {
    expect cond(IsNumber, CondT, CondId)(Num(10)) == Num(11);
  }

  method {:test} CondCallsTheFalseCaseWhenTheValidatorReturnsFalsey() {
    expect cond(IsNumber, CondT, CondId)(Str("hello")) == Str("hello");
  }

  // `map(cond(isArray, prop('length'), identity))`: the port's `prop` takes a
  // map, so the array's length is a local lambda.
  method {:test} CondCallsTheTrueCaseOnArraysAndTheFalseCaseOnOthers() {
    var len := (a: Js) => if a.Arr? then Num(|a.items|) else a;
    var list := [Arr([Num(1), Num(2), Num(3), Num(4), Num(5)]), Num(10), Arr([Num(0), Num(1)]), Num(15)];
    var arrayToLength := (l: seq<Js>) => mapSeq(cond((a: Js) => a.Arr?, len, CondId), l);
    expect arrayToLength(list) == [Num(5), Num(10), Num(2), Num(15)];
  }

  // The two arguments are a tuple; Ramda's asserts inside the callback become
  // a check of what the callback receives (returned here).
  method {:test} CondPassesTheArgumentsToTheTrueCase() {
    var identity := (p: (int, string)) => p;
    var onTrue := (p: (int, string)) => p;
    expect cond((p: (int, string)) => true, onTrue, identity)((123, "abc")) == (123, "abc");
  }

  method {:test} CondPassesTheArgumentsToTheFalseCase() {
    var identity := (p: (int, string)) => p;
    var onFalse := (p: (int, string)) => p;
    expect cond((p: (int, string)) => false, identity, onFalse)((123, "abc")) == (123, "abc");
  }

  method {:test} CondReturnsACurriedFunction() {
    var ifIsNumber := (tt: Js -> Js, ff: Js -> Js) => cond(IsNumber, tt, ff);
    expect ifIsNumber(CondT, CondId)(Num(15)) == Num(16);
    expect ifIsNumber(CondT, CondId)(Str("hello")) == Str("hello");
  }
}
