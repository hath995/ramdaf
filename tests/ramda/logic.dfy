// Ramda v0.29.1 test/both.js, either.js, complement.js, and.js, or.js,
// not.js, allPass.js, anyPass.js, all.js, any.js, ifElse.js, cond.js,
// defaultTo.js, propSatisfies.js, when.js, unless.js, until.js and xor.js (until v0.8.0
// test.booleans.js, test.allany.js and test.cond.js), transcribed. (v0.16.0
// passes cond's pairs as one list, `R.cond([[p, f], …])`, the port's form
// all along.) Not transcribed: the short-circuit cases ("does not evaluate the second
// expression", "short-circuits on first false value"), which detect a call by
// its side effect (since v0.19.0 both's and either's call the combined
// function, which v0.18.0's `lift` versions did not short-circuit), the
// "reports its arity" cases, and the "throws on zero
// arguments" cases (no-argument calls, until v0.10.0; the `typeof` checks of "is curried"
// hold by construction, and so does cond's "returns a function"). The
// multi-parameter predicates take their arguments as a tuple. cond's
// "forwards all arguments" case checks `arguments.length`, here the tuple
// that reaches the transformer. (v0.8.0 renamed test.cond.js's
// describe('cond') to describe('ifElse') and added a describe('cond') for
// the new function; v0.9.0 renamed the allPredicates, anyPredicates, every
// and some describes to allPass, anyPass, all and any, and removed ifElse's
// "is aliased by `if`" with the alias; v0.12.0 moved the and, or and not
// describes to both, either and complement with the functions and gave the
// value operators and, or and not new describes, whose number, string and
// array operands are not bool (README "Deviations"); all.js's and any.js's
// new `into` and transformer `it`s (transducers, not portable) and ifElse.js's
// arity and curried `it`s (`R.gt`, `R.subtract` on two arguments) are not
// transcribed, nor are v0.14.0's "dispatches to `and` method" and
// "dispatches to `or` method", whose operands are objects with methods, and
// which v0.18.0 removed with the dispatch. v0.18.0 makes and.js and or.js
// bool-only, all transcribed; it drops allPass's and anyPass's "does not
// have to be curried" (`allPass(preds, v)` now ignores v) and adds "returns
// true on empty predicate list" and "returns a curried function whose arity
// matches that of the highest-arity predicate", whose uncurried call is
// transcribed over a tuple (its `.length` and curried calls are not).)
// defaultTo's values are Js values (the default 42 and the values differ in
// type), and its null and undefined are both None (README "Deviations");
// v0.18.0's `defaultTo42(NaN)` line is not transcribed (no NaN). when.js's
// and unless.js's values are Js values too: `R.is(Number)` and
// `R.isArrayLike` (since v0.24.0 the private `_isArrayLike`, which the tests
// import) are not portable, and `R.of` changes the value's type, so
// they are local functions on Js. v0.20.0's fantasy-land `it`s of both,
// either and complement (sanctuary's `Just` and `Nothing`: README
// "Deviations") and cond's "retains highest predicate arity" (arity) are
// not transcribed. until.js's calls pass a fuel of 100 (README
// "Deviations"), and "works with lists" runs over `Tree<int>`, where
// `R.isArrayLike` of an element is `Node?`.
// (v0.26.0 removed the per-function "is curried" `it`s of both, either, and,
// or, all and any, with their transcriptions here.)

module RamdafTests.Ramda.Logic {
  import opened Ramdaf.Prelude
  import opened Ramdaf.List
  import opened Ramdaf.Logic
  import opened Support

  // ---- and.js, or.js, not.js, allPass.js, anyPass.js ----

  function even(x: int): bool { x % 2 == 0 }
  function gt10(x: int): bool { x > 10 }
  function between(t: (int, int, int)): bool { t.0 < t.1 && t.1 < t.2 }
  function total20(t: (int, int, int)): bool { t.0 + t.1 + t.2 == 20 }

  // describe('both') (v0.12.0; describe('and') until v0.11.0)
  method {:test} BothCombinesTwoPredicates() {
    var f := both(even, gt10);
    expect f(8) == false;
    expect f(13) == false;
    expect f(14) == true;
  }
  method {:test} BothAcceptsMultiParameterFunctions() {
    var f := both(between, total20);
    expect f((4, 5, 11)) == true;
    expect f((12, 2, 6)) == false;
    expect f((5, 6, 15)) == false;
  }

  // describe('either') (v0.12.0; describe('or') until v0.11.0)
  method {:test} EitherCombinesTwoPredicates() {
    var f := either(even, gt10);
    expect f(8) == true;
    expect f(13) == true;
    expect f(7) == false;
  }
  method {:test} EitherAcceptsMultiParameterFunctions() {
    var f := either(between, total20);
    expect f((4, 5, 8)) == true;
    expect f((12, 2, 6)) == true;
    expect f((7, 5, 1)) == false;
  }

  // describe('complement') (v0.12.0; describe('not') until v0.11.0)
  method {:test} ComplementReversesAPredicate() {
    var f := complement(even);
    expect f(8) == false;
    expect f(13) == true;
  }
  method {:test} ComplementAcceptsAMultiParameterFunction() {
    var f := complement(between);
    expect f((4, 5, 11)) == false;
    expect f((12, 2, 6)) == true;
  }

  // describe('and') (v0.12.0, the value operator; until v0.17.1 "compares
  // two values with js &&" used numbers and an array, `and(1, 0)` → 0, which
  // are not bool operands)
  method {:test} AndComparesTwoValuesWithJsAnd() {
    expect and(true, true) == true;
    expect and(true, false) == false;
    expect and(false, true) == false;
    expect and(false, false) == false;
  }

  // describe('or') (v0.12.0; v0.18.0's "compares two values with js &&", so
  // titled, is or's truth table; until v0.17.1 its operands were numbers,
  // strings and an array)
  method {:test} OrComparesTwoValuesWithJsOr() {
    expect or(true, true) == true;
    expect or(true, false) == true;
    expect or(false, true) == true;
    expect or(false, false) == false;
  }

  // describe('not') (v0.12.0): "reverses argument", its bool line
  // (`not(1)` and `not('')` are not bool)
  method {:test} NotReversesArgument() {
    expect not(false) == true;
  }

  // `!!(n % 2)`
  function odd(n: int): bool { n % 2 != 0 }

  // describe('allPass') (describe('allPredicates') until v0.8.0)
  method {:test} AllPassReportsWhetherAllAreSatisfied() {
    var ok := allPass([odd, (n: int) => n < 20, (n: int) => n > 5]);
    expect ok(7) == true;
    expect ok(9) == true;
    expect ok(10) == false;
    expect ok(3) == false;
    expect ok(21) == false;
  }
  method {:test} AllPassReturnsTrueOnEmptyPredicateList() {
    var none: seq<int -> bool> := [];
    expect allPass(none)(3) == true;
  }

  // `plusEq(w, x, y, z) = w + x === y + z`; the four arguments are a tuple,
  // which `odd` and `gt5` read the first of
  function plusEq(t: (int, int, int, int)): bool { t.0 + t.1 == t.2 + t.3 }

  // "returns a curried function whose arity matches that of the
  // highest-arity predicate" (v0.18.0): its uncurried call
  method {:test} AllPassReturnsACurriedFunctionOfTheHighestArity() {
    var ok := allPass([(t: (int, int, int, int)) => odd(t.0), (t: (int, int, int, int)) => t.0 > 5, plusEq]);
    expect ok((9, 9, 9, 9)) == true;
  }

  // describe('anyPass') (describe('anyPredicates') until v0.8.0)
  method {:test} AnyPassReportsWhetherAnyIsSatisfied() {
    var ok := anyPass([odd, (n: int) => n > 20, (n: int) => n < 5]);
    expect ok(7) == true;
    expect ok(9) == true;
    expect ok(10) == false;
    expect ok(18) == false;
    expect ok(3) == true;
    expect ok(22) == true;
  }
  method {:test} AnyPassReturnsFalseForAnEmptyPredicateList() {
    var none: seq<int -> bool> := [];
    expect anyPass(none)(3) == false;
  }

  method {:test} AnyPassReturnsACurriedFunctionOfTheHighestArity() {
    var ok := anyPass([(t: (int, int, int, int)) => odd(t.0), (t: (int, int, int, int)) => t.0 < 5, plusEq]);
    expect ok((6, 7, 8, 9)) == false;
  }

  // ---- all.js, any.js ----

  // describe('all') (describe('every') from v0.4.1 to v0.8.0; v0.4.1 had
  // renamed `all` to `every` and dropped "should be aliased by `every`")
  method {:test} AllTrueWhenAllSatisfy() { expect all(even, [2, 4, 6, 8, 10, 12]) == true; }
  method {:test} AllFalseWhenAnyFails() { expect all(even, [2, 4, 6, 8, 9, 10]) == false; }
  method {:test} AllTrueForTheEmptyList() {
    var empty: seq<int> := [];
    expect all((x: int) => true, empty) == true;
  }
  // v0.5.0: `o.x.length === 3`, `o.x.indexOf('a') > -1`
  method {:test} AllWorksWithMoreComplexObjects() {
    var xs := [map["x" := "abc"], map["x" := "ade"], map["x" := "fghiajk"]];
    expect all((o: map<string, string>) => "x" in o && |o["x"]| == 3, xs) == false;
    expect all((o: map<string, string>) => "x" in o && 'a' in o["x"], xs) == true;
  }

  // describe('any') (describe('some') from v0.4.1 to v0.8.0; v0.4.1 had
  // renamed `any` to `some` and dropped "should be aliased by `some`") (`n % 2 === 1`)
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

  // ---- ifElse.js, cond.js (test.cond.js from v0.6.0 to v0.8.0) ----

  // describe('ifElse') (describe('cond') from v0.6.0 to v0.7.2): `t = a + 1`
  // (it only meets numbers), `identity`, and the validator
  // `typeof a === 'number'`
  function CondT(a: Js): Js { match a case Num(n) => Num(n + 1) case _ => a }
  function CondId(a: Js): Js { a }
  function IsNumber(a: Js): bool { a.Num? }

  method {:test} IfElseCallsTheTruthCaseWhenTheValidatorReturnsTruthy() {
    expect ifElse(IsNumber, CondT, CondId)(Num(10)) == Num(11);
  }

  method {:test} IfElseCallsTheFalseCaseWhenTheValidatorReturnsFalsey() {
    expect ifElse(IsNumber, CondT, CondId)(Str("hello")) == Str("hello");
  }

  // `map(ifElse(isArray, prop('length'), identity))`: the port's `prop` takes
  // a map, so the array's length is a local lambda.
  method {:test} IfElseCallsTheTrueCaseOnArraysAndTheFalseCaseOnOthers() {
    var len := (a: Js) => if a.Arr? then Num(|a.items|) else a;
    var list := [Arr([Num(1), Num(2), Num(3), Num(4), Num(5)]), Num(10), Arr([Num(0), Num(1)]), Num(15)];
    var arrayToLength := (l: seq<Js>) => mapSeq(ifElse((a: Js) => a.Arr?, len, CondId), l);
    expect arrayToLength(list) == [Num(5), Num(10), Num(2), Num(15)];
  }

  // The two arguments are a tuple; Ramda's asserts inside the callback become
  // a check of what the callback receives (returned here).
  method {:test} IfElsePassesTheArgumentsToTheTrueCase() {
    var identity := (p: (int, string)) => p;
    var onTrue := (p: (int, string)) => p;
    expect ifElse((p: (int, string)) => true, onTrue, identity)((123, "abc")) == (123, "abc");
  }

  method {:test} IfElsePassesTheArgumentsToTheFalseCase() {
    var identity := (p: (int, string)) => p;
    var onFalse := (p: (int, string)) => p;
    expect ifElse((p: (int, string)) => false, identity, onFalse)((123, "abc")) == (123, "abc");
  }

  method {:test} IfElseReturnsACurriedFunction() {
    var ifIsNumber := (tt: Js -> Js, ff: Js -> Js) => ifElse(IsNumber, tt, ff);
    expect ifIsNumber(CondT, CondId)(Num(15)) == Num(16);
    expect ifIsNumber(CondT, CondId)(Str("hello")) == Str("hello");
  }

  // describe('cond') (v0.8.0): a list of [predicate, transformer] pairs;
  // undefined (no predicate matches) is None. `R.eq(0)` is `t => t == 0`,
  // `R.always(v)` is `_ => v` and `R.alwaysTrue` is `_ => true`.
  method {:test} CondReturnsAConditionalFunction() {
    var fn := cond([((t: int) => t == 0, (t: int) => "water freezes at 0\U{00B0}C"),
                    ((t: int) => t == 100, (t: int) => "water boils at 100\U{00B0}C"),
                    ((t: int) => true, (t: int) => "nothing special happens at " + NumStr(t) + "\U{00B0}C")]);
    expect fn(0) == Some("water freezes at 0\U{00B0}C");
    expect fn(50) == Some("nothing special happens at 50\U{00B0}C");
    expect fn(100) == Some("water boils at 100\U{00B0}C");
  }

  method {:test} CondReturnsUndefinedIfNoPredicateMatches() {
    var fn := cond([((s: string) => s == "foo", (s: string) => 1),
                    ((s: string) => s == "bar", (s: string) => 2)]);
    expect fn("quux") == None;
  }

  // `fn()` is `fn(())`
  method {:test} CondPredicatesAreTestedInOrder() {
    var fn := cond([((u: ()) => true, (u: ()) => "foo"),
                    ((u: ()) => true, (u: ()) => "bar"),
                    ((u: ()) => true, (u: ()) => "baz")]);
    expect fn(()) == Some("foo");
  }

  // `fn(21, 42, 84)`: the arguments are a tuple, and the transformer returns
  // what it receives (Ramda's returns `arguments.length`, 3).
  method {:test} CondForwardsAllArgumentsToPredicatesAndToTransformers() {
    var fn := cond([((t: (int, int, int)) => t.1 == 42, (t: (int, int, int)) => t)]);
    expect fn((21, 42, 84)) == Some((21, 42, 84));
  }

  // ---- defaultTo.js (v0.10.0) ----

  // `defaultTo42 = defaultTo(42)`
  function DefaultTo42(v: Option<Js>): Js { defaultTo(Num(42), v) }

  // `defaultTo42(null)` and `defaultTo42(undefined)`
  method {:test} DefaultToReturnsTheDefaultValueIfInputIsNullOrUndefined() {
    expect DefaultTo42(None) == Num(42);
  }

  method {:test} DefaultToReturnsTheInputValueIfItIsNotNullOrUndefined() {
    expect DefaultTo42(Some(Str("a real value"))) == Str("a real value");
  }

  method {:test} DefaultToReturnsTheInputValueEvenIfItIsConsideredFalsy() {
    expect DefaultTo42(Some(Str(""))) == Str("");
    expect DefaultTo42(Some(Num(0))) == Num(0);
    expect DefaultTo42(Some(Bool(false))) == Bool(false);
    expect DefaultTo42(Some(Arr([]))) == Arr([]);
  }

  method {:test} DefaultToCanBeCalledWithBothArgumentsDirectly() {
    expect defaultTo(Num(42), None) == Num(42);
    expect defaultTo(Num(42), Some(Str("a real value"))) == Str("a real value");
  }

  // describe('propSatisfies') (v0.16.0): `isPositive(n) = n > 0`, which
  // gets the property, None when it is absent (`undefined > 0` is false)
  function IsPositive(n: Option<int>): bool { n.Some? && n.value > 0 }

  method {:test} PropSatisfiesReturnsTrueIfThePropertySatisfiesThePredicate() {
    expect propSatisfies(IsPositive, "x", map["x" := 1, "y" := 0]) == true;
  }

  method {:test} PropSatisfiesReturnsFalseOtherwise() {
    expect propSatisfies(IsPositive, "y", map["x" := 1, "y" := 0]) == false;
  }

  // ---- when.js, unless.js (v0.18.0) ----

  // `R.isArrayLike` on the values these tests use (`R.is(Number)` is
  // IsNumber, above)
  function IsArrayLike(v: Js): bool { v.Arr? }

  // describe('when'): `when(is(Number), add(1))`
  function AddOne(v: Js): Js { if v.Num? then Num(v.n + 1) else v }

  method {:test} WhenCallsTheWhenTrueFunctionIfTheValidatorReturnsATruthyValue() {
    expect when(IsNumber, AddOne, Num(10)) == Num(11);
  }

  method {:test} WhenReturnsTheArgumentUnmodifiedIfTheValidatorReturnsAFalseyValue() {
    expect when(IsNumber, AddOne, Str("hello")) == Str("hello");
  }

  // `ifIsNumber = when(is(Number))`
  method {:test} WhenReturnsACurriedFunction() {
    var ifIsNumber := (f: Js -> Js) => ((x: Js) => when(IsNumber, f, x));
    expect ifIsNumber(AddOne)(Num(15)) == Num(16);
    expect ifIsNumber(AddOne)(Str("hello")) == Str("hello");
  }

  // describe('unless'): `unless(isArrayLike, of)`, `R.of` making a list
  // (since v0.29.0 `ofArray = R.of(Array)`)
  function Of(v: Js): Js { Arr([v]) }

  method {:test} UnlessCallsTheWhenFalseFunctionIfTheValidatorReturnsAFalseyValue() {
    expect unless(IsArrayLike, Of, Num(10)) == Arr([Num(10)]);
  }

  method {:test} UnlessReturnsTheArgumentUnmodifiedIfTheValidatorReturnsATruthyValue() {
    expect unless(IsArrayLike, Of, Arr([Num(10)])) == Arr([Num(10)]);
  }

  // `unless(isArrayLike)(of)`
  method {:test} UnlessReturnsACurriedFunction() {
    var unlessArrayLike := (f: Js -> Js) => ((x: Js) => unless(IsArrayLike, f, x));
    expect unlessArrayLike(Of)(Num(10)) == Arr([Num(10)]);
    expect unlessArrayLike(Of)(Arr([Num(10)])) == Arr([Num(10)]);
  }

  // ---- until.js (v0.20.0) ----

  // `R.gt(R.__, 100)`, `R.multiply(2)`
  method {:test} UntilAppliesFnUntilPredIsSatisfied() {
    expect until((x: int) => x > 100, (x: int) => 2 * x, 1, 100) == 128;
  }

  // `R.until(R.none(R.isArrayLike), R.unnest)([1, [2], [[3]]])`
  method {:test} UntilWorksWithLists() {
    var noNodes := (l: seq<Tree<int>>) => none((t: Tree<int>) => t.Node?, l);
    expect until(noNodes, (l: seq<Tree<int>>) => unnest(l), [Leaf(1), Node([Leaf(2)]), Node([Node([Leaf(3)])])], 100) ==
      [Leaf(1), Leaf(2), Leaf(3)];
  }

  // `R.until(R.T, R.T, false)`
  method {:test} UntilIgnoresFnIfPredicateIsAlwaysTrue() {
    expect until((x: bool) => true, (x: bool) => true, false, 100) == false;
  }

  // ---- xor.js (v0.27.0). Its truthy and falsy `it`s use non-bool operands
  // (JS truthiness), which the bool operands exclude, as for and and or. ----

  method {:test} XorComparesTwoValuesWithExclusiveOr() {
    expect xor(true, true) == false;
    expect xor(true, false) == true;
    expect xor(false, true) == true;
    expect xor(false, false) == false;
  }

  // `R.xor()(a)(b)`: the call with no arguments returns xor itself, which
  // the port has no form for; the curried calls are lambdas
  method {:test} XorReturnsACurriedFunction() {
    var x := (a: bool) => ((b: bool) => xor(a, b));
    expect x(true)(true) == false;
    expect x(true)(false) == true;
    expect x(false)(true) == true;
    expect x(false)(false) == false;
  }
}
